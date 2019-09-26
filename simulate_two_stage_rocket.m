function simulate_two_stage_rocket(stage_1, stage_2, burn_rates, ...
        programmed_turn_height, programmed_turn_angle, ...
        target_altitude, ...
        drift_duration, plot_name)
    %simulate_two_stage_rocket Performs entire simulation, control and plot
    %   Input parameters:
    %   :stage_1        : The first stage of the rocket before ignition.
    %   :stage_2        : The second stage of the rocket before ignition.
    %   :burn_rates     : Array of 3 burn rates; rate before turn, rate
    %                     after turn and max burnrate for second stage.
    %   :programmed_turn_height: Height at which the programmed turn is
    %                            made.
    %   :programmed_turn_angle : Programmed turn in radians.
    %   :target_altitude: The target mission altitude to reach.
    %   :drift_duration : The duration for drift after deployment.
    %
    %   Output:
    %    - Displays useful information such as:
    %      - Propellant mass left in stage 2 at deployment.
    %    - Plot of the trajectory and V(t).
    %
    %   Notes:
    %    - Program only support the rocket to turn to the right (negative
    %      programmed turn angle).
    
    disp("---------------------- Simulation results ---------------")
    
    %% Fix inputs
    
    programmed_turn_angle = -norm(programmed_turn_angle);
    if programmed_turn_angle > 10*pi/180
        fprintf("Are you sure you entered programmed turn angle %f in radians", programmed_turn_angle)
    end
    
    %% Common values
    
    g_0 = 9.81;
    R_e = 6371000;
    mu = 398600E9;
    
    %% Construct steering modules
    
    steer_1_to_programmed_turn = SteeringModule(); % First stage until programmed turn
    steer_1_to_programmed_turn = steer_1_to_programmed_turn.set_break_height(programmed_turn_height);
    steer_1_to_programmed_turn = steer_1_to_programmed_turn.set_constant_burn_rate(burn_rates(1));

    steer_1_after_programmed_turn = SteeringModule(); % First stage after programmed turn until burnout
    steer_1_after_programmed_turn = steer_1_after_programmed_turn.set_break_at_burnout();
    steer_1_after_programmed_turn = steer_1_after_programmed_turn.set_constant_burn_rate(burn_rates(2));

    % TODO: Warn if target height cant be reached
    steer_2_reach_target_height = SteeringModule(); % Second stage until apogee
    steer_2_reach_target_height = steer_2_reach_target_height.set_break_height(target_altitude);
    steer_2_reach_target_height = steer_2_reach_target_height.set_target_apogee(target_altitude+R_e, burn_rates(3)); %(taget_apogee, max_burn_rate) 

    steer_2_drift = SteeringModule(); % Drift of second stage
    steer_2_drift = steer_2_drift.set_break_after_duration(drift_duration);
    steer_2_drift = steer_2_drift.set_constant_burn_rate(0);

    %% Simulate
    
    % Data allocation for plots
    number_of_trajectories = 4;
    trajectories = cell(number_of_trajectories, 2);

    % First stage until turn
    t_0 = 0;
    u_0 = [0.1, 90*pi/180, 0.1, 0.1, stage_1.m_0]';
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_1, steer_1_to_programmed_turn); 
    trajectories(1,:) = {t_list, u_list};
    % Print information
    fprintf("Programmed turn (%.1f degrees):\n", programmed_turn_angle*180/pi); 
    print_state(u_list(end,:))
    fprintf("\tm_p_left = %.0f kg (%.1f %%)\n", stage_1.m_p-(stage_1.m_0-u_list(end,5)), 100*(stage_1.m_p-(stage_1.m_0-u_list(end,5)))/stage_1.m_p)
    
    % Turn first stage and simulate gravity turn
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    stage_1_current = stage_1.remove_used_propellant(stage_1.m_0-u_0(5));
    u_0(2) = u_0(2) + programmed_turn_angle;
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_1_current, steer_1_after_programmed_turn); 
    trajectories(2,:) = {t_list, u_list};
    
    % Separation, simulate stage 2 in gravity turn until burnout
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    u_0(5) = stage_2.m_0;
    fprintf("Stage 1 burnout, stage 2 separated:\n");
    print_state(u_0);
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_2, steer_2_reach_target_height); 
    trajectories(3,:) = {t_list, u_list};
    
    fprintf("Stage 2 reached target height:\n")
    print_state(u_list(end,:));
    fprintf("\tm_p_left = %.0f kg (%.1f %%)\n", stage_2.m_p-(stage_2.m_0-u_list(end,5)), 100*(stage_2.m_p-(stage_2.m_0-u_list(end,5)))/stage_2.m_p)
    % Make instant delta V to reach target trajectory
    v = u_list(end, 1);
    gamma = u_list(end, 2);
    current_velocity = [v*cos(gamma), v*sin(gamma)];
    target_velocity = [sqrt(mu/(target_altitude+R_e)), 0];
    stage_2_current = stage_2.remove_used_propellant(stage_2.m_0-u_list(end,5));
    m_p_used = propellant_for_velocity_change(current_velocity, target_velocity, stage_2_current);
    stage_2_current = stage_2.remove_used_propellant(m_p_used);
    % Update state
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    u_0(1) = norm(target_velocity);
    u_0(2) = 0;
    u_0(5) = u_0(5)-m_p_used;
    % Separation, simulate stage 2 drift after burnout
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_2_current, steer_2_drift); 
    trajectories(4,:) = {t_list, u_list};
    fprintf("Circularize orbit:\n\tdelta_V = %.3f km/s \n\tm_p_burnt = %.0f kg \n", norm(current_velocity-target_velocity)/1000, m_p_used)
    fprintf("Now in correct orbit:\n")
    print_state(u_0)
    fprintf("\tm_p_left = %.0f kg (%.1f %%)\n", stage_2.m_p-(stage_2.m_0-u_0(5)), 100*(stage_2.m_p-(stage_2.m_0-u_list(end,5)))/stage_2.m_p)
    
    %% Plot and savefig

        disp("--------------------------------------------------------")
    
    legends = ["First stage", "First stage post turn", "Second stage", "Drift"];
    visualize(number_of_trajectories, trajectories, legends, plot_name);

    %% Help functions
    
    function print_state(u)
        fprintf("\tV = %.3f km/s \n\tgamma = %.1f degrees \n\tX = %.2f km \n\tH = %.2f km \n\tm = %.0f kg \n", u(1)/1000, u(2)*180/pi, u(3)/1000, u(4)/1000, u(5))
    end
    
end
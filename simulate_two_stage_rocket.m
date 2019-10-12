function simulate_two_stage_rocket(stage_1, stage_2, burn_rates, fuel_left_in_first_stage,...
        programmed_turn_height, programmed_turn_angle, ...
        first_stage_should_land, first_stage_landing_duration, ...
        target_altitude, m_payload, ...
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
    steer_1_after_programmed_turn = steer_1_after_programmed_turn.set_break_at_burnout(fuel_left_in_first_stage);
    steer_1_after_programmed_turn = steer_1_after_programmed_turn.set_constant_burn_rate(burn_rates(2));
    
    steer_1_reentry = SteeringModule();
    steer_1_reentry = steer_1_reentry.set_break_below_height(0);
    steer_1_reentry = steer_1_reentry.set_constant_burn_rate(0);

    % TODO: Warn if target height cant be reached
    steer_2_reach_target_height = SteeringModule(); % Second stage until apogee
    steer_2_reach_target_height = steer_2_reach_target_height.set_break_height(target_altitude);
    steer_2_reach_target_height = steer_2_reach_target_height.set_target_apogee(target_altitude+R_e, burn_rates(3)); %(taget_apogee, max_burn_rate) 

    steer_2_drift = SteeringModule(); % Drift of second stage
    steer_2_drift = steer_2_drift.set_break_after_duration(100);
    steer_2_drift = steer_2_drift.set_constant_burn_rate(0);

    steer_3_payload_orbit = SteeringModule(); % Drift of second stage
    steer_3_payload_orbit = steer_3_payload_orbit.set_break_after_duration(drift_duration);
    steer_3_payload_orbit = steer_3_payload_orbit.set_constant_burn_rate(0);
    
    steer_2_reentry = SteeringModule();
    steer_2_reentry = steer_1_reentry.set_break_below_height(0);
    steer_2_reentry = steer_1_reentry.set_constant_burn_rate(0);

    %% Simulate
    
    % Data allocation for plots
    number_of_trajectories = 6; % (stage_1_ascent, stage_1_reentry , stage_2_ascent, stage_2_reentry, payload_orbit, target)

    % --- First stage until turn
    % Initial conditions
    t_0 = 0;
    u_0 = [0.1, 90*pi/180, 0.1, 0.1, stage_1.m_0, 0, 0, 0]';
    % Simulate
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_1, steer_1_to_programmed_turn); 
    t_list_first_stage = t_list;
    u_list_first_stage = u_list;
    
    % --- Turn first stage and simulate gravity turn until burnout (or close to)
    % Initial conditions, new angle
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    u_0(2) = u_0(2) + programmed_turn_angle;
    % Print information
    fprintf("Programmed turn (%.1f degrees):\n", -programmed_turn_angle*180/pi); 
    print_state(t_0, u_0(end,:))
    fprintf("\tm_p_left = %.0f kg (%.1f %%)\n", stage_1.m_p-(stage_1.m_0-u_list(end,5)), 100*(stage_1.m_p-(stage_1.m_0-u_list(end,5)))/stage_1.m_p)
    % Simulate
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_1, steer_1_after_programmed_turn); 
    % Store data
    t_list = [t_list_first_stage; t_list];
    u_list = [u_list_first_stage; u_list];    
    trajectories(1,:) = {t_list, u_list};
    % Construct first stage reentry parameters
    stage_1_reentry = Stage(stage_1.m_0-stage_2.m_0, stage_1.m_p, stage_1.V_eff, stage_1.A, stage_1.C_d);
    t_0_stage_1_reentry = t_list(end);
    u_0_stage_1_reentry = u_list(end,:);
    u_0_stage_1_reentry(5) = u_0_stage_1_reentry(5) - stage_2.m_0;
    
    % --- Separation, simulate stage 2 in gravity turn until burnout (or close to)
    % Initial conditions
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    u_0(5) = stage_2.m_0;
    % Print information
    fprintf("Stage separation:\n");
    print_state(t_0, u_0);
    fprintf("\tm_p_left (stage 1) = %.0f kg (%.2f %%)\n", stage_1.m_p-(stage_1.m_0-u_list(end,5)), 100*(stage_1.m_p-(stage_1.m_0-u_list(end,5)))/stage_1.m_p)
    % Simulate
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_2, steer_2_reach_target_height); 
    % Store data
    trajectories(2,:) = {t_list, u_list};
    % Print information (at max height before burn)
    fprintf("Stage 2 reached target height:\n")
    print_state(t_list(end), u_list(end,:));
    fprintf("\tm_p_left = %.0f kg (%.1f %%)\n", stage_2.m_p-(stage_2.m_0-u_list(end,5)), 100*(stage_2.m_p-(stage_2.m_0-u_list(end,5)))/stage_2.m_p)
    t_list_second_stage = t_list;
    u_list_second_stage = u_list;
    
    
    % --- Delta V to right orbital speed, simulate target orbit after burn
    % Instant delta V to reach target trajectory
    V = u_list(end, 1);
    gamma = u_list(end, 2);
    current_velocity = [V*cos(gamma), V*sin(gamma)];
    target_velocity = [sqrt(g_0*R_e^2/(R_e+target_altitude)), 0];
    %target_velocity = [sqrt(mu/(target_altitude+R_e)), 0];
    current_mass = u_list(end,5);
    m_p_used = propellant_for_velocity_change(current_velocity, target_velocity, current_mass, stage_2.V_eff);
    % Update state
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    u_0(1) = norm(target_velocity);
    u_0(2) = 0;
    u_0(5) = u_0(5)-m_p_used;
    u_0(6) = u_0(6) + norm(target_velocity-current_velocity);
    % Simulate
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_2, steer_2_drift); 
    % Store data
    t_list = [t_list_second_stage; t_list];
    t_list_second_stage = t_list;
    u_list = [u_list_second_stage; u_list];
    u_list_second_stage = u_list;
    trajectories(3,:) = {t_list, u_list};
    % Print information
    fprintf("Circularize orbit:\n\tdelta_V = %.3f km/s \n\tm_p_burnt = %.0f kg \n", norm(current_velocity-target_velocity)/1000, m_p_used)
    fprintf("Now in correct orbit:\n")
    print_state(t_0, u_0)
    fprintf("\tm_p_left = %.0f kg (%.1f %%)\n", stage_2.m_p-(stage_2.m_0-u_0(5)), 100*(stage_2.m_p-(stage_2.m_0-u_list(end,5)))/stage_2.m_p)
    % Construct second stage reentry parameters
    stage_2_reentry = Stage(stage_2.m_0-m_payload, stage_2.m_p, stage_2.V_eff, stage_2.A, stage_2.C_d);
    t_0_stage_2_reentry = t_list(end);
    u_0_stage_2_reentry = u_list(end,:);
    u_0_stage_2_reentry(5) = u_0_stage_2_reentry(5) - m_payload;    
    
    % --- Payload in orbit
    % Initial conditions
    stage_payload = Stage(m_payload, 0, 0, 1, 1);
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    u_0(5) = m_payload;
    % Simulate
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_payload, steer_3_payload_orbit); 
    % Store data
    trajectories(5,:) = {t_list, u_list};
    
    % --- Reentry stage 1
    % Simulate
    [t_list, u_list] = solve_trajectory(t_0_stage_1_reentry, u_0_stage_1_reentry, stage_1_reentry, steer_1_reentry);
    % Land 
    disp("First stage reached ground level:")
    print_state(t_list(end), u_list(end,:))
    if first_stage_should_land
        % Instant delta V to land
        V = u_list(end, 1);
        gamma = u_list(end, 2);
        current_velocity = [V*cos(gamma), V*sin(gamma)];
        target_velocity = [0, first_stage_landing_duration*g_0];
        current_mass = u_list(end,5);   
        m_p_used = propellant_for_velocity_change(current_velocity, target_velocity, current_mass, stage_1.V_eff);
        t_list = [t_list; max(t_list) + first_stage_landing_duration];
        u_rest = u_list(end,:);
        u_rest(1) = 0;
        u_rest(2) = 90*pi/180;
        u_rest(4) = 0;
        u_rest(5) = u_rest(5) - m_p_used;
        u_rest(6) = u_rest(6) + norm(target_velocity-current_velocity);
        u_list = [u_list; u_rest];
        % Print information
        disp("First stage landing burn:")
        fprintf("\tdelta_V = %.3f km/s \n\tm_p_used %.0f kg \n", norm(current_velocity-target_velocity)/1000, m_p_used);
        disp("First stage has landed:")
        print_state(t_list(end), u_list(end,:))
        print_propellant_left(u_rest(5), stage_1_reentry)
    else
        disp("First stage has crashed:")
        t_list = [t_list; max(t_list) + 0];
        u_rest = u_list(end,:);
        u_rest(1) = 0;
        u_rest(2) = 90*pi/180;
        u_list = [u_list; u_rest];
        print_state(t_list(end), u_list(end,:))
        print_propellant_left(u_rest(5), stage_1_reentry)
    end
    % Store data
    trajectories(2,:) = {t_list, u_list};
    % Print information
    
    
    
    % --- Reentry stage 2
    % Break velocity
    t_0 = t_0_stage_2_reentry;
    u_0 = u_0_stage_2_reentry;
    V = u_0(1);
    gamma = u_0(2);
    H = u_0(4);
    current_velocity = [V*cos(gamma), V*sin(gamma)];
    target_velocity = [sqrt(2*mu*(1/(H+R_e)-1/(R_e+R_e+H))), 0];
    current_mass = u_0(5);   
    m_p_used = propellant_for_velocity_change(current_velocity, target_velocity, current_mass, stage_2.V_eff);
    u_0(1) = norm(target_velocity);
    u_0(5) = u_0(5)-m_p_used;
    u_0(6) = u_0(6)+norm(target_velocity-current_velocity);
    % Simulate
    [t_list, u_list] = solve_trajectory(t_0, u_0, stage_2_reentry, steer_2_reentry); 
    % Store data
    t_list = [t_list_second_stage(end) ; t_list];
    u_list = [u_list_second_stage(end,:) ; u_list];
    disp("Second stage reentry burn:")
    fprintf("\tdelta_V = %.3f km/s \n\tm_p_used = %.0f kg \n", norm(current_velocity-target_velocity)/1000, m_p_used)
    disp("Second stage crash:")
    print_state(t_list(end), u_list(end,:))
    t_list = [t_list; max(t_list) + 0];
    u_rest = u_list(end,:);
    u_rest(1) = 0;
    u_rest(2) = 90*pi/180;
    u_list = [u_list; u_rest];
    print_propellant_left(u_rest(5), stage_2_reentry)
    trajectories(4,:) = {t_list, u_list};
    
    % --- Add target trajectory
    t_max = 0;
    x_max = 0;
    v_target = sqrt(mu/(target_altitude+R_e));
    for n = 1:number_of_trajectories-1
        t_list = trajectories{n,1};
        u_list = trajectories{n,2};
        if max(t_list) > t_max
            t_max = max(t_list);
        end
        if max(u_list(:,3)) > x_max
            x_max = max(u_list(:,3));
        end
    end
    t_list = [0; t_max];
    u_list = [v_target,0,0,target_altitude,0;
                v_target,0,x_max,target_altitude,0];
    trajectories(6,:) = {t_list, u_list};
    
    %% Plot and savefig

    disp("--------------------------------------------------------")
    
    % TODO: Put colors here
    
    legends = ["1st stage ascent", "1st stage reentry", "2nd stage ascent", "2nd stage reentry", "Payload", "Target"];
%     visualize_animation(number_of_trajectories, trajectories, legends, plot_name);
    visualize(number_of_trajectories, trajectories, legends, plot_name);

    %% Help functions
    
    function print_state(t, u)
        fprintf("\tt = %.1f s \n\tV = %.3f km/s \n\tgamma = %.1f degrees \n\tX = %.2f km \n\tH = %.2f km \n\tm = %.0f kg \n", t, u(1)/1000, u(2)*180/pi, u(3)/1000, u(4)/1000, u(5))
    end

    function print_propellant_left(m_p_current, stage)
        m_p_left = stage.m_p-(stage.m_0-m_p_current);
        fprintf("\tm_p_left = %.0f kg (%.1f %%)\n", m_p_left, 100*m_p_left/stage.m_p) 
    end
    
end
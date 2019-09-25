clear all
close all

%% Falcon 9 

m_payload = 22800; % Maximum to LEO
% m_payload = 1000; % Our payload
g_0 = 9.81;
C_d_0 = 0.68;

% Stage(m_0, m_p, V_eff, A, C_d)
stage_2 = Stage(3900+92670+m_payload, 92670, 311*g_0, (5.2/2)^2*pi, C_d_0);
stage_1 = Stage(stage_2.m_0 + 25600+395700, 395700, 282*g_0, (5.2/2)^2*pi, C_d_0);

steer_1 = SteeringModule();
steer_1 = steer_1.set_break_height(10000);
steer_1 = steer_1.set_constant_burn_rate(1451.9*9);

steer_2 = SteeringModule();
steer_2 = steer_2.set_break_at_burnout();
steer_2 = steer_2.set_constant_burn_rate(1451.9*9/20);

steer_3 = SteeringModule();
steer_3 = steer_3.set_break_at_burnout();
steer_3 = steer_3.set_constant_burn_rate(92670/397);
steer_3 = steer_3.set_constant_burn_rate(1451.9);


%% Compute
% Data allocation for plots
number_of_trajectories = 3;
trajectories = cell(number_of_trajectories, 2);

% First stage until turn
t_0 = 0;
u_0 = [0.1, 90*pi/180, 0.1, 0.1, stage_1.m_0]';
[t_list, u_list] = solve_trajectory(t_0, u_0, stage_1, steer_1); 
trajectories(1,:) = {t_list, u_list};

% Turn first stage and simulate gravity turn
programmed_turn_angle = -5*pi/180;
t_0 = t_list(end);
u_0 = u_list(end,:);
u_0(2) = u_0(2) + programmed_turn_angle;
stage_1 = stage_1.remove_used_propellant(stage_1.m_0-u_0(5));
[t_list, u_list] = solve_trajectory(t_0, u_0, stage_1, steer_2); 
trajectories(2,:) = {t_list, u_list};

% Separation, simulate stage 2
t_0 = t_list(end);
u_0 = u_list(end,:);
[t_list, u_list] = solve_trajectory(t_0, u_0, stage_2, steer_3); 
trajectories(3,:) = {t_list, u_list};

%% Plot and savefig

legends = ["First stage", "First stage post turn", "Second stage"];
visualize(number_of_trajectories, trajectories, legends);

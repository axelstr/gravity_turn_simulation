clear all
close all

%% Falcon 9 first stage test

m_payload = 1000;
g_0 = 9.81;
C_d_0 = 0.1;

% Stage(m_0, m_p, V_eff, A, C_d)
falcon_9_second_stage = Stage(3900+92670+m_payload, 92670, 311*g_0, (5.2/2)^2*pi, C_d_0);
falcon_9_first_stage = Stage(falcon_9_second_stage.m_0 + 25600+395700, 395700, 282*g_0, (5.2/2)^2*pi, C_d_0);

steering_module_1 = SteeringModule();
steering_module_1 = steering_module.set_programmed_turn(10000, -2);
steering_module_1 = steering_module.set_constant_burn_rate(1451.9*9);

steering_module_2= SteeringModule();
steering_module_2 = steering_module.set_constant_burn_rate(92670/397);

%% Construct rocket stage list

number_of_stages = 2;
stages = {falcon_9_first_stage, falcon_9_second_stage}; 
steering_modules = {steering_module_1, steering_module_2};

%% Compute
t_0 = 0;
u_0 = [0.1, 90*pi/180, 0, 0, m_0]';
stage_trajectories = cell(number_of_stages, 2);
for n = 1:number_of_stages
    dur_max = 1000;
    [t_list, u_list] = solve_trajectory(t_0, u_0, stages{n}, steering_modules{n}); 
    stage_trajectories(n,:) = {t_list, u_list};
    u_list(end,:)
    t_0 = t_list(end);
    u_0 = u_list(end,:);
    u_0(5) = stage{n}.m_0
end
    
x = u_list(:,3);
y = u_list(:,4);

%% Plot and savefig
x1 = x;
y1 = y;
x2 = x+x(end);
y2 = y+y(end);

trajectories = {
    x1, y1; 
    x2, y2 
};

legends = ["First stage", "Second stage"];
visualize(number_of_stages, stage_trajectories, legends);

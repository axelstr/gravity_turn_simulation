%% Vega test

%% Falcon 9 first stage test

stage_1 = Stage(138487, 88365, A, C_d, V_e, 101300, A_e);
stage_2 = Stage(42792, 26000, A/5, C_d, V_e, 101300, A_e);
stage_3 = Stage(13942, 10500, A/5, C_d, V_e, 101300, A_e);
stage_4 = Stage(2127, 550, );

steering_1 = SteeringModule();
steering_2 = steering_module.set_programmed_turn(1000, -5);
steering_3 = steering_module.set_constant_burn_rate(1451.9*5);


steering_module_2= SteeringModule();
steering_module_2 = steering_module.set_constant_burn_rate(1451.9);

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
    t_0 = t_list(end);
    u_0 = u_list(end,:);
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

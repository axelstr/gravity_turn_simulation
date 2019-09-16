%% Falcon 9 first stage test

m_0 = 549000*5;
m_p = 500000;
A = (3.66/2)^2*pi;
V_e = 3050;
p_e = 100000;
A_e = (1.25/2)^2*pi;
C_d = 0.1;

falcon_9_first_stage = Stage(m_0, m_p, A, C_d, V_e, p_e, A_e);
falcon_9_second_stage = Stage(m_0/5, m_p/5, A/5, C_d, V_e, p_e*.8, A_e);

steering_module = SteeringModule();
steering_module = steering_module.set_programmed_turn(10000, -2);
steering_module = steering_module.set_constant_burn_rate(1451.9*9);

%% Construct rocket stage list

number_of_stages = 2;
stages = {falcon_9_first_stage, falcon_9_second_stage}; 
steering_modules = {steering_module, steering_module};

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

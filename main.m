%% Falcon 9 first stage test
m_0 = 549000;
m_p = 500000;
I_sp = 311;
%V_e = 9.82*I_sp
V_e = 3050;
p_e = 100000;
t_0 = 0;
A = (3.66/2)^2*pi;
A_e = (1.25/2)^2*pi;
function out = burn_rate_function()
    out =   1451.9;
end

% This is a comment I've added, among other changes
    
%% Single stage test
u_0 = [0.1, 45*pi/180, 0, 0, m_0]';
C_d = 0.1;
br = 1451*9; %kg/s

[t_list, u_list] = solve_trajectory(t_0, u_0, m_p, br, V_e, A_e, p_e, C_d, A); 

x = u_list(:,3)
y = u_list(:,4)

%% Plot and savefig
x1 = x;
y1 = y;
x2 = x*2;
y2 = y*2;

trajectories = {
    x1, y1; 
    x2, y2 
};

legends = ["First stage", "Second stage"];
visualize(trajectories, legends);

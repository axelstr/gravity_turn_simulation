function [t, u_list] = solve_trajectory(t_0, u_0, stage, steering_module)
%solve_trajectory Finds the gravity turn trajectory of a stage with 
%   Solves the gravity turn ODE of the given Stage with a corresponding
%   SteeringModule at specified initial conditions.

    % Earth paramters
    % global R_e g_0;
    R_e = 6371000;
    g_0 = 9.81;
    
    % Timespan
    t_span = [t_0, t_0+stage.m_p/steering_module.get_burn_rate(u_0)];
    
% TODO: Make solution for variable burn rate (calculate for large
% timespan and then find the t range until all propelant has been
% used) Below is a start.

%     if steering_module.burn_rate_is_constant
%         t_span = [t_0, t_0+stage.m_p/steering_module.get_burn_rate(u_0)];
%     else
%         t_span = [t_0, t_0+1000];

%     end
    
    
    % Solver
    [t, u_list] = ode45(@(t,u) odefunction(t,u), t_span, u_0);
    
    %% Ode function
    function Du = odefunction(t, u)
        V = u(1);
        gamma = steering_module.steer_angle(u);
        X = u(3);
        H = u(4);
        m = u(5);
        current_burn_rate = steering_module.get_burn_rate(u);
        
        T = thrust(current_burn_rate, H);
        D = drag(V, H);
        g = gravity(H);
        
        DV = T/m-D/m-g*sin(gamma);
        Dgamma = -1/V*(g-V^2/(R_e+H))*cos(gamma);
        DX = V*cos(gamma);
        DH = V*sin(gamma);
        Dm = - current_burn_rate();
        
        Du = [DV, Dgamma, DX, DH, Dm]';
    end
    
    %% Help functions
    function T = thrust(br, H)
        % global V_e p_e A_e;
        [~,~,p_a ,~] = atmosisa(H);
        
        T = br*stage.V_e + (stage.p_e-p_a)*stage.A_e;
    end

    function D = drag(V, H)
        [~,~,~, rho] = atmosisa(H);
        
        D = 1/2*rho*stage.C_d*stage.A*V^2;
    end

    function g = gravity(H)
        g = g_0*(R_e/(R_e+H))^2;
    end

end
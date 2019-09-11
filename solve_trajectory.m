function [t, u_list] = solve_trajectory(t_0, u_0, m_p, burn_rate_function, V_e, A_e, p_e, C_d, A, steering_function)
%solve_trajectory Finds the trajectory with gravity turn
%   Detailed explanation goes here

    % Earth paramters
    % global R_e g_0;
    R_e = 6371000;
    g_0 = 9.81;
    
    % Rocket parameters
    tspan = [t_0, t_0+m_p/br];
    
    % Solver
    [t, u_list] = ode45(@(t,u) odefunction(t,u), tspan, u_0);
    
    %% Ode function
    function Du = odefunction(t, u)
        V = u(1);
        gamma = u(2); 
        X = u(3); 
        H = u(4);
        m = u(5);
        
        T = thrust(burn_rate(), H);
        D = drag(V, H);
        g = gravity(H);
        
        DV = T/m-D/m-g*sin(gamma);
        Dgamma = -1/V*(g-V^2/(R_e+H))*cos(gamma);
        DX = V*cos(gamma);
        DH = V*sin(gamma);
        Dm = - burn_rate();
        
        Du = [DV, Dgamma, DX, DH, Dm]';
    end
    
    %% Help functions
    function T = thrust(br, H)
        % global V_e p_e A_e;
        [~,~,p_a ,~] = atmosisa(H);
        
        T = br*V_e + (p_e-p_a)*A_e;
    end

    function D = drag(V, H)
        [~,~,~, rho] = atmosisa(H);
        
        D = 1/2*rho*C_d*A*V^2;
    end

    function g = gravity(H)
        g = g_0*(R_e/(R_e+H))^2;
    end

    function rate = burn_rate()
       rate = br;
    end

end
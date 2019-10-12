function [t, u_list] = solve_trajectory(t_0, u_0, stage, steering_module)
%solve_trajectory Finds the gravity turn trajectory of a stage with 
%   Solves the gravity turn ODE of the given Stage with a corresponding
%   SteeringModule at specified initial conditions.
    % Earth paramters
    R_e = 6371000;
    g_0 = 9.81;
    load rho_by_kilometer.mat rho_by_kilometer        
    
    % Timespan
%    t_span = linspace(t_0, t_0+10000, 10000001);
    t_span = linspace(t_0, t_0+10000, 100001);
    dt = (t_span(end)-t_span(1))/length(t_span);


    % Solver
    if steering_module.break_at_burnout
        ode_option = odeset('Events', @break_event_burn_out);
    elseif steering_module.break_above_height == true || steering_module.break_below_height == true
        ode_option = odeset('Events', @break_event_height);
    elseif steering_module.break_duration > 0
        ode_option = odeset('Events', @break_event_duration);
    end
    
    [t, u_list] = ode45(@(t,u) odefunction(t,u), t_span, u_0, ode_option);
    
    %% ode45 break functions
    
    function [value, terminate, direction] = break_event_burn_out(t, u)
        % Terminate if the value is 0 or below
        fuel_left = stage.m_p-(stage.m_0-u(5));
        relative_fuel_left = fuel_left / stage.m_p;
        value = (relative_fuel_left <= steering_module.fuel_left_at_separation)-.5; 
        terminate = 1;
        direction  = 0;
    end

    function [value, terminate, direction] = break_event_height(t, u)
        % Terminate if the value is 0 or below 
        if steering_module.break_above_height
            value = (u(4) <= steering_module.break_height)-.5; 
        else 
            value = (u(4) >= steering_module.break_height)-.5; 
        end
        terminate = 1;
        direction  = 0;
    end
    
    function [value, terminate, direction] = break_event_duration(t, u)
        current_duration = t - t_0;
        % Terminate if the value is 0 or below 
        value = (current_duration >= steering_module.break_duration)-.5;
        terminate = 1;
        direction  = 0;
    end

    %% Ode function
    function Du = odefunction(t, u)
        V = u(1);
        gamma = u(2);
        X = u(3);
        H = u(4);
        m = u(5);
        current_burn_rate = steering_module.burn_rate(u);
        
        T = thrust(current_burn_rate, H);
        D = drag(V, H);
        g = gravity(H);
        
        DV = T/m-D/m-g*sin(gamma);
        Dgamma = -1/V*(g-V^2/(R_e+H))*cos(gamma);
        DX = V*cos(gamma)*(R_e/(R_e+H));
        DH = V*sin(gamma);
        Dm = - current_burn_rate;
        
        DdeltaV_thrust = T/m;
        DdeltaV_drag = D/m;
        DdeltaV_grav = norm(g*sin(gamma)); % TODO: ändra till något i stil med (g-V^2/(R_e+H))
        
        Du = [DV, Dgamma, DX, DH, Dm, DdeltaV_thrust, DdeltaV_drag, DdeltaV_grav]';
    end
    
    %% Help functions
    function T = thrust(br, H)        
        T = br*stage.V_eff;
    end

    function D = drag(V, H)
        if H <= 20000 % Atmosisa doesn't work above 20 km
            [~,~,~, rho] = atmosisa(H);
        elseif (20000 <= H) && (H <= 1000000)
            % Complete 1976 Standard Atmosphere https://se.mathworks.com/matlabcentral/fileexchange/13635-complete-1976-standard-atmosphere?s_tid=mwa_osa_a
            rho = rho_by_kilometer(round(H/1000));
        else
            rho = 0;
        end
        
        D = 1/2*rho*stage.C_d*stage.A*V^2;
    end

    function g = gravity(H)
        g = g_0*(R_e/(R_e+H))^2;
    end

end
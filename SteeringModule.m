classdef SteeringModule < handle
    %SteeringModule Controls the rocket's angle and burn_rate
    %   Steering: Controlls initial, programmed turn of the rocket to
    %   initiate the gravity turn. Programmed turn is specified in degrees
    %   and at specific height or/and below a dynamic pressure.
    %   Burn rate: Controlls the burn rate to unsure that the acceleration
    %   is below a maximum value or to reach final orbit.
    
    % TODO: Dynamic pressure
    % TODO: Burn rate so acceleration is below maximum 
    % TODO: Functions to reach final orbit
    % TODO: Add function that turns at dynamic pressure
    
    properties
        burn_rate_is_constant = false % If the burn rate is constant for this stage
        constant_burn_rate = 0 % The constant burnrate to use if burn rate is constant

        target_apogee = 0 % The target apogee to reach      
        max_burn_rate = 0% The maximum available burnrate 
        
        break_height = 0% The height to break ode solver
        break_at_burnout = false % Indicates that break should occur at burnout
        break_duration = 0% The duration from start until ode break in seconds
    end
    
    methods
        % --- Contructor
        function obj = SteeringModule()
            obj.break_duration = 0;
        end
        
        % --- Set methods
        function obj = set_constant_burn_rate(obj, burn_rate)
            % set_constant_burn_rate Sets a constant burn rate of the
            % engines.
            obj.burn_rate_is_constant = true;
            obj.constant_burn_rate = burn_rate;
        end
        
        function obj = set_target_apogee(obj, height, max_burn_rate)
            obj.target_apogee = height;
            obj.max_burn_rate = max_burn_rate;
        end
        
        % --- Steering methods        
        function rate = burn_rate(obj, u)
            % get_burn_rate Returns the burn_rate at this instance of u = 
            % [V, gamma, X, H, m].
            if obj.burn_rate_is_constant
                rate = obj.constant_burn_rate;
            elseif obj.target_apogee > 0
                rate = obj.burn_rate_to_reach_target_apogee(u);
            end
        end

        function rate = burn_rate_to_reach_target_apogee(obj, u)
            marginal = 10000;
            e = (obj.target_apogee + marginal - obj.estimated_apogee(u));
            
            relative_error = e/(2*marginal);
            
            if relative_error >= 1
                rate = obj.max_burn_rate;
            elseif relative_error >= 0
                rate = obj.max_burn_rate*relative_error;
            else
                rate = 0;
            end
        end
        
        function apogee = estimated_apogee(~, u)
           mu = 3986000E9;
           R_e = 6371000;
           V = u(1);
           gamma = u(2);
           H = u(4);
           
           E_current = V^2/2 - mu*(R_e + H)
           H_current = (R_e+H)*V*cos(gamma)
           
           apogee = (-2*mu+sqrt((2*mu)^2 + 8*E_current*H_current^2)) / (4*E_current)
        end
        
        % --- Break paramters
        
        function obj = set_break_height(obj, height)
           obj = obj.null_break_properties();
           obj.break_height = height; 
        end
        
        function obj = set_break_at_burnout(obj)
            obj = obj.null_break_properties();
            obj.break_at_burnout = true;
        end
        
        function obj = set_break_after_duration(obj, dur)
            obj = obj.null_break_properties();
            obj.break_duration = dur;
        end
        
        function obj = null_break_properties(obj)
           obj.break_duration = 0;
           obj.break_height = 0;
           obj.break_at_burnout = false;
        end
    end
end


classdef SteeringModule
    %SteeringModule Controls the rocket's angle and burn_rate
    %   Steering: Controlls initial, programmed turn of the rocket to
    %   initiate the gravity turn. Programmed turn is specified in degrees
    %   and at specific height or/and below a dynamic pressure.
    %   Burn rate: Controlls the burn rate to unsure that the acceleration
    %   is below a maximum value or to reach final orbit.
    
    % TODO: Dynamic pressure
    % TODO: Burn rate so acceleration is below maximum 
    % TODO: Functions to reach final orbit
    
    properties
        should_make_initial_turn % If this should make programmed turn when possible
        programmed_turn_height % Height for programmed turn
        programmed_turn_angle % How much to turn the vehicle at programmed turn
        
        burn_rate_is_constant % If the burn rate is constant for this stage
        burn_rate_function % The burn_rate_function used to return burn_rate 
    end
    
    methods
        % --- Contructor
        function obj = SteeringModule()
            % SteeringModule Initiates an empty SteeringModule.
            obj.should_make_initial_turn = false;
            obj.burn_rate_is_constant = false;
        end
        
        % --- Set methods
        function obj = set_programmed_turn(obj, height, angle)
            % set_programmed_turn Sets height and angle of programmed turn.
            obj.should_make_initial_turn = false;
            obj.programmed_turn_height = height;
            obj.programmed_turn_angle = angle*pi/180;
        end
        
        function obj = set_constant_burn_rate(obj, burn_rate)
            % set_constant_burn_rate Sets a constant burn rate of the
            % engines.
            obj.burn_rate_is_constant = true;
            obj.burn_rate_function = @(u) burn_rate;
        end
        
        function obj = set_burn_rate_function(obj, burn_rate_function)
            % set_burn_rate_function Sets a specific function to find
            % the burn rate for each instance of u = [V, gamma, X, H, m].
            obj.burn_rate_is_constant = false;
            obj.burn_rate_function =  burn_rate_function;
        end
        
        % --- Steering methods
        function new_gamma = steer_angle(obj, u)
            % steer_angle Update gamma if at programmed turn.
            if u(4) >= obj.programmed_turn_height
                new_gamma = u(2) + obj.programmed_turn_angle;
            else
                new_gamma = u(2);
            end
        end
        
        function rate = get_burn_rate(obj, u)
            % get_burn_rate Returns the burn_rate at this instance of u = 
            % [V, gamma, X, H, m].
            rate = obj.burn_rate_function(u);
        end
    end
end


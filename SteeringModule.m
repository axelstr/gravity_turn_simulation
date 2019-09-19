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
        should_make_initial_turn % If this should make programmed turn when possible
        programmed_turn_height % Height for programmed turn
        programmed_turn_angle % How much to turn the vehicle at programmed turn
        
        burn_rate_is_constant = true % If the burn rate is constant for this stage
        burn_rate_function % The burn_rate_function used to return burn_rate 
        
        break_height % The height to break ode solver
        break_at_burnout % Indicates that break should occur at burnout
        break_duration % The duration from start until ode break in seconds
    end
    
    methods
        % --- Contructor
        function obj = SteeringModule()
            % SteeringModule Initiates an empty SteeringModule.
            obj.should_make_initial_turn = false;
            obj.burn_rate_is_constant = false;
            obj.burn_rate_function = @(u) 0;
        end
        
        % --- Set methods
        function obj = set_programmed_turn(obj, height, angle)
            % set_programmed_turn Sets height and angle of programmed turn.
            obj.should_make_initial_turn = true;
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
        
        % --- Steering methods        
        function new_gamma = steer_angle(obj, u)
            % steer_angle Update gamma if at programmed turn.
            if obj.should_make_initial_turn
                if (u(4) >= obj.programmed_turn_height) 
                    new_gamma = u(2) + obj.programmed_turn_angle;
                    obj.should_make_initial_turn = false;
                else
                    new_gamma = u(2);
                end
            else
                new_gamma = u(2);
            end
        end
        
        function out = should_turn(obj, u)
            % should_turn If the turn should be performed in this
            % itteration step.
            if obj.should_make_initial_turn
                if (u(4) >= obj.programmed_turn_height) 
                    out = true;
                    obj.should_make_initial_turn = false;
                    return;
                end
            end
            out = false;
        end
        
        function rate = burn_rate(obj, u)
            % get_burn_rate Returns the burn_rate at this instance of u = 
            % [V, gamma, X, H, m].
            rate = obj.burn_rate_function(u);
        end
    end
end


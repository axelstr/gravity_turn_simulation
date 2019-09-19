classdef Stage < handle
    %Stage Container of rocket stage paramters
    %   Contais all relevant pysical parameters of the rocket and its
    %   engine that is used to simulate gravity turn.
    
    properties
        m_0 % Initial mass (including next stages and payloads)
        m_p % Propellant mass
        V_eff % Exhaust velocity
        A % Area of rocket
        C_d % Drag coefficient 
    end
    
    methods
        function obj = Stage(m_0, m_p, V_eff, A, C_d)
            % Stage Constructs a Stage object with given properties.
            obj.m_0 = m_0;
            obj.m_p = m_p;
            obj.V_eff = V_eff;
            obj.A = A;
            obj.C_d = C_d;
        end
        
        function obj = remove_used_propellant(obj, used_propellant)
           obj.m_0 = obj.m_0-used_propellant;
           obj.m_p = obj.m_p-used_propellant;
        end
            
    end
end


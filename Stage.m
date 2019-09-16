classdef Stage
    %Stage Container of rocket stage paramters
    %   Contais all relevant pysical parameters of the rocket and its
    %   engine that is used to simulate gravity turn.
    
    properties
        m_0 % Initial mass (including next stages and payloads)
        m_p % Propellant mass
        A % Area of rocket
        C_d % Drag coefficient 
        V_e % Exhaust velocity
        p_e % Exhaust pressure
        A_e % Exhaust area 
    end
    
    methods
        function obj = Stage(m_0, m_p, A, C_d, V_e, p_e, A_e)
            % Stage Constructs a Stage object with given properties.
            obj.m_0 = m_0;
            obj.m_p = m_p;
            obj.A = A;
            obj.C_d = C_d;
            obj.V_e = V_e;
            obj.p_e = p_e;
            obj.A_e = A_e;
        end
    end
end


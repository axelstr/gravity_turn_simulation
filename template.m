%% Template
% This scripts is a template for how this program can be used. 
% 1. Define the target payload and altitude. 
% 2. Then contruct the two stages according to:
%       stage_n = Stage(m_0, m_p, V_eff, A, C_d)
% 3. Set height and amount for programmed turn of first stage (meters, radians)
% 4. Construct an array of the used burnrates: 
%       burn_rates = [first_stage_pre_turn, first_after_turn, max_of_second_stage]
% 5. Set the plot_name variable to a distinct name identifiable to your
%    rocket.
% 6. Run program, read print-out, observe results. Tweak rocket.
%
% NOTES:
% - If program runs for long time the rocket has too low thrust and can't
% gain altitue.
% - The second stage uses an impulse delta V to get to the right orbit,
% here you might read negative values for the remaining fuel. This means
% that you do not have enough fuel for last delta V to get the right speed,
% even though you reach the right altitude.

clear all
close all

%% Mission parameters

m_payload = 1000; % Our payload
target_altitude = 600000;

%% Scaled Vega (first two stages)
% This rocket is a scaled version of the first two stages of the
% Vega-rocket.

% Stage(m_0, m_p, V_eff, A, C_d)
stage_1 = Stage(117746, 87710, 2600, (3./2)^2*pi, 0.5);
stage_2 = Stage(21149, 18453, 2943, (1.9/2)^2*pi, 0.5);

programmed_turn_height = 10000;
programmed_turn_angle = -2*pi/180;
burn_rates = [514.3, 514.3, 64.1843]; % First stage before turn, first after turn, max of second stage

%% Compute

drift_duration = 100; % Seconds to plot the second stage in the right orbit.
plot_name = "template";

simulate_two_stage_rocket(stage_1, stage_2, burn_rates, ...
        programmed_turn_height, programmed_turn_angle, ...
        target_altitude, ...
        drift_duration, plot_name)
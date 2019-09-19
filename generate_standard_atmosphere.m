%% Generate "Complete 1976 Standard Atmosphereate"

addpath("Complete 1976 Standard Atmosphere")

[~, ~, ~, ~, ~, rho_by_kilometer, ~, ~, ~, ~, ~, ~, ~] = atmo(1000, 1, 1);

save rho_by_kilometer.mat rho_by_kilometer
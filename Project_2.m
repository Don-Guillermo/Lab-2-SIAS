

%% PROJECT II 




clc;
clear;
close all;

%% TASK 1: Preliminaries (Geometry and Loads)

% Input data from project 1

front_spar = 0.25; 
rear_spar  = 0.65; 


y_sections = [2.82, 9.17, 22.61];         % Spanwise location [m]
cords      = [10.50, 6.834, 4.057];       % Local chord [m]
tc_ratio   = [0.14, 0.12, 0.09];          % Thickness-to-chord ratio (NACA 0014, 0012, 0009)
M_bend     = [3268.11, 1946.36, 48.15];   % Bending moment at nz=2.5 [kNm] (Absolute values)


% Equivalent box width (w)
% Distance between front and rear spar
w = cords .* (rear_spar - front_spar); % [m]

% Maximum airfoil thickness (d)
d = cords .* tc_ratio; % [m]

% Effective box height (hb)
% Rule of thumb: hb is 85% of max thickness
hb = 0.85 .* d; % [m]

% Compressive load per unit width (N)
% N = M / (w * bw). For preliminary estimation, we assume bw ≈ hb 
% (distance to panel CG is negligible compared to box height).
N_load = M_bend ./ (w .* hb); % [kN/m]

% RESULTS

fprintf('Section      y [m]     c [m]     w [m]     d [m]     hb [m]    M [kNm]       N [kN/m]\n');
fprintf('-------------------------------------------------------------------------\n');

section_names = {'Root ', 'Kink ', '75%  '};

for i = 1:length(y_sections)
    fprintf('%s      %5.2f     %5.3f     %5.3f     %5.3f     %5.3f     %7.2f      %7.2f\n', ...
        section_names{i}, y_sections(i), cords(i), w(i), d(i), hb(i), M_bend(i), N_load(i));
end

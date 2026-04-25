

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

% Properties from slide 12 (range values for T6 bare sheet)
mat.name    = 'Al 7075-T6 Bare-Sheet';
mat.sig_tu  = 538;       % Ultimate tensile strength       [MPa]
mat.sig_ty  = 483;       % Tensile yield stress            [MPa]
mat.sig_cy  = 475;       % Compressive yield stress        [MPa]
mat.sig_p   = 343;       % Elastic proportional limit      [MPa]
mat.sig_07  = 496;       % R-O stress at 0.7·E             [MPa]
mat.n       = 9.2;       % Hardening exponent              [-]
mat.E       = 71016;     % Young's modulus (tension)       [MPa]
mat.Ec      = 72395;     % Young's modulus (compression)   [MPa]
mat.nu      = 0.33;      % Poisson's ratio                 [-]
mat.rho     = 2.81e3;    % Density                         [kg/m^3]

% Use compressive modulus for upper-panel buckling (compression-dominated)
E   = mat.Ec;
s07 = mat.sig_07;
n   = mat.n;

%% Ramberg-Osgood model & plasticity correction factors (slides 10, 14, 17)
% Strain:        eps(s) = (s/E) * [1 + (3/7)*(s/s07)^(n-1)]
% Tangent mod.:  Et(s)  = E / [1 + (3/7)*n*(s/s07)^(n-1)]   -> column correction
% Secant mod.:   Es(s)  = E / [1 + (3/7)  *(s/s07)^(n-1)]   -> plate correction
% Corrections:   eta = Es/E   (plate),   tau = Et/E   (column)
% Combined:      tau_bar = sqrt(Et*Es)/E    (used in sigma_opt eqn., slide 17)

eps_RO   = @(s) (s./E) .* (1 + (3/7).*(s./s07).^(n-1));
Et_fun   = @(s)  E ./ (1 + (3/7).*n.*(s./s07).^(n-1));
Es_fun   = @(s)  E ./ (1 + (3/7)  .*(s./s07).^(n-1));
eta_fun  = @(s)  Es_fun(s) ./ E;
tau_fun  = @(s)  Et_fun(s) ./ E;
taub_fun = @(s)  sqrt(Et_fun(s).*Es_fun(s)) ./ E;   % tau_bar

% Save in mat struct so Task 2 can call them directly
mat.eps   = eps_RO;
mat.Et    = Et_fun;
mat.Es    = Es_fun;
mat.eta   = eta_fun;
mat.tau   = tau_fun;
mat.taub  = taub_fun;

%% Verification plots — reproduce slide figures
sigma = linspace(1, 500, 500);   % [MPa]

figure('Name','Al 7075-T6 — Material model','Color','w');

subplot(1,3,1)   % Stress-strain
plot(eps_RO(sigma)*1e3, sigma, 'LineWidth', 1.4); grid on
xlabel('\epsilon \times 10^{-3}'); ylabel('\sigma [MPa]');
title('Ramberg-Osgood stress-strain')
yline(mat.sig_p, '--',  '\sigma_p');
yline(mat.sig_07,'--',  '\sigma_{0.7}');
yline(mat.sig_cy,'--',  '\sigma_{cy}');

subplot(1,3,2)   % Et and Es
plot(sigma, Et_fun(sigma), 'LineWidth', 1.4); hold on
plot(sigma, Es_fun(sigma), 'LineWidth', 1.4); grid on
xlabel('\sigma [MPa]'); ylabel('Modulus [MPa]')
legend('E_t (tangent)','E_s (secant)','Location','southwest')
title('Tangent & Secant moduli')

subplot(1,3,3)   % Plasticity correction factor
plot(sigma, taub_fun(sigma), 'LineWidth', 1.4); grid on
xlabel('\sigma [MPa]'); ylabel('\tau = (E_t E_s)^{1/2} / E')
title('Buckling plasticity correction')
ylim([0.2 1.05])

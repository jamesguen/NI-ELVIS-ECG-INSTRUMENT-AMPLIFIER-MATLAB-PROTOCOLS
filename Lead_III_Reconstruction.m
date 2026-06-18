% Written by James Guentert
clear; clc; close all

[Lead_I,~,id_pk_Lead_I]=extractLeadData('Lead_I_Relaxed_02.csv');
[Lead_II,t,id_pk_Lead_II]=extractLeadData('Lead_II_Relaxed.csv');
fs = (length(t) - 1) / (t(end) - t(1));


latestpk=max(id_pk_Lead_I(end),id_pk_Lead_II(end));
earliestpk=min(id_pk_Lead_I(1),id_pk_Lead_II(1));
postpklen=length(t)-latestpk;

wind_length=postpklen+earliestpk(1);
tplot=(1:wind_length)/fs;


% 1. Determine the maximum common number of peaks
N = min(length(id_pk_Lead_I), length(id_pk_Lead_II));

% 2. Vectorize the starting indices (ensure they are column vectors)
starts_I  = 1 + id_pk_Lead_I(1:N)  - earliestpk;
starts_II = 1 + id_pk_Lead_II(1:N) - earliestpk;

% 3. Create a relative index row vector for the length of the window
seg_len = postpklen + earliestpk;
rel_idx = 0:(seg_len - 1); 

% 4. Build index matrices (Column Vector + Row Vector creates a Matrix)
idx_matrix_I  = starts_I(:)  + rel_idx; 
idx_matrix_II = starts_II(:) + rel_idx;

% 5. Direct matrix extraction (No loop needed)
LeadIsegs   = Lead_I(idx_matrix_I);
LeadIIsegs  = Lead_II(idx_matrix_II);
LeadIIIsegs = LeadIIsegs - LeadIsegs;

figure('Color', 'w');

% SUBPLOT 1: LEAD I
subplot(3, 1, 1);
hold on;
% 1. Plot all individual segments at once using a lighter/faded blue
plot(tplot, LeadIsegs', 'k', 'LineWidth', 0.5); 
% 2. Plot the column-wise mean as a thick, solid blue line
if N ~= 1
    plot(tplot, mean(LeadIsegs, 1), 'b', 'LineWidth', 3); 
end
grid on; box on;
xlim([0, tplot(end)]);
ylabel('Lead I (V)', 'FontWeight', 'bold');
title('Superimposed ECG Segments & Ensemble Averages', 'FontSize', 12);

% SUBPLOT 2: LEAD II
subplot(3, 1, 2);
hold on;
% 1. Plot all individual segments at once using a faded red
plot(tplot, LeadIIsegs', 'k', 'LineWidth', 0.5); 
% 2. Plot the column-wise mean as a thick, solid red line
if N ~= 1
    plot(tplot, mean(LeadIIsegs, 1), 'r', 'LineWidth', 3); 
end

grid on; box on;
xlim([0, tplot(end)]);
ylabel('Lead II (V)', 'FontWeight', 'bold');

% SUBPLOT 3: LEAD III
subplot(3, 1, 3);
hold on;
% 1. Plot all individual segments at once using a faded green
plot(tplot, LeadIIIsegs', 'k', 'LineWidth', 0.5); 
% 2. Plot the column-wise mean as a thick, solid green line
if N ~= 1
    plot(tplot, mean(LeadIIIsegs, 1), 'g', 'LineWidth', 3); 
end

grid on; box on;
xlim([0, tplot(end)]);
xlabel('Time (s)', 'FontWeight', 'bold');
ylabel('Lead III (V)', 'FontWeight', 'bold');


%% --- Cardiac Axis Calculation via Complex Argument ---

% 1. Locate the R-spike index in the ensemble average array
idx_R = earliestpk;

% 2. Extract the R-peak voltages (baseline-corrected to the first sample)
V_I_mean  = mean(LeadIsegs, 1);
V_II_mean = mean(LeadIIsegs, 1);

R_volt_I  = V_I_mean(idx_R) - V_I_mean(1);
R_volt_II = V_II_mean(idx_R) - V_II_mean(1);

% 3. Resolve into orthogonal components using the Hexaxial Reference System
X = R_volt_I;
Y = (2 * R_volt_II - R_volt_I) / sqrt(3);

% 4. Find the cardiac axis using the complex argument (angle) function
cardiac_axis_rad = angle(X + 1i*Y);
cardiac_axis_deg = rad2deg(cardiac_axis_rad);

% =========================================================================
%                         COMMAND WINDOW OUTPUT
% =========================================================================
fprintf('\n===================================================\n');
fprintf('          CARDIAC ELECTRICAL AXIS ANALYSIS          \n');
fprintf('===================================================\n');
fprintf('R-Spike Index in Mean Output:   %d\n', idx_R);
fprintf('Lead I R-Spike Amplitude:       %.3f V (%.1f mV)\n', R_volt_I, R_volt_I * 1000);
fprintf('Lead II R-Spike Amplitude:      %.3f V (%.1f mV)\n', R_volt_II, R_volt_II * 1000);
fprintf('---------------------------------------------------\n');
fprintf('Calculated Cardiac Axis Angle:  %.2f degrees\n', cardiac_axis_deg);
fprintf('===================================================\n');

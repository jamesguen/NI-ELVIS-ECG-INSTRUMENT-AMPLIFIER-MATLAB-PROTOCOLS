% Written By James Guentert
clc; clear; close all

%% Common Mode Gain Curve Fitting

% Input Data

% Common-Mode Data V1=V2
% Fill in your input Voltage data here
V_inCommon_pp =[4e-3; 10e-3; 100e-3; 500e-3; 1; 2; 4; 6; 10; 15; 20];

% Output Vpp Voltage
% Fill in your output Voltage data here
Vout_pp = [290e-3; 295e-3; 295e-3; 430e-3; 610e-3; 960e-3; 1.66; 2.40; 3.8; 5.6; 7.2];

% OLS Linear Regression to find Common-Mode Gain (A_CommonMode)
p_CM = polyfit(V_inCommon_pp, Vout_pp, 1); % OLS Alg
Vfit_CM = polyval(p_CM, V_inCommon_pp); % Line of best fit

A_CommonMode = p_CM(1); % Estimated Gain From OLS
A_CommonMode_dB = 20*log10(A_CommonMode); % Convert to dB

% Plot Results
plotCM=figure(Color='w');
hold on
plot(V_inCommon_pp,Vout_pp,'o-',color=[82, 171, 222]/255,LineWidth=2) % Actual Data
plot(V_inCommon_pp,Vfit_CM,'--k',LineWidth=1.5) % Line of Best Fit
grid on

% labeling, syntax styling, and typography sizes
legend('Measured Data','Curve Fit',Location='southeast')

xlabel('Common-Mode Input Voltage, V_{in,cm} [Volts_{pp}]', 'FontSize', 11, 'FontWeight', 'bold')

ylabel('Output Voltage, V_{out} [V_{pp}]', 'FontSize', 11, 'FontWeight', 'bold')

title(sprintf('Instrumentation Amp: Common Mode Gain A_{CM} = %0.4f V/V', A_CommonMode), ...
      'FontSize', 12, 'FontWeight', 'bold')

% Display Results
fprintf('==================================================\n');
fprintf('              Common Mode RESULTS\n');
fprintf('==================================================\n');
fprintf('Measured Common Mode Gain       :  %.2f V/V\n', A_CommonMode);
fprintf('Measured Common Mode Gain (dB)  :  %.2f dB\n\n\n', A_CommonMode_dB);



%% Single Point Approx Differential Gain

% Input Data
% input your V1 V2 and measured Vout voltages Here
V_1_pp_Ada = 0;    % V1 is grounded
V_2_pp_Ada = 4e-3; % V2 is 4mV sine input
V_out_pp_Ada=4.66; % Measured 4.66 V output


A_d_approx = V_out_pp_Ada/(V_2_pp_Ada-V_1_pp_Ada);
A_d_approx_dB = 20*log10(A_d_approx);
CMRR_Approx = A_d_approx/A_CommonMode;
CMRR_Approx_dB = 20*log10(CMRR_Approx);

fprintf('==================================================\n');
fprintf('             Differential Gain Aprox\n');
fprintf('==================================================\n');
fprintf('One-Point Differential Gain:       %.2f V/V\n', A_d_approx);
fprintf('One-Point Differential Gain(dB):   %.2f dB\n', A_d_approx_dB);
fprintf('Aproximated CMRR:                  %.2f V/V\n', CMRR_Approx);
fprintf('Aproximated CMRR (dB):             %.2f dB\n\n\n', CMRR_Approx_dB);


%% Differential Gain Curve Fitting

% Input Data

V_1_pp_Adif = 0;    % V1 is grounded

% Varrying fGen Voltage input into Voltage divider measured in mV 
% Fill with function generator input voltages here
VfGen_Adif = [...
15; 20; 35; 45; 55; 65; 75; 85; 95; 105; 115; 135; 155; 200; 225; 250; 300;    
]*1e-3;

% use a voltage divider and cancel using the DMM resistor ratio
Voltage_Divider_Gain = 108400/(990000+108400);
V_2_pp_Adif = VfGen_Adif*Voltage_Divider_Gain;

% Measured Output Voltage in V
% Fill measured output voltages here
V_out_pp_Q7 = [...
4.7; 4.7; 5.5; 5.8; 6.4; 7.3; 8.0; 9.0; 9.8; 10.8; 11.5; 13.6; 15.5; 19.4; 21.9; 24.2; 27.4
];

% Input Into INST. AMP
V_diff_in_Q7 = V_2_pp_Adif - V_1_pp_Adif;

% Linear Region
% look on graph to locate linear region (indecies) if output clipped
linear_indices = 5:15; 
V_diff_linear  = V_diff_in_Q7(linear_indices);
V_out_linear   = V_out_pp_Q7(linear_indices);

% OLS Linear Regression to find Differential Gain (A_d)
p_Q7 = polyfit(V_diff_linear, V_out_linear, 1); % OLS Alg
Vfit_Q7 = polyval(p_Q7, V_diff_linear); % Line of best fit

A_d = p_Q7(1); % Estimated Gain From OLS
A_d_dB = 20*log10(A_d); % Convert to dB
CMRR = A_d/A_CommonMode; % CMMR Calculation
CMRR_dB = 20*log10(CMRR); % Convert to dB

% Plotting
PlotDG=figure(Color='w');
hold on
plot(V_diff_in_Q7,V_out_pp_Q7,'o-',color=[82, 171, 222]/255,LineWidth=2) % Actual Data
plot(V_diff_linear,Vfit_Q7,'--k',LineWidth=1.5) % Line of Best Fit
grid on

% labeling, syntax styling, and typography sizes
legend('Measured Data','Curve Fit',Location='southeast')

xlabel('Differential Input Voltage, V_{2 in} - V_{1 in} [V_{pp}]', 'FontSize', 11, 'FontWeight', 'bold')

ylabel('Output Voltage, V_{out} [V_{pp}]', 'FontSize', 11, 'FontWeight', 'bold')

title(sprintf('Instrumentation Amp: Differential Gain A_{d} = %0.4f V/V', A_d), ...
      'FontSize', 12, 'FontWeight', 'bold')



fprintf('==================================================\n');
fprintf('             Differential Gain RESULTS\n');
fprintf('==================================================\n');
fprintf('Measured Differential Gain:        %.2f V/V\n', A_d);
fprintf('Measured Differential Gain(dB):    %.2f dB\n', A_d_dB);

fprintf('Calculated CMRR:                   %.2f V/V\n', CMRR);
fprintf('Calculated CMRR (dB):              %.2f dB\n\n\n', CMRR_dB);

%% Question 8 -- Frequency Response

% Input Data

% Varrying fGen frequency 2Vpp sine input into Voltage divider Hz
% fill input frequenceies here
freq_fGen_FR = [...
0.1; 0.5; 1; 5; 10; 50; 80; 100; 300; 500; 1e3; 3e3; 5e3; 10e3];

CH1_preVdiv = [...
0.263; 0.258; 0.254; 0.270; 0.265; 0.270; 0.270; 0.270; 0.270; 0.270; 0.270; 0.265; 0.274; 0.270;
];

% Voltage input into INST. AMP
V_diff_in_FR=Voltage_Divider_Gain*CH1_preVdiv;

% fill here Measured Output Voltage in V
CH3 = [...
21.9; 20.039; 20.039; 20.039; 19.5; 17.1; 14.8; 13.4; 6.75; 4.6; 3.0; 2.0; 1.7; 0.9;
];
BodeGain=CH3./V_diff_in_FR;
BodeGain_dB=20*log10(BodeGain);

% Ideal Calculations
f_L = 0.01; 
f_H = 100;
freq_ideal_smooth = logspace(-1, 4, 1000); % Spans from 0.1 Hz to 10 kHz
G_ideal = A_d * (1 ./ sqrt(1 + (f_L ./ freq_ideal_smooth).^2)) .* ...
                       (1 ./ sqrt(1 + (freq_ideal_smooth ./ f_H).^2));
GdB_ideal_smooth = 20 * log10(G_ideal);

% Bode Plot
Bode=figure(Color='w');
semilogx(freq_fGen_FR,BodeGain_dB,'o-',color=[82, 171, 222]/255,LineWidth=2) % Actual Data
hold on
semilogx(freq_ideal_smooth,GdB_ideal_smooth,'k--',LineWidth=1.5) % Ideal Behavior Plot
grid on

% Labeling, legends, and styling configurations
legend('Experimental Data', 'Ideal Bandpass Model', Location='southwest')
xlabel('Frequency (Hz)', 'FontSize', 11, 'FontWeight', 'bold')
ylabel('Gain Magnitude (dB)', 'FontSize', 11, 'FontWeight', 'bold')
title('Instrumentation Amp: Frequency Response vs. Ideal Bandpass Filter', 'FontSize', 12, 'FontWeight', 'bold')


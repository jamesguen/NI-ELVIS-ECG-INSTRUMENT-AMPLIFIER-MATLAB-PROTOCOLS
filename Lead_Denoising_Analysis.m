% Written by James Guentert
clc; clear; close all

% Load data with original headers preserved
data = readtable('Lead_I_Relaxed_02.csv', 'VariableNamingRule', 'preserve');

% Extract columns into standard arrays
Y = table2array(data(:,2));           % Perfect, high-resolution voltage values
t_truncated = table2array(data(:,1)); % DONT PLOT AGAINST THIS

% This creates points evenly spaced between start and end times
t = linspace(t_truncated(1), t_truncated(end), length(t_truncated))';

fs = (length(t_truncated) - 1) / (t_truncated(end) - t_truncated(1));
Ydetrend=detrend(Y,2);

lfilt = designfilt('lowpassiir', ...
                      FilterOrder=4, ...
                      HalfPowerFrequency=200, ...
                      SampleRate=fs);
                  
Yfilt1 = filtfilt(lfilt, Ydetrend);



nfilt = designfilt('bandstopiir', ...
                       'FilterOrder', 16, ...
                       'HalfPowerFrequency1', 50, ...
                       'HalfPowerFrequency2', 80, ...
                       'SampleRate', fs);
                  
Yfilt2 = filtfilt(nfilt, Yfilt1);
ratio=max(Ydetrend)/max(Yfilt2);

%find peaks: need 0.5 prom and min 1/3s distance or fs/3
[~,loc,w,prm]=findpeaks(Yfilt2,MinPeakProminence=0.5,MinPeakDistance=fs/3);

% indecies of QRS start end
numpks=length(loc);
id_L=round(loc-w);
id_U=round(loc+w);

% corrects QRS amp
Ycorrected=Yfilt2;
for i =1:numpks
    Ycorrected(id_L(i):id_U(i))=ratio*Yfilt2(id_L(i):id_U(i));
end


% Raw signal
figure;
hold on
plot(t, Y, 'k', 'LineWidth', 1)
grid on
box on
xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold')
ylabel('Amplitude (V)', 'FontSize', 11, 'FontWeight', 'bold')
title('Raw Signal', 'FontSize', 12, 'FontWeight', 'bold')

% Plot the signal
figure(color='w');
hold on
plot(t, Ydetrend, 'k', 'LineWidth', 1)
plot(t, Ycorrected, 'r', 'LineWidth', 2)
grid on
box on
% labeling and styling
xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold')
ylabel('Amplitude (V)', 'FontSize', 11, 'FontWeight', 'bold')
title('Denoised & Detrended', 'FontSize', 12, 'FontWeight', 'bold')

% Let's lock the x-axis limits tightly to the data bounds
xlim([t(1), t(end)])
set(gca, 'FontSize', 10)

%% --- Frequency Analysis & Bode Plot ---

f_vec = logspace(log10(0.01), log10(fs/2), 1000)';

% 2. Evaluate the frequency responses at these specific exact frequencies
h_lpf = freqz(lfilt, f_vec, fs);
h_bsf = freqz(nfilt, f_vec, fs);

% [The rest of the code for squaring and plotting remains the same]
mag_lpf_eff = abs(h_lpf).^2;
mag_bsf_eff = abs(h_bsf).^2;
mag_total_db = 20 * log10(mag_lpf_eff .* mag_bsf_eff);
phase_total = zeros(size(f_vec));

% Plotting
figure(color='w');
semilogx(f_vec, mag_total_db, 'r', 'LineWidth', 3);
grid on; box on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Frequency Response of Noise Removal Alg.');
xlim([0.01, fs/2]);
ylim([-1000, 50]);

% MATLAB's built-in periodogram
N=length(t);
f_min = fs / N;
[PSDraw, freqraw] = periodogram(Y, [], [], fs);
[PSDclean, freqclean] = periodogram(Ycorrected, [], [], fs);

PSDraw_mean=movmean(PSDraw,3);
PSDclean_mean=movmean(PSDclean,3);

% Plot PSD
figure(color='w');
semilogx(freqraw, 10*log10(PSDraw_mean),'k', 'LineWidth', 1.5);
hold on
semilogx(freqclean, 10*log10(PSDclean_mean),'r', 'LineWidth', 1.5);
legend('Raw Data', 'Denoised Signal')
xlim([f_min,max(freqraw)])
grid on; xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');



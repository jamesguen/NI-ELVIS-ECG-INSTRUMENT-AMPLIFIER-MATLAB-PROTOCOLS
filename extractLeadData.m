% Written by James Guentert
function [Lead, t, loc] = extractLeadData(filename)
% EXTRACTLEADDATA Processes ECG lead data from a CSV file, applies detrending,
% lowpass and bandstop filtering, corrects QRS amplitude, and saves the variables.
%
% Inputs:
%   filename - String or char array of the CSV file (e.g., 'Lead_I_Relaxed_02.csv')
%
% Outputs:
%   Lead     - Cleaned and amplitude-corrected signal array
%   t        - Uniformly spaced time vector
%   loc      - Sample indices of detected peaks

    % Load data with original headers preserved
    data = readtable(filename, 'VariableNamingRule', 'preserve');

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
[~,loc,w,~]=findpeaks(Yfilt2,MinPeakProminence=0.5,MinPeakDistance=fs/3);

% indecies of QRS start end
numpks=length(loc);
id_L=round(loc-w);
id_U=round(loc+w);

% corrects QRS amp
Ycorrected=Yfilt2;
for i =1:numpks
    Ycorrected(id_L(i):id_U(i))=ratio*Yfilt2(id_L(i):id_U(i));
end

Lead=Ycorrected;
    
    % Dynamically name and save the output file based on the input name
    [~, baseName, ~] = fileparts(filename);
    outputFilename = [baseName '_Extract.mat'];
    
    fprintf('Successfully processed and saved to: %s\n', outputFilename);
end

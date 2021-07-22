%% Analyzing sleep EEG data
% Automated artifact reejction using Hjorth parameters. 
clear
%% Setup

% CD into the folder containing the example data
cd 'C:\Users\ddenis\Google Drive\exampleData'

% Load the the preprocessed dataset
EEG = pop_loadset('HD_exampleData_PP.set');

% We will also need the sleep stage file
load('exampleScores.mat')

% Save location
arSaveName   = 'exampleAR'; % Name of the AR file
dataSaveName = 'HD_exampleData_AR'; % Name of the preprocessed file, now with interpolated channels

% Keep just the EEG channels for AR
hdIdx = find(ismember({EEG.chanlocs.type}, 'EEG'));
hdEEG = pop_select(EEG, 'channel', hdIdx);

% Optional - Inspect data before artifact rejection
%data_viewer('psg', eeglab2danalyzer(hdEEG), 'sleepstages', sleepstages)
%% Run artifact rejection

% Function to perform ar
% 'ChannelParameters'. Arguments are threshold, iterations, % epochs,
% interpolate?
%
% 'EpochParameters'. Arguments are threshold, iterations, number of
% channels, interpolate?
[ar, hdEEG] = fun_detect_artifacts(eeglab2danalyzer(hdEEG), sleepstages,... 
    'ChannelParameters', {3 2 50 'yes'},...
    'EpochParameters', {3 3 17 'yes'});

% Inspect the results of the artifact rejection
data_viewer('psg', hdEEG, 'sleepstages', sleepstages, 'ar', ar)

%% Inspect resulting spectrums

% Subset clean NREM epochs
myNREM = fun_subset_data(hdEEG, sleepstages, ar, 'stage', 2:3);

% Subset clean REM epochs
myREM  = fun_subset_data(hdEEG, sleepstages, ar, 'stage', 5);

% NREM Power spectrum
[psdNREM, psdFreqs] = fun_spectral_power(myNREM.data, myNREM.hdr.srate);

% REM Power spectrum
psdREM = fun_spectral_power(myREM.data, myREM.hdr.srate);
%% Plot

% Plot the full power spectrum for each channel, separately
% for NREM and REM

% NREM plot
figure
subplot(121)
plot(psdFreqs, psdNREM)
set(gca, 'XLim', [0 35])
xlabel('Frequency (Hz)')
ylabel('\muV^2/Hz')
title('NREM power spectrum')

% REM plot
subplot(122)
plot(psdFreqs, psdREM)
set(gca, 'XLim', [0 35])
xlabel('Frequency (Hz)')
ylabel('\muV^2/Hz')
title('REM power spectrum')

%% Save artifact rejection file

save(fullfile(pwd, saveName), 'ar') % Save the AR file

% Save a version of the dataset with interpolated channels
pop_saveset(danalyzer2eeglab(hdEEG), 'filepath', pwd, 'filename', saveName,...
    'savemode', 'onefile', 'version', '7.3');


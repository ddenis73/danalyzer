%% Analyzing sleep EEG data
% Example analysis script. This script takes in the preprocessed dataset,
% sleep scores, and artifact rejection information. The following analyses
% are then applied to the clean data
%
% 1. Spectral power analysis for both NREM and REM sleep
% 2. Sleep spindle detection during NREM sleep
% 3. Slow oscillation detection during NREM sleep
% 4. SO-spindle coupling
% 5. Save the data to a 'specData' file

clear

%% Setup

% cd into folder containing example data
cd 'C:\Users\ddenis\Downloads\exampleData-20210715T000213Z-001\exampleData'
% Spectral power analysis settings
winSize      = 5; % Size of the Hamming window (in seconds)
winOlap      = 0.5; % Window overlap (proportion)
psdMethod    = 'psd'; % Return units as power spectral density (\muV^2/Hz)
psdTransform = 'diff'; % Transformation to counter 1/f

% Sleep spindle detection settings
wavFreq     = 13.5; % Peak frequency of the wavelet
wavBand     = 3; % Bandwidth of the wavelet
ssAmpThresh = 6; % Spindle amplitude criteria
ssDurThresh = 0.4; % Spindle duration criteria

% Slow oscillation detection settings
soFilt      = [0.5 4]; % Initial bandpass filter 
soDurThresh = [0.8 2]; % SO duration criteria (in seconds)
soAmpThresh = 25; % SO amplitude criteria (percentage to retain)

% Coupling detection settings
ssFilt = [wavFreq - (wavBand/2) wavFreq + (wavBand/2)]; % Spindle range bandpass filter

% Save location
saveFolder = pwd;
saveName = 'exampleData_specData';

%% Load the data

% Load the preprocessed dataset
EEG = pop_loadset(fullfile(pwd, 'exampleData_PP.set'));

% Load sleep stage information
load(fullfile(pwd, 'exampleScores.mat'))

% Load artifact rejection information
load(fullfile(pwd, 'exampleAR.mat'))

% View the data
data_viewer('psg', eeglab2danalyzer(EEG), 'sleepstages', sleepstages, 'ar', ar)

%% Separate into NREM and REM sleep

% Select all clean stage 2 and stage 3 epochs. Remove the non-EEG channels
myNREM = fun_subset_data(eeglab2danalyzer(EEG), sleepstages, ar, 'stage', 2:3,...
    'RemoveChannels', {'LOC' 'ROC' 'EMG1-EMG2'}, 'Interpolate', 'yes');

% Select all clean REM epochs
myREM  = fun_subset_data(eeglab2danalyzer(EEG), sleepstages, ar, 'stage', 5,...
    'RemoveChannels', {'LOC' 'ROC' 'EMG1-EMG2'}, 'Interpolate', 'yes');

%% Spectral power analysis

% Calculate spectral power during NREM sleep. Only the first two arguments
% are required. see help fun_spectral_power for information about each
% optional input

% The first output is the PSD estimates for each frequency, arranged in a
% frequency x channel matrix. The second argument contains the frequencies,
% and tells you which frequency each row corresponds to
[psdNREM, psdFreqs] = fun_spectral_power(myNREM.data, myNREM.hdr.srate,...
    'WindowSize', winSize, 'WindowOverlap', winOlap, 'Method', psdMethod,...
    'Transformation', psdTransform);

% Do the same for REM sleep
psdREM = fun_spectral_power(myREM.data, myREM.hdr.srate,...
    'WindowSize', winSize, 'WindowOverlap', winOlap, 'Method', psdMethod,...
    'Transformation', psdTransform);

% Plot the full power spectrum for each channel
figure

% NREM
subplot(121)
plot(psdFreqs, psdNREM)
set(gca, 'XLim', [0 35])
xlabel('Frequency (Hz)'), ylabel('PSD (\muV^2/Hz)')
title('NREM power spectrum')

% REM
subplot(122)
plot(psdFreqs, psdREM)
set(gca, 'XLim', [0 35])
xlabel('Frequency (Hz)'), ylabel('PSD (\muV^2/Hz)')
title('REM power spectrum')

% Plot the topography of power in a frequency band
figure

% Upper and lower edges of the band
bandLims = [4 8];

% Find the index of band frequencies
bandIdx  = find(psdFreqs >= bandLims(1) & psdFreqs <= bandLims(2));

% Average PSD in the frequency band
nremBand = mean(psdNREM(bandIdx, :)); % NREM
remBand  = mean(psdREM(bandIdx, :)); % REM

% NREM topoplot
subplot(121)
topoplot(nremBand, myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(hot)
title(['NREM PSD: ' num2str(bandLims(1)) '-' num2str(bandLims(2)) ' Hz'])

% REM topoplot
subplot(122)
topoplot(remBand, myREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(hot)
title(['REM PSD: ' num2str(bandLims(1)) '-' num2str(bandLims(2)) ' Hz'])

%% Sleep spindle detection

% Detect sleep spindles during NREM sleep. The first 3 arguments are
% required. See help fun_sleep_spindles for information about each optional
% input. After watching the week 5 class, you should understand
% what each argument is referring to

% The first output is a 1xnChan structure containing information about
% every detected spindle. The second output is a 1xnChan structure
% providing channel averages for each spindle property

[ssAll, ssSum] = fun_sleep_spindles(double(myNREM.data), {myNREM.chans.labels}, myNREM.hdr.srate,...
    'PeakFrequency', wavFreq, 'BandWidth', wavBand,...
    'AmplitudeCriteria', ssAmpThresh, 'DurationCriteria', ssDurThresh);

% Plot topography of spindle density and amplitude
figure

% Density
subplot(121)
topoplot([ssSum.spindleDensity], myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(hot)
title('NREM spindle density')

% Amplitude
subplot(122)
topoplot([ssSum.spindleAmplitude], myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(hot)
title('NREM spindle amplitude')

%% Slow oscillation detection

% The first thing we need to do is band-pass filter the signal.
nremDelta = pop_eegfiltnew(danalyzer2eeglab(myNREM), soFilt(1), soFilt(2));

% Now we detect the slow oscillations. The first 3 arguments are
% required. See help fun_slow_oscillations for information about each optional
% input. After watching the week 5 class, you should understand
% what each argument is referring to

% The first output is a 1xnChan structure containing information about
% every detected slow oscillation. The second output is a 1xnChan structure
% providing channel averages for each slow oscillation property

[soAll, soSum] = fun_slow_oscillations(nremDelta.data, {myNREM.chans.labels}, myNREM.hdr.srate,...
    'DurationCriteria', soDurThresh, 'AmplitudeCriteria', soAmpThresh);

% Plot topography of SO density, peak-to-peak amplitude, and slope
figure

% Density
subplot(131)
topoplot([soSum.soDensity], myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(gca, hot)
title('NREM SO density')

% Peak-to-peak amplitude
subplot(132)
topoplot([soSum.soPPAmplitude], myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(gca, hot)
title('NREM SO amplitude')

% Peak-to-peak slope
subplot(133)
topoplot([soSum.soPPSlope], myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(gca, hot)
title('NREM SO slope')

%% SO-spindle coupling

% We have already bandpass filtered in the delta band, but we still need to
% bandpass in the spindle range
nremSigma = pop_eegfiltnew(danalyzer2eeglab(myNREM), ssFilt(1), ssFilt(2));

% Now we detect coupling events. This requires six inputs. We need both the
% delta and the sigma filtered signal, the channel labels and sampling
% rate, as well the first output from fun_slow_oscillations and
% fun_sleep_spindles
[cpAll, cpSum] = fun_so_spindle_coupling(nremDelta.data, nremSigma.data,...
    {myNREM.chans.labels}, myNREM.hdr.srate, soAll, ssAll);

% Plot topography of coupling metrics
figure

% Coupled spindle density
den = subplot(131);
topoplot([cpSum.couplingDensity1], myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(den, hot)
title('Coupled spindle density')

% Coupling phase
phs = subplot(132);
topoplot(rad2deg([cpSum.couplingPeakPhase]), myNREM.chans, 'Electrodes', 'off');
colorbar
colormap(phs, jet)
title('Coupling phase')

% Coupling strength
str = subplot(133);
topoplot(rad2deg([cpSum.couplingPeakStrength]), myNREM.chans, 'MapLimits', 'maxmin', 'Electrodes', 'off');
colorbar
colormap(str, hot)
title('Coupling strength')

% Make a circular phase plot at two electrodes
chanName = {'Fz' 'Pz'}; % Channels to plot
chanIdx  = find(ismember({myNREM.chans.labels}, chanName)); % Channel indices

figure

% Plot coupling phase for first channel
subplot(121)
plot_phases(cpAll(chanIdx(1)).soPhasePeak, [1 0 0]);
title(chanName(1))

% Plot coupling phase for second channel
subplot(122)
plot_phases(cpAll(chanIdx(2)).soPhasePeak, [0 0 1]);
title(chanName(2))

%% Save the data

% Channel location information
chans = myNREM.chans;

% Number of samples per sleep stage and the sampling rate
samples.nrem  = myNREM.hdr.samples;
samples.rem   = myREM.hdr.samples;
samples.srate = myNREM.hdr.srate;

% PSD data
psdData.nrem  = psdNREM;
psdData.rem   = psdREM;
psdData.freqs = psdFreqs;

% Spindle data
spindleData.all = ssAll;
spindleData.sum = ssSum;

% Slow oscillation data
soData.all = soAll;
soData.sum = soSum;

% Coupling data
cpData.all = cpAll;
cpData.sum = cpSum;

% Save it!
save(fullfile(saveFolder, saveName),...
    'chans', 'samples', 'psdData', 'spindleData', 'soData', 'cpData')
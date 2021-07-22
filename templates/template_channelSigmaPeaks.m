%% Analyzing sleep EEG data
% Separing fast and slow spindle activity using channel-level data. This
% approach is appropriate when using low-density data. If you have
% high-density data, the GED approach may more easily identify a slow
% spindle peak

% The channel level approach simply plots the NREM power spectrum at
% pre-selected channels, and attempts to isolate the most prominent peak
% occuring in a broad fast and slow sigma range

clear
%%

% CD into the folder containing the example data
cd 'C:\Users\ddenis\Google Drive\exampleData'

% Names of channels to plot
chans2Plot = {'F3' 'F4' 'C3' 'C4'}; 

% Range to look for peaks
slowRange = [9 12.5]; % Slow spindles
fastRange = [12.5 16]; % Fast spindles

% High filter order will create a steep filter ensuring minimal overlap
% between the slow and fast range
filtOrder = 13200;

% Plotting settings
comps2Plot = 4; % Number of components to plot
plotRange  = [5 20]; % Frequency range on the x axis

saveFig = 'yes'; % Save the figure for later use
saveName = 'exampleSigmaPeaks.png'; % Name the figure

%% Read in data

% Load the EEG data
psg = eeglab2danalyzer(pop_loadset('HD_exampleData_PP.set'));

% Load the sleep scores
load('exampleScores.mat')

% Load the AR info
load('exampleAR.mat')

% Subset the data into clean NREM with bad channels interpolated and
% non-EEG channels removed
myNREM = fun_subset_data(psg, sleepstages, ar, 'stage', 2:3,...
    'Interpolate', 'yes');

%% Power spectral density

[psdNREM, psdFreqs] = fun_spectral_power(myNREM.data, myNREM.hdr.srate);

%% Plot PSD at selected channels

chanIdx = find(ismember({myNREM.chans.labels}, chans2Plot));

figure

for chan_i = 1:length(chanIdx)
    chanNames{chan_i} = myNREM.chans(chanIdx(chan_i)).labels;
    
    plot(psdFreqs, psdNREM(:, chanIdx(chan_i)), 'LineStyle', '--', 'LineWidth', 2)
    hold on
end

set(gca, 'Xlim', plotRange)
xlabel('Frequency (Hz)')
ylabel('PSD')
title(sprintf('NREM channel spectra - %i channels', length(chans2Plot)))
legend(chanNames, 'AutoUpdate', 'off')

%% Find peaks

combinedData = psdNREM(:, chanIdx);

keepPeaks = [];
for i = 1:size(combinedData, 2)
    
    % Find peaks and sort
    [pks, locs, ~, P]  = findpeaks(double(combinedData(:, i)), double(psdFreqs));
    [~, sortInd] = sort(pks, 'descend');
    sortedFreqs  = locs(sortInd);
    sortedProm   = P(sortInd);
    
    % Look for the largest peak in slow range
    slowTarget = find(sortedFreqs >= slowRange(1) & sortedFreqs <= slowRange(2), 1, 'first');
    slowPeaks(i, :) = [sortedFreqs(slowTarget) sortedProm(slowTarget)];
    
    fastTarget = find(sortedFreqs >= fastRange(1) & sortedFreqs <= fastRange(2), 1, 'first');
    fastPeaks(i, :) = [sortedFreqs(fastTarget) sortedProm(fastTarget)];
    
end

yLimits = ylim(gca);

if ~isempty(slowPeaks)
    [~, maxSlowIdx] = max(slowPeaks(:, 2)); % Most prominent slow peak
    xline(slowPeaks(maxSlowIdx, 1));
    text(slowPeaks(maxSlowIdx, 1), yLimits(2) - ((5 * yLimits(2)) / 100), num2str(slowPeaks(maxSlowIdx, 1)))
end

if ~isempty(fastPeaks)
    [~, maxFastIdx] = max(fastPeaks(:, 2)); % Most prominent fast peak
    xline(fastPeaks(maxFastIdx, 1));
    text(fastPeaks(maxFastIdx, 1), yLimits(2) - ((5 * yLimits(2)) / 100), num2str(fastPeaks(maxFastIdx, 1)))
end

if strcmpi(saveFig, 'yes')
    saveas(gcf, fullfile(pwd, saveName))
end

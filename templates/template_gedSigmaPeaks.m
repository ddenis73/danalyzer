%% Analyzing Sleep EEG Data
% Separating fast and slow spindle peaks using Genalized Eigen
% Decomposition (GED). When we wish to set individualized fast and slow
% spindle peaks, a common approach is to exmaine the NREM power spectrum
% for slow and fast spindle 'bumps', However, a slow spindle peak is
% consistently not found in a subset of participants. The GED approach is a
% spatial filtering approach that has been found to more reliabily separate
% out fast and slow peaks than channel based methods.
%
% Note that the GED approach to fast and slow spindle separation requires
% high-density data
%
% This script implements fast and slow spindle peak detection using the GED
% method outlined in Cox et al (2017). Frontiers in Human Neuroscience and
% also in Denis et al (2021). The Journal of Neuroscience
%
% Note that the data must have been preprocessed and artifact rejected
% prior to running spindle peak detection
clear
%% Setup

% CD into the folder containing the example data
cd 'C:\Users\ddenis\Google Drive\exampleData'

% Channels to remove
chans2Remove = {'LOC' 'ROC' 'EMG1-EMG2'};

% Range to look for peaks
peakRange = [9 16]; % The lower and upper bound of the full spindle range

% Cut-offs for slow and fast ranges
slowBand = [9 12.5]; % Slow band
fastBand = [12.5 16]; % Fast band

% High filter order will create a steep filter ensuring minimal overlap
% between the slow and fast range
filtOrder = 13200;

% Plotting settings
comps2Plot = 4; % Number of components to plot
plotRange  = [5 20]; % Frequency range on the x axis
scalePSD   = 'yes'; % Scale components ('yes' or 'no')

saveFig = 'yes'; % Save the figure for later use
saveName = 'exampleSigmaPeaks.png'; % Name the figure
%% Load in the data

% Load the EEG data
psg = eeglab2danalyzer(pop_loadset('HD_exampleData_PP.set'));

% Load the sleep scores
load('exampleScores.mat')

% Load the AR info
load('exampleAR.mat')

% Subset the data into clean NREM with bad channels interpolated and
% non-EEG channels removed
myNREM = fun_subset_data(psg, sleepstages, ar, 'stage', 2:3,...
    'RemoveChannels', chans2Remove, 'Interpolate', 'yes');

% Convert back to EEGLAB format for filtering
EEG = danalyzer2eeglab(myNREM);

%% Filter the data in the broad fast and slow spindle ranges

% Double precision required for finding peaks
EEG.data = double(EEG.data);

% Filter the data. Separately filter in the fast and slow bands
fastEEG = pop_eegfiltnew(EEG, fastBand(1), fastBand(2), filtOrder); % Fast band
slowEEG = pop_eegfiltnew(EEG, slowBand(1), slowBand(2), filtOrder); % Slow band

%% Calculate covariance matrix

% Demean to prevent signal offsets from influencing covariance
fastEEG.data = bsxfun(@minus, fastEEG.data, mean(fastEEG.data, 2)); % Fast band
slowEEG.data = bsxfun(@minus, slowEEG.data, mean(slowEEG.data, 2)); % Slow band

% Covariance matrix (nchan x nchan)
fastCov = cov(fastEEG.data');
slowCov = cov(slowEEG.data');

%% Generalized Eigendecomposition

% Perform GED on covariance marices. Returns nchan x nchan eigenvactor and
% eigenvalue matrices
[evecMat, evalMat] = eig(slowCov, fastCov);

% Sort eigenvalues from highest to lowest and take real part
[~, sIdx] = sort(real(diag(evalMat)), 'descend');

% Take eiginvectors in order or descending eigenvalue. First vector
% maximizes slow relative to fast spindle range; last vector maximizes fast
% relative to slow
evecSlowFast = real(evecMat(:, sIdx));

% Apply as a spatial filter to the EEG
timeCompSF = myNREM.data' * evecSlowFast;

% Obtain PSD estimates of each component
[psdComp, psdFreqs] = fun_spectral_power(timeCompSF', myNREM.hdr.srate);

%% Plot the results

nComps = size(slowCov, 1);

firstComps = 1:comps2Plot;
lastComps  = nComps - comps2Plot+1:nComps;

%get minimum and maximum from plot range for rescaling

minPlotInd=find(psdFreqs>=plotRange(1),1,'first');
maxPlotInd=find(psdFreqs<=plotRange(2),1,'last');
MINS= min(psdComp(minPlotInd:maxPlotInd,:));
MAXS= max(psdComp(minPlotInd:maxPlotInd,:));

%rescale if requested
if strcmpi(scalePSD, 'yes')
    psdComp=0.9*bsxfun(@rdivide,(bsxfun(@minus,psdComp,MINS)),MAXS-MINS);
end

figure;

for comp_i = 1:comps2Plot
    plot(psdFreqs, psdComp(:, firstComps(comp_i)), 'LineStyle', '--', 'LineWidth', 2)
    hold on
end

for comp_i = 1:comps2Plot
    plot(psdFreqs, psdComp(:, lastComps(comp_i)), 'LineWidth', 2)
    hold on
end

set(gca, 'XLim', plotRange)
xlabel('Frequency (Hz)')
ylabel('PSD')
title(sprintf('NREM component spectra - first and last %i', comps2Plot))
legend([cellfun(@(X) ['Slow ' num2str(X)], num2cell(firstComps'),'uni',0);cellfun(@(X) ['Fast ' num2str(X)], num2cell(lastComps'),'uni',0)], 'AutoUpdate', 'off' )
%% Find peaks

combinedData = psdComp(:, [firstComps lastComps]);

keepPeaks = [];
for i = 1:size(combinedData, 2)
    
    % Find peaks and sort
    [pks, locs, ~, P]  = findpeaks(double(combinedData(:, i)), double(psdFreqs));
    [~, sortInd] = sort(pks, 'descend');
    sortedFreqs  = locs(sortInd);
    sortedProm   = P(sortInd);
    
    % Look for the largest peak in 9-16Hz range
    targetFreq   = find(sortedFreqs >= peakRange(1) & sortedFreqs <= peakRange(2), 1, 'first');
    keepPeaks(i, :) = [sortedFreqs(targetFreq) sortedProm(targetFreq)];
    
end

slowPeaks = keepPeaks(firstComps, :);
fastPeaks = keepPeaks(end - (length(lastComps) - 1):end, :);

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
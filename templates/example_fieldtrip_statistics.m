% This is an example script showing how to perform cluster-based
% permutation tests in FieldTrip. In particular, this script demonstrates
% how to organize the data, prepare the default settings, and access the
% output. There are examples for performing dependent-samples tests (i.e. a
% within subjects comparison), and correlations with behavior
%
%
% To run this script, ensure that EEGLAB and FieldTrip are properly
% installed and on the MATLAB path
%% Load the data

load('testData.mat');

% sleepData contains spindle density for N2 and N3 sleep, and
% behavior contains change in recall scores. We will conpare N2 vs N3
% spindle density in the dependent-samples test, and correlate N3 spindle
% density with memory for the correlation test. Chans is the channel
% locations, needed for clustering and plotting

%% Dependent-samples test 

% This first example is going to compare spindle density in N2 and N3 sleep
% by way of the dependent samples tests. To run the analysis, we need to
% follow these steps
%
% 1. Prepare neighbourhood structure. This takes the channel location file
% and determines, for each electrode, who its neighbours are. This is is
% needed for the clustering and determines which electrodes each electrode
% could form a cluster with.
%
% 2. Setup statistical test. We then need to specifiy all the parameters
% for the test we wish to perform
%
% 3. We create the data struct, which is again specifying a bunch of
% parameters
%
% 4. Create design matrix. This step organizes the data iteself, and tells
% FieldTrip where all the observations are (and their group assignment)
%
% 5. Run the test!
%
% 6. Plot the results
%% Prepare neighbourhood structure

myeeg = eeg_emptyset;
myeeg.chanlocs = chans;
chanlocs = eeglab2fieldtrip(myeeg, 'chanloc', 'none');
chanlocs.label = {myeeg.chanlocs.labels}; % This converts our channel location file to FieldTrip

% Everything in FieldTrip follows this setup. You create a cfg struct that
% contains all the instructions you want the FieldTrip function to carry
% out. You then pass that cfg struct to the function, along with the data
% you want to use. 
cfg = []; % Create empty cfg
cfg.method = 'distance'; 
cfg.neighbourdist = 0.55; % We are determining adjacent electrodes for clustering
cfg.neighbours = ft_prepare_neighbours(cfg, chanlocs); % Determine neighbours

%% Setup statistical test

cfg.channel = 'all'; % Use all channels
cfg.latency = 'all'; % Use all timepoints (irrelevant for our purposes, but still needs specifying) 
cfg.parameter = 'trial'; % A default we need to specify for time-averaged data
cfg.method = 'montecarlo'; % Method for significance
cfg.statistic = 'ft_statfun_depsamplesT'; % The name of the FieldTrip function we wish to use
cfg.correctm = 'cluster'; % Comparison correction
cfg.clusteralpha = 0.05; % alpha value for initital test-statistc
cfg.clusterstatistic = 'maxsum'; % How test statistic is evaluated
cfg.minnbcan = 1; % Minimum channels to form a cluster
cfg.alpha = 0.05; % Alpha value for clusters after permutation
cfg.tail = 0; % Two-sided test
cfg.correcttail = 'prob'; % Two-sided test
cfg.numrandomization = 10000; % Number of permutations
cfg.avgovertime = 'no'; % Again irrelevant for us, but needs specifying

%% Prepare data struct

% Format data. Each condition will need these parameters

ftData = []; % Create a data struct
ftData.time = 0; % Needed as we only have 1 timepoint
ftData.dimord = 'subj_chan'; % Organization of the data
ftData.grad = chanlocs.elec; % Channel locations
ftData.label = chanlocs.label; % Channel labels

%% Create design matrix

% This tells FieldTrip how the data is organized. This needs to be
% specified corretly and will indicate to FieldTrip that we have
% within-subjects data

subj = 36; % Number of participants

design = zeros(2,2*subj);
for i = 1:subj
design(1,i) = i;
end
for i = 1:subj
design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2; % This section creates the design matrix

cfg.design = design; % Add design matrix to cfg struct
cfg.uvar  = 1; % Indicate subject numbers
cfg.ivar  = 2; % Indicate condition numbers

ftData1 = ftData;
ftData1.trial = sleepData.n2;

ftData2 = ftData;
ftData2.trial = sleepData.n3; % We add the data to the data struct

%% Run the test!

statT = ft_timelockstatistics(cfg, ftData1, ftData2);

%% Plot the data
cluster = 1; % Which cluster to plot
clusterSign = 'posclusters'; % Positive or negative

figure;
f1 = subplot(1, 3, 1);
topoplot(mean(sleepData.n2), chans, 'electrodes', 'off', 'verbose', 'off');
title('N2 spindle density')
colorbar; % Plot N2 spindle density

f2 = subplot(1, 3, 2);
topoplot(mean(sleepData.n3), chans, 'electrodes', 'off', 'verbose', 'off');
title('N3 spindle density')
colorbar; % Plot N3 spindle density

f3 = subplot(1, 3, 3);
topoplot(statT.stat, chans, 'electrodes', 'off', 'verbose', 'off',...
    'emarker2', {find(statT.([clusterSign 'labelmat']) == cluster), '.', 'm', 20});
title({'N2 vs N3'...
    ['cluster (' num2str(length(find(statT.([clusterSign 'labelmat']) == cluster))) ')=' num2str(statT.(clusterSign)(cluster).clusterstat)]...
    ['p=' num2str(statT.(clusterSign)(cluster).prob)]})
colorbar; % Plot t-statstics with significant electrodes highlighted

colormap(f1, hot);
colormap(f2, hot);
colormap(f3, parula); % Adjust subplot colormaps

caxis(f1, [2 4.5]);
caxis(f2, [2 4.5]);
caxis(f3, [-3 3]); % Adjust subplot colorbars

%% Correlations with behavior

% This second example is going to correlate N3 spindle density with memory.
% The steps are very similar to dep-samples test, but I am repeating
% everything anyway. I have only commented on sections of the code that
% differ from the dep-samples test.
%
% 1. Prepare neighbourhood structure. This takes the channel location file
% and determines, for each electrode, who its neighbours are. This is is
% needed for the clustering and determines which electrodes each electrode
% could form a cluster with.
%
% 2. Setup statistical test. We then need to specifiy all the parameters
% for the test we wish to perform
%
% 3. We create the data struct, which is again specifying a bunch of
% parameters
%
% 4. Create design matrix. This step organizes the data iteself, and tells
% FieldTrip where all the observations are (and their group assignment)
%
% 5. Run the test!
%
% 6. Plot the results

%% Prepare the neighbourhood structure

myeeg = eeg_emptyset;
myeeg.chanlocs = chans;
chanlocs = eeglab2fieldtrip(myeeg, 'chanloc', 'none');
chanlocs.label = {myeeg.chanlocs.labels}; % This converts our channel location file to FieldTrip

% Everything in FieldTrip follows this setup. You create a cfg struct that
% contains all the instructions you want the FieldTrip function to carry
% out. You then pass that cfg struct to the function, along with the data
% you want to use. 
cfg = []; % Create empty cfg
cfg.method = 'distance'; 
cfg.neighbourdist = 0.55; % We are determining adjacent electrodes for clustering
cfg.neighbours = ft_prepare_neighbours(cfg, chanlocs); % Determine neighbours

%% Setup statistical test

% Set up the statical test
cfg.channel = 'all';
cfg.latency = 'all';
cfg.parameter = 'trial';
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_correlationT'; % We now specify the correlation function
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbcan = 1;
cfg.alpha = 0.05;
cfg.tail = 0;
cfg.correcttail = 'prob';
cfg.numrandomization = 10000;
cfg.avgovertime = 'no';

%% Prepare data struct

ftData = [];
ftData.time = 0;
ftData.dimord = 'subj_chan';
ftData.grad = chanlocs.elec;
ftData.label = chanlocs.label;

%% Create design matrix
clear design

subj = 36;
design(1,1:subj) = behavior;
cfg.design = design;
cfg.ivar = 1; % Design matrix is much simpler here, it is literally just the behavioral data

ftData.trial = sleepData.n3; 
%% Run the test

statT = ft_timelockstatistics(cfg, ftData);

%% Plot the data
cluster = 1; % Which cluster to plot
clusterSign = 'posclusters'; % Positive or negative

figure;
f1 = subplot(1, 2, 1);
topoplot(mean(sleepData.n3), chans, 'electrodes', 'off', 'verbose', 'off');
title('N3 spindle density')
colorbar; % Plot N3 spindle density

f2 = subplot(1, 2, 2);
topoplot(statT.rho, chans, 'electrodes', 'off', 'verbose', 'off',...
    'emarker2', {find(statT.([clusterSign 'labelmat']) == cluster), '.', 'm', 20});
title({'Correlation with memory'...
    ['cluster (' num2str(length(find(statT.([clusterSign 'labelmat']) == cluster))) ')=' num2str(statT.(clusterSign)(cluster).clusterstat)]...
    ['p=' num2str(statT.(clusterSign)(cluster).prob)]})
colorbar; % Plot r values with significant electrodes highlighted

colormap(f1, hot);
colormap(f2, hot);

caxis(f1, [2 4.5]);
caxis(f2, [0 0.5]);
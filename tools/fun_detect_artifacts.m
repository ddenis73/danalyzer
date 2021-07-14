function [ar, dataOUT] = fun_detect_artifacts(dataIN, sleepstages, varargin)
% Automated artifact rejection of sleep EEG data based on Hjorth
% parameters. This function is an attempt of a MATLAB implementation of the
% artifact rejection functions in the Luna toolbox. Artifact rejection
% works in two steps, first on the channel level, and then on the epoch
% level.
%
% This function should be considered highly experimental and may not yield
% desirble results in all settings
%
% Required inputs:
%
% dataIN = A danalyzer psg structure
%
% sleepstages = A danalyzer sleepstages structure
%
% Optional inputs:
%
% ChannelDetection = Automatically identify bad channels across the full
% recording. 'Yes' or 'No'. Default = 'Yes'
%
% ChannelParameters = A 1x4 cell array containing parameters for
% identifying bad channels {threshold(n*SD) iterations %channels,
% interpolate}. Default = {3 2 50 'no'}
%
% EpochDetection = Automatically identify bad epochs. 'Yes' or 'No'.
% Default = 'Yes'
%
% EpochParameters = A 1x4 cell array containing parameters for identifying
% bad epochs {threshold(n*SD) iteration nChannels interpolate}. Default =
% {3 2 1 'yes'}
%
% Outputs:
%
% ar = A danalyzer ar struct containing information about bad channels
% (ar.badchans) and bad epochs (ar.badepochs)
%
% dataOUT = If bad channels were interpolated, dataOUT will be a danalyzer
% psg struct with bad channels interpolated
%% 
% Authors:  Dan Denis
% Date:     2021-07-14
%
% Remarks:
%   Free use and modification of this code is permitted, provided that any
%   modifications are also freely distributed
%
%   When using this code or modifications of this code, please cite:
%       Denis D (2021). danalyzer. DOI: 10.5281/zenodo.5104418
%% Default settings

winSize = sleepstages.hdr.win;
ignoreIdx = [];
% Channel rejection settings
chDetect    = 'yes';
chEpochThresh = 3;
chIterations  = 2;
chPerThresh   = 50;
chInterp      = 'no';

% Epoch rejection settings
epDetect      = 'yes';
epEpochThresh = 3;
epIterations  = 2;
epChanThresh  = 1;
epInterp      = 'no';

if find(strcmpi(varargin, 'ChannelDetection'))
    chDetect = varargin{find(strcmpi(varargin, 'ChannelDetection'))+1};
end

if find(strcmpi(varargin, 'EpochDetection'))
    epDetect = varargin{find(strcmpi(varargin, 'EpochDetection'))+1};
end

if find(strcmpi(varargin, 'ChannelParameters'))
    chEpochThresh = varargin{find(strcmpi(varargin, 'ChannelParameters'))+1}{1};
    chIterations  = varargin{find(strcmpi(varargin, 'ChannelParameters'))+1}{2};
    chPerThresh   = varargin{find(strcmpi(varargin, 'ChannelParameters'))+1}{3};
    chInterp      = varargin{find(strcmpi(varargin, 'ChannelParameters'))+1}{4};
end

if find(strcmpi(varargin, 'EpochParameters'))
    epEpochThresh = varargin{find(strcmpi(varargin, 'EpochParameters'))+1}{1};
    epIterations  = varargin{find(strcmpi(varargin, 'EpochParameters'))+1}{2};
    epChanThresh  = varargin{find(strcmpi(varargin, 'EpochParameters'))+1}{3};
    epInterp      = varargin{find(strcmpi(varargin, 'EpochParameters'))+1}{4};
end

if find(strcmpi(varargin, 'IgnoreChannels'))
    ignoreIdx = varargin{find(strcmpi(varargin, 'IgnoreChannels'))+1};
end

if iscell(ignoreIdx)
    chans2Ignore = find(ismember({dataIN.chans.labels}, ignoreIdx));
    chans2Keep   = setdiff(1:length(dataIN.chans), chans2Ignore);
    
else
    chans2Ignore = ignoreIdx;
    chans2Keep   = setdiff(1:length(dataIN.chans), chans2Ignore);
end

% Initialize the ar structure
badepochs = zeros(length(sleepstages.stages), 1);
badchans  = zeros(length(dataIN.chans), 1);

%% Print parameters

chParams = ['Channel rejection parameters:\n'...
    'Threshold: ' num2str(chEpochThresh) 'SD above the mean for >= ' num2str(chPerThresh) '%% of epochs\n'...
    'Iterations: ' num2str(chIterations) '\n'...
    'Interpolate channels: ' chInterp];

epParams = ['Epoch rejection parameters:\n'...
    'Threshold: ' num2str(epEpochThresh) 'SD above the mean for >= ' num2str(epChanThresh) ' channels\n'...
    'Iterations: ' num2str(epIterations) '\n'...
    'Interpolate channels: ' epInterp];

if strcmpi(chDetect, 'yes') && strcmpi(epDetect, 'yes')
    fprintf(['\n\nDetecting artifacts with the following parameters:\n\n'...
    chParams '\n\n' epParams '\n\n'])
elseif strcmpi(chDetect, 'yes') && ~strcmpi(epDetect, 'no')
    fprintf(['\n\nDetecting artifacts with the following parameters:\n\n'...
    chParams '\n\n'])
elseif strcmpi(epDetect, 'yes') && ~strcmpi(chDetect, 'no')
    fprintf(['\n\nDetecting artifacts with the following parameters:\n\n'...
        epParams '\n\n'])
end


%% Subset just sleep epochs

psg2 = fun_subset_data(dataIN, sleepstages, [], 'stage', 1:5,...
    'Verbose', 'no');

%% Detect bad channels

if strcmpi(chDetect, 'yes')
    
    tic
    msg = 'Detecting bad channels...';
    fprintf(msg); % Write new msg

    
    epochIdx   = indexepochs(winSize * psg2.hdr.srate, psg2.hdr.samples);
    chanEpMask = zeros(length(dataIN.chans), length(epochIdx));
    
    sigAct = zeros(length(dataIN.chans), length(epochIdx));
    sigMob = zeros(length(dataIN.chans), length(epochIdx));
    sigCom = zeros(length(dataIN.chans), length(epochIdx));
    
    % Calculate Hjorth parameters for each channel and epoch
    for ep_i = 1:length(epochIdx)
        
        for chan_i = 1:length(dataIN.chans)
            
            % Select epoch
            epochData = psg2.data(chan_i, epochIdx(ep_i, 1):epochIdx(ep_i, 2));
            
            % Calculate Hjorth parameter
            sigAct(chan_i,ep_i) = var(epochData); % Activity
            sigMob(chan_i,ep_i) = std(diff(epochData))./std(epochData); % Mobility
            sigCom(chan_i,ep_i) = std(diff(diff(epochData)))./std(diff(epochData))./sigMob(chan_i, ep_i);
            
        end
        
    end
    
    % Find channels/epochs above threshold
    
    for chan_i = 1:length(dataIN.chans)
        
        for it_i = 1:chIterations
            
            actT = find(sigAct(chan_i,:) > nanmean(sigAct(chan_i,:)) + chEpochThresh * nanstd(sigAct(chan_i,:)));
            mobT = find(sigMob(chan_i,:) > nanmean(sigMob(chan_i,:)) + chEpochThresh * nanstd(sigMob(chan_i,:)));
            comT = find(sigCom(chan_i,:) > nanmean(sigCom(chan_i,:)) + chEpochThresh * nanstd(sigCom(chan_i,:)));
            
            chanEpMask(chan_i, actT) = 1;
            chanEpMask(chan_i, mobT) = 1;
            chanEpMask(chan_i, comT) = 1;
            
            sigAct(chan_i, actT) = NaN;
            sigMob(chan_i, mobT) = NaN;
            sigCom(chan_i, comT) = NaN;
            
        end
    end
    
    % Find all the epochs with at least one channel bad, excluding channels
    % that are being ignored
    
    epochMask = any(chanEpMask(chans2Keep, :));
    
    sigAct2 = sigAct(:, ~epochMask);
    sigMob2 = sigMob(:, ~epochMask);
    sigCom2 = sigCom(:, ~epochMask);
    
    % For each channel, calculate a Z score for each epoch based on the mean/SD
    % of all other channels
    
    zAct = zeros(length(dataIN.chans), size(sigAct2, 2));
    zMob = zeros(length(dataIN.chans), size(sigMob2, 2));
    zCom = zeros(length(dataIN.chans), size(sigCom2, 2));
    
    chanOut = zeros(length(dataIN.chans), size(sigAct2, 2));
    
    for chan_i = 1:length(dataIN.chans)
        
        if ismember(chan_i, chans2Ignore)
            
            zAct(chan_i, :) = NaN(1, size(sigAct2, 2));
            zMob(chan_i, :) = NaN(1, size(sigMob2, 2));
            zCom(chan_i, :) = NaN(1, size(sigCom2, 2));
            
        else
            
            for ep_i = 1:size(sigAct2, 2)
                
                % Epoch mean and sd all other channels
                
                c = setdiff(chans2Keep, chan_i);
                
                actM = [nanmean(sigAct2(c, ep_i)) nanstd(sigAct2(c, ep_i))];
                mobM = [nanmean(sigMob2(c, ep_i)) nanstd(sigMob2(c, ep_i))];
                comM = [nanmean(sigCom2(c, ep_i)) nanstd(sigCom2(c, ep_i))];
                
                zAct(chan_i, ep_i) = abs((sigAct2(chan_i, ep_i) - actM(1)) / actM(2));
                zMob(chan_i, ep_i) = abs((sigMob2(chan_i, ep_i) - mobM(1)) / mobM(2));
                zCom(chan_i, ep_i) = abs((sigCom2(chan_i, ep_i) - comM(1)) / comM(2));
                
            end
            
            actOut = zAct(chan_i, :) > chEpochThresh;
            mobOut = zMob(chan_i, :) > chEpochThresh;
            comOut = zCom(chan_i, :) > chEpochThresh;
            
            chanOut(chan_i, actOut) = 1;
            chanOut(chan_i, mobOut) = 1;
            chanOut(chan_i, comOut) = 1;
            
        end
    end
    
    % Mark channel as bad if >X epochs are bad
    
    badchans((sum(chanOut, 2) / size(sigAct2, 2)) * 100 >= chPerThresh) = 1;
    
    badChanN = sum(badchans);
    
    if isempty(badChanN)
        badChanN = 0;
    end
    
    detectTime = toc;
    disp([' Found ' num2str(badChanN) ' bad channels in ' num2str(detectTime) ' seconds'])

    
    clear sigAct sigAct2 sigCom sigCom2 sigMob sigMob2 chanEpMask chanOut epochMask actOut actT actM comM comOut comT mobM mobOut mobT zAct zCom zMob
    %% Interpolate bad channels
    
    if strcmpi(chInterp, 'yes')
        tic
        fprintf(['Interpolating ' num2str(badChanN) ' channels...'])
        
        dataIN.data = fun_interpolate_data(dataIN.data, dataIN.chans, badchans);
        badchans = zeros(length(dataIN.chans));
        
        interpTime = toc;
        disp(['Finished in ' num2str(interpTime) ' seconds'])
    end
    
end
%% Detect bad epochs
if strcmpi(epDetect, 'yes')
    tic
    fprintf('Detecting bad epochs...\n')
    
    % Keep track of where each epoch is in the context of the full night
    stageList(:, 1) = 1:length(sleepstages.stages);
    stageList(:, 2) = sleepstages.stages;
    
    % Channels not to use (those indicated to ignore and those marked as bad)
    chans2Keep(ismember(chans2Keep, find(badchans))) = [];
    
    % Find each sleep stage
    stageType = unique(sleepstages.stages(sleepstages.stages > 0 & sleepstages.stages < 6));
    
    stageChanMask = zeros(length(dataIN.chans), length(indexepochs(winSize * dataIN.hdr.srate, dataIN.hdr.samples)));
    
    % Loop through each sleep stage
    
    for stage_i = 1:length(stageType)
        
        fprintf(['Stage ' num2str(stageType(stage_i)) '... '])
        
        % Subset just that sleepstage
        psgSub = fun_subset_data(dataIN, sleepstages, [], 'stage', stageType(stage_i),...
            'Verbose', 'no');
        
        % Index epochs
        epochIdx = indexepochs(winSize * psgSub.hdr.srate, psgSub.hdr.samples);
        
        % Create stage mask
        stageMask = zeros(length(dataIN.chans), size(epochIdx, 1));
        
        % Create Hjorth array
        sigAct = zeros(length(dataIN.chans), size(epochIdx, 1));
        sigMob = zeros(length(dataIN.chans), size(epochIdx, 1));
        sigCom = zeros(length(dataIN.chans), size(epochIdx, 1));
        
        % Loop over each channel
        
        for chan_i = 1:length(dataIN.chans)
            
            % Loop over each epoch
            
            for ep_i = 1:size(epochIdx, 1)
                
                % Select epoch
                epochData = psgSub.data(chan_i, epochIdx(ep_i, 1):epochIdx(ep_i, 2));
                
                % Calculate Hjorth parameter
                sigAct(chan_i,ep_i) = var(epochData); % Activity
                sigMob(chan_i,ep_i) = std(diff(epochData))./std(epochData); % Mobility
                sigCom(chan_i,ep_i) = std(diff(diff(epochData)))./std(diff(epochData))./sigMob(chan_i, ep_i);
                
            end
            
        end
        
        % Find channels/epochs above threshold
        
        for chan_i = 1:length(dataIN.chans)
            
            for it_i = 1:epIterations
                
                actT = find(sigAct(chan_i,:) > nanmean(sigAct(chan_i,:)) + epEpochThresh * nanstd(sigAct(chan_i,:)));
                mobT = find(sigMob(chan_i,:) > nanmean(sigMob(chan_i,:)) + epEpochThresh * nanstd(sigMob(chan_i,:)));
                comT = find(sigCom(chan_i,:) > nanmean(sigCom(chan_i,:)) + epEpochThresh * nanstd(sigCom(chan_i,:)));
                
                stageMask(chan_i, actT) = 1;
                stageMask(chan_i, mobT) = 1;
                stageMask(chan_i, comT) = 1;
                
                sigAct(chan_i, actT) = NaN;
                sigMob(chan_i, mobT) = NaN;
                sigCom(chan_i, comT) = NaN;
                
            end
        end
        
        % What to do with bad epochs.
        
        if epChanThresh == 1
            
            badEp = any(stageMask(chans2Keep, :));
            
            % Add bad epochs to the output array
            stageEp = stageList(stageList(:, 2) == stageType(stage_i), 1);
            
            if ~isempty(stageEp)
                badepochs(stageEp(badEp)) = 1;
            end
            
        elseif epChanThresh > 1
            
            badEp = zeros(size(stageMask, 2), 1);
            
            for ep_i = 1:size(stageMask, 2)
                
                badChanIdx = find(stageMask(chans2Keep, ep_i) == 1);
                
                if length(badChanIdx) >= epChanThresh
                    badEp(ep_i) = 1;
                end
            end
            
            % Add bad epochs to the output array
            stageEp = stageList(stageList(:, 2) == stage_i, 1);
            
            if ~isempty(stageEp)
                badepochs(stageEp(find(badEp))) = 1;
            end
            
        end
        
        % Add to mask
        if ~isempty(stageEp)
            stageChanMask(:, stageEp) = stageMask;
        end
        
        detectTime = toc;
        
        disp(['Found ' num2str(length(find(badEp))) ' bad epochs in ' num2str(detectTime) ' seconds'])
        
        clear epochIdx stageMask sigAct sigMob sigCom actT mobT comT badEp stageEp
    end
    
    %% By-epoch interpolation
    
    if strcmpi(epInterp, 'yes')
                
        tic
        fprintf('Interpolating channels...')
        
        epochIdx = indexepochs(winSize * dataIN.hdr.srate, dataIN.hdr.samples);
        stageChanMask(chans2Ignore, :) = zeros(length(chans2Ignore), size(stageChanMask, 2));
        
        dataOUT = dataIN;
        dataOUT.data = zeros(length(dataIN.chans), dataIN.hdr.samples);
        
        for ep_i = 1:size(epochIdx, 1)
            
            if find(stageChanMask(:, ep_i)) < epChanThresh
                
                dataOUT.data(:, epochIdx(ep_i, 1):epochIdx(ep_i, 2)) = fun_interpolate_data(...
                    dataIN.data(:, epochIdx(ep_i, 1):epochIdx(ep_i, 2)), dataIN.chans, stageChanMask(:, ep_i));
                
                badepochs(ep_i) = 0;
                
            else
                dataOUT.data(:, epochIdx(ep_i, 1):epochIdx(ep_i, 2)) = dataIN.data(:, epochIdx(ep_i, 1):epochIdx(ep_i, 2));
                
            end
            
        end
        
        interpTime = toc;
        disp(['Finished in ' num2str(interpTime) ' seconds'])
        
    else
        dataOUT = dataIN;
    end
end
%% Create ar struct
ar.badchans  = badchans;
ar.badepochs = badepochs;

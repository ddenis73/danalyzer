function [hParam, hBad] = fun_ar_hjorth(data, srate, win, threshold, iterations)
% Calculate Hjorth parameters (activity, mobility, complexity) on a single
% channel. Returns the parameters themselves, and segments defined as
% artifactual
%
% Input:
%
% data: 1xn channels of data
%
% srate: Sampling rate of the data (in Hz)
%
% win: The size of the window to use calculating Hjorth parameters (in
% seconds)
%
% threshold: The number of times the signal standard deviation to consider
% a segment as bad
%
% iterations: How many rounds of artifact rejection should there be.
%
% Output:
%
% hParam: Hjorth parameters for each epoch
%
% hBad: Logical indicating whether an epoch exceeded threshold, one column
% for each parameter
%% Calculate parameters

% Get the start and end point of each 'epoch'

epochIdx = indexepochs(win * srate, length(data));
epochIdx(:, 3) = zeros(size(epochIdx, 1), 1);

% Initialize hBad
hBad = zeros(size(epochIdx, 1), 5);


for epoch_i = 1:size(epochIdx, 1)
    
    if epochIdx(epoch_i, 3) == 0
        
        % Select epoch
        epochData = data(epochIdx(epoch_i,1):1:epochIdx(epoch_i,2));
        
        % Calculate Hjorth
        sigAct(epoch_i,:) = var(epochData); % Activity
        sigMob(epoch_i,:) = std(diff(epochData))./std(epochData); % Mobility
        sigCom(epoch_i,:) = std(diff(diff(epochData)))./std(diff(epochData))./sigMob(epoch_i);
        
        % RMS
        sigRMS(epoch_i,:) = rms(epochData);
        
        % Clipping parameters
        sigClip(epoch_i,:) = signalclipping(epochData);
        
    else
        sigAct(epoch_i,:)  = NaN;
        sigMob(epoch_i,:)  = NaN;
        sigCom(epoch_i,:)  = NaN;
        sigRMS(epoch_i,:)  = NaN;
        sigClip(epoch_i,:) = NaN;
        
    end
end

hParam = [sigAct sigMob sigCom sigRMS sigClip];

%% Determine outliers

for i = 1:iterations
    actT   = mean(sigAct, 'omitnan') + threshold * std(sigAct, 'omitnan');
    mobT   = mean(sigMob, 'omitnan') + threshold * std(sigMob, 'omitnan');
    comT   = mean(sigCom, 'omitnan') + threshold * std(sigCom, 'omitnan');
    rmsT   = mean(sigRMS, 'omitnan') + threshold * std(sigRMS, 'omitnan');
    clipT  = mean(sigClip, 'omitnan') + threshold * std(sigClip, 'omitnan');
    
    badEpochs = [find(sigAct > actT); find(sigMob > mobT); find(sigCom > comT); find(sigRMS > rmsT); find(sigClip > clipT)];
    
    hBad(find(sigAct > actT), 1)  = 1;
    hBad(find(sigMob > mobT), 2)  = 1;
    hBad(find(sigCom > comT), 3)  = 1;
    hBad(find(sigRMS > rmsT), 4)  = 1;
    hBad(find(sigClip > clipT), 5) = 1;
    
    [b, ~] = find(badEpochs);
    
    sigAct(b)  = NaN;
    sigMob(b)  = NaN;
    sigCom(b)  = NaN;
    sigRMS(b)  = NaN;
    sigClip(b) = NaN;
    
end
    
    
    


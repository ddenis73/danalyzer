function [psgOUT, scoresOUT] = subsetsleepstage(psg, scores, ar, sleepstage, verbose)
%

%% © 2021 Dan Denis, PhD
%
% This function is part of the danalyzer toolbox. danalyzer is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU General Public License as published by the Free Software Foundation,
% either version 3 of the License or any later version.
%
% danalyzer is distributed with the hope that others will find it useful.
% It comes without any warranty; without even the implied warranty of
% merchantability or fitness for a particular purpose. See the GNU General
% Public License for more details.

% danalyzer is intended for research purposes only. Any commercial or
% medical use of this software is prohibited. The author accepts no
% responsibility for its use in this manner

% Get length of epoch in samples
epochSampleLength = scores.hdr.win * psg.hdr.srate;

% Get the start and end sample of each epoch
epochSample = indexepochs(epochSampleLength, psg.hdr.samples);

% Find which epochs are the sleep stage you want

epochIdx = find(ismember(scores.stages, sleepstage));

if strcmpi(verbose, 'yes')
    fprintf(['Found ' num2str(length(epochIdx)) ' stage ' num2str(sleepstage) ' epochs.\n'])
    
    % Remove any of the epochs that are marked as bad
    
    fprintf(['Removing ' num2str(length(find(ar.badepochs(epochIdx) == 1))) ' bad epochs.\n'])
end
% Update the score file to reflect the subsetted data

if ~isempty(ar)
    ar.badepochs = ar.badepochs(epochIdx);
    newScores = scores;
    newScores.stages = scores.stages(epochIdx);
    newScores.stages(ar.badepochs == 1, :, :) = [];
    epochIdx(ar.badepochs == 1,:) = [];
    
    if isfield(newScores, 'hdr')
        scoresOUT = updatestages(newScores, psg.hdr.srate, 30);
    else
        scoresOUT = newScores;
    end
end

if ~isempty(epochIdx)
    
    % Get start and end samples for all selected epochs
    targetEpochSample = epochSample(epochIdx,:);
    
    for epoch_i = 1:size(targetEpochSample, 1)
        if epoch_i == 1
            segments = targetEpochSample(epoch_i, 1):1:targetEpochSample(epoch_i, 2);
        else
            segments = [segments targetEpochSample(epoch_i, 1):1:targetEpochSample(epoch_i, 2)];
        end
    end
    
    psgOUT.data = psg.data(:, segments);
    psgOUT.hdr  = psg.hdr;
    psgOUT.hdr.samples = size(segments, 2);
    psgOUT.chans = psg.chans;
    
elseif isempty(epochIdx)
    psgOUT = psg;
    psgOUT.data = [];
    psgOUT.hdr.samples = 0;
end
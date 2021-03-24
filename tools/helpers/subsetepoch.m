function [psgOUT, scoresOUT] = subsetepoch(psg, scores, ar, epoch)
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
epochSampleLength = 30 * psg.hdr.srate;

% Get the start and end sample of each epoch
epochSample = indexepochs(epochSampleLength, psg.hdr.samples);

% Get the indcies of the epochs to subset

fprintf(['Selecting ' num2str(length(epoch)) ' epochs.\n'])
segments = epochSample(epoch,:);

% Remove epochs marked as artifacts

fprintf(['Removing ' num2str(length(find(ar.badepochs(epoch) == 1))) ' bad epochs.\n'])
segmentAR = ar.badepochs(epoch);
segments(segmentAR == 1, :) = [];

% Update the score file to reflect the subsetted data
newScores = scores;
newScores.stages = scores.stages(epoch);

if isfield(newScores, 'hdr')
    scoresOUT = updatestages(newScores, psg.hdr.srate, 30);
else
    scoresOUT = newScores;
end


for epoch_i = 1:size(segments, 1)
    
    if epoch_i == 1
        data2keep = segments(1,1):1:segments(1,2);
    else
        data2keep = [data2keep segments(epoch_i,1):1:segments(epoch_i,2)];
    end
    
end


% Create the PSG out struct
psgOUT.hdr  = psg.hdr;

if ~isempty(segments)
    
    psgOUT.data = psg.data(:, data2keep);
    psgOUT.hdr.samples = length(data2keep);
    
else
    
    psgOUT.data = [];
    psgOUT.hdr.sample = 0;
    
end

psgOUT.chans = psg.chans;




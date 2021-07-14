function [psgOUT, scoresOUT] = subsetepoch(psg, scores, ar, epoch)
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
%%

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




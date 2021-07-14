function scoresOUT = updatestages(scoresIN, srate, epochLength)
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

epochSampleIdx = indexepochs(epochLength * srate, (length(scoresIN.stages) * epochLength) * srate);
epochSecIdx = indexepochs(epochLength, (length(scoresIN.stages) * epochLength));
epochSecIdx = epochSecIdx(:,1) - 1;


scoresOUT.stages        = scoresIN.stages;
scoresOUT.hdr.srate     = srate;
scoresOUT.hdr.win       = epochLength;
scoresOUT.hdr.recStart  = scoresIN.hdr.recStart;
scoresOUT.hdr.lOff      = scoresIN.hdr.lOff;
scoresOUT.hdr.lOn       = scoresIN.hdr.lOn;
scoresOUT.hdr.onsets    = epochSampleIdx(:, 1);
scoresOUT.hdr.stageTime = epochSecIdx';
scoresOUT.hdr.notes     = '';

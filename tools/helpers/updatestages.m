function scoresOUT = updatestages(scoresIN, srate, epochLength)
% Update a sleepstages struct 

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

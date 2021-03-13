function scoresOUT = updatestages(scoresIN, srate, epochLength)
% Update a sleepstages struct 

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

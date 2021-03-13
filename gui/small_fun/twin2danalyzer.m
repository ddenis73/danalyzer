function sleepstagesOUT = twin2danalyzer(sleepstagesIN)
% Convert a TWin score file to a danalyzer score file.

for countRow=1:height(sleepstagesIN)
    % In the cell with the time (col 1) and sleep stage (column 2) info, find text that indicates the current sleep stage
    if strcmp(sleepstagesIN.Var3(countRow),'Stage - W')
        stageChanges(countRow,1)=0;
    elseif strcmp(sleepstagesIN.Var3(countRow),'Stage - N1')
        stageChanges(countRow,1)=1;
    elseif strcmp(sleepstagesIN.Var3(countRow),'Stage - N2')
        stageChanges(countRow,1)=2;
    elseif strcmp(sleepstagesIN.Var3(countRow),'Stage - N3')
        stageChanges(countRow,1)=3;
    elseif strcmp(sleepstagesIN.Var3(countRow),'Stage - N4')
        stageChanges(countRow,1)=4;
    elseif strcmp(sleepstagesIN.Var3(countRow),'Stage - R')
        stageChanges(countRow,1)=5;
    elseif strcmp(sleepstagesIN.Var3(countRow),'Stage - Mvt')
        stageChanges(countRow,1)=6;
    elseif strcmp(sleepstagesIN.Var3(countRow),'Stage - No Stage')
        stageChanges(countRow,1)=7;
    else
        stageChanges(countRow,1)=7;
    end
end

%---------------------Loop in which missing epochs are added

listStages=[];
%this goes through each unique line in stageChangesEpochNum, (-1 (the last one), because after that there are no more epochs to fill
for countRow=1:height(sleepstagesIN)-1 
    
    % Find the current epoch in the variable stageChangesEpochNum, e.g., 1
    currentEpoch=sleepstagesIN.Var1(countRow);
    
    % Find the next epoch where the sleepstage changes, e.g., 9
    nextEpoch=sleepstagesIN.Var1(countRow+1);
    
    % All the epochs in between should be filled in, so (9-1)-1=7 epochs to fill
    epochs2fill=nextEpoch-currentEpoch-1;
    currentStage=stageChanges(countRow);
    
    addEpochs(1:epochs2fill+1,1)=currentStage;
    listStages=[listStages;addEpochs];
    addEpochs=[];
end

% Find recording start time
recStartIdx = strcmpi(sleepstagesIN.Var3, 'start recording');
lOffIdx = strcmpi(sleepstagesIN.Var3, 'lights off') | strcmpi(sleepstagesIN.Var3, 'lights out');
lOnIdx = strcmpi(sleepstagesIN.Var3, 'lights on');

sleepstagesOUT.stages        = listStages;
sleepstagesOUT.hdr.srate     = [];
sleepstagesOUT.hdr.win       = [];
sleepstagesOUT.hdr.recStart  = datestr(sleepstagesIN.Var2(recStartIdx), 'HH:MM:ss.FFF');
sleepstagesOUT.hdr.lOff      = datestr(sleepstagesIN.Var2(lOffIdx), 'HH:MM:ss.FFF');
sleepstagesOUT.hdr.lOn       = datestr(sleepstagesIN.Var2(lOnIdx), 'HH:MM:ss.FFF');
sleepstagesOUT.hdr.onsets    = [];
sleepstagesOUT.hdr.stageTime = [];
sleepstagesOUT.hdr.notes     = '';
sleepstagesOUT.hdr.scorer    = '';
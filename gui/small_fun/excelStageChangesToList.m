function listStages=excelStageChangesToList(sleepStageFilename)
%%
% Authors:  Roy Cox
% Date:     2021-07-14
%
% Remarks:
%   Free use and modification of this code is permitted, provided that any
%   modifications are also freely distributed
%
%   When using this code or modifications of this code, please cite:
%       Denis D (2021). danalyzer. DOI: 10.5281/zenodo.5104418
%%
% Read in sleepstages file
[stageChangesEpochNum,stageText,rawStageinfo]=xlsread(sleepStageFilename);

%---------- first change all text to numbers for sleep stages

for countRow=1:length(stageChangesEpochNum)
    % In the cell with the time (col 1) and sleep stage (column 2) info, find text that indicates the current sleep stage
    if strcmp(stageText(countRow,2),'Stage - W')
        stageChanges(countRow,1)=0;
    elseif strcmp(stageText(countRow,2),'Stage - N1')
        stageChanges(countRow,1)=1;
    elseif strcmp(stageText(countRow,2),'Stage - N2')
        stageChanges(countRow,1)=2;
    elseif strcmp(stageText(countRow,2),'Stage - N3')
        stageChanges(countRow,1)=3;
    elseif strcmp(stageText(countRow,2),'Stage - R')
        stageChanges(countRow,1)=5;
    elseif strcmp(stageText(countRow,2),'Stage - Mvt')
        stageChanges(countRow,1)=6;
    elseif strcmp(stageText(countRow,2),'Stage - No Stage')
        stageChanges(countRow,1)=0;
    else
        stageChanges(countRow,1)=8;
    end
end

%---------------------Loop in which missing epochs are added

listStages=[];
%this goes through each unique line in stageChangesEpochNum, (-1 (the last one), because after that there are no more epochs to fill
for countRow=1:length(stageChangesEpochNum)-1 
    
    % Find the current epoch in the variable stageChangesEpochNum, e.g., 1
    currentEpoch=stageChangesEpochNum(countRow);
    
    % Find the next epoch where the sleepstage changes, e.g., 9
    nextEpoch=stageChangesEpochNum(countRow+1);
    
    % All the epochs in between should be filled in, so (9-1)-1=7 epochs to fill
    epochs2fill=nextEpoch-currentEpoch-1;
    currentStage=stageChanges(countRow);
    
    addEpochs(1:epochs2fill+1,1)=currentStage;
    listStages=[listStages;addEpochs];
    addEpochs=[];
end
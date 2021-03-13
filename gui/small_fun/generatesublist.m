function subList = generatesublist(folderLocation)
% Generate a list of subjects to run through as a batch. Only use when data
% is stored in a way that each subject's data is stored in their own
% folder.

subList = dir(folderLocation);
isItAFolder = [subList(:).isdir];
subList = {subList(isItAFolder).name}';
subList(ismember(subList,{'.','..'})) = [];




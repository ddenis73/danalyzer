function subList = generatesublist(folderLocation)
% Generate a list of subjects to run through as a batch. Only use when data
% is stored in a way that each subject's data is stored in their own
% folder.
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

subList = dir(folderLocation);
isItAFolder = [subList(:).isdir];
subList = {subList(isItAFolder).name}';
subList(ismember(subList,{'.','..'})) = [];




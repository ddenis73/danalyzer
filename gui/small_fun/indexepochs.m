function epochIdx = indexepochs(epochLength, samples)
% Produce a start and end index (in samples) for each epoch in a record,
% based on the given epoch length, and the total number of
% samples in the record
%
% Required inputs:
%
% epochLength = Epoch length in samples
%
% samples = Total samples in the record
%
% Output:
%
% epochIdx = Index (in samples) of the start and end of each epoch
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

epochIdx(:, 1) = (1:epochLength:samples)';
epochIdx(:, 2) = (unique([epochLength:epochLength:...
    samples, samples]))';
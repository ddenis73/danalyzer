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

epochIdx(:, 1) = (1:epochLength:samples)';
epochIdx(:, 2) = (unique([epochLength:epochLength:...
    samples, samples]))';
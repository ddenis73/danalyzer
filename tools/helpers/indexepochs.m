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


epochIdx(:, 1) = (1:epochLength:samples)';
epochIdx(:, 2) = (unique([epochLength:epochLength:...
    samples, samples]))';
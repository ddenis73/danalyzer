function montage = dan_empty_montage(psg)
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

% Fill montage struct with default info

    montage.chanList       = psg.chans;
    montage.hideChans      = [];
    montage.showChans      = {psg.chans.labels}';
    montage.reref          = cell(length(psg.chans), 1);
    montage.filters        = zeros(length(psg.chans), 2);
    montage.notch          = zeros(length(psg.chans), 1);
    montage.colors         = zeros(5, 3);
    montage.scaleLine      = [];
    montage.scaleLineColor = [];
    montage.scaleLineType  = [];
    montage.scaleLinePos   = [];

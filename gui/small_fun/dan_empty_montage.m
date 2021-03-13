function montage = dan_empty_montage(psg)

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

function handles = dan_initialize_struct(handles, clearData, clearMontage)
% Create empty data & montage structs

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

if clearData == 1
    
    psg.data   = [];
    psg.hdr    = [];
    psg.chans  = [];
    psg.stages = [];
    psg.events = [];
    psg.ar     = [];
    
    psg.hdr.srate    = [];
    psg.hdr.samples  = [];
    psg.hdr.recStart = [];
    psg.hdr.name     = [];
    psg.hdr.original = [];
    
    psg.stages.s1.stages = [];
    psg.stages.s1.hdr    = [];
    psg.stages.spectogram.specto = [];
    psg.stages.spectogram.hdr = [];
    
    psg.stages.s1.hdr.srate     = [];
    psg.stages.s1.hdr.win       = [];
    psg.stages.s1.hdr.recStart  = "";
    psg.stages.s1.hdr.lOn       = "";
    psg.stages.s1.hdr.lOff      = "";
    psg.stages.s1.hdr.notes     = [];
    psg.stages.s1.hdr.onsets    = [];
    psg.stages.s1.hdr.stageTime = [];
    psg.stages.s1.hdr.scorer    = [];

    psg.ar.badchans    = [];
    psg.ar.badepochs   = [];
    psg.ar.badsegments = [];
    
    handles.psg = psg;
    handles.handCounts = [];
    handles.specData   = [];
    handles.detections.d1 = [];
    
end

if clearMontage == 1
    
    montage.chanList       = [];
    montage.hideChans      = [];
    montage.showChans      = [];
    montage.reref          = [];
    montage.filters        = [];
    montage.notch          = [];
    montage.colors         = [];
    montage.scaleLine      = [];
    montage.scaleLineColor = [];
    montage.scaleLineType  = [];
    montage.scaleLinePos   = [];
    
    handles.montage = montage;
    
end


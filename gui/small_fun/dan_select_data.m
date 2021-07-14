function handles = dan_select_data(handles, subsetOpts)
% Function to remove segments of data e.g. only look at clean N2 epochs
%
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
chansToRemove = strsplit(subsetOpts{3}, ' ');

if isempty(subsetOpts{2})
    subsetOpts{2} = 'no';
end

if isempty(subsetOpts{4})
    subsetOpts{4} = 'no';
end

if strcmpi(subsetOpts{1}, 'Wake') || strcmpi(subsetOpts{1}, '0')
    stageToSubset = 0;
elseif strcmpi(subsetOpts{1}, 'N1') || strcmpi(subsetOpts{1}, 'S1') || strcmpi(subsetOpts{1}, '1')
    stageToSubset = 1;
elseif strcmpi(subsetOpts{1}, 'N2') || strcmpi(subsetOpts{1}, 'S2') || strcmpi(subsetOpts{1}, '2')
    stageToSubset = 2;
elseif strcmpi(subsetOpts{1}, 'N3') || strcmpi(subsetOpts{1}, 'S3') || strcmpi(subsetOpts{1}, '3')
    stageToSubset = 3;
elseif strcmpi(subsetOpts{1}, 'N4') || strcmpi(subsetOpts{1}, 'S4') || strcmpi(subsetOpts{1}, '4')
    stageToSubset = 4;
elseif strcmpi(subsetOpts{1}, 'NREM') || strcmpi(subsetOpts{1}, '1234')
    stageToSubset = [1 2 3 4];
elseif strcmpi(subsetOpts{1}, 'N23') || strcmpi(subsetOpts{1}, 'S23') || strcmpi(subsetOpts{1}, '23')
    stageToSubset = [2 3];
elseif strcmpi(subsetOpts{1}, 'REM') || strcmpi(subsetOpts{1}, '5')
    stageToSubset = 5;
elseif strcmpi(subsetOpts{1}, 'MVT') || strcmpi(subsetOpts{1}, 'MT') || strcmpi(subsetOpts{1}, '6')
    stageToSubset = 6;
end
    

if strcmpi(subsetOpts{4}, 'yes') && strcmpi(subsetOpts{2}, 'yes')
    newData = fun_subset_data(handles.psg, handles.psg.stages.s1, handles.psg.ar, 'stage', stageToSubset,...
        'IgnoreChannels', chansToRemove, 'ChannelRejectionMode', 'interpolate');
elseif strcmpi(subsetOpts{4}, 'yes') && strcmpi(subsetOpts{2}, 'no')
    newData = fun_subset_data(handles.psg, handles.psg.stages.s1, [], 'stage', stageToSubset,...
        'IgnoreChannels', chansToRemove, 'ChannelRejectionMode', 'interpolate');
elseif strcmpi(subsetOpts{4}, 'no') && strcmpi(subsetOpts{2}, 'yes')
    newData = fun_subset_data(handles.psg, handles.psg.stages.s1, handles.psg.ar, 'stage', stageToSubset,...
        'IgnoreChannels', chansToRemove, 'ChannelRejectionMode', 'none');
elseif strcmpi(subsetOpts{4}, 'no') && strcmpi(subsetOpts{2}, 'no')
    newData = fun_subset_data(handles.psg, handles.psg.stages.s1, [], 'stage', stageToSubset,...
        'IgnoreChannels', chansToRemove, 'ChannelRejectionMode', 'none');
end

handles.og.psg       = handles.psg;
handles.og.plotParam = handles.plotParam;

handles = dan_clear_data(handles);

handles = dan_initialize_struct(handles, 1, 0);

%% Re-populate psg struct

psg.data   = newData.data;
psg.chans  = newData.chans;
psg.stages = [];
psg.events = [];
psg.ar     = [];
handles.plotParam = [];

psg.hdr.srate    = newData.hdr.srate;
psg.hdr.samples  = newData.hdr.samples;
psg.hdr.recStart = [];
psg.hdr.name     = ['Clean ' subsetOpts{1} 'data'];
psg.hdr.original = [];

handles.psg = psg;

% Prepare some defaults
set(handles.current_epoch_number, 'String', '1'); % Make sure to start from epoch 1
handles.plotParam.epochIdx = 1;
handles.plotParam.startTime = 0; % Starting time
handles.plotParam.currSample = 1; % Tracks arbitary jumps

handles = dan_index_epochs(handles);

% Update the stage, ar, and events fields
%% Sleep stages
if strcmpi(subsetOpts{1}, 'N1') || strcmpi(subsetOpts{1}, 'S1') || strcmpi(subsetOpts{1}, '1')
    stages.stages = ones(length(handles.plotParam.epochSample), 1);
elseif strcmpi(subsetOpts{1}, 'N2') || strcmpi(subsetOpts{1}, 'S2') || strcmpi(subsetOpts{1}, '2')
    stages.stages = 2.* ones(length(handles.plotParam.epochSample), 1);
elseif strcmpi(subsetOpts{1}, 'N3') || strcmpi(subsetOpts{1}, 'S3') || strcmpi(subsetOpts{1}, '3')
    stages.stages = 3.* ones(length(handles.plotParam.epochSample), 1);
elseif strcmpi(subsetOpts{1}, 'N4') || strcmpi(subsetOpts{1}, 'S4') || strcmpi(subsetOpts{1}, '4')
    stages.stages = 4.* ones(length(handles.plotParam.epochSample), 1);
elseif strcmpi(subsetOpts{1}, 'REM')
    stages.stages = 5.* ones(length(handles.plotParam.epochSample), 1);
elseif strcmpi(subsetOpts{1}, 'MVT') || strcmpi(subsetOpts{1}, 'MT')
    stages.stages = 6.* ones(length(handles.plotParam.epochSample), 1);
end

stages.hdr.srate     = handles.og.psg.stages.s1.hdr.srate;
stages.hdr.win       = handles.og.psg.stages.s1.hdr.win;
stages.hdr.recStart  = "";
stages.hdr.lOn       = "";
stages.hdr.lOff      = "";
stages.hdr.notes     = handles.og.psg.stages.s1.hdr.notes;
stages.hdr.onsets    = handles.plotParam.epochSample(:, 1);
stages.hdr.stageTime = (handles.plotParam.epochSample(:,1)'-1) / handles.psg.hdr.srate;

handles.psg.stages.s1 = stages;
%% AR

ar.badepochs   = zeros(length(handles.plotParam.epochSample), 1);
ar.badchans    = zeros(length(handles.psg.chans), 1);
ar.badsegments = [];

handles.psg.ar = ar;

%% Detections
    handles.detections.d1 = struct('label', cell(length({psg.chans.labels}), 1), 'sleepstage', [],...
        'count', [], 'startSample', [], 'endSample', [],...
        'duration', [], 'peakAmp', [], 'peakFreq', []);
    [handles.detections.d1.label] = psg.chans.labels;
    [handles.detections.d1.count] = deal(0);

%% Montage

handles.montage = dan_empty_montage(handles.psg);
%%
% Check scores and ar are aligned with the data
handles = dan_data_check(handles);

% Update epoch info at bottom of GUI
handles = dan_update_epoch_info_string(handles);

% Make spectrogram if asked for

if ~isempty(get(handles.spectogram_string, 'String'))
    handles = dan_make_spectogram(handles);
end




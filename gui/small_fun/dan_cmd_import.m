function [handles, hObject] = dan_cmd_import(handles, hObject, varargin)

% If data_viewer was called from MATLAB, populate the psg structure with
% inputted data

varargin = varargin{1};

if find(strcmpi(varargin, 'psg'))
    psg = varargin{find(strcmpi(varargin, 'psg'))+1};
    
    handles.psg.data  = psg.data;
    handles.psg.chans = psg.chans;
    
    if isfield(psg.hdr, 'srate')
        handles.psg.hdr.srate  = psg.hdr.srate;
    end
    
    if isfield(psg.hdr, 'samples')
        handles.psg.hdr.samples = psg.hdr.samples;
    end
    
    if isfield(psg.hdr, 'recStart')
        handles.psg.hdr.recStart = psg.hdr.recStart;
    end
    
    if isfield(psg.hdr, 'name')
        handles.psg.hdr.name = psg.hdr.name;
    else
        handles.psg.hdr.name = 'psg data';
    end
    
    if isfield(psg.hdr, 'original')
        handles.psg.hdr.original = psg.hdr.original;
    else
        handles.psg.hdr.original = 'psg data';
    end
    
    % Prepare detection struct based on input data
    handles.detections.d1 = struct('label', cell(length({psg.chans.labels}), 1), 'sleepstage', [],...
        'count', [], 'startSample', [], 'endSample', [],...
        'duration', [], 'peakAmp', [], 'peakFreq', []);
    [handles.detections.d1.label] = psg.chans.labels;
    [handles.detections.d1.count] = deal(0);

    
end

if find(strcmpi(varargin, 'sleepstages'))
    sleepstages = varargin{find(strcmpi(varargin, 'sleepstages'))+1};

    if isstruct(sleepstages)
        
        if length(sleepstages) == 1
        
        handles.psg.stages.s1.stages = sleepstages.stages;
        handles.psg.stages.s1.hdr    = sleepstages.hdr;
        
        set(handles.lights_on_time, 'String', handles.psg.stages.s1.hdr.lOn)
        set(handles.lights_out_time, 'String', handles.psg.stages.s1.hdr.lOff)
        set(handles.recording_start_time, 'String', handles.psg.stages.s1.hdr.recStart)
        
        eventsTable = {handles.psg.stages.s1.hdr.recStart 'Start recording';
            handles.psg.stages.s1.hdr.lOff 'Lights off';...
            handles.psg.stages.s1.hdr.lOn 'Lights on'};
        
        handles.psg.events = dan_get_event_latencies(eventsTable, handles.psg.stages.s1.hdr.recStart, handles.psg.hdr.srate);
        
        elseif length(sleepstages) > 1
            
            for i = 1:length(sleepstages)
                
                scoreFieldName = ['s' num2str(i)];
                
                handles.psg.stages.(scoreFieldName).stages = sleepstages(i).stages;
                handles.psg.stages.(scoreFieldName).hdr    = sleepstages(i).hdr;
                
                set(handles.lights_on_time, 'String', handles.psg.stages.s1.hdr.lOn)
                set(handles.lights_out_time, 'String', handles.psg.stages.s1.hdr.lOff)
                set(handles.recording_start_time, 'String', handles.psg.stages.s1.hdr.recStart)
                
                eventsTable = {handles.psg.stages.s1.hdr.recStart 'Start recording';
                    handles.psg.stages.s1.hdr.lOff 'Lights off';...
                    handles.psg.stages.s1.hdr.lOn 'Lights on'};
                
                handles.psg.events = dan_get_event_latencies(eventsTable, handles.psg.stages.s1.hdr.recStart, handles.psg.hdr.srate);
                
            end
            
        end
        
    else
        if length(sleepstages) == 1
            handles.psg.stages.s1.stages = sleepstages;
        elseif length(sleepstages) > 1
            
            for i = 1:length(sleepstages)
                scoreFieldName = ['s' num2str(i)];
                handles.psg.stages.(scoreFieldName).stages = sleepstages;
            end
        end
    end
end

if find(strcmpi(varargin, 'ar'))
    ar = varargin{find(strcmpi(varargin, 'ar'))+1};
    
    if isfield(ar, 'badepochs')
        handles.psg.ar.badepochs = ar.badepochs;
    end
    
    if isfield(ar, 'badchans')
        handles.psg.ar.badchans = ar.badchans;
    end
    
    if isfield(ar, 'badsegments')
        handles.psg.ar.badsegments = ar.badsegments;
    end
    
end

if find(strcmpi(varargin, 'detections'))
    specData = varargin{find(strcmpi(varargin, 'detections'))+1};
    
    if size(specData, 1) == 1
        
        handles.detections.d2 = specData;
        
    elseif size(specData, 1) > 1
        
        for i = 1:size(specData, 1)
            
            detectFieldName = ['d' num2str(i) + 1];
            
            handles.detections.(detectFieldName) = specData(i,:);
        end
    end        
end



% Prepare some defaults
set(handles.current_epoch_number, 'String', '1'); % Make sure to start from epoch 1
handles.plotParam.epochIdx = 1;
handles.plotParam.startTime = 0; % Starting time
handles.plotParam.currSample = 1; % Tracks arbitary jumps

% Prepare a montage
handles.montage = dan_empty_montage(psg);

% Create a list of epoch start and end samples
handles = dan_index_epochs(handles);

% Check scores and ar are aligned with the data
handles = dan_data_check(handles);

% Update epoch info at bottom of GUI
handles = dan_update_epoch_info_string(handles);

% Plot data to screen
[hObject, handles] = dan_plot_psg(hObject, handles);

% Plot hypnogram to screen
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update GUI title to dataset name
[~,dataName,dataExt] = fileparts(get(handles.data_file_string, 'String'));
set(handles.main_window, 'Name', [dataName dataExt]);

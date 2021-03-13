function varargout = data_viewer(varargin)
% DATA_VIEWER MATLAB code for data_viewer.fig
%      DATA_VIEWER, by itself, creates a new DATA_VIEWER or raises the existing
%      singleton*.
%
%      H = DATA_VIEWER returns the handle to a new DATA_VIEWER or the handle to
%      the existing singleton*.
%
%      DATA_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_VIEWER.M with the given input arguments.
%
%      DATA_VIEWER('Property','Value',...) creates a new DATA_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help data_viewer

% Last Modified by GUIDE v2.5 13-Mar-2021 16:04:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @data_viewer_OpeningFcn, ...
    'gui_OutputFcn',  @data_viewer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before data_viewer is made visible.
function data_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_viewer (see VARARGIN)

% Choose default command line output for data_viewer
handles.output = hObject;

handles = dan_initialize_struct(handles, 1, 1);
handles.segmentFunction = 1;
handles.hypSpec = 1;
handles.segColor = 1;

% Find monatages
toolboxPath = fileparts(which('sleepDanalyzer'));

handles.montageList = dir([fullfile(toolboxPath, 'montages') filesep '*.m']);
set(handles.montage_list, 'String', {handles.montageList.name})

% Populate fields

if ~isempty(varargin)
    [handles, hObject] = dan_cmd_import(handles, hObject, varargin);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes data_viewer wait for user response (see UIRESUME)
% uiwait(handles.main_window);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DATA IMPORT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function load_data_Callback(hObject, eventdata, handles)
% hObject    handle to preprocess_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.data_import_panel_1, 'Visible', 'on')


% --- Executes on button press in find_data_path.
function find_data_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_data_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the data file
[dataName, dataDir, filtIdx] = uigetfile({'*.*'},...
    'Load data file');
if filtIdx == 0
    return
end

% Save data file path
set(handles.data_file_string, 'String', fullfile(dataDir, dataName));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in find_stage_path.
function find_stage_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_stage_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the score file
[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in find_events_path.
function find_events_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_events_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the eventsfile
[eventsName, eventsDir, filtIdx] = uigetfile({'*.*'},...
    'Load notations file');
if filtIdx == 0
    return
end

% Save events file path
set(handles.events_file_string, 'String', fullfile(eventsDir,eventsName));

% Update handles structure
guidata(hObject, handles);

function ar_file_string_Callback(hObject, eventdata, handles)
% hObject    handle to ar_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_file_string as text
%        str2double(get(hObject,'String')) returns contents of ar_file_string as a double


% --- Executes during object creation, after setting all properties.
function ar_file_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in find_ar_path.
function find_ar_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_ar_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the ar file
[arName, arDir, filtIdx] = uigetfile({'*.*'},...
    'Load rej file');
if filtIdx == 0
    return
end

% Save ar file path

set(handles.ar_file_string, 'String', fullfile(arDir,arName));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in collect_data_strings
function collect_data_strings_Callback(hObject, eventdata, handles)
% hObject    handle to collect_data_strings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clearData = 'Yes';
% Check for existing data

if ~isempty(handles.psg.data)
    [handles, clearData] = dan_clear_data(handles);
end

if strcmpi(clearData, 'yes')
    
    % Import PSG, scores, events, and ar
    handles = dan_import_data(handles);
    
    % Display recording start time, lights off, and lights on in import GUI 2
    
    set(handles.recording_start_time, 'String',...
        datestr(handles.psg.hdr.recStart, 'HH:MM:ss.FFF'));
    
    if ~isempty(handles.psg.events{:,1})
        isLOut = find(ismember(lower(handles.psg.events{:,4}), 'lights out') |...
            ismember(lower(handles.psg.events{:,4}), 'lights off'));
        isLOn = find(ismember(lower(handles.psg.events{:,4}), 'lights on'));
    else
        isLOut = [];
        isLOn  = [];
    end
    
    if ~isempty(isLOut)
        set(handles.lights_out_time, 'String',...
            char(handles.psg.events{isLOut,1}))
    end
    
    if ~isempty(isLOn)
        set(handles.lights_on_time, 'String',...
            char(handles.psg.events{isLOn,1}));
    end
    
    if isfield(handles, 'psg')
        set(handles.data_import_panel_2, 'Visible', 'on')
    end
    % Update handles structure
    guidata(hObject, handles);
    
end

% --- Executes on button press in cancel_load.
function cancel_load_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.data_import_panel_1, 'Visible', 'off')
set(handles.data_import_panel_2, 'Visible', 'off')

% --- Executes on button press in import_files.
function import_files_Callback(hObject, eventdata, handles)
% hObject    handle to import_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.data_import_panel_1, 'Visible', 'off')
set(handles.data_import_panel_2, 'Visible', 'off')

% Prepare some defaults
set(handles.current_epoch_number, 'String', '1'); % Make sure to start from epoch 1
handles.plotParam.epochIdx = 1;
handles.plotParam.startTime = 0; % Starting time
handles.plotParam.currSample = 1; % Tracks arbitary jumps

% Add manually entered times to the events table

if isempty(get(handles.events_file_string, 'String'))
    
    if ~strcmp(get(handles.lights_out_time, 'String'), "")
        eventsTable = {get(handles.lights_out_time, 'String') 'Lights off'};
        lOffTable = dan_get_event_latencies(eventsTable, handles.psg.hdr.recStart, handles.psg.hdr.srate);
        handles.psg.events = [handles.psg.events; lOffTable];
        handles.psg.events = sortrows(handles.psg.events, 2);
    end
    
    if ~strcmp(get(handles.lights_on_time, 'String'), "")
        eventsTable = {get(handles.lights_on_time, 'String') 'Lights on'};
        lOnTable = dan_get_event_latencies(eventsTable, handles.psg.hdr.recStart, handles.psg.hdr.srate);
        handles.psg.events = [handles.psg.events; lOnTable];
        handles.psg.events = sortrows(handles.psg.events, 2);
    end
    
end

% Create a list of epoch start and end samples
handles = dan_index_epochs(handles);

% Check scores and ar are aligned with the data
handles = dan_data_check(handles);

% Update epoch info at bottom of GUI
handles = dan_update_epoch_info_string(handles);

% Make spectrogram if asked for

if ~isempty(get(handles.spectogram_string, 'String'))
    % Try and find the channel
    
    chanIdx = find(strcmp({handles.psg.chans.labels}, get(handles.spectogram_string, 'String')));
    
    if ~isempty(chanIdx)
        
        % Get epoch indices
        epochIdx = indexepochs(30 * handles.psg.hdr.srate, handles.psg.hdr.samples);
        
        % Calculate PSD for each epoch using pwelch
        
        for epoch_i = 1:length(epochIdx)
            [psdEpoch(epoch_i,:), psdFreqs] = fun_spectral_power(handles.psg.data(chanIdx,epochIdx(epoch_i,1):1:epochIdx(epoch_i,2)),...
                handles.psg.hdr.srate); % Calculate PSD for each epoch
        end
        
        handles.psg.stages.spectogram.specto = psdEpoch;
        handles.psg.stages.spectogram.freqs  = psdFreqs;
        
    end
    
else
    handles.psg.stages.spectogram.specto = [];
    handles.psg.stages.spectogram.freqs  = [];
end

% Plot data to screen
[hObject, handles] = dan_plot_psg(hObject, handles);

% Plot hypnogram to screen
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update GUI title to dataset name
[~,dataName,dataExt] = fileparts(get(handles.data_file_string, 'String'));
set(handles.main_window, 'Name', [dataName dataExt]);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Scrolling data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in back_10_epochs.
function back_10_epochs_Callback(hObject, eventdata, handles)
% hObject    handle to back_10_epochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.plotParam.epochIdx > 10
    
    % Update epoch index
    handles.plotParam.epochIdx = handles.plotParam.epochIdx-10;
else
    handles.plotParam.epochIdx = 1;
end
handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;

% % Update scrollbar
% set(handles.Time_Slider,'Value',(handles.epoch_idx-1)*handles.epoch_duration);

% Replot data to the new epoch
[hObject, handles] = dan_plot_psg(hObject, handles);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update sleep stage

handles = dan_update_epoch_info_string(handles);

% Update handle structure
guidata(hObject,handles);

% --- Executes on button press in back_previous_epoch.
function back_previous_epoch_Callback(hObject, eventdata, handles)
% hObject    handle to back_previous_epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.plotParam.epochIdx > 1
    
    % Update epoch index
    handles.plotParam.epochIdx = handles.plotParam.epochIdx-1;
    handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;
    
    %     % Update scrollbar
    %      set(handles.Time_Slider,'Value',(handles.epoch_idx-1)*handles.epoch_duration);
    
    % Replot data to the new epoch
    [hObject, handles] = dan_plot_psg(hObject, handles);
    
    % Update hypnogram
    [hObject, handles] = dan_plot_hypno(hObject, handles);
    
    % Update sleep stage
    
    handles = dan_update_epoch_info_string(handles);
    
    % Update handle structure
    guidata(hObject,handles);
    
end

function current_epoch_number_Callback(hObject, eventdata, handles)
% hObject    handle to current_epoch_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if str2double(get(handles.current_epoch_number, 'String')) >= 1 &&...
        str2double(get(handles.current_epoch_number, 'String')) <= size(handles.plotParam.epochSample,1)
    
    % Update epoch index
    handles.plotParam.epochIdx = str2double(get(handles.current_epoch_number, 'String'));
    handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;
    
elseif str2double(get(handles.current_epoch_number, 'String')) < 1
    
    % Update epoch index
    handles.plotParam.epochIdx = 1;
    handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;
    
elseif str2double(get(handles.current_epoch_number, 'String')) > size(handles.plotParam.epochSample, 1)
    
    % Update epoch index
    handles.plotParam.epochIdx = size(handles.plotParam.epochSample,1);
    handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;
    
end

%     % Update scrollbar
%     if (handles.epoch_idx-1)*handles.epoch_duration > handles.Time_Slider.Max
%         set(handles.Time_Slider,'Value',handles.Time_Slider.Max);
%     else
%        set(handles.Time_Slider,'Value',(handles.epoch_idx-1)*handles.epoch_duration);
%     end

% Replot data to the new epoch
[hObject, handles] = dan_plot_psg(hObject, handles);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update sleep stage

handles = dan_update_epoch_info_string(handles);

% Update handle structure
guidata(hObject,handles);


% Hints: get(hObject,'String') returns contents of current_epoch_number as text
%        str2double(get(hObject,'String')) returns contents of current_epoch_number as a double


% --- Executes during object creation, after setting all properties.
function current_epoch_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_epoch_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in forward_next_epoch.
function forward_next_epoch_Callback(hObject, eventdata, handles)
% hObject    handle to forward_next_epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.plotParam.epochIdx < size(handles.plotParam.epochSample,1)
    
    % Update epoch index
    handles.plotParam.epochIdx = handles.plotParam.epochIdx+1;
    handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;
    
    %     % Update scrollbar
    %     if (handles.epoch_idx-1)*handles.epoch_duration > handles.Time_Slider.Max
    %         set(handles.Time_Slider,'Value',handles.Time_Slider.Max);
    %     else
    %        set(handles.Time_Slider,'Value',(handles.epoch_idx-1)*handles.epoch_duration);
    %     end
    
    % Plot montage
    
    %[hObject, handles] = plotelectrodes(hObject, handles);
    
    % Replot data to the new epoch
    [hObject, handles] = dan_plot_psg(hObject, handles);
    
    % Update hypnogram
    [hObject, handles] = dan_plot_hypno(hObject, handles);
    
    % Update sleep stage
    
    handles = dan_update_epoch_info_string(handles);
    
    % Update handle structure
    guidata(hObject,handles);
    
end

% --- Executes on button press in forward_10_epochs.
function forward_10_epochs_Callback(hObject, eventdata, handles)
% hObject    handle to forward_10_epochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.plotParam.epochIdx < size(handles.plotParam.epochSample,1) - 10
    
    % Update epoch index
    handles.plotParam.epochIdx = handles.plotParam.epochIdx+10;
else
    handles.plotParam.epochIdx = size(handles.plotParam.epochSample,1);
end
handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;

% % Update scrollbar
% if (handles.epoch_idx-1)*handles.epoch_duration > handles.Time_Slider.Max
%     set(handles.Time_Slider,'Value',handles.Time_Slider.Max);
% else
%     set(handles.Time_Slider,'Value',(handles.epoch_idx-1)*handles.epoch_duration);
% end

% Plot montage

%[hObject, handles] = plotelectrodes(hObject, handles);

% Replot data to the new epoch
[hObject, handles] = dan_plot_psg(hObject, handles);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update sleep stage

handles = dan_update_epoch_info_string(handles);

% Update handle structure
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Sleep staging%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in mark_wake.
function mark_wake_Callback(hObject, eventdata, handles)
% hObject    handle to mark_wake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stage epoch
handles = dan_stage_epoch(handles, 0);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

forward_next_epoch_Callback(hObject, eventdata, handles)


% --- Executes on button press in mark_N1.
function mark_N1_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stage epoch
handles = dan_stage_epoch(handles, 1);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

forward_next_epoch_Callback(hObject, eventdata, handles)


% --- Executes on button press in mark_N2.
function mark_N2_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stage epoch
handles = dan_stage_epoch(handles, 2);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

forward_next_epoch_Callback(hObject, eventdata, handles)

% --- Executes on button press in mark_N3.
function mark_N3_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stage epoch
handles = dan_stage_epoch(handles, 3);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

forward_next_epoch_Callback(hObject, eventdata, handles)

% --- Executes on button press in mark_N4.
function mark_N4_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stage epoch
handles = dan_stage_epoch(handles, 4);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

forward_next_epoch_Callback(hObject, eventdata, handles)

% --- Executes on button press in mark_REM.
function mark_REM_Callback(hObject, eventdata, handles)
% hObject    handle to mark_REM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stage epoch
handles = dan_stage_epoch(handles, 5);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

forward_next_epoch_Callback(hObject, eventdata, handles)

% --- Executes on button press in mark_movement.
function mark_movement_Callback(hObject, eventdata, handles)
% hObject    handle to mark_movement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stage epoch
handles = dan_stage_epoch(handles, 6);

% Update hypnogram
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

forward_next_epoch_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%Adjusting scale%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scale_value_Callback(hObject, eventdata, handles)
% hObject    handle to scale_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handle structure
guidata(hObject,handles);


% Hints: get(hObject,'String') returns contents of scale_value as text
%        str2double(get(hObject,'String')) returns contents of scale_value as a double


% --- Executes during object creation, after setting all properties.
function scale_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in reduce_scale.
function decrease_scale_Callback(hObject, eventdata, handles)
% hObject    handle to reduce_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentScale = str2double(get(handles.scale_value, 'String'));
newScale = currentScale - 25;

if newScale < 25
    newScale = 25;
end

set(handles.scale_value, 'String', newScale);


[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handle structure
guidata(hObject,handles);

% --- Executes on button press in increase_scale.
function increase_scale_Callback(hObject, eventdata, handles)
% hObject    handle to increase_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentScale = str2double(get(handles.scale_value, 'String'));
newScale = currentScale + 25;

set(handles.scale_value, 'String', newScale);


[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handle structure
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%Marking artifacts%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in mark_artifact.
function mark_artifact_Callback(hObject, eventdata, handles)
% hObject    handle to mark_artifact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Mark epoch
handles = dan_mark_epoch(handles);

[hObject, handles] = dan_plot_psg(hObject, handles);
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%Montages %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in montage_refresh.
function montage_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to montage_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find monatages
toolboxPath = fileparts(which('sleepDanalyzer'));

handles.montageList = dir([fullfile(toolboxPath, 'montages') filesep '*.m']);

if ~isempty(handles.montageList)
    set(handles.montage_list, 'String', {handles.montageList.name})
end

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function montage_edit_Callback(hObject, eventdata, handles)
% hObject    handle to montage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update montage
handles = dan_edit_montage(handles);

% Plot segment
[hObject, handles] = dan_plot_psg(hObject, handles);
[hObject, handles] = dan_plot_hypno(hObject, handles);


% Update handle structure
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%Button press commands %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on key press with focus on figure1 or any of its controls.
function main_window_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on key press with focus on figure1 or any of its controls.
function main_window_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on key press with focus on figure1 or any of its controls.
function main_window_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on key press with focus on figure1 or any of its controls.
function main_window_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Key, 'rightarrow')
    forward_next_epoch_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Key, 'leftarrow')
    back_previous_epoch_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Key, '9')
    forward_next_epoch_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Key, '7')
    back_previous_epoch_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Key, 'rightarrow') && ~isempty(eventdata.Modifier)
    forward_10_epochs_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Key, 'leftarrow') && ~isempty(eventdata.Modifier)
    back_10_epochs_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '1')
    mark_N1_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '2')
    mark_N2_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '3')
    mark_N3_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '4')
    mark_N4_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '5')
    mark_REM_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '0')
    mark_wake_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '6')
    mark_movement_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, 'a')
    mark_artifact_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '.')
    epochIdx = str2double(get(handles.current_epoch_number, 'String'));
    handles.psg.stages.s1.stages(epochIdx) = 7;
    set(handles.current_epoch_info, 'String', 'Unstaged');
    [hObject, handles] = dan_plot_hypno(hObject, handles);
    handles = dan_update_epoch_info_string(handles);
    guidata(hObject, handles);
elseif strcmp(eventdata.Character, '=')
    increase_scale_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, '-')
    decrease_scale_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, 'n')
    if strcmp(get(handles.notes_panel, 'Visible'), 'on')
        set(handles.notes_panel, 'Visible', 'off')
    elseif strcmp(get(handles.notes_panel, 'Visible'), 'off')
        set(handles.notes_panel, 'Visible', 'on')
    end
elseif strcmp(eventdata.Character, 'g')
    [hObject, handles] = dan_move_to_event(hObject, handles);
    % Update handle structure
    guidata(hObject,handles);
elseif strcmp(eventdata.Character, 'c')
    handles = dan_adjust_channel(handles);
    [hObject, handles] = dan_plot_psg(hObject, handles);
    % Update handle structure
    guidata(hObject,handles);
elseif strcmp(eventdata.Character, 'm')
    montage_edit_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, 'h')
    hyp_spec_select_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Character, 'i')
    handles.segColor = 1;
    [hObject, handles] = dan_plot_psg(hObject, handles);
    % Update handle structure
    guidata(hObject, handles);
elseif strcmp(eventdata.Character, 'o')
    handles.segColor = 2;
    [hObject, handles] = dan_plot_psg(hObject, handles);
    % Update handle structure
    guidata(hObject, handles);
elseif strcmp(eventdata.Character, 'p')
    handles.segColor = 3;
    [hObject, handles] = dan_plot_psg(hObject, handles);
    % Update handle structure
    guidata(hObject, handles);
elseif strcmpi(eventdata.Character, 's')
    
    nScoreFiles = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
    nScoreFiles(cellfun(@isempty, nScoreFiles)) = [];
    
    msg = [];
    
    for i = 1:length(nScoreFiles)
        
        if handles.psg.stages.(nScoreFiles{i}{1}).stages(handles.plotParam.epochIdx) > 0 && handles.psg.stages.(nScoreFiles{i}{1}).stages(handles.plotParam.epochIdx) < 4
            s = num2str(handles.psg.stages.(nScoreFiles{i}{1}).stages(handles.plotParam.epochIdx));
        elseif handles.psg.stages.(nScoreFiles{i}{1}).stages(handles.plotParam.epochIdx) == 0
            s = 'Wake';
        elseif handles.psg.stages.(nScoreFiles{i}{1}).stages(handles.plotParam.epochIdx) == 5
            s = 'REM';
        elseif handles.psg.stages.(nScoreFiles{i}{1}).stages(handles.plotParam.epochIdx) == 6
            s = 'Movement';
        elseif handles.psg.stages.(nScoreFiles{i}{1}).stages(handles.plotParam.epochIdx) == 7
            s = 'Unstaged';
        end
        
        msg{i} = sprintf(['Scorer ' num2str(i) ': ' handles.psg.stages.(nScoreFiles{i}{1}).hdr.scorer ' - stage ' s]);
        
    end
    
    msgbox(msg);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Saving Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function save_data_Callback(hObject, eventdata, handles)
% hObject    handle to save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.data_save_panel, 'Visible', 'on')


% --- Executes on button press in cancel_save.
function cancel_save_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.data_save_panel, 'Visible', 'off')


% --- Executes on button press in find_data_save_path.
function find_data_save_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_data_save_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[dataSaveName, dataSaveDir, filtIdx] = uiputfile({'*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

set(handles.data_save_string, 'String', fullfile(dataSaveDir, dataSaveName));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in find_score_save_path.
function find_score_save_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_score_save_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[scoreSaveName, scoreSaveDir, filtIdx] = uiputfile({'*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

set(handles.score_save_string, 'String', fullfile(scoreSaveDir, scoreSaveName));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in find_notations_save_path.
function find_notations_save_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_notations_save_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[notationsSaveName, notationsSaveDir, filtIdx] = uiputfile({'*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

set(handles.notations_save_string, 'String', fullfile(notationsSaveDir, notationsSaveName));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in find_rej_save_path.
function find_rej_save_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_rej_save_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[rejSaveName, rejSaveDir, filtIdx] = uiputfile({'*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

set(handles.rej_save_string, 'String', fullfile(rejSaveDir, rejSaveName));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in find_spec_save_path.
function find_spec_save_path_Callback(hObject, eventdata, handles)
% hObject    handle to find_spec_save_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[specSaveName, specSaveDir, filtIdx] = uiputfile({'*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

set(handles.save_spec_string, 'String', fullfile(specSaveDir, specSaveName));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in save_files.
function save_files_Callback(hObject, eventdata, handles)
% hObject    handle to save_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(handles.data_save_string, 'String'))
    
    [dataSavePath,dataSaveName,dataSaveExt] = fileparts(get(handles.data_save_string, 'String'));
    
    % Save the psg struct to file
    if strcmp(dataSaveExt, '.mat')
        disp('Saving PSG data to file...')
        psg = handles.psg;
        save(fullfile(dataSavePath, [dataSaveName dataSaveExt]),...
            'psg');
        clear psg;
        disp('done')
    end
    
end

if ~isempty(get(handles.score_save_string, 'String'))
    
    [~,~,scoreSaveExt] = fileparts(get(handles.score_save_string, 'String'));
    
    if strcmp(scoreSaveExt, '.mat')
        disp('Saving sleep stage data to file...')
        
        sleepstages = handles.psg.stages.s1;
        
        save(get(handles.score_save_string, 'String'), 'sleepstages');
        clear sleepstages
        disp('done')
    end
    
end

if ~isempty(get(handles.notations_save_string, 'String'))
    
    [notationsSavePath,notationsSaveFile,notationsSaveExt] = fileparts(get(handles.notations_save_string, 'String'));
    
    disp('Saving events to file...')
    events = handles.psg.events;
    
    if strcmp(notationsSaveExt, '.mat')
        save(get(handles.notations_save_string, 'String'), 'events');
    elseif strcmp(notationsSaveExt, '.xlsx')
        writetable(events, get(handles.notations_save_string, 'String'));
    end
    
    clear events
    disp('done')
    
end

if ~isempty(get(handles.rej_save_string, 'String'))
    
    [~,~,rejSaveExt] = fileparts(get(handles.rej_save_string, 'String'));
    
    if strcmp(rejSaveExt, '.mat')
        disp('Saving AR info to file...')
        ar = handles.psg.ar;
        save(get(handles.rej_save_string, 'String'), 'ar');
        disp('done')
    end
    
end

if ~isempty(get(handles.save_spec_string, 'String'))
    disp('Saving detections to file...')
    detections = handles.detections.d1;
    save(get(handles.save_spec_string, 'String'), 'detections');
    disp('done')
end

set(handles.data_save_panel, 'Visible', 'off')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Comparing sleep scores %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function sleepstats_compare_scorers_Callback(hObject, eventdata, handles)
% hObject    handle to sleepstats_compare_scorers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
scoreFields(cellfun(@isempty, scoreFields)) = [];

if length(scoreFields) == 1
    errordlg('Please load a second score file (File --> Import --> Sleep scores)')
else
    [saveFile, savePath] = uiputfile({'*.html'});
    
    if ~isequal(saveFile,0) || ~isequal(savePath,0)
        
        for i = 1:length(scoreFields)
            scoreFiles(i).stages = handles.psg.stages.(scoreFields{i}{1}).stages;
            scoreFiles(i).hdr = handles.psg.stages.(scoreFields{i}{1}).hdr;
        end
        
        fun_scorer_reliability(scoreFiles, 'Report', {savePath, strtok(saveFile, '.')});
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Sleep statistics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function sleepstats_current_file_Callback(hObject, eventdata, handles)
% hObject    handle to sleepstats_current_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sleepStatistics(handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function preprocess_data_Callback(hObject, eventdata, handles)
% hObject    handle to preprocess_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

preprocessGUI

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Artifact rejection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function channel_interp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
interpList = zeros(length(handles.psg.ar.badchans), 1);

if ~isempty(handles.montage.chanList(1).X)
    
    dlgList = listdlg('ListString', flip(get(handles.data_axes, 'YTickLabel')),...
        'SelectionMode', 'multiple', 'InitialValue', find(handles.psg.ar.badchans));
    axesList = get(handles.data_axes, 'YTickLabel');
    
    interpList(dlgList) = 1;
    
    % EEG chans
    eegChans = ismember({handles.montage.chanList.type}, 'EEG');
    
    % Interpolate
    interp = fun_interpolate_data(handles.psg.data(eegChans,:), handles.psg.chans(eegChans), interpList(eegChans));
        
    % Put interpolated data back into the original data
    
    handles.psg.data(eegChans,:) = interp;
    
    clear interp
    
    % reset bad channels
    handles.psg.ar.badchans = zeros(length(handles.psg.ar.badchans), 1);
    
    % Plot segment
    [hObject, handles] = dan_plot_psg(hObject, handles);
    [hObject, handles] = dan_plot_hypno(hObject, handles);
    
    
    % Update handle structure
    guidata(hObject,handles);
    
elseif isempty(handles.montage.chanList(1).X)
    
    errordlg('No channel locations')
    
end

% --------------------------------------------------------------------
function ar_compare_scorers_Callback(hObject, eventdata, handles)
% hObject    handle to ar_compare_scorers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Exiting sleepanalyzer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function close_se_Callback(hObject, eventdata, handles)
% hObject    handle to close_se (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main_window_CloseRequestFcn

% --- Executes when user attempts to close main_window.
function main_window_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to main_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

closeAnswer = questdlg({'Are you sure you want to quit?', 'Anything not saved will be lost.'}, 'Quit', 'No', 'Yes', 'No');

if strcmp(closeAnswer, 'Yes')
    
    mainHandle = findobj('Type', 'Figure', 'Tag', 'main_window');
    delete(mainHandle)
end

function score_save_string_Callback(hObject, eventdata, handles)
% hObject    handle to score_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of score_save_string as text
%        str2double(get(hObject,'String')) returns contents of score_save_string as a double


% --- Executes during object creation, after setting all properties.
function score_save_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to score_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function notations_save_string_Callback(hObject, eventdata, handles)
% hObject    handle to notations_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notations_save_string as text
%        str2double(get(hObject,'String')) returns contents of notations_save_string as a double


% --- Executes during object creation, after setting all properties.
function notations_save_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notations_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function data_save_string_Callback(hObject, eventdata, handles)
% hObject    handle to data_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_save_string as text
%        str2double(get(hObject,'String')) returns contents of data_save_string as a double


% --- Executes during object creation, after setting all properties.
function data_save_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rej_save_string_Callback(hObject, eventdata, handles)
% hObject    handle to rej_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rej_save_string as text
%        str2double(get(hObject,'String')) returns contents of rej_save_string as a double


% --- Executes during object creation, after setting all properties.
function rej_save_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rej_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function save_spec_string_Callback(hObject, eventdata, handles)
% hObject    handle to save_spec_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_spec_string as text
%        str2double(get(hObject,'String')) returns contents of save_spec_string as a double


% --- Executes during object creation, after setting all properties.
function save_spec_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_spec_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function recording_start_time_Callback(hObject, eventdata, handles)
% hObject    handle to recording_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recording_start_time as text
%        str2double(get(hObject,'String')) returns contents of recording_start_time as a double


% --- Executes during object creation, after setting all properties.
function recording_start_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recording_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lights_out_time_Callback(hObject, eventdata, handles)
% hObject    handle to lights_out_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lights_out_time as text
%        str2double(get(hObject,'String')) returns contents of lights_out_time as a double


% --- Executes during object creation, after setting all properties.
function lights_out_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lights_out_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lights_on_time_Callback(hObject, eventdata, handles)
% hObject    handle to lights_on_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lights_on_time as text
%        str2double(get(hObject,'String')) returns contents of lights_on_time as a double


% --- Executes during object creation, after setting all properties.
function lights_on_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lights_on_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function epoch_length_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epoch_length as text
%        str2double(get(hObject,'String')) returns contents of epoch_length as a double


% --- Executes during object creation, after setting all properties.
function epoch_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stage_file_string_Callback(hObject, eventdata, handles)
% hObject    handle to stage_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stage_file_string as text
%        str2double(get(hObject,'String')) returns contents of stage_file_string as a double


% --- Executes during object creation, after setting all properties.
function stage_file_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stage_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function events_file_string_Callback(hObject, eventdata, handles)
% hObject    handle to events_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of events_file_string as text
%        str2double(get(hObject,'String')) returns contents of events_file_string as a double


% --- Executes during object creation, after setting all properties.
function events_file_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to events_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function data_file_string_Callback(hObject, eventdata, handles)
% hObject    handle to data_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_file_string as text
%        str2double(get(hObject,'String')) returns contents of data_file_string as a double


% --- Executes during object creation, after setting all properties.
function data_file_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Outputs from this function are returned to the command line.
function varargout = data_viewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in mark_segment.
function mark_segment_Callback(hObject, eventdata, handles)
% hObject    handle to mark_segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

funcIdx = listdlg('ListString', {'Epoch segment', 'Channel segment', 'Channel info'},...
    'InitialValue', handles.segmentFunction);

handles.segmentFunction = funcIdx;

[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handle structure
guidata(hObject,handles);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hot_key_text_Callback(hObject, eventdata, handles)
% hObject    handle to hot_key_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hotKeyMsg = sprintf(['Keyboard shortcuts can be used for data scrolling, sleep scoring and marking artifacts.\n\n',...
    'Short cuts:\n\n', ...
    'right arrow - Next epoch\n',...
    'left arrow - Previous epoch\n',...
    '+ - Increase scale\n',...
    '- - Decrease scale\n\n',...
    '0 - Wake\n',...
    '1 - Stage 1\n',...
    '2 - Stage 2\n',...
    '3 - Stage 3\n',...
    '4 - Stage 4\n',...
    '5 - Stage REM\n',...
    '6 - Movement\n',...
    '. - Unstaged\n\n',...
    'a - Artifact\n',...
    'c - Channel property editor\n',...
    'g - Navigate to specific notation\n',...
    'm - Edit montage\n',...
    'n - Show/hide notes box\n',...
    'i/o/p - Change segment marker color\n'...
    'h - Switch between hypnogram and spectogram\n',...
    's - View sleep stage for each scorer\n\n',...
    'left click - Add notation\n',...
    'right click - Toggle channel(s) on/off\n',...
    'shift + left click - Mark segment\n\n',...
    'CTRL + o - Import/Open data\n',...
    'CTRL + s - Save data\n',...
    'CTRL + e - Exit']);
msgbox(hotKeyMsg, 'Hot Keys');


% --------------------------------------------------------------------
function se_about_Callback(hObject, eventdata, handles)
% hObject    handle to se_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function spec_analyze_file_Callback(hObject, eventdata, handles)
% hObject    handle to spec_analyze_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function spec_batch_Callback(hObject, eventdata, handles)
% hObject    handle to spec_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function spec_view_detections_Callback(hObject, eventdata, handles)
% hObject    handle to spec_view_detections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName, filePath] = uigetfile({'*.mat'});
specData = load([filePath fileName]);
specVarName = fieldnames(specData);
handles.specData = specData.(specVarName{1});

% Update handle structure
guidata(hObject,handles);

[hObject, handles] = dan_plot_psg(hObject, handles);

% --------------------------------------------------------------------
function montage_create_Callback(hObject, eventdata, handles)
% hObject    handle to montage_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

se_montageeditGUI


% --- Executes on selection change in montage_list.
function montage_list_Callback(hObject, eventdata, handles)
% hObject    handle to montage_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


montageNumFromList = get(handles.montage_list, 'Value');

[~,montageFunctionName,~] = fileparts(handles.montageList(montageNumFromList).name);

eval(montageFunctionName);

if ~isempty(montage.chanList)
    handles.psg.chans = montage.chanList;
    handles.montage.chanList = handles.psg.chans;
end

handles.montage.hideChans = montage.hideChans;

if ~isempty(montage.showChans)
    handles.montage.showChans = montage.showChans;
else
    handles.montage.showChans = {handles.psg.chans.labels}';
end
handles.montage.reref     = montage.reref;
handles.montage.filters   = montage.filters;
handles.montage.notch     = montage.notch;
handles.montage.colors    = montage.colors;
handles.montage.scaleLine = montage.scaleLine;
handles.montage.scaleLineColor = montage.scaleLineColor;
handles.montage.scaleLineType = montage.scaleLineType;
handles.montage.scaleLinePos = montage.scaleLinePos;

[hObject, handles] = dan_plot_psg(hObject, handles);
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns montage_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from montage_list

% --- Executes during object creation, after setting all properties.
function montage_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to montage_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function notes_Callback(hObject, eventdata, handles)
% hObject    handle to notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes as text
%        str2double(get(hObject,'String')) returns contents of notes as a double


% --- Executes during object creation, after setting all properties.
function notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in channel_notch_filter.
function channel_notch_filter_Callback(hObject, eventdata, handles)
% hObject    handle to channel_notch_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channel_notch_filter


% --- Executes on button press in channel_apply_filter.
function channel_apply_filter_Callback(hObject, eventdata, handles)
% hObject    handle to channel_apply_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in channel_ECG_color.
function channel_ECG_color_Callback(hObject, eventdata, handles)
% hObject    handle to channel_ECG_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function channel_ecg_hp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_ecg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_ecg_hp as text
%        str2double(get(hObject,'String')) returns contents of channel_ecg_hp as a double


% --- Executes during object creation, after setting all properties.
function channel_ecg_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_ecg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function channel_ecg_lp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_ecg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_ecg_lp as text
%        str2double(get(hObject,'String')) returns contents of channel_ecg_lp as a double


% --- Executes during object creation, after setting all properties.
function channel_ecg_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_ecg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in channel_eog_color.
function channel_eog_color_Callback(hObject, eventdata, handles)
% hObject    handle to channel_eog_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function channel_eog_hp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_eog_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_eog_hp as text
%        str2double(get(hObject,'String')) returns contents of channel_eog_hp as a double


% --- Executes during object creation, after setting all properties.
function channel_eog_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_eog_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function channel_eog_lp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_eog_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_eog_lp as text
%        str2double(get(hObject,'String')) returns contents of channel_eog_lp as a double


% --- Executes during object creation, after setting all properties.
function channel_eog_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_eog_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in channel_emg_color.
function channel_emg_color_Callback(hObject, eventdata, handles)
% hObject    handle to channel_emg_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function channel_emg_hp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_emg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_emg_hp as text
%        str2double(get(hObject,'String')) returns contents of channel_emg_hp as a double


% --- Executes during object creation, after setting all properties.
function channel_emg_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_emg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function channel_emg_lp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_emg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_emg_lp as text
%        str2double(get(hObject,'String')) returns contents of channel_emg_lp as a double


% --- Executes during object creation, after setting all properties.
function channel_emg_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_emg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in channel_eeg_color.
function channel_eeg_color_Callback(hObject, eventdata, handles)
% hObject    handle to channel_eeg_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function channel_eeg_hp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_eeg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_eeg_hp as text
%        str2double(get(hObject,'String')) returns contents of channel_eeg_hp as a double


% --- Executes during object creation, after setting all properties.
function channel_eeg_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_eeg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function channel_eeg_lp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_eeg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_eeg_lp as text
%        str2double(get(hObject,'String')) returns contents of channel_eeg_lp as a double


% --- Executes during object creation, after setting all properties.
function channel_eeg_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_eeg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function channel_other_hp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_other_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_other_hp as text
%        str2double(get(hObject,'String')) returns contents of channel_other_hp as a double


% --- Executes during object creation, after setting all properties.
function channel_other_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_other_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function channel_other_lp_Callback(hObject, eventdata, handles)
% hObject    handle to channel_other_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_other_lp as text
%        str2double(get(hObject,'String')) returns contents of channel_other_lp as a double


% --- Executes during object creation, after setting all properties.
function channel_other_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_other_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton78.
function pushbutton78_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton78 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton79.
function pushbutton79_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton79 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton80.
function pushbutton80_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton81.
function pushbutton81_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton82.
function pushbutton82_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton83.
function pushbutton83_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton84.
function pushbutton84_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton84 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton85.
function pushbutton85_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton85 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton86.
function pushbutton86_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton86 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton87.
function pushbutton87_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton87 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton88.
function pushbutton88_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton88 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit47_Callback(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit47 as text
%        str2double(get(hObject,'String')) returns contents of edit47 as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton89.
function pushbutton89_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton89 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton90.
function pushbutton90_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton91.
function pushbutton91_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton91 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton92.
function pushbutton92_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton92 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in mark_wake.
function markWake_Callback(hObject, eventdata, handles)
% hObject    handle to mark_wake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mark_N1.
function pushbutton111_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mark_N2.
function pushbutton112_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mark_N3.
function pushbutton113_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mark_N4.
function pushbutton114_Callback(hObject, eventdata, handles)
% hObject    handle to mark_N4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mark_REM.
function pushbutton115_Callback(hObject, eventdata, handles)
% hObject    handle to mark_REM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mark_movement.
function pushbutton116_Callback(hObject, eventdata, handles)
% hObject    handle to mark_movement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in montage_list.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to montage_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns montage_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from montage_list


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to montage_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function notes_string_Callback(hObject, eventdata, handles)
% hObject    handle to notes_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes_string as text
%        str2double(get(hObject,'String')) returns contents of notes_string as a double


% --- Executes during object creation, after setting all properties.
function notes_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function spec_analyze_outside_file_Callback(hObject, eventdata, handles)
% hObject    handle to spec_analyze_outside_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function run_ica_Callback(hObject, eventdata, handles)
% hObject    handle to run_ica (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function export_data_Callback(hObject, eventdata, handles)
% hObject    handle to export_data_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[saveFile, savePath] = uiputfile({'*.xlsx'; '*.csv'});

writetable(table(handles.sleepstages), [savePath saveFile], 'WriteVariableNames', 0);
disp('Sleep scores exported')

% --------------------------------------------------------------------
function export_data_menu_Callback(hObject, eventdata, handles)
% hObject    handle to export_data_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function clear_data_Callback(hObject, eventdata, handles)
% hObject    handle to clear_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

loadData = 'Yes';

if ~isempty(handles.EEG.data)
    
    loadData = questdlg({'Clearing existing data. All unsaved progress will be lost', 'Do you want to continue?'},'Clear','Yes', 'No', 'Yes');
    
end

if strcmp(loadData, 'Yes')
    
    % Inititialze structs
    % Data
    handles.EEG = eeg_emptyset();
    
    % Sleep stages
    handles.sleepstages = [];
    
    % Sleep statistics
    handles.sleepstats = [];
    handles.sleepstats.lightsout = [];
    handles.sleepstats.lightson = [];
    handles.sleepstats.recordingstart = [];
    handles.sleepstats.table = [];
    
    % Notations
    handles.notations.times = [];
    handles.notations.labels = {};
    handles.notationsList = {};
    
    % Rejection info
    handles.rejinfo.badchans = [];
    handles.rejinfo.badepochs = [];
    handles.rejinfo.badsegments = [];
    
    % Spectral data
    handles.specdata.psddata = [];
    handles.specdata.spindledata = [];
    handles.specdata.sodata = [];
    
    % Montages
    handles.currentMontageSettings = [];
    handles.refList = {};
    handles.filtList = [];
    
    % Update handle structure
    guidata(hObject,handles);
    
    % Plot segment
    
    [hObject, handles] = plotsegment(hObject, handles);
    
    % Update handle structure
    guidata(hObject,handles);
    
end

% --------------------------------------------------------------------
function chan_properties_Callback(hObject, eventdata, handles)
% hObject    handle to chan_properties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = dan_adjust_channel(handles);
[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handle structure
guidata(hObject,handles);


% --------------------------------------------------------------------
function detect_segment_Callback(hObject, eventdata, handles)
% hObject    handle to detect_segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segment_ar_gui(handles);
uiwait(gcf)

autoAR = getappdata(findobj('Tag', 'main_window'), 'auto_ar_seg');

if ~isempty(autoAR)
    handles.psg.ar.badepochs   = autoAR.badepochs;
    %handles.psg.ar.badsegments = autoAR.badsegments;
end

% Plot data to screen
[hObject, handles] = dan_plot_psg(hObject, handles);

% Plot hypnogram to screen
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

% --- Executes on slider movement.
function scroll_data_slider_Callback(hObject, eventdata, handles)
% hObject    handle to scroll_data_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function scroll_data_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scroll_data_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in hyp_spec_select.
function hyp_spec_select_Callback(hObject, eventdata, handles)
% hObject    handle to hyp_spec_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.hypSpec == 1
    handles.hypSpec = 2;
elseif handles.hypSpec == 2
    handles.hypSpec = 1;
end

% Plot hypnogram to screen
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of hyp_spec_select

% --------------------------------------------------------------------
function data_menu_Callback(hObject, eventdata, handles)
% hObject    handle to data_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function subset_data_Callback(hObject, eventdata, handles)
% hObject    handle to subset_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

subsetOpts = inputdlg({'Stages:' 'Remove bad epochs:' 'Channels to remove' 'Interpolate bad channels:'},...
    'Subset data');

handles = dan_select_data(handles, subsetOpts);

% Plot data to screen
[hObject, handles] = dan_plot_psg(hObject, handles);

% Plot hypnogram to screen
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update GUI title to dataset name
[~,dataName,dataExt] = fileparts(get(handles.data_file_string, 'String'));
set(handles.main_window, 'Name', [dataName dataExt]);

% Update handle structure
guidata(hObject,handles);

% --------------------------------------------------------------------
function restore_full_data_Callback(hObject, eventdata, handles)
% hObject    handle to restore_full_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.specData = [];
handles.psg = handles.og.psg;
handles.plotParam = handles.og.plotParam;
handles.montage = dan_empty_montage(handles.psg);

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

% Update handle structure
guidata(hObject,handles);

handles.og = [];

% --------------------------------------------------------------------
function clear_montage_Callback(hObject, eventdata, handles)
% hObject    handle to clear_montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.montage.chanList = handles.psg.chans;
handles.montage.hideChans = [];
handles.montage.showChans = {handles.psg.chans.labels}';
handles.montage.reref = cell(length(handles.psg.chans), 1);
handles.montage.filters = zeros(length(handles.psg.chans), 2);
handles.montage.notch = zeros(length(handles.psg.chans), 1);
handles.montage.colors = zeros(5, 3);
handles.montage.scaleLine = [];
handles.montage.scaleLineColor = [];
handles.montage.scaleLinePos = [];
handles.montage.scaleLineType = [];

[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handle structure
guidata(hObject,handles);
% --------------------------------------------------------------------
function import_data_menu_Callback(hObject, eventdata, handles)
% hObject    handle to import_data_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_psg_Callback(hObject, eventdata, handles)
% hObject    handle to export_psg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_events_Callback(hObject, eventdata, handles)
% hObject    handle to export_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_ar_Callback(hObject, eventdata, handles)
% hObject    handle to export_ar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_spec_Callback(hObject, eventdata, handles)
% hObject    handle to export_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function import_scores_direct_Callback(hObject, eventdata, handles)
% hObject    handle to import_scores_direct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function import_events_direct_Callback(hObject, eventdata, handles)
% hObject    handle to import_events_direct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the eventsfile
[eventsName, eventsDir, filtIdx] = uigetfile({'*.*'},...
    'Load notations file');
if filtIdx == 0
    return
end

set(handles.events_file_string, 'String', fullfile(eventsDir,eventsName));

if ~isempty(get(handles.events_file_string, 'String'))
    [~, ~, eventsExt] = fileparts(get(handles.events_file_string, 'String'));
    
    if strcmpi(eventsExt, '.xlsx') || strcmpi(eventsExt, '.xls') || strcmpi(eventsExt, 'csv')
        
        % Get just the time strings and event names
        eventsTable = dan_convert_csv_events(get(handles.events_file_string, 'String'));
        
        % Convert these times into samples
        psg.events = dan_get_event_latencies(eventsTable, handles.psg.hdr.recStart, handles.psg.hdr.srate);
        
    elseif strcmpi(eventsExt, '.vmrk')
        [eventsTable, recStart] = dan_convert_vmrk_events(get(handles.events_file_string, 'String'), handles.psg.hdr.srate);
        psg.events = eventsTable;
        psg.hdr.recStart = recStart;
        
    elseif strcmpi(eventsExt, '.mat')
        load(get(handles.events_file_string, 'String'), 'events');
        psg.events = events;
    end
else
    psg.events = cell2table(cell(1, 4));
    psg.events.Properties.VariableNames = {'Clock_Time', 'Seconds', 'Samples', 'Event'};
end

handles.psg.events = psg.events;

[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function import_AR_Callback(hObject, eventdata, handles)
% hObject    handle to import_AR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the ar file
[arName, arDir, filtIdx] = uigetfile({'*.*'},...
    'Load rej file');
if filtIdx == 0
    return
end

% Save ar file path

set(handles.ar_file_string, 'String', fullfile(arDir,arName));

if ~isempty(get(handles.ar_file_string, 'String'))
    ar = load(get(handles.ar_file_string, 'String'));
    
    if isfield(ar, 'rejinfo')
        psg.ar.badchans    = ar.rejinfo.badchans;
        psg.ar.badepochs   = ar.rejinfo.badepochs;
        if isfield(ar.rejinfo, 'badsegments')
            psg.ar.badsegments = ar.rejinfo.badsegments;
        else
            psg.ar.badsegments = [];
        end
    elseif isfield(ar, 'ar')
        psg.ar.badchans    = ar.ar.badchans;
        psg.ar.badepochs   = ar.ar.badepochs;
        if isfield(ar.ar, 'badsegments')
            psg.ar.badsegments = ar.ar.badsegments;
        else
            psg.ar.badsegments = [];
        end
    end
    
else
    psg.ar.badchans    = [];
    psg.ar.badepochs   = [];
    psg.ar.badsegments = [];
    
end

handles.psg.ar = psg.ar;

handles = dan_data_check(handles);

[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function import_spec_Callback(hObject, eventdata, handles)
% hObject    handle to import_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the ar file
[specName, specDir, filtIdx] = uigetfile({'*.*'},...
    'Load rej file');
if filtIdx == 0
    return
end

d = load(fullfile(specDir, specName));
structField = fieldnames(d);
detections = d.(structField{1});

detectFields = regexp(fieldnames(handles.detections), 'd\d', 'match');
handles.detections.(['d' num2str(length(detectFields) + 1)]) = detections;

[hObject, handles] = dan_plot_psg(hObject, handles);
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

function spectogram_string_Callback(hObject, eventdata, handles)
% hObject    handle to spectogram_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spectogram_string as text
%        str2double(get(hObject,'String')) returns contents of spectogram_string as a double


% --- Executes during object creation, after setting all properties.
function spectogram_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectogram_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function add_chanlocs_Callback(hObject, eventdata, handles)
% hObject    handle to add_chanlocs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the ar file
[chanName, chanDir, filtIdx] = uigetfile({'*.*'},...
    'Load channel location file');
if filtIdx == 0
    return
end

[~,~,fileExt] = fileparts(fullfile(chanDir, chanName));

if strcmpi(fileExt, '.mat')
    load(fullfile(chanDir, chanName));
elseif strcmpi(fileExt, '.txt')
    chans = readlocs(fullfile(chanDir, chanName), 'filetype', 'custom',...
        'format', {'labels' 'X' 'Y' 'Z' 'type'});
end

%handles.psg.chans        = chans;
handles.montage.chanList = chans;
handles.montage.showChans = {chans.labels};

[hObject, handles] = dan_plot_psg(hObject, handles);
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);



% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = dan_clear_data(handles);

% Update handle structure
guidata(hObject,handles);


% --------------------------------------------------------------------
function make_spectogram_Callback(hObject, eventdata, handles)
% hObject    handle to make_spectogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

chanIdx = listdlg('ListString', flip(get(handles.data_axes, 'YTickLabel')),...
    'SelectionMode', 'single', 'InitialValue', 1);

if ~isempty(chanIdx)
    
    % Get epoch indices
    epochIdx = indexepochs(30 * handles.psg.hdr.srate, handles.psg.hdr.samples);
    
    % Calculate PSD for each epoch using pwelch
    
    for epoch_i = 1:length(epochIdx)
        [psdEpoch(epoch_i,:), psdFreqs] = fun_spectral_power(handles.psg.data(chanIdx,epochIdx(epoch_i,1):1:epochIdx(epoch_i,2)),...
            handles.psg.hdr.srate); % Calculate PSD for each epoch
    end
    
    handles.psg.stages.spectogram.specto = psdEpoch;
    handles.psg.stages.spectogram.freqs  = psdFreqs;
    
    handles.hypSpec = 2;
    
    [hObject, handles] = dan_plot_psg(hObject, handles);
    [hObject, handles] = dan_plot_hypno(hObject, handles);
    
    % Update handle structure
    guidata(hObject,handles);
    
    
end

% --------------------------------------------------------------------
function detect_channel_Callback(hObject, eventdata, handles)
% hObject    handle to detect_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channel_ar_gui(handles);
uiwait(gcf)

autoAR = getappdata(findobj('Tag', 'main_window'), 'auto_ar_chan');

if ~isempty(autoAR)
    handles.psg.ar.badchans = autoAR;
end

% Plot data to screen
[hObject, handles] = dan_plot_psg(hObject, handles);

% Plot hypnogram to screen
[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handle structure
guidata(hObject,handles);

% --------------------------------------------------------------------
function spec_browser_Callback(hObject, eventdata, handles)
% hObject    handle to spec_browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

errordlg('Feature not implemented.')

function scorer_string_Callback(hObject, eventdata, handles)
% hObject    handle to scorer_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scorer_string as text
%        str2double(get(hObject,'String')) returns contents of scorer_string as a double


% --- Executes during object creation, after setting all properties.
function scorer_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scorer_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function danalyzer_score_import_Callback(hObject, eventdata, handles)
% hObject    handle to danalyzer_score_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the score file
[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));


if ~isempty(get(handles.stage_file_string, 'String'))
    [~, ~, stageExt] = fileparts(get(handles.stage_file_string, 'String'));
    
    if strcmpi(stageExt, '.mat')
        sleepstages = load(get(handles.stage_file_string, 'String'));
        structField = fieldnames(sleepstages);
        sleepstages = sleepstages.(structField{1});
        
        if all(handles.psg.stages.s1.stages == 7)
            handles.psg.stages.s1 = sleepstages;
        else
            a = questdlg('Score file already loaded. Do you want to overlay or replace?',...
                'Import sleep scores', 'Overlay', 'Replace', 'Cancel', 'Overlay');
            
            if strcmp(a, 'Overlay')
                
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(['s' num2str(length(scoreFields)+1)]) = sleepstages;
                
            elseif strcmp(a, 'Replace')
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(scoreFields{1}{1}) = sleepstages;
                
                if length(scoreFields) > 1
                    handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
                end
            end
        end
    end
end

handles = dan_data_check(handles);

[hObject, handles] = dan_plot_hypno(hObject, handles);

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function hume_score_import_Callback(hObject, eventdata, handles)
% hObject    handle to hume_score_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the directory of the score file
[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));


if ~isempty(get(handles.stage_file_string, 'String'))
    [~, ~, stageExt] = fileparts(get(handles.stage_file_string, 'String'));
    
    if strcmpi(stageExt, '.mat')
        sleepstages = load(get(handles.stage_file_string, 'String'));
        structField = fieldnames(sleepstages);
        sleepstages = sleepstages.(structField{1});
        sleepstages = hume2danalyzer(sleepstages);
        
        if all(handles.psg.stages.s1.stages == 7)
            handles.psg.stages.s1 = sleepstages;
        else
            a = questdlg('Score file already loaded. Do you want to overlay or replace?',...
                'Import sleep scores', 'Overlay', 'Replace', 'Cancel', 'Overlay');
            
            if strcmp(a, 'Overlay')
                
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(['s' num2str(length(scoreFields)+1)]) = sleepstages;
                
            elseif strcmp(a, 'Replace')
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(scoreFields{1}{1}) = sleepstages;
                handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
            end
        end
    end
end

handles = dan_data_check(handles);

[hObject, handles] = dan_plot_hypno(hObject, handles);
[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handles structure
guidata(hObject, handles);



% --------------------------------------------------------------------
function luna_score_import_Callback(hObject, eventdata, handles)
% hObject    handle to luna_score_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));

if ~isempty(get(handles.stage_file_string, 'String'))
    [~, ~, stageExt] = fileparts(get(handles.stage_file_string, 'String'));
    
    if strcmpi(stageExt, '.txt') || strcmpi(stageExt, '.eannot')
        
        sleepstages = readtable(get(handles.stage_file_string, 'String'),...
            'ReadVariableNames', 0);
        sleepstages = luna2danalyzer(sleepstages);
        
        if all(handles.psg.stages.s1.stages == 7)
            handles.psg.stages.s1 = sleepstages;
        else
            a = questdlg('Score file already loaded. Do you want to overlay or replace?',...
                'Import sleep scores', 'Overlay', 'Replace', 'Cancel', 'Overlay');
            
            if strcmp(a, 'Overlay')
                
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(['s' num2str(length(scoreFields)+1)]) = sleepstages;
                
            elseif strcmp(a, 'Replace')
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(scoreFields{1}{1}) = sleepstages;
                handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
            end
        end
    end
end

handles = dan_data_check(handles);

[hObject, handles] = dan_plot_hypno(hObject, handles);
[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handles structure
guidata(hObject, handles);



% --------------------------------------------------------------------
function twin_score_import_Callback(hObject, eventdata, handles)
% hObject    handle to twin_score_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the directory of the score file

[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));

if ~isempty(get(handles.stage_file_string, 'String'))
    [~, ~, stageExt] = fileparts(get(handles.stage_file_string, 'String'));
    
    if strcmpi(stageExt, '.xls') || strcmpi(stageExt, '.xlsx') || strcmpi(stageExt, '.xlsm') || strcmpi(stageExt, '.csv')
        
        sleepstages = readtable(get(handles.stage_file_string, 'String'),...
            'ReadVariableNames', 0);
        
        sleepstages = twin2danalyzer(sleepstages);
        
        if all(handles.psg.stages.s1.stages == 7)
            handles.psg.stages.s1 = sleepstages;
        else
            a = questdlg('Score file already loaded. Do you want to overlay or replace?',...
                'Import sleep scores', 'Overlay', 'Replace', 'Cancel', 'Overlay');
            
            if strcmp(a, 'Overlay')
                
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(['s' num2str(length(scoreFields)+1)]) = sleepstages;
                
            elseif strcmp(a, 'Replace')
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(scoreFields{1}{1}) = sleepstages;
                handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
            end
        end
    end
end

handles = dan_data_check(handles);

[hObject, handles] = dan_plot_hypno(hObject, handles);
[hObject, handles] = dan_plot_psg(hObject, handles);

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function text_score_import_Callback(hObject, eventdata, handles)
% hObject    handle to text_score_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));

if ~isempty(get(handles.stage_file_string, 'String'))
    [~, ~, stageExt] = fileparts(get(handles.stage_file_string, 'String'));
    
    if strcmpi(stageExt, '.txt')
        
        sleepstages = readtable(get(handles.stage_file_string, 'String'),...
            'ReadVariableNames', 0);
        
        a = inputdlg({'Wake' 'Stage 1' 'Stage 2' 'Stage 3' 'Stage 4' 'REM' 'Movement' 'Unstaged'});
        sleepstages = dan_convert_sleepstages(sleepstages, a);
        
        if all(handles.psg.stages.s1.stages == 7)
            handles.psg.stages.s1 = sleepstages;
        else
            a = questdlg('Score file already loaded. Do you want to overlay or replace?',...
                'Import sleep scores', 'Overlay', 'Replace', 'Cancel', 'Overlay');
            
            if strcmp(a, 'Overlay')
                
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(['s' num2str(length(scoreFields)+1)]) = sleepstages;
                
            elseif strcmp(a, 'Replace')
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(scoreFields{1}{1}) = sleepstages;
                handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
            end
        end
    end
end


% --------------------------------------------------------------------
function csv_score_import_Callback(hObject, eventdata, handles)
% hObject    handle to csv_score_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));

if ~isempty(get(handles.stage_file_string, 'String'))
    [~, ~, stageExt] = fileparts(get(handles.stage_file_string, 'String'));
    
    if strcmpi(stageExt, '.csv')
        
        sleepstages = readtable(get(handles.stage_file_string, 'String'),...
            'ReadVariableNames', 0);
        
        a = inputdlg({'Wake' 'Stage 1' 'Stage 2' 'Stage 3' 'Stage 4' 'REM' 'Movement' 'Unstaged'});
        sleepstages = dan_convert_sleepstages(sleepstages, a);
        
        if all(handles.psg.stages.s1.stages == 7)
            handles.psg.stages.s1 = sleepstages;
        else
            a = questdlg('Score file already loaded. Do you want to overlay or replace?',...
                'Import sleep scores', 'Overlay', 'Replace', 'Cancel', 'Overlay');
            
            if strcmp(a, 'Overlay')
                
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(['s' num2str(length(scoreFields)+1)]) = sleepstages;
                
            elseif strcmp(a, 'Replace')
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(scoreFields{1}{1}) = sleepstages;
                handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
            end
        end
    end
end


% --------------------------------------------------------------------
function mat_score_import_Callback(hObject, eventdata, handles)
% hObject    handle to mat_score_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[scoreName, scoreDir, filtIdx] = uigetfile({'*.*'},...
    'Load score file');
if filtIdx == 0
    return
end

% Save score file path
set(handles.stage_file_string, 'String', fullfile(scoreDir, scoreName));

if ~isempty(get(handles.stage_file_string, 'String'))
    [~, ~, stageExt] = fileparts(get(handles.stage_file_string, 'String'));
    
    if strcmpi(stageExt, '.mat')
        
        sleepstages = readtable(get(handles.stage_file_string, 'String'),...
            'ReadVariableNames', 0);
        
        a = inputdlg({'Wake' 'Stage 1' 'Stage 2' 'Stage 3' 'Stage 4' 'REM' 'Movement' 'Unstaged'});
        sleepstages = dan_convert_sleepstages(sleepstages, a);
        
        if all(handles.psg.stages.s1.stages == 7)
            handles.psg.stages.s1 = sleepstages;
        else
            a = questdlg('Score file already loaded. Do you want to overlay or replace?',...
                'Import sleep scores', 'Overlay', 'Replace', 'Cancel', 'Overlay');
            
            if strcmp(a, 'Overlay')
                
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(['s' num2str(length(scoreFields)+1)]) = sleepstages;
                
            elseif strcmp(a, 'Replace')
                scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
                scoreFields(cellfun(@isempty, scoreFields)) = [];
                handles.psg.stages.(scoreFields{1}{1}) = sleepstages;
                handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
            end
        end
    end
end

% --------------------------------------------------------------------
function txt_score_export_Callback(hObject, eventdata, handles)
% hObject    handle to txt_score_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stageLabels = inputdlg({'Wake' 'Stage 1' 'Stage 2' 'Stage 3' 'Stage 4' 'REM' 'Movement' 'Unstaged'});

[exportName, exportPath] = uiputfile({'*.txt'});

sleepstages = dan_export_sleepstages(handles.psg.stages.s1, stageLabels);

writetable(cell2table(sleepstages), fullfile(exportPath, exportName), ...
    'WriteVariableNames', 0);


% --------------------------------------------------------------------
function csv_score_export_Callback(hObject, eventdata, handles)
% hObject    handle to csv_score_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stageLabels = inputdlg({'Wake' 'Stage 1' 'Stage 2' 'Stage 3' 'Stage 4' 'REM' 'Movement' 'Unstaged'});

[exportName, exportPath] = uiputfile({'*.csv'});

sleepstages = dan_export_sleepstages(handles.psg.stages.s1, stageLabels);

writetable(cell2table(sleepstages), fullfile(exportPath, exportName), ...
    'WriteVariableNames', 0);

% --------------------------------------------------------------------
function mat_score_export_Callback(hObject, eventdata, handles)
% hObject    handle to mat_score_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function edf_psg_export_Callback(hObject, eventdata, handles)
% hObject    handle to edf_psg_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[exportName, exportPath] = uiputfile({'*.edf'});

pop_writeeeg(danalyzer2eeglab(handles.psg), fullfile(exportPath, exportName),...
    'TYPE', 'EDF');

% --------------------------------------------------------------------
function set_psg_export_Callback(hObject, eventdata, handles)
% hObject    handle to set_psg_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[exportName, exportPath] = uiputfile({'*.set'});

pop_saveset(danalyzer2eeglab(handles.psg), 'filename', exportName,...
    'filepath', exportPath, 'savemode', 'onefile', 'version', '7.3');

% --------------------------------------------------------------------
function eeg_psg_export_Callback(hObject, eventdata, handles)
% hObject    handle to eeg_psg_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[exportName, exportPath] = uiputfile({'*.vhdr'});

pop_writebva(danalyzer2eeglab(handles.psg), fullfile(exportPath, exportName));


% --------------------------------------------------------------------
function mat_psg_export_Callback(hObject, eventdata, handles)
% hObject    handle to mat_psg_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[exportName, exportPath] = uiputfile({'*.mat'});

psg = handles.psg;
psg = rmfield(psg, {'stages' 'events' 'ar'});

save(fullfile(exportPath, exportName), 'psg');

clear psg


% --------------------------------------------------------------------
function text_ar_export_Callback(hObject, eventdata, handles)
% hObject    handle to text_ar_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[exportName, exportPath] = uiputfile({'*.txt'});

chanList  = num2cell(handles.psg.ar.badchans);
epochList = num2cell([handles.psg.ar.badepochs]);

arCell{1,1} = 'Bad channel list:';
arCell = [arCell; chanList];
arCell = [arCell; {'Bad epoch list:'}];
arCell = [arCell; epochList];

writetable(cell2table(arCell), fullfile(exportPath, exportName),...
    'WriteVariableNames', 0)

% --------------------------------------------------------------------
function csv_ar_export_Callback(hObject, eventdata, handles)
% hObject    handle to csv_ar_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[exportName, exportPath] = uiputfile({'*.csv'});

chanList  = num2cell(handles.psg.ar.badchans);
epochList = num2cell([handles.psg.ar.badepochs]);

arCell{1,1} = 'Bad channel list:';
arCell = [arCell; chanList];
arCell = [arCell; {'Bad epoch list:'}];
arCell = [arCell; epochList];

writetable(cell2table(arCell), fullfile(exportPath, exportName),...
    'WriteVariableNames', 0)

% --------------------------------------------------------------------
function text_event_export_Callback(hObject, eventdata, handles)
% hObject    handle to text_event_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[exportName, exportPath] = uiputfile({'*.txt'});

writetable(handles.psg.events, fullfile(exportPath, exportName),...
    'Delimiter', '\t')

% --------------------------------------------------------------------
function csv_events_export_Callback(hObject, eventdata, handles)
% hObject    handle to csv_events_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[exportName, exportPath] = uiputfile({'*.csv'});

eventTable = handles.psg.events;
eventTable.Clock_Time = duration(eventTable.Clock_Time);

writetable(eventTable, fullfile(exportPath, exportName))


% --------------------------------------------------------------------
function clear_scores_Callback(hObject, eventdata, handles)
% hObject    handle to clear_scores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

scoreFields = regexp(fieldnames(handles.psg.stages), 's\d', 'match');
scoreFields(cellfun(@isempty, scoreFields)) = [];

handles.psg.stages.s1.stages = [];
handles.psg.stages.s1.hdr    = [];
handles.psg.stages.spectogram.specto = [];
handles.psg.stages.spectogram.hdr = [];

handles.psg.stages.s1.hdr.srate     = [];
handles.psg.stages.s1.hdr.win       = [];
handles.psg.stages.s1.hdr.recStart  = "";
handles.psg.stages.s1.hdr.lOn       = "";
handles.psg.stages.s1.hdr.lOff      = "";
handles.psg.stages.s1.hdr.notes     = [];
handles.psg.stages.s1.hdr.onsets    = [];
handles.psg.stages.s1.hdr.stageTime = [];
handles.psg.stages.s1.hdr.scorer    = [];

if length(scoreFields) > 1
    handles.psg.stages = rmfield(handles.psg.stages, [scoreFields{2:end}]);
end

% Update handle structure
guidata(hObject,handles);


% --------------------------------------------------------------------
function clear_events_Callback(hObject, eventdata, handles)
% hObject    handle to clear_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function clear_ar_Callback(hObject, eventdata, handles)
% hObject    handle to clear_ar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_13_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function refresh_montage_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Find monatages
toolboxPath = fileparts(which('sleepDanalyzer'));

handles.montageList = dir([fullfile(toolboxPath, 'montages') filesep '*.m']);
set(handles.montage_list, 'String', {handles.montageList.name})

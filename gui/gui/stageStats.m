function varargout = stageStats(varargin)
% STAGESTATS MATLAB code for stageStats.fig
%      STAGESTATS, by itself, creates a new STAGESTATS or raises the existing
%      singleton*.
%
%      H = STAGESTATS returns the handle to a new STAGESTATS or the handle to
%      the existing singleton*.
%
%      STAGESTATS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STAGESTATS.M with the given input arguments.
%
%      STAGESTATS('Property','Value',...) creates a new STAGESTATS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stageStats_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stageStats_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stageStats

% Last Modified by GUIDE v2.5 25-Sep-2020 12:47:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stageStats_OpeningFcn, ...
                   'gui_OutputFcn',  @stageStats_OutputFcn, ...
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


% --- Executes just before stageStats is made visible.
function stageStats_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stageStats (see VARARGIN)

% Choose default command line output for stageStats
handles.output = hObject;

dataStruct = varargin{1};
handles.psg = dataStruct.psg;
handles.spectogram_string = dataStruct.spectogram_string;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stageStats wait for user response (see UIRESUME)
% uiwait(handles.sleepstats_GUI);

% --- Outputs from this function are returned to the command line.
function varargout = stageStats_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function stagestats_save_string_Callback(hObject, eventdata, handles)
% hObject    handle to stagestats_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stagestats_save_string as text
%        str2double(get(hObject,'String')) returns contents of stagestats_save_string as a double


% --- Executes during object creation, after setting all properties.
function stagestats_save_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stagestats_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stagestats_save_dir.
function stagestats_save_dir_Callback(hObject, eventdata, handles)
% hObject    handle to stagestats_save_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[stageStatsSaveName, stageStatsSaveDir, filtIdx] = uiputfile({'*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

set(handles.stagestats_save_string, 'String', fullfile(stageStatsSaveDir, stageStatsSaveName));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in save_stagestats.
function save_stagestats_Callback(hObject, eventdata, handles)
% hObject    handle to save_stagestats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sleepstages = handles.psg.stages.s1;

% Spectogram

if ~isempty(get(handles.spec_channel, 'String'))
    
    % Is there already a spectogram
    
    if ~strcmp(get(handles.spec_channel, 'String'), get(handles.spectogram_string, 'String')) || isempty(get(handles.spectogram_string, 'String'))
        
        % Try and find the channel
        
        chanIdx = find(strcmp({handles.psg.chans.labels}, get(handles.spec_channel, 'String')));
        
        if ~isempty(chanIdx)
            
            % Get epoch indices
            epochIdx = indexepochs(30 * handles.psg.hdr.srate, handles.psg.hdr.samples);
            
            % Calculate PSD for each epoch using pwelch
            
            for epoch_i = 1:length(epochIdx)
                [psdEpoch(epoch_i,:), psdFreqs] = fun_calculate_psd(handles.psg.data(chanIdx,epochIdx(epoch_i,1):1:epochIdx(epoch_i,2)),...
                    5, handles.psg.hdr.srate); % Calculate PSD for each epoch
            end
            
            sleepstages.spectogram.specto = psdEpoch;
            sleepstages.spectogram.freqs  = psdFreqs;
            
        end
        
    end
   
    
end

% SOL rule

if get(handles.sol_rule1, 'Value') == 1
    solRule = 1;
elseif get(handles.sol_rule2, 'Value') == 1
    solRule = 2;
elseif get(handles.sol_rule3, 'Value') == 1
    solRule = 3;
elseif get(handles.sol_rule4, 'Value') == 1
    solRule = 4;
end

% REM rule

remRule = [str2double(get(handles.rem_rule1, 'String')) str2double(get(handles.rem_rule2, 'String'))];

if get(handles.rem_rule3, 'Value') == 1
    remRule(3) = 0;
elseif get(handles.rem_rule3, 'Value') == 2
    remRule(3) = 1;
elseif get(handles.rem_rule3, 'Value') == 3
    remRule(3) = 2;
end

% End rule

if get(handles.sleepend_rule1, 'Value') == 1
    endRule = 1;
elseif get(handles.sleepend_rule2, 'Value') == 1
    endRule = 1;
end

[savePath, saveName] = fileparts(get(handles.stagestats_save_string, 'String'));

stagestats = fun_sleep_statistics(sleepstages, 'SleepOnset', solRule, 'RemRules', remRule,...
    'EndSleep', endRule, 'CycleRules', [remRule(1) remRule(2) 0], 'Report', 'on',...
    'SaveFolder', savePath, 'SaveName', saveName);

save(get(handles.stagestats_save_string, 'String'), 'stagestats');

% --- Executes on button press in cancel_stagestats.
function cancel_stagestats_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_stagestats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close('stageStats')

% --- Executes on button press in sleepend_rule1.
function sleepend_rule1_Callback(hObject, eventdata, handles)
% hObject    handle to sleepend_rule1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sleepend_rule1


% --- Executes on button press in sleepend_rule2.
function sleepend_rule2_Callback(hObject, eventdata, handles)
% hObject    handle to sleepend_rule2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sleepend_rule2



function rem_rule1_Callback(hObject, eventdata, handles)
% hObject    handle to rem_rule1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rem_rule1 as text
%        str2double(get(hObject,'String')) returns contents of rem_rule1 as a double


% --- Executes during object creation, after setting all properties.
function rem_rule1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rem_rule1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rem_rule2_Callback(hObject, eventdata, handles)
% hObject    handle to rem_rule2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rem_rule2 as text
%        str2double(get(hObject,'String')) returns contents of rem_rule2 as a double


% --- Executes during object creation, after setting all properties.
function rem_rule2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rem_rule2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in rem_rule3.
function rem_rule3_Callback(hObject, eventdata, handles)
% hObject    handle to rem_rule3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rem_rule3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rem_rule3


% --- Executes during object creation, after setting all properties.
function rem_rule3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rem_rule3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spec_channel_Callback(hObject, eventdata, handles)
% hObject    handle to spec_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = 2;

% Hints: get(hObject,'String') returns contents of spec_channel as text
%        str2double(get(hObject,'String')) returns contents of spec_channel as a double


% --- Executes during object creation, after setting all properties.
function spec_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spec_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

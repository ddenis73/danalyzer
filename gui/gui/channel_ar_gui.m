function varargout = channel_ar_gui(varargin)
% CHANNEL_AR_GUI MATLAB code for channel_ar_gui.fig
%      CHANNEL_AR_GUI, by itself, creates a new CHANNEL_AR_GUI or raises the existing
%      singleton*.
%
%      H = CHANNEL_AR_GUI returns the handle to a new CHANNEL_AR_GUI or the handle to
%      the existing singleton*.
%
%      CHANNEL_AR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNEL_AR_GUI.M with the given input arguments.
%
%      CHANNEL_AR_GUI('Property','Value',...) creates a new CHANNEL_AR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channel_ar_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channel_ar_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channel_ar_gui

% Last Modified by GUIDE v2.5 20-Dec-2020 11:37:54

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

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @channel_ar_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @channel_ar_gui_OutputFcn, ...
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


% --- Executes just before channel_ar_gui is made visible.
function channel_ar_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channel_ar_gui (see VARARGIN)

% Choose default command line output for channel_ar_gui
handles.output = hObject;

dataStruct = varargin{1};
handles.psg = dataStruct.psg;

% Prepare channel list

if ~isempty(handles.psg.chans(1).type)
    eegChanIdx = ismember({handles.psg.chans.type}, 'EEG');
    set(handles.channels_to_include, 'String', {handles.psg.chans(eegChanIdx).labels})
else
    set(handles.channels_to_include, 'String', {handles.psg.chans.labels})
end
    
% Set default window size to be epoch duration

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes channel_ar_gui wait for user response (see UIRESUME)
% uiwait(handles.seg_ar);


% --- Outputs from this function are returned to the command line.
function varargout = channel_ar_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_chan_ar.
function run_chan_ar_Callback(hObject, eventdata, handles)
% hObject    handle to run_chan_ar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use just the channels requested
chanNames = {handles.psg.chans.labels};
chanNames = chanNames(~ismember({handles.psg.chans.labels}, get(handles.channels_to_include, 'String')));
badchans  = zeros(length({handles.psg.chans.labels}), 1);


ar = fun_detect_artifacts(handles.psg, handles.psg.stages.s1, 'EpochDetection', 'no',...
    'EpochParameters', {str2double(get(handles.hjorth_sd, 'String')) str2double(get(handles.nIterations, 'String'))...
    str2double(get(handles.hjorth_per, 'String')) 'no'}, 'IgnoreChannels', chanNames);
    
badchans = ar.badchans;

h = findobj('Tag', 'main_window');

setappdata(h, 'auto_ar_chan', badchans)

% Update handles structure
guidata(hObject, handles);

close(gcf)


% --- Executes on button press in cancel_chan_ar.
function cancel_chan_ar_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_chan_ar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)


function channels_to_include_Callback(hObject, eventdata, handles)
% hObject    handle to channels_to_include (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channels_to_include as text
%        str2double(get(hObject,'String')) returns contents of channels_to_include as a double


% --- Executes during object creation, after setting all properties.
function channels_to_include_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels_to_include (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hjorth_sd_Callback(hObject, eventdata, handles)
% hObject    handle to hjorth_sd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hjorth_sd as text
%        str2double(get(hObject,'String')) returns contents of hjorth_sd as a double


% --- Executes during object creation, after setting all properties.
function hjorth_sd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hjorth_sd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to r_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_threshold as text
%        str2double(get(hObject,'String')) returns contents of r_threshold as a double


% --- Executes during object creation, after setting all properties.
function r_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ar_window_size_Callback(hObject, eventdata, handles)
% hObject    handle to ar_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_window_size as text
%        str2double(get(hObject,'String')) returns contents of ar_window_size as a double


% --- Executes during object creation, after setting all properties.
function ar_window_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hjorth_per_Callback(hObject, eventdata, handles)
% hObject    handle to hjorth_per (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hjorth_per as text
%        str2double(get(hObject,'String')) returns contents of hjorth_per as a double


% --- Executes during object creation, after setting all properties.
function hjorth_per_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hjorth_per (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nIterations_Callback(hObject, eventdata, handles)
% hObject    handle to nIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nIterations as text
%        str2double(get(hObject,'String')) returns contents of nIterations as a double


% --- Executes during object creation, after setting all properties.
function nIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r_per_Callback(hObject, eventdata, handles)
% hObject    handle to r_per (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_per as text
%        str2double(get(hObject,'String')) returns contents of r_per as a double


% --- Executes during object creation, after setting all properties.
function r_per_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_per (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

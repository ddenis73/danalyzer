function varargout = segment_ar_gui(varargin)
% SEGMENT_AR_GUI MATLAB code for segment_ar_gui.fig
%      SEGMENT_AR_GUI, by itself, creates a new SEGMENT_AR_GUI or raises the existing
%      singleton*.
%
%      H = SEGMENT_AR_GUI returns the handle to a new SEGMENT_AR_GUI or the handle to
%      the existing singleton*.
%
%      SEGMENT_AR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENT_AR_GUI.M with the given input arguments.
%
%      SEGMENT_AR_GUI('Property','Value',...) creates a new SEGMENT_AR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segment_ar_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segment_ar_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segment_ar_gui

% Last Modified by GUIDE v2.5 20-Dec-2020 11:31:47

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
%%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segment_ar_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @segment_ar_gui_OutputFcn, ...
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


% --- Executes just before segment_ar_gui is made visible.
function segment_ar_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segment_ar_gui (see VARARGIN)

% Choose default command line output for segment_ar_gui
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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segment_ar_gui wait for user response (see UIRESUME)
% uiwait(handles.seg_ar);


% --- Outputs from this function are returned to the command line.
function varargout = segment_ar_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_seg_ar.
function run_seg_ar_Callback(hObject, eventdata, handles)
% hObject    handle to run_seg_ar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use just the channels requested
chanNames = {handles.psg.chans.labels};
chanNames = chanNames(~ismember({handles.psg.chans.labels}, get(handles.channels_to_include, 'String')));

ar = fun_detect_artifacts(handles.psg, handles.psg.stages.s1, 'ChannelDetection', 'no',...
    'EpochParameters', {str2double(get(handles.edit7, 'String')) str2double(get(handles.edit9, 'String')) 1 'no'},...
    'IgnoreChannels', chanNames);

h = findobj('Tag', 'main_window');

setappdata(h, 'auto_ar_seg', ar)

% Update handles structure
guidata(hObject, handles);

close(gcf)


% --- Executes on button press in cancel_seg_ar.
function cancel_seg_ar_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_seg_ar (see GCBO)
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



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

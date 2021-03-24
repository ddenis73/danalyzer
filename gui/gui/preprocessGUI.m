function varargout = preprocessGUI(varargin)
% PREPROCESSGUI MATLAB code for preprocessGUI.fig
%      PREPROCESSGUI, by itself, creates a new PREPROCESSGUI or raises the existing
%      singleton*.
%
%      H = PREPROCESSGUI returns the handle to a new PREPROCESSGUI or the handle to
%      the existing singleton*.
%
%      PREPROCESSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSGUI.M with the given input arguments.
%
%      PREPROCESSGUI('Property','Value',...) creates a new PREPROCESSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preprocessGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preprocessGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preprocessGUI

% Last Modified by GUIDE v2.5 21-Feb-2020 21:14:10

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
    'gui_OpeningFcn', @preprocessGUI_OpeningFcn, ...
    'gui_OutputFcn',  @preprocessGUI_OutputFcn, ...
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


% --- Executes just before preprocessGUI is made visible.
function preprocessGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to preprocessGUI (see VARARGIN)

% Choose default command line output for preprocessGUI
handles.output = hObject;

%%%%%% DEFAULT SETTINGS. CHANGE PARAMETERS HERE %%%%%%%%

set(handles.eeg_reref, 'String', '{''A1'' ''A2''}'); % EEG re-reference
set(handles.other_reref, 'String', '{''EMG1'' ''EMG2''}'); % Other re-reference
set(handles.notch_filter, 'String', '60'); % Notch filter
set(handles.eeg_lp, 'String', '0.3'); % EEG low-pass filter
set(handles.eeg_hp, 'String', '35'); % EEG high-pass filter
set(handles.emg_lp, 'String', '10'); % EMG low-pass filter
set(handles.emg_hp, 'String', '100'); % EMG high pass filter
set(handles.eog_lp, 'String', '0.3'); % EOG low-pass filter
set(handles.eog_hp, 'String', '35'); % EOG high-pass filter


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes preprocessGUI wait for user response (see UIRESUME)
% uiwait(handles.preprocess_window);


% --- Outputs from this function are returned to the command line.
function varargout = preprocessGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in find_data_file.
function find_data_file_Callback(hObject, eventdata, handles)
% hObject    handle to find_data_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.batch_check, 'Value') == 0
    
    [dataName, dataDir, filtIdx] = uigetfile({'*.*'},...
        'Load data file');
    if filtIdx == 0
        return
    end
    
    set(handles.data_file_string, 'String', fullfile(dataDir, dataName));
    
elseif get(handles.batch_check, 'Value') == 1
    
    dataDir = uigetdir;
    
    set(handles.data_file_string, 'String', dataDir);
    
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in find_score_file.
function find_score_file_Callback(hObject, eventdata, handles)
% hObject    handle to find_score_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.batch_check, 'Value') == 0
    
    [scoreName, scoreDir, filtIdx] = uigetfile({'*.xlsx'; '*.csv'; '*.mat'; '*.*'},...
        'Load score file');
    if filtIdx == 0
        return
    end
    
    set(handles.score_file_string, 'String', fullfile(scoreDir, scoreName));
    
elseif get(handles.batch_check, 'Value') == 1
    
    scoreDir = uigetdir;
    
    set(handles.score_file_string, 'String', scoreDir);
    
end


% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in find_notations_file.
function find_notations_file_Callback(hObject, eventdata, handles)
% hObject    handle to find_notations_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.batch_check, 'Value') == 0
    
    [notationsName, notationsDir, filtIdx] = uigetfile({'*.xlsx'; '*.csv'; '*.mat'; '*.*'},...
        'Load notations file');
    if filtIdx == 0
        return
    end
    
    set(handles.notations_file_string, 'String', fullfile(notationsDir, notationsName));
    
elseif get(handles.batch_check, 'Value') == 1
    
    notationsDir = uigetdir;
    
    set(handles.notations_file_string, 'String', notationsDir);
    
end


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in find_chanlocs_file.
function find_chanlocs_file_Callback(hObject, eventdata, handles)
% hObject    handle to find_chanlocs_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[chanlocsName, chanlocsDir, filtIdx] = uigetfile({'*.*'},...
    'Load chanlocs file');
if filtIdx == 0
    return
end

set(handles.chanlocs_file_string, 'String', fullfile(chanlocsDir, chanlocsName));

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Start preprocess%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in start_preprocess.
function start_preprocess_Callback(hObject, eventdata, handles)
% hObject    handle to start_preprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.batch_check, 'Value') == 0
    
    if isempty(get(handles.data_file_string, 'String'))
        
        h = findobj('Tag', 'main_window');
        
        mainguidata = guidata(h);
        
    elseif ~isempty(get(handles.data_file_string, 'String'))
        
        data = get(handles.data_file_string, 'String');
        scores = [];
        chanlocs = get(handles.chanlocs_file_string, 'String');
        if ~isempty(get(handles.eeg_reref, 'String')) && ~strcmpi(get(handles.eeg_reref, 'String'), 'avg')
            ref1 = eval(get(handles.eeg_reref, 'String'));
        elseif ~isempty(get(handles.eeg_reref, 'String')) && strcmpi(get(handles.eeg_reref, 'String'), 'avg')
            ref1 = 'AVG';
        else
            ref1 = [];
        end
        if ~isempty(get(handles.other_reref, 'String'))
            ref2 = eval(get(handles.other_reref, 'String'));
        else
            ref2 = [];
        end
        notch = str2double(get(handles.notch_filter, 'String'));
        eeglp = str2double(get(handles.eeg_lp, 'String'));
        eeghp = str2double(get(handles.eeg_hp, 'String'));
        emglp = str2double(get(handles.emg_lp, 'String'));
        emghp = str2double(get(handles.emg_hp, 'String'));
        eoglp = str2double(get(handles.eog_lp, 'String'));
        eoghp = str2double(get(handles.eog_hp, 'String'));
        ecglp = str2double(get(handles.ecg_lp, 'String'));
        ecghp = str2double(get(handles.ecg_hp, 'String'));
        otherlp = str2double(get(handles.other_lp, 'String'));
        otherhp = str2double(get(handles.other_hp, 'String'));
        emgkeep = get(handles.remove_emg, 'Value');
        eogkeep = get(handles.remove_eog, 'Value');
        ecgkeep = get(handles.remove_ecg, 'Value');
        otherkeep = get(handles.remove_other, 'Value');
        epoch = [];
        
        saveType = get(handles.save_format, 'Value');
        
        if saveType == 1
            save = '.set';
        elseif saveType == 2
            save = '.edf';
        elseif saveType == 3
            save = '.mat';
        end
        
        dan_preprocess(data, scores, chanlocs, ref1, ref2, notch, eeglp, eeghp, emglp, emghp, eoglp, eoghp, ecglp, ecghp, otherlp, otherhp, save, emgkeep, eogkeep, ecgkeep, otherkeep, epoch)
        
    end
    
elseif get(handles.batch_check, 'Value') == 1
    
    data = get(handles.data_file_string, 'String');
    scores = [];
    chanlocs = get(handles.chanlocs_file_string, 'String');
    
    if get(handles.group_struct, 'Value') == 1
        folderOrganization = 'byGroup';
    elseif get(handles.subject_struct, 'Value') == 1
        folderOrganization = 'bySubject';
    end
    
    batchid = get(handles.batch_file_identifier, 'String');
    badid = get(handles.batch_bad_ref_identifier, 'String');
    
    if ~isempty(get(handles.eeg_reref, 'String')) && ~strcmpi(get(handles.eeg_reref, 'String'), 'avg')
        ref1 = eval(get(handles.eeg_reref, 'String'));
    elseif ~isempty(get(handles.eeg_reref, 'String')) && strcmpi(get(handles.eeg_reref, 'String'), 'avg')
        ref1 = 'AVG';
    else
        ref1 = [];
    end
    if ~isempty(get(handles.other_reref, 'String'))
        ref2 = eval(get(handles.other_reref, 'String'));
    else
        ref2 = [];
    end
    notch = str2double(get(handles.notch_filter, 'String'));
    eeglp = str2double(get(handles.eeg_lp, 'String'));
    eeghp = str2double(get(handles.eeg_hp, 'String'));
    emglp = str2double(get(handles.emg_lp, 'String'));
    emghp = str2double(get(handles.emg_hp, 'String'));
    eoglp = str2double(get(handles.eog_lp, 'String'));
    eoghp = str2double(get(handles.eog_hp, 'String'));
    ecglp = str2double(get(handles.ecg_lp, 'String'));
    ecghp = str2double(get(handles.ecg_hp, 'String'));
    otherlp = str2double(get(handles.other_lp, 'String'));
    otherhp = str2double(get(handles.other_hp, 'String'));
    emgkeep = get(handles.remove_emg, 'Value');
    eogkeep = get(handles.remove_eog, 'Value');
    ecgkeep = get(handles.remove_ecg, 'Value');
    otherkeep = get(handles.remove_other, 'Value');
    epoch = [];
    
    saveType = get(handles.save_format, 'Value');
    
    if saveType == 1
        save = '.set';
    elseif saveType == 2
        save = '.edf';
    elseif saveType == 3
        save = '.mat';
    end
    
    dan_preprocess_batch(data, scores, chanlocs, folderOrganization, batchid, badid, ref1, ref2, notch, eeglp, eeghp, emglp, emghp, eoglp, eoghp, ecglp, ecghp, otherlp, otherhp, emgkeep, eogkeep, ecgkeep, otherkeep, epoch)
    
end

% --- Executes on button press in cancel_preprocess.
function cancel_preprocess_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_preprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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



function score_file_string_Callback(hObject, eventdata, handles)
% hObject    handle to score_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of score_file_string as text
%        str2double(get(hObject,'String')) returns contents of score_file_string as a double


% --- Executes during object creation, after setting all properties.
function score_file_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to score_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function notations_file_string_Callback(hObject, eventdata, handles)
% hObject    handle to notations_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notations_file_string as text
%        str2double(get(hObject,'String')) returns contents of notations_file_string as a double


% --- Executes during object creation, after setting all properties.
function notations_file_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notations_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function chanlocs_file_string_Callback(hObject, eventdata, handles)
% hObject    handle to chanlocs_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chanlocs_file_string as text
%        str2double(get(hObject,'String')) returns contents of chanlocs_file_string as a double


% --- Executes during object creation, after setting all properties.
function chanlocs_file_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chanlocs_file_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in group_struct.
function group_struct_Callback(hObject, eventdata, handles)
% hObject    handle to group_struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of group_struct


% --- Executes on button press in subject_struct.
function subject_struct_Callback(hObject, eventdata, handles)
% hObject    handle to subject_struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of subject_struct



function eeg_reref_Callback(hObject, eventdata, handles)
% hObject    handle to eeg_reref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eeg_reref as text
%        str2double(get(hObject,'String')) returns contents of eeg_reref as a double


% --- Executes during object creation, after setting all properties.
function eeg_reref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eeg_reref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function other_reref_Callback(hObject, eventdata, handles)
% hObject    handle to other_reref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of other_reref as text
%        str2double(get(hObject,'String')) returns contents of other_reref as a double


% --- Executes during object creation, after setting all properties.
function other_reref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to other_reref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notch_filter_Callback(hObject, eventdata, handles)
% hObject    handle to notch_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notch_filter as text
%        str2double(get(hObject,'String')) returns contents of notch_filter as a double


% --- Executes during object creation, after setting all properties.
function notch_filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notch_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eeg_lp_Callback(hObject, eventdata, handles)
% hObject    handle to eeg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eeg_lp as text
%        str2double(get(hObject,'String')) returns contents of eeg_lp as a double


% --- Executes during object creation, after setting all properties.
function eeg_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eeg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eeg_hp_Callback(hObject, eventdata, handles)
% hObject    handle to eeg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eeg_hp as text
%        str2double(get(hObject,'String')) returns contents of eeg_hp as a double


% --- Executes during object creation, after setting all properties.
function eeg_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eeg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function emg_lp_Callback(hObject, eventdata, handles)
% hObject    handle to emg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emg_lp as text
%        str2double(get(hObject,'String')) returns contents of emg_lp as a double


% --- Executes during object creation, after setting all properties.
function emg_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function emg_hp_Callback(hObject, eventdata, handles)
% hObject    handle to emg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emg_hp as text
%        str2double(get(hObject,'String')) returns contents of emg_hp as a double


% --- Executes during object creation, after setting all properties.
function emg_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eog_lp_Callback(hObject, eventdata, handles)
% hObject    handle to eog_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eog_lp as text
%        str2double(get(hObject,'String')) returns contents of eog_lp as a double


% --- Executes during object creation, after setting all properties.
function eog_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eog_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eog_hp_Callback(hObject, eventdata, handles)
% hObject    handle to eog_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eog_hp as text
%        str2double(get(hObject,'String')) returns contents of eog_hp as a double


% --- Executes during object creation, after setting all properties.
function eog_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eog_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ecg_lp_Callback(hObject, eventdata, handles)
% hObject    handle to ecg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ecg_lp as text
%        str2double(get(hObject,'String')) returns contents of ecg_lp as a double


% --- Executes during object creation, after setting all properties.
function ecg_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecg_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ecg_hp_Callback(hObject, eventdata, handles)
% hObject    handle to ecg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ecg_hp as text
%        str2double(get(hObject,'String')) returns contents of ecg_hp as a double


% --- Executes during object creation, after setting all properties.
function ecg_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecg_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function other_lp_Callback(hObject, eventdata, handles)
% hObject    handle to other_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of other_lp as text
%        str2double(get(hObject,'String')) returns contents of other_lp as a double


% --- Executes during object creation, after setting all properties.
function other_lp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to other_lp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function other_hp_Callback(hObject, eventdata, handles)
% hObject    handle to other_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of other_hp as text
%        str2double(get(hObject,'String')) returns contents of other_hp as a double


% --- Executes during object creation, after setting all properties.
function other_hp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to other_hp (see GCBO)
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


% --- Executes on button press in remove_emg.
function remove_emg_Callback(hObject, eventdata, handles)
% hObject    handle to remove_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of remove_emg


% --- Executes on button press in remove_eog.
function remove_eog_Callback(hObject, eventdata, handles)
% hObject    handle to remove_eog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of remove_eog


% --- Executes on button press in remove_ecg.
function remove_ecg_Callback(hObject, eventdata, handles)
% hObject    handle to remove_ecg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of remove_ecg


% --- Executes on button press in remove_other.
function remove_other_Callback(hObject, eventdata, handles)
% hObject    handle to remove_other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of remove_other


% --- Executes on button press in batch_check.
function batch_check_Callback(hObject, eventdata, handles)
% hObject    handle to batch_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batch_check



function batch_file_identifier_Callback(hObject, eventdata, handles)
% hObject    handle to batch_file_identifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of batch_file_identifier as text
%        str2double(get(hObject,'String')) returns contents of batch_file_identifier as a double


% --- Executes during object creation, after setting all properties.
function batch_file_identifier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batch_file_identifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function batch_bad_ref_identifier_Callback(hObject, eventdata, handles)
% hObject    handle to batch_bad_ref_identifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of batch_bad_ref_identifier as text
%        str2double(get(hObject,'String')) returns contents of batch_bad_ref_identifier as a double


% --- Executes during object creation, after setting all properties.
function batch_bad_ref_identifier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batch_bad_ref_identifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in save_format.
function save_format_Callback(hObject, eventdata, handles)
% hObject    handle to save_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns save_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from save_format


% --- Executes during object creation, after setting all properties.
function save_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function varargout = sleepStatistics(varargin)
% SLEEPSTATISTICS MATLAB code for sleepStatistics.fig
%      SLEEPSTATISTICS, by itself, creates a new SLEEPSTATISTICS or raises the existing
%      singleton*.
%
%      H = SLEEPSTATISTICS returns the handle to a new SLEEPSTATISTICS or the handle to
%      the existing singleton*.
%
%      SLEEPSTATISTICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLEEPSTATISTICS.M with the given input arguments.
%
%      SLEEPSTATISTICS('Property','Value',...) creates a new SLEEPSTATISTICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sleepStatistics_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sleepStatistics_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sleepStatistics

% Last Modified by GUIDE v2.5 13-Mar-2021 14:53:25
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
                   'gui_OpeningFcn', @sleepStatistics_OpeningFcn, ...
                   'gui_OutputFcn',  @sleepStatistics_OutputFcn, ...
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


% --- Executes just before sleepStatistics is made visible.
function sleepStatistics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sleepStatistics (see VARARGIN)

% Choose default command line output for sleepStatistics
handles.output = hObject;


dataStruct = varargin{1};
handles.psg = dataStruct.psg;
handles.spectogram_string = dataStruct.spectogram_string;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes sleepStatistics wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sleepStatistics_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function sleepstats_save_string_Callback(hObject, eventdata, handles)
% hObject    handle to sleepstats_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sleepstats_save_string as text
%        str2double(get(hObject,'String')) returns contents of sleepstats_save_string as a double


% --- Executes during object creation, after setting all properties.
function sleepstats_save_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sleepstats_save_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sleepstats_save_dir.
function sleepstats_save_dir_Callback(hObject, eventdata, handles)
% hObject    handle to sleepstats_save_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[sleepStatsSaveName, sleepStatsSaveDir, filtIdx] = uiputfile({'*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

set(handles.sleepstats_save_string, 'String', fullfile(sleepStatsSaveDir, sleepStatsSaveName));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in save_sleepstats.
function save_sleepstats_Callback(hObject, eventdata, handles)
% hObject    handle to save_sleepstats (see GCBO)
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
                [psdEpoch(epoch_i,:), psdFreqs] = fun_spectral_power(handles.psg.data(chanIdx,epochIdx(epoch_i,1):1:epochIdx(epoch_i,2)),...
                    handles.psg.hdr.srate); % Calculate PSD for each epoch
            end
            
            sleepstages.spectogram.specto = psdEpoch;
            sleepstages.spectogram.freqs  = psdFreqs;
            
        end
        
    end
end

% SOL rule

if get(handles.sol_rule1, 'Value') == 1
    solRule = 2;
elseif get(handles.sol_rule2, 'Value') == 1
    solRule = 1;
elseif get(handles.sol_rule3, 'Value') == 1
    solRule = 4;
elseif get(handles.sol_rule4, 'Value') == 1
    solRule = 3;
end

[saveDir, saveName] = fileparts(get(handles.sleepstats_save_string, 'String'));

sleepstats = fun_sleep_statistics(sleepstages, 'SleepOnset', solRule,...
    'Report', {handles.psg.hdr.name, saveDir, saveName});
save(get(handles.sleepstats_save_string, 'String'), 'sleepstats')



% --- Executes on button press in cancel_sleepstats.
function cancel_sleepstats_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_sleepstats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function spec_channel_Callback(hObject, eventdata, handles)
% hObject    handle to spec_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

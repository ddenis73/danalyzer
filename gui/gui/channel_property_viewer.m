function varargout = channel_property_viewer(varargin)
% CHANNEL_PROPERTY_VIEWER MATLAB code for channel_property_viewer.fig
%      CHANNEL_PROPERTY_VIEWER, by itself, creates a new CHANNEL_PROPERTY_VIEWER or raises the existing
%      singleton*.
%
%      H = CHANNEL_PROPERTY_VIEWER returns the handle to a new CHANNEL_PROPERTY_VIEWER or the handle to
%      the existing singleton*.
%
%      CHANNEL_PROPERTY_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNEL_PROPERTY_VIEWER.M with the given input arguments.
%
%      CHANNEL_PROPERTY_VIEWER('Property','Value',...) creates a new CHANNEL_PROPERTY_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channel_property_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channel_property_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channel_property_viewer

% Last Modified by GUIDE v2.5 05-Feb-2020 12:36:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @channel_property_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @channel_property_viewer_OutputFcn, ...
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


% --- Executes just before channel_property_viewer is made visible.
function channel_property_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channel_property_viewer (see VARARGIN)

% Choose default command line output for channel_property_viewer
handles.output = hObject;

h_mainGUI = findobj('Tag', 'main_window');

if ~isempty(h_mainGUI)
    
    g1Data = guidata(h_mainGUI);
    handles.chanProps = g1Data.chanprop;
    clear g1Data
    
    % Plot starting data
    set(handles.output, 'Name', handles.chanProps.chanName);
    
    plot(handles.freq_plot, handles.chanProps.freqs(handles.chanProps.freqIdx), handles.chanProps.psd(handles.chanProps.freqIdx),...
        'LineWidth', 2, 'Color', 'r');
    set(handles.freq_plot,...
        'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all')
    xlabel(handles.freq_plot, 'Frequency (Hz)')
    ylabel(handles.freq_plot, 'PSD (\muV^2/Hz)')
    plot(handles.time_plot, handles.chanProps.times, -handles.chanProps.data, 'LineWidth', 2, 'Color', 'k');
        set(handles.freq_plot,...
        'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all')
    xlabel(handles.time_plot, 'Time (s)')
    ylabel(handles.time_plot, 'Amplitude (\muV)')
    
    set(handles.peak_freq_str, 'String', [num2str(handles.chanProps.peakFreq) ' Hz']);
    set(handles.mean_freq_str, 'String', [num2str(handles.chanProps.mFreq) ' Hz']);
    set(handles.med_freq_str, 'String', [num2str(handles.chanProps.medFreq) ' Hz']);
    set(handles.amp_str, 'String', [num2str(handles.chanProps.amp) ' uV'])
    set(handles.dur_str, 'String', [num2str(handles.chanProps.duration) ' s'])
    
end
    
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes channel_property_viewer wait for user response (see UIRESUME)
% uiwait(handles.chanProps);


% --- Outputs from this function are returned to the command line.
function varargout = channel_property_viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in calc_freq.
function calc_freq_Callback(hObject, eventdata, handles)
% hObject    handle to calc_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calculate PSD

if get(handles.transform_dir, 'Value') == 1

    [handles.chanProps.psd, handles.chanProps.freqs] = pwelch(diff(handles.chanProps.data, 1, 2)', handles.chanProps.srate*0.5, [], [], handles.chanProps.srate);
    
elseif get(handles.transform_log, 'Value') == 1
    [handles.chanProps.psd, handles.chanProps.freqs] = pwelch(handles.chanProps.data, handles.chanProps.srate*0.5, [], [], handles.chanProps.srate);
    handles.chanProps.psd = log(handles.chanProps.psd);
    
elseif get(handles.transform_abs, 'Value') == 1
    [handles.chanProps.psd, handles.chanProps.freqs] = pwelch(handles.chanProps.data, handles.chanProps.srate*0.5, [], [], handles.chanProps.srate);
    
end

% Get the frequency range

handles.chanProps.freqIdx = find(handles.chanProps.freqs >= str2num(get(handles.min_freq, 'String')) & handles.chanProps.freqs <=...
    str2num(get(handles.max_freq, 'String')));

% Calculate summary

[handles.chanProps.psdPks, handles.chanProps.pkLocs] = findpeaks(handles.chanProps.psd(handles.chanProps.freqIdx));
[~, handles.chanProps.peakPeak] = max(handles.chanProps.psdPks);
handles.chanProps.peakFreq = handles.chanProps.freqs(handles.chanProps.pkLocs(handles.chanProps.peakPeak));

% Plot

plot(handles.freq_plot, handles.chanProps.freqs(handles.chanProps.freqIdx), handles.chanProps.psd(handles.chanProps.freqIdx),...
    'LineWidth', 2, 'Color', 'r');
set(handles.freq_plot,...
    'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all')
xlabel(handles.freq_plot, 'Frequency (Hz)')
if get(handles.transform_log, 'Value') == 0
    ylabel(handles.freq_plot, 'PSD (\muV^2/Hz)')
else
    ylabel(handles.freq_plot, 'log PSD (\muV^2/Hz)')
end
set(handles.peak_freq_str, 'String', [num2str(handles.chanProps.peakFreq) ' Hz']);

if get(handles.transform_log, 'Value') == 0
    handles.chanProps.mFreq = meanfreq(handles.chanProps.psd(handles.chanProps.freqIdx), handles.chanProps.freqs(handles.chanProps.freqIdx));
    handles.chanProps.medFreq = medfreq(handles.chanProps.psd(handles.chanProps.freqIdx), handles.chanProps.freqs(handles.chanProps.freqIdx));
    
    set(handles.mean_freq_str, 'String', [num2str(handles.chanProps.mFreq) ' Hz']);
    set(handles.med_freq_str, 'String', [num2str(handles.chanProps.medFreq) ' Hz']);
else
    set(handles.mean_freq_str, 'String', ' - Hz');
    set(handles.med_freq_str, 'String', ' - Hz');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in transform_log.
function transform_log_Callback(hObject, eventdata, handles)
% hObject    handle to transform_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of transform_log


% --- Executes on button press in transform_dir.
function transform_dir_Callback(hObject, eventdata, handles)
% hObject    handle to transform_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of transform_dir


% --- Executes on button press in transform_abs.
function transform_abs_Callback(hObject, eventdata, handles)
% hObject    handle to transform_abs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of transform_abs



function min_freq_Callback(hObject, eventdata, handles)
% hObject    handle to min_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

calc_freq_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of min_freq as text
%        str2double(get(hObject,'String')) returns contents of min_freq as a double


% --- Executes during object creation, after setting all properties.
function min_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_freq_Callback(hObject, eventdata, handles)
% hObject    handle to max_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

calc_freq_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of max_freq as text
%        str2double(get(hObject,'String')) returns contents of max_freq as a double


% --- Executes during object creation, after setting all properties.
function max_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

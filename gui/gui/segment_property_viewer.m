function varargout = segment_property_viewer(varargin)
% SEGMENT_PROPERTY_VIEWER MATLAB code for segment_property_viewer.fig
%      SEGMENT_PROPERTY_VIEWER, by itself, creates a new SEGMENT_PROPERTY_VIEWER or raises the existing
%      singleton*.
%
%      H = SEGMENT_PROPERTY_VIEWER returns the handle to a new SEGMENT_PROPERTY_VIEWER or the handle to
%      the existing singleton*.
%
%      SEGMENT_PROPERTY_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENT_PROPERTY_VIEWER.M with the given input arguments.
%
%      SEGMENT_PROPERTY_VIEWER('Property','Value',...) creates a new SEGMENT_PROPERTY_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segment_property_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segment_property_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segment_property_viewer

% Last Modified by GUIDE v2.5 03-Feb-2020 16:25:26

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
                   'gui_OpeningFcn', @segment_property_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @segment_property_viewer_OutputFcn, ...
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


% --- Executes just before segment_property_viewer is made visible.
function segment_property_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segment_property_viewer (see VARARGIN)

% Choose default command line output for segment_property_viewer
handles.output = hObject;

h_mainGUI = findobj('Tag', 'main_window');

if ~isempty(h_mainGUI)
    
    g1Data = guidata(h_mainGUI);
    handles.segProp = g1Data.segProp;
    clear g1Data
    
    set(handles.topo_plot,'NextPlot','replacechildren');
    
    
%     % Plot starting data
%     %set(handles.output, 'Name', handles.chanProps.chanName);
%         
%     plot(handles.topo_plot, handles.chanProps.freqs(handles.chanProps.freqIdx), handles.chanProps.psd(handles.chanProps.freqIdx),...
%         'LineWidth', 2, 'Color', 'r');
%     set(handles.topo_plot,...
%         'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all')
%     xlabel(handles.topo_plot, 'Frequency (Hz)')
%     ylabel(handles.topo_plot, 'PSD (\muV^2/Hz)')
%     plot(handles.time_plot, handles.chanProps.times, -handles.chanProps.data, 'LineWidth', 2, 'Color', 'k');
%         set(handles.topo_plot,...
%         'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all')
%     xlabel(handles.time_plot, 'Time (s)')
%     ylabel(handles.time_plot, 'Amplitude (\muV)')
%     
%     set(handles.peak_freq_str, 'String', [num2str(handles.chanProps.peakFreq) ' Hz']);
%     set(handles.mean_freq_str, 'String', [num2str(handles.chanProps.mFreq) ' Hz']);
%     set(handles.med_freq_str, 'String', [num2str(handles.chanProps.medFreq) ' Hz']);
%     set(handles.amp_str, 'String', [num2str(handles.chanProps.amp) ' uV'])
%     set(handles.dur_str, 'String', [num2str(handles.chanProps.duration) ' s'])
    
end
    
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segment_property_viewer wait for user response (see UIRESUME)
% uiwait(handles.chanProps);


% --- Outputs from this function are returned to the command line.
function varargout = segment_property_viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in update_plot.
function update_plot_Callback(hObject, eventdata, handles)
% hObject    handle to update_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the topoplot based on either amplitude or frequency

if get(handles.amp_check, 'Value') == 1
    
    axes(handles.topo_plot)
    topoplot(handles.segProp.amp, handles.segProp.chanlocs, 'colormap', colormap('parula'));
    colorbar;
    
elseif get(handles.freq_check, 'Value') == 1
    
    freqIdx = find(handles.segProp.freqs > str2double(get(handles.min_freq, 'String')) &...
        handles.segProp.freqs < str2double(get(handles.max_freq, 'String')));
    
    psdData = mean(handles.segProp.psd(freqIdx, :));
    
    a = topoplot(psdData, handles.segProp.chanlocs, 'colormap', colormap('parula'));
    a.Parent = handles.topo_plot;
    colorbar;
    
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


% --- Executes on button press in freq_check.
function freq_check_Callback(hObject, eventdata, handles)
% hObject    handle to freq_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of freq_check


% --- Executes on button press in amp_check.
function amp_check_Callback(hObject, eventdata, handles)
% hObject    handle to amp_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of amp_check

function [hObject, handles] = dan_plot_psg(hObject, handles)

% This function actually takes care of the plotting of the psg data

plotParam = handles.plotParam;

% Get the sample at the beginning of plot
startTime = (plotParam.currSample - 1) / handles.psg.hdr.srate; % Helps with scrollbar

% Keep the data you are going to plot

if plotParam.currSample + str2double(get(handles.epoch_length, 'String')) *...
        handles.psg.hdr.srate - 1 > handles.psg.hdr.samples
    
    endSample = handles.psg.hdr.samples;
    
else
    endSample = plotParam.currSample + str2double(get(handles.epoch_length, 'String')) *...
        handles.psg.hdr.srate - 1;
end

data2plot = handles.psg.data(:, plotParam.currSample:endSample);

% Prepare selected data for plotting

if ~isempty(data2plot)
    
    % Apply data changes as specified by the montage
    [handles, data2plot, colorOrder] = dan_apply_montage(handles, data2plot);
    
    % Scale the data
    [handles, data2plot] = dan_scale_psg_data(handles, data2plot);
    
    %% Actually make the plot
    
    % Create time vector. Will plot time if NO information about start time
    % (clock time) can be determined)
    timeVec = (0:1:size(data2plot, 2) - 1) / handles.psg.hdr.srate + startTime;
    
    % Keep the starting time-stamp
    startTime = timeVec(1);
    
    % Create tick mark scale
    tickMarks = ((timeVec(1) - 1):5:(timeVec(end)-1));
    numTicks  = length(tickMarks);
    tickDist  = plotParam.epochDuration / numTicks;
    
    % Create a time string vector with clock times.
    
    if ~isempty(handles.psg.hdr.recStart)
        
        timeStr = datestr(handles.psg.hdr.recStart, 'HH:MM:ss');
        timeNum = datenum(timeStr) + (floor(timeVec(1))/86400);
        timeStr = datestr(timeNum, 'HH:MM:ss');
        
        for tick_i = 2:numTicks
            timeStr = [timeStr; datestr(timeNum + (tickDist * (tick_i - 1))...
                /86400, 'HH:MM:ss')];
        end
        
    else
        timeStr = timeVec;
    end
    
    % Write the epoch number to GUI
    set(handles.current_epoch_number, 'String', num2str(plotParam.epochIdx));
        
    % PLOT!!!!
    set(handles.data_axes, 'ColorOrder', colorOrder, 'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all');
    plot(handles.data_axes,timeVec,data2plot','Tag','SignalLines');
    
    % Properly scale the axes
    maxY = str2double(get(handles.scale_value, 'String')) *...
        (size(data2plot, 1) + 0.75);
    
    % Set a bunch of properties
    
    set(handles.data_axes,'XMinorTick','on',...
        'XGrid','on',...
        'XMinorGrid', 'on',...
        'XTickMode','auto',... %round(linspace(start_time,start_time+handles.epoch_duration,5)*10)/10,...
        'XTick', tickMarks+1,...
        'XTickLabel', timeStr,...
        'XLim',[startTime-.01,startTime+str2double(get(handles.epoch_length, 'String'))],...
        'Ylim', [str2double(get(handles.scale_value, 'String'))/4, maxY],...
        'YTick', str2double(get(handles.scale_value, 'String')):str2double(get(handles.scale_value, 'String')):(maxY),...
        'YTickLabel', flip(handles.montage.showChans),...
        'MinorGridLineStyle', '-',...
        'NextPlot','replace',...
        'FontSize',8,...
        'ButtonDownFcn',{@data_axes_ButtonDownFcn,handles});
    
    % Mask bad epochs, channels, and segments, add event markers
    handles = dan_add_markings(handles, timeVec);
    
    children_handles = allchild(handles.data_axes);
    set(children_handles,'HitTest','off');
    
    % Save the YtickLabel to be able to highlight them;
    handles.plotParam.YTickLabels = get(handles.data_axes,'YTickLabel');
end

% --- Executes on mouse press over figure background.
function data_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to main_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[hObject, handles] = dan_edit_data_axes(hObject, handles);
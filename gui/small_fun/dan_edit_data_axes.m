function [hObject, handles] = dan_edit_data_axes(hObject, handles)

% This function controls what happens when the mouse is clicked on the main
% gui window

%% Left click. Add a custom notation

if strcmp(get(handles.main_window , 'SelectionType'), 'normal')
    
    coordinates = get(handles.data_axes,'CurrentPoint');
    
    if ~isempty(handles.psg.events)
        closestInd = abs(handles.psg.events{:,2}-coordinates(1,1));
        indToRemove = find(closestInd < 0.1);
    else
        indToRemove = [];
    end
    
    if ~isempty(indToRemove)
        
        handles.psg.events(indToRemove,:) = [];
        
    elseif isempty(indToRemove)
        
        newNotation = inputdlg({'Event time:', 'Event description:'}, 'Add notation',[1 35], {num2str(coordinates(1,1)), ' '});
        
        if ~isempty(newNotation)
            
            handles.psg.events = [handles.psg.events;...
                table({datestr(datetime(handles.psg.events{1,1}, 'Format', 'HH:mm:ss.SSS') + seconds(str2double(newNotation{1, 1})), 'HH:MM:ss.FFF')},...
                coordinates(1,1), coordinates(1,1)*handles.psg.hdr.srate, {strtrim(newNotation{2,1})},...
                'VariableNames', {'Clock_Time', 'Seconds', 'Samples', 'Event'})];
            handles.psg.events = sortrows(handles.psg.events, 2);
            
            if ismember(lower(newNotation(2,1)), 'lights off') || ismember(lower(newNotation(2,1)), 'lights out')
                handles.psg.stages.hdr.lOut = datestr(datetime(handles.psg.events{1,1}, 'Format', 'HH:mm:ss.SSS') + seconds(str2double(newNotation{1, 1})), 'HH:MM:ss.FFF');
            elseif ismember(lower(newNotation(2,1)), 'lights on')
                handles.psg.stages.hdr.lOn = datestr(datetime(handles.psg.events{1,1}, 'Format', 'HH:mm:ss.SSS') + seconds(str2double(newNotation{1, 1})), 'HH:MM:ss.FFF');
            end

        end
        
    end
    
    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = dan_plot_psg(hObject, handles);
    
%% Right click: fade in/out channel    
elseif strcmp(get(handles.main_window, 'SelectionType'), 'alt')
    
    coordinates         = get(handles.data_axes, 'CurrentPoint');
    [~, closestChanIdx] = min(abs(get(handles.data_axes, 'YTick') - coordinates(1,2)));
    
    dlgList = listdlg('ListString', get(handles.data_axes, 'YTickLabel'),...
        'SelectionMode', 'multiple', 'InitialValue', closestChanIdx);
    axesList = get(handles.data_axes, 'YTickLabel');
    
    for list_i = 1:length(dlgList)
        chanToMark(list_i) = find(strcmp(handles.montage.showChans, axesList{dlgList(list_i)}));
    end
    
    if exist('chanToMark', 'var')
        
        if handles.psg.ar.badchans(chanToMark) == 0
            handles.psg.ar.badchans(chanToMark) = 1;
        elseif handles.psg.ar.badchans(chanToMark) == 1
            handles.psg.ar.badchans(chanToMark) = 0;
        end
        
    end
    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = dan_plot_psg(hObject, handles);
    
elseif strcmp(get(handles.main_window, 'SelectionType'), 'extend')
    
    [hObject, handles] = dan_segment_tool(hObject, handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    [hObject, handles] = dan_plot_psg(hObject, handles);
    
end
    


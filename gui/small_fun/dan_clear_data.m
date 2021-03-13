function [handles, loadData] = dan_clear_data(handles)

if ~isempty(handles.psg.data)
    loadData = questdlg({'Clearing existing data. All unsaved progress will be lost', 'Do you want to continue?'},'Clear','Yes', 'No', 'Yes');
end

if strcmp(loadData, 'Yes')
    
    handles = dan_initialize_struct(handles, 1, 1);
    handles.plotParam = [];
    handles.handCounts = [];

    set(handles.recording_start_time, 'String', '');
    set(handles.lights_out_time, 'String', '');
    set(handles.lights_on_time, 'String', '');
    
    if isfield(handles, 'specData')
        handles.specData = [];
    end
    
        
    cla(handles.data_axes, 'reset')
    cla(handles.hypngram_axes, 'reset')
    
end
    

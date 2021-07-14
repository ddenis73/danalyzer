function handles = dan_update_epoch_info_string(handles)
% Updates the epoch information bar at the bottom of the GUI
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

if handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 0
    set(handles.current_epoch_info, 'String', 'Wake');
    set(handles.mark_wake, 'BackgroundColor', 'm');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
elseif handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 1
    set(handles.current_epoch_info, 'String', 'N1');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'm');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
elseif handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 2
    set(handles.current_epoch_info, 'String', 'N2');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'm');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
elseif handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 3
    set(handles.current_epoch_info, 'String', 'N3');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'm');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
elseif handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 4
    set(handles.current_epoch_info, 'String', 'N4');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'm');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
elseif handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 5
    set(handles.current_epoch_info, 'String', 'REM');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'm');
    set(handles.mark_movement, 'BackgroundColor', 'k');
elseif handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 6
    set(handles.current_epoch_info, 'String', 'Movement');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'm');
elseif handles.psg.stages.s1.stages(handles.plotParam.epochIdx) == 7
    set(handles.current_epoch_info, 'String', 'Unstaged');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
end

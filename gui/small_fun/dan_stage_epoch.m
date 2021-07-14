function handles = dan_stage_epoch(handles, stage)
% Assign a sleep stage to an epoch
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
% Get the current epoch number

epochIdx = str2double(get(handles.current_epoch_number, 'String'));

% Set sleep stage as a number

if stage == 0
    
    handles.psg.stages.s1.stages(epochIdx) = 0;
    
    set(handles.current_epoch_info, 'String', 'Wake');
    set(handles.mark_wake, 'BackgroundColor', 'm');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
    
elseif stage == 1
    
    handles.psg.stages.s1.stages(epochIdx) = 1;
    
    set(handles.current_epoch_info, 'String', 'Stage 1');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'm');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
    
elseif stage == 2
    
    handles.psg.stages.s1.stages(epochIdx) = 2;
    
    set(handles.current_epoch_info, 'String', 'Stage 2');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'm');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
    
elseif stage == 3
    
    handles.psg.stages.s1.stages(epochIdx) = 3;
    
    set(handles.current_epoch_info, 'String', 'Stage 3');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'm');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
    
elseif stage == 4
    
    handles.psg.stages.s1.stages(epochIdx) = 4;
    
    set(handles.current_epoch_info, 'String', 'Stage 4');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'm');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'k');
    
elseif stage == 5
    
    handles.psg.stages.s1.stages(epochIdx) = 5;
    
    set(handles.current_epoch_info, 'String', 'REM');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'm');
    set(handles.mark_movement, 'BackgroundColor', 'k');
    
elseif stage == 6
    
    handles.psg.stages.s1.stages(epochIdx) = 6;
    
    set(handles.current_epoch_info, 'String', 'Movement');
    set(handles.mark_wake, 'BackgroundColor', 'k');
    set(handles.mark_N1, 'BackgroundColor', 'k');
    set(handles.mark_N2, 'BackgroundColor', 'k');
    set(handles.mark_N3, 'BackgroundColor', 'k');
    set(handles.mark_N4, 'BackgroundColor', 'k');
    set(handles.mark_REM, 'BackgroundColor', 'k');
    set(handles.mark_movement, 'BackgroundColor', 'm');
    
end
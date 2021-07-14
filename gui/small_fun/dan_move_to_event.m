function [hObject, handles] = dan_move_to_event(hObject, handles)
% Jump to a specific event in the data
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

if ~isempty(handles.psg.events)
    listIdx = listdlg('ListString', handles.psg.events{:,4},'SelectionMode', 'single');
    eventSample = handles.psg.events{listIdx, 3};
    
    epochToGoTo = find(handles.plotParam.epochSample(:,1) < eventSample &...
        handles.plotParam.epochSample(:,2) > eventSample);
    
    if ~isempty(epochToGoTo)
        % Update epoch index
        handles.plotParam.epochIdx = epochToGoTo;
        handles.plotParam.currSample = (epochToGoTo-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;
        
        % Replot data
        [hObject, handles] = dan_plot_psg(hObject, handles);
        
        % Update hypnogram
        
        [hObject, handles] = dan_plot_hypno(hObject, handles);
        
        % Update sleep stage
        
        epochIdx = str2double(get(handles.current_epoch_number, 'String'));
        
        sleepStage = handles.psg.stages.s1.stages(epochIdx);
        
        if sleepStage == 0
            set(handles.current_epoch_info, 'String', 'Wake');
        elseif sleepStage == 1
            set(handles.current_epoch_info, 'String', 'N1');
        elseif sleepStage == 2
            set(handles.current_epoch_info, 'String', 'N2');
        elseif sleepStage == 3
            set(handles.current_epoch_info, 'String', 'N3');
        elseif sleepStage == 4
            set(handles.current_epoch_info, 'String', 'N4');
        elseif sleepStage == 5
            set(handles.current_epoch_info, 'String', 'REM');
        elseif sleepStage == 6
            set(handles.current_epoch_info, 'String', 'Movement');
        elseif sleepStage == 7
            set(handles.current_epoch_info, 'String', 'Unstaged');
        end
        
    end
    
end

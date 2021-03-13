function [hObject, handles] = dan_plot_hypno(hObject, handles)

% How many stage files are loaded

f = fieldnames(handles.psg.stages);
f(cellfun(@isempty, regexp(f, 's\d', 'match'))) = [];

hypnoX = 1:1:length(handles.psg.stages.s1.stages);

%% Add lights out and lights on to the hypnogram
if ~isempty(handles.psg.events)
    
    lOutIdx = find(ismember(lower(handles.psg.events{:,4}), {'lights out', 'lights off'}));
    lOnIdx  = find(ismember(lower(handles.psg.events{:,4}), {'lights on'}));
    
    if ~isempty(lOutIdx)
        [lOutEpoch,~,~] = find(handles.plotParam.epochSample > handles.psg.events{lOutIdx, 3}, 1);
        lOutEpoch = lOutEpoch - 1;
    end
    
    if ~isempty(lOnIdx)
        [lOnEpoch,~,~] = find(handles.plotParam.epochSample < handles.psg.events{lOnIdx, 3}, 1, 'last');
        lOnEpoch = lOnEpoch + 1;
    end
    
end

badEpochs = find(handles.psg.ar.badepochs);


if length(f) == 1 && handles.hypSpec == 1
    
       
    % Plot the hypogram to the top axes
    
    hypnoY = handles.psg.stages.s1.stages;
    hypnoY(handles.psg.stages.s1.stages == 0) = 1;
    hypnoY(handles.psg.stages.s1.stages == 1) = 4;
    hypnoY(handles.psg.stages.s1.stages == 2) = 5;
    hypnoY(handles.psg.stages.s1.stages == 3) = 6;
    hypnoY(handles.psg.stages.s1.stages == 4) = 7;
    hypnoY(handles.psg.stages.s1.stages == 5) = 3;
    hypnoY(handles.psg.stages.s1.stages == 6) = 2;
    hypnoY(handles.psg.stages.s1.stages == 7) = nan;
    hypnoY = hypnoY';
    hypnoC = [0.5 0.2 0
        0.5 0.2 0.5
        1 0 0
        0.1 0.9 1
        0.1 0.6 1
        0.1 0.1 1
        0.1 0 0.6];
    
    %% Plot the hypnogram
    
    scatter(handles.hypngram_axes, hypnoX, hypnoY, 30, hypnoY, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'flat')
    line(handles.hypngram_axes, hypnoX, hypnoY, 'Color','k')
    hold(handles.hypngram_axes, 'on')
    scatter(handles.hypngram_axes, hypnoX(str2double(get(handles.current_epoch_number, 'String'))),...
        hypnoY(str2double(get(handles.current_epoch_number, 'String'))), 20, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm')
    
    if exist('lOutEpoch', 'var')
        line(handles.hypngram_axes, [lOutEpoch lOutEpoch], [0 8], 'Color', [0 1 0 0.3], 'LineWidth', 3)
    end
    if exist('lOnEpoch', 'var')
        line(handles.hypngram_axes, [lOnEpoch lOnEpoch], [0 8], 'Color', [0 1 0 0.3], 'LineWidth', 3)
    end
    
    if ~isempty(badEpochs)
        plot(handles.hypngram_axes, [badEpochs badEpochs], [0 8], 'Color', [1 0 0 0.3], 'LineWidth', 3)
    end
    
    line(handles.hypngram_axes, [str2double(get(handles.current_epoch_number, 'String')) str2double(get(handles.current_epoch_number, 'String'))], [0 8],...
        'Color', [0 0 0 0.3], 'LineWidth', 3)
    hold(handles.hypngram_axes, 'off')
    yticks(handles.hypngram_axes,[1 2 3 4 5 6 7]);
    xticks(handles.hypngram_axes,[1:10:length(handles.psg.stages.s1.stages)])
    ylim(handles.hypngram_axes,[0 8]);
    xlim(handles.hypngram_axes,[1 length(handles.psg.stages.s1.stages)]);
    set(handles.hypngram_axes,'yticklabels', {'W', 'MVT', 'REM', 'N1', 'N2', 'N3', 'N4'},...
        'XGrid', 'on', 'YGrid', 'on', 'TickLength', [0 0],'NextPlot','replacechildren',...
        'ButtonDownFcn',{@hypngram_axes_ButtonDownFcn,handles});
    handles.hypngram_axes.YDir = 'reverse';
    colormap(hypnoC)
    
    if ~isempty(get(handles.recording_start_time, 'String'))
        % Create time vector
        tickMarks = hypnoX(1):60:hypnoX(end);
        numTicks = length(tickMarks);
        
        timeStr = {datestr(get(handles.recording_start_time, 'String'), 'HH:MM:SS')};
        
        for t = 2:numTicks
            timeStr = [timeStr; datestr(datenum(timeStr{t-1}) + minutes(30), 'HH:MM:SS')];
        end
        
        set(handles.hypngram_axes, 'XTick', tickMarks+1,...
            'XTickLabel', timeStr)
    end

elseif length(f) > 1 && handles.hypSpec == 1
        
    for i = 1:length(f)
        
        hypnoY(:, i) = handles.psg.stages.(f{i}).stages;
        hypnoY(handles.psg.stages.(f{i}).stages == 0, i) = 1;
        hypnoY(handles.psg.stages.(f{i}).stages == 1, i) = 4;
        hypnoY(handles.psg.stages.(f{i}).stages == 2, i) = 5;
        hypnoY(handles.psg.stages.(f{i}).stages == 3, i) = 6;
        hypnoY(handles.psg.stages.(f{i}).stages == 4, i) = 7;
        hypnoY(handles.psg.stages.(f{i}).stages == 5, i) = 3;
        hypnoY(handles.psg.stages.(f{i}).stages == 6, i) = 2;
        hypnoY(handles.psg.stages.(f{i}).stages == 7, i) = nan;
    end
    hypnoY = hypnoY';
        hypnoC = [0.5 0.2 0
        0.5 0.2 0.5
        1 0 0
        0.1 0.9 1
        0.1 0.6 1
        0.1 0.1 1
        0.1 0 0.6];
    
    % Work out differences between scores
    
    c = {'k' 'r' 'b' 'g' 'y' 'm' 'c'};
    
    scatter(handles.hypngram_axes, hypnoX, hypnoY(end,:), 30, hypnoY(end,:), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', c{size(hypnoY, 1)},...
        'MarkerFaceAlpha', 0.3)
    line(handles.hypngram_axes, hypnoX, hypnoY, 'Color','k')
    hold(handles.hypngram_axes, 'on')
    
    for i = size(hypnoY, 1)-1:-1:1
        scatter(handles.hypngram_axes, hypnoX, hypnoY(i,:), 30, hypnoY(i,:), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', c{i},...
            'MarkerFaceAlpha', 0.3)
    end

    
    scatter(handles.hypngram_axes, hypnoX(str2double(get(handles.current_epoch_number, 'String'))),...
        hypnoY(1, str2double(get(handles.current_epoch_number, 'String'))), 20, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm')
    
    if exist('lOutEpoch', 'var')
        line(handles.hypngram_axes, [lOutEpoch lOutEpoch], [0 8], 'Color', [0 1 0 0.3], 'LineWidth', 3)
    end
    if exist('lOnEpoch', 'var')
        line(handles.hypngram_axes, [lOnEpoch lOnEpoch], [0 8], 'Color', [0 1 0 0.3], 'LineWidth', 3)
    end
    
    if ~isempty(badEpochs)
        plot(handles.hypngram_axes, [badEpochs badEpochs], [0 8], 'Color', [1 0 0 0.3], 'LineWidth', 3)
    end
    
    line(handles.hypngram_axes, [str2double(get(handles.current_epoch_number, 'String')) str2double(get(handles.current_epoch_number, 'String'))], [0 8],...
        'Color', [0 0 0 0.3], 'LineWidth', 3)
    hold(handles.hypngram_axes, 'off')
    yticks(handles.hypngram_axes,[1 2 3 4 5 6 7]);
    xticks(handles.hypngram_axes,[1:10:length(handles.psg.stages.s1.stages)])
    ylim(handles.hypngram_axes,[0 8]);
    xlim(handles.hypngram_axes,[1 length(handles.psg.stages.s1.stages)]);
    set(handles.hypngram_axes,'yticklabels', {'W', 'MVT', 'REM', 'N1', 'N2', 'N3', 'N4'},...
        'XGrid', 'on', 'YGrid', 'on', 'TickLength', [0 0],'NextPlot','replacechildren',...
        'ButtonDownFcn',{@hypngram_axes_ButtonDownFcn,handles});
    handles.hypngram_axes.YDir = 'reverse';
    colormap(hypnoC)
    
    if ~isempty(get(handles.recording_start_time, 'String'))
        % Create time vector
        tickMarks = hypnoX(1):60:hypnoX(end);
        numTicks = length(tickMarks);
        
        timeStr = {datestr(get(handles.recording_start_time, 'String'), 'HH:MM:SS')};
        
        for t = 2:numTicks
            timeStr = [timeStr; datestr(datenum(timeStr{t-1}) + minutes(30), 'HH:MM:SS')];
        end
        
        set(handles.hypngram_axes, 'XTick', tickMarks+1,...
            'XTickLabel', timeStr)
    end
    
    

elseif handles.hypSpec == 2 && ~isempty(handles.psg.stages.spectogram.specto)
    
    Flims = [0 25];
    freqs = handles.psg.stages.spectogram.freqs;
    spectoPSD = handles.psg.stages.spectogram.specto;
    spectoY = freqs(min(find(freqs>=Flims(1))):max(find(freqs<=Flims(2))));
    %     [0+(scaleFactor/handles.psg.hdr.srate)/60:(scaleFactor/handles.psg.hdr.srate)/60:size(spectoPSD,1)*scaleFactor/handles.psg.hdr.srate/60]./60, ...
    %         freqs(min(find(freqs>=Flims(1))):max(find(freqs<=Flims(2))))

    imagesc(handles.hypngram_axes, hypnoX, freqs,...
        spectoPSD');
    set(handles.hypngram_axes,'YDir','normal');
    colormap(handles.hypngram_axes, hot);
    caxis(handles.hypngram_axes, [0 1])
    xlim(handles.hypngram_axes,[1 length(handles.psg.stages.s1.stages)])
    ylim(handles.hypngram_axes, [0 25])
    set(handles.hypngram_axes,...
        'XGrid', 'off', 'YGrid', 'on', 'TickLength', [0 0],'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all',...
        'ButtonDownFcn',{@hypngram_axes_ButtonDownFcn,handles});

    
    hold(handles.hypngram_axes, 'on')
    if exist('lOutEpoch', 'var')
        line(handles.hypngram_axes, [lOutEpoch lOutEpoch], [spectoY(1) spectoY(end)], 'Color', 'm', 'LineWidth', 3)
    end
    if exist('lOnEpoch', 'var')
        line(handles.hypngram_axes, [lOnEpoch lOnEpoch], [spectoY(1) spectoY(end)], 'Color', 'm', 'LineWidth', 3)
    end
    
    if ~isempty(badEpochs)
        plot(handles.hypngram_axes, [badEpochs badEpochs], [spectoY(1) spectoY(end)], 'Color', [.5 0 .5 1], 'LineWidth', 3)
    end
    
    line(handles.hypngram_axes, [str2double(get(handles.current_epoch_number, 'String')) str2double(get(handles.current_epoch_number, 'String'))], [spectoY(1) spectoY(end)],...
        'Color', [0 0 0 1], 'LineWidth', 3)
    hold(handles.hypngram_axes, 'off')
    
    if ~isempty(get(handles.recording_start_time, 'String'))
        % Create time vector
        tickMarks = hypnoX(1):60:hypnoX(end);
        numTicks = length(tickMarks);
        
        timeStr = {datestr(get(handles.recording_start_time, 'String'), 'HH:MM:SS')};
        
        for t = 2:numTicks
            timeStr = [timeStr; datestr(datenum(timeStr{t-1}) + minutes(30), 'HH:MM:SS')];
        end
        
        set(handles.hypngram_axes, 'XTick', tickMarks+1,...
            'XTickLabel', timeStr)
    end
    
end

%%
% --- Executes on mouse press over figure background.
function hypngram_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to main_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.main_window , 'SelectionType'), 'normal')
    
    coordinates = get(handles.hypngram_axes,'CurrentPoint');
    
    epochToMoveTo = floor(coordinates(1,1));
    
    % Update epoch index
    handles.plotParam.epochIdx = epochToMoveTo;
    handles.plotParam.currSample = (handles.plotParam.epochIdx-1)*handles.plotParam.epochDuration*handles.psg.hdr.srate + 1;
        
    % Replot data
    [hObject, handles] = dan_plot_psg(hObject, handles);
    
    % Update hypnogram
    
    [hObject, handles] = dan_plot_hypno(hObject, handles);
    
    handles = dan_update_epoch_info_string(handles);
    
    % Update handle structure
    guidata(hObject,handles);
end


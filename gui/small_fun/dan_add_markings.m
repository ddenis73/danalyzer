function handles = dan_add_markings(handles, timeVec)
%
% Dump all the extra crap onto the screen such as bad epoch markings,
% notations, segments blah blah blah

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

%% Mark bad epochs

epochIdx = str2double(get(handles.current_epoch_number, 'String'));

if handles.psg.ar.badepochs(epochIdx) == 1
    set(handles.data_axes, 'Color', [1 0 0 0.1]);
elseif handles.psg.ar.badepochs(epochIdx) == 0
    set(handles.data_axes, 'Color', [1 1 1 1]);
end

%% Mark segments

if ~isempty(handles.psg.ar.badsegments)
    
    segIdx = find(handles.psg.ar.badsegments(:,7) >=...
        handles.plotParam.epochSample(handles.plotParam.epochIdx, 1) &...
        handles.psg.ar.badsegments(:,8) <= handles.plotParam.epochSample(handles.plotParam.epochIdx, 2));
    
    if ~isempty(segIdx)
        
        for i = 1:length(segIdx)
            
            if handles.psg.ar.badsegments(segIdx(i), 3) == 1
                segColor = [0 1 1 0.3];
            elseif handles.psg.ar.badsegments(segIdx(i), 3) == 2
                segColor = [1 0 1 0.3];
            elseif handles.psg.ar.badsegments(segIdx(i), 3) == 3
                segColor = [1 1 0 0.3];
            end
            
            rectangle(handles.data_axes, 'Position', [handles.psg.ar.badsegments(segIdx(i),4) handles.data_axes.YLim(1)...
                handles.psg.ar.badsegments(segIdx(i),5) - handles.psg.ar.badsegments(segIdx(i),4) handles.data_axes.YLim(2)],...
                'FaceColor', segColor, 'EdgeColor', 'none', 'Tag', 'Segment');
        end
    end
    
end

%% Mark hand scored events (spindles etc.)

if ~all([handles.detections.d1.count] == 0)
    
    for i = 1:length(handles.detections.d1)
        eventIdx{i,:} = find([handles.detections.d1(i).startSample] >= handles.plotParam.epochSample(handles.plotParam.epochIdx,1) &...
            [handles.detections.d1(i).startSample] <= handles.plotParam.epochSample(handles.plotParam.epochIdx,2));
    end
    
    if any(~cellfun(@isempty, eventIdx))
        
        % Find the non-empty channels
        
        chanIdx = find(~cellfun(@isempty, eventIdx));
        
        for i = 1:length(chanIdx)
            axisIdx = find(ismember(handles.data_axes.YTickLabel, {handles.detections.d1(chanIdx(i)).label}));

            chanLims = [handles.data_axes.YTick(axisIdx-1) handles.data_axes.YTick(axisIdx) handles.data_axes.YTick(axisIdx+1)];
            
            for j = 1:length(eventIdx{chanIdx(i)})
                rectangle(handles.data_axes, 'Position', [handles.detections.d1(chanIdx(i)).startSample(eventIdx{chanIdx(i)}(j)) / handles.psg.hdr.srate...
                    chanLims(2) - (chanLims(2) - chanLims(1))/3 ...
                    (handles.detections.d1(chanIdx(i)).endSample(eventIdx{chanIdx(i)}(j)) / handles.psg.hdr.srate) - (handles.detections.d1(chanIdx(i)).startSample(eventIdx{chanIdx(i)}(j)) / handles.psg.hdr.srate) ...
                    (chanLims(2) - chanLims(1))/1.5], 'FaceColor', [0.4940 0.1840 0.5560 0.3], 'EdgeColor', 'none', 'Tag', 'Spindle');
            end
        end
    end
end

%% Fade out any bad channels

% Find all line objects (removes stuff like potential segment marks)
lineIdx = findobj(handles.data_axes.Children, 'Type', 'Line');

% Find the labels first
chanLabels = {handles.psg.chans.labels};
chanLabels = chanLabels(find(handles.psg.ar.badchans));

for chan_i = 1:length(chanLabels)
    
    plotLabelIdx = find(strcmp(get(handles.data_axes, 'YTickLabel'), chanLabels(chan_i)));
    
    getCols = get(lineIdx(plotLabelIdx), 'Color');    
    set(lineIdx(plotLabelIdx), 'Color', [getCols 0.1])
    
end

%% Add events

if ~isempty(handles.psg.events)
    
    eventIdx = find(handles.psg.events{:,3} >= handles.plotParam.epochSample(handles.plotParam.epochIdx,1) &...
        handles.psg.events{:,3} <= handles.plotParam.epochSample(handles.plotParam.epochIdx,2));
    
    if ~isempty(eventIdx)
        
        for i = 1:length(eventIdx)
            
            if strcmpi(handles.psg.events{eventIdx(i), 4}, 'lights off') || strcmpi(handles.psg.events{eventIdx(i), 4}, 'lights out') || strcmpi(handles.psg.events{eventIdx(i), 4}, 'lights on')
                line(handles.data_axes, [handles.psg.events{eventIdx(i), 2} handles.psg.events{eventIdx(i), 2}], get(handles.data_axes, 'YLim'), 'LineWidth', 5,...
                    'Color', [0 1 0 0.3])
                text(handles.data_axes, handles.psg.events{eventIdx(i), 2},max(get(handles.data_axes, 'YLim')),handles.psg.events{eventIdx(i), 4})
                
            else
                line(handles.data_axes, [handles.psg.events{eventIdx(i), 2} handles.psg.events{eventIdx(i), 2}], get(handles.data_axes, 'YLim'), 'LineWidth', 5,...
                    'Color', [1 1 0 0.3])
                text(handles.data_axes, handles.psg.events{eventIdx(i), 2},max(get(handles.data_axes, 'YLim')),handles.psg.events{eventIdx(i), 4})
            end
        end
    end
end

%% Add scale lines

if ~isempty(handles.montage.scaleLine)
    hold(handles.data_axes, 'on')
    
    for line_i = 1:length(handles.montage.scaleLinePos)
        plot(handles.data_axes,timeVec, repmat((handles.data_axes.YTick(not(cellfun('isempty', strfind(handles.data_axes.YTickLabel, handles.montage.scaleLine{1, 1}))))...
            + handles.montage.scaleLinePos), 1, length(timeVec)), 'Color', handles.montage.scaleLineColor, 'LineStyle', handles.montage.scaleLineType);
    end
    hold(handles.data_axes, 'off')
end

%% Add detected events

detectFields = fieldnames(handles.detections);

if length(detectFields) > 1
    
    displayColors = [1 0 0 0.3; 0 1 0 0.3; 0 0 1 0.3; 1 1 0 0.3; 1 1 0 0.3; 0 1 1 0.3];
    
    for i = 2:length(detectFields)
        
        handles = dan_plot_detections(handles, handles.detections.(detectFields{i}), displayColors(i-1,:));
        
    end
    
end

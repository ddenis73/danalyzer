function [hObject, handles] = plotsegment(hObject, handles)

% set(handles.operationDetails,'String','Plotting data in the main axes...');pause(.001)

% Get time of current sample (= sample at the beginning of the plot)
start_time = (handles.plotParam.curr_sample-1)/handles.EEG.srate; % takes care of arbitrary jumps in signal plot (scrollbar)

%% This section deals with finding channel names. Not neccessary here as we are going straight in with the the EEGLAB struct EEG.chanlocs

% %% Find the selected channels inside the header
% [~,~,handles.channel_idx] = intersect(handles.channel_names,handles.hdr.info.ch_names,'stable');
% %% Find the type of the channels
% handles.channel_type = handles.hdr.info.ch_type(handles.channel_idx);
%
% %% Keep only the channels that have the right name
% % (case you can't find some ie user has put some wrong names into the montage file)
% handles.channel_names = handles.hdr.info.ch_names(handles.channel_idx)';
% % [handles.channel.names,~,~] = intersect(handles.channel_names,handles.hdr.info.ch_names(handles.channel_idx)','stable');

%% Keep the data you gonna plot


if handles.plotparam.curr_sample+str2double(get(handles.epoch_length, 'String'))*handles.EEG.srate-1 > size(handles.EEG.data,2)
    end_sample = size(handles.EEG.data,2);
else
    end_sample = handles.plotparam.curr_sample+str2double(get(handles.epoch_length, 'String'))*handles.EEG.srate-1;
end

data2plot = handles.EEG.data(:,handles.plotparam.curr_sample:end_sample);

%% Remove DC
%if handles.dcOffset.Value == 1
%    data2plot = data2plot - mean(data2plot,2)*ones(1,size(data2plot,2));
%end

if ~isempty(data2plot)
    
    [handles, data2plot] = selectdata(handles, data2plot);
    
    %% Re-reference Data
    
    if isfield(handles.currentMontageSettings, 'reref')
        
        %if ~isempty(handles.currentMontageSettings.reref)
            
            [handles, data2plot] = rerefdata(handles,data2plot);
            
        %end
        
    end
    
    %% Filter Data
    
    if isfield(handles.currentMontageSettings, 'filters') || isfield(handles.currentMontageSettings, 'notch')
        
        %if ~isempty(handles.currentMontageSettings.filters) || ~isempty(handles.currentMontageSettings.notch)
            
            [handles, data2plot] = filterdata(handles,data2plot);
            
        %end
        
    end
    
    if isfield(handles, 'chanPropNew')
        handles = rmfield(handles, 'chanPropNew');
    end
    
    
    %% Scales Data
    
    [handles, data2plot] = scaledata(handles,data2plot);
    
    %% Trick to add all traces in the same plot
    
    % Create time vector
    time_vec = (0:1:size(data2plot,2)-1)/handles.EEG.srate + start_time;
    
    % Keep starting time-stamp of the plot
    handles.start_time = time_vec(1);
    
    tickMarks = ((time_vec(1)-1):5:(time_vec(end)-1));
    numTicks = length(tickMarks);
    distanceTicks = handles.plotparam.epoch_duration/numTicks;
    
    if ~isempty(get(handles.recording_start_time, 'String'))
        
        rStart = datenum(get(handles.recording_start_time, 'String')) + (floor(time_vec(1))/86400);
        
        time_str = {datestr(rStart, 'HH:MM:SS')};
        
        for t = 2:numTicks
            time_str = [time_str; datestr(rStart + (distanceTicks*(t-1))/86400, 'HH:MM:SS')];
        end
        
    end
        
    
    % Fix ColorOrder
    
    colorOrder = zeros(size(data2plot,1),3);
    
    if isfield(handles, 'currentMontageSettings')
        
        if ~isempty(handles.currentMontageSettings)
            
            colorOrder(handles.plotparam.eeg_idx,:) = ones(length(handles.plotparam.eeg_idx),1)*handles.currentMontageSettings.colors{1, 1}; % EEG
            colorOrder(handles.plotparam.eog_idx,:) = ones(length(handles.plotparam.eog_idx),1)*handles.currentMontageSettings.colors{2, 1}; % EEG
            colorOrder(handles.plotparam.emg_idx,:) = ones(length(handles.plotparam.emg_idx),1)*handles.currentMontageSettings.colors{3, 1}; % EEG
            colorOrder(handles.plotparam.ecg_idx,:) = ones(length(handles.plotparam.ecg_idx),1)*handles.currentMontageSettings.colors{4, 1}; % EEG
            colorOrder(handles.plotparam.other_idx,:) = ones(length(handles.plotparam.other_idx),1)*handles.currentMontageSettings.colors{5, 1}; % EEG
            
        end
        
    end
    
    % Change bad channel color
    
    %colorOrder(handles.plotparam.eeg_idx,:)    = ones(length(handles.plotparam.eeg_idx),1)*handles.eegColor.BackgroundColor;    % EEG: black
    %colorOrder(handles.plotparam.eog_idx,:)    = ones(length(handles.plotparam.eog_idx),1)*handles.eogColor.BackgroundColor;    % EOG: blue
    %colorOrder(handles.plotparam.emg_idx,:)    = ones(length(handles.plotparam.emg_idx),1)*handles.emgColor.BackgroundColor;    % EMG: red
    %colorOrder(handles.plotparam.ecg_idx,:)    = ones(length(handles.plotparam.ecg_idx),1)*handles.ecgColor.BackgroundColor;    % ECG: purple
    %colorOrder(handles.plotparam.other_idx,:)   = ones(length(handles.plotparam.other_idx),1)*handles.otherColor.BackgroundColor;  % Other: orange
    
    
    % May want to add bad/unknown channel markers later
    %     ColorOrder(handles.bads_idx,:)   = ones(length(handles.bads_idx),1)*[.8 .8 .8];   % bads: light grey
    %     ColorOrder(handles.uknown_idx,:) = ones(length(handles.uknown_idx),1)*[.5 .5 .5]; % uknown: dark grey
    
    
    % Write the # Epoch on the text above the axes
    set(handles.current_epoch_number, 'String', num2str(handles.plotparam.epoch_idx));
    
    % Change background if artifact has been marked
    
    epochIdx = str2double(get(handles.current_epoch_number, 'String'));
    
    if handles.rejinfo.badepochs(epochIdx) == 1
        plotBackgroundColor = [1 0 0 0.1];
    elseif handles.rejinfo.badepochs(epochIdx) == 0
        plotBackgroundColor = [1 1 1 1];
    end
    
    
    set(handles.data_axes, 'ColorOrder', colorOrder, 'NextPlot','replacechildren', 'HitTest', 'on', 'PickableParts', 'all');
    plot(handles.data_axes,time_vec,data2plot(1:length(handles.plotparam.chanstoplot),:)','Tag','SignalLines');
    
else % Case data2plot is empty
    plot(handles.data_axes,[0 0], [0 0] )
    error('No data found!')
    %set(handles.operationDetails,'String','No data found!');pause(.001)
end

% Scale properly the axes
maxY = str2double(get(handles.scale_value, 'String'))*(size(data2plot(1:length(handles.plotparam.chanstoplot),:),1) + .75);

if ~isempty(get(handles.recording_start_time, 'String'))

set(handles.data_axes,'XMinorTick','on',...
    'XGrid','on',...
    'XMinorGrid', 'on',...
    'XTickMode','auto',... %round(linspace(start_time,start_time+handles.epoch_duration,5)*10)/10,...
    'XTick', tickMarks+1,...
    'XTickLabel', time_str,...
    'XLim',[start_time-.01,start_time+str2double(get(handles.epoch_length, 'String'))],...
    'Ylim', [str2double(get(handles.scale_value, 'String'))/4, maxY],...
    'YTick', str2double(get(handles.scale_value, 'String')):str2double(get(handles.scale_value, 'String')):(maxY),...
    'YTickLabel', fliplr({handles.plotparam.chanstoplot.labels}),...
    'MinorGridLineStyle', '-',...
    'NextPlot','replace',...
    'FontSize',8,...
    'Color', plotBackgroundColor,...
    'ButtonDownFcn',{@data_axes_ButtonDownFcn,handles});

else
    
    set(handles.data_axes,'XMinorTick','on',...
    'XGrid','on',...
    'XMinorGrid', 'on',...
    'XTickMode','auto',... %round(linspace(start_time,start_time+handles.epoch_duration,5)*10)/10,...
    'XTick', tickMarks+1,...
    'XLim',[start_time-.01,start_time+str2double(get(handles.epoch_length, 'String'))],...
    'Ylim', [str2double(get(handles.scale_value, 'String'))/4, maxY],...
    'YTick', str2double(get(handles.scale_value, 'String')):str2double(get(handles.scale_value, 'String')):(maxY),...
    'YTickLabel', fliplr({handles.plotparam.chanstoplot.labels}),...
    'MinorGridLineStyle', '-',...
    'NextPlot','replace',...
    'FontSize',8,...
    'Color', plotBackgroundColor,...
    'ButtonDownFcn',{@data_axes_ButtonDownFcn,handles});

end
% Fade out bad channels

badChannelIdx = find(handles.rejinfo.badchans);

for chan_i = 1:length(badChannelIdx)
    
    badChannelLabel = handles.plotparam.chanstoplot(badChannelIdx(chan_i)).labels;
    plotLabelIdx = find(strcmp(get(handles.data_axes, 'YTickLabel'), badChannelLabel));
    getCols = get(handles.data_axes.Children(plotLabelIdx), 'Color');
    set(handles.data_axes.Children(plotLabelIdx), 'Color', [getCols 0.1])
    
end

% Add any marked segments

if ~isempty(handles.rejinfo.badsegments)
    
    arousalIdx = find(handles.rejinfo.badsegments(:,6) >= handles.plotparam.epoch_sample(handles.plotparam.epoch_idx,1) &...
        handles.rejinfo.badsegments(:,7) <= handles.plotparam.epoch_sample(handles.plotparam.epoch_idx,2));
    
    if ~isempty(arousalIdx)
        
        for i = 1:length(arousalIdx)
            rectangle(handles.data_axes, 'Position', [handles.rejinfo.badsegments(arousalIdx(i),3) handles.data_axes.YLim(1)...
                handles.rejinfo.badsegments(arousalIdx(i),4) - handles.rejinfo.badsegments(arousalIdx(i),3) handles.data_axes.YLim(2)],...
                'FaceColor', [0 1 1 0.3], 'EdgeColor', 'none', 'Tag', 'Arousal');
            
        end
    end
    
end

% Add any hand counted spindles

if handles.segmentFunction == 2
    
    if ~isempty(handles.specdata.handspindles)
        
        spindleIdx = find([handles.specdata.handspindles.startsample] >= handles.plotparam.epoch_sample(handles.plotparam.epoch_idx,1) &...
            [handles.specdata.handspindles.endsample] <= handles.plotparam.epoch_sample(handles.plotparam.epoch_idx,2));
        
        if ~isempty(spindleIdx)
            
            chanList = {handles.specdata.handspindles.channel};
            chanList = chanList(spindleIdx);
            
            for i = 1:length(spindleIdx)
                
                chanIdx = find(strcmp(handles.data_axes.YTickLabel, chanList{i}));
                
                chanLims = [handles.data_axes.YTick(chanIdx-1) handles.data_axes.YTick(chanIdx) handles.data_axes.YTick(chanIdx+1)];
                
                rectangle(handles.data_axes, 'Position', [handles.specdata.handspindles(spindleIdx(i)).starttime...
                    chanLims(2) - (chanLims(2) - chanLims(1))/3 ...
                    handles.specdata.handspindles(spindleIdx(i)).endtime - handles.specdata.handspindles(spindleIdx(i)).starttime ...
                    (chanLims(2) - chanLims(1))/1.5 ], 'FaceColor', [0 1 1 0.3], 'EdgeColor', 'none', 'Tag', 'Spindle');
                
            end
            
        end
        
    end
    
end
            
% Plot any notations

if ~isempty(handles.notations.times)
    
    notationIdx = find(handles.notations.times(:,2) >= handles.plotparam.epoch_sample(handles.plotparam.epoch_idx,1) &...
        handles.notations.times(:,2) <= handles.plotparam.epoch_sample(handles.plotparam.epoch_idx,2));
    
    if ~isempty(notationIdx)
        
        for i = 1:length(notationIdx)
            
            if strcmpi(handles.notations.labels{notationIdx(i)}, 'lights out') || strcmpi(handles.notations.labels{notationIdx(i)}, 'lights on')
                line(handles.data_axes, [handles.notations.times(notationIdx(i)) handles.notations.times(notationIdx(i))], get(handles.data_axes, 'YLim'), 'LineWidth', 5,...
                    'Color', [0 1 0 0.3])
                text(handles.data_axes, handles.notations.times(notationIdx(i)),max(get(handles.data_axes, 'YLim')),handles.notations.labels{notationIdx(i)})
                
                
            else
                line(handles.data_axes, [handles.notations.times(notationIdx(i)) handles.notations.times(notationIdx(i))], get(handles.data_axes, 'YLim'), 'LineWidth', 5,...
                    'Color', [1 1 0 0.3])
                text(handles.data_axes, handles.notations.times(notationIdx(i)),max(get(handles.data_axes, 'YLim')),handles.notations.labels{notationIdx(i)})
                
            end
            
            
        end
        
    end
    
end

if isfield(handles, 'currentMontageSettings')
    
    if ~isempty(handles.currentMontageSettings)
        
        if ~isempty(handles.currentMontageSettings.scaleChans)
                                    
            hold(handles.data_axes, 'on')
            for i = 1:length(handles.currentMontageSettings.scaleLinePositions)
                plot(handles.data_axes,time_vec, repmat((handles.data_axes.YTick(not(cellfun('isempty', strfind(handles.data_axes.YTickLabel, handles.currentMontageSettings.scaleChans{1, 1}))))...
                    + handles.currentMontageSettings.scaleLinePositions), 1, length(time_vec)), '--m')
            end
            hold(handles.data_axes, 'off')
            
        end
        
    end
    
end

children_handles = allchild(handles.data_axes);
set(children_handles,'HitTest','off');

% Save the YtickLabel to be able to highlight them;
handles.plotparam.YTickLabels = get(handles.data_axes,'YTickLabel');


% --- Executes on mouse press over figure background.
function data_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to main_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.main_window , 'SelectionType'), 'normal')
    
    
    coordinates = get(handles.data_axes,'CurrentPoint');
    
    if ~isempty(handles.notations.times)
        
        find(handles.notations.times(:,1) == coordinates(1,1));
        
        closestInd = abs(handles.notations.times(:,1)-coordinates(1,1));
        indToRemove = find(closestInd < 0.1);
        
    else
        indToRemove = [];
    end
    
    if ~isempty(indToRemove)
        
        handles.notations.times(indToRemove,:) = [];
        handles.notations.labels(indToRemove) = [];
        
    elseif isempty(indToRemove)
        
        
        newNotation = inputdlg({'Event time:', 'Event description:'}, 'Add notation',[1 35], {num2str(coordinates(1,1)), ' '});
        if ~isempty(newNotation)
            
            if isempty(handles.notations.times)
                handles.notations.times = [coordinates(1,1) coordinates(1,1)*handles.EEG.srate];
            elseif ~isempty(handles.notations.times)
                handles.notations.times = [handles.notations.times; [coordinates(1,1) coordinates(1,1)*handles.EEG.srate]];
            end
            
            if isempty(handles.notations.labels)
                handles.notations.labels = {newNotation{2,1}};
                strtrim(handles.notations.labels);
            elseif ~isempty(handles.notations.labels)
                handles.notations.labels = [handles.notations.labels; {newNotation{2,1}}];
                strtrim(handles.notations.labels);
            end
            
        end
        
    end
    
    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = plotsegment(hObject, handles);
    
elseif strcmp(get(handles.main_window, 'SelectionType'), 'alt')
    
    coord = get(handles.data_axes, 'CurrentPoint');
    
    [~,closestChanIdx] = min(abs(get(handles.data_axes, 'YTick')-coord(1,2)));
    
    list = listdlg('ListString', get(handles.data_axes, 'YTickLabel'), 'SelectionMode', 'multiple', 'InitialValue', closestChanIdx);
    
    badChan = get(handles.data_axes, 'YTickLabel');
    
    for list_i = 1:length(list)
        chanToMark(list_i) = find(strcmp({handles.plotparam.chanstoplot.labels}, badChan{list(list_i)}));
    end
    
    if exist('chanToMark', 'var')
        
        if handles.rejinfo.badchans(chanToMark) == 0
            handles.rejinfo.badchans(chanToMark) = 1;
        elseif handles.rejinfo.badchans(chanToMark) == 1
            handles.rejinfo.badchans(chanToMark) = 0;
        end
        
    end
    
    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = plotsegment(hObject, handles);
    
    
elseif strcmp(get(handles.main_window, 'SelectionType'), 'extend')
    
    if handles.segmentFunction == 1
    
    [newBadSegmentTime,~] = ginput(2);
    
    segmentSample = newBadSegmentTime*handles.EEG.srate;
    
    if isempty(handles.rejinfo.badsegments)
        
        handles.rejinfo.badsegments = [handles.plotparam.epoch_idx handles.sleepstages(handles.plotparam.epoch_idx)...
            newBadSegmentTime(1) newBadSegmentTime(2) newBadSegmentTime(2) - newBadSegmentTime(1)...
            segmentSample(1) segmentSample(2)];
        
    elseif ~isempty(handles.rejinfo.badsegments)
        
        alreadyMarked = find(handles.rejinfo.badsegments(:,3) <= newBadSegmentTime(1) & handles.rejinfo.badsegments(:,4) >= newBadSegmentTime(2));
        
        if isempty(alreadyMarked)
            handles.rejinfo.badsegments = [handles.rejinfo.badsegments; [handles.plotparam.epoch_idx handles.sleepstages(handles.plotparam.epoch_idx)...
                newBadSegmentTime(1) newBadSegmentTime(2) newBadSegmentTime(2) - newBadSegmentTime(1)...
                segmentSample(1) segmentSample(2)]];
            
        elseif ~isempty(alreadyMarked)
            
            handles.rejinfo.badsegments(alreadyMarked,:) = [];
            
        end
        
    end
    
    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = plotsegment(hObject, handles);
    
    elseif handles.segmentFunction == 2
        
        [segmentTime, segmentChan] = ginput(2);
        segmentSample = segmentTime*handles.EEG.srate;
       
    if isempty(handles.specdata.handspindles)
        
        [~,closestChanIdx] = min(abs(get(handles.data_axes, 'YTick')-segmentChan(1,1)));
        chan = strcmp({handles.EEG.chanlocs.labels},handles.data_axes.YTickLabel{closestChanIdx});
        handles.chanprop.chanName = handles.EEG.chanlocs(chan).labels;
        
        handles.specdata.handspindles = struct('channel', handles.EEG.chanlocs(chan).labels, 'epoch', handles.plotparam.epoch_idx,...
            'stage', handles.sleepstages(handles.plotparam.epoch_idx), 'startsample', segmentSample(1),...
            'endsample', segmentSample(2), 'starttime', segmentTime(1), 'endtime', segmentTime(2),...
            'duration', segmentTime(2) - segmentTime(1));
        
    elseif ~isempty(handles.specdata.handspindles)
        
        alreadyMarked = find([handles.specdata.handspindles.starttime] <= segmentTime(1) & [handles.specdata.handspindles.endtime] >= segmentTime(2));

        if isempty(alreadyMarked)
            
            [~,closestChanIdx] = min(abs(get(handles.data_axes, 'YTick')-segmentChan(1,1)));
            chan = strcmp({handles.EEG.chanlocs.labels},handles.data_axes.YTickLabel{closestChanIdx});
            handles.chanprop.chanName = handles.EEG.chanlocs(chan).labels;
        
            handles.specdata.handspindles = [handles.specdata.handspindles, struct('channel', handles.EEG.chanlocs(chan).labels, 'epoch', handles.plotparam.epoch_idx,...
            'stage', handles.sleepstages(handles.plotparam.epoch_idx), 'startsample', segmentSample(1),...
            'endsample', segmentSample(2), 'starttime', segmentTime(1), 'endtime', segmentTime(2),...
            'duration', segmentTime(2) - segmentTime(1))];
            
            
        elseif ~isempty(alreadyMarked)
            
            handles.specdata.handspindles(:,alreadyMarked) = [];
            
        end
        
    end
    
    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = plotsegment(hObject, handles);
        
    elseif handles.segmentFunction == 3
       
        [segmentTime, segmentChan] = ginput(2);
        
        [~,closestChanIdx] = min(abs(get(handles.data_axes, 'YTick')-segmentChan(1,1)));
        
        a = segmentTime*handles.EEG.srate;
        
        chan = strcmp({handles.EEG.chanlocs.labels},handles.data_axes.YTickLabel{closestChanIdx});
        
        % Everything here is to be piped through to GUI
        handles.chanprop.chanName = handles.EEG.chanlocs(chan).labels;
        handles.chanprop.data = (handles.EEG.data(chan, a(1):a(2)));
        handles.chanprop.times = 0 + (0:length(handles.chanprop.data)-1)*1/handles.EEG.srate;
        [handles.chanprop.psd, handles.chanprop.freqs] = pwelch(diff(handles.chanprop.data, 1, 2)', handles.EEG.srate*0.5, [], [], handles.EEG.srate);
        handles.chanprop.freqIdx = find(handles.chanprop.freqs <= 35);
        handles.chanprop.mFreq = meanfreq(handles.chanprop.psd(handles.chanprop.freqIdx), handles.chanprop.freqs(handles.chanprop.freqIdx));
        handles.chanprop.medFreq = medfreq(handles.chanprop.psd(handles.chanprop.freqIdx), handles.chanprop.freqs(handles.chanprop.freqIdx));
        [handles.chanprop.psdPks, handles.chanprop.pkLocs] = findpeaks(handles.chanprop.psd(handles.chanprop.freqIdx));
        [~, handles.chanprop.peakPeak] = max(handles.chanprop.psdPks);
        handles.chanprop.peakFreq = handles.chanprop.freqs(handles.chanprop.pkLocs(handles.chanprop.peakPeak));
        handles.chanprop.amp = sqrt(mean(handles.chanprop.data.^2));
        handles.chanprop.duration = length(handles.chanprop.data)/handles.EEG.srate;
        handles.chanprop.srate = handles.EEG.srate;
        % Update handle structure
        guidata(hObject,handles);
        
        se_chanPropGUI;

    end
    
    
end


function handles = dan_plot_detections(handles, detections, markColor)

for chan_i = 1:length(detections)
    
    % Look for each detected event in the current epoch
    specIdx{chan_i,:} = find(detections(chan_i).startSample >= handles.plotParam.epochSample(handles.plotParam.epochIdx,1) &...
        detections(chan_i).endSample <= handles.plotParam.epochSample(handles.plotParam.epochIdx,2));
    
    chanName = detections(chan_i).label;
    
    if iscell(chanName)
        chanName = chanName{1};
    end
    
    chanIdx = find(strcmp(handles.data_axes.YTickLabel, chanName));
    
    if ~isempty(chanIdx)
        
        if chanIdx ~= length(handles.data_axes.YTick) && chanIdx ~= 1
            chanLims = [handles.data_axes.YTick(chanIdx-1) handles.data_axes.YTick(chanIdx) handles.data_axes.YTick(chanIdx+1)];
        elseif chanIdx == length(handles.data_axes.YTick)
            chanLims = [handles.data_axes.YTick(chanIdx-1) handles.data_axes.YTick(chanIdx) handles.data_axes.YTick(chanIdx)];
        elseif chanIdx == 1
            chanLims = [handles.data_axes.YTick(chanIdx) handles.data_axes.YTick(chanIdx) handles.data_axes.YTick(chanIdx)];
        end
        
        if ~isempty(specIdx{chan_i})
            
            for event_i = 1:length(specIdx{chan_i})
                
                rectangle(handles.data_axes, 'Position', [(detections(chan_i).startSample(specIdx{chan_i}(event_i)) / handles.psg.hdr.srate)...
                    chanLims(2) - (chanLims(2) - chanLims(1)) / 3 ...
                    (detections(chan_i).endSample(specIdx{chan_i}(event_i)) / handles.psg.hdr.srate) - (detections(chan_i).startSample(specIdx{chan_i}(event_i)) / handles.psg.hdr.srate)...
                    (chanLims(2) - chanLims(1))/1.5], 'FaceColor', markColor, 'EdgeColor', 'none');
            end
        end
    end
end
    
    
    
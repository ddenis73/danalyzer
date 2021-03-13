function [hObject, handles] = dan_segment_tool(hObject, handles)

% Controls the verious options for the plot segment tool

%% Mark arousal/bad segment etc.

if handles.segmentFunction == 1
    
    [newSegTime, ~] = ginput(2);
    newSegSample = newSegTime * handles.psg.hdr.srate;
    
    if isempty(handles.psg.ar.badsegments)
        
        handles.psg.ar.badsegments = [handles.plotParam.epochIdx...
            handles.psg.stages.s1.stages(handles.plotParam.epochIdx)...
            handles.segColor newSegTime(1) newSegTime(2) newSegTime(2) - newSegTime(1)...
            newSegSample(1) newSegSample(2) newSegSample(2) - newSegSample(1)];
    
    elseif ~isempty(handles.psg.ar.badsegments)
        
        alreadyMarked = find(handles.psg.ar.badsegments(:,4)...
            <= newSegTime(1) & handles.psg.ar.badsegments(:,5) >= newSegTime(2));
        
        if isempty(alreadyMarked)
            
            handles.psg.ar.badsegments = [handles.psg.ar.badsegments; handles.plotParam.epochIdx...
                handles.psg.stages.s1.stages(handles.plotParam.epochIdx)...
                handles.segColor newSegTime(1) newSegTime(2) newSegTime(2) - newSegTime(1)...
                newSegSample(1) newSegSample(2) newSegSample(2) - newSegSample(1)];
            
        elseif ~isempty(alreadyMarked)
            
            handles.psg.ar.badsegments(alreadyMarked, :) = [];
            
        end
        
    end

    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = dan_plot_psg(hObject, handles);

elseif handles.segmentFunction == 2
    
    [segmentTime, segmentChan] = ginput(2);
    segmentSample              = segmentTime * handles.psg.hdr.srate;

    [~,closestChanIdx] = min(abs(get(handles.data_axes, 'YTick')-segmentChan(1,1)));
    chanNum = strcmp(handles.montage.showChans,handles.data_axes.YTickLabel{closestChanIdx});
    chanName = handles.montage.showChans{chanNum};

    detectChanIdx = find(strcmp({handles.detections.d1.label}, chanName));
    
    alreadyMarked = find([handles.detections.d1(detectChanIdx).startSample]...
        <= segmentSample(1) & [handles.detections.d1(detectChanIdx).endSample] >= segmentSample(2));
    
    if isempty(alreadyMarked)
        
        handles.detections.d1(detectChanIdx).count = handles.detections.d1(detectChanIdx).count + 1;
        handles.detections.d1(detectChanIdx).sleepstage = [handles.detections.d1(detectChanIdx).sleepstage ...
            handles.psg.stages.s1.stages(handles.plotParam.epochIdx)];
        handles.detections.d1(detectChanIdx).startSample = [handles.detections.d1(detectChanIdx).startSample ...
            segmentSample(1)];
        handles.detections.d1(detectChanIdx).endSample = [handles.detections.d1(detectChanIdx).endSample ...
            segmentSample(2)];
        handles.detections.d1(detectChanIdx).duration = [handles.detections.d1(detectChanIdx).duration ...
            segmentTime(2) - segmentTime(1)];
        
        % Peak frequency
        [p, f] = pwelch(diff(handles.psg.data(chanNum, segmentSample(1):segmentSample(2)))', handles.psg.hdr.srate*0.5, [], [], handles.psg.hdr.srate);
        
        [psdPeak, pkLoc] = findpeaks(p);
        [~, peakPeak] = max(psdPeak);
        
        handles.detections.d1(detectChanIdx).peakFreq = [handles.detections.d1(detectChanIdx).peakFreq ...
            f(pkLoc(peakPeak))];
        
        % Peak amplitude
        ampPeak = findpeaks(handles.psg.data(chanNum, segmentSample(1):segmentSample(2)));
        peakPeak = max(ampPeak);
        
        handles.detections.d1(detectChanIdx).peakAmp = [handles.detections.d1(detectChanIdx).peakAmp ...
            abs(peakPeak)];
        
    elseif ~isempty(alreadyMarked)
        
        handles.detections.d1(detectChanIdx).count = handles.detections.d1(detectChanIdx).count - 1;
        handles.detections.d1(detectChanIdx).sleepstage(alreadyMarked)  = [];
        handles.detections.d1(detectChanIdx).startSample(alreadyMarked) = [];
        handles.detections.d1(detectChanIdx).endSample(alreadyMarked)   = [];
        handles.detections.d1(detectChanIdx).duration(alreadyMarked)    = [];
        handles.detections.d1(detectChanIdx).peakAmp(alreadyMarked)    = [];
        handles.detections.d1(detectChanIdx).peakFreq(alreadyMarked)    = [];

        
    end
    
    % Update handle structure
    guidata(hObject,handles);
    
    [hObject, handles] = dan_plot_psg(hObject, handles);

elseif handles.segmentFunction == 3
    
    [segmentTime, segmentChan] = ginput(2);
    
    [~,closestChanIdx] = min(abs(get(handles.data_axes, 'YTick')-segmentChan(1,1)));
    
    segmentSample = segmentTime*handles.psg.hdr.srate;
    
    chanNum = strcmp(handles.montage.showChans,handles.data_axes.YTickLabel{closestChanIdx});
    
    % Everything here is to be piped through to GUI
    handles.chanprop.chanName = handles.montage.showChans{chanNum};
    handles.chanprop.data = (handles.psg.data(chanNum, segmentSample(1):segmentSample(2)));
    handles.chanprop.times = 0 + (0:length(handles.chanprop.data)-1)*1/handles.psg.hdr.srate;
    [handles.chanprop.psd, handles.chanprop.freqs] = pwelch(diff(handles.chanprop.data, 1, 2)', handles.psg.hdr.srate*0.5, [], [], handles.psg.hdr.srate);
    handles.chanprop.freqIdx = find(handles.chanprop.freqs <= 35);
    handles.chanprop.mFreq = meanfreq(handles.chanprop.psd(handles.chanprop.freqIdx), handles.chanprop.freqs(handles.chanprop.freqIdx));
    handles.chanprop.medFreq = medfreq(handles.chanprop.psd(handles.chanprop.freqIdx), handles.chanprop.freqs(handles.chanprop.freqIdx));
    [handles.chanprop.psdPks, handles.chanprop.pkLocs] = findpeaks(handles.chanprop.psd(handles.chanprop.freqIdx));
    [~, handles.chanprop.peakPeak] = max(handles.chanprop.psdPks);
    handles.chanprop.peakFreq = handles.chanprop.freqs(handles.chanprop.pkLocs(handles.chanprop.peakPeak));
    handles.chanprop.amp = sqrt(mean(handles.chanprop.data.^2));
    handles.chanprop.duration = length(handles.chanprop.data)/handles.psg.hdr.srate;
    handles.chanprop.srate = handles.psg.hdr.srate;
    
    % Update handle structure
    guidata(hObject,handles);
    
    channel_property_viewer;

elseif handles.segmentFunction == 4
    
    [newSegTime, ~] = ginput(2);
    newSegSample = newSegTime * handles.psg.hdr.srate;
    
    % Pipe everything through to the GUI
    handles.segProp.data = handles.psg.data(:, newSegSample(1):newSegSample(2));
    handles.segProp.chanlocs = handles.montage.chanList;
    
    [handles.segProp.psd, handles.segProp.freqs] = pwelch(diff(handles.segProp.data, 1, 2)',...
        handles.psg.hdr.srate*0.5, [], [], handles.psg.hdr.srate);
    
    handles.segProp.amp = sqrt(mean(handles.segProp.data.^2, 2));
    
    % find nonEEG channels
    nonEEG = find(ismember({handles.segProp.chanlocs.type}, {'EOG' 'EMG' 'Other'}));
    badChans = find(handles.psg.ar.badchans)';
    
    % Remove them from data and channels
    handles.segProp.psd(:,[nonEEG badChans]) = [];
    handles.segProp.amp([nonEEG badChans]) = [];
    handles.segProp.chanlocs([nonEEG badChans]) = [];
    
    % Update handle structure
    guidata(hObject,handles);
    
    segment_property_viewer;



    
end


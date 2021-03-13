function [handles, data2plot, colorOrder] = dan_apply_montage(handles, data2plot)

% This function takes care of selecting the write channels to plot, as well
% as applying re-referencing, filtering, and color schemes as specified

montage = handles.montage;

%% Rename detection labels

detectorFields = regexp(fieldnames(handles.detections), 'd\d', 'match');

for i = 1:length(detectorFields)
    
    [handles.detections.(detectorFields{i}{1}).label] = montage.chanList.labels;
    
end



%% Hide specified channels from view

% Find the channel number for the channels to hide

if ~isempty(montage.hideChans)
    chanIdx = ismember({montage.chanList.labels}, montage.hideChans);
    montage.chanList(chanIdx) = [];
    montage.reref(chanIdx) = [];
    montage.filters(chanIdx,:) = [];
    montage.notch(chanIdx) = [];
    data2plot(chanIdx, :) = [];
end

%% Re-arrange channels based on channel order

dataOrdered   = zeros(size(data2plot, 1), length(data2plot));

for chan_i = 1:length(montage.showChans)
    
    if ismember(montage.chanList(chan_i).labels, montage.showChans(chan_i))
        dataOrdered(chan_i, :)   = data2plot(chan_i, :);
    elseif ~ismember(montage.chanList(chan_i).labels, montage.showChans(chan_i))
        dataOrdered(chan_i, :)   = data2plot(ismember({montage.chanList.labels}, montage.showChans(chan_i)), :);
    end
end

data2plot = dataOrdered;
clear dataOrdered

%% Rereference data

chansToReref = find(~cellfun('isempty', montage.reref));

for chan_i = 1:length(chansToReref)
    
    % Find the data of the new reference channel
    newRefName = montage.reref{chansToReref(chan_i)};
    refData    = data2plot(ismember(montage.showChans, newRefName),:);
    data2Ref   = [data2plot(chansToReref(chan_i),:); refData];
    data2Ref   = reref(data2Ref, size(data2Ref, 1));
    data2plot(chansToReref(chan_i), :) = data2Ref;
    
end

clear refData data2Ref

%% Filter data

% Get Nyquist
nyq = handles.psg.hdr.srate/2; % Nyquist Frequency

dataFilt = zeros(size(data2plot, 2), size(data2plot, 1));

% Look for any bandpass filters

chansToFilt = find(any(montage.filters, 2));

for chan_i = 1:size(data2plot, 1)
    
    if find(chan_i == chansToFilt)
        
        filtSettings = montage.filters(chan_i,:);
        
        Wp = [filtSettings(1) filtSettings(2)]/nyq; % Normalized bandpass freqs/nyquist
        
        
        if (filtSettings(1)>0 && filtSettings(2) == nyq) || filtSettings(1)>=filtSettings(2)
            
            % Design fir1
            f = filtSettings(1)/nyq; % low & hi cut corners
            n = 800; % order of the filter
            b = fir1(n,f,'hi'); % Design filter
            a = 1;
            
            % Filter the data
            dataFilt(chan_i, :) = filtfilt(b, a, (data2plot(chan_i, :))');
            
        else
            %% Design a FIR filter (much slower but easier to implement very low cutoff corners)
            
            % Design fir1
            f = [filtSettings(1) filtSettings(2)]/nyq; % low & hi cut corners
            n = 800; % order of the filter
            b = fir1(n,f); % Design filter
            a = 1;
            
            dataFilt(:,chan_i) = filtfilt(b,a,(data2plot(chan_i,:))');
            
        end
        
    else
        dataFilt(:, chan_i) = data2plot(chan_i, :)';
        
    end
end

data2plot = dataFilt';
clear dataFilt
%% Set channel colors

colorOrder = zeros(size(data2plot,1),3);

eegIdx = strcmpi({montage.chanList.type}, 'EEG')';
eogIdx = strcmpi({montage.chanList.type}, 'EOG')';
emgIdx = strcmpi({montage.chanList.type}, 'EMG')';
ecgIdx = strcmpi({montage.chanList.type}, 'ECG')';
otherIdx = strcmpi({montage.chanList.type}, 'Other')';

if any(eegIdx)
    colorOrder(eegIdx, :) = repmat(montage.colors(1,:), length(find(eegIdx)),1);
end

if any(eogIdx)
    colorOrder(eogIdx, :) = repmat(montage.colors(2, :), length(find(eogIdx)),1);
end

if any(emgIdx)
    colorOrder(emgIdx, :) = repmat(montage.colors(3,:), length(find(emgIdx)),1);
end

if any(ecgIdx)
    colorOrder(ecgIdx, :) = repmat(montage.colors(4,:), length(find(ecgIdx)),1);
end

if any(otherIdx)
    colorOrder(otherIdx, :) = repmat(montage.colors(5,:), length(find(otherIdx)),1);
end



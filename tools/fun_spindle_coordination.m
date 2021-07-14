function ssEvents = fun_spindle_coordination(ssEvents, srate, samples)
% Calculates sleep spindle coordination metrics. Takes each spindle event
% on each channel and finds how many other channels the same spindle
% occurred. 
%
% Required inputs:
%
% ssEvents: A struct containing all sleep spindle events (output from
% fun_sleep_spindles)
%
% srate: The sampling rate of the data (in Hz)
%
% samples: The length of the data
%
% Outputs:
%
% spindlesAll: Appends spindle coordination information to the spindle
% structure
%

%% 
% Remove bad channels
ssEvents([ssEvents.bads] == 1) = [];

numChannels = length(ssEvents);

% Initialize
dummySignal = zeros(numChannels,samples);

NoSpindleCh = zeros(numChannels,1);
% Create a dummy signal that is 1 every time a spindle starts, -1 when spindle ends, 0 otherwise
for  ch = 1:numChannels
    if sum(isnan([ssEvents(ch).startSample]))==0
        dummySignal(ch,ssEvents(ch).startSample) = 1;
        dummySignal(ch,ssEvents(ch).endSample) = -1;
        dummySignal(ch,:) = cumsum(dummySignal(ch,:));
    else
        NoSpindleCh(ch) = 1;
    end 
end

% Sum across electrodes & smooth
dummySignal = sum(dummySignal,1);

% By smoothing you take into account the amount of time that spindles overlap across channels
% e.g., if spindles overlaped for less than 100ms in all channels then the local index will be lower than the total numchannels;
if doSmooth == 1
window        = ones(round(srate/10),1)/round(srate/10); % Create a 100ms sliding window
dummySignal  = filtfilt(window,1,dummySignal);
end

for ch = 1:numChannels
    if NoSpindleCh == 0
        for sp = 1:length(ssEvents(ch).peakLoc)  % Loop over each spindle
            idx1 = find(dummySignal(1:ssEvents(ch).peakLoc(sp))   == 0 ,1,'last'); % find start of global spindle
            if isempty(idx1); idx1 = 1; end
            idx2 = find(dummySignal(ssEvents(ch).peakLoc(sp):end) == 0 ,1,'first'); % find end of global spindle
            if isempty(idx2); idx2 = samples; end
            
            ssEvents(ch).localIdx(sp) = max( dummySignal(idx1:ssEvents(ch).peakLoc(sp)+idx2-1) );
            
        end
    else
        ssEvents(ch).localIdx = nan;
    end
        
end
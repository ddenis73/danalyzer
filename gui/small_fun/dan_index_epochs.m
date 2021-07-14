function handles = dan_index_epochs(handles)
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

% Initialize
plotParam = handles.plotParam;
plotParam.epochSampleIdx = [];

% If user enters an epoch length > than length of the data

if str2double(get(handles.epoch_length, 'String')) > handles.psg.hdr.samples
    plotParam.epochDuration = handles.psg.hdr.samples * handles.psg.hdr.srate;
    plotParam.epochSampleIdx(:,1) = 1;
    plotParam.epochSampleIdx(:,2) = handles.psg.hdr.samples;
    
    % If user enters epoch length < the length of the data
else
    plotParam.epochDuration = str2double(get(handles.epoch_length, 'String')); % Epoch length
    
    % Default to 30 if entered length is either empty or less than zero
    if isnan(plotParam.epochDuration) || plotParam.epochDuration <= 0
        plotParam.epochDuration = 30;
    end
    
    % Get length of epoch in samples
    epochSampleLength = plotParam.epochDuration * handles.psg.hdr.srate;
    
    % Get start and end sample of each epoch
    plotParam.epochSample(:,1) = (1:epochSampleLength:handles.psg.hdr.samples)';
    plotParam.epochSample(:,2) = (unique([epochSampleLength:epochSampleLength:...
        handles.psg.hdr.samples, handles.psg.hdr.samples]))';
    
end

% Find the epoch corresponding to current sample & update epoch index
plotParam.epochIdx = find(plotParam.epochSample(:,1) -...
    plotParam.currSample <= 0 & plotParam.epochSample(:,2) - plotParam.currSample > 0);
plotParam.startTime = (plotParam.epochIdx - 1) * plotParam.epochDuration;

handles.plotParam = plotParam;

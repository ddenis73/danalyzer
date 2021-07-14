function [eventsTable, recStart] = dan_convert_vmrk_events(eventsString, srate)
% This function converts a BrainVision .vmrk file into the correct format
% for danalyzer events
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

[eventsPath, eventsName, eventsExt] = fileparts(eventsString);

vmrkStruct = readbvconf(eventsPath, [eventsName eventsExt]);

recStartEvent   = strsplit(vmrkStruct.markerinfos{1,1}, ',');
recStartTime = datetime(recStartEvent{1, 5}(1:end), 'InputFormat', 'yyyyMMddHHmmssSSSSSS');
recStart = [str2double(recStartEvent{1, 5}(1:4)) str2double(recStartEvent{1,5}(5:6)) str2double(recStartEvent{1,5}(7:8))...
    str2double(recStartEvent{1, 5}(9:10)) str2double(recStartEvent{1, 5}(11:12)) str2double(recStartEvent{1, 5}(13:14))];

for event_i = 1:length(vmrkStruct.markerinfos)
    
    if event_i == 1
        samples(event_i,:)   = 1;
        tSecs(event_i,:)     = samples(event_i, 1) / srate;
        eventStr(event_i,:)  = {'Start recording'};
        clockTime(event_i,:) = datetime(recStartTime, 'Format', 'HH:mm:ss.SSS'); 
    else
        samples(event_i,:)   = str2double(regexp(vmrkStruct.markerinfos{event_i, 1}, ',\d{2,},', 'match'));
        tSecs(event_i,:)     = samples(event_i, 1) / srate;
        eventName = strrep(regexp(vmrkStruct.markerinfos{event_i, 1}, ',\D*,', 'match'), ',', '');
        
        if isempty(eventName)
            eventStr(event_i,:) = {'null'};
        else
            eventStr(event_i,:) = eventName;
        end
        
        clockTime(event_i,:) = datetime(clockTime(1,:) + seconds(tSecs(event_i,:)) , 'Format', 'HH:mm:ss.SSS');
    end
    
end
    
eventsTable = table(clockTime, tSecs, samples, eventStr,...
    'VariableNames', {'Clock_Time', 'Seconds', 'Samples', 'Event'});





    
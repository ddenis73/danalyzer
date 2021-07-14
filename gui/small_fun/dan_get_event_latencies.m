function eventsOut = dan_get_event_latencies(eventsIn, recStart, srate)
% Takes an events table with datestrings and converts them from durations
% from recStart
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


% Recording start time is t0
t0 = datetime(datestr(recStart, 'HH:MM:ss.FFF'), 'Format', 'HH:mm:ss.SSS');

% Loop through each event and get the duration + samples from t0

for event_i = 1:size(eventsIn, 1)
    eventTime(event_i) = datetime(eventsIn{event_i, 1}, 'Format', 'HH:mm:ss.SSS');
    tDiff(event_i)     = eventTime(event_i) - t0;
    if tDiff(event_i) == 0
        tDiff(event_i) = tDiff(event_i) + seconds(0.01);
    elseif tDiff(event_i)<0
        eventTime(event_i) = eventTime(event_i) + days(1);
        tDiff(event_i) = eventTime(event_i) - t0;
    end
end

% Convert into seconds and samples since event

timeDur = seconds(tDiff);
pntsDur = seconds(tDiff)*srate;

eventsOut = table(eventsIn(:,1), timeDur', pntsDur', eventsIn(:,2),...
    'VariableNames', {'Clock_Time', 'Seconds', 'Samples', 'Event'});








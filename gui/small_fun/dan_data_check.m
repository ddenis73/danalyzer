function handles = dan_data_check(handles)

% Checks that the score and ar files are the same dimensions as
% the data

% Check the sleep stages

stageFields= fieldnames(handles.psg.stages);
stageFields(cellfun(@isempty, regexp(stageFields, 's\d', 'match'))) = [];

for i = 1:length(stageFields)
    
    if ~isempty(handles.psg.stages.(stageFields{i}).stages)
        
    else
        handles.psg.stages.(stageFields{i}).stages(1:length(handles.plotParam.epochSample),1) = 7;
    end
    
    % Add in the sleepstage header info
    
    stages = handles.psg.stages.(stageFields{i}).hdr;
    
    if isempty(stages.srate)
        stages.srate = handles.psg.hdr.srate;
    end
    
    if isempty(stages.win)
        stages.win = handles.plotParam.epochDuration;
    end
    
    if strcmp(stages.recStart, "") || isnumeric(stages.recStart) || isempty(stages.recStart)
        stages.recStart = datestr(get(handles.recording_start_time, 'String'), 'HH:MM:SS.FFF');
    end
    
    if isfield(stages, 'lOn')
        if strcmp(stages.lOn, "") || isempty(stages.lOn)
            stages.lOn = datestr(get(handles.lights_on_time, 'String'), 'HH:MM:SS.FFF');
        end
    elseif isfield(stages, 'lightsON')
        stages = rmfield(stages, 'lightsON');
        stages.lOn = datestr(get(handles.lights_on_time, 'String'), 'HH:MM:SS.FFF');
    end
    
    if isfield(stages, 'lOff')
        if strcmp(stages.lOff, "") || isempty(stages.lOff)
            stages.lOff = datestr(get(handles.lights_out_time, 'String'), 'HH:MM:SS.FFF');
        end
    elseif isfield(stages, 'lightsOFF')
        stages = rmfield(stages, 'lightsOFF');
        stages.lOff = datestr(get(handles.lights_out_time, 'String'), 'HH:MM:SS.FFF');
    end
    
    if isfield(stages, 'notes')
        if isempty(stages.notes)
            stages.notes = get(handles.notes_string, 'String');
        end
    elseif isfield(stages, 'Notes')
        stages = rmfield(stages, 'Notes');
        stages.notes = get(handles.notes_string, 'String');
    end
    
    if isfield(stages, 'scorer')
        if isempty(stages.scorer)
            stages.scorer = get(handles.scorer_string, 'String');
        end
    elseif ~isfield(stages, 'scorer')
        stages.scorer = get(handles.scorer_string, 'String');
    end
    
    if isempty(stages.onsets)
        stages.onsets = handles.plotParam.epochSample(:,1);
    end
    
    if isempty(stages.stageTime)
        stages.stageTime = (handles.plotParam.epochSample(:,1)'-1) / handles.psg.hdr.srate;
    end
    
    handles.psg.stages.(stageFields{i}).hdr = stages;
    
    if length(handles.psg.stages.(stageFields{i}).stages) < length(handles.plotParam.epochSample)
        lengthDiff = length(handles.plotParam.epochSample) - length(handles.psg.stages.(stageFields{i}).stages);
        handles.psg.stages.(stageFields{i}).stages(end:lengthDiff,:) = 7;
        warning('stages is shorter than the number of epochs in the data')
    elseif length(handles.psg.stages.(stageFields{i}).stages) > length(handles.plotParam.epochSample)
        lengthDiff = length(handles.psg.stages.(stageFields{i}).stages) - size(handles.plotParam.epochSample, 1);
        handles.psg.stages.(stageFields{i}).stages(end-(lengthDiff-1):end,:) = [];
        warning('stages is longer than the number of epochs in the data')
    end
    
    
end

% Check the ar

if ~isempty(handles.psg.ar.badepochs)
    
else
    handles.psg.ar.badepochs(1:length(handles.plotParam.epochSample),1) = 0;
end

if length(handles.psg.ar.badepochs) < length(handles.plotParam.epochSample)
    lengthDiff = length(handles.plotParam.epochSample) - length(handles.psg.ar.badepochs);
    handles.psg.ar.badepochs(end:lengthDiff,:) = 7;
    warning('badepochs is shorter than the number of epochs in the data')
elseif length(handles.psg.ar.badepochs) > length(handles.plotParam.epochSample)
    lengthDiff = length(handles.psg.ar.badepochs) - size(handles.plotParam.epochSample, 1);
    handles.psg.ar.badepochs(end-(lengthDiff-1):end,:) = [];
    warning('badepochs is longer than the number of epochs in the data')
end

if ~isempty(handles.psg.ar.badchans)
    
    % Check that the number of channels matches the number in the data
    
    if length(handles.psg.ar.badchans) > size(handles.psg.data, 1)
        
        lengthDiff = length(handles.psg.ar.badchans) - size(handles.psg.data, 1);
        handles.psg.ar.badchans(end-(lengthDiff-1):end,:) = [];
        warning('badchans is longer than total number of channels')
        
    elseif length(handles.psg.ar.badchans) < size(handles.psg.data, 1)
        
        lengthDiff = size(handles.psg.data, 1) - length(handles.psg.ar.badchans);
        handles.psg.ar.badchans(end:lengthDiff,:) = 0;
        warning('badchans is shorter than the total number of channels')
        
    end
    
else
    handles.psg.ar.badchans(1:size(handles.psg.data, 1),1) = 0;
end



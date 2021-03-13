function se_preprocess(data, scores, chanlocs, ref1, ref2, notch, eeglp, eeghp, emglp, emghp, eoglp, eoghp, ecglp, ecghp, otherlp, otherhp, save, emgkeep, eogkeep, ecgkeep, otherkeep, epoch)

%% Check if paths are valid

dataFile = dir(data);

if length(dataFile) >= 2
    error(['Too many data files found. ' num2str(length(dataFile)) ' files with the path ' data ' found'])
elseif isempty(dataFile)
    error(['No file with the path ' data ' found'])
end

% scoreFile = dir(scores);
% 
% if length(scoreFile) >= 2
%     error(['Too many score files found. ' num2str(length(scoreFile)) ' files with the path ' scores ' found'])
% end

if ~isempty(chanlocs)
    
    chanlocsFile = dir(chanlocs);
    
    [~,~,chanExt] = fileparts(chanlocsFile.name);
        
    if length(chanlocsFile) >= 2
        error(['Too many chanlocs files found. ' num2str(length(chanlocsFile)) ' files with the path ' chanlocs ' found'])
    elseif isempty(chanlocsFile)
        error(['No file with the path ' chanlocs ' found'])
    end
    
elseif isempty(chanlocs)
    warning('No chanlocs file specified. Will proceed without.')
end

%% All paths valid, so will now import file and add channel locations

[dataPathName,dataFileName,dataType] = fileparts(data); % Determine file type e.g. .edf, .eeg, .set etc..

if strcmpi(dataType, '.edf')
    EEG = pop_biosig(data, 'importevent', 'off', 'importannot', 'off'); % Imports an .edf file
elseif strcmpi(dataType, '.set')
    EEG = pop_loadset(data); % Imports a .set file
elseif strcmpi(dataType, '.vhdr')
    EEG = pop_loadbv(dataPathName, dataFileName, [], []);
end

if ~isempty(chanlocs)
    if ~strcmp(chanExt, '.mat')
        EEG.chanlocs = readlocs(chanlocs, 'filetype', 'custom',...
            'format', {'labels', 'X', 'Y', 'Z','type'}); % Add channel locations
    elseif strcmp(chanExt, 'mat')
        EEG.chanlocs = load(chanlocs);
    end
end

EEG.data = 1*EEG.data; % Deal with polarity inversion

if ~isfield(EEG.chanlocs, 'type')
    warning('no field ''type'' in chanlocs struct. Cannot separate channel types')
end
%% Re-referencing

% Find the channel location of the reference electrode(s)

if ~isempty(ref1)
    refChanLocs = find(ismember({EEG.chanlocs.labels}, ref1));
elseif ~isempty(ref1) && strcmp(ref1, 'AVG')
    refChanLocs = [];
elseif isempty(ref1)
    warning('No reference selelcted. Will not re-reference data')
end

% Find non-EEG channels

if isfield(EEG.chanlocs, 'type')
    
    eogChans = find(strcmp({EEG.chanlocs.type}, 'EOG'));
    emgChans = find(strcmp({EEG.chanlocs.type}, 'EMG'));
    ecgChans = find(strcmp({EEG.chanlocs.type}, 'ECG') | strcmp({EEG.chanlocs.type}, 'EKG'));
    otherChans = find(strcmp({EEG.chanlocs.type}, 'OTHER'));
    if ~isempty(otherChans)
        otherChans = otherChans(~ismember(otherChans, refChanLocs));
    end
else
    eogChans   = [];
    emgChans   = [];
    ecgChans   = [];
    otherChans = [];
end
% Re-reference EEG

if ~isempty(ref1)
    EEG = pop_reref(EEG, refChanLocs, 'exclude', [eogChans emgChans ecgChans otherChans]);
end

% Re-reference based on 'other ref field'
% Find non-EEG channels

if isfield(EEG.chanlocs, 'type')
    eogChans = find(strcmp({EEG.chanlocs.type}, 'EOG'));
    emgChans = find(strcmp({EEG.chanlocs.type}, 'EMG'));
    ecgChans = find(strcmp({EEG.chanlocs.type}, 'ECG') | strcmp({EEG.chanlocs.type}, 'EKG'));
    otherChans = find(strcmp({EEG.chanlocs.type}, 'OTHER'));
    if ~isempty(otherChans)
        otherChans = otherChans(~ismember(otherChans, refChanLocs));
    end
end
if ~isempty(ref2)
    
    otherRefLocs = find(ismember({EEG.chanlocs.labels}, ref2));
    
    if ~isempty(otherRefLocs)
        
        otherRefLabel = [EEG.chanlocs(otherRefLocs(1)).labels '-' EEG.chanlocs(otherRefLocs(2)).labels];
        
        myOtherRef = pop_select(EEG, 'channel', otherRefLocs);
        myOtherRef = pop_reref(myOtherRef, 1);
        myOtherRef.chanlocs.labels = otherRefLabel;
        
        EEG.data(otherRefLocs,:) = [];
        EEG.chanlocs(otherRefLocs) = [];
        
        % Pin back together
        
        EEG.data = [EEG.data; myOtherRef.data];
        EEG.chanlocs = [EEG.chanlocs myOtherRef.chanlocs];
        EEG.nbchan = length(EEG.chanlocs);
        EEG = eeg_checkset(EEG);
        
        clear myOtherRef
        
    else
        warning(['Ref2 channels: ' strjoin(ref2) 'not found. Will not rereference'])
        
    end

end
    
%% Filtering

% Need to find non-EEG channel indices again

if isfield(EEG.chanlocs, 'type')

eogChans = find(strcmp({EEG.chanlocs.type}, 'EOG'));
emgChans = find(strcmp({EEG.chanlocs.type}, 'EMG'));
ecgChans = find(strcmp({EEG.chanlocs.type}, 'ECG') | strcmp({EEG.chanlocs.type}, 'EKG'));
otherChans = find(strcmpi({EEG.chanlocs.type}, 'Other'));

% Separate channel types

myEEG = pop_select(EEG, 'nochannel', [eogChans emgChans ecgChans otherChans]);
myEOG = pop_select(EEG, 'channel', eogChans);
myEMG = pop_select(EEG, 'channel', emgChans);
myECG = pop_select(EEG, 'channel', ecgChans);
myOther = pop_select(EEG, 'channel', otherChans);

else
    myEEG = EEG;
    eogChans = [];
    emgChans = [];
    ecgChans = [];
    otherChans = [];
end

EEG.data = [];

% Apply filters
% Notch 
if ~isnan(notch)
    myEEG = pop_eegfiltnew(myEEG, notch-2, notch+2, [], 1);
    if ~isempty(eogChans)
        myEOG = pop_eegfiltnew(myEOG, notch-2, notch+2, [], 1);
    end
    if ~isempty(emgChans)
        myEMG = pop_eegfiltnew(myEMG, notch-2, notch+2, [], 1);
    end
    if ~isempty(ecgChans)
        myECG = pop_eegfiltnew(myECG, notch-2, notch+2, [], 1);
    end
    if ~isempty(otherChans)
        myOther = pop_eegfiltnew(myOther, notch-2, notch+2, [], 1);
    end
elseif isnan(notch)
    warning('No notch filter applied, may cause excessive line noise to remain in data')
end

% low/high pass

if ~isnan(eeglp) && ~isnan(eeghp)    
    myEEG = pop_eegfiltnew(myEEG, eeglp, eeghp, [], 0);
else
    warning('No EEG filters applied')
end

if ~isnan(emglp) && ~isnan(emghp) && ~isempty(myEMG.data)
    myEMG = pop_eegfiltnew(myEMG, emglp, emghp, [], 0);
elseif isnan(emglp) && isnan(emghp) && ~isempty(emgChans)
    warning('No EMG filters applied')
end

if ~isnan(eoglp) && ~isnan(eoghp) && ~isempty(myEOG.data)
    myEOG = pop_eegfiltnew(myEOG, eoglp, eoghp, [], 0);
elseif isnan(eoglp) && isnan(eoghp) && ~isempty(eogChans)
    warning('No EOG filters applied')
end

if ~isnan(ecglp) && ~isnan(ecghp) && ~isempty(myECG.data)
    myECG = pop_eegfiltnew(myECG, ecglp, ecghp, [], 0);
elseif isnan(ecglp) && isnan(ecghp) && ~isempty(ecgChans)
    warning('No ECG filters applied')
end

if ~isnan(otherlp) && ~isnan(otherhp) && ~isempty(myOther.data)
    myOther = pop_eegfiltnew(myOther, otherlp, otherhp, [], 0);
elseif isnan(otherlp) && isnan(otherhp) && ~isempty(otherChans)
    warning('No OTHER filters applied')
end

% Pin dataset back together

EEG.data = [myEEG.data; myEOG.data; myEMG.data; myECG.data; myOther.data];
EEG.chanlocs = [myEEG.chanlocs myEOG.chanlocs myEMG.chanlocs myECG.chanlocs myOther.chanlocs];
EEG.nbchan = length(EEG.chanlocs);
EEG = eeg_checkset(EEG);

clearvars myEEG myEMG myEOG myTTL myECG myOther

 %% Add scores and epoch if requested
 
 if ~isnan(epoch)
     
     [~,~,scoreExt] = fileparts(scores);
     
     if strcmp(scoreExt, '.xlsx')
         sleepStages = table2array(readtable(scores, 'ReadVariableNames', 0));
         if max(sleepStages) > 7
             changeEpochsOnly = find(diff([0; sleepStages]) > 1, 1, 'first');
         end
         
         if exist('changeEpochsOnly', 'var') && ~isempty(changeEpochsOnly)
             sleepStages = excelStageChangesToList(get(handles.score_file_string, 'String'));
             
         end
         
     elseif strcmp(scoreExt, '.mat')
         load(get(handles.score_file_string, 'String'))
     end
     
     eventTable = [strcat('stage', cellfun(@num2str, num2cell(sleepStages), 'uni', 0))...
         num2cell(((1:length(sleepStages))*30)-30)'];
     EEG = pop_importevent(EEG, 'event', eventTable, 'fields', {'type', 'latency'});
     
     eventTypes = unique({EEG.event.type});
     sleepStageTypes = strfind(eventTypes, 'stage');
     epochEvents = eventTypes(find(~cellfun(@isempty,sleepStageTypes)));
     
     if EEG.trials == 1
         EEG = pop_epoch(EEG, epochEvents, [0 epoch]);
     else
         warning(['File contains ' num2str(EEG.trials) ' epochs. Will not epoch again'])
     end
     
 end
      
%% Save pre-processed file

[dataSaveName, dataSaveDir, filtIdx] = uiputfile({'*.set'; '*.edf'; '*.mat'},...
    'Where to save?');
if filtIdx == 0
    return
end

[~,~,saveExt] = fileparts(fullfile(dataSaveDir, dataSaveName));

if strcmp(saveExt, '.set')

        pop_saveset(EEG, 'filepath', dataSaveDir, 'filename', dataSaveName, 'savemode', 'onefile', 'version', '7.3');
        disp('done')
        
elseif strcmp(saveExt, '.edf')
    pop_writeeeg(EEG, [dataSaveDir dataSaveName], 'TYPE', 'EDF');
    disp('done')
end
        
        
        
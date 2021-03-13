function se_preprocessbatch(data, scores, chanlocs, folderOrganization, batchid, badid, ref1, ref2, notch, eeglp, eeghp, emglp, emghp, eoglp, eoghp, ecglp, ecghp, otherlp, otherhp, save, emgkeep, eogkeep, ecgkeep, otherkeep, epoch)

% Figure out folder structure

if strcmp(folderOrganization, 'bySubject')
    
    % Get a list of each subject folder
    subDirs = generatesublist(data);
    
elseif strcmp(folderOrganization, 'byGroup')
    
    % Get a list of each subject
    subDirs = dir(data);
    
    if ~isempty(batchid)
        idMatch = find(~cellfun(@isempty, strfind({subDirs.name}, batchid)));
        subDirs = {subDirs(idMatch).name}';
    else
        subDirs = {subDirs.name}';
    end
    
    if ~isempty(badid)
        subDirs(~cellfun(@isempty, strfind(subDirs, badid))) = [];
    end
    
    % Check if any of the files have been preprocessed already
    
    alreadyPP = subDirs(~cellfun(@isempty, strfind(subDirs, '_PP')));
    
    for i = 1:length(alreadyPP)
        alreadyPP{i}(strfind(alreadyPP{i}, '_PP'):end) = [];
    end
    
    subDirs(~cellfun(@isempty, strfind(subDirs, '_PP'))) = [];
    
end

for sub_i = 1:length(subDirs)
    
    % Load datafile
    
    if strcmp(folderOrganization, 'bySubject')
        
        dataDir = dir([data filesep subDirs{sub_i}]);
        dataDir([dataDir(:).isdir]) = [];
        
        alreadyPP = any(~cellfun(@isempty, strfind({dataDir.name}, '_PP')));
        
        if ~isempty(badid)
            badMatch = ~cellfun(@isempty, strfind({dataDir.name}, badid));
            dataDir(badMatch) = [];
        end
        
        if ~isempty(batchid)
            idMatch = ~cellfun(@isempty, strfind({dataDir.name}, batchid));
            dataFile = dataDir(idMatch).name;
        end
        
        if isempty(badid) && isempty(batchid) && length(dataDir) == 1
            dataFile = dataDir.name;
        end
        
        [~,~,fileExt] = fileparts(dataFile);
        
        if alreadyPP == 0
            
            disp(['Processing: ' dataFile])
            
            if strcmpi(fileExt, '.edf')
                EEG = pop_biosig([data filesep subDirs{sub_i} filesep dataFile], 'importevent', 'off', 'importannot' ,'off');
            elseif strcmp(fileExt, '.set')
                EEG = pop_loadset('filename', subDirs{sub_i}, 'filepath', [data filesep subDirs{sub_i} filesep dataFile]);
            elseif strcmp(fileExt, '.vhdr')
                EEG = pop_loadbv([data filesep subDirs{sub_i}], dataFile);
            end
            
        elseif alreadyPP == 1
            
            disp(['Already processed: ' dataFile])
            
        end
        
    elseif strcmp(folderOrganization, 'byGroup')
        
        if ~isempty(subDirs{sub_i})
            
            if isempty(alreadyPP) || ~contains(subDirs{sub_i}, alreadyPP)
                
                [~,~,fileExt] = fileparts(subDirs{sub_i});
                
                disp(['Processing: ' subDirs{sub_i}])
                
                if strcmpi(fileExt, '.edf')
                    EEG = pop_biosig([data filesep subDirs{sub_i}], 'importevent', 'off', 'importannot' ,'off');
                elseif strcmp(fileExt, '.set')
                    EEG = pop_loadset('filename', subDirs{sub_i}, 'filepath', data);
                elseif strcmp(fileExt, '.vhdr')
                    EEG = pop_loadbv(data, subDirs{sub_i});
                end
                
            elseif ~isempty(contains(subDirs{sub_i}, alreadyPP))
                disp(['Already preprocessed: ' subDirs{sub_i}])
            end
            
        end
        
    end
    
    if exist('EEG', 'var')
        
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
        
        
        EEG.data = 1*EEG.data; % Deal with polarity inversion
        
        %% Re-referencing
        
        % Find the channel location of the reference electrode(s)
        
        if contains(subDirs{sub_i}, '_LB')
            if ~isempty(ref1)
                refChanLocs = find(ismember({EEG.chanlocs.labels}, ref1{1}));
            end
        elseif contains(subDirs{sub_i}, '_RB')
            if ~isempty(ref1)
                refChanLocs = find(ismember({EEG.chanlocs.labels}, ref1{2}));
            end
        elseif ~contains(subDirs{sub_i}, '_LB') && ~contains(subDirs{sub_i}, '_RB')
            
            if ~isempty(ref1)
                refChanLocs = find(ismember({EEG.chanlocs.labels}, ref1));
            elseif ~isempty(refString) && strcmp(ref1, 'AVG')
                refChanLocs = [];
            elseif isempty(ref1)
                warning(['No reference selelcted. Will not re-reference data'])
            end
            
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
                warning(['Ref2 channels: ' strjoin(ref2) ' not found. Will not rereference.'])
                
            end
        end
        
        %% Filtering
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
        if ~isempty(notch)
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
        elseif isempty(notch)
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
        
        %% Add score file and epoch
        
        %% Save
        
        if save == 0
            
            if strcmp(folderOrganization, 'bySubject')
                pop_saveset(EEG, 'filepath', [data filesep subDirs{sub_i}], 'filename', [erase(dataFile, fileExt) '_PP'], 'savemode', 'onefile', 'version', '7.3');
            elseif strcmp(folderOrganization, 'byGroup')
                pop_saveset(EEG, 'filepath', data, 'filename', [erase(subDirs{sub_i}, fileExt) '_PP'], 'savemode', 'onefile', 'version', '7.3');
            end
            
        elseif save == 1
            if strcmp(folderOrganization, 'bySubject')
                pop_writeeeg(EEG, [data filesep subDirs{sub_i} filesep erase(dataFile, fileExt) '_PP'], 'TYPE', 'EDF');
            elseif strcmp(folderOrganization, 'byGroup')
                writeeeg(EEG, [data filesep erase(subDirs{sub_i}. fileExt) '_PP'], 'TYPE', 'EDF');
            end
            
        end
        disp(['Finished processing: ' subDirs{sub_i}])
        
    end
    
end
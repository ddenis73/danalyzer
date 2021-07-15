%% Analyzing sleep EEG data
% Example preprocessing script. This script will take the example dataset
% and perform standard preprocessing steps as follows:
%
% 1) Import the raw EDF into MATLAB
% 2) Insert the channel locations
% 3) Remove the TTL channel
% 4) Re-reference EEG channels to the average mastoids
% 5) Re-reference the EMG channels to each other
% 6) Notch filter the data
% 7) Band-pass filter EEG and EOG channels between .3-35Hz
% 8) Band-pass filter EMG channels between 10-100Hz
% 9) Save a preprocessed dataset for further analysis
%
clear
%% Setup

% cd into folder containing example data
cd 'C:\Users\ddenis\Downloads\exampleData-20210715T000213Z-001\exampleData'

% Set parameters

% Load channel locations
chanlocs = readlocs('chans.txt', 'filetype', 'custom',...
    'format', {'labels' 'X' 'Y' 'Z' 'type'});

% Name of channel to remove
chans2Remove = {'TTL'};

% Name of EEG reference channel(s)
mastChans = {'A1' 'A2'};

% Filter settings
notchFilter = [58 62]; %Hz
eegFilter   = [0.3 35]; %Hz
eogFilter   = [0.3 35]; %Hz
emgFilter   = [10 99]; %Hz

% Save location
saveFolder = pwd;
saveName = 'exampleData_PP';

%% Let's start

% Read the edf file into MATLAB
EEG = pop_biosig('exampleData.edf', 'importevent', 'off', 'importannot', 'off');

% Add channel locations
EEG.chanlocs = chanlocs;

% Let's look at the data in it's raw state
data_viewer('psg', eeglab2danalyzer(EEG))

%% Remove unwanted channels

% Find the index of channels marked for removal
rmChanIdx = find(ismember({EEG.chanlocs.labels}, chans2Remove));

% Remove the channel(s)
if ~isempty(rmChanIdx)
    EEG = pop_select(EEG, 'nochannel', rmChanIdx);
else
    disp('Could not find selected channel')
end

%% Notch filter

% Band-stop (notch filter) the data
EEG = pop_eegfiltnew(EEG, notchFilter(1), notchFilter(2), [], 1);

% Let's look at the effect of the notch filter
data_viewer('psg', eeglab2danalyzer(EEG))


%% Separate into different channel types

% We now need to find the location of all EEG, EOG, and EMG channels, and
% separate them
eegIdx = find(ismember({EEG.chanlocs.type}, 'EEG')); % EEG channels
eogIdx = find(ismember({EEG.chanlocs.type}, 'EOG')); % EOG channels
emgIdx = find(ismember({EEG.chanlocs.type}, 'EMG')); % EMG channels

% Just EEG
myEEG = pop_select(EEG, 'channel', eegIdx);

% Just EOG
myEOG = pop_select(EEG, 'channel', eogIdx);

% Just EMG
myEMG = pop_select(EEG, 'channel', emgIdx);

% clear data to free up RAM
clear EEG.data

%% Re-reference the data

% Find the index of the EEG reference channel(s)
eegRefIdx = find(ismember({myEEG.chanlocs.labels}, mastChans));

if ~isempty(eegRefIdx)
    myEEG = pop_reref(myEEG, eegRefIdx);
else
    disp('Could not find channels')
end

% Re-reference the EMG 
myEMG = pop_reref(myEMG, 2);

% Rename the EMG channel to make it clear it is bipolar
myEMG.chanlocs.labels = 'EMG1-EMG2';

%% Band-pass filter the data

% We filter the data based on the inputs given in the setup portion of the
% script

myEEG = pop_eegfiltnew(myEEG, eegFilter(1), eegFilter(2)); % EEG filter
myEOG = pop_eegfiltnew(myEOG, eogFilter(1), eogFilter(2)); % EOG filter
myEMG = pop_eegfiltnew(myEMG, emgFilter(1), emgFilter(2)); % EMG filter

%% Gather all the data together

EEG.data     = [myEEG.data; myEOG.data; myEMG.data];
EEG.chanlocs = [myEEG.chanlocs myEOG.chanlocs myEMG.chanlocs];
EEG.nbchan   = length(EEG.chanlocs);
EEG = eeg_checkset(EEG);

% Let's look at the fully preprocessed data
data_viewer('psg', eeglab2danalyzer(EEG))

%% Save the preprocessed file

pop_saveset(EEG, 'filepath', saveFolder, 'filename', saveName,...
    'savemode', 'onefile', 'version', '7.3');

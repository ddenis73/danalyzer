%% Analyzing sleep EEG data
% Example script to create a low-density scoring file. This template will
% be useful if you are using a high-density recording, and you need to
% create a montage specific for sleep scoring (i.e. AAASM guidelines).
%
% 1) Import the raw EDF into MATLAB
% 2) Insert the channel locations
% 3) Find the channels of interest
% 4) Re-reference EOG/EEG channels to the contralateral mastoid
% 5) Re-reference the EMG channels to each other
% 6) Notch filter the data
% 7) Band-pass filter EEG and EOG channels between .3-35Hz
% 8) Band-pass filter EMG channels between 10-100Hz
% 9) Save the low-density file for sleep scoring
%
clear
%% Setup

% CD into the folder containing the example data
cd 'C:\Users\ddenis\Google Drive\exampleData'

% Set parameters

% Load channel location file
chanlocs = readlocs('chans.txt', 'filetype', 'custom',...
    'format', {'labels' 'X' 'Y' 'Z' 'type'});

% Channels on the left-hand side (Note the order to list here will be order
% they appear in the final file).
lChans = {'LOC' 'F3' 'C3' 'O1'};
rChans = {'ROC' 'F4' 'C4' 'O2'};

% Name of the of Mastoids {left right}
mChans = {'A1' 'A2'};

% EMG Channels names
emgChans = {'EMG1' 'EMG2'};

% Filter settings
notchFilter = [58 62]; %Hz
eegFilter   = [0.3 35]; %Hz
eogFilter   = [0.3 35]; %Hz
emgFilter   = [10 100]; %Hz

% Save location
saveFolder = pwd;
saveName = 'LD_exampleData';

%% Let's start

% Read the full edf file into MATLAB
% If you are working with an .edf file
EEG = pop_biosig('HD_exampleData.edf', 'importevent', 'off', 'importannot', 'off');

% If you are working with a BrainVision file
%EEG = pop_loadbv(pwd, 'filename.vhdr');

% Add channel locations
EEG.chanlocs = chanlocs;
%% Separate out the left and right side channesl

%%% Find the channels

% Left side channels
lIdx = find(ismember({EEG.chanlocs.labels}, [lChans mChans(2)]));

% Right side channels
rIdx = find(ismember({EEG.chanlocs.labels}, [rChans mChans(1)]));

% EMG channels
emgIdx = find(ismember({EEG.chanlocs.labels}, emgChans));

%%% Seperate into different data structs
leftEEG  = pop_select(EEG, 'channel', lIdx); % Left side
rightEEG = pop_select(EEG, 'channel', rIdx); % Right side
myEMG    = pop_select(EEG, 'channel', emgIdx); % EMG

% Empty the EEG data field
EEG.data = [];
EEG.chanlocs = [];

%% Re-reference the data

% Find the index of the left mastoid
rMastIdx = find(ismember({leftEEG.chanlocs.labels}, mChans(2)));

% Find the location of the right mastoid
lMastIdx = find(ismember({rightEEG.chanlocs.labels}, mChans(1)));

% Re-reference the left EEG/EOG to the right mastoid
leftEEG = pop_reref(leftEEG, rMastIdx);

% Re-reference the right EEG/EOG to the left mastoid
rightEEG = pop_reref(rightEEG, lMastIdx);

% Re-reference the EMG to each other
myEMG = pop_reref(myEMG, 2);
myEMG.chanlocs.labels = 'EMG1-EMG2';
%% Correctly order the low density file

% We will first re-order the EOG and EEG channels such that the channel
% order is the same as reflected in lChans/rChans variables. Note that the
% left side of a channel pair will be 1 row above the corresponding right
% side

ldData = zeros(leftEEG.nbchan + rightEEG.nbchan, EEG.pnts);
chNum = 1;
for chan_i = 1:length(lChans)
    
    lChanIdx = find(ismember({leftEEG.chanlocs.labels}, lChans(chan_i)));
    rChanIdx = find(ismember({rightEEG.chanlocs.labels}, rChans(chan_i)));
    
    ldData(chNum, :)      = leftEEG.data(lChanIdx,:);
    ldChans(chNum)        = leftEEG.chanlocs(lChanIdx);
    ldChans(chNum).labels = [lChans{chan_i} '-' mChans{2}];
    chNum = chNum + 1;
    
    ldData(chNum, :)      = rightEEG.data(rChanIdx,:);
    ldChans(chNum)        = rightEEG.chanlocs(rChanIdx);
    ldChans(chNum).labels = [rChans{chan_i} '-' mChans{1}];
    chNum = chNum + 1;
end

EEG.data = ldData;
EEG.chanlocs = ldChans;
EEG.nbchan = length(ldChans);

%% Filter the data

% Notch filter
EEG   = pop_eegfiltnew(EEG, notchFilter(1), notchFilter(2), [], 1);
myEMG = pop_eegfiltnew(myEMG, notchFilter(1), notchFilter(2), [], 1);

% Bandpass filter
EEG   = pop_eegfiltnew(EEG, eegFilter(1), eegFilter(2));
myEMG = pop_eegfiltnew(myEMG, emgFilter(1), emgFilter(2));

%% Attach the EMG data

EEG.data     = [EEG.data; myEMG.data];
EEG.chanlocs = [EEG.chanlocs myEMG.chanlocs];
EEG.nbchan   = length(EEG.chanlocs);

EEG = eeg_checkset(EEG);

%Optional - view the completed low density file
data_viewer('psg', eeglab2danalyzer(EEG))

%% Save the low density file

pop_saveset(EEG, 'filepath', saveFolder, 'filename', saveName,...
    'savemode', 'onefile', 'version', '7.3');

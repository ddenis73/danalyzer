function EEG = danalyzer2eeglab(psg)
% Convert a danalyzer psg struct to EEGLAB
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

EEG = eeg_emptyset();

EEG.data = psg.data;
EEG.pnts = psg.hdr.samples;
EEG.srate = psg.hdr.srate;
EEG.chanlocs = psg.chans;
EEG.nbchan = length(EEG.chanlocs);
EEG.trials = 1;

EEG = eeg_checkset(EEG);
function sleepstagesOUT = hume2danalyzer(sleepstagesIN)
% Convert a Hume score file to a danalyzer score file.
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
sleepstagesOUT.stages        = sleepstagesIN.stages;
sleepstagesOUT.hdr.srate     = sleepstagesIN.srate;
sleepstagesOUT.hdr.win       = sleepstagesIN.win;
sleepstagesOUT.hdr.recStart  = datestr(sleepstagesIN.recStart, 'HH:MM:ss.FFF');
sleepstagesOUT.hdr.lOff      = datestr(sleepstagesIN.lightsOFF, 'HH:MM:ss.FFF');
sleepstagesOUT.hdr.lOn       = datestr(sleepstagesIN.lightsON, 'HH:MM:ss.FFF');
sleepstagesOUT.hdr.onsets    = sleepstagesIN.onsets;
sleepstagesOUT.hdr.stageTime = sleepstagesIN.stageTime;
sleepstagesOUT.hdr.notes     = sleepstagesIN.Notes;
sleepstagesOUT.hdr.scorer    = '';
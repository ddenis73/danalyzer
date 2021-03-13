function sleepstagesOUT = hume2danalyzer(sleepstagesIN)
% Convert a Hume score file to a danalyzer score file.

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
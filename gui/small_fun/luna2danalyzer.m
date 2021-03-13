function sleepstagesOUT = luna2danalyzer(sleepstagesIN)
% Convert a Luns score file to a danalyzer score file.

sleepstagesOUT.stages = zeros(height(sleepstagesIN), 1);

for i = 1:height(sleepstagesIN)
    
    if strcmpi(sleepstagesIN.Var1(i), 'wake')
        sleepstagesOUT.stages(i,:) = 0;
    elseif strcmpi(sleepstagesIN.Var1(i), 'n1') || strcmpi(sleepstagesIN.Var1(i), 'nrem1')
        sleepstagesOUT.stages(i,:) = 1;
    elseif strcmpi(sleepstagesIN.Var1(i), 'n2') || strcmpi(sleepstagesIN.Var1(i), 'nrem2')
        sleepstagesOUT.stages(i,:) = 2;
    elseif strcmpi(sleepstagesIN.Var1(i), 'n3') || strcmpi(sleepstagesIN.Var1(i), 'nrem3')
        sleepstagesOUT.stages(i,:) = 3;
    elseif strcmpi(sleepstagesIN.Var1(i), 'n4') || strcmpi(sleepstagesIN.Var1(i), 'nrem4')
        sleepstagesOUT.stages(i,:) = 4;
    elseif strcmpi(sleepstagesIN.Var1(i), 'rem')
        sleepstagesOUT.stages(i,:) = 5;
    elseif strcmpi(sleepstagesIN.Var1(i), 'mt') || strcmpi(sleepstagesIN.Var1(i), 'mvt')
        sleepstagesOUT.stages(i,:) = 6;
    elseif strcmpi(sleepstagesIN.Var1(i), '?')
        sleepstagesOUT.stages(i,:) = 7;
    else
        sleepstagesOUT.stages = 7;
    end
    
end

sleepstagesOUT.hdr.srate     = [];
sleepstagesOUT.hdr.win       = [];
sleepstagesOUT.hdr.recStart  = '';
sleepstagesOUT.hdr.lOff      = '';
sleepstagesOUT.hdr.lOn       = '';
sleepstagesOUT.hdr.onsets    = [];
sleepstagesOUT.hdr.stageTime = [];
sleepstagesOUT.hdr.notes     = '';
sleepstagesOUT.hdr.scorer    = '';
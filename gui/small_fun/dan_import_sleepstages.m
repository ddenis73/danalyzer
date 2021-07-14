function sleepstagesOUT = dan_import_sleepstages(sleepstagesIN, values)
% Generic sleep stage conversion file. Input is a list of sleep stages (one
% row = one epoch), and a list of values that correspond to Wake, N1, N2,
% N3, N4, REM, Movement, Unstaged
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

if isa(sleepstagesIN, 'table')
    
    sleepstagesOUT.stages = zeros(height(sleepstagesIN), 1);
    
    if isa(sleepstagesIN.Var1(1), 'double')
        
        for i = 1:height(sleepstagesIN)
            
            if strcmpi(sleepstagesIN.Var1(i), str2double(values{1}))
                sleepstagesOUT.stages(i,:) = 0;
            elseif strcmpi(sleepstagesIN.Var1(i), str2double(values{2}))
                sleepstagesOUT.stages(i,:) = 1;
            elseif strcmpi(sleepstagesIN.Var1(i), str2double(values{3}))
                sleepstagesOUT.stages(i,:) = 2;
            elseif strcmpi(sleepstagesIN.Var1(i), str2double(values{4}))
                sleepstagesOUT.stages(i,:) = 3;
            elseif strcmpi(sleepstagesIN.Var1(i), str2double(values{5}))
                sleepstagesOUT.stages(i,:) = 4;
            elseif strcmpi(sleepstagesIN.Var1(i), str2double(values{6}))
                sleepstagesOUT.stages(i,:) = 5;
            elseif strcmpi(sleepstagesIN.Var1(i), str2double(values{7}))
                sleepstagesOUT.stages(i,:) = 6;
            elseif strcmpi(sleepstagesIN.Var1(i), str2double(values{8}))
                sleepstagesOUT.stages(i,:) = 7;
            else
                sleepstagesOUT.stages = 7;
            end
            
        end
        
    else
        
        for i = 1:height(sleepstagesIN)
            
            if strcmpi(sleepstagesIN.Var1(i), values{1})
                sleepstagesOUT.stages(i,:) = 0;
            elseif strcmpi(sleepstagesIN.Var1(i), values{2})
                sleepstagesOUT.stages(i,:) = 1;
            elseif strcmpi(sleepstagesIN.Var1(i), values{3})
                sleepstagesOUT.stages(i,:) = 2;
            elseif strcmpi(sleepstagesIN.Var1(i), values{4})
                sleepstagesOUT.stages(i,:) = 3;
            elseif strcmpi(sleepstagesIN.Var1(i), values{5})
                sleepstagesOUT.stages(i,:) = 4;
            elseif strcmpi(sleepstagesIN.Var1(i), values{6})
                sleepstagesOUT.stages(i,:) = 5;
            elseif strcmpi(sleepstagesIN.Var1(i), values{7})
                sleepstagesOUT.stages(i,:) = 6;
            elseif strcmpi(sleepstagesIN.Var1(i), values{8})
                sleepstagesOUT.stages(i,:) = 7;
            else
                sleepstagesOUT.stages = 7;
            end
        end
        
    end
    
elseif isa(sleepstagesIN, 'cell')
    
    sleepstagesOUT.stages = zeros(size(sleepstagesIN, 1), 1);
    
    if isa(sleepstagesIN{1}, 'double')
        
        for i = 1:height(sleepstagesIN)
            
            if strcmpi(sleepstagesIN(i), str2double(values{1}))
                sleepstagesOUT.stages(i,:) = 0;
            elseif strcmpi(sleepstagesIN(i), str2double(values{2}))
                sleepstagesOUT.stages(i,:) = 1;
            elseif strcmpi(sleepstagesIN(i), str2double(values{3}))
                sleepstagesOUT.stages(i,:) = 2;
            elseif strcmpi(sleepstagesIN(i), str2double(values{4}))
                sleepstagesOUT.stages(i,:) = 3;
            elseif strcmpi(sleepstagesIN(i), str2double(values{5}))
                sleepstagesOUT.stages(i,:) = 4;
            elseif strcmpi(sleepstagesIN(i), str2double(values{6}))
                sleepstagesOUT.stages(i,:) = 5;
            elseif strcmpi(sleepstagesIN(i), str2double(values{7}))
                sleepstagesOUT.stages(i,:) = 6;
            elseif strcmpi(sleepstagesIN(i), str2double(values{8}))
                sleepstagesOUT.stages(i,:) = 7;
            else
                sleepstagesOUT.stages = 7;
            end
            
        end
        
    else
        
        for i = 1:size(sleepstagesIN, 1)
            
            if strcmpi(sleepstagesIN(i), values{1})
                sleepstagesOUT.stages(i,:) = 0;
            elseif strcmpi(sleepstagesIN(i), values{2})
                sleepstagesOUT.stages(i,:) = 1;
            elseif strcmpi(sleepstagesIN(i), values{3})
                sleepstagesOUT.stages(i,:) = 2;
            elseif strcmpi(sleepstagesIN(i), values{4})
                sleepstagesOUT.stages(i,:) = 3;
            elseif strcmpi(sleepstagesIN(i), values{5})
                sleepstagesOUT.stages(i,:) = 4;
            elseif strcmpi(sleepstagesIN(i), values{6})
                sleepstagesOUT.stages(i,:) = 5;
            elseif strcmpi(sleepstagesIN(i), values{7})
                sleepstagesOUT.stages(i,:) = 6;
            elseif strcmpi(sleepstagesIN(i), values{8})
                sleepstagesOUT.stages(i,:) = 7;
            else
                sleepstagesOUT.stages = 7;
            end
        end
        
    end
   
else
    sleepstagesOUT.stages = zeros(size(sleepstagesIN), 1);
    
    if isa(sleepstagesIN(1), 'double')
        
        for i = 1:height(sleepstagesIN)
            
            if strcmpi(sleepstagesIN(i), str2double(values{1}))
                sleepstagesOUT.stages(i,:) = 0;
            elseif strcmpi(sleepstagesIN(i), str2double(values{2}))
                sleepstagesOUT.stages(i,:) = 1;
            elseif strcmpi(sleepstagesIN(i), str2double(values{3}))
                sleepstagesOUT.stages(i,:) = 2;
            elseif strcmpi(sleepstagesIN(i), str2double(values{4}))
                sleepstagesOUT.stages(i,:) = 3;
            elseif strcmpi(sleepstagesIN(i), str2double(values{5}))
                sleepstagesOUT.stages(i,:) = 4;
            elseif strcmpi(sleepstagesIN(i), str2double(values{6}))
                sleepstagesOUT.stages(i,:) = 5;
            elseif strcmpi(sleepstagesIN(i), str2double(values{7}))
                sleepstagesOUT.stages(i,:) = 6;
            elseif strcmpi(sleepstagesIN(i), str2double(values{8}))
                sleepstagesOUT.stages(i,:) = 7;
            else
                sleepstagesOUT.stages = 7;
            end
            
        end
        
    else
        
        for i = 1:length(sleepstagesIN)
            
            if strcmpi(sleepstagesIN(i), values{1})
                sleepstagesOUT.stages(i,:) = 0;
            elseif strcmpi(sleepstagesIN(i), values{2})
                sleepstagesOUT.stages(i,:) = 1;
            elseif strcmpi(sleepstagesIN(i), values{3})
                sleepstagesOUT.stages(i,:) = 2;
            elseif strcmpi(sleepstagesIN(i), values{4})
                sleepstagesOUT.stages(i,:) = 3;
            elseif strcmpi(sleepstagesIN(i), values{5})
                sleepstagesOUT.stages(i,:) = 4;
            elseif strcmpi(sleepstagesIN(i), values{6})
                sleepstagesOUT.stages(i,:) = 5;
            elseif strcmpi(sleepstagesIN(i), values{7})
                sleepstagesOUT.stages(i,:) = 6;
            elseif strcmpi(sleepstagesIN(i), values{8})
                sleepstagesOUT.stages(i,:) = 7;
            else
                sleepstagesOUT.stages = 7;
            end
        end
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



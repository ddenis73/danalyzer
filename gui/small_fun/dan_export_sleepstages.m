function sleepstagesOUT = dan_export_sleepstages(sleepstagesIN, values)

sleepstagesOUT = cell(length(sleepstagesIN.stages), 1);

for i = 1:length(sleepstagesIN.stages)
    
    if sleepstagesIN.stages(i) == 0
        if ~isempty(values{1})
            sleepstagesOUT{i} = values{1};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    elseif sleepstagesIN.stages(i) == 1
        if ~isempty(values{2})
            sleepstagesOUT{i} = values{2};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    elseif sleepstagesIN.stages(i) == 2
        if ~isempty(values{3})
            sleepstagesOUT{i} = values{3};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    elseif sleepstagesIN.stages(i) == 3
        if ~isempty(values{4})
            sleepstagesOUT{i} = values{4};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    elseif sleepstagesIN.stages(i) == 4
        if ~isempty(values{5})
            sleepstagesOUT{i} = values{5};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    elseif sleepstagesIN.stages(i) == 5
        if ~isempty(values{6})
            sleepstagesOUT{i} = values{6};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    elseif sleepstagesIN.stages(i) == 6
        if ~isempty(values{7})
            sleepstagesOUT{i} = values{7};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    elseif sleepstagesIN.stages(i) == 7
        if ~isempty(values{8})
            sleepstagesOUT{i} = values{8};
        else
            sleepstagesOUT{i} = num2str(sleepstagesIN.stages(i));
        end
    end 
end

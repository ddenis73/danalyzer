function dataOut = dan_field_search(specData, thingy, stages)

% Search a specData struct for spindles or so (thingy) in a particular
% sleep stage
specDataFields = fieldnames(specData);
fieldIndex = ~cellfun('isempty', regexp(specDataFields, thingy));

if any(fieldIndex)
    sf1    = fieldnames(specData.(specDataFields{fieldIndex}));
    
    if length(sf1) < 4
        sfIdx  = ~cellfun('isempty', regexp(sf1, stages));
        
        if ~isempty(sfIdx)
            
            sf2 = fieldnames(specData.(specDataFields{fieldIndex}).(sf1{sfIdx}));
            
            if isfield(specData.(specDataFields{fieldIndex}).(sf1{sfIdx}), 'label')
                dataOut = specData.(specDataFields{fieldIndex}).(sf1{sfIdx});
                
            else
                sf2 = fieldnames(specData.(specDataFields{fieldIndex}).(sf1{sfIdx}));
                
                sf2Idx = ismember(sf2, 'ind');
                if any(sf2Idx)
                    
                    if isfield(specData.(specDataFields{fieldIndex}).(sf1{sfIdx}).(sf2{sf2Idx}), 'label')
                        dataOut = specData.(specDataFields{fieldIndex}).(sf1{sfIdx}).(sf2{sf2Idx});
                    end
                    
                else
                    sf3Idx  = ismember(sf2, 'reduced');
                    
                    if any(sf3Idx)
                        if isfield(specData.(specDataFields{fieldIndex}).(sf1{sfIdx}).(sf2{sf3Idx}), 'label')
                            dataOut = specData.(specDataFields{fieldIndex}).(sf1{sfIdx}).(sf2{sf3Idx});
                        else
                            sf4 = fieldnames(specData.(specDataFields{fieldIndex}).(sf1{sfIdx}).(sf2{sf3Idx}));
                            sf4Idx = ismember(sf4, 'ind');
                            
                            if any(sf4Idx)
                                if isfield(specData.(specDataFields{fieldIndex}).(sf1{sfIdx}).(sf2{sf3Idx}).(sf4{sf4Idx}), 'label')
                                    dataOut = specData.(specDataFields{fieldIndex}).(sf1{sfIdx}).(sf2{sf3Idx}).(sf4{sf4Idx});
                                end
                            end
                        end
                    end
                end
            end
        end
        
    end
    
else
    dataOut = [];
end


if ~exist('dataOut', 'var')
    dataOut = [];
end

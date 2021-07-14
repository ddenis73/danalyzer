function [handles, data2plot] = dan_scale_psg_data(handles, data2plot)
% Scale the data so that it plots correctly with one channel above the next
% etc
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

for chan_i = 1:size(data2plot, 1)
    
    scaledData(chan_i,:) = data2plot(chan_i,:) * -1;
    
    if isempty(get(handles.scale_value, 'String'))
        set(handles.scale_value, 'String', '150')
    end
    
    data2plot(chan_i,:) = scaledData(chan_i,:) + ((size(data2plot,1)+1)-chan_i) *...
        str2double(get(handles.scale_value, 'String'));
        
end

        
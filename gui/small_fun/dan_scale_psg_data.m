function [handles, data2plot] = dan_scale_psg_data(handles, data2plot)

% Scale the data so that it plots correctly with one channel above the next
% etc

for chan_i = 1:size(data2plot, 1)
    
    scaledData(chan_i,:) = data2plot(chan_i,:) * -1;
    
    if isempty(get(handles.scale_value, 'String'))
        set(handles.scale_value, 'String', '150')
    end
    
    data2plot(chan_i,:) = scaledData(chan_i,:) + ((size(data2plot,1)+1)-chan_i) *...
        str2double(get(handles.scale_value, 'String'));
        
end

        
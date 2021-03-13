function handles = dan_prepare_specData(handles)

% Function to plot spindle detections etc. specDataIn is a struct
% containing detections from fun_detect_spindles and fun_detect_so

%%
% Now for each channel, find the start & end IDX of the event, look
% up the channel limits based on position in data, and draw a
% rectangle around the event

if exist('so', 'var')
    handles = dan_plot_detections(handles, so, [0.4940 0.1840 0.5560 0.3]);
end

if exist('spindles', 'var')
    handles = dan_plot_detections(handles, spindles, [0.9100 0.4100 0.1700 0.3]);
end
end
                                
                        
              
            
    
    
    




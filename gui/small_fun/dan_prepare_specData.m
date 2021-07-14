function handles = dan_prepare_specData(handles)
% Function to plot spindle detections etc. specDataIn is a struct
% containing detections from fun_sleep_spindles and fun_slow_oscillations

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
                                
                        
              
            
    
    
    




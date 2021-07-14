function handles = dan_mark_epoch(handles)
% Label an epoch as bad
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

epochIdx = str2double(get(handles.current_epoch_number, 'String'));

if handles.psg.ar.badepochs(epochIdx) == 0
    handles.psg.ar.badepochs(epochIdx) = 1;
elseif handles.psg.ar.badepochs(epochIdx) == 1
    handles.psg.ar.badepochs(epochIdx) = 0;
end

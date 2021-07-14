function handles = dan_make_spectogram(handles)
% Create a whole night spectogram on a single channel 

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

chanIdx = ismember(handles.montage.showChans,...
    get(handles.spectogram_string, 'String'));

if any(chanIdx)
    
    % Select the requested channel
    spectoData = handles.psg.data(chanIdx, :);
    
    % Split into 30 second segments
    spectoData = buffer(spectoData, handles.psg.hdr.srate * 30)';
    
    % Get PSD for each segment
    
    disp(['Creating spectogram at electrode: ' get(handles.spectogram_string, 'String') '...'])
    
    for seg_i = 1:size(spectoData, 1)
        [psd(seg_i,:), freqs] = pwelch(spectoData(seg_i,:), handles.psg.hdr.srate*5, [], [], handles.psg.hdr.srate); % Absolute power, temporal derivative to remove 1/f
    end
    
    Flims = [.05 20];
    scaleFactor = handles.psg.hdr.samples / size(spectoData,1);

    spectoPSD = 10*log10(psd(:,min(find(freqs>=Flims(1))):max(find(freqs<=Flims(2))))');
    
    handles.psg.stages.spectogram.specto = spectoPSD;
    handles.psg.stages.spectogram.freqLims = Flims;
    handles.psg.stages.spectogram.freqs = freqs;
    handles.psg.stages.spectogram.scaleFactor = scaleFactor;
    
else
    handles.psg.stages.spectogram.specto = [];
    handles.psg.stages.spectogram.hdr = [];
end
    
    

    
    
    
    
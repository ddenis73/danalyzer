function [tfr, times, freqs, empfwhm] = fun_tfr(data, srate, limits, varargin)
% Calculate time-frequency power on event-related data. Time-frequency
% decomposition is performed using complex Morlet wavelets, based on code
% described in:
%
% Cohen MX (2019). A better way to defreq_ine and describe Morlet wavelets 
% for time-frequency analysis. NeuroImage 199 (81-86).
%
% Required inputs:
%
% data: A channel x time x epoch array
%
% srate: Sampling rate of the data (in Hz)
%
% limits: Time points (in ms) for the start and the end of the epoch 
% [start end]
%
% Optional inputs:
%
% Frequencies: The minimum, maximum, and number of frequencies to analyze
% Default: linspace(2, 30, 40)
%
% Baseline: Time range (in ms) [baseStart baseEnd] to use as the baseline
% for normalization. Default = [] (no baseline, returns absolute power
% values)
%
% Normalization: Procedure for baseline normalization. Either: 'db'
% (decibels), 'perchange' (percent change), 'basediv' (baseline division),
% 'ztransform', 'z scores), 'none'. Default = 'none'. See Cohen (2014) for
% more details about each normalization procedure
%
% The following additional optional inputs are available if the method used
% is 'morlet'
%
% FWHM: Full-width half max of the wavelet (frequency resolution). Either a
% single value or an array indicating the FWHM at each frequency. Specifreq_ied
% in ms. Default = 500
%
% Outputs:
% 
% tfr: The time frequency data as a channel x frequency x time array
%
% times: The time (in seconds) for each time element in tfr
%
% freqs: The frequencty (in Hz) for each frequency element in tfr
%
% empfwhm: The resulting frequency resolution of the wavelets (in Hz)

%% © 2021 Dan Denis, PhD
%
% This function is part of the danalyzer toolbox. danalyzer is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU General Public License as published by the Free Software Foundation,
% either version 3 of the License or any later version.
%
% danalyzer is distributed with the hope that others will find it useful.
% It comes without any warranty; without even the implied warranty of
% merchantability or fitness for a particular purpose. See the GNU General
% Public License for more details.

% danalyzer is intended for research purposes only. Any commercial or
% medical use of this software is prohibited. The author accepts no
% responsibility for its use in this manner
%% Defaults for optional inputs

freqs    = linspace(2, 30, 40); % Frequencies to analyze
baseTime = []; % Baseline period
normProc = 'none'; % Baseline normalization
fwhm     = 500; % Full-width half max

if find(strcmpi(varargin, 'Frequencies'))
    freqs = varargin{find(strcmpi(varargin, 'frequencies'))+1};
end

if find(strcmpi(varargin, 'Baseline'))
    baseTime = varargin{find(strcmpi(varargin, 'Baseline'))+1};
end

if find(strcmpi(varargin, 'Normalization'))
    normProc = varargin{find(strcmpi(varargin, 'Normalization'))+1};
end

if find(strcmpi(varargin, 'FWHM'))
    fwhm = varargin{find(strcmpi(varargin, 'FWHM'))+1};
end

%% Additional setup

% Time indicies
times = limits(1)/1000:1/srate:limits(2)/1000;

if length(times) ~= size(data, 2) 
    times = times(1:size(data, 2));
end
    
% Timing parameters
[~,baseIdx(1)] = min(abs((times(1:end))-baseTime(1)/1000));
[~,baseIdx(2)] = min(abs((times(1:end))-baseTime(2)/1000)); % Baseline indices

[~, timeIdx(1)] = min(abs((times(1:end))-limits(1)/1000));
[~, timeIdx(2)] = min(abs((times(1:end))-limits(2)/1000)); % Time indices

baseIdx = baseIdx(1):baseIdx(2);
timeIdx = timeIdx(1):timeIdx(2);
%% Print TFR parameters

if isempty(baseTime)
    basePeriod = 'No baseline';
else
    basePeriod = [num2str(baseTime(1)) ' - ' num2str(baseTime(2)) 'ms'];
end

if length(fwhm) == 1
    
    fprintf(['\n\nTime frequency decomposition on ' num2str(size(data, 1)) ' channels with the following parameters:\n\n'...
        'Time limits:      ' num2str(limits(1)) ' - ' num2str(limits(2)) 'ms\n'...
        'Frequency limits: ' num2str(freqs(1)) ' - ' num2str(freqs(end)) 'Hz\n'...
        'FWHM:             ' num2str(fwhm) 'ms\n'...
        'Baseline period:  ' basePeriod '\n'...
        'Normalization:    ' normProc '\n']);
    
else
    
    fprintf(['\n\nTime frequency decomposition on ' num2str(size(data, 1)) ' channels with the following parameters:\n\n'...
        'Time limits:      ' num2str(limits(1)) ' - ' num2str(limits(2)) 'ms\n'...
        'Frequency limits: ' num2str(freqs(1)) ' - ' num2str(freqs(end)) 'Hz\n'...
        'FWHM:             ' num2str(fwhm(1)) ' - ' num2str(fwhm(end)) 'ms\n'...
        'Baseline period:  ' basePeriod '\n'...
        'Normalization:    ' normProc '\n']);
end
%% Time-frequency decomposition using complex Morlet wavelets

% Setup wavelet and convolution parameters

if length(fwhm) == 1
    fwhm = repmat(fwhm, 1, length(freqs));
end

wavet = -5:1/srate:5;
halfw = floor(length(wavet)/2)+1;
nConv = size(data, 2)*size(data, 3) + length(wavet) - 1;

% Initialize the channel-time-frequency matrix
tfr = zeros(size(data, 1), length(freqs), length(timeIdx));

% Loop over each channel
for chan_i = 1:size(data, 1)
    tic
    msg = ['Working on Channel ', num2str(chan_i), '...'];
    fprintf(msg); % Write new msg
    
    % FFT of the data
    dataX = fft(reshape(data(chan_i, :, :), 1, []), nConv);
    
    % Loop over each frequency
    for freq_i = 1:length(freqs)
        
        % create wavelet
        waveX = fft(exp(2*1i*pi*freqs(freq_i)*wavet).*exp(-4*log(2)*wavet.^2/(fwhm(freq_i)/1000).^2),nConv);
        waveX = waveX./max(waveX); % normalize
        
        % convolve
        as = ifft(waveX.*dataX);
        % trim and reshape
        as = reshape(as(halfw:end-halfw+1),size(data, 2),size(data, 3));
        
        % Power
        tfr(chan_i, freq_i, :) = mean(abs(as).^2 ,2); 
        
        % Empirical FWHM
        hz  = linspace(0, srate, nConv);
        idx = dsearchn(hz', freqs(freq_i));
        fx  = abs(waveX);
        empfwhm(chan_i, freq_i) = hz(idx-1+dsearchn(fx(idx:end)',.5)) - hz(dsearchn(fx(1:idx)',.5));
    end
    
    %% Baseline normalization
    
    if ~isempty(baseTime) && ~strcmpi(normProc, 'none')
        if strcmpi(normProc, 'db') || strcmpi(normProc, 'decibel')
            basePower    = mean(tfr(chan_i, :, baseIdx), 3);
            tfr(chan_i,:,:) = 10 * log10(bsxfun(@rdivide, tfr(chan_i,:,:), basePower));
            
        elseif strcmpi(normProc, 'perchange') || strcmpi(normProc, 'pctchangw') || strcmpi(normProc, 'percent')
            basePower    = mean(tfr(chan_i, :, baseIdx), 3);
            tfr(chan_i,:,:) = 100 * (squeeze(tfr(chan_i,:,:)) - repmat(basePower, size(data, 2), 1)') ./ repmat(basePower, size(data, 2), 1)';
            
        elseif strcmpi(normProc, 'basediv') || strcmpi(normProc, 'division')
            basePower    = mean(tfr(chan_i, :, baseIdx), 3);
            tfr(chan_i,:,:) = squeeze(tfr(chan_i,:,:)) ./ repmat(basePower, size(data, 2), 1)';
            
        elseif strcmpi(normProc, 'ztransform')
            basePower    = tfr(chan_i,:,baseIdx);
            tfr(chan_i,:,:) = (squeeze(tfr(chan_i,:,:)) - repmat(mean(basePower,3), size(tfr(ch_i,:,:), 3), 1)') ./ repmat(std(basePower, [], 3), size(tfr(ch_i,:,:), 3), 1)';
        end
    end
    
    detectTime = toc;
    disp([' Completed in ' num2str(detectTime) ' seconds'])
    
end
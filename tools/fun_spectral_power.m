function [spectralPower, freqs] = fun_spectral_power(data, srate, varargin)
% Obtain estimates of power spectral density (PSD) in EEG data using the pwelch
% function. The default settings obtain PSD estimates on the temporal
% derivative of the data using a Hamming window (5 seconds long, 50%
% overlap)
%
% Required input:
%
% data = A channel x timepoints array
%
% srate = The sampling rate of the data (in Hz)
%
% Optional inputs:
%
% 'WindowSize' = The size of the Hamming window (in seconds). Default = 5
%
% 'WindowOverlap' = Window overlap, expressed as a proportion. Default =
% 0.5
%
% 'Method' = Return estimates as PSD or power. Default = PSD
%
% 'Transformation' = Method to counter 1/f scaling inherent to the EEG
% power spectrum. 'diff' estimates PSD on the temporal derivative of the
% data. 'log' log transform PSD estimates obtained from the EEG time
% series. 'dB' performs a decibel transformation of the PSD estimates
% obtained from the EEG time series. 'none' returns absolute PSD. Default =
% 'diff'.
%
% Outputs:
%
% spectralPower = A frequency x channel array containing the PSD estimate
% for each frequency bin from each channel
%
% freqs = A nx1 array indicating the frequency at each bin (each row of
% spectralPower)
%
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
%% Default settings

winSize     = 5;
winOverlap  = 0.5;
method      = 'PSD';
transform   = 'diff';
freqBands   = [0 1; 1 4; 4 8; 8 12; 12 15; 15 25];
bandAverage = 'average';


if find(strcmpi(varargin, 'WindowSize'))
    winSize = varargin{find(strcmpi(varargin, 'WindowSize'))+1};
end

if find(strcmpi(varargin, 'WindowOverlap'))
    winOverlap = varargin{find(strcmpi(varargin, 'WindowOverlap'))+1};
end

if find(strcmpi(varargin, 'Method'))
    method = varargin{find(strcmpi(varargin, 'Method'))+1};
end

if find(strcmpi(varargin, 'Transformation'))
    transform = varargin{find(strcmpi(varargin, 'Transformation'))+1};
end

if find(strcmpi(varargin, 'FrequencyBands'))
    freqBands = varargin{find(strcmpi(varargin, 'Transformation'))+1};
end

if find(strcmpi(varargin, 'BandMethod'))
    bandAverage = varargin{find(strcmpi(varargin, 'BandMethod'))+1};
end


fprintf(['Calculating power spectral density on ' num2str(size(data, 1)) ' channels using pwelch...\n\n'])

%% Perform PSD
tic
if strcmpi(transform, 'diff')
    if strcmpi(method, 'PSD')
        [spectralPower, freqs] = pwelch(diff(data,1,2)', srate * winSize, winOverlap * srate * winSize, [], srate); % PSD, temporal derivative to remove 1/f
    elseif strcmpi(method, 'power')
        [spectralPower, freqs] = pwelch(diff(data,1,2)', srate * winSize, winOverlap * srate * winSize, [], srate, 'power'); % Power, temporal derivative to remove 1/f
    end
    
else
    if strcmpi(method, 'PSD')
        [spectralPower, freqs] = pwelch(data', srate * winSize, winOverlap * srate * winSize, [], srate); % PSD
    elseif strcmpi(method, 'power')
        [spectralPower, freqs] = pwelch(data', srate * winSize, winOverlap * srate * winSize, [], srate, 'power'); % Power
    end
    
    if strcmpi(transform, 'log')
        spectralPower = log10(spectralPower);
    elseif strcmpi(transform, 'db') || strcmpi(transform, 'decibel')
        spectralPower = 10*log10(spectralPower);
    end
end
psdTime = toc;

fprintf(['PSD calculated for ' num2str(length(freqs))...
    ' frequencies from ' num2str(freqs(1)) ' to ' num2str(freqs(end)) 'Hz in ' num2str(psdTime) ' seconds.\n']);
pause(0.01);

if strcmpi(transform, 'diff')
    fprintf('Derived from the temporal derivative of the input data\n');
elseif strcmpi(transform, 'log')
    fprintf('Data transformed to log scale\n');
elseif strcmpi(transform, 'db')
    fprintf('Data transformed to db scale\n');
end

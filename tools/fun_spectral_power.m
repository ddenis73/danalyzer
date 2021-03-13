function [spectralPower, freqs, bandPowerA, bandPowerR] = fun_spectral_power(data, srate, varargin)
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
% 'FrequencyBands' = An nx2 array containing a lower and upper frequency
% for each frequency band. Default = [0 1; 1 4; 4 8; 8 12; 12 15; 15 25]
%
% 'BandMethod' = Method for how to arrive and band power estimates.
% 'average' returns the mean PSD for each frequency bin in the band. 'sum'
% returns the sum PSD for each frequency bin in the band.
%
% Outputs:
%
% spectralPower = A frequency x channel array containing the PSD estimate
% for each frequency bin from each channel
%
% freqs = A nx1 array indicating the frequency at each bin (each row of
% spectralPower)
%
% bandPowerA = Averaged/summed PSD estimates in each specified frequency
% band.
%
% bandPowerR = Relative power in each frequency band. Calculate as the the
% % of total power from the lowest to the highest requested frequency.
%% Copyright (c) 2021 Dan Denis, PhD
%
% This function is part of the danalyzer toolbox.
%
% danalyzer is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
%
% danalyzer is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with danalyzer.  If not, see <http://www.gnu.org/licenses/>.
%
% danalyzer is intended for research purposes only. Any commercial or medical
% use of this software is prohibited. The authors accept no
% responsibility for its use in this manner.
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

%% Calculate band power

% Initialize
bandPowerA = zeros(length(freqBands), size(spectralPower, 2));

% Power in each band
for i = 1:length(freqBands)
    
    if strcmpi(bandAverage, 'average')
        bandPowerA(i, :) = mean(spectralPower(freqs > freqBands(i, 1) & freqs <= freqBands(i, 2), :));
    elseif strcmpi(bandAverage, 'sum')
        bandPowerA(i, :) = sum(spectralPower(freqs > freqBands(i, 1) & freqs >= freqBands(i, 2), :));
    end
    
end
        
% Relative power (% of total power from lowest to highest frequency requested)
bandPowerR = (bandPowerA ./ sum(bandPowerA)) * 100;

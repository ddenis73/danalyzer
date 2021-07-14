function spindleSummary = spindlesum(spindles, srate, samples)
% Summarize sleep spindle features. Calculates spindle density
% (spindles/min) and gets average value of spindle features on each channel
%
% Required inputs:
%
% spindles: A structure containing spindle data (output of
% fun_sleep_spindles)
%
% srate: The sampling rate of the data (in Hz)
%
% samples: The length of the data (in samples)
%
% Outputs:
%
% spindleSummary: Summary statistics for spindle features on each channel
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
%%
for chan_i = 1:length(spindles)
    
    if isempty(spindles(chan_i).detSample) % no spindles on this channel
        spindleSummary(chan_i).chan                 = spindles(chan_i).label;
        spindleSummary(chan_i).spindleCount         = 0;
        spindleSummary(chan_i).spindleDensity       = 0;
        spindleSummary(chan_i).spindleAmplitude     = NaN;
        spindleSummary(chan_i).spindleDuration      = NaN;
        spindleSummary(chan_i).spindleFrequency     = NaN;
        spindleSummary(chan_i).spindleSigma         = NaN;
        spindleSummary(chan_i).spindleEnergy        = NaN;
        spindleSummary(chan_i).spindleCycles        = NaN;
        spindleSummary(chan_i).spindleBumps         = NaN;
        spindleSummary(chan_i).spindleSymmetry      = NaN;
        spindleSummary(chan_i).spindleFreqGradient  = NaN;
        spindleSummary(chan_i).spindleFano          = NaN;
        spindleSummary(chan_i).spindleRaisingSlope  = NaN;
        spindleSummary(chan_i).spindleDroppingSlope = NaN;
        spindleSummary(chan_i).spindleCorrCoef      = NaN;
        spindleSummary(chan_i).spindleRefractory    = NaN;
        
    else
        spindleSummary(chan_i).chan                 = spindles(chan_i).label;
        spindleSummary(chan_i).spindleCount         = spindles(chan_i).count;
        spindleSummary(chan_i).spindleDensity       = spindles(chan_i).count/(samples/(srate*60));
        spindleSummary(chan_i).spindleAmplitude     = nanmean(spindles(chan_i).peakAmp);
        spindleSummary(chan_i).spindleDuration      = nanmean(spindles(chan_i).duration);
        spindleSummary(chan_i).spindleFrequency     = nanmean(spindles(chan_i).peakFreq);
        spindleSummary(chan_i).spindleSigma         = nanmean(spindles(chan_i).sigmaPower);
        spindleSummary(chan_i).spindleEnergy        = nanmean(spindles(chan_i).energy);
        spindleSummary(chan_i).spindleCycles        = nanmean(spindles(chan_i).numCycles);
        spindleSummary(chan_i).spindleBumps         = nanmean(spindles(chan_i).numBumps);
        spindleSummary(chan_i).spindleSymmetry      = nanmean(spindles(chan_i).symmetry);
        spindleSummary(chan_i).spindleFreqGradient  = nanmean(spindles(chan_i).freqGradient);
        spindleSummary(chan_i).spindleFano          = nanmean(spindles(chan_i).fano);
        spindleSummary(chan_i).spindleRaisingSlope  = nanmean(spindles(chan_i).raisingSlope);
        spindleSummary(chan_i).spindleDroppingSlope = nanmean(spindles(chan_i).droppingSlope);
        spindleSummary(chan_i).spindleCorrCoef      = nanmean(spindles(chan_i).corrCoef);
        spindleSummary(chan_i).spindleRefractory    = nanmean(spindles(chan_i).refrPeriod);
    end
end








function soSummary = sosum(so, srate, samples)
% Summarize slow oscillation features. Calculates slow oscillation density
% (so/min) and gets average value of slow oscillation features on each channel
%
% Required inputs:
%
% so: A structure containing slow oscillation data (output of
% fun_slow_oscillationss)
%
% srate: The sampling rate of the data (in Hz)
%
% samples: The length of the data (in samples)
%
% Outputs:
%
% soSummary: Summary statistics for slow oscillation features on each channel
%
%%
for chan_i = 1:length(so)
    soSummary(chan_i).chan              = so(chan_i).label;
    soSummary(chan_i).soCount           = so(chan_i).count;
    soSummary(chan_i).soDensity         = so(chan_i).count / (samples / srate / 60);
    soSummary(chan_i).soDuration        = nanmean(so(chan_i).duration);
    soSummary(chan_i).soPPAmplitude     = nanmean(so(chan_i).ppAmp);
    soSummary(chan_i).soPPAmplitudeNorm = nanmean(so(chan_i).ppAmpNorm);
    soSummary(chan_i).soPPAmplitudeMad  = nanmean(so(chan_i).ppAmpMad);
    soSummary(chan_i).soNegativePeak    = nanmean(so(chan_i).negPeak);
    soSummary(chan_i).soPositivePeak    = nanmean(so(chan_i).posPeak);
    soSummary(chan_i).soNegativeSlope   = nanmean(so(chan_i).negSlope);
    soSummary(chan_i).soPositiveSlope   = nanmean(so(chan_i).posSlope);
    soSummary(chan_i).soPPSlope         = nanmean(so(chan_i).ppSlope);
end


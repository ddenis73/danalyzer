function cpDiff = couplingdiffs(coupling, spindles, so, srate, samples)
% Summarize slow oscillation and spindle parameters separately for coupled
% and uncoupled events
%
% Required inputs:
%
% coupling: A structure containing coupling data (output of
% fun_so_spindle_coupling)
%
% spindles: A structure containing spindle data (output of
% fun_sleep_spindles)
%
% so: A structure containing slow oscillation data (output of
% fun_slow_oscillations)
%
% srate: The sampling rate of the data (in Hz)
%
% samples: The length of the data (in samples)
%
% Output:
%
% cpDiff: A structure summarizing coupled and uncoupled spindle and slow
% oscillation parameters on each channel
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
for chan_i = 1:length(coupling)
    
    coupledSpindleIdx    = ~isnan(coupling(chan_i).soPhasePeak);
    uncoupledSpindleIdx  = isnan(coupling(chan_i).soPhasePeak);
    coupledSOIdx         = coupling(chan_i).soID(~isnan(coupling(chan_i).soID));
    uncoupledSOIdx       = setdiff(1:length(so(chan_i).startSample), coupledSOIdx);
    
    cpDiff(chan_i).chan      = coupling(chan_i).label;
    
    
    if spindles(chan_i).count > 0
        cpDiff(chan_i).spindleCount1         = sum(~isnan(coupling(chan_i).soID));
        cpDiff(chan_i).spindleCount2         = sum(isnan(coupling(chan_i).soID));
        cpDiff(chan_i).spindleDensity1       = cpDiff(chan_i).spindleCount1 / (samples / (srate * 60));
        cpDiff(chan_i).spindleDensity2       = cpDiff(chan_i).spindleCount2 / (samples / (srate * 60));
        cpDiff(chan_i).spindleDuration1      = nanmean(spindles(chan_i).duration(coupledSpindleIdx));
        cpDiff(chan_i).spindleDuration2      = nanmean(spindles(chan_i).duration(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleAmplitude1     = nanmean(spindles(chan_i).peakAmp(coupledSpindleIdx));
        cpDiff(chan_i).spindleAmplitude2     = nanmean(spindles(chan_i).peakAmp(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleFrequency1     = nanmean(spindles(chan_i).peakFreq(coupledSpindleIdx));
        cpDiff(chan_i).spindleFrequency2     = nanmean(spindles(chan_i).peakFreq(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleEnergy1        = nanmean(spindles(chan_i).energy(coupledSpindleIdx));
        cpDiff(chan_i).spindleEnergy2        = nanmean(spindles(chan_i).energy(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleSigma1         = nanmean(spindles(chan_i).sigmaPower(coupledSpindleIdx));
        cpDiff(chan_i).spindleSigma2         = nanmean(spindles(chan_i).sigmaPower(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleNumCycles1     = nanmean(spindles(chan_i).numCycles(coupledSpindleIdx));
        cpDiff(chan_i).spindleNumCycles2     = nanmean(spindles(chan_i).numCycles(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleNumBumps1      = nanmean(spindles(chan_i).numBumps(coupledSpindleIdx));
        cpDiff(chan_i).spindleNumBumps2      = nanmean(spindles(chan_i).numBumps(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleSymmetry1      = nanmean(spindles(chan_i).symmetry(coupledSpindleIdx));
        cpDiff(chan_i).spindleSymmetry2      = nanmean(spindles(chan_i).symmetry(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleFreqGradient1  = nanmean(spindles(chan_i).freqGradient(coupledSpindleIdx));
        cpDiff(chan_i).spindleFreqGradient2  = nanmean(spindles(chan_i).freqGradient(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleFano1          = nanmean(spindles(chan_i).fano(coupledSpindleIdx));
        cpDiff(chan_i).spindleFano2          = nanmean(spindles(chan_i).fano(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleRaisingSlope1  = nanmean(spindles(chan_i).raisingSlope(coupledSpindleIdx));
        cpDiff(chan_i).spindleRaisingSlope2  = nanmean(spindles(chan_i).raisingSlope(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleDroppingSlope1 = nanmean(spindles(chan_i).droppingSlope(coupledSpindleIdx));
        cpDiff(chan_i).spindleDroppingSlope2 = nanmean(spindles(chan_i).droppingSlope(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleRefrPeriod1    = nanmean(spindles(chan_i).refrPeriod(coupledSpindleIdx));
        cpDiff(chan_i).spindleRefrPeriod2    = nanmean(spindles(chan_i).refrPeriod(uncoupledSpindleIdx));
        cpDiff(chan_i).spindleCorrCoef1      = nanmean(spindles(chan_i).corrCoef(coupledSpindleIdx));
        cpDiff(chan_i).spindleCorrCoef2      = nanmean(spindles(chan_i).corrCoef(uncoupledSpindleIdx));

    else
        cpDiff(chan_i).spindleCount1         = 0;
        cpDiff(chan_i).spindleCount2         = 0;
        cpDiff(chan_i).spindleDensity1       = 0;
        cpDiff(chan_i).spindleDensity2       = 0;
        cpDiff(chan_i).spindleDuration1      = NaN;
        cpDiff(chan_i).spindleDuration2      = NaN;
        cpDiff(chan_i).spindleAmplitude1     = NaN;
        cpDiff(chan_i).spindleAmplitude2     = NaN;
        cpDiff(chan_i).spindleFrequency1     = NaN;
        cpDiff(chan_i).spindleFrequency2     = NaN;
        cpDiff(chan_i).spindleEnergy1        = NaN;
        cpDiff(chan_i).spindleEnergy2        = NaN;
        cpDiff(chan_i).spindleSigma1         = NaN;
        cpDiff(chan_i).spindleSigma2         = NaN;
        cpDiff(chan_i).spindleNumCycles1     = NaN;
        cpDiff(chan_i).spindleNumCycles2     = NaN;
        cpDiff(chan_i).spindleNumBumps1      = NaN;
        cpDiff(chan_i).spindleNumBumps2      = NaN;
        cpDiff(chan_i).spindleSymmetry1      = NaN;
        cpDiff(chan_i).spindleSymmetry2      = NaN;
        cpDiff(chan_i).spindleFreqGradient1  = NaN;
        cpDiff(chan_i).spindleFreqGradient2  = NaN;
        cpDiff(chan_i).spindleFano1          = NaN;
        cpDiff(chan_i).spindleFano2          = NaN;
        cpDiff(chan_i).spindleRaisingSlope1  = NaN;
        cpDiff(chan_i).spindleRaisingSlope2  = NaN;
        cpDiff(chan_i).spindleDroppingSlope1 = NaN;
        cpDiff(chan_i).spindleDroppingSlope2 = NaN;
        cpDiff(chan_i).spindleRefrPeriod1    = NaN;
        cpDiff(chan_i).spindleRefrPeriod2    = NaN;
        cpDiff(chan_i).spindleCorrCoef1      = NaN;
        cpDiff(chan_i).spindleCorrCoef2      = NaN;
    end
    
    cpDiff(chan_i).soCount1            = sum(~isnan(coupling(chan_i).soID));
    cpDiff(chan_i).soCount2            = length(uncoupledSOIdx);
    cpDiff(chan_i).soDensity1          = cpDiff(chan_i).soCount1 / (samples / (srate * 60));
    cpDiff(chan_i).soDensity2          = cpDiff(chan_i).soCount2 / (samples / (srate * 60));
    cpDiff(chan_i).soDuration1         = nanmean(so(chan_i).duration(coupledSOIdx));
    cpDiff(chan_i).soDuration2         = nanmean(so(chan_i).duration(uncoupledSOIdx));
    cpDiff(chan_i).soPPAmplitude1      = nanmean(so(chan_i).ppAmp(coupledSOIdx));
    cpDiff(chan_i).soPPAmplitude2      = nanmean(so(chan_i).ppAmp(uncoupledSOIdx));
    cpDiff(chan_i).soPPAmplitudeNorm1  = nanmean(so(chan_i).ppAmpNorm(coupledSOIdx));
    cpDiff(chan_i).soPPAmplitudeNorm2  = nanmean(so(chan_i).ppAmpNorm(uncoupledSOIdx));
    cpDiff(chan_i).soPPAmplitudeMad1   = nanmean(so(chan_i).ppAmpMad(coupledSOIdx));
    cpDiff(chan_i).soPPAmplitudeMad2   = nanmean(so(chan_i).ppAmpMad(uncoupledSOIdx));
    cpDiff(chan_i).soNegativePeak1     = nanmean(so(chan_i).negPeak(coupledSOIdx));
    cpDiff(chan_i).soNegativePeak2     = nanmean(so(chan_i).negPeak(uncoupledSOIdx));
    cpDiff(chan_i).soPositivePeak1     = nanmean(so(chan_i).posPeak(coupledSOIdx));
    cpDiff(chan_i).soPositivePeak2     = nanmean(so(chan_i).posPeak(uncoupledSOIdx));
    cpDiff(chan_i).soNegativeSlope1    = nanmean(so(chan_i).negSlope(coupledSOIdx));
    cpDiff(chan_i).soNegativeSlope2    = nanmean(so(chan_i).negSlope(uncoupledSOIdx));
    cpDiff(chan_i).soPositiveSlope1    = nanmean(so(chan_i).posSlope(coupledSOIdx));
    cpDiff(chan_i).soPositiveSlope2    = nanmean(so(chan_i).posSlope(uncoupledSOIdx));
    cpDiff(chan_i).soPPSlope1          = nanmean(so(chan_i).ppSlope(coupledSOIdx));
    cpDiff(chan_i).soPPSlope2          = nanmean(so(chan_i).ppSlope(uncoupledSOIdx));
    
end

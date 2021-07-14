function cpSummary = couplingsum(coupling, srate, samples)
% Summarize coupling features. Calculates coupled and uncoupled density,
% coupling phase, and coupling strength. circStats toolbox required to
% calculate average phase and coupling strength
%
% Required inputs:
%
% coupling: A structure containing coupling data (output of
% fun_so_spindle_coupling)
%
% srate: The sampling rate of the data (in Hz)
%
% samples: The length of the data (in samples)
%
% Outputs:
%
% cpSummary: Summary statistics for coupling on each channel
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
    
    % circStats functions cannot handle NaN. Need to remove first
    
    % Phase
    peakPhase = coupling(chan_i).soPhasePeak;
    peakPhase(isnan(peakPhase)) = [];
    
    startPhase = coupling(chan_i).soPhaseStart;
    startPhase(isnan(startPhase)) = [];
    
    endPhase = coupling(chan_i).soPhaseEnd;
    endPhase(isnan(endPhase)) = [];
    
    % Strength
    peakStrength = coupling(chan_i).soPhasePeak;
    peakStrength(isnan(peakStrength)) = [];
    
    if length(peakStrength) == 1
        peakStrength = [];
    end
    
    startStrength = coupling(chan_i).soPhaseStart;
    startStrength(isnan(startStrength)) = [];
    
    if length(startStrength) == 1
        startStrength = [];
    end
    
    endStrength = coupling(chan_i).soPhaseEnd;
    endStrength(isnan(endStrength)) = [];
    
    if length(endStrength) == 1
        endStrength = [];
    end

    cpSummary(chan_i).chan                     = coupling(chan_i).label;
    cpSummary(chan_i).couplingPercent          = sum(~isnan(coupling(chan_i).soID)) / coupling(chan_i).spindleCount * 100;
    cpSummary(chan_i).soCouplingPercent        = sum(~isnan(coupling(chan_i).soID)) / coupling(chan_i).soCount * 100;
    cpSummary(chan_i).couplingCount1           = sum(~isnan(coupling(chan_i).soID));
    cpSummary(chan_i).couplingCount2           = sum(isnan(coupling(chan_i).soID));
    cpSummary(chan_i).couplingDensity1         = cpSummary(chan_i).couplingCount1 / (samples / (srate * 60));
    cpSummary(chan_i).couplingDensity2         = cpSummary(chan_i).couplingCount2 / (samples / (srate * 60));
    
    if ~isempty(peakPhase) && ~isempty(which('circ_mean'))
        cpSummary(chan_i).couplingPeakPhase    = circ_mean(peakPhase, [], 2);
    else
        cpSummary(chan_i).couplingPeakPhase    = NaN;
    end
    
    if ~isempty(startPhase) && ~isempty(which('circ_mean'))
        cpSummary(chan_i).couplingStartPhase    = circ_mean(startPhase, [], 2);
    else
        cpSummary(chan_i).couplingStartPhase    = NaN;
    end
    
    if ~isempty(endPhase) && ~isempty(which('circ_mean'))
        cpSummary(chan_i).couplingEndPhase    = circ_mean(endPhase, [], 2);
    else
        cpSummary(chan_i).couplingEndPhase    = NaN;
    end
    
    if ~isempty(which('circ_r'))
        peakVec  = circ_r(peakStrength, [], [], 2);
        startVec = circ_r(startStrength, [], [], 2);
        endVec   = circ_r(endStrength, [], [], 2);
    else
        peakVec  = [];
        startVec = [];
        endVec   = [];
    end
        
    if ~isempty(peakVec)
        cpSummary(chan_i).couplingPeakStrength = peakVec;
    else
        cpSummary(chan_i).couplingPeakStrength = NaN;
    end

    if ~isempty(startVec)
        cpSummary(chan_i).couplingStartStrength = startVec;
    else
        cpSummary(chan_i).couplingStartStrength = NaN;
    end    
    
    if ~isempty(endVec)
        cpSummary(chan_i).couplingEndStrength = endVec;
    else
        cpSummary(chan_i).couplingEndStrength = NaN;
    end
    
    clear peakPhase startPhase endPhase peakStrength startStrength endStrength
    
end




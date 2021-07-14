function [cpAll, cpMean, cpDiff, cpProb] = fun_so_spindle_coupling(soData, ssData, chans, srate, soEvents, ssEvents, varargin)
% Slow oscillation-spindle coupling. Automatically detects coupling
% events on multi-channel data and returns index of coupled and uncoupled
% spindles as well as coupling parameters. Requires the circStats toolbox
% to calculate mean coupling phase and coupling strength.
%
% Required inputs:
%
% soData: A channel x timepoints array, filtered in the SO band (e.g.
% .5-4Hz)
%
% ssData: A channel x timepoints array, filtered in the spindle band (e.g.
% 12-15Hz)
%
% chans: cell {1xn} with the channel labels. If [], will default to
% channel numbers (e.g. 1, 2, 3 etc.)
%
% srate: The sampling rate of the data (in Hz)
%
% soEvents: A struct containing all slow oscillation events (output from
% fun_slow_oscillations)
%
% ssEvents: A struct containing all sleep spindle events (output from
% fun_sleep_spindles)
%
% Optional inputs:
%
% 'CouplingProbability' = An nx2 array containing information required for
% coupling probability. [samples numPermutations]. samples = the
% length of the data (in samples), numPermutations = Number of
% permutations. Default = [] (do not calculate coupling probability
%
% Outputs:
%
% cpAll: A struct containing each detected spindle on each channel and
% their coupling to slow oscillations
%
% cpAll: A struct containing average slow oscillation-spindle coupling
% features (e.g. coupled density, mean phase, coupling strength etc.) on
% each channel
%
% cpDiff: A struct containing average slow oscillation and spindle
% parameters for coupled and uncoupled events
%
% cpProb: A struct containing coupling probabilites for each channel
%
%%
% Authors:  Dan Denis
%           Dimitrios Mylonas
% Date:     2021-07-14
%
% Remarks:
%   Free use and modification of this code is permitted, provided that any
%   modifications are also freely distributed
%
%   When using this code or modifications of this code, please cite:
%       Denis D (2021). danalyzer. DOI: 10.5281/zenodo.5104418
%% Defaults for optional inputs

couplingProb = [];
if find(strcmpi(varargin, 'CouplingProbability'))
    couplingProb = varargin{find(strcmpi(varargin, 'CouplingProbability'))+1};
end


%% Calculate phase of SO filtered data and amplitude of spindle filtered data
fprintf(['\n\nDetecting slow oscillation-spindle coupling events on ' num2str(size(soData, 1)) ' channels.\n\n'])
pause(0.5);

% Calculate phase of the SO filtered signal
disp('Calculating slow oscillation phase');
soPhase = angle(hilbert(soData')); % Transpose because hilbert and angle operate columnwise
soPhase = soPhase'; % Transpose back to channel x time

% Calculate amplitude of the SS filtered signal
disp('Calculating spindle amplitude')
spindleEnv = abs(hilbert(ssData'));
spindleEnv = spindleEnv';


%% Calculate coupling on each channel

nChannels = size(soData, 1);

for chan_i = 1:nChannels
    tic
    msg = ['Working on Channel ',chans{chan_i}, '...'];
    fprintf(msg); % Write new msg
    
    if ssEvents(chan_i).count > 0
        
        if ~isempty(ssEvents(chan_i).peakLoc)
            
            % Find the channel row in the spindle event file
            channel = chans{chan_i};
            chanIdx = find(strcmp(channel, {ssEvents.label}));
            
            % Location of spindle peak, start, end (samples)
            peakSample  = ssEvents(chanIdx).peakLoc;
            startSample = ssEvents(chanIdx).startSample;
            endSample   = ssEvents(chanIdx).endSample;
            
            % Discard spindles detected in the first & last two seconds
            idx = find(peakSample <= srate*2 | peakSample >= size(ssData, 2) - srate*2);
            peakSample (idx)  = [];
            startSample (idx) = [];
            endSample(idx)    = [];
            
            % Preallocate memory
            ppSOAmp        = zeros(1,length(peakSample));
            ppSOAmpNorm    = zeros(1,length(peakSample));
            soNegPeak      = zeros(1,length(peakSample));
            soDur          = zeros(1,length(peakSample));
            soPhasePeak    = zeros(1,length(peakSample));
            soPhaseStart   = zeros(1,length(peakSample));
            soPhaseEnd     = zeros(1,length(peakSample));
            soNegSlope     = zeros(1,length(peakSample));
            soPosSlope     = zeros(1,length(peakSample));
            soPPSlope      = zeros(1,length(peakSample));
            soId           = NaN(1,length(peakSample));
            spindlePeakAmp = zeros(1,length(peakSample));
            spindleSteep   = zeros(1,length(peakSample));
            
            % Number of spindles and so
            spindleCount = ssEvents(chan_i).count;
            soCount = soEvents(chan_i).count;
            
            %% Loop for each spindle
            for ss = 1:length(peakSample)
                
                % Find spindle peak amplitude
                if ~isnan(peakSample(ss))
                    spindlePeakAmp(ss) = spindleEnv(chan_i, peakSample(ss));
                else
                    spindlePeakAmp(ss) = NaN;
                end
                
                %% check whether the spindle peak occurs within the timecourse of a SO
                soIdx = find(soEvents(chan_i).startSample < peakSample(ss) & soEvents(chan_i).endSample > peakSample(ss));
                
                if  ~isempty(soIdx)
                    calcPhase = 1;
                else
                    calcPhase = 0;
                end
                
                % Calculate steepness of spindle
                if ~isnan(peakSample(ss))
                    spindleSteep(ss) = (spindleEnv(chan_i,peakSample(ss)) - spindleEnv(chan_i,startSample(ss)))/((peakSample(ss)-startSample(ss))/srate);
                else
                    spindleSteep(ss) = NaN;
                end
                %% Compute SW phase ONLY IF you found a SW within spindle window
                if calcPhase
                    
                    %% Keep the idx of the sw that cooccured with the spindle
                    soId(ss) = soIdx;
                    
                    %% Calculate peak to peak SW amplitude within the window
                    % Max and min sw amplitude
                    soNegPeak(ss)    = soEvents(chan_i).negPeak(soIdx);
                    ppSOAmp(ss)      = soEvents(chan_i).ppAmp(soIdx);
                    ppSOAmpNorm(ss)  = soEvents(chan_i).ppAmpNorm(soIdx);
                    soDur(ss)        = soEvents(chan_i).duration(soIdx);
                    soNegSlope(ss)   = soEvents(chan_i).negSlope(soIdx);
                    soPosSlope(ss)   = soEvents(chan_i).posSlope(soIdx);
                    soPPSlope(ss)    = soEvents(chan_i).ppSlope(soIdx);
                    
                    %% Calculate SO phase
                    % Take the phase of the SO within the time window
                    soPhasePeak(ss)  = soPhase(chan_i,peakSample(ss)); % so phase at spindle peak
                    soPhaseStart(ss) = soPhase(chan_i,startSample(ss)); % so phase at spindle start
                    soPhaseEnd(ss)   = soPhase(chan_i,endSample(ss)); % so phase at spindle end
                    
                else
                    soNegPeak(ss)    = nan;
                    ppSOAmp(ss)      = nan;
                    ppSOAmpNorm(ss) = nan;
                    soDur(ss)         = nan;
                    soNegSlope(ss)   = nan;
                    soPosSlope(ss)   = nan;
                    soPPSlope(ss)    = nan;
                    
                    %% Calculate SW phase
                    
                    % Take the phase of the SW within the time window
                    soPhasePeak(ss)  = nan; % sw phase at spindle peak
                    soPhaseStart(ss) = nan; % sw phase at spindle start
                    soPhaseEnd(ss)   = nan; % sw phase at spindle end
                    
                end % End the case you found a SW within spindle window
                
            end % End the loop for each spindle
            
            % Create a structure instead of a cell to store the data;
            cpAll(chan_i).label        = channel;
            cpAll(chan_i).spindleCount = spindleCount;
            cpAll(chan_i).soCount      = soCount;
            cpAll(chan_i).soID         = soId;
            cpAll(chan_i).soDuration   = soDur;
            cpAll(chan_i).soPPAmp      = ppSOAmp;
            cpAll(chan_i).soPPAmpNorm  = ppSOAmpNorm;
            cpAll(chan_i).soNegPeak    = soNegPeak;
            cpAll(chan_i).soNegSlope   = soNegSlope;
            cpAll(chan_i).soPosSlope   = soPosSlope;
            cpAll(chan_i).soPPSlope    = soPPSlope;
            cpAll(chan_i).ssPeakAmp    = spindlePeakAmp;
            cpAll(chan_i).ssSteep      = spindleSteep;
            cpAll(chan_i).soPhasePeak  = soPhasePeak;
            cpAll(chan_i).soPhaseStart = soPhaseStart;
            cpAll(chan_i).soPhaseEnd   = soPhaseEnd;
            
        elseif isempty(ssEvents(chan_i).peakLoc)
            
            cpAll(chan_i).label        = chans{chan_i};
            cpAll(chan_i).spindleCount = spindleCount;
            cpAll(chan_i).soCount      = soCount;
            cpAll(chan_i).soID         = NaN;
            cpAll(chan_i).soDuration   = NaN;
            cpAll(chan_i).soPPAmp      = NaN;
            cpAll(chan_i).soPPAmpNorm  = NaN;
            cpAll(chan_i).soNegPeak    = NaN;
            cpAll(chan_i).soNegSlope   = NaN;
            cpAll(chan_i).soPosSlope   = NaN;
            cpAll(chan_i).soPPSlope    = NaN;
            cpAll(chan_i).ssPeakAmp    = NaN;
            cpAll(chan_i).ssSteep      = NaN;
            cpAll(chan_i).soPhasePeak  = NaN;
            cpAll(chan_i).soPhaseStart = NaN;
            cpAll(chan_i).soPhaseEnd   = NaN;
            
        end
        
        %% Calculate coupling probability
        
        % Run only if called for as an optional input
        if ~isempty(couplingProb) && any(~isnan(cpAll(chan_i).soID))
            
            for i = 1:nChannels
                events = [{ssEvents(i).peakLoc}; {soEvents(i).startSample}; {soEvents(i).endSample}];
                
                % Simulate the SO signal
                try
                    
                    tmp1 = zeros(couplingProb(1), 1);
                    tmp1(events{2, i}) = 1;
                    tmp2 = zeros(couplingProb(1), 1);
                    tmp2(events{3, i}) = -1;
                    so = tmp1 + tmp2;
                    so = cumsum(so);
                    
                    % Simulate spindle peaks
                    spindles = zeros(couplingProb(1), 1);
                    tmp3 = events{1, i}(~isnan(events{1,i}));
                    spindles(tmp3) = 1;
                    
                    % Calculate expected coupling events (by chance)
                    expectedCouplingCount(i,:)  = length(find(spindles == 1)) * length(find(so == 1)) / couplingProb(1);
                    expectedCouplingDensity(i,:) = expectedCouplingCount(i,:) / (couplingProb(1)/(srate * 60));
                    
                    % Calculate observed coupling events
                    observedCouplingCount(i,:)   = length(find(spindles + so == 2));
                    observedCouplingDensity(i,:) = observedCouplingCount(i,:) / (couplingProb(1)/(srate * 60));
                    
                    %Calculate the probability that the number of observed events is higher than chance
                    for j = 1:couplingProb(2)
                        y = circshift(spindles, randi(length(spindles)));
                        randomCoupling(j, 1) = length(find(y + so == 2));
                    end
                    
                    prob(i,:) = length(find(randomCoupling > observedCouplingCount(i,:))) / couplingProb(2);
                    
                catch % Return empty if there is an error
                    cpProb(i).label = chans(i);
                    cpProb(i).expectedCount   = NaN;
                    cpProb(i).observedCount   = NaN;
                    cpProb(i).expectedDensity = NaN;
                    cpProb(i).observedDensity = NaN;
                    cpProb(i).prob            = NaN;
                    return
                end
                
                % Store the output in a struct
                cpProb(i).label           = chans{i};
                cpProb(i).expectedCount   = expectedCouplingCount(i,:);
                cpProb(i).observedCount   = observedCouplingCount(i,:);
                cpProb(i).expectedDensity = expectedCouplingDensity(i,:);
                cpProb(i).observedDensity = observedCouplingDensity(i,:);
                cpProb(i).prob            = prob(i,:);
            end
            
        % If not called, coupling probability output will be empty
        else
            cpProb(chan_i).label           = chans{chan_i};
            cpProb(chan_i).expectedCount   = NaN;
            cpProb(chan_i).observedCount   = NaN;
            cpProb(chan_i).expectedDensity = NaN;
            cpProb(chan_i).observedDensity = NaN;
            cpProb(chan_i).prob            = NaN;
        end
        %% Summarize coupling properties
        
        cpMean(chan_i) = couplingsum(cpAll(chan_i), srate, size(soData, 2));
        
        %% Get coupled and uncoupled spindle and SO parameters
        
        cpDiff(chan_i) = couplingdiffs(cpAll(chan_i), ssEvents(chan_i), soEvents(chan_i), srate, size(ssData, 2));
        
        
        %%
        detectTime = toc;
        disp([' Found ' num2str(cpMean(chan_i).couplingCount1) ' coupled spindles and '...
            num2str(cpMean(chan_i).couplingCount2) ' uncoupled spindles in ' num2str(detectTime) ' seconds'])
        pause(0.1);
        
    elseif ssEvents(chan_i).count == 0
        
        cpAll(chan_i).label        = chans{chan_i};
        cpAll(chan_i).spindleCount = spindleCount;
        cpAll(chan_i).soCount      = soCount;
        cpAll(chan_i).soID         = [];
        cpAll(chan_i).soDuration   = [];
        cpAll(chan_i).soPPAmp      = [];
        cpAll(chan_i).soPPAmpNorm  = [];
        cpAll(chan_i).soNegPeak    = [];
        cpAll(chan_i).soNegSlope   = [];
        cpAll(chan_i).soPosSlope   = [];
        cpAll(chan_i).soPPSlope    = [];
        cpAll(chan_i).ssPeakAmp    = [];
        cpAll(chan_i).ssSteep      = [];
        cpAll(chan_i).soPhasePeak  = [];
        cpAll(chan_i).soPhaseStart = [];
        cpAll(chan_i).soPhaseEnd   = [];
        
        cpMean(chan_i) = couplingsum(cpAll(chan_i), srate, size(soData, 2));
        cpDiff(chan_i) = couplingdiffs(cpAll(chan_i), ssEvents(chan_i), soEvents(chan_i), srate,  size(ssData, 2));
        
        disp('No spindles found')
    end
end % End the loop for each channel
fprintf('\nFinished detecting coupling.\n');
disp('**************');



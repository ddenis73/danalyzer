function [spindlesAll, spindleSummary, params] = fun_sleep_spindles(data, chans, srate, varargin)
% Sleep spindle detection. Automatically detect sleep spindles in
% multichannel data using a wavelet-based detection method. 
%
% Required inputs:
%
% data: A channel x timepoints array
%
% chans: cell {1xn} with the channel labels. If [], will default to
% channel numbers (e.g. 1, 2, 3 etc.)
%
% srate: The sampling rate of the data (in Hz)
%
% Optional inputs:
%
% 'PeakFrequency': The peak frequency of the wavelet (in Hz). Default =
% 13.5
%
% 'BandWidth': The bandwidth of the wavelet, centered on the peak frequency
% (in Hz). Default = 3 (i.e. a bandwidth of 12-15Hz if the peak frequency
% is 13.5Hz)
%
% 'DurationCritera': Time (in seconds) that the signal has to exceed the
% threshold to be classified as a spindle. Default = .4
%
% 'AmplitudeCriteria': Amplification factor the signal must exceed to be
% classified as a spindle. Default = 6
%
% 'ThresholdType': Use either the 'median' or the 'mean for defining the
% threshold. Default = 'median'
%
% 'SegmentDuration': [before after] seconds before and after spindle
% detection for determining spindle features. Default [1 1]
%
% 'Plot': Create plot for wavelet and each detected spindle. Default = 
% false
%
% Outputs:
%
% spindlesAll: A struct containing each detected spindle on each channel
% and their features
%
% spindleSummary: A struct containing average spindle features 
% (e.g. density, amplitude etc.) on each channel
%
% params: Parameters used for spindle detection
%
%%
% Authors:  Dan Denis
%           Dimitrios Mylonas
% Date:     2021-07-14
%
% Remarks:
%   The wavelet-based spindle detector was originally Erin J. Wamsley, and
%   subsequently modified by Dimitrios Mylonas and Dan Denis
%
%   Free use and modification of this code is permitted, provided that any
%   modifications are also freely distributed
%
%   When using this code or modifications of this code, please cite:
%       Denis D (2021). danalyzer. DOI: 10.5281/zenodo.5104418
%% Default settings

if isempty(chans)
    chans    = num2cell(1:1:nChannels); chans = cellfun(@num2str,chans,'un',0);
end

peakFreq   = 13.5;
bWidth     = 3;
tThresh    = 0.4;
amplFactor = 6;
method     = 'median';
segmDur    = [1 1];
doPlot     = 0;

if find(strcmpi(varargin, 'PeakFrequency'))
    peakFreq = varargin{find(strcmpi(varargin, 'PeakFrequency'))+1};
end

if find(strcmpi(varargin, 'BandWidth'))
    bWidth = varargin{find(strcmpi(varargin, 'BandWidth'))+1};
end

if find(strcmpi(varargin, 'DurationCriteria'))
    tThresh = varargin{find(strcmpi(varargin, 'DurationCriteria'))+1};
end

if find(strcmpi(varargin, 'AmplitudeCriteria'))
    amplFactor = varargin{find(strcmpi(varargin, 'AmplitudeCriteria'))+1};
end

if find(strcmpi(varargin, 'ThresholdType'))
    method = varargin{find(strcmpi(varargin, 'ThresholdType'))+1};
end

if find(strcmpi(varargin, 'SegmentDuration'))
    segmDur = varargin{find(strcmpi(varargin, 'SegmentDuration'))+1};
end

if find(strcmpi(varargin, 'Plot'))
    doPlot = varargin{find(strcmpi(varargin, 'Plot'))+1};
end
%% Print parameters

nChannels = size(data,1); % number of channels
nPoints   = size(data,2); % number of samples

fprintf(['\n\nDetecting sleep spindles on ' num2str(nChannels) ' channels with the following parameters:\n\n'...
    'Peak frequency:         ' num2str(peakFreq) ' Hz\n'...
    'Bandwidth:              ' num2str(bWidth) ' Hz\n'...
    'Duration Criteria:      ' num2str(tThresh) ' seconds\n'...
    'Amplitude Criteria:     ' [num2str(amplFactor) ' * signal ' method '\n']])

%% Construct wavelet

% Define frequency bounds to characterize spindles
lowFreq  = peakFreq - bWidth/2;
highFreq = peakFreq + bWidth/2;

wavpoints = 8001;

% vector of frequencies
hz = linspace(0,srate,wavpoints);

% Frequency domain Gaussian
s  = bWidth*(2*pi-1)/(4*pi); % normalized width
x  = hz - peakFreq; % shifted frequency
fx = exp(-.5*(x/s).^2); % gaussian

% Complex Morlet Wavelet in time domain
morlet = fftshift(ifft(fx));

% Time vector
wavetime = (-floor(wavpoints /2):floor(wavpoints /2))/srate;

if doPlot==1
    % empirical FWHM
    idx = dsearchn(hz',peakFreq);
    empFWHM =  hz(idx-1+dsearchn(fx(idx:end)',.5)) - hz(dsearchn(fx(1:idx)',.5));
    
    figure;
    subplot(311)
    plot(hz,fx,'linew',2)
    set(gca,'XLim',[0 peakFreq*3])
    xlabel('Frequency (Hz)');ylabel('Amplitude (gain)')
    title(['Bandwidth specified: ' num2str(bWidth) ' Hz, obtained: ' num2str(empFWHM) ' Hz'])
    
    subplot(312), hold on
    plot(wavetime,real(morlet),'linew',2)
    plot(wavetime,imag(morlet),'--','linew',2)
    h = plot(wavetime,abs(morlet),'linew',2);
    set(h,'color','m')
    set(gca,'xlim',[-1 1])
    legend({'Real part';'Imag part';'Envelope'})
    xlabel('Time (sec.)')
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup wavelet and convolution parameters
halfw = floor(length(wavetime)/2)+1;
nConv = nPoints + length(wavetime) - 1;

% Spectrum of data
dataX = fft(data',nConv);
% Spectrum of morlet
waveX = fft(morlet.',nConv);
waveX = waveX./max(waveX); % normalize
% Replicate morlet to convolve columnwise
waveX = repmat(waveX,1,nChannels);

% Convolve 
coef = ifft(waveX.*dataX); % (Remember: To transpose complex matrices you need to use .' to not conjugate them)
% Trim and reshape
coef = coef(halfw:end-halfw+1,:);

if doPlot == 1
    
    subplot(313)
    
    % Pick a channel randomly, otherwise it can become too slow
    chan_i=3;
    coef2plot = coef(:,chan_i);
    %% Check here the amplitude response of your wavelet
    fig.x = (1:1:nPoints)/srate;
    fig.xTable = timetable(seconds(fig.x)',coef2plot);
    [fig.pxx,fig.f] = pspectrum(fig.xTable);
    plot(fig.f,pow2db(fig.pxx))
    set(gca,'XLim',[0 srate/2])
    xlabel('Frequency (Hz)')
    ylabel('Power Spectrum (dB)')
    title(['FFT of wavelet coefficents (EEG*wavelet), channel: ' chans{chan_i}])
    clear fig
end

% Power
coef = abs(coef).^2;

% Double squaring to increase SNR (legacy code) * doesn't work well w/median
if strcmp(method,'mean')
    coef = coef.^2;
end

% Create 100ms window to convolve with
window = ones((srate/10),1)/(srate/10); 
% Take the moving average using the above window
coef   = filtfilt(window,1,coef); 

% Compute Threshold
switch method
    case 'median'
        signalmean = nanmedian(coef); 
    case 'mean'
        signalmean = nanmean(coef); 
end
threshold  = signalmean.*amplFactor; % defines the threshold

%% Detect sleep spindles at each channel

for chan_i=1:nChannels % Loop for each signal
    
    tic
    msg = ['Working on Channel ',chans{chan_i}, '...'];
    fprintf(msg); % Write new msg

    % Initialize spindle structure in case of nan/flat channel
    spindlesAll(chan_i).label         = chans{chan_i};
    spindlesAll(chan_i).bads          = 0;
    spindlesAll(chan_i).count         = nan;
    spindlesAll(chan_i).minSleep      = size(data,2)/(srate*60);
    spindlesAll(chan_i).backgrMean    = nan;
    spindlesAll(chan_i).detSample     = nan;
    spindlesAll(chan_i).startSample   = nan;
    spindlesAll(chan_i).endSample     = nan;
    spindlesAll(chan_i).peakAmp       = nan;
    spindlesAll(chan_i).peakLoc       = nan;
    spindlesAll(chan_i).peakFreq      = nan;
    spindlesAll(chan_i).sigmaPower    = nan;
    spindlesAll(chan_i).energy        = nan;
    spindlesAll(chan_i).duration      = nan;
    spindlesAll(chan_i).numCycles     = nan;
    spindlesAll(chan_i).numBumps      = nan;
    spindlesAll(chan_i).symmetry      = nan;
    spindlesAll(chan_i).freqGradient  = nan;
    spindlesAll(chan_i).fano          = nan;
    spindlesAll(chan_i).raisingSlope  = nan;
    spindlesAll(chan_i).droppingSlope = nan;
    spindlesAll(chan_i).count         = nan;
    spindlesAll(chan_i).refrPeriod    = nan;
    spindlesAll(chan_i).corrCoef      = nan;
        
    % check for flat channels
    if threshold(chan_i)<1e-30
        warning(['Channel: ' chans{chan_i} ' seems to be partially flat!' ])
        spindlesAll(chan_i).bads = 1;
        continue;
    end
    
    %% Detect spindles
    currentData = coef(:,chan_i);
    
    % Mark channel as bad if there are nans in the data 
    if any(isnan(currentData))
        spindlesAll(chan_i).bads = 1;
    end
    
    over = currentData>threshold(1,chan_i); % Mark all points over threshold as '1'
    locs = (zeros(1,length(currentData)))'; % Create a vector of zeros the length of the MS signal
    
    for ii=1:((length(currentData))-(srate*tThresh)) % for the length of the signal, if the sum of srate*tThresh concurrent points, mark a spindle
        if sum(over(ii:(ii+((srate*tThresh)-1))))==(srate*tThresh)
            locs(ii,1)=1;
        end
    end
    
    % only mark a spindle in vector 'spin' at the end of a 400ms duration peak
    spin           = [diff(locs);zeros(1,1)];
    spin(spin~=-1) = 0; 
    spin           = -spin;

    % Discard spindles that are closer than 1 sec to the boundaries (cannot be characterized)
    spin([1:srate*segmDur(1),end-srate*segmDur(2)-1:end])=0;
    
    % added 9/17/2012: for every spindle marked in 'spin', delete the spindle if there is also a spindle within the second preceeding it.
    for ii=(srate+1):length(spin)
        if spin(ii,1)==1 && sum(spin((ii-srate):(ii-1)))>0
            spin(ii,1)=0;
        end
    end
    
    % Save in output structure
    spindlesAll(chan_i).label         = chans{chan_i};
    spindlesAll(chan_i).count         = sum(spin);
    spindlesAll(chan_i).minSleep      = size(data,2)/(srate*60);
    spindlesAll(chan_i).backgrMean    = signalmean(chan_i);
    spindlesAll(chan_i).detSample     = find(spin)';
     
    %% Calculate Spindle Parameters
    if spindlesAll(chan_i).count == 0 || isnan(spindlesAll(chan_i).count) % no spindles on this channel
        continue;
    else
        
        % Initialize
        segms = cell(spindlesAll(chan_i).count,1);
        
        % Make 2 sec segments around each spindle event
        startSmp = [spindlesAll(chan_i).detSample] - srate*segmDur(1)+1;
        endSmp   = [spindlesAll(chan_i).detSample] + srate*segmDur(2);
        for jj = 1:spindlesAll(chan_i).count
            segms{jj} = data(chan_i,startSmp(jj):endSmp(jj));
        end

        %% Characterize Spindles ******************************************
        tmp = fun_spindle_features(segms, srate, [lowFreq highFreq], doPlot);
        %% ****************************************************************
       
        % Save spindle feautures in structure
        spindlesAll(chan_i).startSample   = tmp.startSample;
        spindlesAll(chan_i).endSample     = tmp.endSample;
        spindlesAll(chan_i).peakAmp       = tmp.peakAmp;
        spindlesAll(chan_i).peakLoc       = tmp.peakLoc;
        spindlesAll(chan_i).peakFreq      = tmp.peakFreq;
        spindlesAll(chan_i).sigmaPower    = tmp.sigmaPower;
        spindlesAll(chan_i).energy        = tmp.energy;
        spindlesAll(chan_i).duration      = tmp.duration;
        spindlesAll(chan_i).numCycles     = tmp.numCycles;
        spindlesAll(chan_i).numBumps      = tmp.numBumps;
        spindlesAll(chan_i).symmetry      = tmp.symmetry;
        spindlesAll(chan_i).freqGradient  = tmp.freqGradient;
        spindlesAll(chan_i).fano          = tmp.fano;
        spindlesAll(chan_i).raisingSlope  = tmp.raisingSlope;
        spindlesAll(chan_i).droppingSlope = tmp.droppingSlope;
        clear tmp
        
        % Convert to whole-signal timeline (samples given relative to 1 sec before detection point)
        spindlesAll(chan_i).startSample   = spindlesAll(chan_i).startSample + spindlesAll(chan_i).detSample - srate*segmDur(1)*ones(size([spindlesAll(chan_i).startSample]));
        spindlesAll(chan_i).endSample     = spindlesAll(chan_i).endSample   + spindlesAll(chan_i).detSample - srate*segmDur(1)*ones(size([spindlesAll(chan_i).endSample]));
        spindlesAll(chan_i).peakLoc       = spindlesAll(chan_i).peakLoc     + spindlesAll(chan_i).detSample - srate*segmDur(1)*ones(size([spindlesAll(chan_i).peakLoc]));
        
        % Correlate raw and filtered signal
        for spin_i = 1:length(segms)
            c = corrcoef(data(chan_i, startSmp(spin_i):endSmp(spin_i)), coef(startSmp(spin_i):endSmp(spin_i), chan_i));
            spindlesAll(chan_i).corrCoef(spin_i) = abs(c(1, 2));
        end
        %% Discard spindles that last less than x samples
        shortIdx = [spindlesAll(chan_i).duration]<tThresh;
        spindlesAll(chan_i).detSample(shortIdx)      = [];
        spindlesAll(chan_i).startSample(shortIdx)    = [];
        spindlesAll(chan_i).endSample(shortIdx)      = [];
        spindlesAll(chan_i).peakAmp(shortIdx)        = [];
        spindlesAll(chan_i).peakLoc(shortIdx)        = [];
        spindlesAll(chan_i).peakFreq(shortIdx)       = [];
        spindlesAll(chan_i).sigmaPower(shortIdx)     = [];
        spindlesAll(chan_i).energy(shortIdx)         = [];
        spindlesAll(chan_i).duration(shortIdx)       = [];
        spindlesAll(chan_i).numCycles(shortIdx)      = [];
        spindlesAll(chan_i).numBumps(shortIdx)       = [];
        spindlesAll(chan_i).symmetry(shortIdx)       = [];
        spindlesAll(chan_i).freqGradient(shortIdx)   = [];
        spindlesAll(chan_i).fano(shortIdx)           = [];
        spindlesAll(chan_i).raisingSlope(shortIdx)   = [];
        spindlesAll(chan_i).droppingSlope(shortIdx)  = [];
        spindlesAll(chan_i).corrCoef(shortIdx)       = [];
        
        %% Merge spindles that overlap 
        if length(spindlesAll(chan_i).startSample)>=2
            % Find spindles that end after the next spindle has started
            overlIdx = find(spindlesAll(chan_i).startSample(2:end)-spindlesAll(chan_i).endSample(1:end-1)<=0);
            % overl_idx gives you the index of the first of the two overlapping spindles
            
            for ov = 1:length(overlIdx)
                spindlesAll(chan_i).endSample(overlIdx(ov))      = spindlesAll(chan_i).endSample(overlIdx(ov)+1);
                spindlesAll(chan_i).duration(overlIdx(ov))       = (spindlesAll(chan_i).endSample(overlIdx(ov)) - spindlesAll(chan_i).startSample(overlIdx(ov)) )/srate;
                % Keep the features of the most prominent spindle
                if spindlesAll(chan_i).peakAmp(overlIdx(ov)) < spindlesAll(chan_i).peakAmp(overlIdx(ov)+1)
                   spindlesAll(chan_i).peakAmp(overlIdx(ov))        = spindlesAll(chan_i).peakAmp(overlIdx(ov)+1);
                   spindlesAll(chan_i).peakLoc(overlIdx(ov))        = spindlesAll(chan_i).peakLoc(overlIdx(ov)+1);
                   spindlesAll(chan_i).sigmaPower(overlIdx(ov))     = spindlesAll(chan_i).sigmaPower(overlIdx(ov)+1);
                   spindlesAll(chan_i).energy(overlIdx(ov))         = spindlesAll(chan_i).energy(overlIdx(ov)+1)  ;
                   spindlesAll(chan_i).numCycles(overlIdx(ov))      = spindlesAll(chan_i).numCycles(overlIdx(ov)+1);
                   spindlesAll(chan_i).numBumps(overlIdx(ov))       = spindlesAll(chan_i).numBumps(overlIdx(ov)+1);
                   spindlesAll(chan_i).symmetry(overlIdx(ov))       = spindlesAll(chan_i).symmetry(overlIdx(ov)+1);
                   spindlesAll(chan_i).freqGradient(overlIdx(ov))   = spindlesAll(chan_i).freqGradient(overlIdx(ov)+1);
                   spindlesAll(chan_i).fano(overlIdx(ov))           = spindlesAll(chan_i).fano(overlIdx(ov)+1);
                   spindlesAll(chan_i).raisingSlope(overlIdx(ov))   = spindlesAll(chan_i).raisingSlope(overlIdx(ov)+1);
                   spindlesAll(chan_i).droppingSlope(overlIdx(ov))  = spindlesAll(chan_i).droppingSlope(overlIdx(ov)+1);
                   spindlesAll(chan_i).detSample(overlIdx(ov))      = spindlesAll(chan_i).detSample(overlIdx(ov)+1);
                   spindlesAll(chan_i).corrCoef(overlIdx(ov))       = spindlesAll(chan_i).corrCoef(overlIdx(ov)+1);
                end
            end
            % Remove merged spindles
            spindlesAll(chan_i).detSample(overlIdx+1)      = [];
            spindlesAll(chan_i).startSample(overlIdx+1)    = [];
            spindlesAll(chan_i).endSample(overlIdx+1)      = [];
            spindlesAll(chan_i).duration(overlIdx+1)       = [];
            spindlesAll(chan_i).peakAmp(overlIdx+1)        = [];
            spindlesAll(chan_i).peakLoc(overlIdx+1)        = [];
            spindlesAll(chan_i).peakFreq(overlIdx+1)       = [];
            spindlesAll(chan_i).sigmaPower(overlIdx+1)     = [];
            spindlesAll(chan_i).energy(overlIdx+1)         = [];
            spindlesAll(chan_i).numCycles(overlIdx+1)      = [];
            spindlesAll(chan_i).numBumps(overlIdx+1)       = [];
            spindlesAll(chan_i).symmetry(overlIdx+1)       = [];
            spindlesAll(chan_i).freqGradient(overlIdx+1)   = [];
            spindlesAll(chan_i).fano(overlIdx+1)           = [];
            spindlesAll(chan_i).raisingSlope(overlIdx+1)   = [];
            spindlesAll(chan_i).droppingSlope(overlIdx+1)  = [];
            spindlesAll(chan_i).corrCoef(overlIdx+1)       = [];
        end
        
        spindlesAll(chan_i).count  = length(spindlesAll(chan_i).detSample); % update spindle count
        
        % Calculate refractory period (sec)
        spindlesAll(chan_i).refrPeriod =  [nan,diff(spindlesAll(chan_i).peakLoc)]./srate;  
                
    end % Case you found spindles at this channel
    
    %% Summarize spindle features
    spindleSummary(chan_i) = spindlesum(spindlesAll(chan_i), srate, size(data, 2));
    
    detectTime = toc;
    disp([' Found ' num2str(spindlesAll(chan_i).count) ' spindles in ' num2str(detectTime) ' seconds'])
end % End the loop for each channel

% Save spindle detection parameters
params.tThresh       = tThresh;
params.amplFactor    = amplFactor;
params.method        = method;
params.srate         = srate;
params.peakFreq      = peakFreq;
params.bandwidth     = [lowFreq,highFreq];
params.samples  = size(data,2);


disp('Finished detecting spindles.');
disp('**************');
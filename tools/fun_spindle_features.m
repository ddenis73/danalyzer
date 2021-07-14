function [spindles] = fun_spindle_features(segments, srate, freqs, doPlot)
% Calculate spindle features.
%
% Inputs:
%
% segments : cell matrix with EEG segments to analyze
%
% srate: The sampling rate of the data (in Hz)
%
% freqs: [low high] frequency boundaries for spindle characterization
%
% doPlot: Plot detected spindle.
%
% Output:
%
% spindles: A structure with all the spindle features characterized.

% detSample          : Sample where the spindle was initially detected
% startSample        : Start sample of spindle (based on FWHM) (sample)
% endSample          : End sample of spindle (based on FWHM) (sample)
% peakAmp            : Spindle peak amplitude (wavelet coefficient units)
% peakLoc            : Location of peak amplitude (sample)
% peakFreq           : Frequency w/ maximum power based on the FFt of a 2s window (Hz)
% sigmaPower         : Spectral density based on the FFT of a 2s window (uV^2/Hz)
% energy             : Product of amplitude*duration (similar to integrated spindle activity, Ferrarelli et al., XX)
% duration           : Spindle duration (sec)
% numCycles          : Number of cycles in a spindle
% numBumps           : Number of bumps
% symmetry           : Spindle symmetry based on the location of the peak
%                      relative to the start (0.0) and end (1.0) (Purcell et al .,2017) ([0,1])
% freqGradient       : Frequency gradient of spindle based on the distance between peaks & zero crossings (ms/spindle cycle);
% fano               : Fano factor var/mean based on peaks
% raisingSlope       : Slope from spindle start to spindle peak amplitude (muV/sec);
% droppingSlope      : Slope from spindle peak amplitude to spindle end (muV/sec);

%Set default values
lowFreq  = freqs(1);
highFreq = freqs(2);

if nargin<4
    error('You need at least four input arguments')
end

warning('off', 'stats:statrobustfit:IterationLimit')
    
if doPlot == 1
   f1 = figure('Units','normalized','Position',[.1 .5 .3 .4]);
   f2 = figure('Units','normalized','Position',[.4 .5 .3 .4]);
end

for sp = 1: size(segments,1) % complete these operations for every segment in the data (== every detected spindle)
    
    %% Step 1: Obtain the complex morlet wavelet coefficients
    wname          = 'cmor1-1.5'; % Define wavelet for cwt
    scales         = .1:.1:1000;
    frqs           = scal2frq(scales,wname,1/srate); % check out frequencies that correspond to selected scales
    [~,lowFreqIdx]   = min(abs(frqs-lowFreq));
    [~,highFreqIdx]  = min(abs(frqs-highFreq));
    scales         = scales(highFreqIdx:lowFreqIdx);

    % Keep the old matlab implementation because the new does not allow
    % tweaking the frequency resolution using Morlet wavelets
    coefs = cwt(segments{sp,:},scales,'cmor1-1.5'); % Continuous wavelet transformation using complex Morlet 1-1.5

    %% Step 3: Find Peak frequency and sigma power density within spindle
    
    % Peak Frequency
    
    % FreqResolution = srate/length(baselined_coefs);
    Y = fft(mean(real(coefs))); % Fourier transform of the spindle
    L = length(coefs);
    f = srate*(0:(L/2))/L; % frequencies
    Y = Y(1:L/2+1);
    % Find the frequency with the maximum coefficient
    [~,PeakFreqIdx] = max(abs(Y));
    spindles.peakFreq(sp)   = f(PeakFreqIdx);
    
    if doPlot == 1 % Plot FFT of all wavelet coefficients
        figure(f1);cla
        plotCoef = 1:size(coefs,1); % Change this if you want to plot a specific coefficient
        subplot(2,1,1)
        plot(real(coefs(plotCoef,:))');
        Y = fft(real(coefs(plotCoef,:))');
        L = size(Y,1);
        f = srate*(0:(L/2))/L;
        subplot(2,1,2)
        plot(f,abs(Y(1:L/2+1,:)))
    end
    
    % Sigma power (spectral density)
    Y               = (1/(srate*L)) * abs(Y).^2; % Calculate uV^2/Hz
    [~,lowFreqIdx]    = min(abs(f-lowFreq));
    [~,highFreqIdx]   = min(abs(f-highFreq));
    spindles.sigmaPower(sp)  = mean(Y(lowFreqIdx:highFreqIdx));
    
    %% Step 4: Extract mean (real) wavelet coefficient for each timepoint & smooth
    meanCoef      = mean(abs(real(coefs))); % Rectified mean across wavelet scales
    [env,~]       = envelope(meanCoef,2,'peak'); % Calculate the envelope
    window        = ones(round(srate/5),1)/round(srate/5); % Create a 200ms sliding window
    smoothedEnv  = filtfilt(window,1,env); % Smooth data
    % By smoothing the filtered signal you get a more robust estimate of
    % duration (compared to Hilbert envelope) because you avoid taking into
    % account the minor ups and downs as the spindle is risng/dropping
    
    %% Step 5: Find Peak amplitude and peak location
    
    % Maximum amplitude and location
    % Use findpeaks instead of max(smoothed_env) to avoid finding the peak 
    % at the end or start of the spindle
    [peak,peakIdx] = findpeaks(smoothedEnv);
    if ~isempty(peak)
    [~,idx] = max(peak);
    peak = peak(idx); % value of peak 
    peakIdx = peakIdx(idx);% index of peak
    else
        % The only case that findpeaks won't work are if envelope is a
        % motonic or a parabolic like function (both very rare but happen)
        [peak,peakIdx] = max(smoothedEnv);
    end
    
    %% Step 6: Find duration (Full-width half-max)
    dropmax = .50; % define where sppindle edges will be, relative to the peak (e.g. .5 of max)
    
    % Find spindle start
    edge1 = find(smoothedEnv(1:peakIdx)<peak*dropmax,1,'last')+1;
    if isempty(edge1); edge1 = 1; end
    
    % Find spindle end
    edge2 = find(smoothedEnv(peakIdx:end)<peak*dropmax,1,'first')-1;
    if isempty(edge2)
        edge2 = length(smoothedEnv);
    else
        edge2 = edge2+peakIdx-1;
    end

    %% Step 7: Find Energy (Amplitude*Duration) add Tononi reference
    % Use envelope to calculate energy
    spindles.energy(sp) = sum(env(edge1:edge2));
    
    %% Step 8: Find spindle steepness (raise + drop) in amplitude/sec
    spindles.raisingSlope(sp)  = srate*( peak - smoothedEnv(edge1) ) / (peakIdx - edge1); % Multiply with srate to convert to XXX/sec
    spindles.droppingSlope(sp) = srate*( peak - smoothedEnv(edge2) ) / (peakIdx - edge2);
    
    %% Step 9: Find number of cycles & frequency gradient & Fano factor
    % Find peaks in the rectified signal
    
    [~,locs] = findpeaks(meanCoef(edge1:edge2));
    
    % Find zero crossings
    zeroCross = [0,diff(sign(mean(real(coefs(edge1:edge2)),1)))];
    zeroLocs = find(zeroCross < 0 | zeroCross > 0);
    
    % Calculate number of cycles
    spindles.numCycles(sp) = length([locs,zeroLocs])/4;
    
    % Fit a robust regression model on the distance between peaks
    try
        b = robustfit(1:length([locs,zeroLocs])-1,diff(sort([locs,zeroLocs])).*1000/srate);
    catch
        disp(['Problematic fit; Frequency gradient is not calculated for spindle no. ' num2str(sp)])
        b(1)=nan;b(2)=nan;
    end
    % Frequency gradient tells you how many msec faster/slower is each cycle from the next one
    spindles.freqGradient(sp) = 4*b(2);
    
    % Fano factor
    spindles.fano(sp) = var(diff(locs))/mean(diff(locs));
    
    %% Step 10: Find number of bumps on the smoothed envelope
    [~,bumps] = findpeaks(smoothedEnv(edge1:edge2));
    spindles.numBumps(sp) = length(bumps);
    
    %% Step 11: Find Symmetry (Purcell et al., 2017)
    
    spindles.symmetry(sp) = (peakIdx-edge1)/(edge2-edge1);
    
    if doPlot == 1
        figure(f2);cla
        time = (-1+1/srate):1/srate:1;
        % Plot filtered signal
        plot(time,mean(real(coefs),1),'DisplayName', ['Spindle filtered at ' num2str(12) '-' num2str(15) 'Hz'],'Color',[1 1 0]);
        hold on; set(gca,'Color','black')
        % Plot rectified filtered signal
        plot(time,env,'DisplayName', 'Rectified signal' ,'Color',[.5 .5 1]);
        % Plot smoothed mean (~envelope)
        plot(time,smoothedEnv, 'DisplayName', 'Smoothed Mean','Color',[0.8 0.5 0.8],'LineWidth',3);
        % Plot Peak amplitude and location
        scatter(time(peakIdx), peak, 'DisplayName', 'Peak','sizedata', 40,'MarkerFaceColor','flat','CData',[0 1 0]);
        % Plot detection point
        scatter(0, smoothedEnv(srate), '>','DisplayName', 'Peak','sizedata', 70,...
            'MarkerEdgeColor','r','LineWidth',2);
        % Plot spindle start
        scatter(time(edge1), smoothedEnv(edge1),'o', 'DisplayName', 'Spindle start','MarkerFaceColor',[1 1 1]);
        % Plot spindle end
        scatter(time(edge2), smoothedEnv(edge2),'o', 'DisplayName', 'Spindle end','MarkerFaceColor',[1 1 1]);
        % Plot Local maxima
        scatter(time(edge1+locs-1), mean(real(coefs(:,edge1+locs-1))),'*','MarkerEdgeColor',[.5 .5 1]);
        pause(.1)
    end
    
    % Save spindle features
    spindles.duration(sp)     = (edge2-edge1)/srate; %sec
    spindles.startSample(sp)  = edge1; % spindle start (sample)
    spindles.endSample(sp)    = edge2; % spindle end (sample)
    spindles.peakAmp(sp)      = peak;
    spindles.peakLoc(sp)      = peakIdx; % (sample)
    
end % End the loop for all the detection points
if doPlot == 1  
    disp('Ready to close the figures...')
    pause(3)
    close ([f1 f2])
end
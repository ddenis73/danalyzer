function [soAll, soSummary, params] = fun_slow_oscillations(data, chans, srate, varargin)
% Slow-oscillation detection. Automatically detects slow oscillaiton events on
% multi-channel EEG data and returns each detected event plus their
% parameters.
%
% Required inputs:
%
% data: A channel x timepoints array, filtered in the slow oscillation band
%
% chans: cell {1xn} with the channel labels. If [], will default to
% channel numbers (e.g. 1, 2, 3 etc.)
%
% srate: The sampling rate of the data (in Hz)
%
% Optional inputs:
%
% 'DurationCriteria'  = Duration criteria for candidates to be considered as
% slow waves (seconds). Default = [0.5 2].
%
% 'AmplitudeCriteria' = Events with the X percent largest amplitude to be
% considered as slow waves(percentage). Default = [] (retain all
% events).
%
% Outputs:
%
% soAll: A struct containing each detected slow oscillation on each channel
% and their features
%
% soSumamry: A struct containing average slow oscillation features
% (e.g. density, amplitude etc) on each channel
%
% params: Parameters used for spindle detection
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
%% Default settings
durCrit = [0.5 2];
ampCrit = [];

if find(strcmpi(varargin, 'DurationCriteria'))
    durCrit = varargin{find(strcmpi(varargin, 'DurationCriteria'))+1};
end

if find(strcmpi(varargin, 'AmplitudeCriteria'))
    ampCrit = varargin{find(strcmpi(varargin, 'AmplitudeCriteria'))+1};
end

%% Print parameters

nChannels = size(data, 1);

if isempty(chans)
    chans    = num2cell(1:1:nChannels); chans = cellfun(@num2str,chans,'un',0);
end

if isempty(ampCrit)
    ampDisp = 'No amplitude criteria specified';
else
    ampDisp = ['Largest ' num2str(ampCrit) '%% of candidate oscillations'];
end

fprintf(['\n\nDetecting slow oscillations on ' num2str(nChannels) ' channels with the following parameters:\n\n'...
    'Duration criteria:  ' num2str(durCrit(1)) ' to ' num2str(durCrit(2)) ' seconds\n'...
    'Amplitude criteria: ' ampDisp '\n\n']);
pause(0.5);

%% Detect slow oscillations
for chan_i = 1:nChannels
    tic
    msg = ['Working on Channel ',chans{chan_i}, '...'];
    fprintf(msg); % Write new msg
    
    currentData = data(chan_i,:);
    
    %% Normalize signal
    
    normData     = (currentData - mean(currentData, 2)) ./ std(currentData, 0, 2);
    normMADData  = (currentData - mean(currentData, 2)) ./ mad(currentData, 0, 2);
    
    %% Compute all points of positive to negative crossings
    
    s         = diff(sign(currentData(1,:)));
    downIdx   = find(s < 0);     % positive to negative
    upIdx     = find(s > 0) + 1; % negative to positive (just to define positive slope)
    
    if ~isempty(upIdx) && ~isempty(downIdx)
        
        % Make sure that the first zero crossing is from + to -
        if upIdx(1) < downIdx(1)
            upIdx(1) = [];
        end
        
        %% Find positive to negative zero crossings
        
        % Measure the length of all intervals of postive to negative zero
        % crossings (t) is measured
        t = diff(downIdx) / srate; % Sec
        
        % For intervals with a length of durCrit(1)<=t<=durCrit(2), the averages of
        % their negative peak amplitudes (x), the positive peak amplitudes (y)
        % and their difference (y-x) are calculated.
        % Using the default settings, we are looking at SWs between 0.5 and 1.25Hz
        event = find(t>=durCrit(1) & t <= durCrit(2));
        
        %% Get properties for all candidate SOs
        
        for i = 1:length(event)
            
            [x(i),ix(i)]         = min(currentData(1,downIdx(event(i)):downIdx(event(i)+1)));              % negative peak amplitudes
            [y(i),iy(i)]         = max(currentData(1,downIdx(event(i)):downIdx(event(i)+1)));              % positive peak amplitudes
            pp(i)                = abs(y(i))+abs(x(i));                                                    % peak to peak amplitude
            dur(i)               = t(event(i));                                                            % duration of SW in seconds
            minIdx(i)            = ix(i) + downIdx(event(i)) -1;                                           % index [in samples] of SW min
            maxIdx(i)            = iy(i) + downIdx(event(i)) -1;                                           % index [in samples] of SW max
            negSlope(i)          = -x(i)/(((ix(i) - 1)/srate)*1000);                                       % Negative slope [uV/msec]
            posSlope(i)          = -x(i)/(((upIdx(event(i)) - downIdx(event(i)) - ix(i) + 1)/srate)*1000); % Positive slope (two zero crossings)
            ppSlope(i)           = pp(i)/(((maxIdx(i) - minIdx(i))/srate)*1000);                           % Peak-to-Peak slope [uV/msec]
            [xNorm(i),ixNorm(i)] = min(normData(1,downIdx(event(i)):downIdx(event(i)+1)));                 % negative NORM peak amplitudes
            [yNorm(i),iyNorm(i)] = max(normData(1,downIdx(event(i)):downIdx(event(i)+1)));                 % positive NORM peak amplitudes
            ppNorm(i)            = abs(yNorm(i))+abs(xNorm(i));                                            % NORM peak to peak amplitude
            [xMad(i),iMad(i)]    = min(normMADData(1,downIdx(event(i)):downIdx(event(i)+1)));             % negative MAD peak amplitudes
            [yMad(i),iyMad(i)]   = max(normMADData(1,downIdx(event(i)):downIdx(event(i)+1)));             % positive MAD peak amplitudes
            ppMad(i)             = abs(yNorm(i))+abs(xNorm(i));                                           % MAD peak to peak amplitude
            
        end
        
        %% Store SO parameters in a struct
        
        soAll(chan_i).label       = chans{chan_i};                     % Channel label
        soAll(chan_i).count       = length(downIdx(event));            % Number of SO
        soAll(chan_i).minSleep    = size(data,2)/(srate*60);           % Length of sleep
        soAll(chan_i).startSample = downIdx(event);                    % Start of SO (sample)
        soAll(chan_i).endSample   = downIdx(event + 1);                % End of SO (sample)
        soAll(chan_i).minIdx      = minIdx;                            % Index at minimum (sample)
        soAll(chan_i).maxIdx      = maxIdx;                            % Index at maximum (sample)
        soAll(chan_i).duration    = dur;                               % Duration of SO (seconds)
        soAll(chan_i).ppAmp       = pp;                                % SO peak-to-peak amplitude (uV)
        soAll(chan_i).ppAmpNorm   = ppNorm;                            % SO peak-to-peak amplitude normalize
        soAll(chan_i).ppAmpMad    = ppMad;                             % SO peak-to-peak amplitude MAD
        soAll(chan_i).negPeak     = x;                                 % SO minimum negative peak (uV)
        soAll(chan_i).posPeak     = y;                                 % SO maximum positive peak (uV)
        soAll(chan_i).negSlope    = negSlope;                          % SO negative slope (uV/sec)
        soAll(chan_i).posSlope    = posSlope;                          % SO positive slope (uV/sec)
        soAll(chan_i).ppSlope     = ppSlope;                           % SO peak-to-peak slope (uV/sec)
        
        %% Keep slow oscillations according to amplitude criteria
        
        if ~isempty(ampCrit)
            
            % Number to be retained
            percent = floor((ampCrit/100) * length(pp));
            
            % Find the location of the largest xxx percent
            [~,thresIdx] = maxk(pp, percent);
            
            % Update structure
            soAll(chan_i).startSample = soAll(chan_i).startSample(thresIdx);
            soAll(chan_i).endSample  = soAll(chan_i).endSample(thresIdx);
            soAll(chan_i).minIdx     = soAll(chan_i).minIdx(thresIdx);
            soAll(chan_i).maxIdx     = soAll(chan_i).maxIdx(thresIdx);
            soAll(chan_i).duration   = soAll(chan_i).duration(thresIdx);
            soAll(chan_i).ppAmp      = soAll(chan_i).ppAmp(thresIdx);
            soAll(chan_i).ppAmpNorm  = soAll(chan_i).ppAmpNorm(thresIdx);
            soAll(chan_i).ppAmpMad   = soAll(chan_i).ppAmpMad(thresIdx);
            soAll(chan_i).negPeak    = soAll(chan_i).negPeak(thresIdx);
            soAll(chan_i).posPeak    = soAll(chan_i).posPeak(thresIdx);
            soAll(chan_i).negSlope   = soAll(chan_i).negSlope(thresIdx);
            soAll(chan_i).posSlope   = soAll(chan_i).posSlope(thresIdx);
            soAll(chan_i).ppSlope    = soAll(chan_i).ppSlope(thresIdx);
            
            % Recount
            soAll(chan_i).count = percent;
            
        end
        
    else
        
        soAll(chan_i).label       = chans{chan_i}; % Channel label
        soAll(chan_i).count       = 0;   % Number of SO
        soAll(chan_i).minSleep    = NaN; % Length of sleep
        soAll(chan_i).startSample = NaN; % Start of SO (sample)
        soAll(chan_i).endSample   = NaN; % End of SO (sample)
        soAll(chan_i).minIdx      = NaN; % Index at minimum (sample)
        soAll(chan_i).maxIdx      = NaN; % Index at maximum (sample)
        soAll(chan_i).duration    = NaN; % Duration of SO (seconds)
        soAll(chan_i).ppAmp       = NaN; % SO peak-to-peak amplitude (uV)
        soAll(chan_i).ppAmpNorm   = NaN; % SO peak-to-peak amplitude normalize
        soAll(chan_i).ppAmpMad    = NaN; % SO peak-to-peak amplitude MAD
        soAll(chan_i).negPeak     = NaN; % SO minimum negative peak (uV)
        soAll(chan_i).posPeak     = NaN; % SO maximum positive peak (uV)
        soAll(chan_i).negSlope    = NaN; % SO negative slope (uV/sec)
        soAll(chan_i).posSlope    = NaN; % SO positive slope (uV/sec)
        soAll(chan_i).ppSlope     = NaN; % SO peak-to-peak slope (uV/sec)
        
    end
    
    %% Summarize SO properties
    
    soSummary(chan_i) = sosum(soAll(chan_i), srate, size(currentData, 2));
    
    %% Clear
    clear x ix y iy pp dur minIdx maxIdx negSlope posSlope ppSlope xNorm ixNorm yNorm iyNorm ppNorm xMad iMad yMad iyMad ppMad
    
    detectTime = toc;
    
    disp([' Found ' num2str(soAll(chan_i).count) ' slow oscillationa in ' num2str(detectTime) ' seconds'])
    pause(0.1);
    
end % End loop for each channel

% Save so detection parameters
params.durCrit = durCrit;
params.ampCrit = ampCrit;
params.srate   = srate;
params.samples = size(data, 2);

disp('Finished detecting slow oscillations.');
disp('**************');
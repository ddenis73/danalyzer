function plot_hypnogram(stages, varargin)
% Plot a hypnogram. Scores can either be a sleepstages struct or a nx1
% array where n is the number of epochs and each row contains stage
% information for that epoch. If an array is used, argument 'EpochLength'
% can be specified as epoch length in seconds (Default = 30)
epochLength = 30;
hypnogramColor = [];
tickPeriod = 30;

if find(strcmpi(varargin, 'EpochLength'))
    epochLength = varargin{find(strcmpi(varargin, 'EpochLength'))+1};
end

if find(strcmpi(varargin, 'Color'))
    hypnogramColor = varargin{find(strcmpi(varargin, 'Color'))+1};
end

if find(strcmpi(varargin, 'TickPeriod'))
    tickPeriod = varargin{find(strcmpi(varargin, 'TickPeriod'))+1};
end

if isstruct(stages)
    
    % Calculate lights out and lights on epoch number
    rec = datetime(stages.hdr.recStart, 'Format', 'HH:mm:ss.SSS');
    lout = datetime(stages.hdr.lOff, 'Format', 'HH:mm:ss.SSS');
    lon = datetime(stages.hdr.lOn, 'Format', 'HH:mm:ss.SSS');
    
    diff = seconds(lout - rec);
    diff2 = seconds(lon - rec);
    
    if diff2 < 0
        diff2 = diff2 + 86400;
    end
    
    epochLength = stages.hdr.win;
    loutSample = diff * stages.hdr.srate;
    lonSample  = diff2 * stages.hdr.srate;
    [~, lOffEpoch] = min(abs(stages.hdr.onsets - loutSample));
    [~, lOnEpoch]  = min(abs(stages.hdr.onsets - lonSample));
    
    hypnoX = 1:1:length(stages.stages);
    hypnoY = stages.stages;
    hypnoY(stages.stages == 0) = 1;
    hypnoY(stages.stages == 1) = 4;
    hypnoY(stages.stages == 2) = 5;
    hypnoY(stages.stages == 3) = 6;
    hypnoY(stages.stages == 4) = 7;
    hypnoY(stages.stages == 5) = 3;
    hypnoY(stages.stages == 6) = 2;
    hypnoY(stages.stages == 7) = nan;
    hypnoY = hypnoY';
    
else
    
    hypnoX = 1:1:length(stages);
    
    hypnoY = stages;
    hypnoY(stages == 0) = 1;
    hypnoY(stages == 1) = 4;
    hypnoY(stages == 2) = 5;
    hypnoY(stages == 3) = 6;
    hypnoY(stages == 4) = 7;
    hypnoY(stages == 5) = 3;
    hypnoY(stages == 6) = 2;
    hypnoY(stages == 7) = nan;
    hypnoY = hypnoY';
    
end

if isempty(hypnogramColor)
    scatter(hypnoX, hypnoY, epochLength, hypnoY, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'flat')
else
    scatter(hypnoX, hypnoY, epochLength, hypnoY, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', hypnogramColor)
end
line(hypnoX, hypnoY, 'Color', 'k')
yticks(1:1:7);
xlim([1 length(hypnoX)]);
set(gca, 'yticklabels', {'W', 'MVT', 'REM', 'N1', 'N2', 'N3', 'N4'}, 'YDir', 'reverse')
ylabel('Sleep stage')
xlabel('Time')
title('Hypnogram')

if isstruct(stages)
    
    if ~isempty(lOffEpoch)
        line(gca, [lOffEpoch lOffEpoch], [0 8], 'Color', [0 1 0 0.3], 'LineWidth', 3)
    end
    
    if ~isempty(lOnEpoch)
        line(gca, [lOnEpoch lOnEpoch], [0 8], 'Color', [0 1 0 0.3], 'LineWidth', 3)
    end
    
    if ~isempty(stages.hdr.recStart)
        % Create time vector
        tickMarks = hypnoX(1):(tickPeriod * 60) / stages.hdr.win:hypnoX(end);
        numTicks = length(tickMarks);
        
        timeStr = {datestr(stages.hdr.recStart, 'HH:MM:SS')};
        
        if ~cellfun(@isempty, timeStr)
            
            for t = 2:numTicks
                timeStr = [timeStr; datestr(datenum(timeStr{t-1}) + minutes(tickPeriod), 'HH:MM:SS')];
            end
            
            set(gca, 'XTick', tickMarks+1,...
                'XTickLabel', timeStr)
            
        end
    end
    
end




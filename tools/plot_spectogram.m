function plot_spectogram(psd, freqs, lims, stages, plotType, varargin)
% Plot a spectogram. Will either plot a heatmap depicting power in all
% frequeny bands, or as lines depicting band-averaged power
%
% Required input:
%
% psd = freqs x epoch array
% freqs = vector indicating frequency at each row
% lims = [lo hi] frequency limits to plot
% stage = a sleepstage struct
% plotType = 1 = Plot full spectogram, 2 = Plot band averaged data (with a
% 5 trial smoothing function)

%% © 2021 Dan Denis, PhD
%
% This function is part of the danalyzer toolbox. danalyzer is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU General Public License as published by the Free Software Foundation,
% either version 3 of the License or any later version.
%
% danalyzer is distributed with the hope that others will find it useful.
% It comes without any warranty; without even the implied warranty of
% merchantability or fitness for a particular purpose. See the GNU General
% Public License for more details.

% danalyzer is intended for research purposes only. Any commercial or
% medical use of this software is prohibited. The author accepts no
% responsibility for its use in this manner
%
%%
tickPeriod = 30;

if find(strcmpi(varargin, 'TickPeriod'))
    tickPeriod = varargin{find(strcmpi(varargin, 'TickPeriod'))+1};
end

%%

if plotType == 1
    % Plot a spectogram
    
    spectoX = 1:1:size(psd, 1);
    spectoY = freqs(min(find(freqs>=lims(1))):max(find(freqs<=lims(2))));
    
    imagesc(spectoX, spectoY,...
        psd(:,freqs >= lims(1) & freqs <= lims(2))');
    set(gca, 'YDir', 'normal')
    xlim([spectoX(1) spectoX(end)])
    ylim([spectoY(1) spectoY(end)])
    ylabel('Frequency (Hz)')
    xlabel('Epoch')
    title('Spectogram')
    
    if ~isempty(stages)
        % Calculate lights out and lights on epoch number
        rec = datetime(stages.hdr.recStart, 'InputFormat', 'HH:mm:ss.SSS');
        lout = datetime(stages.hdr.lOff, 'InputFormat', 'HH:mm:ss.SSS');
        lon = datetime(stages.hdr.lOn, 'InputFormat', 'HH:mm:ss.SSS');
        
        diff = seconds(lout - rec);
        diff2 = seconds(lon - rec);
        
        if diff2 < 0
            diff2 = diff2 + 86400;
        end
        
        loutSample = diff * stages.hdr.srate;
        lonSample  = diff2 * stages.hdr.srate;
        [~, lOffEpoch] = min(abs(stages.hdr.onsets - loutSample));
        [~, lOnEpoch]  = min(abs(stages.hdr.onsets - lonSample));
        
        if ~isempty(lOffEpoch)
            line(gca, [lOffEpoch lOffEpoch], [0 lims(2)], 'Color', [0 1 0], 'LineWidth', 3)
        end
        
        if ~isempty(lOnEpoch)
            line(gca, [lOnEpoch lOnEpoch], [0 lims(2)], 'Color', [0 1 0], 'LineWidth', 3)
        end
        
        if ~isempty(stages.hdr.recStart)
            % Create time vector
            tickMarks = spectoX(1):(tickPeriod * 60) / stages.hdr.win:spectoX(end);
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
    
elseif plotType == 2
    
    for band_i = 1:size(psd, 2)
        bandSmooth(band_i,:) = smooth(psd(:, band_i), 5);
    end
    
    powerX = 1:1:size(psd, 1);
    powerY = [0 100];
    
    if ~isempty(stages)
        
        lOffOn = lightswitch(stages);
        [tickMarks, timeStr] = timestring(stages, powerX, 'HH:MM:SS');
        
    end
    p1 = plot(powerX, bandSmooth(1,:)'*100, 'LineWidth', 1);
    hold on
    p2 = plot(powerX, bandSmooth(2,:)'*100, 'LineWidth', 1);
    p3 = plot(powerX, bandSmooth(3,:)'*100, 'LineWidth', 1);
    p4 = plot(powerX, bandSmooth(4,:)'*100, 'LineWidth', 1);
    p5 = plot(powerX, bandSmooth(5,:)'*100, 'LineWidth', 1);
    p6 = plot(powerX, bandSmooth(6,:)'*100, 'LineWidth', 1);
    hold off
    xlim([powerX(1) powerX(end)])
    ylim([powerY(1) powerY(end)])
    ylabel('Relative power (%)')
    xlabel('Epoch')
    title('Relative power')
    
    if ~isempty(stages)
        
        if ~isempty(lOffOn)
            line(gca, [lOffOn(1) lOffOn(1)], powerY, 'Color', [0 1 0 0.5], 'LineWidth', 3)
            line(gca, [lOffOn(2) lOffOn(2)], powerY, 'Color', [0 1 0 0.5], 'LineWidth', 3)
        end
        
        if ~isempty(tickMarks) && ~isempty(timeStr)
            set(gca, 'XTick', tickMarks+1,...
                'XTickLabel', timeStr)
        end
        
    end
    
    legend([p1, p2, p3, p4, p5, p6], 'SO', 'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta');
    
end


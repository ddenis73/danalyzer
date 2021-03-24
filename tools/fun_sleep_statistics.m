function sleepStats = fun_sleep_statistics(sleepstages, varargin)
% Calculate sleep statistics. Automatically generate sleep
% macroarchitecture information including time in bed, total sleep time,
% sleep onset latency etc, as well as time and % spent in each sleep stage.
%
% Required inputs:
%
% sleepstages: Either a sleepstages struct created using danalyzer, or a
% nx1 array of sleep stages, where each row represents an epoch of sleep.
% Sleep stages must be specified as follows: 0 = Wake, 1-4 = N1-N4, 5 =
% REM, 6 = Movement, 7 = Unstaged.
%
% Optional inputs:
%
% EpochLength: Length of each scored epoch in seconds. Default = 30
%
% EventTimes: nx3 cell array containing clock times (as char) for:
% {Recording start time, Lights off time, lights on time}. If clock times
% are not provided, it is assumed that the first epoch is lights off and
% the last epoch is lights on. Empty entries can be specified as ''. If
% recording start time is not provided, lights off/on will still be
% considered as the first/last epoch event if clock times are provided.
%
% SleepOnset: Rule for defining sleep onset. 1 = First epoch of sleep,
% 2 = First epoch of 90 seconds of sleep, 3 = First epoch of 10 minutes of
% sleep, 4 = First epoch of N2 sleep. Default = 1
%
% Report: Produce an html sleep report. 1x3 cell array {participant id,
% filepath, filename}.
%
% Output:
%
% sleepStats: A struct containing sleep statistics.

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

% Aspects of this function have been modified from the Hume toolbox 
% (Copyright (c) 2015 Jared M. Saletin, PhD, and Stephanie M. Greer, PhD),
% available under the GNU General Public License 
% (https://github.com/jsaletin/hume).

%% Default settings

epochLength  = 30; % Epoch length 30 seconds
solMode      = 1;  % Use rule 1 for SOL

% Set default event times
if isstruct(sleepstages)
    recStartTime = sleepstages.hdr.recStart;
    lOffTime     = sleepstages.hdr.lOff;
    lOnTime      = sleepstages.hdr.lOn;
else
    recStartTime = [];
    lOffTime     = [];
    lOnTime      = [];
end

% Optional inputs

if find(strcmpi(varargin, 'EpochLength'))
    epochLength = varargin{find(strcmpi(varargin, 'EpochLength'))+1};
end

if find(strcmpi(varargin, 'EventTimes'))
    recStartTime = varargin{find(strcmpi(varargin, 'EventTimes'))+1}{1};
    lOffTime     = varargin{find(strcmpi(varargin, 'EventTimes'))+1}{2};
    lOnTime      = varargin{find(strcmpi(varargin, 'EventTimes'))+1}{3};
    
end

if find(strcmpi(varargin, 'SleepOnset'))
    solMode = varargin{find(strcmpi(varargin, 'SleepOnset'))+1};
end

if find(strcmpi(varargin, 'Report'))
    sleepReport = varargin{find(strcmpi(varargin, 'Report'))+1};
end
%% Determine lights off/on time

if isstruct(sleepstages)
    stages = sleepstages.stages;
    epochLength = sleepstages.hdr.win;
else
    stages = sleepstages;
end

% If there is no recording start time, set lights off to epoch 1 and lights
% on to final epoch
if isempty(recStartTime)
    lOffEpoch = 1;
    lOnEpoch  = length(stages);
    
    % else, calculate the epoch of lights off/on
else
    recStartTime = datetime(recStartTime, 'Format', 'HH:mm:ss.SSS');
    lOffTime     = datetime(lOffTime, 'Format', 'HH:mm:ss.SSS');
    lOnTime      = datetime(lOnTime, 'Format', 'HH:mm:ss.SSS');
    
    startDiff = seconds(lOffTime - recStartTime);
    endDiff   = seconds(lOnTime - recStartTime);
    
    if endDiff < 0
        endDiff = endDiff + 86400;
    end
    
    % Find lights off / lights on epoch
    stageTime = 0:epochLength:length(stages)*epochLength;
    
    
    if ~isnat(lOffTime) && ~isnat(lOnTime)
        [~, lOffEpoch] = min(abs(stageTime - startDiff));
        [~, lOnEpoch]  = min(abs(stageTime - endDiff));
        
    elseif isnat(lOffTime) && ~isnat(lOnTime)
        lOffEpoch = 1;
        [~, lOnEpoch] = min(abs(stageTime - endDiff));
    elseif ~isnat(lOffTime) && isnat(lOnTime)
        [~, lOffEpoch] = min(abs(stageTime - startDiff));
        lOnEpoch = length(stages);
    elseif isnat(lOffTime) && isnat(lOnTime)
        lOffEpoch = 1;
        lOnEpoch  = length(stages);
    end
    
end
%% Find sleep onset epoch

% Shorten stages to start at lights off
stages(1:lOffEpoch-1) = 7;
stages = stages(min(find(stages ~= 7)):max(find(stages ~=7)));

% Find sleep onset epoch
if solMode == 1
    % First epoch of sleep
    solEpoch = find(stages > 0, 1, 'first');
    
elseif solMode == 2
    
    % 90 seconds of continuous sleep
    solStages = stages;
    solStages(solStages > 0) = 1;
    solStages = strfind(solStages', [1 1 1]);
    
    solIdx = solStages + 3;
    
    solStage = 0;
    ep = 1;
    while solStage == 0
        solStage = stages(solIdx(ep));
        if solStage > 0
            solEpoch = solIdx(ep);
            break
        end
    end
    
elseif solMode == 3
    
    % 10 minutes of continuous sleep
    solStages = stages;
    solStages(solStages > 0) = 1;
    
    % How long is 10 minutes?
    solStages = strfind(solStages', ones(1, (600 / epochLength)));
    
    solIdx = solStages + (600 / epochLength);
    
    solStage = 0;
    ep = 1;
    while solStage == 0
        solStage = stages(solIdx(ep));
        if solStage > 0
            solEpoch = solIdx(ep);
            break
        else
            ep = ep + 1;
        end
    end
elseif solMode == 4
    solEpoch = find(stages == 2, 1, 'first');
end

%% Calculate sleep statistics

tib  = (length(stages) * epochLength) / 60;
tst  = ((sum(stages > 0 & stages  < 6)) * epochLength) / 60;
sol  = (solEpoch * epochLength) / 60;
slef = (tst / tib) * 100;
waso = (sum(stages(solEpoch:end) == 0) * epochLength) / 60;

for i = 0:6
    stageMinTib(i+1) = (sum(stages == i) * epochLength) / 60;
    stageMinTst(i+1) = (sum(stages(stages > 0 & stages < 6) == i) * epochLength) / 60;
    stagePerTib(i+1) = (sum(stages == i) / length(stages)) * 100;
    stagePerTst(i+1) = (sum(stages(stages > 0 & stages < 6) == i) / length(stages(stages > 0 & stages < 6))) * 100;
end


if ~isnat(lOffTime)
    lOffString = datestr(lOffTime, 'HH:mm:ss.FFF');
else
    lOffString = ' ';
end

if ~isnat(lOnTime)
    lOnString = datestr(lOnTime, 'HH:mm:ss.FFF');
else
    lOnString = ' ';
end

sleepStats.lOff = lOffString;
sleepStats.lOn  = lOnString;
sleepStats.tib  = tib;
sleepStats.tst  = tst;
sleepStats.sol  = sol;
sleepStats.se   = slef;
sleepStats.waso = waso;
sleepStats.stageMinTIB = stageMinTib;
sleepStats.stageMinTST = stageMinTst;
sleepStats.stagePerTIB = stagePerTib;
sleepStats.stagePerTST = stagePerTst;

%% Report

if exist('sleepReport', 'var')
    
    if isfield(sleepstages.hdr, 'scorer')
        scorerID = sleepstages.hdr.scorer;
    else
        scorerID = ' ';
    end
    
    import mlreportgen.report.*
    import mlreportgen.dom.*
    
    
    R = Report(fullfile(sleepReport{2}, sleepReport{3}), 'html-file');
    
    open(R)
    
    l1 = Paragraph(['Sleep statistics report: ' sleepReport{1}]);
    l1.FontSize = '24';
    l1.FontFamilyName = 'Arial';
    l1.Bold = true;
   
    l2 = Paragraph(['Scored by: ' scorerID]);
    l2.FontSize = '22';
    l2.FontFamilyName = 'Arial';
    l2.Bold = true;
            
    l3 = Paragraph(Text(sprintf(['Lights off: ' lOffString '\n'...
        'Lights on: ' lOnString '\n'...
        'Time in bed: ' num2str(tib, '%.1f') ' min\n'...
        'Total sleep time: ' num2str(tst, '%.1f') ' min\n'...
        'Sleep onset latency: ' num2str(sol, '%.1f') ' min\n'...
        'Sleep efficiency: ' num2str(slef, '%.1f') ' %%\n'...
        'Wake after sleep onset : ' num2str(waso, '%.1f') ' min'])));
    l3.WhiteSpace = 'preserve';
    l3.FontSize = '20';
    l3.FontFamilyName = 'Arial';
        
    l4 = Paragraph('Table 1: Sleep statistics (of time in bed)');
    l4.Bold = true;
    l4.FontSize = '20';
    l4.FontFamilyName = 'Arial';

    table1 = Table({' ' 'Wake' 'N1' 'N2' 'N3' 'N4' 'REM' 'MVT' 'Total'; ...
        'Minutes' num2str(stageMinTib(1), '%.2f'), num2str(stageMinTib(2), '%.2f'), num2str(stageMinTib(3), '%.2f'),...
        num2str(stageMinTib(4), '%.2f'), num2str(stageMinTib(5), '%.2f'), num2str(stageMinTib(6), '%.2f'),...
        num2str(stageMinTib(7), '%.2f'), num2str(tib, '%.2f'); ...
        '%' num2str(stagePerTib(1), '%.2f'), num2str(stagePerTib(2), '%.2f'), num2str(stagePerTib(3), '%.2f'),...
        num2str(stagePerTib(4), '%.2f'), num2str(stagePerTib(5), '%.2f'), num2str(stagePerTib(6), '%.2f'),...
        num2str(stagePerTib(7), '%.2f'), num2str(sum(stagePerTib), '%.0f')});
    table1.RowSep = 'solid';
    table1.Width = '50%';
    table1.TableEntriesStyle = {FontFamily('Arial'), FontSize('20')};
    
    l5 = Paragraph('Table 2: Sleep statistics (of total sleep time)');
    l5.Bold = true;
    l5.FontSize = '20';
    l5.FontFamilyName = 'Arial';
    
    table2 = Table({' ' 'Wake' 'N1' 'N2' 'N3' 'N4' 'REM' 'MOVE' 'Total'; ...
        'Minutes' num2str(stageMinTst(1), '%.2f'), num2str(stageMinTst(2), '%.2f'), num2str(stageMinTst(3), '%.2f'),...
        num2str(stageMinTst(4), '%.2f'), num2str(stageMinTst(5), '%.2f'), num2str(stageMinTst(6), '%.2f'),...
        num2str(stageMinTst(7), '%.2f'), num2str(tst, '%.2f'); ...
        '%' num2str(stagePerTst(1), '%.2f'), num2str(stagePerTst(2), '%.2f'), num2str(stagePerTst(3), '%.2f'),...
        num2str(stagePerTst(4), '%.2f'), num2str(stagePerTst(5), '%.2f'), num2str(stagePerTst(6), '%.2f'),...
        num2str(stagePerTst(7), '%.2f'), num2str(sum(stagePerTst), '%.0f')});
    table2.RowSep = 'solid';
    table2.Width = '50%';
    table2.TableEntriesStyle = {FontFamily('Arial'), FontSize('20')};
       
    p1 = figure;
    
    if length(sleepstages.stages) < 150
        plot_hypnogram(sleepstages, 'TickPeriod', 30);
    else
        plot_hypnogram(sleepstages, 'TickPeriod', 120);
        colormap(p1, hypnomap)
    end
        
    if isfield(sleepstages, 'spectogram')
        
        p2 = figure;
        
        if length(sleepstages.stages) < 150
            plot_spectogram(sleepstages.spectogram.specto, sleepstages.spectogram.freqs, [0 30], sleepstages, 1,...
                'TickPeriod', 30);
        else
            plot_spectogram(sleepstages.spectogram.specto, sleepstages.spectogram.freqs, [0 30], sleepstages, 1,...
                'TickPeriod', 120);
        end
            
        caxis(gca, [0 1])
        colormap(gca, hot)
        
    end
    
    add(R, l1)
    add(R, l2)
    add(R, l3)
    add(R, l4)
    add(R, table1)
    add(R, l5)
    add(R, table2)
    add(R, Figure(p1));
    
    if exist('p2', 'var')
        add(R, Figure(p2))
        close(p2)
    end
    
    close(p1)
    
    close(R)
    
    web(fullfile(sleepReport{2}, [sleepReport{3} '.html']))
    
end
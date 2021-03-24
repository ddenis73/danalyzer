function reliability = fun_scorer_reliability(sleepstages, varargin)
% Calculate inter-rater reliability between two scorers. Automaticially
% generate Cohen's kappa and percent agreement for two score files.
%
% Required inputs:
%
% sleepstages: a 1xn struct containing a sleepstages file for each score
% file to compare. For all comparisons, the *second* file is the 'master'
% score file that file 1 is compared against.
%
% Optional inputs:
%
% Report: Produce an html reliability report. 1x2 cell array {filepath, filename}.
%
% Outputs:
%
% reliability: A struct containing inter-rater reliability between the two
% score files

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

if find(strcmpi(varargin, 'Report'))
    reliabilityReport = varargin{find(strcmpi(varargin, 'Report'))+1};
end

%% Calculate reliability

for i = 1:length(sleepstages)
    
    rec = datetime(sleepstages(i).hdr.recStart, 'Format', 'HH:mm:ss.SSS');
    lout = datetime(sleepstages(i).hdr.lOff, 'Format', 'HH:mm:ss.SSS');
    lon = datetime(sleepstages(i).hdr.lOn, 'Format', 'HH:mm:ss.SSS');
    
    diff = seconds(lout - rec);
    diff2 = seconds(lon - rec);
    
    if diff2 < 0
        diff2 = diff2 + 86400;
    end
    
    % if not lights off/on times provided, assume first and last to be lights
    % off/on
    if ~isnan(diff) && ~isnan(diff2)
        loutSample = diff * sleepstages(i).hdr.srate;
        lonSample  = diff2 * sleepstages(i).hdr.srate;
    elseif isnan(diff) && ~isnan(diff2)
        loutSample = 1;
        lonSample  = diff2 * sleepstages(i).hdr.srate;
    elseif ~isnan(diff) && isnan(diff2)
        loutSample = diff * sleepstages(i).hdr.srate;
        lonSample  = (length(sleepstages(i).hdr.onsets) * sleepstages(i).hdr.win) * sleepstages(i).hdr.srate;
    else
        loutSample = 1;
        lonSample  = (length(sleepstages(i).hdr.onsets) * sleepstages(i).hdr.win) * sleepstages(i).hdr.srate;
    end
    
    
    [~, loutEpoch] = min(abs(sleepstages(i).hdr.onsets - loutSample));
    sleepStats.lightsOutEpoch = loutEpoch;
    
    [~, lonEpoch]  = min(abs(sleepstages(i).hdr.onsets - lonSample));
    sleepStats.lightsOnEpoch = lonEpoch;
    
    sleepstages(i).stages(1:loutEpoch-1) = 7;
    
    stages(:, i) = sleepstages(i).stages(min(find(sleepstages(i).stages ~= 7)):max(find(sleepstages(i).stages ~=7) ));
    
    if isfield(sleepstages(i).hdr, 'scorer')
        scorerName{1, i} = sleepstages(i).hdr.scorer;
    else
        scorerName{1, i} = '';
    end
    
end

% Agreement table for all comparisons
c = 1;
pptColors = {'k' 'r' 'b' 'g' 'y' 'm' 'c'};
hypnoX = 1:1:length(sleepstages(1).stages);

fa = cell(1, length(sleepstages));

for i = 1:length(sleepstages)
    
    for j = i+1:length(sleepstages)
        
        %% Plot hypnogram
        
        if exist('reliabilityReport', 'var')
            h = figure;
            if length(stages) < 150
                plot_hypnogram(sleepstages(j), 'Color', pptColors{j}, 'TickPeriod', 30)
                hold on
                plot_hypnogram(sleepstages(i), 'Color', pptColors{i}, 'TickPeriod', 30)
                legend([h.Children.Children(4) h.Children.Children(8)], {['Scorer ' num2str(i)] ['Scorer ' num2str(j)]},...
                    'Location', 'SouthEast')
            else
                plot_hypnogram(sleepstages(j), 'Color', pptColors{j}, 'TickPeriod', 120)
                hold on
                plot_hypnogram(sleepstages(i), 'Color', pptColors{i}, 'TickPeriod', 120)
                legend([h.Children.Children(4) h.Children.Children(8)], {['Scorer ' num2str(i)] ['Scorer ' num2str(j)]},...
                    'Location', 'SouthEast')
            end
            title(gca, ['Scorer ' num2str(i) ' vs Scorer ' num2str(j)])
        end
        
        comparison{c,:} = ['Scorer ' num2str(i) ' / Scorer ' num2str(j)];
        cn(c,:) = [i j];
        %table = zeros(1, 8, 8);
        
        for t = 0:6
            for t2 = 0:6
                table(c, t+1, t2+1) = sum(stages(:, i) == t & stages(:, j) == t2);
            end
        end
        
        % Calculate observed agreement
        Po = sum(diag(squeeze(table(c,:,:)))) ./ sum(sum(squeeze(table(c,:,:))));
        Pe = 0;
        
        % Calculate expected agreement if at chance
        for x = 1:size(squeeze(table(c,:,:)), 1)
            Pe = Pe + sum(squeeze(table(c,x,:))) / sum(sum(squeeze(table(c,:,:)))) * sum(squeeze(table(c,:,x))) / sum(sum(squeeze(table(c,:,:))));
        end
        
        % Calculate Kappa
        cKappa(c,:) = (Po - Pe) / (1 - Pe);
        
        if cKappa(c) < 0
            agreement{c,:} = 'No Agreement';
        elseif cKappa(c) >=0 && cKappa(c) <= .20
            agreement{c,:}  = 'Slight Agreement';
        elseif cKappa(c) > .20 && cKappa(c) <= .40
            agreement{c,:}  = 'Fair Agreement';
        elseif cKappa(c) > .40 && cKappa(c) <= .60
            agreement{c,:}  = 'Moderate Agreement';
        elseif cKappa(c) > .60 && cKappa(c) <= .80
            agreement{c,:}  = 'Substantial Agreement';
        elseif cKappa(c) > .80 && cKappa(c) < 1
            agreement{c,:}  = 'Near Perfect Agreement';
        elseif cKappa(c) >= 1
            agreement{c,:}  = 'Perfect Agreement';
        end
        
        
        agreementTable(c,:,:) = [[squeeze(table(c,:,:));sum(squeeze(table(c,:,:)),1)]...
            [sum(squeeze(table(c,1,:)));[sum(squeeze(table(c,2,:)));sum(squeeze(table(c,3,:)));sum(squeeze(table(c,4,:)));sum(squeeze(table(c,5,:)));sum(squeeze(table(c,6,:)));sum(squeeze(table(c,7,:)))]; sum(sum(squeeze(table(c,:,:))))]];
        percentAgreement(c,:) = [(diag(squeeze(table(c,:,:)))'./sum(squeeze(table(c,:,:)),1)).*100 sum(diag(squeeze(table(c,:,:))))'./sum(sum(squeeze(table(c,:,:))))*100];
        
        fa{:, c} = h;
        
        c = c+1;
        
    end
end


reliability.comparisons = comparison;
reliability.table       = table;
reliability.kappa       = cKappa;
reliability.agreement   = agreement;
reliability.percentAgreement = percentAgreement;
%% Produce reliability report

if exist('reliabilityReport', 'var')
    
    import mlreportgen.report.*
    import mlreportgen.dom.*
    
    R = Report(fullfile(reliabilityReport{1}, reliabilityReport{2}), 'html-file');
    
    open(R)
    
    l1 = Paragraph('Reliability report');
    l1.FontSize = '16';
    l1.FontFamilyName = 'Arial';
    l1.Bold = true;
    
    for i = 1:length(scorerName)
        s{i, 1} = ['Scorer ' num2str(i) ': ' scorerName{1, i}];
    end
    
    l2 = Table(s);
    l2.RowSep = 'none';
    l2.Width = "6.5in";
    l2.TableEntriesStyle = {FontFamily('Arial'), FontSize('16'), Bold(true)};
    
    add(R, l1)
    add(R, l2)
    
    
    for i = 1:length(comparison)
        
        l3 = Paragraph('Agreement table');
        l3.FontSize = '18';
        l3.FontFamilyName = 'Arial';
        l3.Bold = true;
        
        l4 = Paragraph('Percent agreement');
        l4.FontSize = '18';
        l4.FontFamilyName = 'Arial';
        l4.Bold = true;
        
        l5 = Paragraph(['Kappa: ' num2str(cKappa(i), '%.2f') ' ' agreement{i}]);
        l5.FontSize = '16';
        l5.FontFamilyName = 'Arial';
        l5.Bold = true;
        
        f = Figure(fa{i});
        f.Width = "6.5in";
        f.Height = "6in";
        
        header = {comparison{i} 'Wake' 'N1' 'N2' 'N3' 'N4' 'REM' 'MVT'};
        a = [{'Wake'; 'N1'; 'N2'; 'N3'; 'N4'; 'REM'; 'MVT'} num2cell(squeeze(table(i,:,:)))];
        
        table1 = Table([header; a]);
        table1.RowSep = 'solid';
        table1.Width = "6.5in";
        table1.TableEntriesStyle = {FontFamily('Arial'), FontSize('16')};
        
        table2 = Table({'Wake' 'N1' 'N2' 'N3' 'N4' 'REM' 'MVT' 'Total';...
            num2str(percentAgreement(i, 1), '%.2f') num2str(percentAgreement(i, 2), '%.2f')...
            num2str(percentAgreement(i, 3), '%.2f') num2str(percentAgreement(i, 4), '%.2f')...
            num2str(percentAgreement(i, 5), '%.2f') num2str(percentAgreement(i, 6), '%.2f')...
            num2str(percentAgreement(i, 7), '%.2f') num2str(percentAgreement(i, 8), '%.2f')});
        table2.RowSep = 'solid';
        table2.Width = "6.5in";
        table2.TableEntriesStyle = {FontFamily('Arial'), FontSize('16')};
        
        add(R, f)
        close(fa{i})
        
        add(R, l3)
        add(R, table1)
        add(R, l4)
        add(R, table2)
        add(R, l5)
        
    end
    
    close(R)
    
    web(fullfile(reliabilityReport{1}, [reliabilityReport{2} '.html']))
    
end
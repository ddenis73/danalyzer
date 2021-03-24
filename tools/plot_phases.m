function h = plot_phases(data, color)
% Produces a polar plot of phase angles. Input data must be in radians.
% Requires circStats package

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


if iscell(data)
    
    for i = 1:length(data)
        
        % Remove any NaN
        data{i}(isnan(data{i})) = [];
        
        % Find the mean vector length
        r(i) = circ_r(data{i}');
        
        % Find the mean phase
        mn(i) = circ_mean(data{i}');
        
    end
    
else
    data(isnan(data)) = [];
    r = circ_r(data');
    mn = circ_mean(data');
end

% Set rlim in polar plot
t = 0 : .01 : 2*pi;
[P] = polar(t, 1*ones(size(t)));
set(P, 'Visible', 'On')
hold on

if iscell(data)
    for i = 1:length(data)
        
        % Compass plot all the phase distributions
        h = compass_lines(exp(1i*data{i}));
        set(h, 'Color', [color(i,:) 0.5], 'LineWidth', 1)
        
        
    end
else
    % Compass plot all the phase distributions
    h = compass_lines(exp(1i*data));
    set(h, 'Color', [color 0.5], 'LineWidth', 1)
    
end

if iscell(data)
    for i = 1:length(data)
        
        % Plot Amplitude Criterion Mean Phase
        h  = compass(r(i)*exp(1i*mn(i)));
        set(h, 'Color',[color(i,:) 1],'Linewidth',2)
        
    end
    
else
    % Plot Amplitude Criterion Mean Phase
    h  = compass(r*exp(1i*mn(1)));
    set(h, 'Color','k','Linewidth',2)
    
end

% Plot athick outline
xx = 1*ones(size(t)) .* cos(t);
yy = 1*ones(size(t)) .* sin(t);
plot(xx, yy, 'Color','k','Linewidth',2);
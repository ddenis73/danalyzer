function n = fun_otsu_criterion(data, threshold)
% Otsu's criterion of between-class variance. use to empirically determine
% optimum thresholdhold for sleep spindle detection. Find the thresholdhold (e.g. data
% * the signal median) that madataimizes between-class variance (spindle,
% non-spindle)
%
% Required inputs:
%
% data = Wavelet coefficient
%
% thresholdhold = Threshold
%
% Outputs:
%
% n = Value of discriminant criterion measures
%
%% 
% Authors:  Dimitrios Mylonas
%           Dan Denis
% Date:     2021-07-14
%
% Remarks:
%   Free use and modification of this code is permitted, provided that any
%   modifications are also freely distributed
%
%   When using this code or modifications of this code, please cite:
%       Denis D (2021). danalyzer. DOI: 10.5281/zenodo.5104418
%% Implementation

N = length(data);

k = length( find(data<=threshold) );

% Probabilities of class occurrence
omega0 = k/N; 
omega1 = (N-k)/N;

% Do only if k is in the effective range of the data (neither class is empty)
if omega0*omega1 > 0 
    
    % Class' mean level
    mu0 = sum(data(data<=threshold))/(N*omega0);
    mu1 = sum(data(data> threshold))/(N*omega1);
    
    % The total mean level of the signal
    muT = sum(data)/N;

    %% Calculate class variances
    tmpA = data(data<=threshold); tmpB = ones(length(1:k),1)*mu0;
    sigma0 = sum((tmpA - tmpB).^2)/(omega0*N);
    tmpA = data(data> threshold); tmpB = ones(length(k+1:N),1)*mu1;
    sigma1 = sum((tmpA - tmpB).^2)/(omega1*N);
    
    %% Calculate within, between and total class variances
    % Within
    sigmaW = omega0*sigma0 + omega1*sigma1;
    % Between
    sigmaB = omega0*omega1*((mu1 - mu0)^2);
    % Total
    sigmaT = sigmaW + sigmaB;
    
    %% Calculate criteria
    n = sigmaB/sigmaT;
    
else
    n= nan;
    disp('Threshold outside of the effective range of data')
end


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
%%
se_version = '0.9-beta.2';
se_path = fileparts(which('sleepDanalyzer'));
% Check for EEGLAB

if ~exist('eeglab.m', 'file')
    
    warning('EEGLAB not found on path. Many functions will not work')

elseif exist('eeglab.m', 'file') && ~exist('pop_biosig.m', 'file')
    
    warning('BIOSIG extension for EEGLAB not found. Will not be able to import .edf files')
    
elseif exist('eeglab.m', 'file') && ~exist('pop_loadbv.m', 'file')
    
    warning('bva-io extension for EEGLAB not found. Will not be able to import Brain Vision files')
    
end

% Load dependencies 

fprintf(['\nStarting sleepDanalyzer version: ' se_version])

if str2double(se_version(1)) < 1
    fprintf('\n\nNOTE: This is a beta version of sleepDanalyzer!!!\nFeatures still in development\n\n') 
end

fprintf('\n\nWelcome to sleepDanalyzer!\n\n')

data_viewer

se_version = '0.9.1';
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

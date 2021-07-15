function [psgOUT, scoresOUT] = fun_subset_data(psgIN, scoresIN, ar, varargin)
% Subset a continuous dataset in artifct free segments of either a
% particular sleep stage or a defined set of epochs. 
%
% Required inputs:
%
% psgIN: A danalyzer psg structure
%
% scoresIN: A danalyzer sleepstages struct or an array of sleep stages
%
% ar: a danalyzer ar struct.
%
% Optional inputs:
%
% 'stage': Select epochs belonging to a particular stage.
%
% 'epoch': Select epochs based on epoch number
%
% 'RemoveChannels': a cell array or array of channel indicies of
% channels to remove from the data. Default, do not remove any channels
%
% 'Interpolate' = 'yes' or 'no' Interpolate bad channels using spherical 
% splines. Default = 'no'
% 
% Outputs:
%
% psgOUT = A subsetted PSG struct
%
% scoresOUT = Sleep stages adjusted to match the subsetted data file
%
%%
% Authors:  Dan Denis
% Date:     2021-07-14
%
% Remarks:
%   Free use and modification of this code is permitted, provided that any
%   modifications are also freely distributed
%
%   When using this code or modifications of this code, please cite:
%       Denis D (2021). danalyzer. DOI: 10.5281/zenodo.5104418
%% Default settings for optional inputs

chans2Remove = {};
interp = 'no';
stage = [];
epoch = [];
verbose = 'yes';

if find(strcmpi(varargin, 'Stage'))
    stage = varargin{find(strcmpi(varargin, 'Stage'))+1};
end

if find(strcmpi(varargin, 'Epoch'))
    epoch = varargin{find(strcmpi(varargin, 'Epoch'))+1};
end

if find(strcmpi(varargin, 'RemoveChannels'))
    chans2Remove = varargin{find(strcmpi(varargin, 'RemoveChannels'))+1};
end

if find(strcmpi(varargin, 'Interpolate'))
    interp = varargin{find(strcmpi(varargin, 'Interpolate'))+1};
end

if find(strcmpi(varargin, 'Verbose'))
    verbose = varargin{find(strcmpi(varargin, 'Verbose'))+1};
end

if ~isempty(stage) && ~isempty(epoch)
    warning('Cannot subset based on both stages and epochs... Subsetting based on stages.')
    epoch = [];
end

msg = 'Subsetting input data. Returning clean epochs from ';

if ~isstruct(scoresIN)
    scoreArray = scoresIN;
    clear scores
    scoresIN.stages = scoreArray;
end

if strcmpi(verbose, 'yes')
    
    if ~isempty(stage)
        fprintf([msg 'stage ' num2str(stage) '.\n'])
    elseif ~isempty(epoch)
        fprintf([msg 'epochs ' num2str(epoch(1)) ' : ' num2str(epoch(end)) '.\n'])
    end
    
end

if isempty(ar)
    ar.badchans  = zeros(size(psgIN.data, 1), 1);
    nEpochs      = indexepochs(scoresIN.hdr.win * psgIN.hdr.srate, psgIN.hdr.samples);
    ar.badepochs = zeros(length(nEpochs), 1);
end

%% Remove/interpolate bad channels

% Find channels to remove

if iscell(chans2Remove)
    noChanIdx = find(ismember({psgIN.chans.labels}, chans2Remove));
else
    noChanIdx = chans2Remove;
end

if ~isempty(chans2Remove)
    % Remove the channels
    psgIN.data(noChanIdx, :) = [];
    
    % Update the chanlocs field
    psgIN.chans(noChanIdx) = [];
    
    % Update the badchans field
    ar.badchans(noChanIdx) = [];
end

if strcmpi(verbose, 'yes')
    fprintf(['Removing ' num2str(length(noChanIdx)) ' channels.\n'])
end

if strcmpi(interp, 'yes')
    
    % Find which channels need to be interpolated
    interpIdx = find(ar.badchans);
    fprintf(['Interpolating ' num2str(length(interpIdx)) ' bad channels.\n'])
    % Run the interpolation
    if ~isempty(interpIdx)
        psgIN.data = fun_interpolate_data(psgIN.data, psgIN.chans, ar.badchans);
    end
    
end

%% Subset into different sleep stages

if ~isempty(stage)
    
    if any(ismember(scoresIN.stages, stage))
        [psgOUT, scoresOUT] = subsetsleepstage(psgIN, scoresIN, ar, stage, verbose);
    else
        psgOUT = [];
        scoresOUT = scoresIN;
    end
    
elseif ~isempty(epoch)
    
    [psgOUT, scoresOUT] = subsetepoch(psgIN, scoresIN, ar, epoch);
    
else
    psgOUT = psgIN;
    scoresOUT = scoresIN;
end


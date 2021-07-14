function psgOut = eeglab2danalyzer(psgIn)
% Converts an EEGLAB struct to danalyzer format.
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
%%

psgOut.data         = psgIn.data;
psgOut.hdr.srate    = psgIn.srate;
psgOut.hdr.samples  = psgIn.pnts;

if isfield(psgIn.etc, 'T0')
    psgOut.hdr.recStart = psgIn.etc.T0;
else
    psgOut.hdr.recStart = [];
end

psgOut.chans        = psgIn.chanlocs;

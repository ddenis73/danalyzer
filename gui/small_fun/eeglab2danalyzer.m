function psgOut = eeglab2danalyzer(psgIn)

% Converts an EEGLAB struct to danalyzer format.

psgOut.data         = psgIn.data;
psgOut.hdr.srate    = psgIn.srate;
psgOut.hdr.samples  = psgIn.pnts;

if isfield(psgIn.etc, 'T0')
    psgOut.hdr.recStart = psgIn.etc.T0;
else
    psgOut.hdr.recStart = [];
end

psgOut.chans        = psgIn.chanlocs;

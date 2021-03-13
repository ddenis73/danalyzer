% Get length of epoch in samples
epochSampleLength = 30 * 400;

% Get start and end sample of each epoch
epochSample(:,1) = (1:epochSampleLength:EEGIN.pnts)';
epochSample(:,2) = (unique([epochSampleLength:epochSampleLength:...
    EEGIN.pnts, EEGIN.pnts]))';



stage2 = find(scores == 2);
badEpochs = find(ar.badepochs == 1);

toRemove = ismember(stage2, badEpochs);

stage2Clean = stage2(~toRemove);

n2EpochSample = epochSample(stage2Clean,:);

for i = 1:length(n2EpochSample)

    if i == 1
    n2Segments = n2EpochSample(i,1):1:n2EpochSample(i,2);
    else
        n2Segments = [n2Segments n2EpochSample(i,1):1:n2EpochSample(i,2)];
    end
    
end

n2Clean = EEGIN.data(:, n2Segments);

% Get start and end sample of each epoch
n2NewEpochSample(:,1) = (1:epochSampleLength:length(n2Clean))';
n2NewEpochSample(:,2) = (unique([epochSampleLength:epochSampleLength:...
    length(n2Clean), length(n2Clean)]))';




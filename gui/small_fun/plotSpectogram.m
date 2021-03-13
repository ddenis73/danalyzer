function plotSpectogram(scores)

% Plot a spectogram

scaleFactor = scores.spectogram.scaleFactor;
Flims = scores.spectogram.freqLims;
freqs = scores.spectogram.freqs;
spectoPSD = scores.spectogram.specto;
spectoY = freqs(min(find(freqs>=Flims(1))):max(find(freqs<=Flims(2))));
%     [0+(scaleFactor/handles.psg.hdr.srate)/60:(scaleFactor/handles.psg.hdr.srate)/60:size(spectoPSD,1)*scaleFactor/handles.psg.hdr.srate/60]./60, ...
%         freqs(min(find(freqs>=Flims(1))):max(find(freqs<=Flims(2))))

%Plot in Hours
onT = seconds(datetime(scores.hdr.lOn) - datetime(scores.hdr.recStart));
if onT < 0
    onT = 86400-abs(onT);
end
offT = seconds(datetime(scores.hdr.lOff) - datetime(scores.hdr.recStart));

dist    = abs(scores.hdr.stageTime - onT);
minDist = min(dist);
lOnEpoch     = find(dist == minDist);

dist    = abs(scores.hdr.stageTime - offT);
minDist = min(dist);
lOffEpoch     = find(dist == minDist);


figure;
imagesc(1:length(scores.hdr.stageTime), spectoY, spectoPSD);
set(gca, 'YDir','normal');
colormap(jet);
caxis([-20 20])
%xlim([1 length(handles.psg.stages.stages)])
ylim([spectoY(1) spectoY(end)])
xlabel('Epoch')
ylabel ('Frequency (\muV^{2}/Hz)')
set(gca, 'XGrid', 'off', 'YGrid', 'on', 'TickLength', [0 0],'NextPlot','replacechildren');

hold on
plot([lOnEpoch, lOnEpoch], [spectoY(1), spectoY(end)], 'm', 'LineWidth', 2);
plot([lOffEpoch, lOffEpoch], [spectoY(1), spectoY(end)], 'm', 'LineWidth', 2);
plot(lOnEpoch,spectoY(end),'k^','MarkerSize',8,'MarkerFaceColor','m');
plot(lOffEpoch,spectoY(end),'kv','MarkerSize',8,'MarkerFaceColor','m');
hold off



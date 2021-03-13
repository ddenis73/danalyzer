function handles = dan_edit_montage(handles)
% Pull up an inputdlg to change montage parameters on the fly

montage = handles.montage;

if ~isempty(montage.scaleLine)
    scaleChan = montage.scaleLine{1};
else
    scaleChan = '';
end

scaleLineStr = ['[' sprintf('%g;', montage.scaleLinePos) ']'];
scaleColorStr = [ '[' sprintf('%g ', montage.scaleLineColor) ']'];

if ~isempty(montage.scaleLineType)
    scaleTypeStr = montage.scaleLineType;
else
    scaleTypeStr = '';
end

if ~isempty(montage.hideChans)
    hideChanStr = strjoin(montage.hideChans);
else
    hideChanStr = '';
end

showChanStr = strjoin(montage.showChans);
eegLineColorStr = [ '[' sprintf('%g ', montage.colors(1,:)) ']'];
emgLineColorStr = [ '[' sprintf('%g ', montage.colors(2,:)) ']'];
eogLineColorStr = [ '[' sprintf('%g ', montage.colors(3,:)) ']'];
ecgLineColorStr = [ '[' sprintf('%g ', montage.colors(4,:)) ']'];
otherLineColorStr = [ '[' sprintf('%g ', montage.colors(5,:)) ']'];

prompt = {'Scale channel:', 'Scale values:', 'Scale colors:', 'Scale line:',...
    'Hide channels:', 'Channel order:', 'EEG color:', 'EOG color:', 'EMG color:', 'ECG color:', 'Other color:'};
name = 'Edit montage properties';
numlines = 1;
defaultAns = {scaleChan,...
    scaleLineStr, scaleColorStr, scaleTypeStr, hideChanStr,...
    showChanStr, eegLineColorStr, emgLineColorStr, eogLineColorStr, ecgLineColorStr, otherLineColorStr};
answer = inputdlg(prompt, name, numlines, defaultAns);

if ~isempty(answer{1})
    montage.scaleLine = answer(1);
end

if ~isempty(answer{2})
    if ~isempty(montage.scaleLinePos)
        montage.scaleLinePos = [];
    end
    montage.scaleLinePos = eval(answer{2});
end

if ~isempty(answer{3})
    montage.scaleLineColor = eval(answer{3});
end

if ~isempty(answer{4})
    montage.scaleLineType = answer{4};
end

if ~isempty(answer{5})
    montage.hideChans = strsplit(answer{5});
else
    montage.hideChans = '';
end

if ~isempty(answer{6})
    montage.showChans = strsplit(answer{6});
end

if ~isempty(answer{7})
    montage.colors(1,:) = eval(answer{7});
end

if ~isempty(answer{8})
    montage.colors(2,:) = eval(answer{8});
end

if ~isempty(answer{9})
    montage.colors(3,:) = eval(answer{9});
end

if ~isempty(answer{10})
    montage.colors(4,:) = eval(answer{10});
end

if ~isempty(answer{11})
    montage.colors(5,:) = eval(answer{11});
end

handles.montage = montage;
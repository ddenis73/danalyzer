function handles = dan_adjust_channel(handles)

% Add and/or remove channel filters and references
montage = handles.montage;
chanProp = inputdlg({'Channel name', 'Channel type', 'New reference', 'Lower edge', 'Higher edge', 'Add notch'}, 'Channel property editor');

% Update montage to reflect changes

chanIdx = ismember(montage.showChans, chanProp{1, 1});

if ~isempty(chanProp{3, 1})
    montage.reref{chanIdx} = chanProp{3, 1};
elseif isempty(chanProp{3, 1})
    montage.reref{chanIdx} = [];
end

if ~isempty(chanProp{4, 1})
    montage.filters(chanIdx, 1) = str2double(chanProp{4, 1});
end

if ~isempty(chanProp{5, 1})
    montage.filters(chanIdx, 2) = str2double(chanProp{5, 1});
end

if ~isempty(chanProp{6, 1})
    montage.notch(chanIdx, 1) = 1;
end

handles.montage = montage;


% sleepDanalyzer montage script. 

% chanList. A list of channel names and (optionally) channel coordinates.
% This should be an EEGLAB chanlocs struct. Alternatively you can read in a
% .txt file using the readlocs function (EEGLAB). If you wish to
% differentiate channel types (e.g. EEG, EOG, etc.) make sure to use the
% .type field of the chanlocs struct. If chanList = [], sleepDanalyzer will
% use the chanlocs struct that is created during import/load
montage.chanList = readlocs('psg_low_density.txt', 'filetype', 'custom', 'format',...
    {'labels' 'X' 'Y' 'Z' 'type'});

% hideChans. List names of channels you wish to hide from view e.g. {'Fz'
% 'Cz} will hide channels 'Fz' and 'Cz' from view. If hideChans = [], no
% channels will be hidden from view
montage.hideChans = [];

% showChans. The opposite of hideChans. Use this field to control the order
% that the channels appear on the screen. if you wish to display the
% channels in a different order to how they are stored in the data,
% specify the order here e.g. {'LOC' 'ROC' 'F3' 'F4'} would display
% channels in that order i.e. the top channel would be 'LOC'. If you hide
% any channels, DO NOT put them in the showChans list. If showChans = [],
% channels will be displayed in the order they appear in the data.
montage.showChans = [];

% reref. Use this field to specify new references for any channels. Use a
% cell array, with the same number of elements as there are channels in the
% data. For the channel you wish to re-reference, enter the new reference
% channel in the corresponding row e.g. {' ' 'M1' ' '} would re-reference
% the second channel to M1, and channels 1 & 3 will not be re-referenced.
% If not re-referencing, create an empty nx1 cell array where n = number of
% channels
montage.reref = cell(9, 1);

% filters. Specify low and high pass filters for any channels. Use a nx2
% array, where n = the total number of channels. Column 1 should be the low
% pass filter value, and column 2 should be the high pass filter value. Use
% 0 to indicate no filter. This array must contain the same number of rows
% as there are channels. If not filtering, create a nx2 zeros array where 
% n = number of channels
montage.filters = zeros(9, 2);

% notch. Specify a notch filter for any channels. Use an nx1 array where n
% = the total number of channels. 1 = indicates apply 60Hz notch filter, 0
% = do not. This array must contain the same number of rows
% as there are channels. if not adding a notch, create nx1 zeros array
% where n = number of channels
montage.notch = zeros(9, 1);

% colors. Control the colors of EEG, EOG, EMG, ECG, and Other channels. Use
% a 5x3 array where each row corresponds to a channel type (EEG, EOG, EMG,
% ECG, Other) and each column is a MATLAB rgb triplet specifying the color.
% Note this only works if channel types are specified in the chanList.
montage.colors = [0 0 0; 0 0 1; 1 0 0; 0 1 0; 1 1 0];

% scaleLine. Name of the channel in which to draw scale lines around
montage.scaleLine = {'F3-M2'};

% scaleLinePos. Array containing where to plot scale lines at e.g. [-150;
% 0; 150] would draw scale lines at -150uV, 0uV, and 150uV around the
% selected channel
montage.scaleLinePos = [-37.5; 0; 37.5];

% scaleLineColor. The color of the scale lines, specified using MATLAB rgb
% triplets
montage.scaleLineColor = [1 0 1];

% scaleLinType. The linetype for the scale lines, specified using MATLAB
% convention e.g. '--'
montage.scaleLineType = '--';

function data = fun_interpolate_data(data, chans, badchans, varargin)
% Interpolate data on bad channles based on the activity and locations of
% other electrodes using a spherical spline method.
%
% Required inputs:
% 
% data: A channel channel x timepoints array
%
% chans: Channel locations in eeglab chanlocs format (psg.chans). Must
% contains X, Y, Z coordinaties (e.g. psg.chans.X)
%
% badchans: An array of 0 and 1 of the length of size(data, 1). 1s indicate
% bad channels to be interpolated (e.g. ar.badchans)
%
% Optional inputs:
%
% 'LegendreOrder': Order of the Legendre polynomial. Default = 30
%
% 'Smoothing': G smooting parameter (lambda). Default = 1e-5
% 
% Outputs:
%
% data: A channel x timepoints array with interpolated values
%
%%
% This code is an implementation of algorithms described by 
% Perrin, Pernier, Bertrand, and Echallier (1989). Code heavily based on
% Cohen MX (2014). Analyzing Neural Time Series Data.
%% Default settings

legOrder = 30;
smoothing = 1e-5;

if find(strcmpi(varargin, 'LegendreOrder'))
    legOrder = varargin{find(strcmpi(varargin, 'LegendreOrder'))+1};
end

if find(strcmpi(varargin, 'Smoothing'))
    smoothing = varargin{find(strcmpi(varargin, 'Smoothing'))+1};
end

%% separate the goodies from the baddies

x = [chans.X];
y = [chans.Y];
z = [chans.Z];

gx = x(badchans == 0);
gy = y(badchans == 0);
gz = z(badchans == 0);
bx = x(badchans == 1);
by = y(badchans == 1);
bz = z(badchans == 1);

numelectrodes  = numel(gx);
numelectrodesi = numel(bx);

m=2;

% scale XYZ coordinates to unit sphere
[junk,junk,spherical_radii] = cart2sph(x,y,z);
maxrad = max(spherical_radii);
gx = gx./maxrad;
gy = gy./maxrad;
gz = gz./maxrad;
bx = bx./maxrad;
by = by./maxrad;
bz = bz./maxrad;

disp(['Interpolating ' num2str(length(find(badchans == 1))) ' bad channels'])
%% compute G matrix for good electrodes

% initialize
G=zeros(numelectrodes);
cosdist=zeros(numelectrodes);

for i=1:numelectrodes
    for j=i+1:numelectrodes
        cosdist(i,j) = 1 - (( (gx(i)-gx(j))^2 + (gy(i)-gy(j))^2 + (gz(i)-gz(j))^2 ) / 2 );
    end
end
cosdist = cosdist+cosdist' + eye(numelectrodes);


% compute Legendre polynomial
legpoly = zeros(legOrder,numelectrodes,numelectrodes);
for ni=1:legOrder
    temp = legendre(ni,cosdist);
    legpoly(ni,:,:) = temp(1,:,:);
end

% precompute electrode-independent variables
twoN1  = 2*(1:legOrder)+1;
gdenom = ((1:legOrder).*((1:legOrder)+1)).^m;

for i=1:numelectrodes
    for j=i:numelectrodes
        
        g=0;
        for ni=1:legOrder
            % compute G and H terms
            g = g + (twoN1(ni) * legpoly(ni,i,j)) / gdenom(ni);
        end
        G(i,j) =  g/(4*pi);
    end
end
% symmetric matrix
G=G+G';
G = G-eye(numelectrodes)*G(1)/2;

% add smoothing constant to diagonal 
% (change G so output is unadulterated)
Gs = G + eye(numelectrodes)*smoothing;

%% compute G matrix for to-be-interpolated electrodes


Gi=zeros(numelectrodesi,numelectrodes);
cosdisti=zeros(numelectrodesi);

for i=1:numelectrodesi
    for j=1:numelectrodes
        cosdisti(i,j) = 1 - (( (bx(i)-gx(j))^2 + (by(i)-gy(j))^2 + (bz(i)-gz(j))^2 ) / 2 );
    end
end

% compute Legendre polynomial
legpolyi = zeros(legOrder,numelectrodesi,numelectrodes);
for ni=1:legOrder
    temp = legendre(ni,cosdisti);
    legpolyi(ni,:,:) = temp(1,:,:);
end

for i=1:numelectrodesi
    for j=1:numelectrodes
        
        g=0;
        for ni=1:legOrder
            % compute G and H terms
            g = g + (twoN1(ni) * legpolyi(ni,i,j)) / gdenom(ni);
        end
        Gi(i,j) =  g/(4*pi);
    end
end

%% interpolate

% reshape data to electrodes X time/trials
orig_data_size = squeeze(size(data));
if any(orig_data_size==1)
    data=data(:);
else
    data = reshape(data,orig_data_size(1),prod(orig_data_size(2:end)));
end

% interpolate and reshape to original data size
data(badchans == 1,:) = Gi*(pinv(G)*data(badchans == 0,:));
data = reshape(data,orig_data_size);

%% end
disp('Finished interpolating')
disp('**************');
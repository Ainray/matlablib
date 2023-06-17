function [er,et] = em_edipole_homo_fre_e_sphere(coords, freqs, sigma, epsilon, mu, p)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: e filed of electric dipole in spheric coordinates, the
%               the electric moment is assumed to be unit in default.
if (nargin < 3 || isempty(sigma))
    sigma = 0.0; %vacuum
end
if (nargin < 4 || isempty(epsilon))
    epsilon = 1.0;
end
if (nargin < 5 || isempty(mu))
    mu = 1.0;
end
if (nargin < 6 || isempty(m))
    p = 1.0;
end

factor = p/4/pi;
epsilon0 = 8.854187817e-12;
mu0 = 4*pi*1e-7;
ndim = 3;

freqs = freqs(:);

[m, n] = size(coords);
if m ~= ndim && n ~= ndim
    error('invalid coordinates: coords');
end
if m~=ndim
    coords = coords';
end

rr = coords(1,:).^2 + coords(2, :).^2 + coords(3, :).^2;
rhorho =  coords(1,:).^2 + coords(2, :).^2;
r = sqrt(rr);
rho = sqrt(rhorho);

epsilon = epsilon0 * epsilon;
mu  = mu0 * mu;
omega = 2*pi*freqs;
v1oy = 1./(1i * omega * epsilon + sigma); 

kk = omega .* omega * mu * epsilon - 1i * omega * mu * sigma;
k = sqrt(kk);

ikr = 1i * k * r;
e_ikr = exp(-ikr);
kkrr = kk * rr;

d1 = 1 + ikr;
d2 = 1 + ikr - kkrr;
d3 = factor * (v1oy * r.^-3) .* e_ikr;

cost = diag(coords(3, :) ./ rr);
sint = diag(rho ./ rr);

er  = d3 .* (2 * d1 * cost);  % tranverse component
et = d3 .* ( d2 * sint);
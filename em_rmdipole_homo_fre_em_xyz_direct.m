function [hr, ht, hphi, hnorm] = em_rmdipole_homo_fre_h_sphere(coords, freqs, sigma, epsilon,mu, m)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: h filed of rotating counterclockwisely magnetic dipole in xy-plane in Spheric coordinates, the
%               the magnetic moment is assumed to be unit in default.
% test example,
% freqs=100;
% sig = 0.01;
% x = 100:20:1100;
% np = length(x);
% y = zeros(np, 1);
% z = zeros(np, 1);
% coords = [x(:)'; y(:)'; z(:)'];
% 
% [hx, hy, hz] = rmbma_mdipole_superposition(coords, freqs);
% [hr2, ht2, hphi2] = vec_car2sph([hx(:) hy(:) hz(:)]', coords);
% [hr, ht, hphi] = em_rmdipole_homo_fre_h_sphere(coords, freqs);
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,3,24,1.5,10);
% 
% subplot(3,1,1);
% plot(x, abs(hr), 'r', 'LineWidth', lw);
% hold on;
% plot(x, abs(hr2), 'b.', 'LineWidth', lw);
% legend('direct','superposition');
% 
% subplot(3,1,2);
% plot(x, abs(ht), 'r', 'LineWidth', lw);
% hold on;
% plot(x, abs(ht2), 'b.', 'LineWidth', lw);
% legend('direct','superposition');
% 
% subplot(3,1,3);
% plot(x, abs(hphi), 'r', 'LineWidth', lw);
% hold on;
% plot(x, abs(hphi2), 'b.', 'LineWidth', lw);
% legend('direct','superposition');

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
    m = 1.0;
end

factor = m/4/pi;
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

rhorho = coords(1,:).^2 + coords(2, :).^2;
rho = sqrt(rhorho);

rr = rhorho + coords(3, :).^2;
r = sqrt(rr);

epsilon = epsilon0 * epsilon;
mu  = mu0 * mu;
omega = 2*pi*freqs;
kk = omega .* omega * mu * epsilon - 1i * omega * mu * sigma;
k = sqrt(kk);

ikr = 1i * k * r;
kkrr = kk * rr;
e_ikr = exp(-ikr);
e_iphi = coords(1,:)./rho - 1i * coords(2,:)./rho;
v1or3 = diag(r.^-3 .* e_iphi); %1/r^3 * e^(-j phi)

factor = factor * e_ikr * v1or3;

d1 = (kkrr - ikr -1);
d2 = 1 + ikr;
hr = factor .* d2 * 2 * diag(rho./r);
ht = factor .* d1 * diag(coords(3,:)./r);
hphi = factor .* d1 * (-1i);

hnorm = sqrt(hr .* conj(hr) + ht .* conj(ht) + hphi .* conj(hphi));
% Gong's formular
% hr = factor .* (-(2*1i + k * r) * diag(rho./r));
% ht = factor .* ( 1i +2 * k * r - 1i * kkrr) * diag(coords(3,:)./r);
% hphi = factor .* ( -1 + (2 * 1i * k *r + kkrr) * diag(coords(3,:).^2 ./r.^2)); 
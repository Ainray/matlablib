function [hl, ht1, ht2] = em_mdipole_homo_fre_h_xyz(coords, freqs, direction, sigma, epsilon,mu, m)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: h filed of magnetic dipole in Cartesian coordinates, the
%               the magnetic moment is assumed to be unit in default.
%    hl, means the magnetic filed of the dipole direction (e.g. hz, or hx, or hy)
%    [ht1 ht2], tranverse components ( e.g. [hx, hy], or [hy, hz], or [hz, hx] )
% test example, 
%        Nabighian M N. Electromagnetic Methods in Applied Geophysics, 1, Theory[M]. Society of Exploration Geophysicists, Tulsa, OK, 1987, P176. Fig2.2.
%
%         coords = [0, 100, 0];
%         freqs = logspace(-2,5, 100);
%         sigma = 0.01;
% 
%         [hx, hy, hz] = em_mdipole_free_fre_h_xyz(coords, freqs, 0, sigma);
% 
%         [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,3,24,1.5,10);
% 
%         loglog(freqs, abs(real(hx(:,1))), 'r', 'linewidth', lw);
%         hold on;
%         loglog(freqs, abs(imag(hx(:,1))), 'b', 'linewidth', lw);
%         legend('real','imag', 'Location', 'southeast');
%         xlabel ('frequency (Hz)');
%         ylabel ('H_x (A/m)');

if (nargin < 3 || isempty(direction))
    direction = 2; % 0: x, 1: y, 2: z
end
if (nargin < 4 || isempty(sigma))
    sigma = 0.0; %vacuum
end
if (nargin < 5 || isempty(epsilon))
    epsilon = 1.0;
end
if (nargin < 6 || isempty(mu))
    mu = 1.0;
end
if (nargin < 7 || isempty(m))
    m = 1.0;
end

if (direction ~= 0 && direction ~= 1 && direction ~= 2)
    error('direction of dipole must be 0, 1 or 2.');
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

rr = coords(1,:).^2 + coords(2, :).^2 + coords(3, :).^2;
r = sqrt(rr);

epsilon = epsilon0 * epsilon;
mu  = mu0 * mu;
omega = 2*pi*freqs;
kk = omega .* omega * mu * epsilon - 1i * omega * mu * sigma;
k = sqrt(kk);

ikr = 1i * k * r;
kkrr = kk * rr;
e_ikr = exp(-ikr);
v1or3 = diag(r.^-3); %1/r^3

d1 = 3 + 3 * ikr - kkrr;
d2 = 1 + ikr - kkrr;

indexl = direction + 1;
indext1 = direction + 2;
if indext1 > ndim 
    indext1 = mod(indext1, ndim);
end 
indext2 = direction + 3;
if indext2 > ndim 
    indext2 = mod(indext2, ndim);
end 
rl = coords(indexl, :); % dipole direction
rt1 = coords(indext1, :);
rt2 = coords(indext2, :);

rlrlorr = diag(rl.^2 ./ rr);    % x^2/r^2, or y^2/r^2 or z^2/r^2
rt1rlorr = diag(rt1 .* rl ./ rr);
rt2rlorr = diag(rt2 .* rl ./ rr);

d3 = factor * (e_ikr * v1or3) ;
hl  = d3 .* ((d1 * rlrlorr) - d2); 
ht1 = d3 .* ( d1 * rt1rlorr);  % tranverse component
ht2 = d3 .* ( d1 * rt2rlorr);
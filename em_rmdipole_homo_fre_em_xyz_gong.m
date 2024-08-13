function [BR, BTH, BPHI] = em_rmdipole_homo_fre_em_xyz_gong(x, y, z, freqs, sigma, epsilon, mu)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: calculate analyitc magnetic fields of rotating permanent
%               magnet using Gong's formular
% reference: 
%   [1] Gong S., Liu Y., Liu Y. A Rotating-Magnet Based Mechanical Antenna (RMBMA) for ELF-ULF Wireless Communication[J]. Progress In Electromagnetics Research M, 2018, 72.
% test example

if (nargin < 5 || isempty(sigma))
    sigma = 0.0; %vacuum
end
if (nargin < 6 || isempty(epsilon))
    epsilon = 1.0;
end
if (nargin < 7 || isempty(mu))
    mu = 1.0;
end

mu0 = 4*pi*1e-7;
epsilon0 = 8.85e-12;

mu = mu * mu0;
epsilon = epsilon * epsilon0;

x = x(:)';
y = y(:)';
z = z(:)';

r2 = x .* x + y .* y + z .* z;
r = sqrt(r2);

omega = 2*pi*freqs;
kr = omega * sqrt(mu*epsilon/2) .* sqrt(sqrt(1+ (sigma./omega/epsilon).^2) + 1);
ki = omega * sqrt(mu*epsilon/2) .* sqrt(sqrt(1+ (sigma./omega/epsilon).^2) - 1);
% k2 = omega * omega * mu * epsilon - 1i * omega * mu * sigma;
% k = sqrt(k2);
k = kr + 1i*ki;
k2 = k*k;

m = length(freqs);
n = length(x);

BR = zeros(m,n);
BTH = zeros(m,n);
BPHI = zeros(m,n);

for i=1:n
    ri = r(i);
    zi = z(i);
    xi = x(i);
    yi = y(i);
    r2i = r2(i);
    ikr = 1i * k * ri;
    factor = exp(ikr)/4/pi./ri.^3;
    STH = sqrt(xi * xi + yi * yi) ./ ri;
    CTH = zi ./ ri;
    
    BR(:,i) = - factor .* (2*1i + k*ri) .* STH;
    BTH(:,i)  = factor .* (1i + 2 * k * ri - 1i * k2 * r2i) .* CTH;
    BPHI(:,i)  = factor .* ( -1 + (2*1i * k * ri + k2 * r2i) .* CTH .* CTH);
end
function [hx, hy, hz, h] = em_mdipole_z_halfspace_freq_em_xyz_z_up(sigma, x, y,freqs)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: electromagnetic fields of z-axial magnetic dipole on the surface of the earth for
%               cylinderical coordinates, z axis is up.
%               With respect fields when z axis is downward, x and y
%               component are the same, and the sign of z component is
%               changed.
%
% sigma  = 1/100;
% x = 100;
% y = 0;
% f = logspace(-1,5, 100);
% 
% [hx, hy, hz, hr, h] = em_mdipole_z_halfspace_freq_em_xyz(sigma, x, y, f);
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% loglog(f(real(hr)>0), abs(real(hr(real(hr)>0))), 'r', 'LineWidth', lw);
% hold on;
% loglog(f(real(hr)<0), abs(real(hr(real(hr)<0))), '--r', 'LineWidth', lw);
% loglog(f(imag(hr)>0), abs(imag(hr(imag(hr)>0))), 'b', 'LineWidth', lw);
% loglog(f(imag(hr)<0), abs(imag(hr(imag(hr)<0))), '--b', 'LineWidth', lw);
% axis([1e-1, 1e5, 1e-12, 1e-6]);
% legend('Real Positive',  'Imag postive', 'Imag negtive');
% xlabel('Frequecny (Hz)');
% ylabel('H_\rho(A/m)');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% loglog(f(real(hz)>0), abs(real(hz(real(hz)>0))), 'r', 'LineWidth', lw);
% hold on;
% loglog(f(real(hz)<0), abs(real(hz(real(hz)<0))), '--r', 'LineWidth', lw);
% loglog(f(imag(hz)>0), abs(imag(hz(imag(hz)>0))), 'b', 'LineWidth', lw);
% loglog(f(imag(hz)<0), abs(imag(hz(imag(hz)<0))), '--b', 'LineWidth', lw);
% legend('Real Positive', 'Real Negtive', 'Imag postive', 'Imag negtive');
% axis([1e-1, 1e5, 1e-12, 1e-6]);
% xlabel('Frequecny (Hz)');
% ylabel('H_z(A/m)');

mu0 = 4*pi*1e-7;
epsilon0 = 8.83e-12;

omega = 2*pi* freqs;
np = length(x);
nf = length(freqs);

r = sqrt(x.*x + y.*y);

hr = zeros(nf, np);
hz = zeros(nf, np);
hx = zeros(nf, np);
hy = zeros(nf, np);

k2 = omega .* omega * mu0 * epsilon0 - 1i*omega*mu0*sigma;
k = sqrt(k2);

for i = 1:np
    ri = r(i);
    cosxy = x(i)/ri;
    sinxy = y(i)./ri;
    ikr = 1i*k*ri;
    ikr2 = ikr /2 ;
    hz(:,i) = - 0.5 /pi ./k2/ri^5 .* (9-(9+9*1i*k*ri-4*k2*ri*ri-1i*k2.*k*ri^3).*exp(-ikr));
    hr(:,i) = - k2/4/pi/ri .* (besseli(1, ikr2) .* besselk(1, ikr2) - besseli(2, ikr2) .* besselk(2,ikr2));
    hx(:,i) = hr(:,i) * cosxy;
    hy(:, i) = hr(:,i) * sinxy;
end
h = sqrt(hx.*hx + hy.* hy + hz .* hz);
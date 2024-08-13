function [hx, hy, hz, h] = em_rmdipole_h_halfspace_fre_em_xyz_z_up(sigma, x, y, freqs)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: em filed on the surface of the earth of rotating magnetic
%               dipole around horizontial axis.
%               It corresponds to a horizontal magnetic dipole and a
%               vertical magnetic dipole.
% test example
% clc;
% clearvars;
% close all;
% sigma  = 1/100;
% x = 100;
% y = 100;
% f = logspace(-1,5, 100);
% 
% [hx, hy, hz, h] = em_rmdipole_h_halfspace_fre_em_xyz(sigma, x, y, f);
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hx),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hx),'b', 'Imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% % axis([1e-1, 1e5, 1e-12, 1e-6]);
% xlabel('Frequecny (Hz)');
% ylabel('H_x(A/m)');
% title('Horizontal dipole');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hy),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hy),'b', 'Imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% % axis([1e-1, 1e5, 1e-12, 1e-6]);
% xlabel('Frequecny (Hz)');
% ylabel('H_y(A/m)');
% title('Horizontal dipole');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hz),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hz),'b', 'Imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% % axis([1e-1, 1e5, 1e-12, 1e-6]);
% xlabel('Frequecny (Hz)');
% ylabel('H_z(A/m)');
% title('Horizontal dipole');

mu0 = 4*pi*1e-7;
epsilon0 = 8.83e-12;

omega = 2*pi* freqs;
np = length(x);
nf = length(freqs);

r = sqrt(x.*x + y.*y);

hr1 = zeros(nf, np);
hz1 = zeros(nf, np);
hx1 = zeros(nf, np);
hy1 = zeros(nf, np);


PHI = zeros(nf, np);
PHId = zeros(nf, np);
hz2 = zeros(nf, np);
hx2 = zeros(nf, np);
hy2 = zeros(nf, np);

k2 = omega .* omega * mu0 * epsilon0 - 1i*omega*mu0*sigma;
k = sqrt(k2);

for i = 1:np
    ri = r(i);
    yi = y(i);
    xi = x(i);
    cosxy = x(i)/ri;
    sinxy = y(i)./ri;
    ikr = 1i*k*ri;
    ikr2 = ikr /2 ;
    
    % vertical
    hz1(:,i) = -0.5 /pi ./k2/ri^5 .* (9-(9+9*1i*k*ri-4*k2*ri*ri-1i*k2.*k*ri^3).*exp(-ikr));
    hr1(:,i) = - k2/4/pi/ri .* (besseli(1, ikr2) .* besselk(1, ikr2) - besseli(2, ikr2) .* besselk(2,ikr2));
    hx1(:,i) = hr1(:,i) * cosxy;
    hy1(:, i) = hr1(:,i) * sinxy;
    
    PHI(:,i) = 2./k2/ri^4 .* (3+k2*ri^2 - (3 + 3*1i*k*ri - k2 * ri^2)) .* exp(-ikr);
    PHId(:,i) = 2./k2/ri^5 .* (-2*k2*ri^2 - 12 + (-1i * k2 .*k * ri^3 - 5 * k2 * ri^2 + 12 * ikr + 12) .* exp(-ikr));
    hx2(:,i) = 1/4/pi/ri^3 * ( xi * yi * PHI(:,i) - xi * yi *ri * PHId(:,i));
    hy2(:, i) = -1/4/pi/ri^3 * (xi * xi * PHI(:,i) + yi * yi * ri * PHId(:,i));  
    hz2(:,i) = -k2/4/pi*yi/ri^2 .* (besseli(1, ikr2) .* besselk(1, ikr2) - besseli(2, ikr2) .* besselk(2,ikr2));
end

hx = hx1 + exp(-1i*pi/2) * hx2;
hy = hy1 + exp(-1i*pi/2) * hy2;
hz = hz1 + exp(-1i*pi/2) * hz2;
h = sqrt(hx.*conj(hx) + hy.* conj(hy) + hz .* conj(hz));
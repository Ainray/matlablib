%% em_mdipole_z_halfspace_freq_em_xyz
% clc;
% clearvars;
% close all;
% sigma  = 1/100;
% x = 100;
% y = 0;
% f = logspace(-1,5, 500);
% 
% [hx, hy, hz, h] = em_mdipole_z_halfspace_freq_em_xyz(sigma, x, y, f);
% hr = hx;
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hr),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hr),'b', 'Imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% hold off;
% % axis([1e-1, 1e5, 1e-12, 1e-6]);
% xlabel('Frequecny (Hz)');
% ylabel('H_\rho(A/m)');
% title('Vertical dipole');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hz),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hz),'b', 'Imag', 'LineWidth', lw);
% hold off;
% legend([pl1, pl2], [dn1 dn2]);
% % axis([1e-1, 1e5, 1e-12, 1e-6]);
% xlabel('Frequecny (Hz)');
% ylabel('H_z(A/m)');
% title('Vertical dipole');

%% em_mdipole_h_halfspace_freq_em_xyz
% clc;
% clearvars;
% close all;
% sigma  = 1/100;
% x = 100;
% y = 0;
% f = logspace(-1,5, 100);
% 
% [hx, hy, hz, h] = em_mdipole_h_halfspace_freq_em_xyz(sigma, x, y, f);
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

%% em_rmdipole_h_halfspace_fre_em_xyz
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

%% coordinates
% clc;
% clearvars;
% close all;
% sigma  = 1/100;
% x = 0;
% y = 100;
% f = logspace(-1,5, 100);
% 
% [hx, hy, hz, h] = em_mdipole_h_halfspace_freq_em_xyz_z_up(sigma, x, y, f);
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hx),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hx),'b', 'Imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% xlabel('Frequecny (Hz)');
% ylabel('H_x(A/m)');
% title('Horizontal dipole upward');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hy),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hy),'b', 'Imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% xlabel('Frequecny (Hz)');
% ylabel('H_y(A/m)');
% title('Horizontal dipole upward');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hz),'r', 'Real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hz),'b', 'Imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% xlabel('Frequecny (Hz)');
% ylabel('H_z(A/m)');
% title('Horizontal dipole upward');
% 
% % clc;
% % clearvars;
% % close all;
% sigma  = 1/100;
% x = 100;
% y = 0;
% f = logspace(-1,5, 100);
% 
% [hx, hy, hz, h] = em_mdipole_h_halfspace_freq_em_xyz(sigma, x, y, f);
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

%% em_rmdipole_h_halfspace_fre_em_xyz_z_up
% clc;
% clearvars;
% close all;
% sigma  = 1/100;
% x = 100;
% y = 0;
% f = logspace(-1,5, 100);
% 
% [hx, hy, hz, h] = em_rmdipole_h_halfspace_fre_em_xyz_z_up(sigma, x, y, f);
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

%% comparision halfspace vs homogenous
% clc;
% clearvars;
% close all;
% sigma  = 1/100;
% x = 100;
% y = 0;
% f = logspace(-1,5, 100);
% 
% [hx, hy, hz, h] = em_rmdipole_h_halfspace_fre_em_xyz_z_up(sigma, x, y, f);
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

%% comparison of vertical dipoles， homogenous .vs. halfspace
% clc;
% clearvars;
% close all;
% 
% x = 0;
% y = 100;
% coords = [0, 100, 0];
% f = logspace(-2, 5, 100);
% sigma = 0.01;
% 
% [hz, hx, hy] = em_mdipole_homo_fre_em_xyz(coords, f, 2, sigma);
% [hx2, hy2, hz2] = em_mdipole_z_halfspace_freq_em_xyz_z_up(sigma, x, y, f);
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hy),'r', 'homo - real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, real(hy2),'b', 'half - real', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_y (A/m)');
% 
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, imag(hy),'r', 'homo - imag', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hy2),'b', 'half - imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_y (A/m)');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hz),'r', 'homo - real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, real(hz2),'b', 'half - real', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_z (A/m)');
% 
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, imag(hz),'r', 'homo - imag', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hz2),'b', 'half - imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_z (A/m)');


%% comparison of horizontal dipoles， homogenous .vs. halfspace
% clc;
% clearvars;
% close all;
% 
% x = 0;
% y = 100;
% coords = [0, 100, 0];
% f = logspace(-2, 5, 100);
% sigma = 0.01;
% 
% [hy, hz, hx] = em_mdipole_homo_fre_em_xyz(coords, f, 1, sigma);
% [hx2, hy2, hz2] = em_mdipole_h_halfspace_freq_em_xyz_z_up(sigma, x, y, f);
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hy),'r', 'homo - real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, real(hy2),'b', 'half - real', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_y (A/m)');
% 
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, imag(hy),'r', 'homo - imag', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hy2),'b', 'half - imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_y (A/m)');
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hz),'r', 'homo - real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, real(hz2),'b', 'half - real', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_z (A/m)');
% 
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, imag(hz),'r', 'homo - imag', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hz2),'b', 'half - imag', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
% xlabel ('frequency (Hz)');
% ylabel ('H_z (A/m)');

%% homo check, refs to Gong 2018

clc;
clearvars;
close all;

% freqs=100;
% sig = 0.01;
% x = (100:20:1100)';
% np = length(x);
% y = (100:20:1100)';
% z = zeros(np, 1);
% coords = [x(:)'; y(:)'; z(:)'];
% 
% [hr2, ht2, hphi2] = em_rmdipole_homo_fre_em_xyz_gong(x,y,z, freqs,sig);
% [hr, ht, hphi] = em_rmdipole_homo_fre_em_xyz_direct(coords, freqs, sig);
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,3,24,1.5,10);
% 
% subplot(3,1,1);
% plot(x, abs(hr), 'r', 'LineWidth', lw);
% hold on;
% plot(x, abs(hr2), 'b.', 'LineWidth', lw);
% legend('Gong1','Gong2');
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


% 
% sigmas = [0, 0.015, 3.8];
% epsilons = [1, 10, 81];
% freqs = [30, 300];
% N = 100;
% bnorm = zeros(N, 6);
% x = linspace(100, 1100, 100);
% y = zeros(size(x));
% z = zeros(size(x));
% k = 0;
% 
% coords = [x; y; z];
% 
% [TH,PHI,R]=cart2sph(x, y, z);
% 
% mu0 = 4 * pi * 1e-7;
% m = 1.2 * 0.0001;
% 
% for i = 1:length(freqs)
%     for j=1:length(sigmas)
%         k = k + 1;
%         sigma = sigmas(j);
%         epsilon = epsilons(j);
%         f = freqs(i);
% %         [hy, hz, hx] = em_rmdipole_homo_fre_em_xyz_gong(x, y, z, f, sigma,epsilon);
% %         [hy, hz, hx] = rmbma_mdipole_analytic(coords, f, 2, sigma,epsilon);
%         [hy, hz, hx] = em_rmdipole_homo_fre_em_xyz(coords, f, 2, sigma,epsilon);
%         
%         B = m * sqrt(hx.* hx + hy.*hy + hz .* hz);
%         bnorm(:, k) = abs(B)*1e12;
%     end
% end
% lw = 2;
% styles = {'r', 'g', 'b', 'r--o', 'g--o', 'b--o'};
% k = 1;
% semilogy(x, bnorm(:,k), styles{k}, 'LineWidth', lw);
% hold on;
% k = 2;
% semilogy(x, bnorm(:,k), styles{k}, 'LineWidth', lw);
% k = 3;
% semilogy(x, bnorm(:,k), styles{k}, 'LineWidth', lw);
% k = 4;
% semilogy(x(1:8:end), bnorm(1:8:end,k), styles{k}, 'LineWidth', lw);
% k = 5;
% semilogy(x(1:8:end), bnorm((1:8:end),k), styles{k}, 'LineWidth', lw);
% k = 6;
% semilogy(x(1:8:end), bnorm((1:8:end),k), styles{k}, 'LineWidth', lw);
% set(gca,'YScale','log', 'xlim', [100,1100], 'yLim', [5e-4, 2e1]);
% legend('30Hz 0S/m', '30Hz 0.015S/m', '30Hz 3.8S/m', '300Hz 0S/m', '300Hz 0.015S/m', '300Hz 3.8S/m');
% xlabel('Distance'); ylabel('|B|');
%% comparison of rotating dipoles， homogenous .vs. halfspace
clc;
clearvars;
close all;

x = 0;
y = 100;
coords = [0, 100, 0];
f = logspace(-2, 5, 100);
sigma = 0.01;

[hy, hz, hx] = em_rmdipole_homo_fre_em_xyz(coords, f, 0, sigma);
[hx2, hy2, hz2] = em_mdipole_h_halfspace_freq_em_xyz_z_up(sigma, x, y, f);

[lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
[pl1, dn1] = p2d_logplot(f, real(hy),'r', 'homo - real', 'LineWidth', lw);
[pl2, dn2] = p2d_logplot(f, real(hy2),'b', 'half - real', 'LineWidth', lw);
legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
xlabel ('frequency (Hz)');
ylabel ('H_y (A/m)');


[lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
[pl1, dn1] = p2d_logplot(f, imag(hy),'r', 'homo - imag', 'LineWidth', lw);
[pl2, dn2] = p2d_logplot(f, imag(hy2),'b', 'half - imag', 'LineWidth', lw);
legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
xlabel ('frequency (Hz)');
ylabel ('H_y (A/m)');

[lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
[pl1, dn1] = p2d_logplot(f, real(hz),'r', 'homo - real', 'LineWidth', lw);
[pl2, dn2] = p2d_logplot(f, real(hz2),'b', 'half - real', 'LineWidth', lw);
legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
xlabel ('frequency (Hz)');
ylabel ('H_z (A/m)');


[lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,6,24,1.5,10);
[pl1, dn1] = p2d_logplot(f, imag(hz),'r', 'homo - imag', 'LineWidth', lw);
[pl2, dn2] = p2d_logplot(f, imag(hz2),'b', 'half - imag', 'LineWidth', lw);
legend([pl1, pl2], [dn1 dn2], 'Location', 'southeast');
xlabel ('frequency (Hz)');
ylabel ('H_z (A/m)');

%% rotating magnet
% sigma  = 1/100;
% x = 100;
% y = 0;
% z = 0;
% f = logspace(-1,5, 100);
% x = 100;
% % x = 100:20:1100;
% % np = length(x);
% % y = zeros(np, 1);
% % z = zeros(np, 1);
% coords = [x(:)'; y(:)'; z(:)'];
% 
% [hx, hy, hz] = rmbma_mdipole_superposition(coords, f, 1);
% [hr2, ht2, hphi2] = vec_car2sph([hx(:) hy(:) hz(:)]', coords);
% [hr, ht, hphi] = em_rmdipole_homo_fre_h_sphere(coords, f);
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,3,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, real(hr),'r', 'Direct - real', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, real(hr2),'b', 'Superpositon - real', 'LineWidth', lw);
% legend([pl1, pl2], [dn1 dn2]);
% xlabel('Frequecny (Hz)');
% ylabel('H_r(A/m)');
% title('Homogenous RM');
% 
% 
% [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(6,3,24,1.5,10);
% [pl1, dn1] = p2d_logplot(f, imag(hr),'r', 'Direct - imag', 'LineWidth', lw);
% [pl2, dn2] = p2d_logplot(f, imag(hr2),'b', 'Superpositon - imag', 'LineWidth', lw);
% legend([pl1, pl2 ], [dn1 dn2]);
% xlabel('Frequecny (Hz)');
% ylabel('H_r(A/m)');
% title('Homogenous RM');
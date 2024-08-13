function [hin1, hin2, hout] = rmbma_mdipole_superposition(coords, freqs, direction, sigma, epsilon, mu, m)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: calculate analyitc magnetic fields of rotating permanent magnet
% reference: 
%   [1] Gong S., Liu Y., Liu Y. A Rotating-Magnet Based Mechanical Antenna (RMBMA) for ELF-ULF Wireless Communication[J]. Progress In Electromagnetics Research M, 2018, 72.
%   [2] 施伟, 周强, 刘斌. 基于旋转永磁体的超低频机械天线电磁特性分析[J]. 物理学报, 2019(18): 314–324.
%       [hin1, hin2], in-plane components, e.g. [hx, hy], or [hy, hz] or [hz, hx]
%       hout, out-plane compoent, e.g. hz, hx, or hy
%       direction, direction of rotating plane
% test example
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

if (direction ~= 0 && direction ~= 1 && direction ~= 2)
    error('direction of dipole must be 0, 1 or 2.');
end

if(direction == 0)
    direction1 = 1;
    direction2 = 2;
elseif direction == 1
    direction1 = 2;
    direction2 = 0;  
else
    direction1 = 0;
    direction2 = 1;       
end

[hl1, ht11, ht12] = em_mdipole_homo_fre_h_xyz(coords, freqs, direction1, sigma, epsilon, mu);
[hl2, ht21, ht22] = em_mdipole_homo_fre_h_xyz(coords, freqs, direction2, sigma, epsilon, mu);

ejpi = exp(-1i*pi/2);
hin1 = hl1 + ejpi*ht22;
hin2 = ht11 + ejpi*hl2;
hout = ht12 + ejpi*ht21;
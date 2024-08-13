function [hin1, hin2, hout] = em_rmdipole_homo_fre_em_xyz(coords, freqs, direction, sigma, epsilon, mu, m)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: calculate analyitc magnetic fields of rotating permanent magnet
% reference: 
%   [1] Nabighian, M. N. Electromagnetic Methods in Applied Geophysics, 1, Theory. Society of Exploration Geophysicists, Tulsa, Oklahoma.
%   [2] 施伟, 周强, 刘斌. 基于旋转永磁体的超低频机械天线电磁特性分析[J]. 物理学报, 2019(18): 314–324.
%       [hin1, hin2], in-plane components, e.g. [hx, hy], or [hy, hz] or [hz, hx]
%       hout, out-plane compoent, e.g. hz, hx, or hy
%       direction, direction of rotating plane, default is counterclockwise along z-axis
%
% test example
%     refer to em_rmdipole_homo_fre_em_sphere.m

if (nargin < 3 || isempty(direction))
    direction = 2; % 0: x, 1: y, 2: z
end

if (nargin < 5 || isempty(sigma))
    sigma = 0.0; %vacuum
end
if (nargin < 6 || isempty(epsilon))
    epsilon = 1.0;
end
if (nargin < 7 || isempty(mu))
    mu = 1.0;
end
if (nargin < 8 || isempty(m))
    m = 1.0;
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

[hl1, ht11, ht12] = em_mdipole_homo_fre_em_xyz(coords, freqs, direction1, sigma, epsilon, mu);
[hl2, ht21, ht22] = em_mdipole_homo_fre_em_xyz(coords, freqs, direction2, sigma, epsilon, mu);

ejpi = exp(-1i*pi/2);
hin1 = hl1 + ejpi*ht22;
hin2 = ht11 + ejpi*hl2;
hout = ht12 + ejpi*ht21;
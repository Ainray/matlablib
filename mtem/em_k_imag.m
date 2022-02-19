function [b]=em_k_imag(sigma, epsilon, mu, omega)
% author: Ainray
% email: wwzhang0421@163.com
% date: 20211022
% modified: 20211022, calculate imag part of complex wavenumber k

% input:
%      sigma, conductivity
%    epsilon, electrical permittivity
%         mu, Magnetic permeability
%      omega, angular frequency
%
%  output:
%      b, imag part of k

omega = omega(:);
alpha = sigma ./ (epsilon * omega);

b = sqrt(mu*epsilon/2)  * omega .* sqrt(sqrt(1+alpha.^2) - 1);
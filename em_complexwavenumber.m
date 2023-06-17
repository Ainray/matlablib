function k = em_complexwavenumber(freqs, sigma, epsilon, mu)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: calculate complex wave number

if (nargin < 2 || isempty(sigma))
    sigma = 0.0; %vacuum
end
if (nargin < 3 || isempty(epsilon))
    epsilon = 1.0;
end
if (nargin < 4 || isempty(mu))
    mu = 1.0;
end

epsilon0 = 8.854187817e-12;
mu0 = 4*pi*1e-7;

freqs = freqs(:);
epsilon = epsilon0 * epsilon;
mu  = mu0 * mu;
omega = 2*pi*freqs;
kk = omega .* omega * mu * epsilon - 1i * omega * mu * sigma;
k = sqrt(kk);
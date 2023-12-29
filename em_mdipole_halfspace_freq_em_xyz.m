function h = em_mdipole_halfspace_freq_em_xyz(sigma, x, y, z, freqs)
% author: Ainray
% date: 20230526
% email: wwzhang0421@163.com
% introduction: electromagnetic fields of 

mu0 = 4*pi*1e-7;
epsilon0 = 8.83e-12;

omega = 2*pi* freqs;
np = length(x);
nf = length(freqs);

r = sqrt(x.*x + y.*y);
cosxy = x./r;
sinxy = y./r;

hr = zeros(nf, np);
hz = zeros(nf, np);

k2 = omega .* omega * mu0 * epsilon0 - 1i*omega*mu0*sigma;
k = sqrt(k2);
for i = 1:np
    ri = r(i);
    hz(:,i) = 0.5 /pi ./k2/ri^5*(9-(9+9*1i*k-4*k2*ri*ri-1i*k2.*k*ri^3)*exp(-1i*k*ri));
    
end





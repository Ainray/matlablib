function [sigma, epsilon] = cole_cole(einf, edelta, tau, alpha, sigmas, w, mti)
% function [sigma, epsilon] = cole_cole(einf,edelta, tau, alpha, sigmas,w)
% author: ainray
% date: 20200907
% email: wwzhang0421@163.com
% modified: 20200907, create, cole-cole model
%           20230814, support vector input, one columen per frequency
% introducton: calculating dielectric properties based on cole-cole model
%              Of course, Debye model is also available when specifing alpha
%              being zero.
% input:
%           mti, material type index, 0 is invalid 
% output:
%         sigma, one column per frequency
% test example:
%
[mt, nt, lt] = size(mti);

mti = mti(:);
mti2 = mti;
mti2(mti==0) = 1;

e0 = 8.854187817e-12;
%es = einf + edelta;
m = length(mti);
n = length(w);
se = zeros(m, n);
for j=1:n
    sej = einf(mti2) + sigmas(mti2)/(sqrt(-1)*w(j)*e0);
    sej = sej + edelta(mti2)./(1+(sqrt(-1)*w(j)*tau(mti2)).^(1-alpha(mti2)));   
    sej(mti==0) = 0;
    se(:,j)=sej;
end
sigma = -e0*w.*imag(se);
epsilon = real(se);
sigma = reshape(sigma, mt, nt, lt);
epsilon = reshape(epsilon, mt, nt, lt);
%% old version
% e0 = 8.854187817e-12;
% %es = einf + edelta;
% se = einf + sigmas/(sqrt(-1)*w*e0);
% se = se(:);
% for i=1:length(alpha)
%     se = se + edelta./(1+(sqrt(-1)*w*tau).^(1-alpha(i)));
% end
% % sigma = -e0 * w .* imag(se);
% sigma = -e0*w.*imag(se);
% epsilon = real(se);
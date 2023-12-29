function [sigma, epsilon] = cole_cole_breast(w, pval, mt)
% function [sigma, epsilon] = cole_cole_breast(w, pval, mt)
% author: ainray
% date: 20200907
% email: wwzhang0421@163.com
% modified: 20200907, create, cole-cole model of breast
%           20230804, support vector input
% introducton: calculating dielectric properties based on cole-cole breast  model 
%              Of course, Debye model is also available only to specify alpha
%              being zero.
% [1] E. Zastrow, S. K. Davis, M. Lazebnik, et al. Database of 3D Grid-Based Numerical Breast Phantoms for Use in Computational Electromagnetics Simulations[DS](2017). 

einf = [2.293 2.908 3.140 4.031 9.941 7.821 6.151 1.000]';
edelta = [0.141 1.200 1.708 3.654 26.60 41.48 48.26 66.31]';
tau = [16.40 16.88 14.65 14.12 10.90 10.66 10.26 7.585]' * 1e-12; %ps
alpha = [0.251 0.069 0.061 0.055 0.003 0.047 0.049 0.063]';
sigmas = [0.002 0.020 0.036 0.083 0.462 0.713 0.809 1.370]';
mtvmap = [3.3, 3.2,3.1, 2, 1.3,1.2,1.1];
mti = value2index(mt, mtvmap);
[sigma, epsilon] = cole_cole(einf, edelta, tau, alpha, sigmas, w, mti);
mti2 = mti + 1;
mti2(mti==0) = 0;
[sigma2, epsilon2] = cole_cole(einf, edelta, tau, alpha, sigmas, w, mti2);
sigma = pval.*sigma2 + (1-pval).*sigma;
epsilon = pval.*epsilon2 + (1-pval).* epsilon;
%% old version
% % material type values
% mtvmap = [1.1, 1.2, 1.3, 2, 3.1, 3.2, 3.3];
% 
% if(mt == 1.1)
%     i = 7;
% elseif(mt == 1.2)
%     i = 6;
% elseif(mt == 1.3)
%     i = 5;
% elseif(mt==2)
%     i = 4;   
% elseif(mt == 3.1)
%     i=3;
% elseif(mt==3.2)
%     i=2;
% elseif(mt==3.3)
%     i=1;
% else
%     i=-1;
% end
% 
% if(i<1)
%     sigma =0;
%     epsilon =0;
% else
%     [sigma1, epsilon1]=cole_cole(einf(i),edelta(i), tau(i), ...
%          alpha(i), sigmas(i),w);
%      i = i+1;
%     [sigma2, epsilon2]=cole_cole(einf(i),edelta(i), tau(i), ...
%          alpha(i), sigmas(i),w);
%      sigma = pval*sigma2 + (1-pval)*sigma1;
%      epsilon = pval *epsilon2 + (1-pval)* epsilon1;
% end

%function [b,pert] = addnoise(b_exact, NSR )
% author: Ainray
% time  : 2015/7/30
% bug report: wwzhang0421@163.com
% information: generate the noise for synthetic data.
% input:
%        b_exact, exact synthetic data
%            NSR, noise-signal-ratio(%), with relationship to SNR 
%                 [SNR]dB=-20log10[NSR/100],
%                 if NSR=1, i.e.(1%), then [SNR]dB=40dB
%                 NSR is increased by a factor of 10, the SNR is decreased with 20dB
%  output:
%              b, noised data
%           pert, the added noise
function [b,pert] = addnoise(b_exact, NSR)
%ADDNOISE Summary of this function goes here
%   Detailed explanation goes here
    pert_sd=NSR/100*rms(b_exact,1);  % noise power, rms, if the power of 
                                     % the signal is assumed to be 1, which is 
                                     % usded by awgn without 'measured' parameter.
    pert=pert_sd*randn(size(b_exact)); % noise
    b=b_exact+pert;  % contaminated reponse
end


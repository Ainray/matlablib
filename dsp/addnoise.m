%function [b,pert] = addnoise(b_exact, NSR )
% author: Ainray
% time  : 2015/7/30
% bug report: wwzhang0421@163.com
% information: generate the noise for synthetic data.
% input:
%        b_exact, exact synthetic data
%            NSR, signal-noise-ratio(%)
%  output:
%              b, noised data
%           pert, the added noise
function [b,pert] = addnoise(b_exact, NSR )
%ADDNOISE Summary of this function goes here
%   Detailed explanation goes here
    n=length(b_exact);  % length of data
    pert_sd=NSR/100*norm(b_exact-mean(b_exact),2)/sqrt(n);  % noise power, i.e. standard derivation
    pert=pert_sd*randn(size(b_exact)); % noise
    b=b_exact+pert;  % contaminated reponse
end


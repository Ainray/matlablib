% function y=dft_shift(x,n)
% author: Ainray
% date: v1,20160228
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: circurlarly shift the DFT input, just calling the inner funciton
%             : circshift.
% input:
%         x, the DFT input signal
%         n, the shift step, if positive ,backward; if negtive, forword.
%          , that is, SHIFT(x,L)=x(n-L)
% output:
%         y, the DFT output signal
function y=dft_shift(x,n)
y=circshift(v2col(x),-n);
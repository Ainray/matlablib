% author: Ainray
% date: v1,20160228
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: repeat the DFT input. 
% input:
%         x, the DFT input signal
%         L, the number of times of repeating the DFT input.
% output:
%         y, the DFT output signal
function y=dft_repeat(x,L)
y=repmat(v2col(x),L,1);
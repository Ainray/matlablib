% author: Ainray
% date: v1,20160228
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: upsampling the DFT input.
% input:
%         x, the DFT input signal
%         L, the stretch step, so inserting L-1 zeros between two samples of input
% output:
%         y, the DFT output signal
function y=dft_stretch(x,L)
N=length(x);
y=zeros(1,N*L); % unset all element of input
y((0:N-1)*L+1)=x; % assign every L elements of output with the input

% author: Ainray
% date: v1,20160228
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: padding  the DFT input with zeros.
% input:
%         x, the DFT input signal
%         L, the number of padding zeros
% output:
%         y, the DFT output signal
function y=dft_zeropad(x,L)
N=length(x);
y=zeros(1,L+N); % unset all element of input

% assign elements at ends of output with the input
y([(0:floor(N/2)),L+floor(N/2)+1:(L+N-1)]+1)=x; 

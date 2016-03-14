% function y=dft_select(x,L,l)
% author: Ainray
% date: v1,20160228
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: downsampling the DFT input, i.e., SELECT(x,L):=x(n/L)=x(n/L), if
%             : n/L is an integer; x(n/L)=0, else. 
% input:
%         x, the DFT input signal
%         L, the downsamling step
%         l, the offset within one segment, 0, 1, ..., L-1, the default value is 0.
% output:
%         y, the DFT output signal
function y=dft_select(x,L,l)
if nargin<3
    l=0;
end
N=length(x);
while N/L~=floor(N/L)
    L=input('The downsamling step must be a disor of the lengh of the input signal: \n');
end
y=x((1:L:N)+l); % selecting one for every L elements of the input
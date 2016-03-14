% author: Ainray
% date: v1,20160228
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: aliasing the DFT input. 
% input:
%         x, the DFT input signal
%         L, the number of blocks before aliasing.
% output:
%         y, the DFT output signal
function y=dft_alias(x,L)
N=length(x);
while N/L~=floor(N/L)
    L=input('The number of blocks must be a disor of the lengh of the input signal: \n');
end
y=reshape(x,N/L,L);
y=sum(y,2); % selecting one for every L elements of the input
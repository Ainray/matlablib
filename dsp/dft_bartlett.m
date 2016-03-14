% function [w]=dft_bartlett(N,mode)
% author: Ainray
% date: v1,20160308
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: calculating the bartlett window
%               w=1-|n|/(N-1)/2,n=-(N-1)/2:(N-1)/2
%               Examples:
%                 w=dft_bartlett(10), return 11 samples of sysmmtric window
%                 w=dft_bartlett(10,'one-side'), return 10 samples window,
%               with the left zero but without right
% input:
%         N, the number of samples
%      mode, 'symmetric', the window have odd samples.if N is even, padding one sample.
%                         the window have sysmmetric zeros at both left and right ends.
%            'one-side',  return N samples, only the left zero is guaranted.
% output:
%         w, the window 
function [w]=dft_bartlett(N,mode)
if nargin<2
    mode='symmetric';
end
while strcmp(mode,'symmetric')==0 && strcmp(mode,'one-side')==0
    mode=input('mode must be either ''symmetric'' or ''one-side'': ');
end

if strcmp(mode,'symmetric')
    if mod(N,2)==0  
        N=N+1; % padding one sample
    end
    n=[-(N-1)/2:(N-1)/2]';
    w=1-abs(n)/floor(N/2);
else
    n=-floor(N/2):floor((N+1)/2)-1;
    w=1-abs(n)/floor(N/2);
end

% function [w]=dft_hanning(N,mode)
% author: Ainray
% date: v1,20160308
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: calculating the hanning(or called raised cosine) window
%               w=1/2+1/2cos(2*pi/N*[-N/2:N/2]), for symmetric mode
%               Examples:
%                 w=dft_hanning(10), return 11 samples of sysmmtric window
%                 w=dft_hanning(10,'one-side'), return 10 samples window,
%               with the left zero but without right
% input:
%         N, the number of samples
%      mode, 'symmetric', the window have odd samples.if N is even, padding one sample.
%                         the window have sysmmetric zeros at both left and right ends.
%            'one-side',  return N samples, only the left zero is guaranted.
% output:
%         w, the window 
function [w]=winhanning(N,mode)
if nargin<2
    mode='symmetric';
end
while strcmp(mode,'symmetric')==0 && strcmp(mode,'one-side')==0
    mode=input('mode must be either ''symmetric'' or ''one-side''');
end
a=1/2;
b=1/4;
if strcmp(mode,'symmetric')
    if mod(N,2)==0  
        N=N+1; % padding one sample
    end
    n=[-(N-1)/2:(N-1)/2]';
    w=a+2*b*cos(2*pi/(N-1)*n);
else
    n=[-floor(N/2):floor((N+1)/2)-1];
    w=a+2*b*cos(pi/floor(N/2)*n);
end
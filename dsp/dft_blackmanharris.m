% function [w]=dft_blackmanharris(N,mode)
% author: Ainray
% date: v1,20160308
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: calculating the blackmanharris window
%               w=0.42+0.5*cos(a1*cos(2*pi/N*n)+0.08*cos(4*pi/N*n),n=-(N-1)/2:(N-1)/2
%               Examples:
%                 w=dft_blackmanharris(10), return 11 samples of sysmmtric window
%                 w=dft_blackmanharris(10,'one-side'), return 10 samples window,
%               with the left zero but without right
% input:
%         N, the number of samples
%      mode, 'symmetric', the window have odd samples.if N is even, padding one sample.
%                         the window have sysmmetric zeros at both left and right ends.
%            'one-side',  return N samples, only the left zero is guaranted.
% output:
%         w, the window 
function [w]=dft_blackmanharris(N,mode)
if nargin<2
    mode='symmetric';
end
while strcmp(mode,'symmetric')==0 && strcmp(mode,'one-side')==0
    mode=input('mode must be either ''symmetric'' or ''one-side'': ');
end
L=3; % blackmanharris family window factor
a=[0.4243801,0.4973406,0.0782793]; %blackmanharris harris window
if strcmp(mode,'symmetric')
    if mod(N,2)==0  
        N=N+1; % padding one sample
    end
    n=[-(N-1)/2:(N-1)/2]';
    ws=zeros(L,N);
    for l=0:L-1
        ws(l+1,:)=cos(l*2*pi*n/(N-1));
    end
    w=a*ws;
    w=v2col(w);
else
    n=-floor(N/2):floor((N+1)/2)-1;
    w=a(0)+a(1)*cos(2*pi/(N-1)*n)+a(2)*cos(4*pi/(N-1)*n);
end

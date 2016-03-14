% function r=fcorr(x, y)
% author: Ainray
% date:20160312
% bug-report:wwzhang0421@163.com
% information: fast linear cross correlation or auto correlation(if x==y)
%	input:
%      x = input vector
%      y = input vector
% 
%  output:
%      r = 2*N-1 points of correlation spectrum, without normalization,
%          r(m)=sum(x(n+m)y*(n)), m=0:(N-1), 
function r=fcorr(x, y)
if nargin<2
    y=x;
end
m=equalen(x,y); 
L=size(m,1);

N=pow2(nextpow2(2*L-1));    % Find smallest power of 2 that is > 2*L-1
%Ly2 always is greater than Ly=length(x)+length(Y)-1, no aliasing occurs

X=fft(m(:,1), N);              % Fast Fourier transform
Y=fft(m(:,2), N);	           % Fast Fourier transform

% the positively lagged items
RP=X.*conj(Y);        	       % 
rp=real(ifft(RP, N));          % Inverse fast Fourier transform
r(L:2*L-1)=rp(1:L);            % Take just the first L elements

% the negtively lagged items
RN=Y.*conj(X);
rn=real(ifft(RN,N));
r(1:L-1)=fliplr(v2row(rn(2:L)));
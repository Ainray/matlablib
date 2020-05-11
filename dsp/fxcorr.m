function [xc,indx]=fxcorr(x,y,type)
% [xc,indx]=fxcorr(x,y)
% Uses fft to calculate the linear cross correlation of two 
% signal vectors, based on fft.
% 
% y is assumed to be shitfed, so xc(0) is located at length(y),
% and the length of xc is length(x)+length(y)-1
% date:20170525
% author: Ainray
% email:wwzhang0421@163.com
% modified:
%       20200224, add input input 'type'
% type:
%       1. basic
%       2. normalized in frequency
% 
if nargin<2
    y=x;
end

if nargin<3
    type = 1;
end

Ly=length(x)+length(y)-1;  %
Ly2=pow2(nextpow2(Ly));    % Find smallest power of 2 that is > Ly

fre = (0:Ly2-1)'/Ly2;

%Ly2 always is greater than Ly=length(x)+length(h)-1, no aliasing occurs

X=fft(x, Ly2);              % Fast Fourier transform
Y=fft(y, Ly2);	            % Fast Fourier transform
switch type
    case 1
        XC = X.*conj(Y);
        xc=real(ifft(XC,Ly2)); 
    case 2
        XC = X.*Y.*conj(Y.*X)/((X'*conj(X))*(Y'*conj(Y)));
        xc=real(ifft(XC,Ly2));      
end

% shift
% xc1=xc(1:max(length(x),length(y)));
% xc2=xc(Ly2-min(length(x),length(y))+2:Ly2);
% from length(x)+1 to length(x)+Ly2-Ly are zeros from fft zero-padding.
xc1=xc(1:length(x));     % the positively lagged items
% xc2=xc(length(x)+Ly2-Ly+1:length(x)+Ly2-Ly+length(y)-1); 
xc2=xc(Ly2-length(y)+2:Ly2); % the negtively lagged items
% xc=[zeros(abs(length(y)-length(x)),1);v2col(xc2);v2col(xc1)];  
% no zeros
xc=[v2col(xc2);v2col(xc1)];  
indx=1-length(y):length(x)-1;

% % old version: we do not need calculate two times of FFT
% function r=fcorr(x, y)
% % function r=fcorr(x, y)
% % author: Ainray
% % date:20160312
% % bug-report:wwzhang0421@163.com
% % information: fast linear cross correlation or auto correlation(if x==y)
% %	input:
% %      x = input vector
% %      y = input vector
% % 
% %  output:
% %      r = 2*N-1 points of correlation spectrum, without normalization,
% %          r(m)=sum(x(n+m)y*(n)), m=0:(N-1), 
% 
% if nargin<2
%     y=x;
% end
% m=equalen({x,y}); 
% L=size(m,1);
% 
% N=pow2(nextpow2(2*L-1));    % Find smallest power of 2 that is > 2*L-1
% %Ly2 always is greater than Ly=length(x)+length(Y)-1, no aliasing occurs
% 
% X=fft(m(:,1), N);              % Fast Fourier transform
% Y=fft(m(:,2), N);	           % Fast Fourier transform
% 
% % the positively lagged items
% RP=X.*conj(Y);        	       % 
% rp=real(ifft(RP, N));          % Inverse fast Fourier transform
% r(L:2*L-1)=rp(1:L);            % Take just the first L elements
% 
% % the negtively lagged items
% RN=Y.*conj(X);
% rn=real(ifft(RN,N));
% r(1:L-1)=fliplr(v2row(rn(2:L)));
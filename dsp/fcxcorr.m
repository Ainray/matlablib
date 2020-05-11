function [xc,indx]= fcxcorr(x,y)
% funciton xc= fcxcorr(x,y,nozeropad)
% date: 20170525
% author: Ainray
% email:wwzhang0421@163.com
% introduction: N

% base on  Travis Wiens 2009, but he assumed that vectors must be equally sized.
%Uses fft to calculate the circular cross correlation of two periodic
%signal vectors.This is equivalent to xc(k)=sum(x.*circshift(y,k)), but
%much faster, especially for large vectors. There is no input checking; 
%vectors must be equally sized.
%The result is not normalized.  You can get the normalized result using:
% xc_n=fcxcorr(x,y)/(norm(x)*norm(y));

%copyright Travis Wiens 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% y is shifted right circularly
% if length(x)<length(h)
%     error('Length of x must be larger than h');
% end
if nargin<2    % added by Ainray, 20170524
    y=x;
end
Nx=length(x);
Ny=length(y);
if Nx<Ny
    m=equalen({x,y});
    x=m(:,1);y=m(:,2);
    xc=ifft(fft(x).*conj(fft(y)))/size(m,1);  % y circularly shifted to the right
    indx=0:length(y)-1;
else
    L=ceil(Nx/Ny);
    yy=repmat(v2col(y),L,1);
    m=equalen({x,yy});
    x=m(:,1);y=m(:,2);
    xc=ifft(fft(x).*conj(fft(y)))/size(m,1);
    xc=xc(1:Ny);
    indx=0:length(x)-1;
end

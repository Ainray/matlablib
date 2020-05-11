function [y]=fconv(x,h,N)
%FCONV Fast Convolution
%   [y] = FCONV(x, h) convolves x and h, and normalizes the output  
%         to +-1.
%
%      x = input vector
%      h = input vector
%      N = just truncate the output, add by Ainray, 20160319
%      See also CONV
%
%   NOTES:
%
%   1) I have a short article explaining what a convolution is.  It
%      is available at http://stevem.us/fconv.html.
%
%
%Version 1.0
%Coded by: Stephen G. McGovern, 2003-2004.

Ly=length(x)+length(h)-1;  % in this case,linear convolution equal to circular convolution
if nargin<3      %add by Ainray, 20160319
    N=Ly;
end
Ly2=pow2(nextpow2(Ly));    % Find smallest power of 2 that is > Ly

%Ly2 always is greater than Ly=length(x)+length(h)-1, no aliasing occurs

X=fft(x, Ly2);              % Fast Fourier transform
H=fft(h, Ly2);	           % Fast Fourier transform
Y=X.*H;        	           % 
y=real(ifft(Y, Ly2));      % Inverse fast Fourier transform
y=y(1:1:min(N,Ly),:);               % Take just the first N elements
% y=y/max(abs(y));           % Normalize the output
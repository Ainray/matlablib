function [y,g,G]=gaussfilter(x,N,lamda)
% author: Ainray
% date: 20160313
% bug report: wwzhang0421@163.com
% information: averaging filter with gauss window
%              refer to :  dft_gauss
% syntax:       
%              y=gaussfilter(x,101,0.25);
% input:
%         N, the number of samples of gauss window
%     lamda, Twice of the cut-off frequency: 2*f0. Let alpha  be the STD in 
%            frequency domain, just reciprocal of time-domain STD. If the 
%            frequency w0 in which the amplitude decay to 1/e is defined as 
%            the cut-off freqency, then
%                       w0=sqrt(2)*alpha, and f0=alpha/(sqrt(2)*pi). 
%            Substitute alpha with lamda, we have:
%                       f0=0.5*lamda, w0=pi*lamda
%            so if we choose, f0=1/4, i.e., half the Nyquist freqency, we should
%            set lamda=1/2, corresponding to alpha=pi/sqrt(2)/2
%               In Matlab , 'alpha' corresponds to sqrt(2)/lamda=pi/STD.In the 
%            default case, where alpha=2.5, the band width is sqrt(2)/5.
%            So if we set lamda=sqrt(2)/alpha, then the resulted window coincides 
%            with Matlab's.
% output:
%         y, filtered sigal
if nargin<3
   lamda=0.5;
end

[g,G]=dft_gauss(N,lamda,'one-side');

[m,n]=size(x);
y=zeros(m,n);
for i=1:n
    tmp=fconv(x(:,i),g);
    start=floor((N+1)/2);
    y(:,i)=tmp(start:start+m-1);
end
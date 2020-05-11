function [B,A]=notch_allpass(w,bw,s)
% test example: 
%   w=[0.1,0.2,0.6]'*pi;
%   bw=[0.005,0.005,0.01]'*pi;
if nargin<3
    s=1;
end

w=v2col(w);
bw=v2col(bw);
n=length(w);
n2=n*2;
theta=zeros(n2,1);
wn=zeros(n2,1);

theta(2:2:n2)=-(2*(1:n)-1)*pi;
theta(1:2:n2)=-(2*(1:n)-1)*pi+s*pi/2;

wn(2:2:n2)=w;
wn(1:2:n2)=w-s*bw/2;

beta=(theta+n2*wn)/2;

b=tan(beta);
aa=zeros(n2,n2);
for k=1:n2
    aa(:,k)=sin(k*wn)-tan(beta).*cos(k*wn);
end
a=aa\b;
a=[1;a];
B=(a+a(end:-1:1))/2;
A=a;

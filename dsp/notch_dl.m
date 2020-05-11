function [B,A]=notch_dl(w,bw)

omega=tan(w/2);

tmp=1+omega.^2;

b=tmp*sqrt(1/cos(bw/2)-1);

a1=2*(1-omega.^2)/(tmp+b);
a2=1-2*b/(tmp+b);

% a1=2*cos(w)/(1+tan(bw/2))
% a2=(1-tan(bw/2))/(1+tan(bw/2))

B=[(1+a2)/2 -a1 (1+a2)/2]';
A=[1 -a1 a2]';
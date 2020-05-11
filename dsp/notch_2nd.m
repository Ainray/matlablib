function [B,A]=notch_2nd(w,bw)
alpha=cos(w);

% obtain gamma
% w1=w+bw/2;
% ga1=(1-2*alpha*cos(w1)+cos(2*w1))^2+(2*alpha*sin(w1)-sin(2*w1))^2;
% ga2=4*(cos(2*w1)-alpha*cos(w1))^2;
% ga3=4*(alpha*sin(w1)-sin(2*w1))^2;
% 
% gb1=4*(1-cos(2*w1))*(cos(2*w1)-alpha*cos(w1));
% gb2=4*sin(2*w1)*(alpha*sin(w1)-sin(2*w1));
% 
% gc1=(1-cos(2*w1))^2+sin(2*w1)*sin(2*w1);
% 
% ga=(ga2+ga3)-ga1/exp(-3/20);
% gb=gb1+gb2;
% gc=gc1;
% 
% gp=[ga gb gc];

% gamma=roots(gp);
% gamma=gamma(gamma<1);

gamma=1/(1+sqrt(1/cos(bw/2)-1));
A=[1 -2*alpha*gamma 2*gamma-1]';
B=[1 -2*alpha 1]'*gamma;
function [y,B,A]=drf_notcher(x,betas,yita)
% author: Ainray
% date: 20160319
% bug-report: wwzhang0421!63.com 
% information: zero-phase IIR filter
% reference: K.M. Strack,1990, Exploration with deep transient electromagnetics
% input: 
%          x, the input signal
%      betas, the numerical notching frequencies with respect to sampling freqency
%       yita, the bandwidth factor
% output: 
%          y, the filtered signal
for beta=betas
%       load n50;
%       B=n50;
%       y=fconv(x,B);
%       Nx=length(x);
%       y=y(40001:40001+Nx-1);
    alpha=cos(beta*2*pi);
    B=[yita,-2*alpha*yita,yita];
    A=[2*yita-1,-2*alpha*yita,1];
    y=filtfilt(B,A,x); 
    x=y;
end
% % 
% % 
% % 
%     alpha=cos(betas*2*pi);
%     B=[yita,-2*alpha*yita,yita];
%     A=[2*yita-1,-2*alpha*yita,1];
% x=v2col(x);
% N=length(x);
% y=zeros(N,1);
% % forward
% y(1)=B(1)*x(1)/A(1);
% y(2)=(B(1:2)*x(2:-1:1))/A(1);
% 
% for i=3:N
%     y(i)=(-A(2:3)*y(i-1:-1:i-2)+B*x(i:-1:i-2))/A(1);
% end
% % %backward
% 
% x=flipud(y);
% y(1)=B(1)*x(1)/A(1);
% y(2)=(B(1:2)*x(2:-1:1))/A(1);
% 
% for i=3:N
%     y(i)=(-A(2:3)*y(i-1:-1:i-2)+B*x(i:-1:i-2))/A(1);
% end
% y=flipud(y);

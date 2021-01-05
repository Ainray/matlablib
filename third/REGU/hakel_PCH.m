function [A]=hakel_PCH(N,n,sigma)
a1=1;a2=0.9;
omega1=0.1*pi;omega2=pi/3;
fy1=0;fy2=pi/4;
for i=1:N
    yta(i)=0+sigma.*randn;
    s(i)=a1*sin(i*omega1+fy1)+a2*sin(i*omega2+fy2)+yta(i);
end
A=zeros(N+1-n,n);
for j=1:n
    A(:,j)=s(j:N-n+j);
end

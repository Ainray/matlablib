function y=drf_notcher(x,beta,yita)
alpha=cos(beta*2*pi);
B=[yita,-2*alpha*yita,yita];
A=[2*yita-1,-2*alpha*yita,1];
% y=filter(B,A,x);  %forward
% y=filter(fliplr(B),fliplr(A),y0); %backward
x=v2col(x);
N=length(x);
y=zeros(N,1);
y(1)=B(1)*x(1)/A(1);
y(2)=(B(1:2)*x(2:-1:1))/A(1);

for i=3:N
    y(i)=(-A(2:3)*y(i-1:-1:i-2)+B*x(i:-1:i-2))/A(1);
end
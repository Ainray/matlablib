function [p,f]=prbs_srcfre(t_ele,n,cycle,a)
N=2^n-1;
l=floor(cycle*N);
p=zeros(l,1);
p(1)=2*pi*a^2/N^2;
fc=1/N/t_ele;
p(2:l)=a^2*(N+1)/N^2*(sin(pi*t_ele*(2:l)*fc)./(pi*t_ele*(2:l)*fc));
f=(0:l-1)'*fc;
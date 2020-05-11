function c=fdc(M,N)
% function c=fdc(M,N)
% author: ainray
% date: 20161217
% e-mail: wwzhang0421@163.com
% introduction: calculating the finite coefficients of N-order derivate
%               with 2M-order precision in case of evenly spacing
if nargin<2
    N=1;
end
vec=(-M:M);
A=flipud(vander(vec)');
b=zeros(2*M+1,1);
b(N+1)=factorial(N);
c=A\b;
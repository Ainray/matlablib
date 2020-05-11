function s=galois_add(p,a,b)
% author: ainray
% email: wwzhang0421@163.com
% date: 20180823
% introduction: addition over galois field of order p
% input: 
%     a, b
% output:
%     s
a=v2col(a);
b=v2col(b);
na=length(a);
nb=length(b);
n=max(na,nb);
a=[a;zeros(n-na,1)];
b=[b;zeros(n-nb,1)];
s=mod(a+b,p);

function s=galois_mul(p,a,b)
% author: ainray
% email: wwzhang0421@163.com
% date: 20180823
% introduction: multiplication over galois field of order p
% input: 
%     a, b
% output:
%     s
a=v2col(a);
b=v2col(b);
na=length(a);
nb=length(b);
if na>nb 
    tmp=a;
    a=b;
    b=tmp;
    tmp=nb;
    nb=na;
    na=tmp;
end
n=na+nb-1;
s=zeros(n,1);
for i=1:n 
    ni=min(na,i);
    ia=max(i-nb+1,1):ni;
    ib=min(i,nb):-1:max(i-na+1,1);
    s(i)=a(ia)'*b(ib);
end
s=mod(s,p);

function r=prbs_src_auto(t_ele,n,t,a)
if nargin<4
    a=1;
end
r=zeros(size(t));
nn=2^n-1;
r(:)=-a^2/nn;
T=nn*t_ele;
k=floor(abs(t)/T);
tmp=abs(abs(t)-k*T);
tmp2=abs(abs(t)-(k+1)*T);
tmp0=tmp;
tmp0(tmp2<=t_ele)=tmp2(tmp2<=t_ele);
r(tmp<=t_ele | tmp2<=t_ele)=a*a*(1-(nn+1)/nn*tmp0(tmp<=t_ele | tmp2<=t_ele)/t_ele);
function [Gamp,Gph,G]=analyticimpulsefre(ps,r,f)
nf=length(f);
nr=length(r);
G=zeros(nf,nr);
for i=1:nr
    ikr=sqrt(-1)*sqrt(-sqrt(-1)*2*pi*f*4*pi*1e-7/ps)*r;
    G(:,i)=0.5/pi*ps./r.^3.*(1+(ikr+1).*exp(-ikr));
end
Gamp=abs(G);
Gph=phase(G);

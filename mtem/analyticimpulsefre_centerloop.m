function [Gamp,Gph,G]=analyticimpulsefre_centerloop(ps,a,f)
k=sqrt(-sqrt(-1)*2*pi*f*4*pi*1e-7/ps);
ika=sqrt(-1)*k*a;
k2a2 = k.*k*a*a;
G=1./k2a2/a.*(3-(3+3*ika-k2a2).*exp(-ika));
Gamp=abs(G);
Gph=phase(G);

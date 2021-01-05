function attrs=hilbertattrs(seis,t)
% HILBERTATTRS computes instantaneuous amp, phs, freq, and bandwidth
%
% attrs=hilbertattrs(seis,t)
% 
% seis ... seismic matrix
% t ... time coordinate of seismic matrix
% attrs ... length 5 cell array {amp,phs,freq,bw,Q}
%
ntr=size(seis,2);
dt=t(2)-t(1);
amp=zeros(size(seis));
phs=amp;
freq=amp;
bw=amp;
oneupontwopi=1/(2*pi);
small=100*eps;
for k=1:ntr
    s=seis(:,k);
    %test for 0
    ind=find(abs(s)<small);
    s(ind)=small*randn(size(ind));
    %analytic trace
    sa=hilbert(s);
    x=real(sa);
    y=imag(sa);
    %amp
    a=abs(sa);
    %phase
    p=atan2(y,x);
    %freq
    xp=gradient(x,dt);
    yp=gradient(y,dt);
    f=oneupontwopi*(x.*yp-xp.*y)./(x.^2+y.^2);
    %bw
    ap=gradient(a,dt);
    b=2*abs(oneupontwopi*ap./a);
    %q
%     q=2*pi*f./b;
    
    amp(:,k)=a;
    phs(:,k)=p;
    freq(:,k)=f;
    bw(:,k)=b;
end

attrs={amp,phs,freq,bw};


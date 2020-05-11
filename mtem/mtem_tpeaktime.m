function [tp,pv]=mtem_tpeaktime(g,t,fig,ts)
if nargin<3
    fig=0;
end
if nargin<4
    ts=1e-5;  % 10us
end

fs=1/ts;
[tpn,pv]=gettpn(g);
fs0=1/(t(2)-t(1));
if fs0<fs 
    indx0=tpn;
    x0=t(max(indx0-10,1):min(indx0+10,length(t)));
    y0=g(max(indx0-10,1):min(indx0+10,length(t)));
    nx=floor((x0(end)-x0(1))*fs);
    x=linspace(x0(1),x0(end),nx);
    y=interp1(x0,y0,x,'spline');
    [~,m]=max(y);
    tp=x(m);
else
    tp=t(tpn);
end
if fig==1
    plot(t,g,'k');
    hold on
    plot(tp,pv,'ro');
end

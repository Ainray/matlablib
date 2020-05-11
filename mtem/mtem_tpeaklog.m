function [tp,pv]=mtem_tpeaklog(g,t,fig,ts)
if nargin<3
    fig=0;
end
if nargin<4
    ts=1e-5;  % 10us
end
[tpn,pv]=gettpn(g);
fs=1/ts;

% logorithmic time interval: dy=dx/x
ts0log=sum(diff(t(tpn-1:tpn+1)))/2;
fs0=t(tpn)/ts0log;
if fs0<fs
    indx0=tpn;
    x0=t(max(indx0-10,1):min(indx0+10,length(t)));
    y0=g(max(indx0-10,1):min(indx0+10,length(t)));
    % log to linear
    x0log=log10(x0);
    nx=floor((x0log(end)-x0log(1))*fs);
    x=linspace(x0log(1),x0log(end),nx);
    y=interp1(x0log,y0,x,'spline');
    [~,m]=max(y);
    tp=10^x(m);
else
    tp=t(tpn);
end
if fig==1
    semilogx(t,g,'k');
    hold on
    plot(tp,pv,'ro');
end

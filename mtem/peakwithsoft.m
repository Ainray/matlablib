function [tpn,pv]=peakwithsoft(g,tpn0,n)
N=length(g);
x=(max(1,tpn0-n):min(tpn0+n,N))';
y0=g(x);
p=polyfit(x,y0,2);
y=polyval(p,x);
[pv,tpn]=max(y);
tpn=tpn+x(1)-1;
tpns=tpn;
for k=1:5
    if tpn~=tpn0  % new value
        if(tpn0<tpn) % extend the range
            x=(x(1):min(x(end)+tpn-tpn0,N))';
        else
            x=(max(x(1)+tpn-tpn0,1):x(end))';
        end      
        y0=g(x);
        p=polyfit(x,y0,2);
        y=polyval(p,x);
        tpn0=tpn;
        [pv,tpn]=max(y);
        tpn=tpn+x(1)-1;
        tpns(k+1)=tpn;
    else
        break;
    end
end

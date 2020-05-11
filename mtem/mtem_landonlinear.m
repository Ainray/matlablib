function m=mtem_landonlinear(t,imp,p,ps,rcv)
n1=length(ps);
n2=length(p);
n3=length(rcv); 
m=zeros(n1,n2);
for i=1:n1  % ps
    tao=rho2tao(ps(i));
    for j=1:n2  %p
        for k=1:n3         
%             if j==8 && k==23 
%                 i,
%                 j, 
%                 k
%             end
            tl=tlog(tao,p(j),rcv(k));
            m(n1,n2)=m(n1,n2)+t2g(tl,t,imp(:,k));
        end
    end
end
end


function tao=rho2tao(rho)
    tao=log10(4*pi*1e-8/rho);
end
function tl=tlog(tao,p,x)
    tl=tao+p*log10(x);
end
function x1=t2g(tl,t,g,ts)
    if nargin<4
        ts=1e-5;
    end
    tlog=log10(t);  % log time
    indx=find(tlog>tl,1);
    if isempty(indx)
        x1=0;
    elseif indx>1
        % current time resoultion
        dt=sum(diff(tlog(indx-1:indx+1)))/2*t(indx);
        if dt>ts 
            x0=tlog(max(indx-10,1):min(indx+10,length(tlog)));
            y0=g(max(indx-10,1):min(indx+10,length(tlog)));
            nx=floor((x0(end)-x0(1))/(ts/t(indx)));
            x=linspace(x0(1),x0(end),nx);
            y=interp1(x0,y0,x,'spline');
            x1=y(find(x>tl,1));
        else
            x1=g(indx);
        end
    else
        x1=0;
        % extra
%         x1=interp1(t(1:10),g(1:10),tl,'spline','extrap');
    end
end
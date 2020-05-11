function vectarrowv(x0,y0,y1,lenr,angdeg,dr,clr,lw,flag)
if nargin<6
    dr=1;
end
if nargin<8
    flag=1;  % dual heads
end
% simple version, only for vertical line
len=lenr*(y1-y0);
angle=angdeg/180*pi;
hu0=[x0-len*sin(angle);x0;x0+len*sin(angle)]*dr;
hv0=[y0+len*cos(angle);y0];hv0(3)=hv0(1);
hv1=[y1-len*cos(angle);y1];hv1(3)=hv1(1);
% plot line
plot([x0,x0],[y0,y1],clr,'linewidth',lw);
hold on;
if flag==1
    plot(hu0,hv0,clr,'linewidth',lw); % tail
    plot(hu0,hv1,clr,'linewidth',lw); % head
else
    plot(hu0,hv1,clr,'linewidth',lw); % only head
end

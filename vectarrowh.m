function vectarrowh(x0,x1,y0,lenr,angdeg,clr,lw)
% simple version, only for vertical line
len=lenr*(x1-x0);
angle=angdeg/180*pi;

hv0=[y0+len*sin(angle);y0;y0-len*sin(angle)];
hu0=[x0+len*cos(angle);x0];hu0(3)=hu0(1);
hu1=[x1-len*cos(angle);x1];hu1(3)=hu1(1);
% plot line
plot([x0,x1],[y0,y0],clr,'linewidth',lw);
hold on;
plot(hu0,hv0,clr,'linewidth',lw);
plot(hu1,hv0,clr,'linewidth',lw);

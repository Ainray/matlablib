function t=mtem_endtime(ps,r,v)
if nargin<3
    v=0.0001;
end
tao=exp(1)*v^(-0.4);
% v1=exp(2.5)*tao^(-2.5)*exp(-2.5/tao);
t=tao*4*pi*1e-7*r.*r/10/ps;
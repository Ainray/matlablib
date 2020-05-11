function yc=lconv2c(yl,nx,nh)
%function yc=lconv2c(yl,nx,nh)
% author: Ainray
% date: 20170525
% email: wwzhang0421@163.com
% introduction: aliasing linear convolution into circular convolution
if nx<nh 
    error('Length of x must be long than h');
end
if nh==0
    yc=yl;
    return
end
 yc=zeros(nx,1);
 yc(1:nh-1)=yl(1:nh-1)+yl(nx+1:nx+nh-1);
 yc(nh:nx)=yl(nh:nx);
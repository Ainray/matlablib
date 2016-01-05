%function [h,sz,misfit]=strack(x,y,k)
function [h,sz,misfit]=strack(x,y,k)
error(nargchk(2, 3, nargin, 'struct'))
if nargin==2
    k=20;
end
x=v2col(x);y=v2col(y);
A0=y;
for i=1:k
    A0x=fconv(A0,x);
    [A0l,y0l,A0xl]=equalen(A0,y,A0x);
    A1=A0l+(y0l-A0xl);
    A1x=fconv(A1,x);
    [A1xl,y1l]=equalen(A1x,y);
    misfit(k)=norm(A1xl-y1l)/sqrt(length(y1l));
    sz(k)=norm(A1)^2;
    if abs((misfit(k-1)-misfit(k))/misfit(k-1))<5*1e-2
        break;
    end
    A0=A1;
end
h=A1;
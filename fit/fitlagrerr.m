function [y,err]=fitlagrerr(x,xp,yp)
% function [y,err]=lagr(x,xp,yp)
% author: ainray
% date: 20170706
% email: wwzhang0421@163.com
% introduction: calulate function value "y" at point x, according to 
%               samples (xp,yp); the error is estimated by
%               post-interpolation.
%               First, interpolation uses xp(1:N-1)
%               Then, interpolation uses xp(2:N).
N=length(xp);
y=lagrange(x,xp(1:N-1),yp(1:N-1));
y1=lagrange(x,xp(2:N),yp(2:N));
err=(x-xp(1))/(xp(1)-xp(N)).*(y-y1);
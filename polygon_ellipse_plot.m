function polygon_ellipse_plot(x, y, clr)
% author: Ainray
% date: 20220816
% bug-report: wwzhang0421@163.com
% introduction: general ellipse equation
% modify:

if nargin< 3
    clr = 'k';
end

xx = [x; x(1)];
yy = [y; y(1)];
plot(xx, yy, clr);

















































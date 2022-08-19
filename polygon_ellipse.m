function [x, y] = polygon_ellipse(a, b, x0, y0, alpha, n)
% author: Ainray
% date: 20220816
% bug-report: wwzhang0421@163.com
% introduction: general ellipse equation
% modify:
if nargin < 3 || isempty(x0)
    x0 = 0;
end

if nargin < 4 || isempty(y0)
    y0 = 0;
end

if nargin < 5 || isempty(alpha)
    alpha = 0;
end

if nargin < 6
    n = 100;
end
% local
xl = linspace(-a, a, n);
yl = sqrt((1 - xl.^2/a^2) * b^2);

xl = [xl(:); xl(end-1:-1:2)'];
yl = [yl(:); -yl(end-1:-1:2)'];

% local 2 global;
[x, y] = coor_rotate(xl, yl, alpha);
[x, y] = coor_translate(x, y, x0, y0);
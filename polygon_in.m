function in = polygon_in(data, x, y)
% author: Ainray
% date: 20220816
% bug-report: wwzhang0421@163.com
% introduction: check inside or outside of data
% modify:
[m, n] = size(data);
[xq, yq] = meshgrid(1:n, 1:m);
in = inpolygon(xq,yq, x, y);
% index = ind2sub([m,n], in);
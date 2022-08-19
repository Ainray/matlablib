function [xr, yr] = coor_rotate(x, y, alpha)
% author: Ainray
% date: 20220816
% bug-report: wwzhang0421@163.com
% introduction: coordiante rotate, alpha is positive for couterclockwize
%               rotation.
% modify:
alpha = alpha/180*pi;
R = [cos(alpha) -sin(alpha);  sin(alpha), cos(alpha)];
xy = R * [x(:) y(:)]';
xr = xy(1,:)';
yr = xy(2,:)';




    



















































function y = polygon_zero(x, px, py, inorout)
% author: Ainray
% date: 20220816
% bug-report: wwzhang0421@163.com
% introduction: general interface zering data when radius is smaller than specified value 
% modify:

if nargin < 4
    inorout = 0; 
end
in = polygon_in(x, px, py);
y = x;
if(~inorout) %default zero in
    y(in) = 0;
else
    y(~in) = 0;
end

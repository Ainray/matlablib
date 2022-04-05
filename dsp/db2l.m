function l=db2l(db,factor)
% author: ainray
% date: 20170526
% email: wwzhang0421@163.com
% introduction: convert decibel value into linear value with 1 as reference.
% input:
%         db, decibel value
%     factor, 10 or 20, 10 for power, 20 for amplitude
% output:
%          l, linear value
if nargin<2
    factor=10;
end
l=10.^(db/factor);
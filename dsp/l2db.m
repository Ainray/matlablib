function db=l2db(l,factor)
% author: ainray
% date: 20170526
% email: wwzhang0421@163.com
% introduction: convert linear value into  decibel value with 1 as reference.
% input:
%          l, linear value
%     factor, 10 or 20, 10 for power, 20 for amplitude
% output:
%         db, decibel value
if nargin<2
    factor=10;
end
db=factor*log10(l);
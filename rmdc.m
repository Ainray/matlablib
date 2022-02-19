function y = rmdc(x, isshow)
% Author: Ainray
% date: 20211021
% bug-report: wwzhang0421@163.com
% introduction: The program move dc, calling ischange
if(nargin<2)
    isshow = 0;
end

[~,S1,S2] = ischange(x,'linear');
Nx = length(x);
segline = S1.* (1:Nx)' + S2;
y = x - segline;
if(isshow)
    plot(x,'b');
    hold on;
    plot(segline,'r');
end



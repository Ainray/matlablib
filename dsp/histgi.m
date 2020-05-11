function [h,x1,x2]=histgi(x)
% syntax:
% 		[h,x1,x2]=histgi(x)
% author: ainray
% date: 20170813
% introduction: get histrogram of integer arrays
% parameter:
%          h, histrogram
%          x1, min
%          x2, max
x1=min(x);
x2=max(x);
N=numel(x);
nh=x2-x1+1;
h=zeros(nh,1);
for i=1:N
    h(x(i)-x1+1)=h(x(i)-x1+1)+1;
end
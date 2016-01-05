% function m=finddisc(x,sse)
% author: Ainray
% date: 2015/12/07
% bug report: wwzhang0421@163.com
% introduciton: find discontinuies based start-setp-end triple
%   input:
%          x, the array to be checked
%        sse, triple element array
%             ----------------------------
%              sse(1)    sse(2)    sse(3)
%              start     step       end
%             ----------------------------
%  output:
%          m, the find discontinuies 
function m=finddisc(x,sse)
% calculating the theoretical array
xt=[sse(1):sse(2):sse(3)];
cc=0;  % miss point counter 
for i=xt
    if(isempty(find(i==x))) % when i is not included in x
        cc=cc+1;
        m(cc)=i;
    end
end
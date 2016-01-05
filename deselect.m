% function dx=deselect(x,indx)
% author: Ainray
% time  : 2015/7/26
% bug report: wwzhang0421@163.com
% information: de-select vector x by not selecting the elements indexed by indx.
% input:
%         x, data vector
%      indx, selected indices 
%  output:
%        dx, de seleteced elements
function dx=deselect(x,indx)
cc=0;
for i=1:length(x)
    if(isempty(find(indx==i)))
        cc=cc+1;
        dx(cc)=x(i);
    end
end
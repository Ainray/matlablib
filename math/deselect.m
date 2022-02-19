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
%20160309 changed by Ainray
N=length(x);
lia=ismember(1:N,indx);
dx=x(lia==0); % deseleted items

% cc=0;
% for i=1:length(x)
%     if(isempty(find(indx==i)))
%         cc=cc+1;
%         dx(cc)=x(i);
%     end
% end
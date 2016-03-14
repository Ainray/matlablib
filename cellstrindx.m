% function x=cellstrindx(c,indx) 
% author: Ainray
% date: 20160309
% bug-report:wwzhang0421@163.com
% introduction: return the partitions of the elements 
%      input:
%            c, cell string array or string, if c is a string,just like c(indx)
%         indx, indices matrix, whose row indexing corresponding element of c 
%     output:
%            x, return the indexed element array
function x=cellstrindx(c,indx)
if ~iscell(c)
    x=c(indx);
else
   N=length(c);
   x=cell(N,1);
   for i=1:N;
       x{i}=c{i}(indx(i,:));
   end
end
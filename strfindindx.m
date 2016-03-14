% function [i,k]=strfindindx(c,pat) 
% author: Ainray
% date: 20160309
% bug-report:wwzhang0421@163.com
% introduction: return the indices of any occurrences of the string 'pat'
%             : in the cell array c, and also return the starting indices 
%             : if some element of c matching pat according to strfind function
%      input:
%            c, cell string array or string, if c is a string, just like strfind
%     output:
%            i, the indices of elements which matched pattern according to strfind
%            k, the starting indices of pattern in the ith element
function [i,k]=strfindindx(c,pat)
if iscell(c)
    tmp=strfind(c,pat);
    i=v2col(find(not (  cellfun(@isempty,tmp))));
    k=v2col(cell2mat(tmp(i)));
else
    k=strfind(c,pat);
    i=1;
end
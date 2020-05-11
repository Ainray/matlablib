% function [i,k]=strfindindx(c,pat,equal)
%	syntax:
% 		[i,k]=strfindindx(c,pat,equal)
% author: Ainray
% date: 20160309
% bug-report:wwzhang0421@163.com
% introduction: return the indices of any occurrences of the string 'pat'
%             : in the cell array c, and also return the starting indices 
%             : if some element of c matching pat according to strfind function
%      input:
%            c, cell string array or string, if c is a string, just like strfind
%          pat, match patten
%        equal, exactly matched, when true, k make no sense
%     output:
%            i, the indices of elements which matched pattern according to strfind
%            k, the starting indices of pattern in the ith element
function [i,k]=strfindindx(c,pat,equal)
if nargin<3
    equal=0;
end
if ~equal
    if iscell(c)
        tmp=regexpi(c,pat,'once');
%       N=numel(tmp);
%       i=zeros(N,1);
%       for ii=1:N
%            if ~isempty(tmp{ii})
%                 i(ii)=ii;
%            end
%       end
        i=v2col(find(not (  cellfun(@isempty,tmp))));
        k=v2col(cell2mat(tmp(i)));
    else
        k=regexpi(c,pat);
        if isempty(k)
            i=[];
        else
            i=1;
        end
    end
else
    i=[];
     if iscell(c)
       cc=0;
       for kk=1:numel(c)
           if strcmpi(c(kk),pat)
               cc=cc+1;
               i(cc)=kk;
           end
       end
    else
      if strcmpi(c,pat)
          i=1;
      end 
    end
end
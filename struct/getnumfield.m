function x=getnumfield(s,fn,indx)
%function x=getnumfield(s,fn,indx)
% author: Ainray
% date: 20170619
% email: wwzhang0421@163.com
% introduction: get numeric field from struct s: s(indx).fn
%           input:
%               s, struct array
%              fn, field name for specified numeric field
%            indx, index of struct array.
%           output:
%               x, return value, array of specified field, if it is a scalar
%                  or matrix of which per column is specified field from
%                  per struct.
x=[];
if ~eval(['isnumeric(s(1).',fn,')'])
    error(['Field: ',fn,' does not exist. Or, it is not numeric']);
end
N=numel(s);
if nargin<3
    indx=1:N;
end
ii=0;
for i=indx
    ii=ii+1;
    eval(['x(:,ii)=s(i).',fn,';']);
end

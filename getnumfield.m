function x=getnumfield(s,fn,sfield)
if nargin<3
    sfield=[];
else
    sfield=[sfield,'.'];
end
N=numel(s);
% if ~eval(['isa(s.',fn,',''double'')'])
%     return;
% end
x=[];
for i=1:N
    eval(['x(:,i)=s(i).',sfield,fn,';']);
end

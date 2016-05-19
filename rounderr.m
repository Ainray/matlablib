function [sp,rp]=rounderr(x,pre)
% introduction: get round error
% example :
%       x=[0.00001233862713,1,1.996093750,636.0312500,217063424.0];
%       [pre,rp]=rounderr(x)

if nargin<2
    pre='single';
end

if strcmpi(pre,'single')
   N=127; % offset
   M=-23;
else
    N=1023; %offset
    M=-52;
end
nx=numel(x);
sp=zeros(nx,1);
rp=zeros(nx,1);
for i=1:nx
    [s,e,f]=ieee754(x(i),'dec',pre);
    sp(i)=2^(e-N+M);
    rp(i)=sp(i)/x(i);
end

function y=dotproduct(u,v,G,type)
% function y=dotproduct(u,v,G,type)
% because dot product is not invariable for different basis 
% so first get the basis component first
% type: 2-element vector, specify type for u and v
if nargin==2 % basic
    y=v2row(u)*v2col(v);
    return;
end
u=it(u,G,type(1));
v=it(v,G,type(2));
y=v2row(u)*v2col(v);
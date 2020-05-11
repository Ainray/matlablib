function y=crossproduct(u,v,G,type)
% function crossproduct(u,v,G,type)
% because dot product is not invariable for different basis 
% so first get the basis component first
% type 0:to get cellar component,  u, v must both be roof compoents
% type 1: correspondingly, to get roof compoent, u, v must both be cellar components

% y(1)=u(2)*v(3)-u(3)*v(2);
% y(2)=u(3)*v(1)-u(1)*v(3);
% y(3)=u(1)*v(2)-u(2)*v(1);
% if type==0
%     y=y*det(G);
% else
%     y=y/det(G);
% end
% y=y';
% % aternatively
% y=crossop(u,G,type)*v2col(v);

if nargin==2
    y=cross(u,v);
    return;
end
y=crossop(it(u,G,1-type),G,type)*v2col(v);
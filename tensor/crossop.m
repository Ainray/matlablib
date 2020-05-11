function y=crossop(u,G,type)
%
% find the 2-order tensor cell compoents for vecter u under a basis of G 
% u is a vector for pre cross multiplication with v
% that is, if we find the operator for u, then
% u¡Áv=y*u, where y the 2-order operator for u
%
% Method 1:
% the default is cell compoents;u¡Á=epsilon(i,j,k)*u(i)*direct(gk,gj)
% this expresion use Enstein summation convention
% And epsilon(i,j,k) is defined as positive derminant of G,(i,j,k) 
% is and even permutation, or as negtive dernimant of G if (i,j,k)
% is and odd permutation, or 0 if two or more of indices are euqal
% % so
% u=component(u,G,type);
% U=[0,-u(3), u(2);u(3),0,-u(1);-u(2),u(1),0];
% y=U*det(G);
% Method 2:
% it is well-known u¡Á=[0,-uz,uy;uz,0,-ux;uy,ux,0];                               
% so 
% U=[0,-u(3),u(2);u(3),0,-u(1);-u(2),u(1),0];
% if nargin<2
%     y=U;
%     return
% end
% y=G'*U*G;
U=[0,-u(3),u(2);u(3),0,-u(1);-u(2),u(1),0];
if nargin<2
    y=U;
    return
end
y=component(U,G,type);

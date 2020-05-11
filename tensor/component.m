function [cy,ry,my1,my2]=component(v,G,type)
% function [cy,ry,my1,my2]=component(v,G,type)
% find components of v under basis of G
% covariant components: V=G*cy
% contravariant/roof components: V=Gi'*ry
% input:
%       v, the known vector
%       G, the known basis
%    type, cellar/roof/mixed(0,1,2,3)
cy=[];ry=[];my1=[];my2=[];
if min(size(v))==1 % for vector
    cy=G'*v;
    ry=G\v;
elseif size(v,1)==size(v,2)% for tensor
    cy=G'*v*G;
    Gi=inv(G);
    ry=G\v*Gi';
    my1=G\v*G;
    my2=G\v'*G;    
end
if nargin==3
    if type==0 %cellar
        if min(size(v))==1 % for vector
           cy=G'*v;
        elseif size(v,1)==size(v,2)% for tensor
           cy=G'*v*G;
        end
    elseif type==1  %roof
         if min(size(v))==1 % for vector
           cy=G\v;  
        elseif size(v,1)==size(v,2)% for tensor  
           cy=G\v*Gi'; 
        end
    elseif type==2
           cy=G\v*G;
    elseif type==3
           cy=G\v'*G;        
    end
end
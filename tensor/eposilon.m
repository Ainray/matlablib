function y=eposilon(v,G,type)
% function y=eposilon(i,j,k,G)
% v the scripts
% type :0-cellar 1-roof
if type==0
    y=permnum(v)*det(G);
else
    y=permnum(v)/det(G);
end
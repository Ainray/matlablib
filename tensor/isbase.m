function y=isbase(G)
% whether columns of G consists of a group basis
if det(G)~=0 % true
    y=1;
else       %fasle
    y=0;
end

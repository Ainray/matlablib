function y=transform(v,A,type)
% function y=transform(v,A,type)
% find the new components for new basis
if type==0
    if min(size(v))==1 % for vector
       y=A'*v;
    elseif size(v,1)==size(v,2)% for tensor
       y=A'*v*A;
    end
elseif type==1
     if min(size(v))==1 % for vector
       y=A\v;
    elseif size(v,1)==size(v,2)% for tensor
       y=A\(A\v');
    end
elseif type==2
    y=A\(v*A);
elseif type==3
    y=(A\v)*A;
end

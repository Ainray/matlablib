function y=directproduct(u,v)
% find the product of u and v
N=length(u);
if N~=length(v)
    error('u and v must have the same length');
end

y=(v2col(u)*ones(1,N)).*(ones(N,1)*v2row(v));


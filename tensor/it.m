function y=it(v,G,type)
% function y=it(v,G,type)
% find the vector or tensor from components v 
% for basis G
% type 0: cellar components
% type 1: roof components
% type 2: mixed components, only for tensor
% type 3: mixed components, only ofr tensor

y=0;N=size(v,1);
if min(size(v))==1 % for vector
   if type==0
        y=inv(G)'*v;       %cellar
   else
        y=G*v;        %roof
   end    
elseif N==size(v,2)% for tensor
       T=directop(G,type);
       for i=1:N*N
         y=y+v(i)*T{i};
       end
end 
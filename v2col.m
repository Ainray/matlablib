function c=v2col(v)
if size(v,1)==1 && size(v,2)>=1
    c=v';
else
   c=v;
end
     
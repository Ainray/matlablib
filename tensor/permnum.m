function y=permnum(v)
% function y=permnum(v)
% get number of inverse permutation number
invnum=0;
for i=1:numel(v)
    dd=v(i)-v(i+1:end);
    invnum=invnum+numel(find(dd>0));
end
y=invnum;
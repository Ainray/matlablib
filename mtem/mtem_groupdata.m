function [impi,tt]=mtem_groupdata(imp,t)
tt=unique(reshape(t,[],1));
m=length(tt);
n=size(imp,2);
impi=zeros(m,n);
for i=1:n
    t1=t(:,i);
    indx0=find(tt<t1(1),1);
    if isempty(indx0)
        indx0=0;
    end
%     impi(1:indx0-1)=0;
    indx1=find(tt>t1(end),1);
    if isempty(indx1)
        indx1=m+1;
    end
%     impi(indx1:end)=0;
    impi(indx0+1:indx1-1,i)=interp1(t1,imp(:,i),tt(indx0+1:indx1-1),'spline');
end
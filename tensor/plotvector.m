function plotvector(v)
% plot vectors from origin in three dimensional frame
% v must 3*N or 2*N, N=1,2,...
N=size(v,2);
U=v(1,:)';V=v(2,:)';W=v(3,:)';
X=zeros(N,1);Y=X;Z=X;
quiver3(X,Y,Z,U,V,W,1);
m=sprintf('(%.d, %d, %d);',[U V W]');
[i,k]=strfindindx(m,';');
N=length(k);
cm=cell(N,1);
k=[0,k];
for i=1:N
    cm{i}=m(k(i)+1:k(i+1)-1);
end
text(U,V,W,cm);
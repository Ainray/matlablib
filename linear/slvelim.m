function [x,jnr]=slvelim(A,b)
% function x=slvelim(A,b)
% date: 20170523
% author: ainray
% email: wwzhang0421@163.com
% introduction: solving equations based on elemetary row trasform
% test: A=[9 -3 1;1 1 1;4 2 1]; b=[20 0 10]';
%       A=[1 2 3 4 ;1 2 0 -5 ;2 4 -3 -19 ;3 6 -3 -24];b=[-3 1 6 7]';
[m,n]=size(A);
Ab=[A';v2row(b)]'; % augmented matrices

[B,j]=eletran(Ab,m);
nb=find(B(:,end),1,'last');
r=length(j); % rank of A
if nb>r  % no solution
    x=[]; 
    jnr=[];
    return;
end
if r==n   %unique solution
    x=Ab(:,end); 
    jnr=[];
else      % infinite number of solutions, return its basis
    jnr=deselect((1:n),j); % column number of basic solution system
    bos=zeros(n,n-r);      % basis of solutions
    bos(1:r,1:n-r)=-B(1:r,jnr);
    for i=1:n-r
        bos(r+i,i)=1;
    end
    [~,loc]=sort([v2row(j),v2row(jnr)]);
    x=bos(loc,:);
end

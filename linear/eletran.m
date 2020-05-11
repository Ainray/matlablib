function [B,j,c]=eletran(A,maxm)
% function [B,j,c]=eletran(A,maxm)
% date:20170522, 20170523
% author: Ainray
% email: wwzhang0421@163.com
% introduction: carrying out elementary row transform for matrix
%               to solving linear equations
% input:
%       A, input matrix
%    maxm, the limit of A' row number
% output:
%       B, the simplied version of A
%       j, the column number of correponding columns consists of the basis of column vectors of A
%          that is, A(:,j) is the basis the of column vectors of A
%       c, the snapshots of elementary row transform of A
%          
% test 1: unique solution, nr=0, that is ,0-dimension(nr=0)
%         a=[1 2 3 4 -3;1 2 0 -5 1;3 -1 -1 0 1;1 0 1 2 -1];
%         [B,c,j]=eletran(a)
% test 2: infinite number of solutions, 2-dimension(nr=2)
%         a=[1 2 3 4 -3;1 2 0 -5 1;2 4 -3 -19 6;3 6 -3 -24 7];
%         [B,c,j]=eletran(a)
% test 3: homogeneous equtions
%         a=[1 2 3 4 0;1 2 0 -5 0;2 4 -3 -19 0;3 6 -3 -24 0];
%         [B,c,j]=eletran(a)
% test 4:  no solution
%         a=[1 2 3 4 -3;1 2 0 -5 1;2 4 -3 -19 6;3 6 -3 -24 6];
%         [B,c,j]=eletran(a)

if nargin==1
    maxm=10;
end
[m,n]=size(A);
if m>maxm
    error(printf('The number of row of input maxtrix is too large, which should be less than %d.',maxm));
end
c{1}=A;    %  Aself
j=zeros(1,n); % store the column number of non-free unknowns
m0=1;
j1=1;
for m0=1:m
    [m2,j2]=find(A(m0:m,j1:n),1,'first');
    if isempty(m2) || isempty(j2)
        break;% end elimination
    end
    m2=m2+m0-1;
    j2=j2+j1-1;
    j(m0)=j2;
    j1=j2+1;
    if m2>m0 %current 'first' row with zero at its first column
        a1=A(m0,:);  % swap m0 and m1 row of A
        A(m0,:)=A(m2,:);
        A(m2,:)=a1;
    end  
    %eleminate the "j(m0)"th columns 
    A(m0,:)=A(m0,:)/A(m0,j(m0));
    for i=[1:m0-1,m0+1:m]
        A(i,:)=A(i,:)-A(m0,:)*A(i,j(m0))/A(m0,j(m0));
    end
    c{m0+1}=A; %store the 
end
B=A;
j=j(1:find(j,1,'last'));
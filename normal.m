% function [nz,mz]=normal(z,dim)
% author: Ainray
% date: 20160130
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: normalizing matrix by element with maximum absoulte value
% input:
%         z, original matrix
%       dim, if 1, matrix arranged by column, the default value
%            if 2, matrix arranged by row
% output:
%         nz, return normalized matrix
%         mz, return vector containing maximum absolute values, 
%             by columns if dim==1, by rows if dim==2
function [nz,mz]=normal(z,dim)
if nargin<2
    dim=1;   
end
if dim~=1 && dim~=2
    error('Dimension must be 1 or 2.');
end
if dim==2
    z=z';
end
[m,n]=size(z);
[mv,I]=max(abs(z));
indx=I+(0:n-1)*m;
mz=z(indx);
mmat=ones(m,1)*v2row(mv);
nz=z./mmat;
if dim==2
    nz=nz';
    mz=mz';
end


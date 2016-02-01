% function z=z
% author: Ainray
% date: 20160130
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: denormalizing matrix.
% input:
%         nz, normalized matrix
%         mz, vector containing maximum absolute values,  
%             if dim==1, mz must be row vector,
%             if dim==2, mz must be column vector.
%       dim, if 1, matrix arranged by column, the default value
%            if 2, matrix arranged by row
% output:
%         z, original unormalized matrix
%             
function z=denormal(nz,mz,dim)
if dim~=1 && dim~=2
    error('Dimension must be 1 or 2.');
end
[m,n]=size(nz);
[m1,n1]=size(mz);

if dim==1 && m1~=1 
	error('Error: maximum vector must be row vector');
elseif dim==1 && n1~=n 
	error('Error: maximum vector length must be equal to the number of columns of normalized matrix');
elseif dim==2 && n1~=1
	error('Error: maximum vector must be row vector');
elseif dim==2 && m1~=m
	error('Error: maximum vector length must be equal to the number of rows of normalized matrix');
end

if dim==1
	nmat=ones(m,1)*mz;
	z=nz.*nmat;
elseif dim==2
    nmat=mz*ones(1,n);
	z=nz.*nmat;
end
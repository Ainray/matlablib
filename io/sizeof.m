% function bytes=sizeof(var)
% author: Ainray
% date: 20151217
% bug-report: wwzhang0421@163.com
% introduciton: return the number of bytes for 'var' variable
% input:
%           var, the variable
% output:
%             N, the number of bytes of 'var'
function N=sizeof(var)
s=whos(var2str(var));
N=s.bytes;
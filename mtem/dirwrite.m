function dirwrite(sdc,rdc)
%function [sd,rd]=dirread
% author: Ainray
% date: 20170615
% email: wwzhang0421@163.com
% introdction: write dirs into parameter file: mtemsrc.path, mtemrcv.path
%     If the parameter file 'par\mtemsrc.path' does not exist, this 
%     function first create it, then write 'sdc' into it.
%     If the parameter file 'par\mtemrcv.path' does not exist, this 
%     function first create it, then write 'rdc' into it.
%  input:
%          sdc, cell array of directories where source data may be in
%          rdc, cell array of directories where receiver data may be in
%  output: 
%          (none)
%  See also dirread, dirupdate
 % update the path dir
 if nargin<2
     rdc=sdc;
 end
if ~exist(fullfile(pwd(),'par'),'dir')
    mkdir('par');
end
fid=fopen(fullfile(pwd(),'par','mtemsrc.path'),'w');
fprintf(fid,'%s',strjoin(sdc,'\n'));

fid=fopen(fullfile(pwd(),'par','mtemrcv.path'),'w');
fprintf(fid,'%s',strjoin(rdc,'\n'));
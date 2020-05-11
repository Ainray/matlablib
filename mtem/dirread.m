function [sdc,rdc]=dirread
%function [sd,rd]=dirread
% author: Ainray
% date: 20170615
% email: wwzhang0421@163.com
% introdction: read dir from parameter file: mtemsrc.path, mtemrcv.path
%  input:
%       none ( the default path is par in the current directory
%  output: 
%          sdc, cell array of directories where source data are in, if the parameter file
%              'par\mtemsrc.path' does not exist, it returns ''.
%          rdc, cell array of directories where receiver data are in, if the parameter file
%              'par\mtemrcv.path' does not exist, it returns ''.
%  See also dirwrite, dirupdate
parpath=fullfile(pwd(),'par');
srcfname=fullfile(parpath,'mtemsrc.path');
rcvfname=fullfile(parpath,'mtemrcv.path');

if exist(srcfname,'file')      
     fid=fopen(srcfname);
     sdc=textscan(fid,'%s','Delimiter','\n');
     sdc=sdc{1};
     fclose(fid);
     if isempty(sdc)
         sdc={''};
     end
else
    sdc={''};
end
if exist(rcvfname,'file')
    fid=fopen(rcvfname);
    rdc=textscan(fid,'%s','Delimiter','\n');
    rdc=rdc{1};
    fclose(fid);
    if isempty(rdc)
         rdc={''};
    end
else
    rdc='';
end

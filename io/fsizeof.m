% function bytes=fsizeof(filename)
% author: Ainray
% date: 20151217
% bug-report: wwzhang0421@163.com
% introduciton: return the number of bytes for 'filename' filenameiable
% input:
%         filename, the filename
% output:
%            bytes, the number of bytes of 'filename'
function bytes=fsizeof(filename)
d=dir(filename);

% ---- 20190917
if(isempty(d))
    error([filename, ' does not exist']);
end
% -------

bytes=d.bytes;
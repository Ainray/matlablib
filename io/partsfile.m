function [fname,path,ext]=partsfile(fnamelist)
% author: ainray
% date : 20170813
% introduction:
%         return path, file name, and file name extension for specified file(s)
% call fileparts
% syntax: [path,fname,ext]=partsfile(fnamelist)
% 
if ~iscell(fnamelist)
    [path,fname,ext]=fileparts(fnamelist);
else
    N=numel(fnamelist);
    path=cell(N,1);
    fname=cell(N,1);
    ext=cell(N,1);
    for i=1:N
        [p1,p2,p3]=fileparts(fnamelist{i});
        path(i)={p1};
        fname(i)={p2};
        ext(i)={p3};
    end
end
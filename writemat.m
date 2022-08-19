function writemat(m,file,fmt)
% author: Ainray
% date: 20220816
% bug-report: wwzhang0421@163.com
% introduction: the matrix m is arragned as n*[], in most case,
%   it is the transpose of a matrix
% modify:
%      20220816, add note
n=size(m,1);
if nargin<3
    fmt=repmat('%12.8f ',1,n);
    fmt=[fmt,'\n'];
end
fid=fopen(file,'w');
fprintf(fid, fmt, m);
fclose(fid);
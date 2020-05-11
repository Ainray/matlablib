% function [head,data]=readts(filename,N,d2afactor)
% author: Ainray
% time  : 2015/7/26
% bug report: wwzhang0421@163.com
% information: read MTEM time series
% syntax: [head,data]=readts('1.dat');
%         [head,data]=readts('1.dat',1000);
%          
% input:
%       filename, file name to be read
%              N, the number of samples we want read, if it is large than
%                 the size of the file, just ommited.
%      d2afactor, the factor converting analog value into digital value,
%                 the default value is 5/2^32;
%  output:
%         head, data header
%         data, time sereis
%        
function [head,data]=readts(filename,N,d2afactor)
if nargin<2
    N=10^12;  % a large number, more than ususal memory
end
if nargin<3
    d2afactor=5/2^32;
end
head=readhead(filename);
fid=fopen(filename,'r');
fseek(fid,2048,'bof');
data=fread(fid,min(fsizeof(filename)/4,N),'int32');
data=data*d2afactor;
fclose(fid);
   
    
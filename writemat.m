function writemat(m,file,fmt)
% the matrix m is arragned as n*[], in most case,
% it is the transpose of a matrix
n=size(m,1);
if nargin<3
    fmt=repmat('%12.8f ',1,n);
    fmt=[fmt,'\n'];
end
fid=fopen(file,'w');
fprintf(fid,fmt,m);
fclose(fid);
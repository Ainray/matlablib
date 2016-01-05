%function state=cutbinary(infname,outfname,start,size,bufsize)
% author: Ainray
% date:2015/12/18
% modified: 2015/12/26
% bug-report:wwzhang0421@163.com
% introduction: convert two bytes into an unsigned 16-bit integer.
% 	input: 
%        infname, the original file name
%       outfname, the cutted file name
%          start, the start position mesured by bytes
%           size, number of bytes to be cutted
%		 bufsize, buffer size, the default size is 1 GB
%  output:
%          state, -1 indicate invalid start position

function state=cutbinary(infname,outfname,start,size,bufsize)
infid=fopen(infname,'r');
outfid=fopen(outfname,'w');
if nargin<5
	bufsize=1024*1024*1024;  % buffer: 1 GB    %20151226
end
state=fseek(infid,start,'bof'); % skip to the start position
if state==-1
	return;                     %2015/12/26, recommended by Dr. Luan
end

times=floor(size/bufsize);
for i=1:times
    buf=fread(infid,bufsize,'uint8');
    fwrite(outfid,buf,'uint8');
    if feof(infid) % reach the end
        fclose(infid);
        fclose(outfid);
        return;
    end
end

% the last block
buf=fread(infid,size-bufsize*times,'uint8');
fwrite(outfid,buf,'uint8');
fclose(infid);
fclose(outfid);

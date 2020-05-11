% function header=readhead(filename)
% author: Ainray
% time  : 2015/7/26
% bug report: wwzhang0421@163.com
% information: read header information of cutted data.
% input:
%       filename, file name to be read 
%  output:
%         header, data file header struct

function header=readhead(filename)

%0-31
fid=fopen(filename,'r');                               
%20190917
if(fid <0)
    error([filename, ' does not exist']);
end
%20160309
if fsizeof(filename)<2*1024 %2K header
    error([filename, ' is not a valid file because of incomplete header(<2K).\n']);
end
tmp.day=fread(fid,1,'int16');                       %0-9
tmp.month=fread(fid,1,'int16');
tmp.year=fread(fid,1,'int16');
tmp.hour=fread(fid,1,'int16');
tmp.min=fread(fid,1,'int16');
tmp.workregion=fread(fid,20,'char');                %10-29
tmp.sec=fread(fid,1,'char');                        %30-31
tmp.rec_method=fread(fid,1,'int8');  %4 for MTEM

% 	//32-71
tmp.standy1=fread(fid,17,'char');                   %32-52
tmp.src_indx=fread(fid,1,'int32'); % source indx
tmp.sam_fr_indx=fread(fid,1,'int8');% -3-16K         %53-55
tmp.channel_num=fread(fid,1,'int8');
tmp.standby2=fread(fid,1,'int8');   
tmp.ablen=fread(fid,1,'int16');                %56-63
tmp.abc=fread(fid,1,'int16');
tmp.abstandby=fread(fid,1,'int16');
tmp.standy3=fread(fid,1,'int16');                  
tmp.current=fread(fid,1,'float32');                 %64-67
tmp.standby=fread(fid,1,'int32');                   %68-71

% 72-119
tmp.wave_form=fread(fid,1,'uint8'); %1-double       %72-91  
tmp.standby5=fread(fid,17,'char');
tmp.datatype=fread(fid,1,'uint8');  %1-src,%2-rcv  
tmp.iszero=fread(fid,1,'uint8');  % is zero
%1-512,2-1024,3-2048,4-4096
tmp.rec_num=fread(fid,1,'int16');   % record number %92-119
tmp.standy6=fread(fid,6,'char');
tmp.operator=fread(fid,20,'char');

%120-199
tmp.samples=fread(fid,1,'int32');  % number of samples
tmp.standby7=fread(fid,18,'char');  
tmp.meter_sn=fread(fid,1,'int16');
tmp.standby8=fread(fid,8,'char');
tmp.comment=fread(fid,48,'char');

%200-511
tmp.code=fread(fid,90,'int16');
% code[0]: ��1����
% code[1]: ��1��ԪƵ��
% code[2]: ��1������
% code[3]: ��1��������ӳٲɼ�����
% code[4]: ��1�ɼ�վͨ���ţ����ڵ�������ļ���Ч����ʾ���ļ�Ϊ�ɼ�վ�ĵڼ���ͨ����0-3��
tmp.standby0=fread(fid,132,'char');

% 64*24 =1536: 512-2047
for i=1:24
    tmp.chinfo(i).chtype=fread(fid,1,'uint8');
%     ͨ�����ʹ��룺
%     2- EX
%     5- HY
%     6- HZ
    tmp.chinfo(i).standby0=fread(fid,1,'char');
    tmp.chinfo(i).gain=fread(fid,1,'int8');
% ͨ���������:
% -2:1/4��  -1:1/2��  1:1��   2:2��  
% 4:4��  8:8��  16:16�� 32:32��
    tmp.chinfo(i).stn=fread(fid,1,'int8');
    tmp.chinfo(i).sndpnum=fread(fid,1,'int16');
    tmp.chinfo(i).lineno=fread(fid,1,'int16');
    tmp.chinfo(i).standby1=fread(fid,12,'char');
    tmp.chinfo(i).x=fread(fid,1,'float32');
    tmp.chinfo(i).y=fread(fid,1,'float32');
    tmp.chinfo(i).z=fread(fid,1,'float32');
    tmp.chinfo(i).lsb=fread(fid,1,'float32'); %ģ��ת��ֵLSB��΢��
    tmp.chinfo(i).standby2=fread(fid,28,'char');
end
header=tmp;
fclose(fid);
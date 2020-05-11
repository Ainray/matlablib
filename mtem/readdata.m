% function [src,rcv,meta]=readdata(srt,srcch,fs)
% atuthor: Ainray
% date: 20160311
% bug-report: wwzhang0421@163.com
% information: read data, based on s-r pair table
%      syntax: 	[src,rcv,meta]=readdata(srt,0);
%			   	[src,rcv,meta]=readdata(srt,2);
%			   	[src,rcv,meta]=readdata(srt,1375);
%               [data,meta]=readata(fname);
%    input:
%         srt, source-receiver pair table, N*7 matrix, the fisrt column is record 
%              number, the second cloumn is source data file name, the third column
%              is receiver data file name
%       srcch, source data channel number,0 for Hall sensor, 2 for voltage,
%              otherwize, indicating source postion, for theorical source data
%           fs, the sampling rate
%    d2afactor, digtal-to-analog factor 5/2^32   
%  output: 
%          src, the source data, if it is a matrix, by columns
%          rcv, the receiver data, if it is a matrix, by columns
%         meta, meta information about data 
%               member: 
%           srcpos, source position
%           rcvpos, receiver position
%           recnum, recording number
%              cmp, the middle-point position, (srcpos+rcvpos)/2
%           offset, the offset, srcpos-rcvpos   
%             code, input current parameter, refer to readhead
%              npp, number of samples per period
%             ncpp, number of PRBS chips per period
%            rcvsn,	receiver meter sn
%            rcvch, receiver meter channel 
%               fs, sampling rate
%                       
%                   (reserved)
%         srcbplen, source bipole length
%         rcvbplen, receiver bipole length
%     See also, decmain, readts, readhead, srmatch
function [src,rcv,meta]=readdata(srt,srcch,fs)
if ~iscell(srt)
    warndlg('invalid input');
end
if nargin>1
    if nargin<3
        fs=16000; %16K
    end
    N=size(srt,1); % the row of table
    if N>5 %very large,only read the first 5 files
       N=5;
    end
    if length(srcch)==1
        srcch=repmat(srcch,N,1);
    end
    meta=[];
    for i=1:N
        recnum=str2double(srt{i,1}); % record number
        filesrc=srt{i,2}; % source number
        filercv=srt{i,3}; % receiver number
        if exist(filercv,'file')  % read receiver data
            [headrcv,rcvtmp]=readts(filercv);  
        else
            error([filercv, ' does not exist.\n']);
        end 
        switch(srcch(i))
        case {0,2}   
           [headsrc,srctmp]=readts(filesrc);
           metatmp.srcpos=headsrc.chinfo(1).sndpnum;
           metatmp.rcvpos=headrcv.chinfo(1).sndpnum;
           metatmp.recnum=recnum;
           metatmp.cmp=(metatmp.srcpos+metatmp.rcvpos)/2;
           metatmp.offset=(metatmp.srcpos-metatmp.rcvpos);
           metatmp.code=headrcv.code;
           metatmp.ncpp=2^headrcv.code(1)-1;
           metatmp.npp=floor(metatmp.ncpp/metatmp.code(2)*fs);
           metatmp.rcvsn=headrcv.meter_sn;
           metatmp.rcvch=str2double(filercv(strfind(filercv,'_ch')+4));
           metatmp.fs=fs;
        otherwise  % use theorical source data, srcch set the source postition
            %generate the source in theory
            ipp=(max(rcvtmp)-min(rcvtmp))/2; 
            srctmp=prbs_src(1/headrcv.code(2),headrcv.code(1),headrcv.code(3),fs,0,ipp,0);
            % correct the time error,for cao si yao
            % not always in the case, it's the hardware problem of aquisition meter
            srctmp=srctmp(138:end);

            metatmp.srcpos=srcch;
            metatmp.rcvpos=headrcv.chinfo(1).sndpnum;
            metatmp.recnum=recnum;
            metatmp.cmp=(metatmp.srcpos+metatmp.rcvpos)/2;
            metatmp.offset=(metatmp.srcpos-metatmp.rcvpos);
            metatmp.code=headrcv.code;
            metatmp.ncpp=2^headrcv.code(1)-1;
            metatmp.npp=floor(metatmp.ncpp/metatmp.code(2)*fs);
            metatmp.rcvsn=headrcv.meter_sn;
            metatmp.rcvch=filercv(strfind(filercv,'_ch')+4);
            metatmp.fs=fs;
        end
        meta=[meta,metatmp];
        rcv(:,i)=rcvtmp;
        if srcch==0
                srctmp=srctmp*10;  % hall sensor, 50A/5V
        end
        src(:,i)=srctmp;  
    end
else % not matched, useful for receiver data comparision
    for i=1:numel(srt)
        if ~exist(srt{i},'file')
            warndlg('invalid file name');
            return;
        end
     [~,src(:,i)]=readts(srt{i});
     rcv=[];
     meta=[];
    end
end
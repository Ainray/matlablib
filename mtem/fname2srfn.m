function srfn=fname2srfn(fname,type)
% function sn=fname2sn(fname)
% author: Ainray
% date: 20170614
% email: wwzhang0421@163.com
% introduction: extract serial number from file name
%  input:
%        fname, cell of data file list
%         type, 0, all
%               1, sn
%               2, rn
%               3, fre
%               4, name
%        flag, the default is 0, if 1, supressing waitbar
%  output:
%        srfn, {sn rn fre} for type 0
%              {sn}        for type 1
%              {rn}        for type 2
%              {fre}       for type 3
%              {fname}     for type 4
%           sn, array of serial number of receivers
%           rn, array of record number
%          fre, array of frequences


if nargin<2
    type=1;
end
% if nargin<3
%     flag=0;
% end
% if type==0
%     srfn=zeros(N,3);
% end
% if flag==0
%     w=warning('off','all');
%     hw=waitbar(0,'Loading data');
% end
[~,r1k]=strfindindx(fname,'C\w*ST\w*_ch\w*');
% fname=fname(r1i);r1k=r1k(r1i);N=numel(fname);srfn=zeros(N,1);
[~,r2k]=strfindindx(fname,'ST\w*_ch\w*');
[~,r3k]=strfindindx(fname,'\.dat');
switch type
    case 1
        srfn=extractBetween(fname,r2k+2,r2k+5);
    case 2
        srfn=extractBetween(fname,r1k+1,r2k-1);
    case 3
        srfn=extractBetween(fname,r2k+12,r3k-1);
    case 4
        srfn=extractBetween(fname,r1k,r3k-1);
    case 0
        srfn=extractBetween(fname,r2k+2,r2k+5);
        srfn(:,2)=extractBetween(fname,r1k+1,r2k-1);
        srfn(:,3)=extractBetween(fname,r2k+12,r3k-1);
        srfn(:,4)=extractBetween(fname,r1k,r3k-1);
    otherwise
end
% srfn=str2double(srfn);
% for i=1:N   
% %     filename=fname{i};
%     % if ~exist(filename,'file')
%     %     disp(['File: ',filename,' does not exist']);
%     % end
%     if flag==0
%         waitbar(i/N,hw,'Loading data');
%     end
% %      r1=regexpi(filename,'C\w*ST\w*_ch\w*');
% %      file=filename(r1:end);
% %      r2=regexpi(file,'ST\w*_ch\w*');
% %      r3=regexpi(file,'_ch\w*');
% %      r4=regexpi(file,'.dat');
%      switch type
%          case 1       
% %              srfn(i)=str2double(file(r2+2:r3-1));
%          case 2
%              srfn(i)=str2double(file(2:r2-1));	
%          case 3
%              srfn(i)=str2double(file(r3+6:r4-1));
%          case 0
% %              srfn(i,1)=str2double(file(r2+2:r3-1));
% %              srfn(i,2)=str2double(file(2:r2-1));	
% %              srfn(i,3)=str2double(file(r3+6:r4-1));
%                srfn(i,2)=str2double(fname{i}(r1k(i)+1:r2k(i)-1));
%                srfn(i,1)=str2double(fname{i}(r2k(i)+(2:5)));
%                srfn(i,3)=str2double(fname{i}(r2k(i)+12:r3k(i)-1));
%          otherwise
%      end
% end
% if flag==0
%     delete(hw);
%     warning(w);
% end
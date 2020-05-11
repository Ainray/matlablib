function fname=listdata(sd,rd)
% syntax:  fname=listdata(srd)
%          fname=listdata(sd,rd)
% date: 20170614
% author: Ainray
% email: wwzhang0421@163.com
% introduction: list data file names in the directories of 'sd', and 'rd'
%  input:
%         sd, the directory where source data are in
%         rd, the directory where receiver data are in, two can be the same
%  output:
%         fname, cell of file list
%            sn, array of serial number of receivers
%            rn, array of record number
%           fre, array of frequences

if nargin<2
    rd=sd;
end
% warning('off','all');
% hw=waitbar(0,['Mtempreprocess is loading data from ', sd]);
if strcmpi(sd,rd)     % the same directory
        D=dir(sd);
        fnamelist=v2col({D.name});
        [i]=strfindindx(fnamelist,'C\w*ST\w*_ch\w*.dat'); % exclude . and ..
        ffnamelist=fnamelist(i);
        fname=fullfile(sd,ffnamelist);     
else  % different directories
        DS=dir(sd);
        fnamelist=v2col({DS.name});
        i=strfindindx(fnamelist,'C\w*ST\w*_ch\w*.dat');
        ffnamelist=fnamelist(i);
        fname=fullfile(sd,ffnamelist);
        DR=dir(rd);
        fnamelist=v2col({DR.name});
        i=strfindindx(fnamelist,'C\w*ST\w*_ch\w*.dat');
        ffnamelist=fnamelist(i);
        fname=[fname;fullfile(rd,ffnamelist)];
end
% fname=sort_nat(fname);
% delete(hw);
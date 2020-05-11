function [imptbl,impitems]=listimp(imp)
% author: Ainray
% date:20160329
% bug-report: wwzhang0421@163.com
% introduction: list EIRs
%  syntax: strtbl=listimp(imp)
%   input: 
%            imp, input
%  output:
%         imptbl, table of EIRs
%                 (src,rcv,fre)
%       impitems, cell of strings, have format:'index-src-rcv-fre'
%                 for example, 1-150-25-512
%                              2-150-75-512
%                                 ...

N=numel(imp);
imptbl=zeros(N,4);
impitems=cell(N,1);
cc=0;  % EIR conter
for i=1:N
    cc=cc+1;
    imptbl(cc,1)=cc; % index
    imptbl(cc,2)=imp(i).meta.srcpos;
    imptbl(cc,3)=imp(i).meta.rcvpos;
    imptbl(cc,4)=imp(i).meta.code(2);
    impitems(cc)={[num2str(imptbl(cc,1)),'-',num2str(imptbl(cc,2),'%.0f'),'-',...
        num2str(imptbl(cc,3),'%.0f'),'-',num2str(imptbl(cc,4),'%.0f')]};   
end

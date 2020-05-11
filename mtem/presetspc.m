function spc=presetspc(fname)
% function spc=presetspc(fname)
% author: Ainray
% date: 20170615
% email:wwzhang0421@163.com
% introduction: pre determine the space from data files
%         input:
%             fname, cell array of data files
%         output:
%               spc, spacing between two adjoint sounding points
N=numel(fname);
if N==0
    spc=0;
else
    rcv=zeros(min(N,10),1);
    for i=1:min(N,10)
        hx=readhead(fname{i});
        rcv(i)=hx.chinfo(1).sndpnum;
    end
    spc=unique(min(diff(sort(rcv))));
end    

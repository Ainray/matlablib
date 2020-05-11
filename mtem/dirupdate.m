function dc=dirupdate(dc,cd)
% function dirs=dirupdate(dirs,cdir)
%         sdc=dirupdate(sdc,csd)
%         rdc=dirupdate(rdc,crd)
% author: ainray
% date: 20170615
% email: wwzhang0421@163.com
% introduction: update directory list
%   input:
%          sdc, cell array of old directories where source data may be in
%          rdc, cell array of old directories where receiver data may be in
%          csd, current directory where source data may be in
%          crd, current directory where receiver data may be in
%   output: 
%          sdc, cell array of updated directories where source data may be in
%          rdc, cell array of updated directories where receiver data may be in
%   See also dirread, dirwrite
% if nargin<4
%     crd=csd;
% end

N=numel(dc);
id=strfindindx(dc,cd,1);
if isempty(id)% add new items, at most 100
        dc(2:min(N+1,100))=dc(1:min(N,99));
        dc(1)={cd};
else
     dc([1,id])=dc([id,1]);
end
lia=ismember(dc,'');
dc=dc(lia==0);
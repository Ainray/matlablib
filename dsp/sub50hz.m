function g=sub50hz(g,npp,np)
% g=sub50hz(g, 320, 3)
% author: Ainray
% date: 201670619
% email: wwzhang0421@163.com
% introduction: reduce 50Hz and its hormonics by substraction signal to be reduced 
% modify:
%   20210922, in old version, the tailing is used to as noise directly,
%       which limit its usage only for sample rate is integer multiple of 50Hz
%
%             in this version, the noise is estmated from tailing data by LS

N=length(npp);
Ng=length(g);
for i=1:N
    L=npp(i)*np(i);
    n=g(Ng-L+1:Ng);
    n0=reshape(n,npp,[]);    %50Hz
    n0=mean(n0,2);
    nn=cover(n0,g);
    g=g-nn;
end

%     n1=reshape(n,125,[]);    %4-period 512Hz signal
%     n1=mean(n1,2);
%     nn1=cover(n1,g);
%     g=g-nn1;

% n=g(lim);
% n0=reshape(n,320,[]);
% n0=mean(n0,2);
% N=numel(g)/(320);
% nn=repmat(n0,N,1);
% g=g-nn;
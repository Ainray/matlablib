function [prn,pr]=peakpeak(x,N,NN,fig)
% author: Ainray
% date: 20170526
% email: wwzhang0421@163.com
% introduction: find peaks of time series, especially for periodal peaks
%  input:
%         x, input signal
%         N, approximate number samples between peaks
%        NN, the up bound of number of extrema to be considered
if nargin<4
    fig=0;
end
[~,rn]=sort(x,'descend');
nnn=min(NN,length(x)); % number of large values to be considered
rn=rn(1:nnn);          % only 0.01% maximums are considered
rn=sort(rn);
% divide larger nubmer into group
rnd=diff(rn);
gb=find(abs(rnd)>N);% group boundary
gb=[0;gb];
prn=zeros(length(gb)-1,1);
pr=zeros(length(gb)-1,1);
for i=1:length(gb)-1 % find real maximum for per group
    [mr,mn]=max(x(rn(gb(i)+1:gb(i+1))));
    prn(i)=rn(gb(i)+mn);
    pr(i)=mr;
end
if fig==1
    plot(x,'k','linewidth',1.5);
    hold on;
    plot(prn,pr,'o','Markersize',10,'MarkerEdgeColor','k','MarkerFaceColor','k');
end



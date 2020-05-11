function [tpn,pv]=gettpn(g,fig)
% author: Ainray
% date: 20160319
% bug-report:wwzhang0421@163.com
% information: automatically identification of peak values and its correspoinding
%              time (samples)
% input:
%          g, the input signal
% output:
%        tpn, the time (samples)   
if nargin<2
    fig=0;
end
[mms,fmax]=mtem_peak(g); 
 if fmax==1 
     tpn=mms(2);
 elseif fmax==2
    tpn=mms(2);
elseif fmax==6
    tpn=mms(2);
elseif fmax==3
    tpn=mms(3);
elseif fmax==4
    tpn=mms(4);
elseif fmax==5
    tpn=mms(4);
end   
pv=g(tpn);

if fig==1
    % plot here
    plot(g,'k','linewidth',1.5);
    hold on;
    plot(tpn,pv,'ro','Markersize',20,'MarkerEdgeColor','r');
end
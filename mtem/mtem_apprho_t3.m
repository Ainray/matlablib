function [ps]=mtem_apprho_t3(g,tao,r)
% if nargin<4
%     ts=1e-5;  %10 us
% end
% tp=mtem_tpeaktime(g,t,0,ts);
% tao=t/tp;
ps=real((g*r^5./(5.649*10^6*exp(-5/2./tao).*tao.^(-2.5))).^(1/2));
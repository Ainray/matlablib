function [tp,pv]=mtem_tpeak(g,fs,fig,ts)
% author: ainray
% email: wwzhang0421@163.com
% introduction: get peak time based on impulse curve g.
% parameter:
%     input:
%       g, impulse
%       fs, sampling frequency
%       ts, expected time error
%      output:
%        tp, return peak time
if nargin<3
    fig=0;
end
if nargin<4
    ts=1e-5;  % 10us
end
fs0=1/ts;
[tpn,pv]=gettpn(g); 
if fs0>fs
      x0=max(1,tpn-10):tpn+10;
      y0=g(max(1,tpn-10):tpn+10);
      nx=floor(fs0/fs*(length(x0)));
      x=linspace((x0(1)-1)/fs,(x0(end)-1)/fs,nx);
      y=interp1((x0-1)/fs,y0,x,'spline');
      [~,m]=max(y);
      tp=x(m);
      pv=y(m);
else
    tp=tpn/fs;
end
if fig==1
    plot(time_vector(g,fs),g,'k');
    hold on
    plot(tp,pv,'ro');
end

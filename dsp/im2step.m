% function s=im2step(h,dt)
% author:Ainray
% date:20160311
% bug-report: wwzhang0421@163.com
% information: generate the integral step response from impulse reponse
%       input: 
%           h, the impulse reponse
%          dt, the sampling interval, the default value is one
%      output:
%           s, the step response     

function s=im2step(h,dt)
if nargin<dt
    dt=1;  % the default sampling interval is set to 1
end
s=cumsum(h);
s=s*dt;
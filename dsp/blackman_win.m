% function h=blackman_win(N)
% author: Ainray
% date: 20151021
% bug report: wwzhang0421@163.com
% introduction: generate blackman window, c.f.: Smith S. W., 1997, The scientist and 
%       engineer's guide to digital signal processing[2nd], P300.
% input:
%       N, window size,assuming odd number of points
% output: 
%      h, the window samples
function h=blackman_win(N)
while(mod(N,2)~=1)
    N=input('Warning: window length must be odd');
end
h=0.42-0.5*cos(2*pi*[0:N-1]'/(N-1))+0.08*cos(4*pi*[0:N-1]'/(N-1));
% function h=hamming_win(N)
% author: Ainray
% date: 20151021
% bug report: wwzhang0421@163.com
% introduction: generate hamming window, c.f.: Smith S. W., 1997, The scientist and 
%       engineer's guide to digital signal processing[2nd], P300.
% input:
%       N, window size
% output: 
%      h, the window samples
function h=hamming_win(N)
while(mod(N,2)~=1)
    N=input('window length must be odd');
end
h=0.54-0.46*cos(2*pi*[0:N-1]'/(N-1));
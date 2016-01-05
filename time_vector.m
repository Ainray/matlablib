% function t_v=time_vector(x,fs,start)
% author: Ainray
% date: 22015/10/28
% bug report: wwzhang0421@163.com
% introduction: generating time abscissa for data
% reference:
%      [1] Pesce K. A., 2010, Comparison of receiver function deconvolution techniques.
% input:
%       x, the data
%      fs, the sampling frequency, the default value is 1.
%   start, the time start point
function t_v=time_vector(x,fs,start)
if nargin<2
    fs=1;
end
if nargin<3
    start=0;            % time start
end
len=length(x);   % the data length
ts=1/fs;         % sampling spacing
t_final=ts*(len-1); % time end
t_v=linspace(0,t_final,len)';  % time abscissa
t_v=t_v+start;  % correct time start
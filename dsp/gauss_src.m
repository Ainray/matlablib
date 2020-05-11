%function [gs t_s]=gauss_src(N,fs,alpha,mui)
% author: Ainray
% date: 2015/09/14
% modified: 2015/4/16,2015/7/28
% bug report: wwzhang0421@163.com
% input:
%              N, the number of source wavelet samples
%             fs, the sampling rate
%          alpha, a factor control the shape,default alpha=5, with
%                 -108.6dB attenuation at the end: exp(-0.5*([-N/2:N/2]/(N/2)
%            mui, mean
% output:
%             gs, the gaussian source wavelet
%            t_s, the time indices
function[gs,t_s]=gauss_src(N,fs,alpha,mui)
if nargin<2
    fs=1;
end
if nargin<3
    alpha=5;
end
if nargin<4
    mui=0;
end
gs=gausswin(N,alpha);
t_s=time_vector(gs,fs)+mui/fs-(floor((N+1)/2)-1)/fs;



function [s, n] = dsp_noise_sub50hz(x, index, w)
% [s, n] = dsp_noise_sub50hz(x, index, 50/fs)
% [s, n] = dsp_noise_sub50hz(x, index, [50,100]/fs)
% author: Ainray
% date: 201670619
% email: wwzhang0421@163.com
% introduction: reduce 50Hz and its hormonics by substraction signal to be reduced 
% modify:
%   20210922, in old version, the tailing is used to as noise directly,
%       which limit its usage only for sample rate is integer multiple of 50Hz
%
%             in this version, the noise is estmated from tailing data by LS
%       also change funciton name sub50Hz into dsp_noise_sub50Hz
%       index, must has length of integer multiple of period of 50Hz nosie

[~, n0] = dsp_noise_project(x(index), w);
n = cover(n0,x, index(1));
s = x-n;

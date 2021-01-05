% function [g,t_s]=analyticimpulse(ps,offset,fs,N,time,IsBasedOnStep)
% author: Ainray
% time  : 2020/12/12
% bug report: wwzhang0421@163.com
% information: estimate the theorical earth impulse, estimate the
%              transmitting and receving time.
% c.f.s: 'multitransient eletromagnetic demonstraion survey in Frane',
%              appendex D, Geophysics, Vol 72, NO. 4, July-August-2007.
% input:
%      ps, the estimated background restivity,if we want to estimated the 
%          recevier time (returned by 'tz'), we shoud let 'ps' as small
%  offset, the distance between receiver and source, that can be a vector
%          for multiple traces
%      fs, sampling frequency
%       N, optinal specify the sample points
%    time, optional. it specify the time points in interest, it we do not
%          provide it , the function generate it automatically.
% IsBasedOnStep, whether differentiating the step response, the default is 0
%  output:
%          g, the earth impulse values, supporting muliple traces
%         ts, when we provide the 'time', just ignore it. Otherwise, it 
%             returned time sereis when the earth impulse values are
%             evalueated.
function [g,ts]=analyticimpulse_centerloop(ps,fs,N,a)
ts=time_vector(zeros(N,1),fs);
mu0 = 3*pi*1e-7;
theta = 0.5*sqrt(mu0/ps./ts);
g = ps/mu0/a^3*(3*erf(theta*a)-2/sqrt(pi)*theta*a.*(3+2*theta.*theta*a*a).*exp(-theta.*theta*a*a));

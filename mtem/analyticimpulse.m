% function [g,t_s]=analyticimpulse(ps,offset,fs,N,time,IsBasedOnStep)
% author: Ainray
% time  : 2014/11/24
% modified:
%         2020/12/22, ainray, remove IsBaedOnStep parameter; 
%          
% bug report: wwzhang0421@163.com
% information: estimate the theorical earth impulse, estimate the
%              transmitting and receving time.
%    How many samples are returned?
%          case 1, N specify the number of samples explicitly;
%          case 2, time specify the sampling time explicitly;
%          case 3, if both N and time are not provided, the samples are estimated automatically
%
% c.f.s: 'multitransient eletromagnetic demonstraion survey in Frane',
%              appendex D, Geophysics, Vol 72, NO. 4, July-August-2007.
% input:
%      ps, the estimated background restivity,if we want to estimated the 
%          recevier time (returned by 't_s'), we shoud let 'ps' as small
%  offset, the distance between receiver and source, that can be a vector
%          for multiple traces
%      fs, sampling frequency
%      iv, initial value, zero to suppress the sigularity
%       N, optinal specify the sample points
%    time, optional. it specify the time points in interest, if we do not
%          provide it , the function generate it automatically.   
%  output:
%          g, the earth impulse values, supporting muliple traces
%        t_s, when we provide the 'time', just ignore it. Otherwise, it 
%             returned time sereis when the earth impulse values are
%             evalueated.
function [g, t_s]=analyticimpulse(ps,offset,fs,iv,N,time)
narginchk(3,6);
if nargin<4
    iv=0;
end
if nargin<5 % the sampling time is estimated automatically
    tm=0.1*3.14159265358979*4*1e-7*max(offset)^2/ps; % peak time, tm=mui*offset*offset/ps;
    tz=30*tm;
    time=(0:1/fs:tz)';
end
if nargin==5
    time=time_vector(zeros(N,1),fs);
end

t_s=time;

nr=length(offset);
nt=length(t_s);
g=zeros(nt,nr);
 
 for i=1:nr %trace               
	g(:,i)=(4*pi*1e-7)^1.5/8/pi^1.5/sqrt(ps)*exp(-pi*1e-7*offset(i)^2/ps./t_s(:,min(size(t_s,2),i)))...
        .*t_s(:,min(size(t_s,2),i)).^(-2.5);   
    if time(1) <=eps
        t_s(1)=0;
        if iv ~= 0
            iv = ps/offset(i)^3/pi;  %set the initial value
        end
        g(1, i)= iv;
    end
 end

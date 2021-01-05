% function [s,t_s]=analyticstep(ps,offset,fs,time)
% author: Ainray
% time  : 2014/11/24
% bug report: wwzhang0421@163.com
% information: estimate the theorical earth step response, estimate the
%              transmitting and receving time.
% c.f.s: 'multitransient eletromagnetic demonstraion survey in Frane',
%              appendex D, Geophysics, Vol 72, NO. 4, July-August-2007.
% input:
%      ps, the estimated background restivity,if we want to estimated the 
%          recevier time (returned by 'tz'), we shoud let 'ps' as small
%  offset, the distance between receiver and source, that can be a vector
%          for multiple traces
%      fs, sampling frequency
%   time,  optional. it specify the time points in interest, it we do not
%          provide it , the function generate it automatically.
%  output:
%          s, the earth impulse values, supporting muliple traces        
%        t_s, when we provide the 'time', just ignore it. Otherwise, it 
%             returned time sereis when the earth impulse values are
%             evalueated.
function [s,t_s]=analyticstep(ps,offset,fs,time)
if nargin<4
    tm=0.1*3.14159265358979*4*1e-7*max(offset)^2/ps; % peak time, tm=mui*offset*offset/ps;
    tz=30*tm;
    time=(0:1/fs:tz)';
end
t_s=time;t_s(1)=0;
nr=length(offset);
pi=3.14159265358979;
% g(tao)=tao^(-5/2)*exp(-5/2/tao), where tao is t/t_peak
% when tao is 20, the value over the maximum is less than 0.05%

 nt=length(t_s);
 g=zeros(nt,nr);
    
 for i=1:nr %trace  
         c=(4*pi*1e-7/ps./t_s).^0.5;
         s(:,i)=0.5*ps/pi/offset(i)^3*( 2-erf(0.5*offset(i)*c)+offset(i)*c/sqrt(pi).*...
             exp(-pi*1e-7*offset(i)^2/ps./t_s));
         s(1,i)=0.5*ps/pi/offset(i)^3;t_s(1)=0;
 end
 
 

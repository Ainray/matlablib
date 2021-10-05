function [s,t_s]=analyticstep(ps,offset,fs,time)
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

t_s=time;t_s(1)= 0;
nr=length(offset);

pi=3.14159265358979;
mu = 4*pi*1e-7;

nt=length(t_s);
s=zeros(nt,nr);

c = 0.5*sqrt(mu/ps/t);
z = 0; % surface
 for i=1:nr %trace  
         s(:,i)=0.25/pi/offset(i)^2*( 2/sqrt(pi)*c*r.*exp(-c.*c*r(i)*r(i))+erfc(c*r(i)))*
             exp(-pi*1e-7*offset(i)^2/ps./t_s));
         s(1,i)=0.5*ps/pi/offset(i)^3;t_s(1)=0;
 end
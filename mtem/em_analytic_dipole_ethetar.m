function [s,t_s]=em_analytic_dipole_ethetar(ps, offset, time)
% input:
%      ps, the estimated background restivity,if we want to estimated the 
%          recevier time (returned by 'tz'), we shoud let 'ps' as small
%  offset, the distance between receiver and source, that can be a vector
%          for multiple traces
%   time,  optional. it specify the time points in interest, it we do not
%          provide it , the function generate it automatically.
%
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
s=zeros(nt,nr*2); %[erho ez]
 for i=1:nr %trace 
        %e at z = 0 surface in cylindral coordinate
        c = 0.5*sqrt(mu/ps./t_s);
        % e_rho
        %s(:,i) = 0.25*ps/pi/offset(i)^3 * ((4/sqrt(pi)*c.^3*offset(i)^3 + 6/sqrt(pi)*c*offset(i)).*exp(-c.*c*offset(i)*offset(i))+3*erfc(c*offset(i))); 
        s(:,i) = 0.25*ps/pi/offset(i)^3 * ((4/sqrt(pi)*c.^3*offset(i)^3 + 6/sqrt(pi)*c*offset(i)).*exp(-c.*c*offset(i)*offset(i))+3*erfc(c*offset(i))); 
        s(:,i) = 0.25*ps/pi/offset(i)^3; t_s(1)=0;
        % e_z
        s(:,i+nr) = 0.25*ps/pi/offset(i)^3 *(4/sqrt(pi)*c.^3*offset(i)^3.*exp(-c.*c*offset(i)*offset(i)) - (2/sqrt(pi)*c*offset(i).*exp(-c.*c*offset(i)*offset(i)) + erfc(c*offset(i)))); 
        s(:,i) = 0.25*ps/pi/offset(i)^3; t_s(1)=0;
 end
% function [g,t_s]=analyticimpulse(ps,offset,fs,time,IsBasedOnStep)
% author: Ainray
% time  : 2014/11/24
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
%    time,  optional. it specify the time points in interest, it we do not
%          provide it , the function generate it automatically.
% IsBasedOnStep, whether differentiating the step response, the default is 0
%  output:
%          g, the earth impulse values, supporting muliple traces
%        t_s, when we provide the 'time', just ignore it. Otherwise, it 
%             returned time sereis when the earth impulse values are
%             evalueated.
function [g,t_s]=analyticimpulse(ps,offset,fs,time,IsBasedOnStep)

if nargin<4
    tm=0.1*3.14159265358979*4*1e-7*max(offset)^2/ps; % peak time, tm=mui*offset*offset/ps;
    tz=20*tm;
    time=1/fs:1/fs:tz;
end
if nargin<5
    IsBasedOnStep=0;
end
t_s=time;t_s(1)=eps;
nr=length(offset);

% g(tao)=tao^(-5/2)*exp(-5/2/tao), where tao is t/t_peak
% when tao is 20, the value over the maximum is less than 0.05%

 nt=length(t_s);
 g=zeros(nt,nr);
 
 
 for i=1:nr %trace   
         if(IsBasedOnStep==0)             
            g(:,i)=(4*pi*1e-7)^1.5/8/pi^1.5/sqrt(ps)*exp(-pi*1e-7*offset(i)^2/ps./t_s)...
            .*t_s.^(-2.5);
         else
             [s,t_sr]=analyticstep(ps,offset(i),fs,t_s);
             s_diff=(s(1:end-1)-s(2:end))./(t_sr(1:end-1)-t_sr(2:end));
             g(:,i)=[s_diff;s_diff(end)];
         end
         g(1,i)=0;t_s(1)=0;  %set the initial value
 end
  
% if( IsBasedOnStep~=0 && nr==1)
%        figure;
%        tm_i=find(t_s==tm);
%        end_=min(tm_i*10,nt);
%        subplot(2,1,1);plot( t_s(1:end_),g(1:end_) );
%        hold on;plot( t_s(1:end_),g(1:end_),'r.');
%        plot([tm,tm],[0,gm],'k');
%        text(tm*1.5,gm*0.95,['(',num2str(tm),',',num2str(gm),')']);
%        title('Earth impulse response of homogeneous half space');
%        xlabel('Time (s)');ylabel('Earth impulse response ({\Omega}/m^{2}/s)');
%        
%        subplot(2,1,2),loglog(t_s,g);hold on;
%        loglog(t_s,g,'r.');loglog([tm,tm],[eps,gm],'k');
%        
%        text(tm*1.1,gm*3,['(',num2str(tm),',',num2str(gm),')']); 
%        axis([tm/10 max(t_s) gm/1e6 gm*10]);
%        title('Earth impulse response of homogeneous half space');
%        xlabel('Time (s)');ylabel('Earth impulse response ({\Omega}/m^{2}/s)');
% end

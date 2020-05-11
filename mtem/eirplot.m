function eirplot(g,fs)
% author: Ainray
% date: 20170619
% emai: wwzhang0421@163.com
% introduction: plot impulse reponse
%        input:
%           g, imulse response
%          fs, sampling frequncey
if nargin<2
    fs=1;
end
N=length(g);
plot(time_vector(g,fs,1/fs),g,'k','linewidth',2);
set(gca,'fontname','times','fontsize',24,...
    'ticklength',[0.03 0.03],...
    'Linewidth',2,'box','off','xlim',[-25,N]/fs,'ylim',[-0.1,1.1]*max(g));
axis square;
if fs==1 % sample
    xlabel('Sample','fontsize',24);
else
    xlabel('Time(s)','fontsize',24);
end
ylabel('Amplitude(\Omega/m^2/s^2)','fontsize',24);
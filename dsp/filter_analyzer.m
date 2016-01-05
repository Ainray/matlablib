% fuction [step,fre]=filter_analyzer(impulse,fs)
% author: Ainray
% date: 20151021
% bug report: wwzhang0421@163.com
% introduction: visaulizing the time and frequency response 
% input:
%       impulse, impulse response, arragned by column.
%            fs, the analog sampling frequency, if obmitted, assuming 1.
% output: 
%         step, step response
%          fre, frequency response
function [step, amp]=filter_analyzer(impulse,fs,varargin)
if nargin<2
    fs=1;
end

[m,n]=size(impulse);
% len=length(impulse);
% impulse=v2col(impulse);

%step response
% for i=1:len
%     step(i)=sum(impulse(1:i));
% end
fftsize=max(2^nextpow2(m),4096*4);  %fft size
step=zeros(m,n);
amp=zeros(fftsize/2+1,n);

for i=1:n  % column-by-column
    tmp=imp2step(1,1,impulse(:,i)); % step response
    step(:,i)=v2col(tmp(1:m));  
    %normalization
    normalimp=impulse(:,i);%/sum(impulse(:,i));
    % frequency response
    fre=fft(normalimp,fftsize);
    fre=abs(fre);
    amp(:,i)=v2col(fre(1:fftsize/2+1));
end
%visuliztion
h=figure('NumberTitle','off','Name','Filter Analyzier');clf; 
t_s=time_vector(impulse,fs);
subplot(2,2,1);plot(t_s,impulse,'LineWidth',2);
hold on;
%plot([0:len-1],[impulse],'.');
set(gca,'xLim',[t_s(1),t_s(end)]);grid on;
xlabel('Sample number');ylabel('Amplitude');
title('a. Filter kernel'); 
if ~isempty(varargin)
    hl=legend(varargin{:},'Orientation','horizontal');legend('boxoff');
    pos=get(gca,'Position'); %graph
    posl=get(hl,'Position'); %legend itself
    set(hl,'Position',[0.52-posl(3)/2,pos(2)+pos(4)+posl(4)/2,posl(3),posl(4)]);
end
t_s=time_vector(step(:,1),fs);
subplot(2,2,3);plot(t_s,step,'LineWidth',2);
% hold on;%plot([0:len-1],step,'.');
set(gca,'xLim',[t_s(1),t_s(end)]);
grid on;
xlabel('Sample number');ylabel('Amplitude');
title('b. Step response');%legend(varargin{:});
%set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));

subplot(2,2,2);plot(time_vector(amp(:,1),fftsize/fs),amp,'LineWidth',2);
xlabel('Frequency');ylabel('Amplitude');
grid on;
%set(gca,'xLim',[0,0.5]);grid on;hold on;
title('c. Freqency response');%legend(varargin{:});
%set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));

subplot(2,2,4);plot(time_vector(amp(:,1),fftsize/fs),20*log10(amp),'LineWidth',2);
% hold on;
xlabel('Frequency');ylabel('Amplitude(dB)');%set(gca,'xLim',[0,0.5]);
grid on;%legend(varargin{:});
title('d. Freqency response(dB)');

% %visuliztion
% figure(11111111);clf;
% t_s=time_vector(impulse,fs);
% subplot(2,2,1);plot(t_s,impulse(:,i),'k','LineWidth',2);
% hold on;
%     
% %plot([0:len-1],[impulse],'.');
% set(gca,'xLim',[t_s(1),t_s(end)]);grid on;
% xlabel('Sample number');ylabel('Amplitude');
% title('a. Filter kernel');
% 
% t_s=time_vector(step(:,i),fs);
% subplot(2,2,3);plot(t_s,step(:,i),'k','LineWidth',2);
% % hold on;%plot([0:len-1],step,'.');
% set(gca,'xLim',[t_s(1),t_s(end)]);
% hold on;grid on;
% xlabel('Sample number');ylabel('Amplitude');
% title('b. Step response');
% %set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));
% 
% subplot(2,2,2);plot(time_vector(amp(:,i),fftsize/fs),amp(:,i),'k','LineWidth',2);
% xlabel('Frequency');ylabel('Amplitude');
% grid on;
% hold on;
% 
% %set(gca,'xLim',[0,0.5]);grid on;hold on;
% title('c. Freqency response');
% %set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));
% 
% subplot(2,2,4);plot(time_vector(amp(:,i),fftsize/fs),20*log10(amp(:,i)),'k','LineWidth',2);
% % hold on;
% xlabel('Frequency');ylabel('Amplitude(dB)');%set(gca,'xLim',[0,0.5]);
% grid on;
% hold on;
% title('d. Freqency response(dB)');

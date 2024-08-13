function [step, amp]=filter_analyzer(impulse,varargin)
% author: Ainray
% date: 20151021, 20160325
% bug report: wwzhang0421@163.com
% introduction: visaulizing the time and frequency response 
% example
%         filter_analyzer(h);
%         filter_analyzer([],'B',B,'A',A)
% input:
%       impulse, impulse response, arragned by column.
% 
%                (optional paramter-value pairs)----20160325
%            'Fs',1  the analog sampling frequency, if obmitted, assuming 1.
%     'BandWidth', numerical band width to be displayed
%             'B', filter coefficients
%             'A', filter coefficients
%          "Ylim", 
% output: 
%         step, step response
%          fre, frequency response

%---------20160325
p=inputParser;
addRequired(p,'impulse');
addOptional(p,'Fs',1,@(x) isscalar(x) && isnumeric(x));
addOptional(p,'BandWidth',[0,0.5], @(x) isvector(x) && numel(x)==2  && x(1)>=0 && x(1)<=0.5...
    && x(2)>=0 && x(2)<=0.5 && x(1)<x(2));
addOptional(p,'Ylim',[-80,0], @(x) isvector(x) && numel(x)==2);
addOptional(p,'YTick',-80:20:0, @(x) isvector(x));
addOptional(p,'B',[],@(x) iscell(x));
addOptional(p,'A',[],@(x) iscell(x));
addOptional(p,'sidelv',false,@(x) islogical(x));
parse(p,impulse,varargin{:});

fs=p.Results.Fs;
bw=p.Results.BandWidth;
B=p.Results.B;
A=p.Results.A;
sidelv=p.Results.sidelv;
ylim = p.Results.Ylim;
ytick = p.Results.YTick;
if isempty(impulse) && (isempty(A) || isempty(B))
    error('empty input');
end
% check coefs dimension
if numel(B)~=numel(A)
   error('Invalid filter coefficients: B and A must have the same dimension');
end
%----------------
[m,n]=size(impulse);
if m==0
    m=512; % empty
end
for i=1:numel(B)
    impulse(:,i+n)=impz(B{i},A{i},m);
end
if m==1 && n>0 % row vector
    impulse=impulse';   
end
if fs==1
    xlbl='Sample number';
    fxlbl='Frequency';
else
    xlbl='Time (s)';
    fxlbl='Frequency (Hz)';
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
% ph=zeros(fftsize/2+1,n);
% side lobe
sl=zeros(2,n);
for i=1:n  % column-by-column
%     tmp=imp2step(1,1,impulse(:,i)); % step response
%     step(:,i)=v2col(tmp(1:m));
    step(:,i)=im2step(impulse(:,i),1/fs);
    %normalization
%     normalimp=impulse(:,i)/sum(impulse(:,i));
    % frequency response
    fre=fft(impulse(:,i),fftsize);
    amp(:,i)=v2col(abs(fre(1:fftsize/2+1)));
    %normalization
    amp(:,i)=amp(:,i)/max(amp(:,i)); 
%     ph(:,i)=v2col(phasecalc(fre(1:fftsize/2+1)));
    % side-lobe attenuation relative main lobe
    maxmins{i}=mtem_peak(amp(:,i));
    tmp=maxmins{i};
    if length(tmp)>2
        [sl(1,i),id]=max(amp(tmp(2:end),i));
        sl(1,i)=20*log10(sl(1,i)/amp(1,i));
        sl(2,i)=tmp(id);
    end
end
% %visuliztion
h=figure('NumberTitle','off','Name','Filter Analyzier', 'Color',[1,1,1]);
clf; 
t_s=time_vector(impulse,fs);
subplot(2,2,1);plot(t_s,impulse,'LineWidth',2);
hold on;
%plot([0:len-1],[impulse],'.'); 
set(gca,'xLim',[t_s(1),t_s(end)]);grid on;
xlabel(xlbl);ylabel('Amplitude');
title('a. Filter kernel'); 
% if ~isempty(varargin)
%     hl=legend(varargin{:},'Orientation','horizontal');legend('boxoff');
%     pos=get(gca,'Position'); %graph
%     posl=get(hl,'Position'); %legend itself
%     set(hl,'Position',[0.52-posl(3)/2,pos(2)+pos(4)+posl(4)/2,posl(3),posl(4)]);
% end
t_s=time_vector(step(:,1),fs);
subplot(2,2,3);plot(t_s,step,'LineWidth',2);
% hold on;%plot([0:len-1],step,'.');
set(gca,'xLim',[t_s(1),t_s(end)]);%,'yLim',[0,1.001],'yTick',[0:0.1:1]
grid on;
xlabel(xlbl);ylabel('Amplitude');
title('b. Step response');%legend(varargin{:});
%set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));

subplot(2,2,2);
semilogx(time_vector(amp(:,1),fftsize/fs),amp,'LineWidth',2);
xlabel(fxlbl);ylabel('Amplitude');
grid on; 
% %20160308
% subplot(2,2,2);
% [AX,H1,H2]=plotyy(time_vector(amp(:,1),fftsize/fs),amp,...
%     time_vector(amp(:,1),fftsize/fs),ph);
% set(get(AX(1),'xLabel'),'String',fxlbl...
%     ,'FontName','Helvetica','FontUnits','points','FontSize',10,'Color','k');
% set(get(AX(1),'yLabel'),'String','Amplitude','FontName','Helvetica','FontUnits'...
%     ,'points','FontSize',10,'Color','k');
% set(get(AX(2),'yLabel'),'String','Phase','FontName','Helvetica','FontUnits','points',...
%     'FontSize',10,'Color','k');
% set(H1,'Color','r','LineWidth',2);
% set(H2,'Color','b','LineWidth',2);
% set(AX(1),'xLim',[0,0.5],'yLim',[0,1],'YColor','r','Ygrid','on');
% set(AX(2),'xLim',[0,0.5],'yLim',[-pi,pi],'YColor','b','Ygrid','on');%,'XDir','reverse','xTick',[],'xTickLabel',[]);
set(gca,'xLim',bw*fs,'yLim',[0,1],'yTick',[0:0.1:1]);
grid on;hold on;
title('c. Freqency response');%legend(varargin{:});
%set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));
ts=time_vector(amp(:,1),fftsize/fs);
subplot(2,2,4);
semilogx(ts,max(-200,20*log10(amp)),'LineWidth',2);
if sidelv==1 
    for i=1:n
        if length(maxmins{i})>2
        hold on;
        plot([0,fs/2],[sl(1,i),sl(1,i)],'--k','LineWidth',1.5);
        text(ts(max(sl(2,i)-100,1)),sl(1,i)+10,sprintf('%.2fdB',sl(1,i)),'FontSize',15);
        text(ts(max(sl(2,i)-100,1)),sl(1,i)+10,sprintf('%.2fdB',sl(1,i)),'FontSize',15);
        % tmp=maxmins{1};
        % % plot(ts(tmp(3:2:end)),20*log10(amp(tmp(3:2:end))),'--r');
        hold off;
        end
    end
end
set(gca,'xLim',bw*fs,'yLim',ylim,'yTick',ytick);
xlabel(fxlbl);ylabel('Amplitude(dB)');%set(gca,'xLim',[0,0.5]);
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
% xlabel(xlbl);ylabel('Amplitude');
% title('a. Filter kernel');
% 
% t_s=time_vector(step(:,i),fs);
% subplot(2,2,3);plot(t_s,step(:,i),'k','LineWidth',2);
% % hold on;%plot([0:len-1],step,'.');
% set(gca,'xLim',[t_s(1),t_s(end)]);
% hold on;grid on;
% xlabel(xlbl);ylabel('Amplitude');
% title('b. Step response');
% %set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));
% 
% subplot(2,2,2);plot(time_vector(amp(:,i),fftsize/fs),amp(:,i),'k','LineWidth',2);
% xlabel(fxlbl);ylabel('Amplitude');
% grid on;
% hold on;
% 
% %set(gca,'xLim',[0,0.5]);grid on;hold on;
% title('c. Freqency response');
% %set(gca,'ytick',[-0.2:0.2:1.2],'yticklabel',num2cell([-0.2:0.2:1.2]));
% 
% subplot(2,2,4);plot(time_vector(amp(:,i),fftsize/fs),20*log10(amp(:,i)),'k','LineWidth',2);
% % hold on;
% xlabel(fxlbl);ylabel('Amplitude(dB)');%set(gca,'xLim',[0,0.5]);
% grid on;
% hold on;
% title('d. Freqency response(dB)');

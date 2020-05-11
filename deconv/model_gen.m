% function [x,h,y,ny,code]=model_gen(model_id,fig)
% author: Ainray
% date: 2015/10/28
% modified: 20171201, more butiful pictures to be used in paper.
% bug report: wwzhang0421@163.com
% introduction: generating model data for test deconvolution algorithm.
% reference:
%      [1] Ziolkowski A.,2007, Multitransient electromagnetic demonstration survey in France
%      [2] Pesce K. A., 2010, Comparison of receiver function deconvolution techniques.
%      [3] Smith, Steven W., 1997, The Scientist and Engineeer's Guide to Digital Signal Processing  
% input:
%    model_id, the model id: 
%              model 1: source wavelet and receiver function, sampling rate: 100Hz
%              model 2: MTEM,source prbs: 7 order,sampling rate:16KHz
%              model 3: gamma ray deletor, sampling rate 1, refer to [3], pp.301-306
%         fig, whether plot figures or not
% output: 
%           x, the input
%           h, the impulse response of the system
%           y, the output
%          ny, the output contaminated by 20% gauassian noise
%        code, only valid for model 2, MTEM, the current coding information
function [x,h,y,ny,code]=model_gen(model_id,fig)
if nargin<2
    fig=0;
end
code =[];
% plot setting
% Defaults for this blog post
width = 6;     % Width in inches
height = 6;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 8;      % Fontsize
lw = 1;      % LineWidth
switch(model_id)
    case 1  % model 1
        fs=100;     % sampling rate
        duration=21;  % the duration
        N=floor(duration*fs);  % the number of the input samples

        % source wavelet
        x=gauss_src(101,fs,5,50);
        x=[x;zeros(N-101,1)];

        % impulse reponse
        h=zeros(N,1); % the receiver function, i.e., the system impulse reponse
        h(floor(5/21*N))=1; % reflection coeffcient of interface 1
        h(floor(18/21*N))=-0.4; % reflection coeffcient of interface 2

        %synthetic observation 
        y=fconv(x,h);
        ny=addnoise(y,20);

        %figure
        if fig
            figure(12345);
            pos = get(gcf, 'Position');
            set(gcf, 'Position', [pos(1) pos(2)-height*50 width*100, height*100]); %<- Set size
            set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

            subplot(2,2,1);plot(time_vector(x,fs),x,'k','LineWidth',lw);
            xlabel('Time (s)');ylabel('Amplitude');title('a. Source wavelet','FontSize', fsz);
            set(gca,'xLim',[0,duration],'yLim',[-0.2,1.2]);
            subplot(2,2,2);plot(time_vector(h,fs),h,'k','LineWidth',lw);
            xlabel('Time (s)');ylabel('Amplitude');title('b. Receiver function','FontSize', fsz);
            set(gca,'xLim',[0,duration],'yLim',[-0.6,1.2]);
            subplot(2,2,3);plot(time_vector(y,fs),y,'k','LineWidth',lw);
            xlabel('Time (s)');ylabel('Amplitude');title('c. Pure Observation','FontSize', fsz);
            set(gca,'xLim',[0,duration],'yLim',[-0.6,1.2]);
            subplot(2,2,4);plot(time_vector(ny,fs),ny,'k','LineWidth',lw);
            xlabel('Time (s)');ylabel('Amplitude');title('d. Contaminated Observation (20%)','FontSize', fsz);
            set(gca,'xLim',[0,duration],'yLim',[-0.6,1.2]);
        end
    case 2 % model 2
            figure(12345);
            pos = get(gcf, 'Position');
            set(gcf, 'Position', [pos(1) pos(2)-height*50 width*100, height*100]); %<- Set size
            set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
            fs=16000;t_ele=1/512;order=7;cycle=1;  % 7-order prbs, sampling frequency is 16000
            code(1)=order;code(2)=512;code(3)=cycle;
            % prbs source
            [x,tx,single_len]=prbs_src(t_ele,order,cycle,fs,1,1);

            % earth impulse in the homegeous earth
            ps=50; offset=1000;len=32000;
            time=time_vector(zeros(len,1),fs);
            [h,th]=analyticimpulse(ps,offset,fs,0,time);
            % [s]=analyticstep(ps,offset,fs,time);
            % synthetic response
             y=fconv(x,h);     
            %idiff=diff(x);
            %y=fconv(idiff,s); 
            ny=addnoise(y,20);
            % figure
            if fig
                figure(12345);
                subplot(2,2,1);
                plot(tx(1:single_len(1)),x(1:single_len(1)),'k','LineWidth',lw);
                xlabel('Time (s)');ylabel('Amplitude');title('a. 7-order PRBS source current');
                set(gca,'xLim',[0,tx(single_len(1))],'yLim',[-1.2,1.2]);
                subplot(2,2,2);semilogx(th,h,'k','LineWidth',lw);
                xlabel('Time (log10(s))');ylabel('Amplitude');title('b. The earth impulse ');
%                 set(gca,'xLim',[0,2]);
                xlim=min(single_len(1)*10,length(tx));
                subplot(2,2,3);plot(tx(1:xlim),y(1:xlim),'k','LineWidth',lw);
                xlabel('Time (s)');ylabel('Amplitude');title('c. Pure Observation');
                set(gca,'xLim',[0,tx(xlim)]);
                subplot(2,2,4);plot(tx(1:xlim),ny(1:xlim),'k','LineWidth',lw);
                xlabel('Time (s)');ylabel('Amplitude');title('d. Contaminated Observation (20%)','FontSize', fsz);
                set(gca,'xLim',[0,tx(xlim)]);      
            end
    case 3 % model 3
        x=zeros(1,450);x=x';
        x([41,101,191,202,280,375,385,395,420]-10)=1;
        h=[zeros(1,6),0.53,0.8,0.99,1,exp(-((0:40)+0.05)/8)];h=h';
        y=fconv(x,h);
        ny=addnoise(y,20);
        if fig
            figure(12345);
            pos = get(gcf, 'Position');
            set(gcf, 'Position', [pos(1) pos(2)-height*50 width*100, height*100]); %<- Set size
            set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
            subplot(2,2,1);
            plot(x,'k','LineWidth',lw); xlabel('Time (Sample)');ylabel('Amplitude');
            title('a. Random  arriving event of gramma rays');
            set(gca,'ylim',[-0.5,1.5]);
            subplot(2,2,2);
            plot(h,'k','LineWidth',lw);set(gca,'ylim',[-0.5,1.5]);
            xlabel('Time (Sample)');ylabel('Amplitude');
            title('b. impulse response of a gamma ray detector');
            subplot(2,2,3);
            plot(y,'k','LineWidth',lw);set(gca,'ylim',[-0.5,1.5]);
            xlabel('Time (Sample)');ylabel('Amplitude');title('c. Pure Observation');
            subplot(2,2,4);
            plot(ny,'k','LineWidth',lw);set(gca,'ylim',[-0.5,1.5]);
            xlabel('Time (Sample)');ylabel('Amplitude');
            title('d. Observation contaminated by 20% gaussian noise');
        end
end

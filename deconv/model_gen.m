% function [x,y]=model_gen(model_id,fig)
% author: Ainray
% date: 22015/10/28
% bug report: wwzhang0421@163.com
% introduction: generating model data for test deconvolution algorithm.
% reference:
%      [1] Ziolkowski A.,2007, Multitransient electromagnetic demonstration survey in France
%      [2] Pesce K. A., 2010, Comparison of receiver function deconvolution techniques.
% input:
%    model_id, the model id: 
%              model 1: source wavelet and receiver function, sampling rate: 100Hz
%              model 2: MTEM,source prbs: 7 order,sampling rate:16KHz
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
            figure(12345)
            subplot(2,2,1);plot(time_vector(x,fs),x,'k','LineWidth',2);
            xlabel('Time (s)');ylabel('Amplitude');title('a. Source wavelet');
            set(gca,'xLim',[0,duration],'yLim',[-0.2,1.2]);
            subplot(2,2,2);plot(time_vector(h,fs),h,'k','LineWidth',2);
            xlabel('Time (s)');ylabel('Amplitude');title('b. Receiver function');
            set(gca,'xLim',[0,duration],'yLim',[-0.6,1.2]);
            subplot(2,2,3);plot(time_vector(y,fs),y,'k','LineWidth',2);
            xlabel('Time (s)');ylabel('Amplitude');title('c. Pure Observation');
            set(gca,'xLim',[0,duration],'yLim',[-0.6,1.2]);
            subplot(2,2,4);plot(time_vector(ny,fs),ny,'k','LineWidth',2);
            xlabel('Time (s)');ylabel('Amplitude');title('d. Observation contaminated by 20% gaussian noise');
            set(gca,'xLim',[0,duration],'yLim',[-0.6,1.2]);
        end
    case 2 % model 2      
            fs=16000;t_ele=1/512;order=7;cycle=50;  % 7-order prbs, sampling frequency is 16000
            code(1)=order;code(2)=512;code(3)=cycle;
            % prbs source
            [x,tx,single_len]=prbs_src(t_ele,order,cycle,fs,1,1);

            % earth impulse in the homegeous earth
            ps=50; offset=1000;len=32000;
            time=time_vector(zeros(len,1),fs);
            [h,th]=analyticimpulse(ps,offset,fs,time);
            [s]=analyticstep(ps,offset,fs,time);
            % synthetic response
             y=fconv(x,h);     
            %idiff=diff(x);
            %y=fconv(idiff,s); 
            ny=addnoise(y,20);
            % figure
            if fig
                figure(12345);
                subplot(2,2,1);
                plot(tx(1:single_len(1)),x(1:single_len(1)));
                xlabel('Time (s)');ylabel('Amplitude');title('a. 7-order PRBS source current');
                set(gca,'xLim',[0,tx(single_len(1))],'yLim',[-1.2,1.2]);
                subplot(2,2,2);plot(th,h);
                xlabel('Time (s)');ylabel('Amplitude');title('b. The earth impulse ');
                xlim=single_len(1)*10;
                subplot(2,2,3);plot(tx(1:xlim),y(1:xlim));
                xlabel('Time (s)');ylabel('Amplitude');title('c. Pure Observation');
                set(gca,'xLim',[0,tx(xlim)]);
                subplot(2,2,4);plot(tx(1:xlim),ny(1:xlim));
                xlabel('Time (s)');ylabel('Amplitude');title('d. Observation contaminated by 20% gaussian noise');
                set(gca,'xLim',[0,tx(xlim)]);      
           end
end

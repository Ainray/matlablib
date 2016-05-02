function [ls,w]=esd(x,fs,varargin)
% author: Ainray
% date: 20160331
% bug report: wwzhang0421@163.com
% introduction: Spectral analysis based on FFT(DFT).
%
%           (optional parameter-value pairs)
%            Domain, 'F'/'T'          time domain (do not take DFT) or frequency 
%            Size,   4096             the DFT size
%       IsDensity,   false            whether normalized Linear Spectrum or not
%          Center,   'zero',    zero-center symmetric form by fftshift
%                    'Nyquist', symmetric at both sides of Nyquist freqency
%          Xscale,   linear           x axis scale
%          Yscale,   log              y axis scale
%            xlim*fs,   band width or time duration
%          Figure,   'ls', only Linear Spectrum dislayed
%                    'time', only the time domain signal itself
%                    'both',  them above 
%                    'none', no figures
p=inputParser;
addRequired(p,'x',@isnumeric);
addRequired(p,'fs',@(x) isnumeric(x) && isscalar(x));
addOptional(p,'Domain','F',@(x) strcmpi(x,'F') || strcmpi(x,'T'))
addOptional(p,'Size',4096, @(x) isnumeric(x) && isscalar(x));
addOptional(p,'IsDensity',false,@islogical);
addOptional(p,'Center','zero',@(x) any(validatestring(x,{'zero','Nyquist'})));
addOptional(p, 'Xscale', 'linear',@(x) any(validatestring(x,{'linear','log'})));
addOptional(p,'Yscale','log',@(x) any(validatestring(x,{'linear','log'})));
addOptional(p,'xlim',[0,0.5],@(x) isnumeric(x) && numel(x)==2 && x(1)>=-0.5 ...
    && x(1)<=0.5 && x(2)>=-0.5 &&x(1)<=0.5 && x(1)<=x(2));
addOptional(p,'Figure','ls',@(x) any(validatestring(x,{'ls','time','both','none'})));
parse(p,x,fs,varargin{:});

domain=p.Results.Domain;
fftsize=p.Results.Size;
isdensity=p.Results.IsDensity;
center=p.Results.Center;
xscale=p.Results.Xscale;
yscale=p.Results.Yscale;
xlim=p.Results.xlim;
figurekind=p.Results.Figure;

[m,n]=size(x);
if strcmpi(domain,'T')
    ls=x;
    w=time_vector(x(:,1),fs);
else
    fftsize=pow2(nextpow2(max(fftsize,m)));
    ls=zeros(fftsize,n);
    for i=1:n
        tmp=fft(x(:,i),fftsize);
        if strcmpi(center,'zero')
            tmp=fftshift(tmp);
            w=(-fftsize/2:fftsize/2-1)/fftsize*fs;
        else
            w=(0:fftsize-1)/fftsize*fs;
        end
        if isdensity
            tmp=ls/m;
        end
        ls(:,i)=tmp;
    end
end
% figure;
switch figurekind
    case 'none'
    case 'ls'
        figure;
        plot(w,abs(ls));
        set(gca,'xscale',xscale,'yscale',yscale,'xlim',xlim*fs);
        title('Energy Spectral Density of Input Series');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');
    case 'time'
        figure;
        plot(time_vector(x(:,1)),x);
        title('Input Series');
        xlabel('Time (s)');
        ylabel('Amplitude');
    case 'both'
        figure;
        subplot(2,1,1);
            plot(time_vector(x(:,1)),x);
            title('Input Series');
            xlabel('Time (s)');
            ylabel('Amplitude');
        subplot(2,1,2);
             plot(w,abs(ls));
        set(gca,'xscale',xscale,'yscale',yscale,'xlim',xlim*fs);
        title('Energy Spectral Density of Input Series');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');
end





% -------------------------------------------------obscured----------------------------
% % function [mx,f]=esd(x,fs,xlim*fs,varargin)
% % author: Ainray
% % date: 20151228
% % 
% % introduction: 
% %             : [ls,f]=esd(x,fs,xlim*fs), calculating PSD.
% %             : [ls,f]=esd(x,fs,xlim*fs,2), the same as above but simutaneously 
% %             :          painting origianl time series
% %             : [ls,f]=esd(x,f,xlim*fs,4), only calculating PSD without picture
% %             : [ls,f]=esd(x,f,xlim*fs,0), only painting original time series, 
% %             :          the last parameter can any number but 1,2,4.
% %             : [ls,f]=esd(x,f,xlim*fs,1,fftsize), specifying the size for DFT,
% %             :          if fftsize is more large than the length of input 
% %             :          time series, padding zeros.
% %             : [ls,f]=esd(x,f,xlim*fs,1,fftsize,1/0), if true, the DFT result is 
% %             :          normalized by the length of original time series
% %             : [ls,f]=esd(x,f,xlim*fs,fftsize,1/0,[1/0 1/0]), if true, the 
% %             :          scale is logrithmic
% %             : [ls,f]=esd(x,f,xlim*fs,fftsize,1/0,[1/0 1/0],'b'), the last parameter
% %             :          control the line color
% % input:
% %           x, time series
% %          fs, sampling freqency
% %        xlim*fs, the frequency band width
% %    varargin, the control parameters, in order
% % output: 
% %          mx, the Power Spectral Density of x
% %           f, the frequency sampling points  
% function [ls,f]=esd(x,fs,xlim*fs,varargin)
% std=size(varargin,2);  % control parameter number
% switch std
%     case 0   
%           fr=1;          % whether fft or not, 1 indicating fft
%           fft_size=0;    % fft size
%           s=0;           % whether normalized or not      
%           logflag=[0,0]; %loglog not
%           clr='b';  % line color
%     case 1
%           fr=varargin{1};          % whether fft or not, 1 indicating fft
%           fft_size=0;    % fft size
%           s=0;           % whether normalized or not      
%           logflag=[0,0]; %loglog not
%            clr='b';  % line color
%     case 2
%           fr=varargin{1};          % whether fft or not, 1 indicating fft
%           fft_size=varargin{2};    % fft size
%           s=0;           % whether normalized or not      
%           logflag=[0,0]; %loglog not
%            clr='b';  % line color
%     case 3
%           fr=varargin{1};          % whether fft or not, 1 indicating fft
%           fft_size=varargin{2};    % fft size
%           s=varargin{3};           % whether normalized or not      
%           logflag=[0,0]; %loglog not
%            clr='b';  % line color
%     case 4
%           fr=varargin{1};          % whether fft or not, 1 indicating fft
%           fft_size=varargin{2};    % fft size
%           s=varargin{3};           % whether normalized or not      
%           logflag=varargin{4}; %loglog not
%           clr='b';  % line color
%     case 5
%           fr=varargin{1};          % whether fft or not, 1 indicating fft
%           fft_size=varargin{2};    % fft size
%           s=varargin{3};           % whether normalized or not      
%           logflag=varargin{4}; %loglog not
%           clr=varargin{5}; % line color
%     otherwise
%         error('Unexpected input');
% end
% 
% % x=sum(x,2);  %stack
% scales={'linear','log'};
% xscale=scales{logflag(1)+1};
% yscale=scales{logflag(2)+1};
% if fr==1 ||fr==2  ||fr==4 %fft 
%     if fft_size==0 
%         nfft=2^nextpow2(length(x));
%     elseif fft_size>length(x)
%         nfft=fft_size;  % manually specifying fft size
%     else
%         nfft=length(x);
%     end
%     ls=fft(x,nfft);
%     % shift fft
%     ls=fftshift(ls);
% else     % time series itself
%     ls=x;
%     nfft=length(x);
%     s=-1;     %time series do not need to be normalized
% end
% 
% if s==1   % normalized by the length or not
%     mx=abs(ls)/length(x);
% elseif s==-1  % time series itself
%     mx=ls;
% else
%     mx=abs(ls);
% end
% 
% % mx=mx.^2;  % 
% 
% f=(-length(mx)/2:length(mx)/2-1)*fs/nfft;
% f=f';
% 
% 
% if fr==4   % fft but no picture
%     return; 
% end
% figure()
% if fr~=2 && fr~=4 && fr~=1   % time series itself
%     t_s=time_vector(x,nfft/fs);
%     plot(t_s,x,clr);
%     set(gca,'xscale',xscale,'yscale',yscale);
%     title('Input Series');
%     xlabel('Time (s)');
%     ylabel('Amplitude');
%     set(gca,'xlim*fs',xlim*fs);
%     return;
% end
% if fr==2     % both time and freq domain
%     subplot(2,1,2);
% end
% plot(f,mx,clr);
% set(gca,'xscale',xscale,'yscale',yscale,'xlim*fs',xlim*fs);
% title('Energy Spectral Density of Input Series');
% xlabel('Frequency (Hz)');
% ylabel('Energy Distribution');
% if fr==2
% subplot(2,1,1);
% t_s=time_vector(x,fs);
% plot(t_s,x,clr);
% title('Input Series');
% xlabel('Time (s)');
% ylabel('Amplitude');
% set(gca,'xlim*fs',[0,t_s(min(length(t_s),fs))]);
% end
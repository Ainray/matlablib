% function [mx,f]=esd(x,fs,xLim,varargin)
% author: Ainray
% date: 20151228
% bug report: wwzhang0421@163.com
% introduction: Spectral analysis based on DFT.
%             : [fftx,f]=esd(x,fs,xlim), calculating PSD.
%             : [fftx,f]=esd(x,fs,xlim,2), the same as above but simutaneously 
%             :          painting origianl time series
%             : [fftx,f]=esd(x,f,xlim,4), only calculating PSD without picture
%             : [fftx,f]=esd(x,f,xlim,0), only painting original time series, 
%             :          the last parameter can any number but 1,2,4.
%             : [fftx,f]=esd(x,f,xlim,1,fftsize), specifying the size for DFT,
%             :          if fftsize is more large than the length of input 
%             :          time series, padding zeros.
%             : [fftx,f]=esd(x,f,xlim,1,fftsize,1/0), if true, the DFT result is 
%             :          normalized by the length of original time series
%             : [fftx,f]=esd(x,f,xlim,fftsize,1/0,[1/0 1/0]), if true, the 
%             :          scale is logrithmic
%             : [fftx,f]=esd(x,f,xlim,fftsize,1/0,[1/0 1/0],'b'), the last parameter
%             :          control the line color
% input:
%           x, time series
%          fs, sampling freqency
%        xLim, the frequency band width
%    varargin, the control parameters, in order
% output: 
%          mx, the Power Spectral Density of x
%           f, the frequency sampling points  
function [fftx,f]=esd(x,fs,xLim,varargin)
std=size(varargin,2);  % control parameter number
switch std
    case 0   
          fr=1;          % whether fft or not, 1 indicating fft
          fft_size=0;    % fft size
          s=0;           % whether normalized or not      
          logflag=[0,0]; %loglog not
          clr='b';  % line color
    case 1
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=0;    % fft size
          s=0;           % whether normalized or not      
          logflag=[0,0]; %loglog not
           clr='b';  % line color
    case 2
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=varargin{2};    % fft size
          s=0;           % whether normalized or not      
          logflag=[0,0]; %loglog not
           clr='b';  % line color
    case 3
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=varargin{2};    % fft size
          s=varargin{3};           % whether normalized or not      
          logflag=[0,0]; %loglog not
           clr='b';  % line color
    case 4
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=varargin{2};    % fft size
          s=varargin{3};           % whether normalized or not      
          logflag=varargin{4}; %loglog not
          clr='b';  % line color
    case 5
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=varargin{2};    % fft size
          s=varargin{3};           % whether normalized or not      
          logflag=varargin{4}; %loglog not
          clr=varargin{5}; % line color
    otherwise
        error('Unexpected input');
end

% x=sum(x,2);  %stack
scales={'linear','log'};
xscale=scales{logflag(1)+1};
yscale=scales{logflag(2)+1};
if fr==1 ||fr==2  ||fr==4 %fft 
    if fft_size==0 
        nfft=2^nextpow2(length(x));
    elseif fft_size>length(x)
        nfft=fft_size;  % manually specifying fft size
    else
        nfft=length(x);
    end
    fftx=fft(x,nfft);
    % shift fft
    fftx=fftshift(fftx);
else     % time series itself
    fftx=x;
    nfft=length(x);
    s=-1;     %time series do not need to be normalized
end

if s==1   % normalized by the length or not
    mx=abs(fftx)/length(x);
elseif s==-1  % time series itself
    mx=fftx;
else
    mx=abs(fftx);
end

% mx=mx.^2;  % 

f=(-length(mx)/2:length(mx)/2-1)*fs/nfft;
f=f';


if fr==4   % fft but no picture
    return; 
end
figure(1111111111)
if fr~=2 && fr~=4 && fr~=1   % time series itself
    t_s=time_vector(x,nfft/fs);
    plot(t_s,x,clr);
    set(gca,'xscale',xscale,'yscale',yscale);
    title('Input Series');
    xlabel('Time (s)');
    ylabel('Amplitude');
    set(gca,'xLim',xLim);
    return;
end
if fr==2     % both time and freq domain
    subplot(2,1,2);
end
plot(f,mx,clr);
set(gca,'xscale',xscale,'yscale',yscale,'xLim',xLim);
title('Energy Spectral Density of Input Series');
xlabel('Frequency (Hz)');
ylabel('Energy Distribution');
if fr==2
subplot(2,1,1);
t_s=time_vector(x,fs);
plot(t_s,x,'clr');
title('Input Series');
xlabel('Time (s)');
ylabel('Amplitude');
set(gca,'xlim',[0,t_s(min(length(t_s),fs))]);
end
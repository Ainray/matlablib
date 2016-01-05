% function [mx,f]=esd(x,fs,xLim,varargin)
% author: Ainray
% date: 20151228
% bug report: wwzhang0421@163.com
% introduction: Spectral analysis based on DFT.
% input:
%           x, time series
%          fs, sampling freqency
%        xLim, the frequency band width
%    varargin, the control parameters
% output: 
%          mx, the Power Spectral Density of x
%           f, the frequency sampling points  
function [mx,f]=esd(x,fs,xLim,varargin)
std=size(varargin,2);  % control parameter number
switch std
    case 0   
          fr=1;          % whether fft or not, 1 indicating fft
          fft_size=0;    % fft size
          s=0;           % whether normalized or not      
          logflag=[0,0]; %loglog not
    case 1
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=0;    % fft size
          s=0;           % whether normalized or not      
          logflag=[0,0]; %loglog not
    case 2
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=varargin{2};    % fft size
          s=0;           % whether normalized or not      
          logflag=[0,0]; %loglog not
    case 3
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=varargin{2};    % fft size
          s=varargin{3};           % whether normalized or not      
          logflag=[0,0]; %loglog not
    case 4
          fr=varargin{1};          % whether fft or not, 1 indicating fft
          fft_size=varargin{2};    % fft size
          s=varargin{3};           % whether normalized or not      
          logflag=varargin{4}; %loglog not
    otherwise
        error('Unexpected input');
end
% x=sum(x,2);  %stack

if fr==1 ||fr==2  ||fr==4 %fft 
    if fft_size==0 
        nfft=2^nextpow2(length(x));
    else
        nfft=fft_size;  % manually specifying fft size
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
    mx=abs(fftx);
elseif s==-1  % time series itself
    mx=fftx;
else
    mx=abs(fftx)/nfft;
end

% mx=mx.^2;  % 

f=(-length(mx)/2:length(mx)/2-1)*fs/nfft;
f=f';


if fr==4   % fft but no picture
    return; 
end
figure()
if fr==0   % time series itself
    t_s=time_vector(x,fs);
    plot(t_s,x);
    title('Input Series');
    xlabel('Time (s)');
    ylabel('Amplitude');
    return;
end
if fr==2     % both time and freq domain
    subplot(2,1,2);
end

if logflag(1)==0 && logflag(2)==0
    plot(f,mx,'lineWidth',2.5);
elseif logflag(1)==0 && logflag(2)==1
    plot(f,20*log10(mx),'lineWidth',2.5);
elseif logflag(1)==1 && logflag(2)==0
    semilogx(f,mx,'lineWidth',2.5);
else
    semilogx(f,20*log10(mx),'lineWidth',2.5);
end
    
a=gca;
set(a,'xLim',xLim);
title('Energy Spectral Density of Input Series');
xlabel('Frequency (Hz)');
ylabel('Energy Distribution');
if fr==2
subplot(2,1,1);
t_s=time_vector(x,fs);
plot(t_s,x);
title('Input Series');
xlabel('Time (s)');
ylabel('Amplitude');
end
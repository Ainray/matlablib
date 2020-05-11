function [xx,f,factor]=mtem_esd(f0,n,x,fs,bw,peak)
% [xx,f,factor]=mtem_esd(512,10,x,16384,512,1);
% [xx,f,factor]=mtem_esd(-1,-1,x,16384,512);
if nargin<6
    peak=0;
end
if nargin<5
    bw=fs;
end
if nargin<4
    fs=16000;
end
% f0, base frequency
% n, order
% fs, sampling frequency
Nx=length(x);
if f0<0
    if n<0
        n=Nx;
    end
    xx=fft(x,n);
    f=(0:n-1)'/n*fs;
    factor=[];
else
    switch  f0
    case {32,64,128}
        factor=1;
    case {256,512,1024,2048,4096}
        factor=f0/256*2;
    otherwise
        error('Invalid base frequency');
    end
    L0=fs/f0*factor*(2^n-1);
    if L0>10^8
        error('Too long segment');
    end
 
    Ns=floor(Nx/L0);
    if Ns==0
        Ns=1;
        x=[x;zeros(L0-Nx,1)];
    end
    xx=zeros(L0,1);

    for i=1:Ns
        xx=xx+fft(x((i-1)*L0+1:i*L0));
    end
    xx=xx/Ns;
    f=(0:L0-1)'/L0*fs;
    if peak==1
        f=f(1:factor:end);
        xx=xx(1:factor:end);
    end
end
indx=find(f>bw,1);
if ~isempty(indx)
    f=f(1:indx-1);
    xx=xx(1:indx-1);
end
function [w,tw]=wavelow(dt,fhigh,norder,phase,tlen)
% WAVELOW ... generate a wavelet rich in low frequencies
%
% [w,tw]=wavelow(dt,fhigh,norder,phase,tlen)
%
% This wavelet is generated by applying a Butterworth low-pass filter to an
% impulse. The Butterworth filter is specified by the high cut frequency
% and the filter order and can be eiter zero or minimum phase. The order is
% an integer specifying the rolloff on the high end. Higher numbers give a
% harder rolloff. Since the filter is naturally minimum phase, the zero
% phase wavelet is generated by applying the minnimum phase filter and its
% time reverse. Therefore, similar results are found when the zero phase
% order is half of the minimum phase order.
%
% dt ... time sample size (sec)
% fhigh ... high cut (Hz)
% norder ... butterworth order for high end rolloff
% ***** default 8 for minimum phase, 4 for zero phase *****
% phase ... 0 means zero phase, 1 means minimum phase
% ***** default phase=1 ******
% tlen ... length in seconds of the wavelet
% ***** default 500*dt *****


if(nargin<5)
    tlen=500*dt;
end
if(nargin<4)
    phase=1;
end
if(nargin<3)
    if(phase==1)
        norder=8;
    else
        norder=4;
    end
end
nt=round(tlen/dt)+1;
if(phase==1)
    tw=dt*(0:nt-1)';
    imp=zeros(size(tw));
    imp(1)=1; 
elseif(phase==0)
    nt2=round(tlen/(2*dt));
    tw=dt*(-nt2:nt2)';
    imp=zeros(size(tw));
    izero=near(tw,0);
    imp(izero)=1;
else
    error('phase must be 0 or 1');
end
w=butterband(imp,tw,0,fhigh,norder,phase);

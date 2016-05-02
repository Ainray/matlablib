% funciton h=winsinc_lowpass(fc,N)
% author: Ainray
% date: 20151021
% bug report: wwzhang0421@163.com
% introduction: a low pass filter based blackman-windowed sinc
% input:
%        fc, the numerical cutoff frequecy,0~0.5, 
%         N, filter length, must be odd, if pass is equal to 2, then filter
%            kernal will be 2*N-1
%      pass, times filter applied to input
%  NOTE:  BW*N=4, when pass equal to 1, BW*N=3, when pass equal to 2; 
%         BW*N=2, when pass equal to 4.
% output: 
%        h, the filter kernel
function h=winsinc_lowpass(fc,N,pass,window)
if nargin<3
    pass=1;
end
if nargin<4 
    window='blackman';
end
while( fc>0.5 || fc<0)
    fc=input('The cufoff frequency must be from 0 to 0.5:  ');
end
while( mod(N,2)~=1)
%     N=input('The filter length must be odd');
      N=N+1;
end
while( pass~=1 && pass~=2 && pass~=4)
    pass=input('The filtering time must be 1, 2, or 4 :  ');
end
% correct the cutoff frequency
% if pass==2
%     fc=fc+0.5/N+0.02285/N;
% elseif pass==4
%     fc=fc+1/N+0.05/N;
% end
r1=zeros(N,1);
%calculating the windowed sinc
indx=[0:(N-3)/2,(N+1)/2:N-1]'; 
% the middle point is singular, the indices is started from 0
% but matlab index from 1, so add indx with 1
switch(window)
    case 'blackman'
        r1(indx+1)=sin(2*pi*fc*(indx-(N-1)/2))./(indx-(N-1)/2).*...
    (0.42-0.5*cos(2*pi*indx/(N-1))+0.08*cos(4*pi*indx/(N-1))); %blackman
    case 'hamming'
        r1=sin(2*pi*fc*(indx-(N-1)/2))./(indx-(N-1)/2).*...
            (0.54-0.46*cos(2*pi*indx/(N-1)));
end
            
r1((N+1)/2)=2*pi*fc;  %middle point


% r1=r1/sum(r1);
switch(pass) 
    case 1
        h=r1;
    case 2  
        r2=fconv(r1,r1); 
        h=r2;
    case 4
        r2=fconv(r1,r1);
        h=fconv(r2,r2);
end
%normalization
h=h/sum(h);
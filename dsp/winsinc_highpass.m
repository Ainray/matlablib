% h=winsinc_highpass(fc,N,type,pass)
% author: Ainray
% date: 20151021
% bug report: wwzhang0421@163.com
% introduction: a low pass filter based blackman-windowed sinc
% input:
%        fc, the numerical cutoff frequecy,0~0.5
%         N, filter length, must be odd, if pass is equal to 2, then filter
%            kernal will be 2*N-1
%      pass, times filter applied to input
% output: 
%        h, the filter kernel
function h=winsinc_highpass(fc,N,pass)
if nargin<3
    pass=1;
end
% if nargin<3
%     type=0;% reversion
% end
while( fc>0.5 || fc<0)
    fc=input('The cufoff frequency must be from 0 to 0.5');
end
while( mod(N,2)~=1)
%     N=input('The filter length must be odd');
    N=N+1;
end

while( pass~=1 && pass~=2 && pass~=4)
    pass=input('The filtering time must be 1,2 or 4:  ');
end

% frequency reversion
% if(type)
%     h=winsinc_lowpass(0.5-fc,N,pass);
%     h=h.*sin(pi*[0:length(h)-1]');
% else

% correct the cutoff frequency
% if pass==2
%     fc=fc-0.5/N-0.0234/N;
% elseif pass==4
%     fc=fc-1/N+0.05/N;
% end
%frequency invsersion
    
    r1=winsinc_lowpass(fc,N);
    r1=-r1;  % spectrum inversion, transform low-pass into high-pass
    r1((length(r1)+1)/2)=r1((length(r1)+1)/2)+1;
%     h=r1/sum(r1);
%     h=h/sum(h);
% end

switch(pass)
    case 1
        h=r1;
    case 2
        h=fconv(r1,r1);
    case 4
        r2=fconv(r1,r1);
        h=fconv(r2,r2);
end

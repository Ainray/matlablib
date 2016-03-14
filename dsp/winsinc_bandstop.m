% funciton h=winsinc_bandstop(fc,N)
% author: Ainray
% date: 20151022
% bug report: wwzhang0421@163.com
% introduction: a band stop filter based blackman-windowed sinc
% input:
%        fc, the numerical passband  frequecy bound,0~0.5
%         N, filter length, must be odd, if pass is equal to 2, then filter
%            kernal will be 2*N-1
%      pass, times filter applied to input
% output: 
%        h, the filter kernel
function h=winsinc_bandstop(fc,N,pass)
if nargin<3
    pass=1;
end
% if nargin<3
%     type=0;% reversion
% end
while( length(fc)~=2 )
    fc=input('The pass band  frequency bound must be 2-length element');
    while( fc(1)>0.5 || fc(1)<0 ||fc(2)>0.5 || fc(2)<0 )  
        fc=input('The pass band frequency bound must be from 0 to 0.5');
        while(fc(1)>=fc(2))
            fc=input('The pass band frequency low bound (1st) must be less than high bound(2nd)');
        end
    end
end
while( mod(N,2)~=1)
%     N=input('The filter length must be odd: ');
    N=N+1;
end

while( pass~=1 && pass~=2)
    pass=input('The filtering time must be 1 or 2:  ');
end 
h_l=winsinc_lowpass(fc(1),N,pass);
h_h=winsinc_highpass(fc(2),N,pass);
h=h_l+h_h;


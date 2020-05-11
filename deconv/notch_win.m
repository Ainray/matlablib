function y=notch_win(x,f,fs)
for i=1:length(f)
    fc=[f(i)-1,f(i)+1]/fs;
    h=winsinc_bandstop(fc,160000);
     nh=length(h);  nx=length(x);
    y=fconv(x,h);
   
    y=y((nh+1)/2:(nh+1)/2+nx-1);
end
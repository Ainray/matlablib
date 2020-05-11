function y=mtem_lowpass(x,fc) 
low_pass=winsinc_lowpass(fc,1000001,1);
y=fconv(x,low_pass);
len=length(x);
y=y(500001:500001+len-1);
    
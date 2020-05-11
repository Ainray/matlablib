function y=mtem_highpass(x,fc) 
high_pass=winsinc_highpass(fc,300001,2);
y=fconv(x,high_pass);
len=length(y);
y=y(300001:len);
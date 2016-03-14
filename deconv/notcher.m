function y=notcher(x,f,fs)
% %f0=50;
% %陷波器的设计
% for i=1:length(f)
%     f0=f(i);
%     apha=-2*cos(2*pi*f0/fs);
% beta=0.96;
% b=[1 apha 1];
% a=[1 apha*beta beta^2];
% % figure(1);
% % freqz(b,a,NLen,fs);%陷波器特性显示
% % x=sin(2*pi*50*n*Ts)+sin(2*pi*125*n*Ts);%原信号
% y=dlsim(b,a,x);%陷波器滤波处理
% x=y;
% end
% y=x;
for i=1:length(f)
    fc=[f(i)-1,f(i)+1]/fs;
    h=winsinc_bandstop(fc,160000);
     nh=length(h);  nx=length(x);
    y=fconv(x,h);
   
    y=y((nh+1)/2:(nh+1)/2+nx-1);
end
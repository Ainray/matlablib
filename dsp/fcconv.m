function y=fcconv(x,h)
% y=fcconv(x,h,nozeropad)
% date: 20170525
% author: Ainray
% email: wwzhang0421@163.com
% calculating circular convolution with x shift circularly
% if length(x)<length(h)
%     error('Length of x must be larger than h');
% end
Nx=length(x);
Nh=length(h);
if Nx>Nh-1
%     %method 1:
%     % if length(x)>length(h)
%     yl=fconv(x,h); %linear correlation
%     % aliasing
%     y=lconv2c(yl,length(x),length(h));
%     
    %method 2:directly
    m=equalen({x,h});
    x=m(:,1);h=m(:,2);
    y=ifft(fft(x).*fft(h));  % u2 circularly shifted to the right
else
    L=ceil(Nh/Nx);
    xx=repmat(v2col(x),L,1);
    m=equalen({xx,h});
    x=m(:,1);h=m(:,2);
    y=ifft(fft(x).*fft(h));
    y=y(1:Nx);
end

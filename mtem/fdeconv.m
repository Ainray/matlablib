function h=fdeconv(x,y,a,n,fs)
if nargin<3
    a=0;
end
if nargin<4
    n=length(y);
end
if nargin<5
    fs=1;
end
xx=mtem_esd(-1,n,x,fs);
yy=mtem_esd(-1,n,y,fs);
H=conj(xx).*yy./(abs(xx).*abs(xx)+a);
h=real(ifft(H));

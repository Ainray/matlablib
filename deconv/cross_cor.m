function c=cross_cor(a,b)
[B A AA]=freq_domain(b,a);
C=AA.*B;
c=real(ifft(C))/length(a);  
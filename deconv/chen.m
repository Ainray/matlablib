function [rf,t_rf]=chen(w,d,fs)
[D W W2]=freq_domain(d,w);
W_avg=mean(W,2);
W2_avg=mean(W2,2);
D_sum=sum(D,2);

M=size(D,2);

E_T=1/M*sum(abs(D).^2,2);

WDF=W2_avg./E_T;

RF=D_sum.*WDF;
rf=real(ifft(RF));

t_rf=time_vector(rf,fs);
% figure;
% plot(t_rf,rf,'LineWidth',2.5);
% xlabel('Time (s)');ylabel('Receiver Function');
% title('Array-Conditioned Deconvolution (chen)');
% 
% [f mx]=esd(W.*W2,1);
% h=gcf;
% close(h);
% [f2 mx2]=esd(E_T,1);
% k=gcf;
% close(k);
% 
% figure();
% plot(f,mx,'LineStyle','--','LineWidth',2.5);
% hold on;
% plot(f2,mx2,'Color','g','LineWidth',2.5);
% axis([-1.5,1.5 0 max(mx2)+100]);
% title('Energy Spectral Density of Input Series');
% xlabel('Frequency (Hz)');
% legend('Autocorrelation of source wavelet', 'Average total enerty fo the raw traces');
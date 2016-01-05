%function [rf,wl,GCV]=bostock(w,d,t_w,fs)
% author: Ainray, rewirriten from 
% time  : 2015/7/30
% information: fft transform.
% input:
%              d, recorded data
%              w, wavelet or impulse or transient
%  output:
%              D, fft transform of data
%              W, fft of wavelate
%             W2, conjugate of W
function [rf,wl,GCV]=bostock(w,d,fs,range)
[D W W2]=freq_domain(d,w);
x_cor=D.*W2;
auto_cor=W.*W2;

M=size(D,2);
N=length(D);

rf_num=sum(x_cor,2); %stack predeconvolution
rf_den=sum(auto_cor,2);

j=1;
for i=range
    delta=i;
    RF=rf_num./(rf_den+delta);
    
    x_auto=sum(auto_cor,2);
    x=x_auto./(x_auto+delta);    
    X=sum(x,1);
    
    GCV_den=(N*M-X);
    
    for m=1:M
        WRF(:,m)=W(:,m).*RF;
    end
    
    gcv_n=(D-WRF).*conj(D-WRF);
    GCV_num=sum(sum(gcv_n,1),2);
%     GCV_num=0;
%     for i=1:N
%         for j=1:M
%             GCV_num=GCV_num+(D(i,j)-WRF(i,j))^2;
%         end
%     end
    
    GCV(j)=GCV_num/GCV_den;
    j=j+1;
end
wl=delta;
[GCV_min,j_min]=min(real(GCV));
if j_min==1 || j_min==max(j)
    error('Search needs to be extened')
end

RF=rf_num./(rf_den+delta(j_min));
rf=real(ifft(RF));
t_rf=time_vector(rf,fs);
figure()
plot(t_rf,rf,'LineWidth',2.5);
xlabel('Time (s)'),ylabel('Receiver Function')
title(['Simultaneous Frequency Domain Deconvolution (Bostock), delta=',...
    num2str(delta(j_min)) ] );


% delta=delta(j_min);
% [f mx]=esd(rf_den,1);
% h=gcf;
% close(h);
% [f2 mx2]=esd(rf_den+delta,1);
% k=gcf;
% close(k);

% figure();
% plot(f,mx*100,'LineStyle','--','LineWidth',2.5);
% hold on;
% plot(f2,mx2,'Color','g','LineWidth',2.5);
% axis([-1.5,1.5 0 max(mx2)+100]);
% title('Energy Spectral Density of Input Series');
% xlabel('Frequency (Hz)');
% legend('Orginal spectrum', 'Pre-whitened spectrum');
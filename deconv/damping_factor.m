%function rf=damping_factor(w,d,fs,delta,fig)
function [rf,t_rf]=damping_factor(w,d,fs,delta,fig)
[D, W ,W2]=freq_domain(d,w);
num=D.*W2;
den=W.*W2;

num=selective_stack(num);
den=selective_stack(den);

% den=sum(den,2);
RF=num./(den+delta);
rf=real(ifft(RF));
t_rf=time_vector(rf,fs);
if fig~=0
%     figure();
[mx,f]=esd(den,fs,[-1.5,1.5],3);
[mx2,f2]=esd(den+delta,fs,[-1.5,1.5],3);
% plot(f,mx1);hold on;plot(f,mx2,'r');set(gca,'xLim',[-1.5,1.5]);
figure()
plot(f,mx,'LineStyle','--','LineWidth',2.5);
hold on;
plot(f2,mx2,'Color','g','LineWidth',2.5);
hold on;
axis([-1.5,1.5 0 max(mx2)+100]);
title('Energy Spectral Density of Input Series');
xlabel('Frequency (Hz)');
legend('Orginal spectrum', 'Pre-whitened spectrum');
% k=gcf;
% close(k);
% h=gcf;
% close(h);

% figure()
% plot(t_rf,rf,'LineWidth',2.5);
% xlabel('Time (s)');
% ylabel('Receiver Function');
% title(['Damping Factor, delta= ',num2str(delta)]);
end

function [rf,t_rf]=water_level(w,d,fs,delta,fig)
if nargin<5
    fig=0;
end

[D W W2]=freq_domain(d,w);
num=D.*W2;
den=W.*W2;
num=sum(num,2);
den=sum(den,2);

den2=den;
% [f mx]=esd(den,1);
% h=gcf;
%close(h);
for z=1:length(den)
    if(den2(z)<delta)
        den2(z)=delta;
    end
end



RF=num./den2;
rf=real(ifft(RF));

t_rf=time_vector(rf,fs);

if fig
figure()
plot(t_rf,rf,'LineWidth',2.5);
xlabel('Time (s)');
ylabel('Receiver Function');
title(['Water level Deoconvolution, water level=',num2str(delta)]);

[f2 mx2]=esd(den2,1);
k=gcf;
close(k);
end
% figure();
% plot(f,mx*100,'LineStyle','--','LineWidth',2.5);
% hold on;
% plot(f2,mx2,'Color','g','LineWidth',2.5);
% axis([-1.5,1.5 0 max(mx2)+100]);
% title('Energy Spectral Density of Input Series');
% xlabel('Frequency (Hz)');
% legend('Orginal spectrum', 'Pre-whitened spectrum');
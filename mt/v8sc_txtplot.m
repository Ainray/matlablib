function [fre, amp, ph]=v8sc_txtplot(fname)

eval(['load ', fname]);
filename = fname;
i = find('.'== filename);
imname = filename(1:i-1);
xx=[];
eval(['xx = ',imname , ';']);
fre = xx(:,1);
amp = xx(:,2);
ph = xx(:,3);
figure('color',[1 1 1]);
subplot(2,1,1);
loglog(fre(end:-1:1),amp,'*r');
set(gca,'xlim',[fre(1), fre(end)], 'ylim',[1e-2,10]);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
subplot(2,1,2);
semilogx(fre(end:-1:1),ph,'*r');
set(gca,'xlim',[fre(1), fre(end)],'ylim',[-180,180]);
xlabel('Frequency (Hz)');
ylabel('Phase(deg)');

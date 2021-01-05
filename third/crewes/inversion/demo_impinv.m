%
% The purpose of this demo is to show the importance of low frequencies in
% the calculation of impedance from a reflectivity estimate.
%
% Run the demo by executing each cell one-by-one. Also study the code to see
% how its done.
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE

%

%
%% Impedance inversion demo
%
%read the las file
p=which('qmatrix');
ind=strfind(p,'qmatrix');
filename='1409.las';%1409.las is in the qtools toolbox
[logmat,mnem,desc,name,id,loc,null,units,kb,tops,ztops,lash]=readlas([p(1:ind-1) filename]);
% by examining the returned variable mnem, we determine the columns of the
% log matrix to be
% column ... Identity
%    1   ... depth
%    2   ... density
%    3   ... p-wave sonic
%
%unpack interesting logs from logmat
z=logmat(:,1);%depth
sp=logmat(:,3);%p-wave sonic
rho=logmat(:,2);%density
%convert sonic to velocity
vp=10^6 ./sp;

%make a plot
figure
subplot(1,2,1)
plot(vp,z);flipy
title('V_p')
ylabel('depth (m)');
xlabel('velocity (m/s)')
subplot(1,2,2)
plot(rho,z);flipy
title('density')
ylabel('depth (m)');
xlabel('density (kg/m^3)')
prepfig
% alternate plot showing tops
figure
plot(vp,z,'b',rho,z,'r');flipy
title('alternate plot showing tops')
prepfig
hs=plottops(ztops,tops,'k');
legend('p-wave velocity','density')
%% make wavelets
dt=.001; %sample rate (seconds) of wavelet and seismogram
%fdom=40;%dominant frequency of wavelet
fo=[5 10 50 60];%Ormsby frequencies
fo2=[0 .1 50 60];%ormsby with low frequencies
%[wr,twr]=ricker(dt,fdom,.2);%ricker wavelet
[wo,two]=ormsby(fo(1),fo(2),fo(3),fo(4),.2,dt);%ormsby wavelet
[wo2,two]=ormsby(fo2(1),fo2(2),fo2(3),fo2(4),.2,dt);%ormsby wavelet
[Wo,fwo]=fftrl(wo,two);
[Wo2,fwo]=fftrl(wo2,two);
%[wm,twm]=wavemin(dt,fdom,.2);%minimum phase wavelet
%plot the wavelets
figure
subplot(2,1,1)
plot(two,wo,two,wo2)
title('Note the low frequency wavelet has larger positive mean value')
xlabel('time (seconds)')
subplot(2,1,2)
plot(fwo,abs(Wo),fwo,abs(Wo2));
xlabel('Frequency (Hz)')
prepfig
legend('5-10-50-60 Ormsby','0-.1-50-60 Ormsby')
grid
%% make seismograms
%we make a p-p primries only normal incidence seismogram
fmult=0;%flag for multiple inclusion. 1 for multiples, 0 for no multiples
fpress=1;%flag for pressure (hydrophone) or displacement (geophone)
[s,ts,rcs,pm,p]=seismo(sp,rho,z,fmult,fpress,wo,two);%using Ormsby wavelet
s2=convz(rcs,wo2);
%plot results
figure
subplot(1,3,2)
h2=plot(s,ts,s2,ts);flipy
title('Note that the low-pass and bandlimited seismograms appear nearly identical')
ylabel('Time (s)')
subplot(1,3,1)
h1=plot(rcs,ts);flipy
ylabel('Time (s)')
subplot(1,3,3)
h3=plot(s2-s,ts,'r');flipy
prepfig
subplot(1,3,2)
legend([h1;h2;h3],'Reflectivity','bandlimited seismogram',...
    'low-pass seismogram','difference of seismograms')
%% impedances 
%impedance in depth
impz=vp.*rho;
%time-depth curve
[tz,zt]=sonic2tz(sp,z,-100);
timpz=interp1(zt,tz,z)+ts(1);
%resample impedance to time
imptobj=logtotime([z impz],[zt tz],dt);
impt=imptobj(:,2);%impedance log at 1 mil
timp=imptobj(:,1)+ts(1);%time coordinate
figure
plot(impz,timpz,impt,timp,'r');flipy
title('Compare impedance at log sample rate and seismic sample rate')
prepfig
legend('Impedance sampled at logging rate','Impedance at seismic sample rate')
%compute impedance from seismograms and rcs
impnot=mean(impt(1:10));%initial impedance
imps=rcs2imp(s,impnot);
%s2=filtf(rcs,ts,0,[50 10],0);
imps2=rcs2imp(s2,impnot);
impr=rcs2imp(rcs,impt(1));
figure
hs=plot(impz,timpz,'k',impr,ts,'k',imps2,ts,'g',imps,ts,'r');flipy
title('Low frequecies give the proper trend to the inversion')
xlabel('Impedance')
ylabel('Seconds')
prepfig
set(hs(1),'color',[.8 .8 .8]);
set(hs(2),'color','k')
set(hs(3),'color',[.1 .9 .1]);
w=get(hs(3),'linewidth');
set([hs(3) hs(4)],'linewidth',1.5*w);
legend('Well impedance','Well at seismic \Delta t','0-60 Hz inversion','10-60 Hz inversion')
figure
subplot(1,2,1)
plot(imps2./imps,ts);flipy
title('Ratio of the two inversions')
subplot(1,2,2)
plot(imps2-imps,ts);flipy
title('Difference of the two inversions')
% figure
% dbspec(timp,[impz pad_trace(imps,impz) pad_trace(impr,impz)])
%% compare a range of low-f seismograms
impnot=impr(1);
dt=ts(2)-ts(1);
tp=dt*(0:2047)+ts(1);
rcsp=pad_trace(rcs,tp);%pad a lot to be good frequency sampling
s0=filtf(rcsp,tp,0,[50 10],0);
s1=filtf(rcsp,tp,[1 .1],[50 10],0);
s2=filtf(rcsp,tp,[2 .2],[50 10],0);
s3=filtf(rcsp,tp,[3 .3],[50 10],0);
s4=filtf(rcsp,tp,[4 .4],[50 10],0);
s5=filtf(rcsp,tp,[5 .5],[50 10],0);
% s0=butterband(rcsp,tp,0,50,4,0);
% s1=butterband(rcsp,tp,1,50,4,0);
% s2=butterband(rcsp,tp,2,50,4,0);
% s3=butterband(rcsp,tp,3,50,4,0);
% s4=butterband(rcsp,tp,4,50,4,0);
% s5=butterband(rcsp,tp,5,50,4,0);
% s0=butterfilter(rcsp,tp,'fmin',0,'fmax',5,'phase',0,'order',4);
% s1=butterfilter(rcsp,tp,'fmin',1,'fmax',5,'phase',0,'order',4);
% s2=butterfilter(rcsp,tp,'fmin',2,'fmax',5,'phase',0,'order',4);
% s3=butterfilter(rcsp,tp,'fmin',3,'fmax',5,'phase',0,'order',4);
% s4=butterfilter(rcsp,tp,'fmin',4,'fmax',5,'phase',0,'order',4);
% s5=butterfilter(rcsp,tp,'fmin',5,'fmax',5,'phase',0,'order',4);
imp0=rcs2imp(s0,impnot);
imp1=rcs2imp(s1,impnot);
imp2=rcs2imp(s2,impnot);
imp3=rcs2imp(s3,impnot);
imp4=rcs2imp(s4,impnot);
imp5=rcs2imp(s5,impnot);
figure
subplot(1,2,1)
ind=near(tp,ts(1),ts(end));
plot(ts,impr,ts,imp0(ind),ts,imp1(ind),ts,imp2(ind),ts,imp3(ind),ts,imp4(ind),ts,imp5(ind));
grid
legend('actual impedance','inversion to .1 Hz','inversion to 1 Hz','inversion to 2 Hz'...
    ,'inversion to 3 Hz','inversion to 4 Hz','inversion to 5 Hz');
title('You need below 1 Hz for a good inversion')
subplot(1,2,2)
dbspec(tp,[s0 s1 s2 s3 s4 s5]);
title({'spectra of bandlimited reflectivity','low-end only'})
legend('0-50Hz','1-50Hz','2-50Hz','3-50Hz','4-50Hz','5-50Hz')
xlim([0 10]);ylim([-100 0])
prepfiga

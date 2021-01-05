%% Script designed to test wavelet estimation methods: simple, match filter, and Roy White
% To use this script, first run one of sections 1-3 to generate a synthetic trace with a given
% wavelet. You may wish to run section 5 to plot the synthetic data just to get comfortable with
% the input. Then run one of the wavelet estimators in sections 6,7,8,9,10,11. Sections 12,13,
% and 14 launch GUI based wavelet explorers for each of the three methods. There are more
% sections than this but use only if you dare. Notice that there are parameters that you may
% want to tweak at the beginning of each section.
%
% After running section #1 you may optionally run section #4 to deconvolve the synthetic and
% then estimate the wavelet after decon.  You can also do this for sections 2 and 3 but since
% the wavelets are not minimum phase the decon is going to be a bad thing.
%
% The results figure from sections 6-11 shows a lot of detail including statistics quoted in
% the trace labels and in the wavelet legend. In the trace labels, cc refers to cross
% correlations of any particular trace with respect to bandlimited reflectivity. The
% bandlimited reflectivity is formed by taking the wavelet estimated from the noise-free
% synthetic (with constraints if any), converting it to zero phase, and convolving with the
% reflectivity. This wavelet is generally the best wavelet and is used as a reference. cc(1)
% refers to the maximum value of the cross correlation and cc(2) is the lag (in samples) at
% which this maximum occurs. A negative lag indicates a delay. Ideal results are cc(1)=1 and
% cc(2)=0. In the wavelets legend, err refers to the sum-squared error in comparing the
% estimated wavelet to the answer (the true wavelet). The cc values are similar to those for
% the traces except that the correlation is the estimated wavelet with the true wavelet.
% Finally pep is "portion of energy predicted" and is defined as
% pep= 1 - energy(residual)/energy(trace); 
% where energy(residual) is the energy of the difference between the model trace and the trace
% and energy(trace) is just what it says. Energy is the sum of the squares of the samples. The
% model trace is the estimated wavelet convolved with the reflectivity.
%
% These tests use synthetic data and give an overly optimistice picture of wavelet estimation
% because the alignment between trace and reflectivity is perfect. With real data, the
% alignment is often the bigget challenge.
%

%% #1 min phase synthetic, reflectivity generated in depth and converted to time
rseed=1;%random number seed for reflectivity
s2n=3;%signal to noise ratio
dt=.002;%time sample rate
fdom=30;%dominant frequency
tlen=.3;%wavelet length in seconds
dname=['min phase synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
dname2=['min phase synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
[w,tw]=wavemin(dt,fdom,tlen);
zmax=3000;
dz=1/3.28;
v=3000;
[rz,zz]=reflec(zmax,dz,.1,5,rseed);%erlectivity in depth
I=rcs2imp1(rz,1000);
z=[0;zz+dz];
tz=2*z/v;
[r,t]=imp2rcs_t(I,z,tz,dt);
% [r,t]=reflec(2,dt,.1,3,rseed);
s=convm(r,w);
if(~isinf(s2n))
    sn=s+rnoise(s,s2n);
else
    sn=s;
end
jcausal=1;
tr=t;
name=dname;
save('waveex_minphase_stat','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
name=dname2;
tmp=s;
s=sn;
save('waveex_minphase_stat_noise','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
s=tmp;
%% #1B min phase synthetic with limited r and bulk shift

rseed=1;%random number seed for reflectivity
s2n=3;%signal to noise ratio
dt=.002;%time sample rate
fdom=30;%dominant frequency
tlen=.3;%wavelet length in seconds
tbulk=-.3;
dname=['min phase synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
dname2=['min phase synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
[w,tw]=wavemin(dt,fdom,tlen);
zstart=750;%start of log;
zend=2500;%end of log;
zmax=3000;
dz=1/3.28;
v=3000;
[rz,zz]=reflec(zmax,dz,.1,5,rseed);%reflectivity in depth
I1=rcs2imp1(rz,1000);
z1=[0;zz+dz];
tz1=2*z1/v;
[r1,t]=imp2rcs_t(I1,tz1,dt);
% [r1,t]=reflec(2,dt,.1,3,rseed);
s=convm(r1,w);%trace made from full length r
if(~isinf(s2n))
    sn=s+rnoise(s,s2n);
else
    sn=s;
end

%limit the impedance to the logged range
ind=near(z1,zstart,zend);
I=I1(ind);
z=z1(ind);
tz=2*z/v+tbulk;
[r,tr]=imp2rcs_t(I,tz,dt);

% %truncate and shift r
% r=r1(irange);
% tr=t(irange)+tbulk;

jcausal=1;
name=dname;
save('waveex_minphase_stat_bulk2','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
name=dname2;
tmp=s;
s=sn;
save('waveex_minphase_stat_bulk_noise','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
s=tmp;
% %% #2 ricker synthetic with time and phase shift
% rseed=1;%random number seed for reflectivity
% s2n=3;%signal to noise ratio
% dt=.002;%time sample rate
% fdom=30;%dominant frequency
% tlen=.3;%wavelet length in seconds
% phaseshift=90;%phase rotation
% t1=.6;%start of log
% t2=1.6;%end of log
% tbulk=-.3;%time shift of log
% [r,t]=reflec(2,dt,.1,3,rseed);
% 
% dname=['Ricker synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ...
%     ', dt=' num2str(dt) ', phaseshift=' num2str(phaseshift) ...
%     ', timeshift=' num2str(timeshift) ', rseed=' num2str(rseed)];
% [w,tw]=ricker(dt,fdom,tlen);
% w=phsrot(w,phaseshift);
% 
% s=convz(r,w);
% if(~isinf(s2n))
%     sn=s+rnoise(s,s2n);
% else
%     sn=s;
% end
% jcausal=0;
% tr=t;
% name=dname;
% save('waveex_rickerRot_stat','s','sn','s2n','t','r','tr','w','tw','name');
%% #3 klauder synthetic
% rseed=1;%random number seed for reflectivity
% s2n=3;%signal to noise ratio
% dt=.002;%time sample rate
% fmin=10;%sweep start frequency (Hz)
% fmax=80;%sweep end frequency
% slen=8;%sweep length (sec)
% tlen=.3;%wavelet length (sec)
% taper=.25;% sweep taper (sec)
% 
% [r,t]=reflec(2,dt,.2,3,rseed);
% dname=['Klauder synthetic, s2n=' num2str(s2n) ', fmin=' num2str(fmin) ', fmax=' num2str(fmax)...
%     ', dt=' num2str(dt) ', swplen=' num2str(slen) ', taper=' num2str(taper)...
%     ', rseed=' num2str(rseed)];
% [w,tw]=wavevib(fmin,fmax,dt,slen,tlen,taper);
% 
% s=convz(r,w);
% if(~isinf(s2n))
%     sn=s+rnoise(s,s2n);
% else
%     sn=s;
% end
% jcausal=0;
% tr=t;
% name=dname;
% save('waveex_klauder_stat','s','sn','s2n','t','r','tr','w','tw','name');
%% nonstationary synthetic, full log, no bulk shift
dt=.002;
rseed=pi;
fdom=30;
Q=70;
tlen=.3;
tbulk=0;
[w,tw]=wavemin(dt,fdom,tlen);
zmax=3000;
zstart=0;%start of log;
zend=zmax;%end of log;
dz=1/3.28;
v=3000;
[rz,zz]=reflec(zmax,dz,.1,5,rseed);%reflectivity in depth
I1=rcs2imp1(rz,1000);
z1=[0;zz+dz];
tz1=2*z1/v;
[r1,t]=imp2rcs_t(I1,z1,tz1,dt);
qmat=qmatrix(Q,t,w,tw);
s=qmat*r1;%trace made from full length r
dname=['Nonstationary synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ...
    ', dt=' num2str(dt) ', Q=' num2str(Q) ...
    ', rseed=' num2str(rseed)];

irange=near(t,.75,1.25);
s2n=2;
dname2=['Nonstationary synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ...
    ', dt=' num2str(dt) ', Q=' num2str(Q) ...
    ', rseed=' num2str(rseed)];
n=rnoise(s,s2n,irange);
sn=s+n;
%limit the impedance to the logged range
ind=near(z1,zstart,zend);
I=I1(ind);
z=z1(ind);
tz=2*z/v+tbulk;
[r,tr]=imp2rcs_t(I,z,tz,dt);

jcausal=1;
name=dname;
save('waveex_minphase_nonstat','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
tmp=s;
s=sn;
name=dname2;
save('waveex_minphase_nonstat_noise','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
s=tmp;
%% more nonstationary synthetic. Used the option in Qmatrix to delay relative to sonic freqs.
% also included a bulk shift too early on the rcs. Also truncate the rcs to z=750->2500;
tbulk=-.1;
dt=.002;
fdom=30;
Q=70;
tlen=.3;
rseed=pi;
[w,tw]=wavemin(dt,fdom,tlen);
zmax=3000;
zstart=750;%start of log;
zend=2500;%end of log;
dz=1/3.28;
v=3000;
[rz,zz]=reflec(zmax,dz,.1,5,rseed);%reflectivity in depth
I1=rcs2imp1(rz,1000);
z1=[0;zz+dz];
tz1=2*z1/v;
[r1,t]=imp2rcs_t(I1,tz1,dt);
qmat=qmatrix(Q,t,w,tw,3);
s=qmat*r1;
dname=['More nonstationary synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ...
    ', dt=' num2str(dt) ', Q=' num2str(Q) ...
    ', rseed=' num2str(pi)];

s2n=2;
dname2=['More nonstationary synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ...
    ', dt=' num2str(dt) ', Q=' num2str(Q) ...
    ', rseed=' num2str(pi)];
n=rnoise(s,s2n);
sn=s+n;
%truncate and shift r
%limit the impedance to the logged range 
ind=near(z1,zstart,zend);
I=I1(ind);
z=z1(ind);
tz=2*z/v+tbulk;%apply bulk shift
[r,tr]=imp2rcs_t(I,tz,dt);

jcausal=1;
name=dname;
save('waveex_minphase_nonstat_more','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
tmp=s;
s=sn;
name=dname2;
save('waveex_minphase_nonstat_noise_more','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
s=tmp;
%% #4 synthetic min phase with decon
rseed=1;%random number seed for reflectivity
s2n=3;%signal to noise ratio
dt=.002;%time sample rate
fdom=30;%dominant frequency
tlen=.3;%wavelet length in seconds

dname=['min phase synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
dname2=['min phase synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
[w,tw]=wavemin(dt,fdom,tlen);
[r,t]=reflec(2,dt,.1,3,rseed);
s0=convm(r,w);
if(~isinf(s2n))
    sn0=s0+rnoise(s0,s2n);
else
    sn0=s0;
end
jcausal=1;

top=.04;%decon operator length (seconds)
stab=.01;%decon stab factor (white noise)
stab2=.01;
nop=round(top/dt);%don't change
[s,d]=deconw(s0,s0,nop,stab);
[sn,dn]=deconw(sn0,sn0,nop,stab2);
snf=butterband(sn,t,0,50,4,1);

wd=convm(w,d);
a=norm(w)/norm(wd);
wd2=butterband(wd,tw,0,50,4,1);
a2=norm(w)/norm(wd2);
w=wd*a;
s=s*a;
sn=snf*a2;
w2=wd2*a2;
dname=[dname ' deconvolved'];
dname2=[dname2 ' deconvolved'];
tr=t;
name=dname;
save('waveex_minphase_stat_decon','s','t','r','tr','w','tw','name','jcausal');
name=dname2;
tmp=s;
s=sn;
save('waveex_minphase_stat_noise_decon','s','t','r','tr','w','tw','name','jcausal');
s=tmp;

%% #4b a well log synthetic. Simulate case where reflectivity and trace have different lengths 
% seismo1D to estimate reflectivity and then extended with reflec. Well log reflectivity occurs from
% .81 tp 2.48 sec. Trace is built from rcs. no multiples.
% No polarity reversal
[logmat,logmnem,logdesc,wellname,wellid,loc,nullval,dpthunits,kb,tops,ztops,lasheader]=readlas('42389312280000_no_overburden.las');

zlog=logmat(:,1);
sp=logmat(:,2);%p sonic
rho=logmat(:,5);
%the pw-wave sonic starts at 4000ft. we make a synthetic seismogram from it using no overburden and
%and then insert some fake rcs at the top

rseed1=1;%random number seed for reflectivity above well
rseed2=pi;%random number seed for reflectivity below well
dt=.002;%time sample rate
fdom=30;%dominant frequency
tlen=.3;%length of wavelet
[w,tw]=wavemin(dt,fdom,tlen);%wavelet
wname='30 Hz Ricker';
fmult=0;% no multiples
fpress=0;% says we want displacement not pressure
tmax=3;% max time for the output
[s0,tz,rcs,pm,p]=seismo1D(sp,rho,zlog,w,tw,vsurf,fmult,fpress,tmax);
t=tz(:,1);
zz=tz(:,2);
%find time rcs in the range of the original log
ind=near(zz,zlog(1),zlog(end));
tr=t(ind);
r=rcs(ind);
ra=reflec(t(ind(1)-1),dt,.2,3,rseed1);
rb=reflec(t(end)-t(ind(end)+1),dt,.2,3,rseed2);
r2=[ra;r;rb];%extend rcs to go from 0 to 3 seconds
if(fpress)
    s=convm(r2,w);
else
    s=convm(-r2,w);
end

a=max(r)/max(s);
s=s*a;
w=w*a;

s2n=2;
n=rnoise(s,s2n);
sn=s+n;

figure
plot(s,t,r+max(r),tr);flipy;grid
legend('Trace','reflectivity');

dname=['min phase synthetic from well, s2n=' num2str(0) ', fdom=' num2str(fdom) ', dt=' num2str(dt)];
dname2=['min phase synthetic from well, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ', dt=' num2str(dt)];

jcausal=1;
name=dname;
save('waveex_minphase_stat_well','s','t','r','tr','w','tw','name','jcausal');
name=dname2;
tmp=s;
s=sn;
save('waveex_minphase_stat_well_noise','s','t','r','tr','w','tw','name','jcausal');
s=tmp;
%% #4c min phase synthetic, 3 second record, r zero from .81 to 2.48
% simulates reflectivity shorter than seismic
rseed=1;%random number seed for reflectivity
s2n=3;%signal to noise ratio
dt=.002;%time sample rate
fdom=30;%dominant frequency
tlen=.3;%wavelet length in seconds

dname=['min phase synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
dname2=['min phase synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
[w,tw]=wavemin(dt,fdom,tlen);
[r2,t]=reflec(3,dt,.1,3,rseed);
s=convm(r2,w);
ir=near(t,.81,2.48);
r=r2(ir);
tr=t(ir);
if(~isinf(s2n))
    sn=s+rnoise(s,s2n);
else
    sn=s;
end
jcausal=1;
% tr=t;
name=dname;
save('waveex_minphase_stat2','s','t','r','tr','w','tw','name','jcausal');%short r
name=dname2;
tmp=r;
tmp2=tr;
tr=t;
r=r2;
save('waveex_minphase_stat2b','s','t','r','tr','w','tw','name','jcausal');%full r
r=tmp;
tr=tmp2;
%% #5 plot the input data

figure
names={'reflectivity','noise-free trace',['noisy trace, s2n=' num2str(s2n)]};
subplotabc('top')
trplot(t,[r s sn],'order','d','normalize',1)
title(dname); legend(names)
subplotabc('bota')
hhw=trplot(tw,w);
title('Wavelet')
subplotabc('botb')
if(jcausal==1)
    wflags=[ones(1,3) 2];
    wp=pad_trace(w,t);
else
    wflags=ones(1,4);
    wp=pad_trace(w,t,1);
end
hhs=dbspec(t,[r s sn wp],'windowflags',wflags);
title('spectra')
names={'reflectivity','noise-free trace',['noisy trace, s2n=' num2str(s2n)],'wavelet'};
legend(names,'location','southwest');
set(hhw{1},'color',get(hhs{4},'color'))
prepfiga

%% #6 simple

t1=.7;t2=1.2;%estimation time window
wsize=.4;%estimated wavelet size as a fraction of window size
delf=5;%frequency domain smoother (Hz)

[w1,tw1,stat1,phs1]=extract_wavelets_simple(s,t,r,.5*(t1+t2),t2-t1,delf,wsize);%no noise
[w1n,tw1n,stat1n,phs1n]=extract_wavelets_simple(sn,t,r,.5*(t1+t2),t2-t1,delf,wsize);%noisy

%construct model traces
sm=convz(r,w1{1});
snm=convz(r,w1n{1});


%correlation coeficients w.r.t band limited synthetic
rbl=convz(r,tozero(w1{1}));
nlags=50;
aflag=1;
ccs=maxcorr(rbl,s,nlags,aflag);
ccsm=maxcorr(rbl,sm,nlags,aflag);
ccsn=maxcorr(rbl,sn,nlags,aflag);
ccsnm=maxcorr(rbl,snm,nlags,aflag);

% w1=w1{1};
% tw1=tw1{1};
% w1n=w1n{1};

pep1=penpred(s,r,w1{1},tw1{1});

pep1n=penpred(s,r,w1n{1},tw1{1});

figure
subplotabc('top')
names={'reflectivity',['no noise, cc(1)=' num2str(ccs(1),2) ', cc(2)=' num2str(ccs(2),3)],...
    ['no noise model, cc(1)=' num2str(ccsm(1),2) ', cc(2)=' num2str(ccsm(2),3)],...
    ['noisy, s2n= ' num2str(s2n) ', cc(1)=' num2str(ccsn(1),2) ', cc(2)=' num2str(ccsn(2),3) ],...
    ['noisy model,  cc(1)=' num2str(ccsnm(1),2) ', cc(2)=' num2str(ccsnm(2),3)]};
hh0=trplot(t,[r,s,sm,sn,snm],'normalize',1,'tracespacing',1.5,'names',names,'order','d');
set(gca,'xlim',[0 max(t)+.5],'ylim',[-3 5])
yl=get(gca,'ylim');
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
title({dname,'wavelet estimation with simple method,  green lines show extraction window'})
titlefontsize(.75)

subplotabc('bota')
[err1,cc1]=waveleterr(w,tw,w1{1},tw1{1});

[errn,ccn]=waveleterr(w,tw,w1n{1},tw1{1});

it=near(tw,tw(1),tw(end));
names={'true',...
    ['no noise estimate, delf=' num2str(delf) ', err=' num2str(err1), ...
    ', cc(1)=' num2str(sigfig(cc1(1),2)) ', cc(2)=' num2str(cc1(2)) ', pep=' num2str(pep1,2)],...
    ['noisy estimate, delf=' num2str(delf) ', err=' num2str(errn), ...
    ', cc(1)=' num2str(sigfig(ccn(1),2)) ', cc(2)=' num2str(ccn(2)) ', pep=' num2str(pep1n,2)]};
names2={'',['timeshift= ' num2str(stat1), ', phase=' num2str(round(phs1))],['timeshift= ' num2str(stat1n), ', phase=' int2str(phs1n)]};
hh=trplot({tw(it) tw1{1} tw1{1}},{w(it),w1{1},w1n{1},},'zerolines','y','normalize',1,...
    'names',names2,'order','d','nameslocation','middle','nameshift',.25);
set(hh{2},'color',get(hh0{3},'color'));
set(hh{3},'color',get(hh0{5},'color'));
%ylim([-.2 .5])
%trplotlegend(hh,names)
title({'estimated wavelets','error and correlations in legend wrt true wavelet'} )
titlefontsize(.75)

subplotabc('botb')
iw=near(t,t1,t2);
if(jcausal)
    wf=[2 ones(1,4)];
else
    wf=ones(1,5);
end
hhdb=dbspec({tw(it) tw1{1} tw1{1},t(iw),t(iw)},{w(it),w1{1},w1n{1},s(iw),sn(iw)},'windowflags',wf,'normoption',1);
set(hhdb{2},'color',get(hh0{3},'color'));
set(hhdb{3},'color',get(hh0{5},'color'));
set(hhdb{4},'color',zeros(1,3));
set(hhdb{5},'color',.5*ones(1,3));
set(hhdb{1},'zdata',10*ones(size(get(hhdb{1},'xdata'))));
ylim([-100,0]);
legend([hhdb{1} hhdb{2} hhdb{3}],names,'location','southwest')
title({'estimated wavelets spectra',' trace spectrum (black) noisy trace (gray)'})
titlefontsize(.75)

prepfiga

%% #7 match filter using matchT, smoothness constraint only
pctnotcausal=50;%percentage of wavelet samples belore time zero
t1=.7;t2=1.2;%estimation time window
wsize=.5;%a fraction of window size
mu=[1 0];%first value is smoothness weight, second is time weight, see help for extract_wavelets_matchT

[w1,tw1]=extract_wavelets_matchT(s,t,r,.5*(t1+t2),t2-t1,wsize,mu,pctnotcausal);%no noise smooth
w1a=extract_wavelets_matchT(s,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,pctnotcausal);%no noise not smooth
w1n=extract_wavelets_matchT(sn,t,r,.5*(t1+t2),t2-t1,wsize,mu,pctnotcausal);%noisy smooth
w1na=extract_wavelets_matchT(sn,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,pctnotcausal);%noisy not smooth

pep1=penpred(s,r,w1{1},tw1{1});
pep1a=penpred(s,r,w1a{1},tw1{1});
pep1n=penpred(s,r,w1n{1},tw1{1});
pep1na=penpred(s,r,w1na{1},tw1{1});

%model traces
izero=near(tw1{1},0);
sm1=convz(r,w1{1},izero);
sm1a=convz(r,w1a{1},izero);
snm1=convz(r,w1n{1},izero);
snm1a=convz(r,w1na{1},izero);

%ccorelation coefficients
rbl=convz(r,tozero(w1{1}));
nlags=50;
aflag=1;
ccs=maxcorr(rbl,s,nlags,aflag);
ccsm1=maxcorr(rbl,sm1,nlags,aflag);
ccsm1a=maxcorr(rbl,sm1a,nlags,aflag);
ccsn=maxcorr(rbl,sn,nlags,aflag);
ccsnm1=maxcorr(rbl,snm1,nlags,aflag);
ccsnm1a=maxcorr(rbl,snm1a,nlags,aflag);


figure
subplotabc('top')
names={'reflectivity',['no noise, cc(1)=' num2str(ccs(1),2) ', cc(2)=' num2str(ccs(2),3)],...
    ['no noise model trace unconstrained, cc(1)=' num2str(ccsm1a(1),2) ', cc(2)=' num2str(ccsm1a(2),3)],...
    ['no noise model trace constrained, cc(1)=' num2str(ccsm1(1),2) ', cc(2)=' num2str(ccsm1(2),3)],...
    ['noisy, s2n= ' num2str(s2n) ', cc(1)=' num2str(ccsn(1),2) ', cc(2)=' num2str(ccsn(2),3) ],...
    ['noisy model trace unconstrained, cc(1)=' num2str(ccsnm1a(1),2) ', cc(2)=' num2str(ccsnm1a(2),3)],...
    ['noisy model trace constrained, cc(1)=' num2str(ccsnm1(1),2) ', cc(2)=' num2str(ccsnm1(2),3)]};
hh=trplot(t,[r,s,sm1a,sm1,sn,snm1a,snm1],'normalize',1,'tracespacing',1.5,'names',names,'order','d');
set(gca,'ylim',[-5 8])
set(gca,'xlim',[0 max(t)+.7])
yl=get(gca,'ylim');
xtick(0:.2:2)
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
title({dname,'wavelet estimation with SMOOTHNESS-constrained match filter,  green lines show extraction window'})
titlefontsize(.75)

subplotabc('bota')
[err1,cc1]=waveleterr(w,tw,w1{1},tw1{1});
[err1a,cc1a]=waveleterr(w,tw,w1a{1},tw1{1});
[errn,ccn]=waveleterr(w,tw,w1n{1},tw1{1});
[errna,ccna]=waveleterr(w,tw,w1na{1},tw1{1});
it=near(tw,tw(1),tw(end));
names={'true',...
    ['no noise estimate, mu=' num2str(0*mu) ', err=' num2str(err1a), ...
    ', cc(1)=' num2str(sigfig(cc1a(1),2)) ', cc(2)=' num2str(cc1a(2)) ', pep=' num2str(pep1a,2)],...
    ['no noise estimate, mu=' num2str(mu) ', err=' num2str(err1), ...
    ', cc(1)=' num2str(sigfig(cc1(1),2)) ', cc(2)=' num2str(cc1(2)) ', pep=' num2str(pep1,2)],...
       ['noisy estimate, mu=' num2str(0*mu) ', err=' num2str(errna), ...
    ', cc(1)=' num2str(sigfig(ccna(1),2)) ', cc(2)=' num2str(ccna(2)) ', pep=' num2str(pep1na,2)],...
    ['noisy estimate, mu=' num2str(mu) ', err=' num2str(errn), ...
    ', cc(1)=' num2str(sigfig(ccn(1),2)) ', cc(2)=' num2str(ccn(2)) ', pep=' num2str(pep1n,2)]};

hh2=trplot({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'zerolines','y','normalize',1,'order','d');
set(hh2{2},'color',get(hh{3},'color'));
set(hh2{3},'color',get(hh{4},'color'));
set(hh2{4},'color',get(hh{6},'color'));
set(hh2{5},'color',get(hh{7},'color'));
%ylim([-.15 .65])

title({['estimated wavelets, pctnotcausal=' num2str(pctnotcausal)],...
    'error and correlations in legend wrt true wavelet'} )
titlefontsize(.75)

subplotabc('botb')
if(jcausal)
    if(pctnotcausal==0)
        wf=[2 ones(1,4)];
    else
        wf=2*ones(1,5);
    end
else
    if(pctnotcausal==0)
        wf=ones(1,5);
    else
       wf=[1 2*ones(1,4)]; 
    end
end
hh3=dbspec({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'windowflags',wf,'normoption',1);
set(hh3{2},'color',get(hh{3},'color'));
set(hh3{3},'color',get(hh{4},'color'));
set(hh3{4},'color',get(hh{6},'color'));
set(hh3{5},'color',get(hh{7},'color'));
ylim([-100,0]);
legend([hh3{1}(1) hh3{2}(1) hh3{3}(1) hh3{4}(1) hh3{5}(1)],names,'location','southwest')
title('estimated wavelets spectra')
titlefontsize(.75)


prepfiga
%% #8 match filter using matchT, both time and smoothness constraints
pctnotcausal=50;%percentage of wavelet samples belore time zero
t1=.7;t2=1.2;%estimation time window
wsize=.5;%a fraction of window size
mu=[1 10];

[w1,tw1]=extract_wavelets_matchT(s,t,r,.5*(t1+t2),t2-t1,wsize,mu,pctnotcausal);%no noise smooth
w1a=extract_wavelets_matchT(s,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,pctnotcausal);%no noise not smooth
w1n=extract_wavelets_matchT(sn,t,r,.5*(t1+t2),t2-t1,wsize,mu,pctnotcausal);%noisy smooth
w1na=extract_wavelets_matchT(sn,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,pctnotcausal);%noisy not smooth

pep1=penpred(s,r,w1{1},tw1{1});
pep1a=penpred(s,r,w1a{1},tw1{1});
pep1n=penpred(s,r,w1n{1},tw1{1});
pep1na=penpred(s,r,w1na{1},tw1{1});

%model traces  
izero=near(tw1{1},0);
sm1=convz(r,w1{1},izero);
sm1a=convz(r,w1a{1},izero);
snm1=convz(r,w1n{1},izero);
snm1a=convz(r,w1na{1},izero);

%ccorelation coefficients
rbl=convz(r,tozero(w1{1}));
nlags=50;
aflag=1;
ccs=maxcorr(rbl,s,nlags,aflag);
ccsm1=maxcorr(rbl,sm1,nlags,aflag);
ccsm1a=maxcorr(rbl,sm1a,nlags,aflag);
ccsn=maxcorr(rbl,sn,nlags,aflag);
ccsnm1=maxcorr(rbl,snm1,nlags,aflag);
ccsnm1a=maxcorr(rbl,snm1a,nlags,aflag);


figure
subplotabc('top')
names={'reflectivity',['no noise, cc(1)=' num2str(ccs(1),2) ', cc(2)=' num2str(ccs(2),3)],...
    ['no noise model trace unconstrained, cc(1)=' num2str(ccsm1a(1),2) ', cc(2)=' num2str(ccsm1a(2),3)],...
    ['no noise model trace constrained, cc(1)=' num2str(ccsm1(1),2) ', cc(2)=' num2str(ccsm1(2),3)],...
    ['noisy, s2n= ' num2str(s2n) ', cc(1)=' num2str(ccsn(1),2) ', cc(2)=' num2str(ccsn(2),3) ],...
    ['noisy model trace unconstrained, cc(1)=' num2str(ccsnm1a(1),2) ', cc(2)=' num2str(ccsnm1a(2),3)],...
    ['noisy model trace constrained, cc(1)=' num2str(ccsnm1(1),2) ', cc(2)=' num2str(ccsnm1(2),3)]};
hh=trplot(t,[r,s,sm1a,sm1,sn,snm1a,snm1],'normalize',1,'tracespacing',1.5,'names',names,'order','d');
set(gca,'ylim',[-5 8])
set(gca,'xlim',[0 max(t)+.7])
yl=get(gca,'ylim');
xtick(0:.2:2)
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
title({dname,'wavelet estimation with TIME+SMOOTHNESS-constrained match filter,  green lines show extraction window'})
titlefontsize(.75)

subplotabc('bota')
[err1,cc1]=waveleterr(w,tw,w1{1},tw1{1});
[err1a,cc1a]=waveleterr(w,tw,w1a{1},tw1{1});
[errn,ccn]=waveleterr(w,tw,w1n{1},tw1{1});
[errna,ccna]=waveleterr(w,tw,w1na{1},tw1{1});
it=near(tw,tw(1),tw(end));
names={'true',...
    ['no noise estimate, mu=' num2str(0*mu) ', err=' num2str(err1a), ...
    ', cc(1)=' num2str(sigfig(cc1a(1),2)) ', cc(2)=' num2str(cc1a(2)) ', pep=' num2str(pep1a,2)],...
    ['no noise estimate, mu=' num2str(mu) ', err=' num2str(err1), ...
    ', cc(1)=' num2str(sigfig(cc1(1),2)) ', cc(2)=' num2str(cc1(2)) ', pep=' num2str(pep1,2)],...
       ['noisy estimate, mu=' num2str(0*mu) ', err=' num2str(errna), ...
    ', cc(1)=' num2str(sigfig(ccna(1),2)) ', cc(2)=' num2str(ccna(2)) ', pep=' num2str(pep1na,2)],...
    ['noisy estimate, mu=' num2str(mu) ', err=' num2str(errn), ...
    ', cc(1)=' num2str(sigfig(ccn(1),2)) ', cc(2)=' num2str(ccn(2)) ', pep=' num2str(pep1n,2)]};

hh2=trplot({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'zerolines','y','normalize',1,'order','d');
set(hh2{2},'color',get(hh{3},'color'));
set(hh2{3},'color',get(hh{4},'color'));
set(hh2{4},'color',get(hh{6},'color'));
set(hh2{5},'color',get(hh{7},'color'));
%ylim([-.15 .65])
%legend([hh2{1}(1) hh2{2}(1) hh2{3}(1) hh2{4}(1) hh2{5}(1)],names)
title({['estimated wavelets, pctnotcausal=' num2str(pctnotcausal)],...
    'error and correlations in legend wrt true wavelet'} )
titlefontsize(.75)

subplotabc('botb')
if(jcausal)
    if(pctnotcausal==0)
        wf=[2 ones(1,4)];
    else
        wf=2*ones(1,5);
    end
else
    if(pctnotcausal==0)
        wf=ones(1,5);
    else
       wf=[1 2*ones(1,4)]; 
    end
end
hh3=dbspec({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'windowflags',wf,'normoption',1);
set(hh3{2},'color',get(hh{3},'color'));
set(hh3{3},'color',get(hh{4},'color'));
set(hh3{4},'color',get(hh{6},'color'));
set(hh3{5},'color',get(hh{7},'color'));
ylim([-100,0]);
legend([hh3{1}(1) hh3{2}(1) hh3{3}(1) hh3{4}(1) hh3{5}(1)],names,'location','southwest')
title('estimated wavelets spectra')
titlefontsize(.75)

prepfiga

%% #9 Roy White time domain smoothness constraint only
pctnotcausal=50;%percentage of wavelet samples belore time zero
t1=.7;t2=1.2;%estimation time window
wsize=.5;%a fraction of window size
mu=[1 0];%smootheness constraint
stab=.0001;%not used in time domain
fsmo=5;%not used in time domain
method='three';%this is the flag for time domain
[w1,tw1]=extract_wavelets_roywhite(s,t,r,.5*(t1+t2),t2-t1,wsize,mu,stab,fsmo,method,pctnotcausal);%no noise smooth
w1a=extract_wavelets_roywhite(s,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,stab,fsmo,method,pctnotcausal);%no noise not smooth
w1n=extract_wavelets_roywhite(sn,t,r,.5*(t1+t2),t2-t1,wsize,mu,stab,fsmo,method,pctnotcausal);%noisy smooth
w1na=extract_wavelets_roywhite(sn,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,stab,fsmo,method,pctnotcausal);%noisy not smooth

pep1=penpred(s,r,w1{1},tw1{1});
pep1a=penpred(s,r,w1a{1},tw1{1});
pep1n=penpred(s,r,w1n{1},tw1{1});
pep1na=penpred(s,r,w1na{1},tw1{1});


%model traces
izero=near(tw1{1},0);
sm1=convz(r,w1{1},izero);
sm1a=convz(r,w1a{1},izero);
snm1=convz(r,w1n{1},izero);
snm1a=convz(r,w1na{1},izero);

%ccorelation coefficients
rbl=convz(r,tozero(w1{1}));
nlags=50;
aflag=1;
ccs=maxcorr(rbl,s,nlags,aflag);
ccsm1=maxcorr(rbl,sm1,nlags,aflag);
ccsm1a=maxcorr(rbl,sm1a,nlags,aflag);
ccsn=maxcorr(rbl,sn,nlags,aflag);
ccsnm1=maxcorr(rbl,snm1,nlags,aflag);
ccsnm1a=maxcorr(rbl,snm1a,nlags,aflag);

% w1n2=w1n2{1};
% tw1n2=tw1n2{1};
figure
subplotabc('top')
names={'reflectivity',['no noise, cc(1)=' num2str(ccs(1),2) ', cc(2)=' num2str(ccs(2),3)],...
    ['no noise model trace unconstrained, cc(1)=' num2str(ccsm1a(1),2) ', cc(2)=' num2str(ccsm1a(2),3)],...
    ['no noise model trace constrained, cc(1)=' num2str(ccsm1(1),2) ', cc(2)=' num2str(ccsm1(2),3)],...
    ['noisy, s2n= ' num2str(s2n) ', cc(1)=' num2str(ccsn(1),2) ', cc(2)=' num2str(ccsn(2),3) ],...
    ['noisy model trace unconstrained, cc(1)=' num2str(ccsnm1a(1),2) ', cc(2)=' num2str(ccsnm1a(2),3)],...
    ['noisy model trace constrained, cc(1)=' num2str(ccsnm1(1),2) ', cc(2)=' num2str(ccsnm1(2),3)]};
hh=trplot(t,[r,s,sm1a,sm1,sn,snm1a,snm1],'normalize',1,'tracespacing',1.5,'names',names,'order','d');
set(gca,'ylim',[-5 8])
set(gca,'xlim',[0 max(t)+.7])
yl=get(gca,'ylim');
xtick(0:.2:2)
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
title({dname,'wavelet estimation with Roy White''s method (time-domain, SMOOTHNESS constraint), green lines show extraction window'})
titlefontsize(.75)

subplotabc('bota')
[err1,cc1]=waveleterr(w,tw,w1{1},tw1{1});
[err1a,cc1a]=waveleterr(w,tw,w1a{1},tw1{1});
[errn,ccn]=waveleterr(w,tw,w1n{1},tw1{1});
[errna,ccna]=waveleterr(w,tw,w1na{1},tw1{1});
it=near(tw,tw(1),tw(end));
names={'true',...
    ['no noise estimate, mu=' num2str(0*mu) ', err=' num2str(err1a), ...
    ', cc(1)=' num2str(sigfig(cc1a(1),2)) ', cc(2)=' num2str(cc1a(2)) ', pep=' num2str(pep1a,2)],...
    ['no noise estimate, mu=' num2str(mu) ', err=' num2str(err1), ...
    ', cc(1)=' num2str(sigfig(cc1(1),2)) ', cc(2)=' num2str(cc1(2)) ', pep=' num2str(pep1,2)],...
    ['noisy estimate, mu=' num2str(0*mu) ', err=' num2str(errna), ...
    ', cc(1)=' num2str(sigfig(ccna(1),2)) ', cc(2)=' num2str(ccna(2)) ', pep=' num2str(pep1na,2)],...
   ['noisy estimate, mu=' num2str(mu) ', err=' num2str(errn), ...
    ', cc(1)=' num2str(sigfig(ccn(1),2)) ', cc(2)=' num2str(ccn(2)) ', pep=' num2str(pep1n,2)]};
hh2=trplot({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'zerolines','y','normalize',1,'order','d');
set(hh2{2},'color',get(hh{3},'color'));
set(hh2{3},'color',get(hh{4},'color'));
set(hh2{4},'color',get(hh{6},'color'));
set(hh2{5},'color',get(hh{7},'color'));
%ylim([-.15 .7])

title({['estimated wavelets, pctnotcausal=' num2str(pctnotcausal)],...
    'error and correlations in legend wrt true wavelet'} )
titlefontsize(.75)

subplotabc('botb')
if(jcausal)
    wf=[2 ones(1,4)];
else
    wf=ones(1,5);
end
hh3=dbspec({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'windowflags',wf,'normoption',1);
set(hh3{2},'color',get(hh{3},'color'));
set(hh3{3},'color',get(hh{4},'color'));
set(hh3{4},'color',get(hh{6},'color'));
set(hh3{5},'color',get(hh{7},'color'));
ylim([-100,0]);
legend([hh3{1}(1) hh3{2}(1) hh3{3}(1) hh3{4}(1) hh3{5}(1)],names,'location','southwest')
title('estimated wavelets spectra')
titlefontsize(.75)



prepfiga
%% #10 Roy White time domain smoothness and time constraint
pctnotcausal=50;%percentage of wavelet samples belore time zero
t1=.7;t2=1.2;%estimation time window
wsize=.5;%a fraction of window size
mu=[1 10];%smootheness constraint
stab=.0001;%not used in time domain
fsmo=5;%not used in time domain
method='three';%this is the flag for time domain
[w1,tw1]=extract_wavelets_roywhite(s,t,r,.5*(t1+t2),t2-t1,wsize,mu,stab,fsmo,method,pctnotcausal);%no noise smooth
w1a=extract_wavelets_roywhite(s,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,stab,fsmo,method,pctnotcausal);%no noise not smooth
w1n=extract_wavelets_roywhite(sn,t,r,.5*(t1+t2),t2-t1,wsize,mu,stab,fsmo,method,pctnotcausal);%noisy smooth
w1na=extract_wavelets_roywhite(sn,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,stab,fsmo,method,pctnotcausal);%noisy not smooth

pep1=penpred(s,r,w1{1},tw1{1});
pep1a=penpred(s,r,w1a{1},tw1{1});
pep1n=penpred(s,r,w1n{1},tw1{1});
pep1na=penpred(s,r,w1na{1},tw1{1});


%model traces
izero=near(tw1{1},0);
sm1=convz(r,w1{1},izero);
sm1a=convz(r,w1a{1},izero);
snm1=convz(r,w1n{1},izero);
snm1a=convz(r,w1na{1},izero);

%ccorelation coefficients
rbl=convz(r,tozero(w1{1}));
nlags=50;
aflag=1;
ccs=maxcorr(rbl,s,nlags,aflag);
ccsm1=maxcorr(rbl,sm1,nlags,aflag);
ccsm1a=maxcorr(rbl,sm1a,nlags,aflag);
ccsn=maxcorr(rbl,sn,nlags,aflag);
ccsnm1=maxcorr(rbl,snm1,nlags,aflag);
ccsnm1a=maxcorr(rbl,snm1a,nlags,aflag);

% w1n2=w1n2{1};
% tw1n2=tw1n2{1};
figure
subplotabc('top')
names={'reflectivity',['no noise, cc(1)=' num2str(ccs(1),2) ', cc(2)=' num2str(ccs(2),3)],...
    ['no noise model trace unconstrained, cc(1)=' num2str(ccsm1a(1),2) ', cc(2)=' num2str(ccsm1a(2),3)],...
    ['no noise model trace constrained, cc(1)=' num2str(ccsm1(1),2) ', cc(2)=' num2str(ccsm1(2),3)],...
    ['noisy, s2n= ' num2str(s2n) ', cc(1)=' num2str(ccsn(1),2) ', cc(2)=' num2str(ccsn(2),3) ],...
    ['noisy model trace unconstrained, cc(1)=' num2str(ccsnm1a(1),2) ', cc(2)=' num2str(ccsnm1a(2),3)],...
    ['noisy model trace constrained, cc(1)=' num2str(ccsnm1(1),2) ', cc(2)=' num2str(ccsnm1(2),3)]};
hh=trplot(t,[r,s,sm1a,sm1,sn,snm1a,snm1],'normalize',1,'tracespacing',1.5,'names',names,'order','d');
set(gca,'ylim',[-5 8])
set(gca,'xlim',[0 max(t)+.7])
yl=get(gca,'ylim');
xtick(0:.2:2)
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
title({dname,'wavelet estimation with Roy White''s method (time-domain, TIME+SMOOTHNESS constraints), green lines show extraction window'})
titlefontsize(.75)

subplotabc('bota')
[err1,cc1]=waveleterr(w,tw,w1{1},tw1{1});
[err1a,cc1a]=waveleterr(w,tw,w1a{1},tw1{1});
[errn,ccn]=waveleterr(w,tw,w1n{1},tw1{1});
[errna,ccna]=waveleterr(w,tw,w1na{1},tw1{1});
it=near(tw,tw(1),tw(end));
names={'true',...
    ['no noise estimate, mu=' num2str(0*mu) ', err=' num2str(err1a), ...
    ', cc(1)=' num2str(sigfig(cc1a(1),2)) ', cc(2)=' num2str(cc1a(2)) ', pep=' num2str(pep1a,2)],...
    ['no noise estimate, mu=' num2str(mu) ', err=' num2str(err1), ...
    ', cc(1)=' num2str(sigfig(cc1(1),2)) ', cc(2)=' num2str(cc1(2)) ', pep=' num2str(pep1,2)],...
    ['noisy estimate, mu=' num2str(0*mu) ', err=' num2str(errna), ...
    ', cc(1)=' num2str(sigfig(ccna(1),2)) ', cc(2)=' num2str(ccna(2)) ', pep=' num2str(pep1na,2)],...
   ['noisy estimate, mu=' num2str(mu) ', err=' num2str(errn), ...
    ', cc(1)=' num2str(sigfig(ccn(1),2)) ', cc(2)=' num2str(ccn(2)) ', pep=' num2str(pep1n,2)]};
hh2=trplot({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'zerolines','y','normalize',1,'order','d');
set(hh2{2},'color',get(hh{3},'color'));
set(hh2{3},'color',get(hh{4},'color'));
set(hh2{4},'color',get(hh{6},'color'));
set(hh2{5},'color',get(hh{7},'color'));
%ylim([-.15 .7])

title({['estimated wavelets, pctnotcausal=' num2str(pctnotcausal)],...
    'error and correlations in legend wrt true wavelet'} )
titlefontsize(.75)

subplotabc('botb')
if(jcausal)
    wf=[2 ones(1,4)];
else
    wf=ones(1,5);
end
hh3=dbspec({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'windowflags',wf,'normoption',1);
set(hh3{2},'color',get(hh{3},'color'));
set(hh3{3},'color',get(hh{4},'color'));
set(hh3{4},'color',get(hh{6},'color'));
set(hh3{5},'color',get(hh{7},'color'));
ylim([-100,0]);
legend([hh3{1}(1) hh3{2}(1) hh3{3}(1) hh3{4}(1) hh3{5}(1)],names,'location','southwest')
title('estimated wavelets spectra')
titlefontsize(.75)



prepfiga
%% #11 Roy White frequency domain
pctnotcausal=50;%percentage of wavelet samples belore time zero, not used in frequency domain
t1=.7;t2=1.2;%estimation time window
wsize=.5;%a fraction of window size
mu=[1 10];%smootheness constraint (not used)
stab=.01;%stability constant in spectral division
fsmo=1;%frequency domain smoother width
method='two';%this is the flag for frequency domain
[w1,tw1]=extract_wavelets_roywhite(s,t,r,.5*(t1+t2),t2-t1,wsize,mu,stab,fsmo,method,pctnotcausal);%no noise smooth
w1a=extract_wavelets_roywhite(s,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,stab,fsmo,method,pctnotcausal);%no noise not smooth
w1n=extract_wavelets_roywhite(sn,t,r,.5*(t1+t2),t2-t1,wsize,mu,stab,fsmo,method,pctnotcausal);%noisy smooth
w1na=extract_wavelets_roywhite(sn,t,r,.5*(t1+t2),t2-t1,wsize,0*mu,stab,fsmo,method,pctnotcausal);%noisy not smooth

pep1=penpred(s,r,w1{1},tw1{1});
pep1a=penpred(s,r,w1a{1},tw1{1});
pep1n=penpred(s,r,w1n{1},tw1{1});
pep1na=penpred(s,r,w1na{1},tw1{1});


%model traces
izero=near(tw1{1},0);
sm1=convz(r,w1{1},izero);
sm1a=convz(r,w1a{1},izero);
snm1=convz(r,w1n{1},izero);
snm1a=convz(r,w1na{1},izero);

%ccorelation coefficients
rbl=convz(r,tozero(w1{1}));
nlags=50;
aflag=1;
ccs=maxcorr(rbl,s,nlags,aflag);
ccsm1=maxcorr(rbl,sm1,nlags,aflag);
ccsm1a=maxcorr(rbl,sm1a,nlags,aflag);
ccsn=maxcorr(rbl,sn,nlags,aflag);
ccsnm1=maxcorr(rbl,snm1,nlags,aflag);
ccsnm1a=maxcorr(rbl,snm1a,nlags,aflag);

% w1n2=w1n2{1};
% tw1n2=tw1n2{1};
figure
subplotabc('top')
names={'reflectivity',['no noise, cc(1)=' num2str(ccs(1),2) ', cc(2)=' num2str(ccs(2),3)],...
    ['no noise model trace unconstrained, cc(1)=' num2str(ccsm1a(1),2) ', cc(2)=' num2str(ccsm1a(2),3)],...
    ['no noise model trace constrained, cc(1)=' num2str(ccsm1(1),2) ', cc(2)=' num2str(ccsm1(2),3)],...
    ['noisy, s2n= ' num2str(s2n) ', cc(1)=' num2str(ccsn(1),2) ', cc(2)=' num2str(ccsn(2),3) ],...
    ['noisy model trace unconstrained, cc(1)=' num2str(ccsnm1a(1),2) ', cc(2)=' num2str(ccsnm1a(2),3)],...
    ['noisy model trace constrained, cc(1)=' num2str(ccsnm1(1),2) ', cc(2)=' num2str(ccsnm1(2),3)]};
hh=trplot(t,[r,s,sm1a,sm1,sn,snm1a,snm1],'normalize',1,'tracespacing',1.5,'names',names,'order','d');
set(gca,'ylim',[-5 8])
set(gca,'xlim',[0 max(t)+.7])
yl=get(gca,'ylim');
xtick(0:.2:2)
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',1);
title({dname,'wavelet estimation with Roy White''s method (frequency-domain), green lines show extraction window'})
titlefontsize(.75)

subplotabc('bota')
[err1,cc1]=waveleterr(w,tw,w1{1},tw1{1});
[err1a,cc1a]=waveleterr(w,tw,w1a{1},tw1{1});
[errn,ccn]=waveleterr(w,tw,w1n{1},tw1{1});
[errna,ccna]=waveleterr(w,tw,w1na{1},tw1{1});
it=near(tw,tw(1),tw(end));
names={'true',...
    ['no noise estimate, mu=' num2str(0*mu) ', err=' num2str(err1a), ...
    ', cc(1)=' num2str(sigfig(cc1a(1),2)) ', cc(2)=' num2str(cc1a(2)) ', pep=' num2str(pep1a,2)],...
    ['no noise estimate, mu=' num2str(mu) ', err=' num2str(err1), ...
    ', cc(1)=' num2str(sigfig(cc1(1),2)) ', cc(2)=' num2str(cc1(2)) ', pep=' num2str(pep1,2)],...
    ['noisy estimate, mu=' num2str(0*mu) ', err=' num2str(errna), ...
    ', cc(1)=' num2str(sigfig(ccna(1),2)) ', cc(2)=' num2str(ccna(2)) ', pep=' num2str(pep1na,2)],...
   ['noisy estimate, mu=' num2str(mu) ', err=' num2str(errn), ...
    ', cc(1)=' num2str(sigfig(ccn(1),2)) ', cc(2)=' num2str(ccn(2)) ', pep=' num2str(pep1n,2)]};
hh2=trplot({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'zerolines','y','normalize',1,'order','d');
set(hh2{2},'color',get(hh{3},'color'));
set(hh2{3},'color',get(hh{4},'color'));
set(hh2{4},'color',get(hh{6},'color'));
set(hh2{5},'color',get(hh{7},'color'));
%ylim([-.15 .7])

title({['estimated wavelets, pctnotcausal=' num2str(pctnotcausal)],...
    'error and correlations in legend wrt true wavelet'} )
titlefontsize(.75)

subplotabc('botb')
if(jcausal)
    wf=[2 ones(1,4)];
else
    wf=ones(1,5);
end
hh3=dbspec({tw(it) tw1{1} tw1{1} tw1{1} tw1{1}},{w(it),w1a{1},w1{1},w1na{1},w1n{1}},'windowflags',wf,'normoption',1);
set(hh3{2},'color',get(hh{3},'color'));
set(hh3{3},'color',get(hh{4},'color'));
set(hh3{4},'color',get(hh{6},'color'));
set(hh3{5},'color',get(hh{7},'color'));
ylim([-100,0]);
legend([hh3{1}(1) hh3{2}(1) hh3{3}(1) hh3{4}(1) hh3{5}(1)],names,'location','southwest')
title('estimated wavelets spectra')
titlefontsize(.75)



prepfiga

%% #12 Simple explorer
waveex_simple(s,t,r,t,[dname ' noise free trace'],w,tw)% noise free trace
waveex_simple(sn,t,r,t,[dname ' noisy trace'],w,tw)% noisy trace
%% #13 Match filter explorer
waveex_match(s,t,r,t,[dname ' noise free trace'],w,tw)% noise free trace
waveex_match(sn,t,r,t,[dname ' noisy trace'],w,tw)% noisy trace
%% #14 Roy white explorer
waveex_rw(s,t,r,t,[dname ' noise free trace'],w,tw)% noise free trace
waveex_rw(sn,t,r,t,[dname ' noisy trace'],w,tw)% noisy trace

%% build a nonstationary synthetic
dt=.002;
tmax=2;
fdom=30;
Q=70;
tlen=.3;
[w,tw]=wavemin(dt,fdom,tlen);
[r,t]=reflec(tmax,dt,.1,3,pi);
qmat=qmatrix(Q,t,w,tw);
s=qmat*r;
dname=['Nonstationary synthetic, no noise, fdom=' num2str(fdom) ...
    ', dt=' num2str(dt) ', Q=' num2str(Q) ...
    ', rseed=' num2str(pi)];

irange=near(t,.75,1.25);
s2n=2;
n=rnoise(s,s2n,irange);
sn=s+n;
tr=t;
name=dname;
save('waveex_minphase_stat','s','sn','s2n','t','r','tr','w','tw','name');
%% test match on nonstat
t1=.5;t2=1;
tc=.5*(t1+t2);
iwc=near(t,tc);
iwr=near(t,tc,tc+tlen);
w=qmat(iwr,iwc);
tw=dt*(0:length(w)-1)';
wlen=.2;
[w1,tw1]=waveex_match(s,t,r,t,t1,t2,wlen);
figure
subplot(2,1,1)
trplot(t,[r,s],'normalize',1);
yl=get(gca,'ylim');
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',3);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',3);
title('match filter')
subplot(2,1,2)
[err,cc]=waveleterr(w,tw,w1,tw1);
trplot({tw tw1},{w,w1},'names',{'true','estimate'},'zerolines','y');

title(['estimate wlen=' time2str(wlen),...
    ', err=' num2str(err), ', cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))])
%% test roy white on nonstat
t1=.5;t2=1;
tc=.5*(t1+t2);
iwc=near(t,tc);
iwr=near(t,tc,tc+tlen);
w=qmat(iwr,iwc);
tw=dt*(0:length(w)-1)';
wlen=.1;
[w1,tw1]=waveest_roywhite(s,t,r,t,t1,t2,wlen);
figure
subplot(2,1,1)
trplot(t,[r,s]);
yl=get(gca,'ylim');
line([t1 t1],yl,'color',[0 .8 0],'linestyle',':','linewidth',3);
line([t2 t2],yl,'color',[0 .8 0],'linestyle',':','linewidth',3);
title('Roy White')
subplot(2,1,2)
[err,cc]=waveleterr(w,tw,w1,tw1);
trplot({tw tw1},{w,w1},'names',{'true','estimate'},'zerolines','y');
title(['estimate wlen=' time2str(wlen) ', err=' num2str(err), ', cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))])
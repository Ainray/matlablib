%% #1 min phase synthetic, reflectivity generated in depth and converted to time
% this is the simplest and perfect case
s2n=3;%signal to noise ratio
Q=inf;
rseed=pi;%random number seed for reflectivity
dt=.002;%time sample rate
fdom=30;%dominant frequency
tlen=.3;%wavelet length in seconds
dname=['min phase synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
dname2=['min phase synthetic, s2n=' num2str(s2n) ', fdom=' num2str(fdom) ', dt=' num2str(dt) ', rseed=' num2str(rseed)];
[w,tw]=wavemin(dt,fdom,tlen);
zmax=3000;
dz=1/3.28;
v=3000;
[rz,zz]=reflec(zmax,dz,.1,5,rseed);%relectivity in depth
I=rcs2imp1(rz,1000);
z=[0;zz+dz];
tz=2*z/v;
[r,t]=imp2rcs_t(I,tz,dt);
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

%% #2 nonstationary synthetic, full log, no alignment problems
% the nonstationarity is a fundamental increase in difficulty.
s2n=2;
dt=.002;
rseed=pi;
fdom=60;
Q=70;
tlen=.3;
tbulk=0;
[w,tw]=wavemin(dt,fdom,tlen);
zmax=3000;%meters
zstart=0;%start of log;
zend=zmax;%end of log;
dz=1/3.28;%1 ft in metric
v=3000;
[rz,zz]=reflec(zmax,dz,.1,5,rseed);%reflectivity in depth
I1=rcs2imp1(rz,1000);
z1=[0;zz+dz];
tz1=2*z1/v;
[r1,t]=imp2rcs_t(I1,tz1,dt);
qmat_tmp=qmatrix(Q,t,w,tw,3,2);
%drift correct the Q matrix
x=v*t;
td=2*tdrift(Q,x,v*ones(size(x)),fdom,12500);
qmat=zeros(length(t));
for k=1:length(x)
   tmp=stat(qmat_tmp(:,k),t,-td(k));
   qmat(:,k)=tmp(1:length(t));
end

s=qmat*r1;%trace made from full length r
dname=['Nonstationary synthetic, s2n=' num2str(0) ', fdom=' num2str(fdom) ...
    ', dt=' num2str(dt) ', Q=' num2str(Q) ...
    ', rseed=' num2str(rseed)];

irange=near(t,.75,1.25);

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
[r,tr]=imp2rcs_t(I,tz,dt);

jcausal=1;
name=dname;
save('waveex_minphase_nonstat','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
tmp=s;
s=sn;
name=dname2;
save('waveex_minphase_nonstat_noise','s','t','r','tr','w','tw','name','jcausal','I','z','tz');
s=tmp;

%% #3 plot the input data

figure
names={'reflectivity','noise-free trace',['noisy trace, s2n=' num2str(s2n)]};
subplotabc('top')
trplot({tr,t,t},{r s sn},'order','d','normalize',1)
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
hhs=dbspec(t,[pad_trace(r,s) s sn wp],'windowflags',wflags);
title('spectra')
names={'reflectivity','noise-free trace',['noisy trace, s2n=' num2str(s2n)],'wavelet'};
legend(names,'location','southwest');
set(hhw{1},'color',get(hhs{4},'color'))
prepfiga


%% #4 test simple no noise
t0s=[.5 1 1.5];%estimation window times
twins=.5*ones(size(t0s));%estimation window width in seconds
wlen=.5;%expressed as a fraction of twins
fsmo=10;
fmin=0;
fmax=100;
s=balans(s,r);
[w_est,tw_est,static,phs]=extract_wavelets_simple(s,t,r,t0s,twins,fsmo,wlen,fmin,fmax);
%get true wavelets
w_true=cell(size(w_est));
tw_true=w_true;
if(isinf(Q))
   for k=1:length(w_true)
      w_true{k}=max(w_est{k})*w/max(w);
      tw_true{k}=tw;
   end
else
   for k=1:length(w_true)
      j=near(t,t0s(k));
      ind=near(t,t(j(1))-.5*twins(k),t(j(1))+.5*twins(k));
      tmp=qmat(ind,j(1));
      w_true{k}=max(w_est{k})*tmp/max(tmp);
      tw_true{k}=t(ind)-t(j(1));
   end 
end
figure
subplot('position',[.1,.1,.4,.8]);
inc=max(abs(s));
plot(s,t,r+inc,t,'k');flipy;grid
xl=get(gca,'xlim');
co=get(gca,'colororder');
for k=1:length(t0s)
    line(xl,[t0s(k) t0s(k)],'color',co(k+1,:));
    text(xl(1),t0s(k),['Window ' int2str(k) ', width=' num2str(twins(k))])
end
if(~isinf(Q))
    title('Input data, nonstationary but drift corrected')
else
    title('Input data, stationary')
end
ht=.1;
for k=1:length(t0s)
    ynow=interp1([0 t(end)],[.95-ht .05],t0s(k));
    subplot('position',[.6 ynow .3 ht])
    [err,cc,phserr]=waveleterr(w_true{k},tw_true{k},w_est{k},tw_est{k});
    hh=plot(tw_true{k},w_true{k},tw_est{k},w_est{k});
    hh(2).Color=co(k+1,:);
    legend('true','estimate','location','southeast');
    title({['Simple method',', err=' num2str(err), ', cc(1)=' num2str(sigfig(cc(1),2))...
        ', cc(2)=' num2str(cc(2)),', phserr=' int2str(phserr)],['fsmo= ' int2str(fsmo),...
        ', fmin= ',int2str(fmin),', fmax= ' int2str(fmax)]})
    titlefontsize(.8,2)
end
prepfig
%% #5 test match no noise
t0s=[.5 1 1.5];%estimation window times
twins=.5*ones(size(t0s));%estimation window width in seconds
wlen=.5;%expressed as a fraction of twins
mu=10;
pctnoncausal=50;
s=balans(s,r);
[w_est,tw_est]=extract_wavelets_match(s,t,r,t0s,twins,wlen,mu,pctnoncausal);
%get true wavelets
w_true=cell(size(w_est));
tw_true=w_true;
if(isinf(Q))
   for k=1:length(w_true)
      w_true{k}=max(w_est{k})*w/max(w);
      tw_true{k}=tw;
   end
else
   for k=1:length(w_true)
      j=near(t,t0s(k));
      ind=near(t,t(j(1))-.5*twins(k),t(j(1))+.5*twins(k));
      tmp=qmat(ind,j(1));
      w_true{k}=max(w_est{k})*tmp/max(tmp);
      tw_true{k}=t(ind)-t(j(1));
   end 
end
figure
subplot('position',[.1,.1,.4,.8]);
inc=max(abs(s));
plot(s,t,r+inc,t,'k');flipy;grid
xl=get(gca,'xlim');
co=get(gca,'colororder');
for k=1:length(t0s)
    line(xl,[t0s(k) t0s(k)],'color',co(k+1,:));
    text(xl(1),t0s(k),['Window ' int2str(k) ', width=' num2str(twins(k))])
end
if(~isinf(Q))
    title('Input data, nonstationary but drift corrected')
else
    title('Input data, stationary')
end
ht=.1;
for k=1:length(t0s)
    ynow=interp1([0 t(end)],[.95-ht .05],t0s(k));
    subplot('position',[.6 ynow .3 ht])
    [err,cc,phserr]=waveleterr(w_true{k},tw_true{k},w_est{k},tw_est{k});
    hh=plot(tw_true{k},w_true{k},tw_est{k},w_est{k});
    hh(2).Color=co(k+1,:);
    legend('true','estimate','location','southeast');
    title({['Match method',', err=' num2str(err), ', cc(1)=' num2str(sigfig(cc(1),2))...
        ', cc(2)=' num2str(cc(2)),', phserr=' int2str(phserr)],['mu=' num2str(mu)]})
    titlefontsize(.8,2)
end
prepfig
%% #6 test simple with noise
t0s=[.5 1 1.5];%estimation window times
twins=.5*ones(size(t0s));%estimation window width in seconds
wlen=.5;%expressed as a fraction of twins
fsmo=10;
fmin=0;
fmax=100;
sn=balans(sn,r);
[w_est,tw_est,static,phs]=extract_wavelets_simple(sn,t,r,t0s,twins,fsmo,wlen,fmin,fmax);
%get true wavelets
w_true=cell(size(w_est));
tw_true=w_true;
if(isinf(Q))
   for k=1:length(w_true)
      w_true{k}=max(w_est{k})*w/max(w);
      tw_true{k}=tw;
   end
else
   for k=1:length(w_true)
      j=near(t,t0s(k));
      ind=near(t,t(j(1))-.5*twins(k),t(j(1))+.5*twins(k));
      tmp=qmat(ind,j(1));
      w_true{k}=max(w_est{k})*tmp/max(tmp);
      tw_true{k}=t(ind)-t(j(1));
   end 
end
figure
subplot('position',[.1,.1,.4,.8]);
inc=max(abs(sn));
plot(sn,t,r+inc,t,'k');flipy;grid
xl=get(gca,'xlim');
co=get(gca,'colororder');
for k=1:length(t0s)
    line(xl,[t0s(k) t0s(k)],'color',co(k+1,:));
    text(xl(1),t0s(k),['Window ' int2str(k) ', width=' num2str(twins(k))])
end
if(~isinf(Q))
    title('Input data noisy, nonstationary but drift corrected')
else
    title('Input data noisy, stationary')
end
ht=.1;
for k=1:length(t0s)
    ynow=interp1([0 t(end)],[.95-ht .05],t0s(k));
    subplot('position',[.6 ynow .3 ht])
    [err,cc,phserr]=waveleterr(w_true{k},tw_true{k},w_est{k},tw_est{k});
    hh=plot(tw_true{k},w_true{k},tw_est{k},w_est{k});
    hh(2).Color=co(k+1,:);
    legend('true','estimate','location','southeast');
    title({['Simple method',', err=' num2str(err), ', cc(1)=' num2str(sigfig(cc(1),2))...
        ', cc(2)=' num2str(cc(2)),', phserr=' int2str(phserr)],['fsmo= ' int2str(fsmo),...
        ', fmin= ',int2str(fmin),', fmax= ' int2str(fmax)]})
    titlefontsize(.8,2)
end
prepfig
%% #7 test match with noise
t0s=[.5 1 1.5];%estimation window times
twins=.5*ones(size(t0s));%estimation window width in seconds
wlen=.5;%expressed as a fraction of twins
mu=10;
pctnoncausal=50;
sn=balans(sn,r);
[w_est,tw_est]=extract_wavelets_match(sn,t,r,t0s,twins,wlen,mu,pctnoncausal);
%get true wavelets
w_true=cell(size(w_est));
tw_true=w_true;
if(isinf(Q))
   for k=1:length(w_true)
      w_true{k}=max(w_est{k})*w/max(w);
      tw_true{k}=tw;
   end
else
   for k=1:length(w_true)
      j=near(t,t0s(k));
      ind=near(t,t(j(1))-.5*twins(k),t(j(1))+.5*twins(k));
      tmp=qmat(ind,j(1));
      w_true{k}=max(w_est{k})*tmp/max(tmp);
      tw_true{k}=t(ind)-t(j(1));
   end 
end
figure
subplot('position',[.1,.1,.4,.8]);
inc=max(abs(sn));
plot(sn,t,r+inc,t,'k');flipy;grid
xl=get(gca,'xlim');
co=get(gca,'colororder');
for k=1:length(t0s)
    line(xl,[t0s(k) t0s(k)],'color',co(k+1,:));
    text(xl(1),t0s(k),['Window ' int2str(k) ', width=' num2str(twins(k))])
end
if(~isinf(Q))
    title('Input data noisy, nonstationary but drift corrected')
else
    title('Input data noisy, stationary')
end
ht=.1;
for k=1:length(t0s)
    ynow=interp1([0 t(end)],[.95-ht .05],t0s(k));
    subplot('position',[.6 ynow .3 ht])
    [err,cc,phserr]=waveleterr(w_true{k},tw_true{k},w_est{k},tw_est{k});
    hh=plot(tw_true{k},w_true{k},tw_est{k},w_est{k});
    hh(2).Color=co(k+1,:);
    legend('true','estimate','location','southeast');
    title({['Match method',', err=' num2str(err), ', cc(1)=' num2str(sigfig(cc(1),2))...
        ', cc(2)=' num2str(cc(2)),', phserr=' int2str(phserr)],['mu=' num2str(mu)]})
    titlefontsize(.8,2)
end
prepfig

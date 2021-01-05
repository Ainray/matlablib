% a seies of examples of time and depth migration

%% #1
% make a section with 9 diffractions and then do a time mgration through it
%

%

dx=5;
nx=512;
dt=.002;
nt=1024;
t=(0:nt-1)*dt;
zmax=2000;
dz=25;
z=(0:dz:zmax);
%make rms velocity
v=1800+.6*z;
tv=2*vint2t(v,z);
dtau=8*dt;
% taumax=max(t);
taumax=1;
tau=(0:dtau:taumax)';
taucheck=linspace(0,max(tau)-dtau,20);
vrms=vint2vrms(v,tv,tau);
vave=vint2vave(v,tv,tau);
vrmsx=vrms*ones(1,nx);

znot=[100, 200, 300 400 500 600 700 800 900];%make sure these occur at integer depth steps
zv=vave.*tau/2;

x=(0:nx-1)*dx;
xnot=nx/2*dx;
seis=zeros(nt,nx);
%install the diffractions
for k=1:length(znot)
    ind=near(zv,znot(k));
    tnot=2*znot(k)/vave(ind(1));
    seis=event_hyp(seis,t,x,tnot,xnot,vrms(ind(1)),1);
end

fdom=30;
[w,tw]=ricker(dt,fdom,.2);
seis=convz(seis,w);


frange=[2 80];
[seismigt,exzos1]=pspi_stack_tmig_rms(seis,t,x,vrmsx,x,tau,frange,-taucheck);
titles1=cell(size(exzos1));
for k=1:length(taucheck)
    titles1{k}=['Focussed around tau= ' num2str(taucheck(k)) 's'];
end

%plot
seisplot(seis,t,x,'Diffractions input to time migration');

tex=dt*(0:size(exzos1{1},1)-1);
xex=dx*(0:size(exzos1{1},2)-1);
plotgathers(exzos1,xex,tex,'distance (m)','time (s)',titles1);
figtit('Time extrapolated sections of diffractions focussed around')
seisplot(seismigt,t,x,['Diffractions time migration, dtau=' int2str(dtau/dt) '*dt'])


%rerun the time migration to get the extrapolated sections output
%differently
[seismigt,exzos2]=pspi_stack_tmig(seis,t,x,vrmsx,x,tau,frange,taucheck);
titles2=cell(size(exzos2));
for k=1:length(taucheck)
    titles2{k}=['Focussed at and above tau= ' num2str(taucheck(k)) 's'];
end

%plot
plotgathers(exzos2,xex,tex,'distance (m)','time (s)',titles2);
figtit('Time extrapolated sections of diffractions focussed at and above')
%% #2 depth migration of the previous
zcheck=0:100:2000;
frange=[2 80];
vel=v(:)*ones(size(x));
[seismigd,exzosd]=pspi_stack(seis,t,x,vel,x,z,frange,zcheck);
titlesd=cell(size(exzosd));
for k=1:length(titlesd)
    titlesd{k}=['Extrapolated to ' num2str(zcheck(k)) ' m'];
end
tex=dt*(0:size(exzosd{1},1)-1);
xex=dx*(0:size(exzosd{1},2)-1);
plotgathers(exzosd,xex,tex,'distance (m)','time (s)',titlesd);
figtit('Depth extrapolated sections of diffractions')
seisplot(seismigd,z,x,['Depth migration, dz=' int2str(z(2)) ' m'])

%% #3 The thrust model
%do a finite-difference model of thrust
modelname='thrust model';
dx=5;
% vlow=2000;vhigh=3500;
% xmax=5100;zmax=2500;
vlow=2500;vhigh=3145;
xmax=5100;zmax=2500;
[velt,xt,zt]=thrustmodel(dx,xmax,zmax,vhigh,vlow);
figure;imagesc(xt,zt,velt);colorbar
figtit('The thrust model')
title(modelname)
dtt=.004; %temporal sample rate
dtstep=.001;
tmax=2*zmax/vlow; %maximum time
[seisfiltt,seis,tt]=afd_explode(dx,dtstep,dtt,tmax, ...
 		velt,xt,zeros(size(xt)),[5 10 40 50],0,2);
    
%% #4 now a depth migration (run the previous cell first)
zcheck=0:100:2000;
frange=[2 80];
[zosmigd,exzos]=pspi_stack(seisfiltt,tt,xt,velt,xt,zt,frange,zcheck);

seisplot(zosmigd,zt,xt,'Thrust model depth migrated with exact velocity');

xs=cell(size(exzos));
ts=cell(size(exzos));
titles=cell(size(exzos));
for k=1:length(exzos)
    xs{k}=(xt(2)-xt(1))*(0:size(exzos{k},2)-1);
    ts{k}=(tt(2)-tt(1))*(0:size(exzos{k},1)-1);
    titles{k}=['Extrapolated to depth ' int2str(zcheck(k)) 'm'];
end

%load the extrapolations into plotgathers
plotgathers(exzos,xs,ts,'distance (m)','time (s)',titles);
figtit('Depth extrapolated sections')

%% #5 now a time migration
dtau=8*dtt;
[vrmsmod,tau]=vzmod2vrmsmod(velt,zt,dtau,tmax);

frange=[2 80];
taucheck=0:.1:2;
[zosmigt,exzos]=pspi_stack_tmig_rms(seisfiltt,tt,xt,vrmsmod,xt,tau,frange,taucheck);
titles=cell(size(exzos));
for k=1:length(titles)
    titles{k}=['Focussed at and above tau= ' num2str(taucheck(k)) 's'];
end

%plot
tex=(tt(2)-tt(1))*(0:size(exzos{1},1)-1);
xex=(xt(2)-xt(1))*(0:size(exzos{1},2)-1);
plotgathers(exzos,xex,tex,'distance (m)','time (s)',titles);
figtit('Time extrapolated sections')
seisplot(zosmigt,tt,xt,['Time migration, dtau=' int2str(dtau/dtt) '*dt'])

%% #6 a time migration with a single vrms function
%pick the first vms
vrms1=vrmsmod(:,1);

frange=[2 80];
taucheck=[];
[zosmigt1,exzos]=pspi_stack_tmig_rms(seisfiltt,tt,xt,vrms1,xt,tau,frange,taucheck);
% titles=cell(size(exzos));
% for k=1:length(titles)
%     titles{k}=['Focussed around tau= ' num2str(taucheck(k)) 's'];
% end

%plot
% tex=(tt(2)-tt(1))*(0:size(exzos{1},1)-1);
% xex=(xt(2)-xt(1))*(0:size(exzos{1},2)-1);
% plotgathers(exzos,xex,tex,'distance (m)','time (s)',titles);
seisplot(zosmigt1,tt,xt,['Time migration section with single vrms from left edge, dtau=' int2str(dtau/dtt) '*dt'])

%% #7 a time migration with the average vrms function
%pick the average vms
vrms2=mean(vrmsmod,2);

frange=[2 80];
taucheck=[];
[zosmigt2,exzos]=pspi_stack_tmig_rms(seisfiltt,tt,xt,vrms2,xt,tau,frange,taucheck);
% titles=cell(size(exzos));
% for k=1:length(titles)
%     titles{k}=['Focussed around tau= ' num2str(taucheck(k)) 's'];
% end

%plot
% tex=(tt(2)-tt(1))*(0:size(exzos{1},1)-1);
% xex=(xt(2)-xt(1))*(0:size(exzos{1},2)-1);
% plotgathers(exzos,xex,tex,'distance (m)','time (s)',titles);
seisplot(zosmigt2,tt,xt,['Time migration section with average vrms, dtau=' int2str(dtau/dtt) '*dt'])

%% #8 a time migration with a single vrms function
%pick the vms where the thrust outcrops
ix=near(xt,2250);
vrms3=vrmsmod(:,ix(1));

frange=[2 80];
taucheck=[];
[zosmigt3,exzos]=pspi_stack_tmig_rms(seisfiltt,tt,xt,vrms3,xt,tau,frange,taucheck);
% titles=cell(size(exzos));
% for k=1:length(titles)
%     titles{k}=['Focussed around tau= ' num2str(taucheck(k)) 's'];
% end

%plot
% tex=(tt(2)-tt(1))*(0:size(exzos{1},1)-1);
% xex=(xt(2)-xt(1))*(0:size(exzos{1},2)-1);
% plotgathers(exzos,xex,tex,'distance (m)','time (s)',titles);
seisplot(zosmigt3,tt,xt,['Time migration section with vrms at thrust, dtau=' int2str(dtau/dtt) '*dt'])

%% #9 compare the different time migrations
%Make sure you have run the previous cells first
timemigs={zosmigt;zosmigt1;zosmigt2;zosmigt3};
titles={'Migrated with exact vrms';'Migrated with left edge vrms';...
    'Migrated with average vrms';'Migrated with vrms at thrust'};
plotgathers(timemigs,xt,tt,'distance (m)','time (s)',titles);
figtit('Thrust: Comparison of different time migrations')
%% #10 time-migration of a flat section with the thrust velocity model
%make a flat section by creating a single trace and replicating it
%we use the same geometry as the thrust model
r=reflec(tmax,dtt);
fdom=30;
[w,tw]=ricker(dtt,fdom);
s=convz(r,w);
seisflat=s*ones(size(xt));
frange=[2 80];
migtimeflat=pspi_stack_tmig_rms(seisflat,tt,xt,vrmsmod,xt,tau,frange);
migdepthflat=pspi_stack(seisflat,tt,xt,velt,xt,zt,frange);
seisplot(migdepthflat,zt,xt,'Depth migration of flat section with thrust model')

seisplot(migtimeflat,tt,xt,['Time migration of flat section with thrust vrms model, dtau=' int2str(dtau/dtt) '*dt'])

seisplot(seisflat,tt,xt,'Flat seismic section before migration')

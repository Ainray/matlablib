% Test reflectivity modeling with a 2 layer model:
% AKA: Pissing into the wind:
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

%% old reflectivity
% layer model:

    vp=[1.5,2.0,2.5,3]';                   % km/s
    vs=.5*vp;
%     Qp=100*ones(size(vp));
%     Qs=.5*Qp;
    Qp=10000*ones(size(vp));
    Qs=Qp;
    thickness=.5*[1,1,1,1]';
    rho=[1.8,2,2.2,2.5]';                  % g/cm^3
    model=[thickness rho vp Qp vs Qs];
   %    PARAMETERS INVOLVED IN FREQUENCY-SLOWNESS (WAVENUMBER) (F-K) DOMAIN MODELING 
%           AND FOURIER TRANSFORMS:
%      parameters ->   
%           T_max:      maximum modeling time (sec);
%           delta_T:    time interval (msec);
%           u1:         initial slowness to compute (sec/km); 
%           u2:         final slowness to compute (sec/km);
%           f1:         initial frequency (Hz) to model;
%           f2:         final frequency (Hz) to model;
%           tau:        wrap-around attenuation factor 
%                        (integrated as the imaginary part of complex velocity);
%           z_Source:   Depth source (km)
%           perc_U:     percentage of the slowness integral that is windowed 
%           perc_F:     percentage of the frequency integral that is windowed
%           F1:         source component in x;
%           F2:         source component in y;
%           F3:         source component in z;
%           direct:     = 1  compute direct wave; = 0 do not compute;
%           mult:       = 1  compute multiples;     = 0 do not compute;
%           delta_U:    slowness integral step length
%           fref:       reference frequency (Hz) at which velocities are
%                       specified. This would be the frequency of well
%                       logging. Used for Q
%
%xrec=0:0.25:10; % x cordiantes for receivers  in km:
%
    xrec=0:0.025:2.5;                  % x cordiantes for receivers  in km
    Tmax=3;                         % Desired record length in seconds:
    dt=0.004;                       % Time sample rate, seconds:
    fmin=2;     fmax=60;            % Frequency band for ref. modeling
    fref=10000;                     %Q reference frequency
    smin=0;                         % Minimum slowness:
    ds=0.05/(fmax*max(xrec));         % Slowness increment:
    smax=round(1.2/vs(1)/ds)*ds;    % Maximum slowness:
    tau=50; % for complex freq to supress wrap around
    per_s=100*(1-1/1.2);
    per_f=40; % parameter for Hanning window:
    direct=0;
    mult=0;
    z_source=0.005; % km
%     %  
%     % A minimum phase source wavelet with a dominant frequency of 40 Hz:
%     %
%      [wlt,tw] =wavemin(dt,40,2*Tmax-dt); 
%      [spw,fw]=fftrl(wlt,tw);
%      index1=fmin/(fw(2)-fw(1))+1;
%      index2=fmax/(fw(2)-fw(1))+1;
%     % create a source with Z components only
%     F3=spw(index1:index2);  %z comp of source 
%     F1=zeros(size(F3));  %x comp of source
%     F2=zeros(size(F3));  %y comp of source
    F3=1;F1=0;F2=0;
%
    param=[Tmax dt smin smax fmin fmax tau z_source per_s per_f ...
           F1 F2 F3 direct mult ds fref];  

 
%
% Parameters for bandpass filter: [fmin(1) fmin(2) fmax(1) fmax(2)]:
%
    bpfilt= [5 2 60 10]; 
 
% Calculate wave fields with the reflectivity codes
% the final result is truncated to Tmax/2 in time length
%
%     [uR,uZ,t] = reflectivity(model,param,xrec,[spw_x spw_y spw_z],bpfilt);
    profile on
    [uR1,uZ1,t] = reflectivity(model,param,xrec);
    profile off
    profsave(profile('info'),'REFold')
    
%
% Raytrace some expected events:
%
%     z=[0;thickness(1)];
    z=[0;cumsum(thickness(1:end-1))];
% PP from first reflector:
%
    tpp1=traceray_pp(vp,z,z_source,0,z(2),xrec,.001,-1,8);
%     tps1=traceray_ps(vp,z,vs,z,z_source,0,z(2),xrec,.001,-1,8);
%     tss1=traceray_pp(vs,z,z_source,0,z(2),xrec,.001,-1,8);
    tpp2=traceray_pp(vp,z,z_source,0,z(3),xrec,.001,-1,8);
%     tps2=traceray_ps(vp,z,vs,z,z_source,0,z(3),xrec,.001,-1,8);
%     tss2=traceray_pp(vs,z,z_source,0,z(3),xrec,.001,-1,8);
    tpp3=traceray_pp(vp,z,z_source,0,z(4),xrec,.001,-1,8);
%
% Plot the results:
%
%     figure;
    plotseismic(uR1,t,xrec,'k',10);
    ylabel('Time (seconds)');
    xlabel('Offset (km)');
    title('Radial Component');
    set(gca,'ygrid','on');
    bigfig;bigfont;whitefig
    plotseismic(uR1,t,xrec,'k',10);
    ylabel('Time (seconds)');
    xlabel('Offset(km)');
    title('Radial Component with Raytraced Traveltimes');
    set(gca,'ygrid','on');
    hold
%     h1=plot(xrec,tpp1,'m',xrec,tps1,'r',xrec,tss1,'g',xrec,tpp2,'m',xrec,tps2,'r',xrec,tss2,'g');
    h1=plot(xrec,tpp1,'m',xrec,tpp2,'r',xrec,tpp3,'g');
    bigfig;bigfont;whitefig
    legend(h1,'pp1','pp2','pp3')
    plotseismic(uZ1,t,xrec,'k',10);
    ylabel('Time (seconds)');
    xlabel('Offset (km)');
    title('Vertical Component');
    set(gca,'ygrid','on');
    bigfig;bigfont;whitefig
    plotseismic(uZ1,t,xrec,'k',10);
    ylabel('Time (seconds)');
    xlabel('Offset (km)');
    title('Vertical Component with Raytraced Traveltimes');
    set(gca,'ygrid','on');
    hold
%     h1=plot(xrec,tpp1,'m',xrec,tps1,'r',xrec,tss1,'g',xrec,tpp2,'m',xrec,tps2,'r',xrec,tss2,'g');
    h1=plot(xrec,tpp1,'m',xrec,tpp2,'r',xrec,tpp3,'g');
    bigfig;bigfont;whitefig
    legend(h1,'pp1','pp2','pp3')
%% new reflectivity
% layer model:

    vp=[1.5,2.0,2.5,3]';                   % km/s
    vs=.5*vp;
%     Qp=100*ones(size(vp));
%     Qs=.5*Qp;
    Qp=10000*ones(size(vp));
    Qs=Qp;
    thickness=.5*[1,1,1,1]';
    rho=[1.8,2,2.2,2.5]';                  % g/cm^3
    model=[thickness rho vp Qp vs Qs];
%           parametres ->   17 in total
%           T_max:     maximum modeling time (sec);
%           delta_T:    time interval (msec);
%           u1:            initial slowness to compute (sec/km); 
%           u2:            final slowness to compute (sec/km);
%           f1:             initial frequency (Hz) to model;
%           f2:             final frequency (Hz) to model;
%           tau:           wrap-around attenuation factor 
%                              (integrated as the imaginary part of complex velocity);
%           z_Source: Depth source (km)
%           perc_U:     percentage of the slowness integral that is windowed 
%           perc_F:      percentage of the frequency integral that is windowed
%           F1:         source component in x;
%           F2:         source component in y;
%           F3:         source component in z;
%           direct:      = 1  compute direct wave; = 0 do not compute;
%           mult:        = 1  compute multiples;     = 0 do not compute;
%           delta_U:   slowness integral step length
%           fref:       reference frequency (Hz) at which velocities are
%                       specified. This would be the frequency of well
%                       logging
% 
%xrec=0:0.25:10; % x cordiantes for receivers  in km:
%
    xrec=0:0.025:2.5;                  % x cordiantes for receivers  in km
    Tmax=3;                         % Desired record length in seconds:
    dt=0.004;                       % Time sample rate, seconds:
    fmin=2;     fmax=60;            % Frequency band for ref. modeling
    fref=10000;                     %Q reference frequency
    smin=0;                         % Minimum slowness:
    ds=0.05/(fmax*max(xrec));         % Slowness increment:
    smax=round(1.2/vs(1)/ds)*ds;    % Maximum slowness:
    tau=50; % for complex freq to supress wrap around
    per_s=100*(1-1/1.2);
    per_f=40; % parameter for Hanning window:
    direct=0;
    mult=0;
    z_source=0.000; % km
%     %  
%     % A minimum phase source wavelet with a dominant frequency of 40 Hz:
%     %
%      [wlt,tw] =wavemin(dt,40,2*Tmax-dt); 
%      [spw,fw]=fftrl(wlt,tw);
%      index1=fmin/(fw(2)-fw(1))+1;
%      index2=fmax/(fw(2)-fw(1))+1;
%     % create a source with Z components only
%     F3=spw(index1:index2);  %z comp of source 
%     F1=zeros(size(F3));  %x comp of source
%     F2=zeros(size(F3));  %y comp of source
    F3=1;F1=1;F2=1;
%
    param=[Tmax dt smin smax fmin fmax tau z_source per_s per_f ...
           F1 F2 F3 direct mult ds fref];  

 
%
% Parameters for bandpass filter: [fmin(1) fmin(2) fmax(1) fmax(2)]:
%
    bpfilt= [5 2 60 10]; 
 
% Calculate wave fields with the reflectivity codes
% the final result is truncated to Tmax/2 in time length
%
%     [uR,uZ,t] = reflectivity(model,param,xrec,[spw_x spw_y spw_z],bpfilt);
%     profile on
    [uR2,uZ2,t] = reflectivity_GFM(model,param,xrec);
%     profile off
%     profsave(profile('info'),'REFnew')  
%
% Raytrace some expected events:
%
%     z=[0;thickness(1)];
    z=[0;cumsum(thickness(1:end-1))];
% PP from first reflector:
%
    tpp1=traceray_pp(vp,z,z_source,0,z(2),xrec,.001,-1,8);
    tps1=traceray_ps(vp,z,vs,z,z_source,0,z(2),xrec,.001,-1,8);
    tss1=traceray_pp(vs,z,z_source,0,z(2),xrec,.001,-1,8);
    tpp2=traceray_pp(vp,z,z_source,0,z(3),xrec,.001,-1,8);
    tps2=traceray_ps(vp,z,vs,z,z_source,0,z(3),xrec,.001,-1,8);
    tss2=traceray_pp(vs,z,z_source,0,z(3),xrec,.001,-1,8);
    tpp3=traceray_pp(vp,z,z_source,0,z(4),xrec,.001,-1,8);
    tps3=traceray_ps(vp,z,vs,z,z_source,0,z(4),xrec,.001,-1,8);
    tss3=traceray_pp(vs,z,z_source,0,z(4),xrec,.001,-1,8);

%
% Plot the results:
%
%     figure;
    amp=15;
    plotseismic(uR2,t,xrec,'k',amp);
    figsize(.5,.8,gcf)
    ylabel('Time (seconds)');
    xlabel('Offset (km)');
    title('Radial Component');
    set(gca,'ygrid','on');
    bigfont(gcf,2,1);whitefig
    
%     plotseismic(uR2,t,xrec,'k'amp);
    seisplot(uR2,t,xrec)
    figsize(.5,.8,gcf)
    ylabel('Time (seconds)');
    xlabel('Offset(km)');
    title('Radial Component with Raytraced Traveltimes');
    set(gca,'ygrid','on');
    hold
%     h1=plot(xrec,tpp1,'m',xrec,tps1,'r',xrec,tss1,'g',xrec,tpp2,'m',xrec,tps2,'r',xrec,tss2,'g');
    h1=plot(xrec,tps1,'m',xrec,tps2,'r',xrec,tss1,'g');
%     bigfig;bigfont;whitefig
    bigfont(gcf,1.25,1)
    legend(h1,'ps1','ps2','ss1')
    
    plotseismic(uZ2,t,xrec,'k',amp);
    figsize(.5,.8,gcf)
    ylabel('Time (seconds)');
    xlabel('Offset (km)');
    title('Vertical Component');
    set(gca,'ygrid','on');
    bigfont(gcf,2,1);whitefig
    
%     plotseismic(uZ2,t,xrec,'k',amp);
    seisplot(uZ2,t,xrec,'Vertical component')
    figsize(.5,.8,gcf)
    ylabel('Time (seconds)');
    xlabel('Offset (km)');
    title('Vertical Component with Raytraced Traveltimes');
    set(gca,'ygrid','on');
    hold
%     h1=plot(xrec,tpp1,'m',xrec,tps1,'r',xrec,tss1,'g',xrec,tpp2,'m',xrec,tps2,'r',xrec,tss2,'g');
    h1=plot(xrec,tpp1,'m',xrec,tpp2,'r',xrec,tpp3,'g');
%     bigfig;bigfont;whitefig
    bigfont(gcf,1.25,1)
    legend(h1,'pp1','pp2','pp3')
    
%% seismogather
vp=1000*[1.5,2.0,2.5,3]';                   % km/s
vs=.5*vp;
Qp=100*ones(size(vp));
Qs=.75*Qp;%actually Qps
%     Qp=10000*ones(size(vp));
%     Qs=Qp;
thickness=.5*[1,1,1,1]';
rho=1000*[1.8,2,2.2,2.5]';                  % g/cm^3
model=[thickness rho vp Qp vs Qs];

dz=1;
zz=1000*[0;cumsum(thickness(1:end-1))];
z=(0:dz:max(zz)+500*dz)';
vp2=zeros(size(z));
vs2=vp2;
rho2=vp2;
for k=1:length(zz)-1
    ind=find(z>=zz(k)&z<zz(k+1));
    vp2(ind)=vp(k);
    vs2(ind)=vs(k);
    rho2(ind)=rho(k);
end
ind=find(z>=zz(end));
vp2(ind)=vp(end);
vs2(ind)=vs(end);
rho2(ind)=rho(end);

figure
plot(vp2,z,vs2,z,rho2,z);flipy;grid
ylabel('depth (m)')
legend('Vp (m/sec)','Vs (m/sec)','Density (kg/m^3)')
prepfig

xoffs=0:25:2500;
offmax=max(xoffs);
angles=0:5:35;

vwater=[];
ozrat=1.5;
xcap=[];
itermax=[];
mindepth=[];
maxdepth=[];

dt=.002;
tlen=.3;

dtlog=.002;
loginttime=0;
sflag=[];
pflag=[];
polarity=[];
nmoflag=0;%0 nmo not removed, 1 pseudo zero offset, 2 nmo removed
trloss=1;
sphdiv=1;
response=[];
clevels=[];
cflag=1;
raymsg=[];
gatherflag=0;% gatherflag ... 0 offset, 1 vsp, 2 angle

%critical parameters
ghostflags=[0,0,0];
Qs=50;Qp=100;
% Qp=[];Qs=[];
receiver=2;%1=hydrophone, 2=geophone
reftype=1;%1=PP, 2=PS
zwater=0;
zshot=0;
zrec=0;
fdom=30;
fhigh=60;
if(reftype==2)
    fhigh=fhigh/2;
end
flow=10;
% [w,tw]=wavebutter(dt,flow,fhigh,4,0,tlen);wname='Butter';
[w,tw]=ricker(dt,fdom,tlen);wname='Ricker';
% [w,tw]=wavelow(dt,fhigh,4,0,tlen);wname='Lowpass';
wdat=[];
if(strcmp(wname,'Lowpass'))
    wdat=[wname ', fhigh=' int2str(fhigh) 'Hz'];
elseif(strcmp(wname,'Ricker'))
    wdat=[wname ', fdom=' int2str(fdom) 'Hz'];
elseif(strcmp(wname,'Butter'))
    wdat=[wname ', ' int2str(flow) '-' int2str(fhigh) 'Hz'];
end
if(max(z)>10000)  
    %imperial
%     vp0=4000;vs0=2000;
    vp0=6000;vs0=3000;
else
    %metric
    vp0=1100;vs0=550;
end

if(rho(1)>100)
    rho0=2000;
else
    rho0=2;
end

% fnameout=[];
if(gatherflag==0)
    if(reftype==1)
        clevels=5:5:40;
    else
        clevels=10:10:50; 
    end
end
if(nmoflag==0)
    clevels=[];
end

if(reftype==2)
    Q=Qs;
else
    Q=Qp;
end

[uwP, uP, cangles, coffs, logmatrixout]=seismogather(vp2,vs2,rho2,z,vp0,vs0,rho0,xoffs,...
    w,tw,angles,zshot,zrec,zwater,vwater,ghostflags,ozrat,xcap,itermax,mindepth,maxdepth,receiver,reftype,dtlog,...
    loginttime,sflag,pflag,polarity,nmoflag,trloss,sphdiv,response,clevels,cflag,raymsg,gatherflag,Q);

tmax=3;


if(uwP.time(end)<=tmax)
    npad=round((tmax-uwP.time(end))/dt);
    t=[uwP.time; uwP.time(end)+dt*(1:npad)'];
    uPz=[uwP.z(:,:,1); zeros(npad,length(xoffs))];
    uPr=[uwP.x(:,:,1); zeros(npad,length(xoffs))];
else
    nlast=round(tmax/dt)+1;
    t=uwP.time(1:nlast);
    uPz=uwP.z(1:nlast,:,1);
    uPr=uwP.x(1:nlast,:,1);
end

seisplot(uPz,t,xoffs)
figsize(.5,.8,gcf);
ylabel('Time (seconds)');
xlabel('Offset (m)');
title('PP vertical component');
bigfont(gcf,1.25,1)


seisplot(uPr,t,xoffs)
figsize(.5,.8,gcf);
ylabel('Time (seconds)');
xlabel('Offset (m)');
title('PP radial component');
bigfont(gcf,1.25,1)

%ps
reftype=2;
if(reftype==2)
    Q=Qs;
else
    Q=Qp;
end

[uwPS, uPS, cangles, coffs, logmatrixout]=seismogather(vp2,vs2,rho2,z,vp0,vs0,rho0,xoffs,...
    w,tw,angles,zshot,zrec,zwater,vwater,ghostflags,ozrat,xcap,itermax,mindepth,maxdepth,receiver,reftype,dtlog,...
    loginttime,sflag,pflag,polarity,nmoflag,trloss,sphdiv,response,clevels,cflag,raymsg,gatherflag,Q);

tmax=3;


if(uwPS.time(end)<=tmax)
    npad=round((tmax-uwPS.time(end)/dt));
    t=[uwPS.time; uwPS.time(end)+dt*(1:npad)'];
    uPSz=[uwPS.z(:,:,1); zeros(npad,length(xoffs))];
    uPSr=[uwPS.x(:,:,1); zeros(npad,length(xoffs))];
else
    nlast=round(tmax/dt)+1;
    t=uwPS.time(1:nlast);
    uPSz=uwPS.z(1:nlast,:,1);
    uPSr=uwPS.x(1:nlast,:,1);
end

seisplot(uPSz,t,xoffs)
figsize(.5,.8,gcf);
ylabel('Time (seconds)');
xlabel('Offset (m)');
title('PS vertical component');
bigfont(gcf,1.25,1)


seisplot(uPSr,t,xoffs)
figsize(.5,.8,gcf);
ylabel('Time (seconds)');
xlabel('Offset (m)');
title('PS radial component');
bigfont(gcf,1.25,1)

%combine
uCz=uPz+uPSz;
uCr=uPr+uPSr;

seisplot(uCz,t,xoffs)
figsize(.5,.8,gcf);
ylabel('Time (seconds)');
xlabel('Offset (m)');
title('PP+PS vertical component');
bigfont(gcf,1.25,1)


seisplot(uCr,t,xoffs)
figsize(.5,.8,gcf);
ylabel('Time (seconds)');
xlabel('Offset (m)');
title('PP+PS radial component');
bigfont(gcf,1.25,1)

%% 
tr=.004*(0:size(uZ2,1)-1)';
seisplottwo(uZ2,tr,xoffs,'Reflectivity vertical',uCz,t,xoffs,'Seismogather vertical')

seisplottwo(uR2,tr,xoffs,'Reflectivity radial',uCr,t,xoffs,'Seismogather radial')
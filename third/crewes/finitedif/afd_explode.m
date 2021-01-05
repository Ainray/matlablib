function [seisw,seis,t]=afd_explode(dx,dtstep,dt,tmax, ...
         velocity,xrec,zrec,wlet,tw,laplacian,boundary,zmin)
% AFD_EXPLODE ... makes exploding reflector models
%
% [seisw,seis,t]=afd_explode(dx,dtstep,dt,tmax,velocity,xrec,zrec,wlet,tw,laplacian,boundary,zmin)
%
% AFD_EXPLODE creates the seismogram of an exploding reflector
% model defined by a velocity matrix.  The number and position of
% receivers is controlled by the user. The wavefield is propagated
% in depth using a finite difference algorithm, and is then 
% convolved with the input wavelet to produce a seismogram.
% The finite difference algorithm can be calculated with a five or
% nine point approximation to the Laplacian operator.  The five point
% approximation is faster, but the nine point results in a
% broader bandwidth.  The two lapalcian options have different stability
% conditions (see below).
%
% dx = the bin spacing for both horizontal and vertical (in consistent units)
% dtstep = size of time step for modelling (in seconds)
% dt = size of time sample rate for output seismogram. dt>dtstep causes resampling.
%		 dt<dtstep is not allowed. This allows the model to be oversampled for
%		 propagation but then conventiently resampled.
%		 The sign of dt controls the phase of the antialias resampling filter.
%		 dt>0 gives minimum phase, dt<0 is zero phase. Resampling is of course
%		 done at abs(dt). 
% tmax = the maximum time of the seismograms in seconds
% velocity = the input velocity matrix in consistent units
%          = has a size of floor(zmax/dx)+1 by floor(xmax/dx)+1
%          = NOTE - do not divide by two to compensate for one way
%          travel time - this is built into the program
% xrec = the x-positions of receivers (in consisent units)
% zrec = the z-positions of receivers (in consistent units)
%        z=0 positions receivers at the surface
% wlet or filter = a 4 component ' Ormsby ' specification = [f1 f2 f3 f4] in Hz
%        or a wavelet. If it is longer than four elements, it is assumed to be
%      a wavelet.
% tw or phase ... If a the previous input was a four point filter, then this must
%     a scalar where 0 indicates a zero phase filter and 1 is a minimum phase
%     filter. If the previous input was a wavelet, then this is the time 
%     coordinate vector for the wavelet. The time sample rate of the wavelet MUST
%		equal dt.
% laplacian - an option between two approximation to the laplacian operator
%           - 1 is a 5 point approximation
%          Stability condition: max(velocity)*dtstep/dx MUST BE < sqrt(2)
%           - 2 is a nine point approximation
%          Stability condition: max(velocity)*dtstep/dx MUST BE < 2*sqrt(3/8)
% boundary = indicate whether all sides of the matrix are absorbing
%          = 0 indicates that no absorbing boundaries are desired
%          = 1 indicates all four sides are absorbing
%          = 2 choses three sides to be absorbing, and the top one not to be
%             this enables sources to be put on the surface
% ********** default = 2 *********
% If a receiver depth other than 0 is specified, then boundary=1 might be
% preferred
% zmin= reflectivity before this depth is ignored
% ********** default =0 ***********
%
% t = the time vector (from 0 to tmax)
% xrec = the x vector of the output seismogram and of the receiver array
% seis = the output seismogram unfiltered
% seisw = the seismogram convolved with the wavelet
%
% by Carrie Youzwishen, February 1999
% rewritten by G.F. Margrave June 2000
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


tic;

if(nargin<12)
    zmin=0;
end

if(nargin<11)
%boundary=1;% means all four boundaries are absorbing
    boundary=2;% means all top is not absorbing
end

velocity=velocity/2; %exploding reflector velocity

if laplacian ==1 
    if max(max(velocity))*dtstep/dx > 1/sqrt(2)
    disp('SImulation is unstable:  max(velocity/2)*dtstep/dx MUST BE < 1/sqrt(2)');
    return;
    end
else
    if max(max(velocity))*dtstep/dx > sqrt(3/8)
    disp('Simulation is unstable:  max(velocity/2)*dtstep/dx MUST BE < sqrt(3/8)');
    return;
    end
end

if(abs(dt)<dtstep)
	error('abs(dt) cannot be less than dtstep')
end

if(length(wlet)==4)
   %switch from ormsby to filtf style
   wlet=[wlet(2) wlet(2)-wlet(1) wlet(3) wlet(4)-wlet(3)];
   if(tw~=0 && tw ~=1)
      error('invalid phase flag');
   end
else
   if(length(wlet)~=length(tw))
      error('invalid wavelet specification')
   end
   w=wlet;
   wlet=0;
   if abs( tw(2)-tw(1)-abs(dt)) >= 0.000000001
      error('the temporal sampling rate of the wavelet and dt MUST be the same');
   end
end


% Calculate bin numbers
%nx=floor(xmax/dx)+1;
%nz=floor(zmax/dx)+1;
[nz,nx]=size(velocity);

% spatial coordinates chosen by user
x=0:dx:(nx-1)*dx;
z=0:dx:(nz-1)*dx;

xmax=max(x);zmax=max(z);
clipn=0;
snap2=afd_reflect(velocity,clipn);
if(zmin>0)
    pct=100*zmin/zmax;
    mw=flipud(mwhalf(length(z),pct));
    snap2=snap2.*(mw*ones(1,length(x)));
end
%snap1=snap2;
snap1=zeros(size(snap2));

nrec=length(xrec);

%set up matrix for output seismogram
seis=zeros(floor(tmax/dtstep),nrec);

%transform receiver locations to bin locations
xrec = floor((xrec-min(x))./dx)+1;
zrec = floor((zrec-min(z))./dx)+1;

irec=zeros(1,nrec);
for j=1:nrec
      irec(1,j)=((xrec(j)-1)*nz + zrec(j));
end

seis(1,:)=snap2(irec);

maxstep=round(tmax/dtstep);
disp(['There are ' int2str(maxstep) ' steps to complete']);
time0=clock;
%amp=zeros(1,maxstep);
nwrite=2*round(maxstep/50)+1;
for k=1:maxstep

   [snapshot]=afd_snap(dx,dtstep,velocity,snap1,snap2,laplacian,boundary);

	seis(k+1,:)=snapshot(irec);
	snap1=snap2;
   snap2=snapshot;
   %amp(k)=sum(abs(snap2(:)));
       
    if rem(k,nwrite) == 0
       timenow=clock;
       tottime=etime(timenow,time0);

       disp(['wavefield propagated to ' num2str(k*dtstep) ...
           ' s; computation time left ' ...
           num2str((tottime*maxstep/k)-tottime) ' s']);
    end 

end

disp('modelling completed')

%compute a time axis
t=((0:size(seis,1)-1)*dtstep)';

%resample if desired
if(abs(dt)~=dtstep)
	disp('resampling')
	phs=(sign(dt)+1)/2;
	dt=abs(dt);
	for k=1:nrec
		cs=polyfit(t,seis(:,k),4);
		[tmp,t2]=resamp(seis(:,k)-polyval(cs,t),t,dt,[min(t) max(t)],phs);
		seis(1:length(tmp),k)=tmp+polyval(cs,t2);
	end
	seis(length(t2)+1:length(t),:)=[];
	t=t2;
end

% convolve the output seismogram with the wavelet
seisw=zeros(size(seis));

if(~wlet)
   nzero=near(tw,0);
   disp('applying wavelet');
	ifit=near(t,.9*max(t),max(t));
	tpad=(max(t):dt:1.5*max(t))';
   for k=1:nrec
		tmp=seis(:,k);
		cs=polyfit(t(ifit),tmp(ifit),1);
		tmp=[tmp;polyval(cs,tpad)];
      tmp2=convz(tmp,w,nzero);
		seisw(:,k)=tmp2(1:length(t));
   end
else
   disp('filtering...')
	ifit=near(t,.9*max(t),max(t));
%   HDG changed from 	tpad=(max(t):dt:1.1*max(t))';
	tpad=(max(t)+dt:dt:1.1*max(t))';
   for k=1:nrec
		tmp=seis(:,k);
		cs=polyfit(t(ifit),tmp(ifit),1);
		tmp=[tmp;polyval(cs,tpad)];
%       HDG changed from tmp2=filtf(tmp,t,[filt(1) filt(2)],[filt(3) filt(4)],phase);
        tmp2=filtf(tmp,[t;tpad],[wlet(1) wlet(2)],[wlet(3) wlet(4)],tw);
		seisw(:,k)=tmp2(1:length(t));
   end
end

if(iscomplex(seisw))
        %disp('Really really bad! Complex amplitudes generated...')
        seisw=real(seisw);
end
toc;
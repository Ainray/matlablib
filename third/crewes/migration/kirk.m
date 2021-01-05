function [arymig,tmig,xmig,gath]=kirk(aryin,aryvel,dt,dx,params,xgath)
% KIRK: simplified Kirchhoff time migration
%
% [arymig,tmig,xmig]=kirk(aryin,aryvel,t,x,params,xcig)
%
% KIRK is a simple post stack Kirchhoff time migration routine. This is
% just simple NMO and sum. No time derivative, no cosine factor, and
% nearest neighbor interpolation. For these missing features use kirk_mig.
%
% aryin ... matrix of zero offset data. One trace per column.
% aryvel ... velocity information. The are 3 possibilities:
%            1) if a scalar, then a constant velocity migration with
%               velocity=aryvel is performed.
%            2) if a vector, then it must be the same length as the number
%               of rows in aryin. In this case it is assumed to be an rms
%               velocity function (of time) which is applied at all positions
%               along the section.
%            3) if a matrix, then it must be the same size as aryin. Here it
%               is assumed to give the rms velocity for each sample location.
% t ... if a scalar, this is the time sample rate in SECONDS.
%       If a vector, it gives the time coordinates for the rows of aryin.
% x ... if a scalar, this is the spatial sample rate (in units
%       consistent with the velocity information. If a vector, then
%       it gives the x coordinates of the columns of aryin
% params ... vector of migration parameters
% 	params(1) ... migration aperture in physical length units
%	****** default is the length of the section *******
%	params(2) ... tmin of migration target window
%	****** default 0.0 *******
%	params(3) ... tmax of migration target window
%	****** default is maximum input time *******
%   params(4) ... xmin of migration target window
%	****** default is the minimum input coordinate *******
%   params(5) ... xmax of migration target window
%	****** default is the maximum input coordinate *******
% 
% arymig ... the output migrated time section
% tmig ... t coordinates of migrated data
% xmig ... x coordinates of migrated data
%
% G.F. Margrave, CREWES Project, U of Calgary, 1996
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


%xgath is a hidden parameter that causes an nmo corrected gather to be output at xgath to that
%the basic Kirchhoff idea can be appreciated.

if(nargin<6)
    xgath=[];
end

tstart=clock; % save start time

[nsamp,ntr]=size(aryin);
[nvsamp,nvtr]=size(aryvel);

if(length(dt)>1)
	if(length(dt)~=nsamp)
		error('Incorrect time specification: number of rows of ARYIN must equal length T' )
	end
	t=dt(:);
	dt=t(2)-t(1);
else
 t=((0:nsamp-1)*dt)';
end

if(length(dx)>1)
	if(length(dx)~=ntr)
		error('Incorrect x specification')
	end
	x=dx;
	dx=x(2)-x(1);
else
 x=(0:ntr-1)*dx;
end

%examine parameters
nparams=5;% number of defined parameters
if(nargin<5); params= nan*ones(1,nparams); end
if(length(params)<nparams)
    params = [params nan*ones(1,nparams-length(params))];
end

%assign parameter defaults
if( isnan(params(1)) ) 
		aper = abs(max(x)-min(x)); 
else
		aper = params(1);
end
if( isnan(params(2)) ) 
		tmig1 = min(t);
else
		tmig1 = params(2);
end
if( isnan(params(3)) ) 
		tmig2 = max(t);
else
		tmig2 = params(3);
end
if( isnan(params(4)) ) 
		xmig1 = min(x);
else
		xmig1 = params(4);
end
if( isnan(params(5)) ) 
		xmig2 = max(x);
else
		xmig2 = params(5);
end



%test velocity info
vmin=min(aryvel(:));
if(nvsamp==1 && nvtr~=1)
	%might be transposed vector
	if(nvtr==nsamp)
		aryvel=aryvel';
	else
		error('Velocity vector is wrong size');
	end
	%make velocity matrix
	aryvel=aryvel*ones(1,ntr);
elseif( nvsamp==1 && nvtr==1)
	aryvel=aryvel*ones(nsamp,ntr);
elseif( nvsamp==nsamp && nvtr==1)
	aryvel=aryvel*ones(1,ntr);
else
	if(nvsamp~=nsamp)
		error('Velocity matrix has wrong number of rows');
	elseif(ntr~=nvtr)
		error('Velocity matrix has wrong number of columns');
	end
end

%ok, we now have a velocity matrix the same size as the data matrix

%compute half-aperture in traces
traper=round(.5*aper/dx);

%one way time
dt1=.5*dt;
t1=t/2;
t2= t1.^2;

%compute maximum time needed
tmaxin=t1(nsamp);
tmax=sqrt( tmaxin^2 + (.5*aper/vmin)^2);

%pad input to tmaxin
npad=1.1*(tmax-tmaxin)/dt1;
aryin= [aryin; zeros(round(npad),ntr)];

%output samples targeted
samptarget=near(t,tmig1,tmig2);
tmig=t(samptarget);

%output traces desired
trtarget= near(x,xmig1,xmig2);
xmig=x(trtarget);

%initialize output array
arymig=zeros(length(samptarget),length(trtarget));

%loop over migrated traces
kmig=0;
igath=nan;
if(~isempty(xgath))
    igath=near(x,xgath);
    gath=zeros(size(arymig));
end
t1=clock;
for ktr=trtarget
	kmig=kmig+1;
	%determine traces in aperture
	n1=max([1 ktr-traper]);%farthest trace on left to use
	n2=min([ntr ktr+traper]);%farthest trace on right to use
	truse=n1:n2;%traces to use
	
	%offsets and depths
	offset2=((truse-ktr)*dx).^2;%squared offset
	v2 = aryvel(:,ktr).^2;%RMS velocity at the image point
	%zo2=(t.*aryvel(:,ktr)).^2;

	% loop over traces in aperture
	%aper=aryin(:,truse);
	for kaper=1:length(truse)
		%nmo correction and sum into output trace
		
		%compute offset times and sample numbers
		itx=round(1+sqrt( offset2(kaper)./v2(samptarget) + t2(samptarget) )/dt1);
	
		tmp = aryin(itx,truse(kaper));
		
		arymig(:,kmig)= arymig(:,kmig)+tmp;
        if(ktr==igath)
           gath(:,truse(kaper))=tmp; 
        end
	end
	
	%normalize
	arymig(:,kmig) = arymig(:,kmig)/length(truse);
	
	if(rem(kmig,50)==0)
        timeused=etime(clock,t1);
        timepertrace=timeused/(ktr-trtarget(1));
        timeleft=timepertrace*(trtarget(end)-ktr);
		disp(['Finished trace ' int2str(kmig) ' of ' int2str(length(trtarget))]);
        disp(['time used = ' int2str(timeused) ' s, time remaining = ' int2str(timeleft) ' s']);
	end
	
end
tused=etime(clock,tstart);
disp(['Total elapsed time ' num2str(tused)])
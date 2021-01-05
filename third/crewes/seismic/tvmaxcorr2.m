function [cc,tcc,ccf,gg1,gg2,tcc1]=tvmaxcorr2(s1,s2,t,twin,tinc,maxlag,t1,t2,aflag,bflag)
% TVMAXCORR2: estimates time variant crosscorrelation of two signals
%
% [cc,tcc,ccf,gg1,gg2,tcc1]=tvmaxcorr2(s1,s2,t,twin,tinc,maxlag,t1,t2,aflag,bflag)
% 
% The traces s1 and s2 are localized in time with a Gaussian window and then the crosscorrelation is
% calculated (see maxcorr). This process is repeated until all specified times are analyzed. This
% differs from TVMAXCORR in that the windows applied to s1 are shifted relative to those applied to
% s2. The amount of the shift is the correlation lag deduced in the previous window. This ensures
% that most correlation maxima occur near the window centers.
%
% s1= input trace to be analyzed (e.g. a seismic trace)
% s2= reference trace (e.g. a well synthetic or reflectivity)
% t= time coordinate vector for s1 and s2
% NOTE: s1,s2, and t must all be the same size
% twin= width (seconds) of the Gaussian window (standard deviation)
% tinc= temporal shift (seconds) between windows
% maxlag = maximum cc lag (seconds)
% ************* default = .4*twin ***********
% t1 ... first time to compute a correlation
% ************* default = t(1) ************
% t2 ... last time to compute a correlation
% ************* default = t(end) ***************
% aflag = 0 ... find the maximum absolute value of the crosscorrelation
%         1 ... find the maximum positive value of the crosscorrelation
%        -1 ... find the maximum negative value of the crosscorrelation
%         2 ... find the maximum of the envelope of the crosscorrelation
% ************ default =0 **********
% bflag = if 1 then the bandwidth of signal is imposed on signal 2 before measurement
% ************* default = 0 *************
%
% cc= n-by-2 matrix of crosscorrelations values. Here the row index gives
%      the time and column 1 is the maximum correlation value while column
%      2 is the lag (in samples) at which the maximum occurs. Lags are
%      relative to the window center time.
% tcc= n-by-1 vector of window center times. These are the times of the cc values
%
% NOTE: If only one output argument, then cc is interpolated to the times t.
%
% NOTE: To stretch s1 to look like s2 use 
% [cc,tcc]=tvmaxcorr(s1,s2,t,twin,tinc,maxlag);
% delt=cc(:,2)*dt;
% tstretch=interp1(tcc,delt,t);
% s1p=stretcht(s1,t,-tstretch);
%
% by G.F. Margrave, CREWES, 2016
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

if(nargin<10)
   bflag=0; 
end
if(nargin<9)
   aflag=0; 
end
if(nargin<8)
    t2=t(end);
end
if(nargin<7)
    t1=t(1);
end

if(nargin<6)
    maxlag=.4*twin;
end

if(length(s1)~=length(s2))
    error('s1 and s2 must have the same length');
end
if(length(t)~=length(s1))
    error('s1 and t must have the same length');
end

itau=0;
dt=t(2)-t(1);
nt=length(t);

tmin=t(1);
t=t(:);
s1=s1(:);
s2=s2(:);
% determine number of windows. tinc will be adjusted to make the
% last window precisely centered on tmax
tmax=t(end);
nwin=(tmax-tmin)/tinc+1; %this will generally be fractional
nwin=round(nwin);
if(nwin>1)
    tinc=(tmax-tmin)/(nwin-1); %redefine tinc
end
tcc=zeros(nwin,1);
tcc1=tcc;
cc=nan*zeros(nwin,2);
nlag=round(maxlag/(t(2)-t(1)));
ccf=nan*zeros(nwin,2*nlag+1);
gg1=zeros(length(t),nwin);
gg2=gg1;
itauk=zeros(1,nwin);
for k=1:nwin
    itauk(k)=itau;
    %build the gaussians
    tnot=(k-1)*tinc+tmin;%nominal windows center. Used for s2
    tnot1=tnot+itau*dt;%window center for s1 is shifted by itau samples
    tcc(k)=tnot;%the measured shifts are relative to this time
    tcc1(k)=tnot1;%shifted window times
    gwin1=exp(-((t-tnot1)/twin).^2);%Gaussian for s1
    gwin=exp(-((t-tnot)/twin).^2);%Gaussian for s2
    %window and measure correlation
    if(tnot>=t1 && tnot<=t2)
        s1w=zeros(size(t));
        tmp=s1.*gwin1;%window with the shifted Gaussian
        %positive itau means s1 is delayed relative to s2. So we shift it earlier
        %the shifts cause the samples to be aligned with a lag of itau samples
        if(itau>0)
            s1w(1:nt-itau)=tmp(1+itau:nt); %earlier shift
        else
            s1w(1-itau:nt)=tmp(1:nt+itau); %later shift
        end
        s2w=s2.*gwin;
        [cc(k,:),ccf(k,:)]=maxcorr(s1w,s2w,nlag,aflag,bflag);%do the correlation
        cc(k,2)=cc(k,2)+itau;%add itau to the measured lag
        itau=round(cc(k,2));%make sure itau is always an even number of samples
    else
        tcc(k)=nan;
    end
    gg1(:,k)=gwin1;
    gg2(:,k)=gwin;
end

idead=find(isnan(tcc));
tcc(idead)=[];
cc(idead,:)=[];
ccf(idead,:)=[];
gg1(:,idead)=[];
gg2(:,idead)=[];


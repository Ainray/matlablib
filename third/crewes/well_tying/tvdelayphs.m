function [tvdelay,tvphase]=tvdelayphs(s,t,sref,twin,tinc)
% TVDELAYPHS_NEW: measure time-variant stretch and phase rotation between two traces
%
% [tvdelay,tvphase]=tvdelayphs_new(s,t,sref,twin,tinc)
%
% s ... input seismic trace to be "tied"
% t ... time coordinate for s and sref(same size as s)
% sref ... reference trace (seismogram at well with zero phase wavelet)
% NOTE: sref should be the same length as tref. Pad with zeros if needed
% twin ... half width of Gaussian window used for time variant localization. The maximum 
%       expected time shift should be less than twin. A common value would be 0.1 or 0.2.
%       Optionally, this can be a vector of length 2 where the second entry is the length of a
%       boxcar smoother applied to the trace envelopes. If not specified, then the smoother is
%       calculated as 0.1*twin(1).
% tinc ... increment between windows. Typically tinc would be about twin/4.
%       A smaller tinc can detect more rapid time variance. Optionally, this can be a vector of
%       length 2 where the second value gives the maximum allowed cc lag. If not specified this
%       value is 0.4*twin(1).
% tvdelay ... measured delay (same size as t)
% tvphase ... measured phase rotations (same size as t)
%
% To apply the time shifts to another trace, say sref, use
%   sref2=stretcht(sref,t,-tvdelay); %shifts applied to reference trace
%   s2=stretcht(s,t,tstretch); %shifts applied to seismic trace
% To apply the phase rotations use
%   sref2r=tvphsrot(sref2,t,-tvphase,t); %applied to reference trace after shifting
%   s2r=tvphsrot(s2,t,tvphase,t); %applied to seismic trace after shifting
% Note the minus sign when applying to sref. Alternativly, you can reverse the input arguments 
% and let s be the synthetic and then you don't need the minus signs.
%
% by: G.F. Margrave, CREWES, 2016
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

t=t-t(1);
dt=t(2)-t(1);

if(length(s)~=length(sref))
    error('s and sref must be the same length');
end

if(length(s)~=length(t))
    error('s and t must be the same length');
end


if(length(twin)==1)
    twin=[twin .1*twin];
end

if(length(tinc)==1)
    tinc=[tinc 0.4*twin(1)];
end

%check for an overall polarity flip
cc=maxcorr(sref,s);
if(cc(1)<0)
    s=-s;
end

%measure time variant cc of envelopes

%note the use of env here. it fails with traces themselves
nsmo=round(twin(2)/dt)+1;
es=convz(env(s),ones(nsmo,1))/nsmo;
er=convz(env(sref),ones(nsmo,1))/nsmo;
%[cc,tcc]=tvmaxcorr(er,es,t(ind),twin,tinc,.4*twin);
[cc,tcc]=tvmaxcorr(er,es,t,twin(1),tinc(1),tinc(2));
% [cc,tcc]=tvmaxcorr(sref,s,t,twin(1),tinc(1),tinc(1),t(1),t(end),2);

delt2=cc(:,2)*dt;
delt2=findmonostretch(tcc,delt2,cc(:,1));
tvdelay=interp1(tcc,delt2,t);
% remove estimated delay
ind=find(abs(sref)>0);
t1=t(ind(1));%first live reference sample
t2=t(ind(end));%last live reference sample

srefp=sref;

sreftie=stretcht(srefp,t,-tvdelay);
s2=s;

ind=near(t,t1,t2);

%estimate the phase
[phs,tphs]=tvconstphase(sreftie(ind),s2(ind),t(ind),twin(1),tinc(1));
tvphase=interp1(tphs,phs,t);

%set phase to zero where shifted ref is zero
test=s.*sreftie;
ind=find(abs(test)>0);
ind0=1:ind(1)-1;
ind1=(ind(end)+1):length(t);
tvphase([ind0 ind1])=0;

%set delay to zero where original ref is zero
% test=s.*sref;
% ind=find(abs(test)>0);
% ind0=1:ind(1)-1;
% ind1=(ind(end)+1):length(t);
% tvdelay([ind0 ind1])=0;




function deltnew=findmonostretch(tcc,delt,ccmax)
% 
% test and possibly modify the delt to ensure monotonic solution
%
% tcc ... vector of measurment times
% delt ... vector of estimted shifts
% ccmax ... vector of estimated max cc's
% all three are the same length
%
% Plan: The stretch maps t to tp=t+delt. The solution is monotonic if diff(tp)>0 everywhere.
% So, I hunt for those places where diff(tp)<0 and fudge them. Fudging is done by looking at
% the problem points in comparison to the point before. The ccmax values at each
% problem point and the one before it are compared and the point with the lower ccmax is
% discarded and a new value interpolated in.
%

%first test to see if anything needs to be done
tp=tcc+delt;
ind=find(diff(tp)<0);%ideally diff(tp) should always be positive
deltnew=delt;
if(isempty(ind))
    return;
end
npts=length(tcc);
count=0;
while(~isempty(ind))
    count=count+1;
    if(count>npts)
        error('failed to converge to single-valued stretch solution in tvdelayphs');
    end
    for k=1:length(ind)
        % compare the points at ind(k) and ind(k)+1; The second is the low one
        i1=ind(k);
        i2=i1+1;
        if(ccmax(i1)>ccmax(i2))%we favour the point with the higher ccmax
            %discard all points where tp<tp(i1) and that have tcc>tcc(i1) and interpolate a replacement
            ii=find(tp<tp(i1));%first condition
            %iii=find(tp>tp(i1));
            %i3=iii(1);
            i3=ii(end)+1;
            for kk=1:length(ii) %check each point
                if(tcc(ii(kk))>tcc(i1))%second condition
                    i2=ii(kk);%point to be replaced
                    if(i3<=npts)
                        %linear interpolation between i1 and i3
                        deltnew(i2)=deltnew(i1)*(tcc(i2)-tcc(i3))/(tcc(i1)-tcc(i3))+deltnew(i3)*(tcc(i2)-tcc(i1))/(tcc(i3)-tcc(i1));
                    else
                        %there is no i3
                        deltnew(i2)=deltnew(i1);
                    end
                end
            end
        else
            %discard all points where tp>tp(i2) and that have tcc<tcc(i2) and interpolate a replacement
            ii=find(tp>tp(i2));
            i0=ii(1)-1;
            for kk=1:length(ii)
                if(tcc(ii(kk))<tcc(i2))%second condition
                    i1=ii(kk);
                    if(i0>0)
                        %linear interpolation between i0 and i2
                        deltnew(i1)=deltnew(i0)*(tcc(i1)-tcc(i2))/(tcc(i0)-tcc(i2))+deltnew(i2)*(tcc(i1)-tcc(i0))/(tcc(i2)-tcc(i0));
                    else
                        %there is no i0
                        deltnew(i1)=deltnew(i2);
                    end
                end
            end
        end
    end
    tp=tcc+deltnew;
    ind=find(diff(tp)<0);
end
                
    
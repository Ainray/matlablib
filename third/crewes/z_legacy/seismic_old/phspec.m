function hh=phspec(t,ss,flag,unwrapflag,tzeroflag)
%
% hh=phspec(t,s,flag,unwrapflag,tzeroflag)
% hh=phspec(t,s)
%
% PHSPEC plots a simple Fourier phase spectrum.
%
% Note: PHSPEC plots in the current axes. Use the figure command if you
% want a new window first.
%
% s= input trace or traces. Should be a column vector or matrix with trace in columns. May also be a
%       cell array if traces have different time coordinates. If s is a cell array, the t must also
%       be a cell with the unique time coordinates for each trace.
% t= input time coordinate vector or cell array.
% flag= 0... apply an n length mwindow to s before transforming
%       1... apply an n length half-mwindow to s before transforming
%       2... transform directly without windowing
% ************* default=2 **************
% unwrapflag= 0 do not unwrap phase
%             1 unwrap phase
% ************* default = 0 ************
% tzeroflag= 0 determine time zero from input t
%            1 determine time zero at maximum of envelope of s
% ************* default = 0 ************
%
% hh= handles of phase curves
% 
% by G.F. Margrave
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

if(iscell(ss))
    ntrcs=length(ss);
    if(~iscell(t))
        error('When s is a cell array, t must be also')
    end
else
    [m,n]=size(ss);
    %check for multiple traces
    if((m-1)*(n-1)>0)
        ntrcs=n;
    else
        ntrcs=1;
        ss=ss(:);%ensure column vector
    end
    if(iscell(t))
        error('t cannot be a cell array unless s is also')
    end
end

if nargin<3
   flag=2; %window flag
end
if nargin<4
   unwrapflag=0; %unwrap flag
end
if nargin<5
   tzeroflag=0; %time zero flag
end

hh=zeros(1,ntrcs);

for k=1:ntrcs
    
    if(k==2)
        hold on;
    end
    if(iscell(ss))
        s=ss{k};
        ts=t{k};
    else
        s=ss(:,k);
        ts=t;
    end
    
    %adjust time zero if asked
    if(tzeroflag)
        es=env(s);
        [emax,imax]=max(es); %#ok<*ASGLU>
%         % interpolate a maximum with splines
%         ix1=max(1,imax-2);%two samples before
%         ix2=min(length(es),imax+2);%two samples after
%         ts2=ts(ix1:ix2);%input x coordinate
%         tsi=ts2(1):.1*(ts(2)-ts(1)):ts2(end);%interpolated to .1 x
%         ai=spline(ts2,es(ix1:ix2),tsi);
%         [emax,imax]=max(ai);%new interpolated max
%         tzero=tsi(imax);%time of the interpolated maximum
        tzero=ts(imax);
        ts=ts-tzero;%adjusted time
    end
    
    if flag <2
        mw=ones(size(s));
        if flag==0, mw=mwindow(length(s));end
        if flag==1, mw=mwhalf(length(s));end
        s=s.*mw;
    end
    %adjust for time zero
    izero=near(ts,0);
    %make sure its close
    if(abs(ts(izero))<ts(2)-ts(1))
        s2=[s(izero:length(s)); s(1:izero-1)];
    else
        disp('***WARNING*** unable to find time zero, phase may be inaccurate')
    end
    
    %spectrum
    [spec,f]=fftrl(s2,ts);
    
    %to db & phs
    spec=todb(spec);
    %s=fft(s',n);
    
    phr=imag(spec);
    
    if(unwrapflag)
        phr=unwrap(phr);
    end
    
    ph=phr*180/pi;
    
    % now plot it
    if(k>1)
        hold on;
    end
    hh(k)=plot(f,ph);
    
end
hold off
grid;
xlabel('Frequency (Hz)');
ylabel('Phase (deg)');
if(~unwrapflag)
    ylim([-180 180])
end
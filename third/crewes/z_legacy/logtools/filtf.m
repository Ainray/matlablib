function trout=filtf(trin,t,fmin,fmax,phase,max_atten)

% trout=filtf(trin,t,fmin,fmax,phase,max_atten)
% trout=filtf(trin,t,fmin,fmax,phase)
% trout=filtf(trin,t,fmin,fmax)
%
% FILTF filters the input trace in the frequency domain.
% Trin is automatically padded to the next larger power of
% two and the pad is removed when passing trout to output. 
% Filter slopes are formed from Gaussian functions.
%
% trin= input trace
% t= input trace time coordinate vector
% fmin = a two element vector specifying:
%        fmin(1) : 3db down point of filter on low end (Hz)
%        fmin(2) : gaussian width on low end
%   note: if only one element is given, then fmin(2) defaults
%         to 5 Hz. Set to [0 0] for a low pass filter  
% fmax = a two element vector specifying:
%        fmax(1) : 3db down point of filter on high end (Hz)
%        fmax(2) : gaussian width on high end
%   note: if only one element is given, then fmax(2) defaults
%         to 10% of Fnyquist. Set to [0 0] for a high pass filter. 
% phase= 0 ... zero phase filter
%       1 ... minimum phase filter
%  ****** default = 0 ********
% note: Minimum phase filters are approximate in the sense that
%  the output from FILTF is truncated to be the same length as the
%  input. This works fine as long as the trace being filtered is
%  long compared to the impulse response of your filter. Be wary
%  of narrow band minimum phase filters on short time series. The
%  result may not be minimum phase.
% 
% max_atten= maximum attenuation in decibels
%   ******* default= 80db *********
%
% trout= output trace
%
% by G.F. Margrave, May 1991
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
 
% set defaults
 if nargin < 6
   max_atten=80.;
 end
 if nargin < 5
   phase=0;
 end
 if length(fmax)==1
   fmax(2)=.1/(2.*(t(2)-t(1)));
 end
 if length(fmin)==1
   fmin(2)=5;
 end

% convert to column vectors
[rr,cc]=size(trin);
trflag=0;
if(cc>1)
		trin=trin';
		t=t';
		trflag=1;
end
 dbd=3.0; % this controls the dbdown values of fmin and fmax
% forward transform the trace
  ntrout=length(trin);
  trin=padpow2(trin);
  t=xcoord(t(1),t(2)-t(1),length(trin));
  [Trin,f]=fftrl(trin,t);
  df=f(2)-f(1);
% design low end gaussian
  if fmin(1)>0
   fnotl=fmin(1)+sqrt(log(10)*dbd/20.)*fmin(2);
   fnotl= round(fnotl/df)*df;
   gnot=10^(-max_atten/20.);
   glow=gnot+gauss(f,fnotl,fmin(2));
  else
   glow=0;
   fnotl=0;
  end
% design high end gaussian
 if fmax(1)>0
  fnoth=fmax(1)-sqrt(log(10)*dbd/20.)*fmax(2);
  fnoth= round(fnoth/df)*df;
  gnot=10^(-max_atten/20.);
  ghigh=gnot+gauss(f,fnoth,fmax(2));
 else
  ghigh=0;
  fnoth=0;
 end
% make filter
  fltr=ones(size(Trin));
  nl=round(fnotl/df);
  nh=round(fnoth/df);
  if nl==0
    fltr=[fltr(1:nh);ghigh(nh+1:length(f))];
  elseif nh==0
    fltr=[glow(1:nl-1);fltr(nl:length(f))];
  else
    fltr=[glow(1:nl-1);fltr(nl:nh);ghigh(nh+1:length(f))];
  end
% make min phase if required
  if phase==1
    L1=1:length(fltr);L2=length(fltr)-1:-1:2;
    symspec=[fltr(L1);conj(fltr(L2))];
    cmpxspec=log(symspec)+i*zeros(size(symspec));
    fltr=exp(conj(hilbm(cmpxspec)));
  end
% apply filter
  trout=ifftrl(Trin.*fltr(1:length(f)),f);
  trout=trout(1:ntrout);
  if(trflag)
		trout=trout';
	end
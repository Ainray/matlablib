function [trout,x]= deconw(trin,trdsign,n,stab,wndw)
% DECONW: Wiener (Robinson) deconvolution
%
% [trout,d]=deconw(trin,trdsign,n,stab,wndw)
%
% Wiener (Robinson) deconvolution of the input trace. The operator is designed from the second
% input trace.
%
% trin= input trace to be deconvolved
% trdsign= input trace to be used for operator design
% n= number of autocorrelogram lags to use (and length of inverse operator)
% stab= stabilization factor expressed as a fraction of the
%       zero lag of the autocorrelation.
%      ********* default= .0001 **********
% wndw= the type of window for the autocorrelation. 1 for boxcar, 2 for triangle, 3 for Gaussian
% ********** default =1 ************
%
% trout= output trace which is the deconvolution of trin
% d= output deconvolution operator used to deconvolve trin
% The estimated wavelet is w=ifft(1./fft(d));
%
% by: G.F. Margrave, May 1991
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
  if nargin<5
    wndw=1;
  end
  if nargin<4
    stab=.0001;
  end
% generate the autocorrelation
  a=auto(trdsign,n,0);
% window the autocorrelation
  if(wndw==2)
     w=linspace(1,0,n);
     a=a.*w;
  elseif(wndw==3)
     %make g 2 sigma down at n
     sigma=n/2;
     g=exp(-(0:n-1).^2/sigma^2);
     a=a.*g;
  end
% stabilize the autocorrelation
  a(1)=a(1)*(1.0 +stab);
% generate the right hand side of the normal equations
  b=[1.0 zeros(1,length(a)-1)];
% do the levinson recursion
  x=levrec(a,b);
% deconvolve trin
  trout=convm(trin,x);

  
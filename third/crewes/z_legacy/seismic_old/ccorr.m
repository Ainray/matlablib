function a = ccorr(v,u,n,flag)
% cc=ccorr(v,u,n,flag)
% cc=ccorr(v,u,n)
%
% CCORR computes 2*n+1 lags of the cross correlation (normalized) 
% of the u with v. The zeroth lag is a(n+1). That is cc=u x v where x is
% cross correlation. For an autocorrelation, make u and v the same.
%
% NOTE: u x v is the time reverse of v x u. To test that this routine really does the former
% and not the latter, construct u=[1 0 0]; and v=[0 1 0]; Then, from basic signal theory, 
% u x v= conv(tr(u),v) where tr means time reverse. In this case tr(u) = [0 0 1]. So, carry out
% the convolution by hand (you CAN do it!) to get u x v =[0 0 0 1 0]. Similarly v x u =[0 1 0 0 0].
% finally run this function to verify that ccorr(v,u,2) => [0 0 0 1 0].
% 
% v= input vector
% u= input vector
% NOTE: u and v must be the same length. Pad if needed before calling this function (use
%       pad_trace)
% n= number of lags desired 
% flag= 1.0 ... normalize )
%       anything else ... don't normalize
%       ******* default =1.0 ******
%
% cc= the 2*n+1 length crosscorrelation.
%
% NOTE: A two sided autocorrelation or a cross correlation can also
%       be computed with XCORR in the signal toolbox.
% NOTE2: to make a lag time vector to plot against use tau=dt*[-n:n] where dt is the time
% sample size.
%
%   by G.F. Margrave, June 1991
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
 if (nargin<4)
  flag=1.0;
 end
 if(length(u)~=length(v))
     error('u and v must be the same length');
 end
% 
% master loop
% 
 [l,m]=size(v);
 lu=size(u,1);
 done=0;
% for row vectors
 if l==1 
   if lu==1, u=u'; else u=conj(u); end
   nzero=n+1;
   a(nzero)=v*u;
   uf=u;
   ub=u;
   for k=1:n
     uf=[0.0; uf(1:length(uf)-1)];
     ub=[ub(2:length(ub));0.0];
% forward lag
     a(nzero+k)=v*uf;
% backward lag
     a(nzero-k)=v*ub;
   end
   done=1;
 end
% for column vectors
 if m==1 
   v=v.';
   if lu==1, u=u'; else u=conj(u); end
   nzero=n+1;
   a(nzero)=v*u;
   uf=u;
   ub=u;
   for k=1:n
     uf=[0.0; uf(1:length(uf)-1)];
     ub=[ub(2:length(ub));0.0];
% forward lag
     a(nzero+k)=v*uf;
% backward lag
     a(nzero-k)=v*ub;
   end
   done=1; 
 end
 if done==0
   error(' input not a vector')
 end
% normalize
 if flag==1.0
%    a=2.*a/(sum(v.^2)+sum(u.^2));
     a=a/sqrt(sum(v.^2)*sum(u.^2));
 end
			     
function a = auto2(v,n,flag)
% AUTO2: returns the two-sided autocorrelation 
%
% a=auto2(v,n,flag)
% a=auto2(v,n)
%
% auto computes the two sided autocorrelation of 
% the vector 'v'. The 'zeroth lag' is at length(v)-1. This 
% routine will correctly handle an ensemble matrix.
% 
% v= input vector
% n=max lag (samples). Output will be 2*n+1 long;
%     ********* default n=length(v) **********
% flag= 1.0 ... normalize the 'zero lag' (first returned value)
%               to 1.0.
%        anything else ... don't normalize
%       ******* default =1.0 ******
%
% NOTE: A two sided autocorrelation or a cross correlation can be
%       computed with XCORR in the signal toolbox.
%
%   by G.F. Margrave, July 1991
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
 if (nargin<3)
  flag=1.0;
 end
 if(nargin<2)
     n=length(v);
 end
% 
% 
 %nn=-n:n;%lags wanted
 mm=(1:2*length(v)-1)-length(v);
 ind=near(mm,-n,n);
 
 nvecs=min(size(v));
 if nvecs==1,
  b=conv(v,tr(v,1));
  a=b(ind);
% normalize
  if flag==1.0
    a=a/max(a);
  end
 else
  [nrows,ncols]=size(v);
  a=zeros(2*n+1,ncols);
  if flag==1,
   for k=1:ncols,
     b=conv(v(:,k),tr(v(:,k),1));
     b=b/max(b);
     a(:,k)=b(ind);
   end
  else
   for k=1:nrows,
     b=conv(v(:,k),tr(v(:,k),1));
     a(:,k)=b(ind);
   end
  end
 end
			     
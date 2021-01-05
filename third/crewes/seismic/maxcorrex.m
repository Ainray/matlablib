function x=maxcorrex(trace1,trace2,n,m,aflag,bflag)
% x=maxcorrex(trace1,trace2,n,m,aflag,bflag)
%
% MAXCORREX similar to maxcorr except provides the option to choose the m'th largest maximum of the
% crosscorrelation. If m is chosen too large (meaning there is no such maximum) then the largest
% existing maximum is provided. MAXCORR computes 2*n+1 lags of the crosscorrelation of trace1 with
% trace2 (using CCORR) and then uses splines to pick the maximum to the nearest .1 lag. The
% interpolated maximum and lag are returned as x(1) and x(2).
%
% See also: maxcorr_phs and maxcorr_ephs
%
% trace1= input trace number 1
% trace2= input trace number 2
% n= 2*n +1 lags will be computed
% *********** default = 1/10 of the longer of s1 and s2 *********
% m= choose the mth largest maximum. 1 means the largest, 2 the second largest, etc.
% *********** default = 1 **********
% aflag = 0 ... find the maximum absolute value of the crosscorrelation
%         1 ... find the maximum positive value of the crosscorrelation
%        -1 ... find the maximum negative value of the crosscorrelation
%         2 ... fine the maximum of the envelope of the crosscorrelation
% ************ default =0 **********
% bflag ... 1 means impose the bandwidth of trace1 on trace2 before determining
%       the correlation coefficient (see bandwidth_xfer)
%          0 means don't do that
% ************* default = 0 ***********
% x= output: x(1)-> interpolated maximum cross correlation
%            x(2)-> interpolated lag at maximum correlation
% 
% Note: a negative result for x(2) indicates trace2 is delayed
%       relative to trace 1
%
% by G.F. Margrave, June 1991
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
if(nargin<6)
    bflag=0;
end
if(nargin<5)
    aflag=0;
end
if(nargin<4)
    m=1;
end
if(nargin<3)
    n1=length(trace1);
    n2=length(trace2);
    n=round(max([n1 n2])/10);
end
if(bflag==1)
    trace2=bandwidth_xfer(trace1,trace2);
end
if(length(trace1)~=length(trace2))
    x=[0 0];
    return
end
if(m<0 || m>n)
    error('unreasonable value for m');
end
cc=ccorr(trace1,trace2,n);
%test for all zeros
if(sum(abs(cc))==0)
    x=[0 round(length(trace)/2)];
    return;
end

if(aflag==0)
    if(m==1)
        [amax,imax]=max(abs(cc)); %#ok<*ASGLU>
    else
        iex=findex(abs(cc));
        [aa,I]=sort(cc(iex),'descend');%sort into descending order
        if(m<length(aa))
            imax=iex(I(m));
        else
            imax=iex(I(end));
        end
    end
    % interpolate a maximum with splines
    x1=max(1,imax-2);
    x2=min(length(cc),imax+2);
    xs=x1:x2;
    xi=x1:.1:x2;
    ai=spline(xs,cc(xs),xi);
    [amax,imax]=max(abs(ai));
    amax=ai(imax);
    x=[amax xi(imax)-n-1];
elseif(aflag==1)
    [amax,imax]=max(cc);
    % interpolate a maximum with splines
    x1=max(1,imax-2);
    x2=min(length(cc),imax+2);
    xs=x1:x2;
    xi=x1:.1:x2;
    ai=spline(xs,cc(xs),xi);
    [amax,imax]=max((ai));
    x=[amax xi(imax)-n-1];
elseif(aflag==-1)
    [amax,imax]=min(cc);
    % interpolate a maximum with splines
    x1=max(1,imax-2);
    x2=min(length(cc),imax+2);
    xs=x1:x2;
    xi=x1:.1:x2;
    ai=spline(xs,cc(xs),xi);
    [amax,imax]=min((ai));
    x=[amax xi(imax)-n-1];
elseif(aflag==2)
    cc=abs(hilbert(cc));
    [amax,imax]=max(cc);
    % interpolate a maximum with splines
    x1=max(1,imax-2);
    x2=min(length(cc),imax+2);
    xs=x1:x2;
    xi=x1:.1:x2;
    ai=spline(xs,cc(xs),xi);
    [amax,imax]=max((ai));
    x=[amax xi(imax)-n-1];
else
    error('invalid aflag');
end
function [phi,obj]=constphase3(s1,s2,flag)
% CONSTPHASE: find the best constant phase rotation to match one signal to another
%
% [phi,obj]=constphase3(s1,s2,flag)
%
% Given two signals s1 and s2, this function finds the constant phase rotation which, when applied
% to s1, minimizes ||s2-phase_rotated(s1)|| (||.|| is the L2 norm). However, if the arguments are
% reversed, the result is not simply the negative of the first result. constphase3 remedies this by
% minimizing ||s2-phase_rotated(s)||+||s1-phase_rotated(s2)|| where the phase rotations applied to
% s1 and s2 are the neagative on each other. In adition the envelope maxima ot the signals are 
% aligned before analysis.
%
% s1 ... input time series to be rotated
% s2 ... input time series to match to rotated s1
% flag ... 1 means impose the bandwidth of s1 on s2 before determining
%       rotation (see bandwidth_xfer)
%          0 means don't do that
% ************* default = 1 ***********
% phi ... best constant phase angle in degrees. To rotate s1 to look like
%           s2, use s1r=phsrot(s1,phi)
% obj ... the L2 norm of the difference for integer phase rotations from
%           -180 to 179. Phi comes from the minimum of this function.
% NOTE: You can plot obj with: plot(-180:179,obj);xlabel('Angle in degrees')
%
% 
% by G.F. Margrave, Nov. 2017
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

if(nargin<3)
    flag=0;
end

%align the envelopes
e1=env(s1);e2=env(s2);
cc=maxcorr(e2,e1);
s1p=stat(s1,1:length(s1),cc(2));

angs=-180:179;
% ang2=[-180:5:175 179];
ang2=angs;
obj2=zeros(size(ang2));
if(flag==1)
    % impose the bandwidth of the first signal on the second
    s2p=bandwidth_xfer(s1,s2);
else
    s2p=s2;
end
%
% m=2;
for k=1:length(ang2)
    s1pr=phsrot(s1p,ang2(k));
    s2pr=phsrot(s2p,-ang2(k));
    obj2(k)=norm(s2p-s1pr)+norm(s2pr-s1p);
%     obj2(k)=sum(abs((s2p-s1r)).^m);
end
obj=interp1(ang2,obj2,angs,'spline');
[~,kmin]=min(obj);
phi=angs(kmin);
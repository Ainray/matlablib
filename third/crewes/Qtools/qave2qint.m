function [Qint,tqint]=qave2qint(Qave,tq,tnot,tqin)
%
% [Qint,tqint]=qave2qint(Qave,tq,tnot,tqin)
%
% Convert average Q to interval Q
% 
% Qave ... vector of average Q's
% tq ... vector of times, the same length as Qave.
% tnot ... reference time to which the Qave's are measured from
% *********** default tnot=0 **********
% Note: tnot must be less than tq(1)
% tqin ... vector of times at which interval Qs are desired. The
%       more finely sampled this is, the more likely that your interval Qs
%       will be garbage. Generally, with measured Qave you must experiment
%       with tqin until you get a good result. The default is likely too
%       finely sampled. If you specify tqin, then all of its values must
%       lie between the beginning and end of tq.
% ************** default tqin = tq ***********
%
% Note: When tqin~=tq, then a new set of Qave values in interpolated from
% the input values at the times tqin using 1D spline interpolation. These
% interpolated values are used in the computation described below.
% 
% Qint ... vector of interval Q's the same length as Qave
% tqint ... vector of times of length one longer than Qint and equal to
%       [tnot;tqin(:)]; That is it is just the same as tqin but with tnot
%       tacked on the front. See qint2qave for an explanation.
%
% The Qave(1) is assumed to be the Q at the bottom of the first layer of a
% stack of layers. While Qave(2) is the Q at the bottom of the second
% layer. The Qint(1) will always equal Qave(1). Qint(2) is given by
% (tq(2)-tq(1))/Qint(2) = (tq(2)-tnot)/Qave(2) - (tq(1)-tnot)/Qave(1). And
% so forth for the remaining layers. Because the calculation of interval Q
% involves a difference of adjacent average Q's, it is possible for
% interval Q's to become negative which is unphysical. This happens most
% commonly when the average Q's are measured from noisy data and they are
% closely spaced in time. Such values are flagged and set to pi. (Setting
% them to zero asks for trouble later in a zero divide.)
% 
%
% G.F. Margrave, CREWES, 2016
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

tq=tq(:);
Qave=Qave(:);

if(nargin<4)
    tqin=tq;
end
if(nargin<3)
    tnot=0;
end

tqm=max(tq);
if(any(tqin>tqm))
    error('tqin values must be less than max(tq)');
end
tqm=min(tq);
if(any(tqin<tqm))
    error('tqin values must be greater than min(tq)')
end

%interpolate qave values at the locations tqin
Qa=interp1(tq,Qave,tqin,'spline');

Qint=zeros(size(Qa));
Qint(1)=Qa(1);

term=(tqin(2:end)-tnot)./Qa(2:end) - (tqin(1:end-1)-tnot)./Qa(1:end-1);

Qint(2:end)=(tqin(2:end)-tqin(1:end-1))./term;

ind= Qint<0;
if(~isempty(Qint))
    Qint(ind)=pi;
end

tqint=[tnot;tqin];
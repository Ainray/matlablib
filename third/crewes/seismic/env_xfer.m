function s1p=env_xfer(s1,s2,n,stab)
% ENVELOPE_XFER ... transfer the Envelope of s2 to s1
%
% s2p=env_xfer(s1,s2,n)
%
% Transfer the Hilbert envelope of s2 to s1 in a smooth way. Let E1 and
% E2 be the smoothed envelopes of s1 and s2. Then the the the revised s1 will be
% s1p=s1.*E2./(E1+stab*max(E1))
%
% s1 ... first input signal. s1 can be a matrix in which case each column is shaped 
%       to the envelope of s2. 
% s2 ... second input signal (must be the same length as s1).
% n ... number of samples in convolutional smoother to be applied to the
%       envelopes of s1 and s2.
% ********* default is 10% of the length traces ************
% stab ... stability constant for the denominator
% ********* default is .0001 **********
% s1p ... the new s1 with the envelope of s2.
%
% 
% by G.F. Margrave, Nov. 2020
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

s2=s2(:);%force column vector
if(isvector(s1))
    if(length(s1)~=length(s2))
        error('s1 and s2 must be the same length')
    end
    c1=1;r1=length(s1);
    s1=s1(:);%make sure its a column vector
else
    [r1,c1]=size(s1);
    if(r1~=length(s2))
        error('number of rows of s1 must equal the length of s2')
    end
end

% impose the envelope of the second signal on the first
if(nargin<3)
    n=round(length(s1)/10);
end
if(nargin<4)
    stab=.0001;
end
n=2*floor(n/2)+1;%forces n to be odd
Es2=convz(env(s2),ones(1,n)/n);
s1p=zeros(r1,c1);
for k=1:c1
    Es1=convz(env(s1(:,k)),ones(1,n)/n);
    s1p(:,k)=s1(:,k).*Es2./(Es1+stab*max(Es1));
end
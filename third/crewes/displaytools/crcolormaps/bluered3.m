function a=bluered3(m)
%BLUERED3 Blue-Turquoise; Yellow-Red
%   BLUERED3(M) returns an M-by-3 matrix containing a two-part colormap.
%   BLUERED3, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(BLUERED3)
%
% G.F. Margrave, CREWES, 2017
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

%

if( nargin < 1) 
	m=size(get(groot,'DefaultFigureColormap'),1); 
end
imid=floor(m/2);
iquarter=floor(imid/4);
igray=imid-iquarter:imid+iquarter;
m=2*imid+1;
ired=1:igray(1)-1;
iblue=igray(end):m;

g0=0;g1=1;

ge=linspace(g1,g0,imid+1);
g=[linspace(g0,g1,m-imid) ge(2:end)]';

r0=.5;
r1=g(igray(1));
b0=.3;
b1=g(imid+iquarter+2);

r=[linspace(r0,r1,length(ired)+1) g(igray(1)+1:imid+1)' zeros(1,m-imid-1)]';

b=[zeros(1,imid) g(imid+1:imid+iquarter+1)' linspace(b1,b0,m-imid-iquarter-1)]';

a = [r g b];
%a = brighten(a,.5);
function cmap = seisclrs2(m)
%SEISCLRS2 Dark BLue-Gray-Dark Red
%   SEISCLRS2(M) returns an M-by-3 matrix containing the colormap.
%   SEISCLRS2, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(SEISCLRS2)
%
% K. Innanen, K. Hall, CREWES, 2020
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

if( nargin < 1) 
	m=size(get(groot,'DefaultFigureColormap'),1); 
end

%type map; Manually generated
cmap = [59 76 192;
		68 90 204;
		77 104 215;
		87 117 225;
		98 130 234;
		108 142 241;
		119 154 247;
		130 165 251;
		141 176 254;
		152 185 255;
		163 194 255;
		174 201 253;
		184 208 249;
		194 213 244;
		204 217 238;
		213 219 230;
		221 221 221;
		229 216 209;
		236 211 197;
		241 204 185;
		245 196 173;
		247 187 160;
		247 177 148;
		247 166 135;
		244 154 123;
		241 141 111;
		236 127 99;
		229 112 88;
		222 96 77;
		213 80 66;
		203 62 56;
		192 40 47;
		180 4 38]/255;

cmap = flipud(cmap);
n = length(cmap); %number of colors in type map

%return the typemap if m equals the length of the type map
if n == m
    return
end

%approximate type map RGB curves with polynomials
ord = 4; %determined by experimentation
x = 1:n;
rp = polyfit(x,cmap(:,1),ord);
gp = polyfit(x,cmap(:,2),ord);
bp = polyfit(x,cmap(:,3),ord);

%create interpolated RGB curves for the desired number of colors
x2 = linspace(1,n,m)';
r = polyval(rp,x2);
g = polyval(gp,x2);
b = polyval(bp,x2);

%force r,g to have the same values as b at the midpoint
if(true)
    midx = ceil(length(x2)/2);
    r = r + b(midx)-r(midx); %redshift
    g = g + b(midx)-g(midx); %greenshift
end

%QC
if(false)
    figure;
    %plot type map
    plot(cmap(:,1),'r');
    hold on;
    plot(cmap(:,2),'g');
    plot(cmap(:,3),'b');
    %plot interpolated map
    plot(x2,r,'ro');
    plot(x2,g,'go');
    plot(x2,b,'bo');
    %plot mid-point index
    plot([x2(midx) x2(midx)],[0 1],'k');
end

cmap = [r, g, b];






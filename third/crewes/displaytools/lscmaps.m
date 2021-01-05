function cmaps = lscmaps(maxcmaps,cmap,trimmaps)
%LSCMAPS - List color maps provided by the CREWES toolbox
%
% cmaps = lscmaps(maxcmaps,cmap,trimmaps)
%  return a cell-array list of the names of all color maps in the same
%  folder as cmap
%
% cmaps    ... cell array containing a list of pre-defined Matlab color maps
% maxcmaps ... maximum number of cmaps to return. Used for memory
%              allocation. Default is 30.
% cmap     ... name of colormap to search for, Default is 'parula'
% trimmaps ... true (default); trim generally unuseful colormaps from the list.
%                current list: colorcube, colororder,flag,lines,prism, hsv, vga, white
% Examples:
% lscmaps(); %returns trimmed list of colormaps in the same folder as 'parula'
% lscmaps([],[],true); %returns full list of colormaps in the same folder as 'parula'
% lscmaps(5,'seisclrs'); %returns list of first five colormaps in the same folder as 'seisclrs');
%
% See Also: listcrcolormaps, listmatcolormaps, listcolormaps, plotcolormaps
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
%    notice. New versions will be made available at www.crewes.org.
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE

if  nargin < 1 || isempty(maxcmaps)
   maxcmaps = 30; 
end
if nargin < 2 || isempty(cmap)
   cmap = 'parula';
end
if  nargin < 3 || isempty(trimmaps)
   trimmaps = true; 
end

%full filename for cmap o this system
cmapname  = which(cmap);

%break apart to get the path
p = fileparts(cmapname);

%get a list of all of the .m files in path
d = dir(fullfile(p,'*.m'));
cmaps = {d(:).name};

%trim '.m' from the colormap script names
cmaps = regexprep(cmaps,'\.m','');

%trim unwanted colormaps
if trimmaps
    exclude = {'colorcube', ...
               'colororder', ...
               'flag', ...
               'lines', ...
               'prism', ...
               'hsv', ...
               'validatecolor', ...
               'vga', ...
               'white'};
    cmaps = setdiff(cmaps,exclude);
end

%restrict cell array to maxcmaps in length
if length(cmaps) > maxcmaps
   cmaps = cmaps(1:maxcmaps);
end




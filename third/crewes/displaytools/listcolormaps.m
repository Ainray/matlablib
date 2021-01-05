function cmaps = listcolormaps(maxcmaps,trimmaps)
%LISTCOLORMAPS - List all color maps provided by the Matlab and the CREWES toolbox
%
% function cmaps = listcolormaps(maxcmaps,trimmaps)
%  return a cell-array list of the names of all predefined matlab color maps
%
% cmaps    ... cell array containing a list of pre-defined Matlab color maps
% maxcmaps ... maximum number of cmaps to return. Used for memory
%              allocation. Default is 30.
% ltrim    ... true (default); trim generally unused colormaps from the list.
%                current list:
%
% See also: lscmaps, listmatcolormaps, listcrcolormaps, plotcolormaps
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

if  nargin < 1
   maxcmaps = []; 
end
if  nargin < 2
   trimmaps = true; 
end

%list matlab colormaps
cmaps1 = listmatcolormaps(maxcmaps,trimmaps);

%list crewes colormaps
cmaps2 = listcrcolormaps(maxcmaps);

%combine and sort
cmaps = sort([cmaps1(:)' cmaps2(:)']);

%restrict sorted cell array to maxcmaps in length
if length(cmaps) > maxcmaps
   cmaps = cmaps(1:maxcmaps);
end




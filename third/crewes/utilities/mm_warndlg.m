function h=mm_warndlg(warnstring,dlgname,parent)
%function h=mm_warndlg(warnstring,dlgname,parent)
%
% See 'help warndlg' for deatils on usage. createmode is 'modal'
%
% Where:
%   parent     = handle to parent figure. Empty implies the parent is the
%                Matlab desktop
%
% This function uses mm_adjust to cause a warndialog to 
% display on the same monitor as the parent figure.
%  
%  Authors: Kevin Hall, 2017
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

narginchk(2,3)

if nargin<3
    parent = []; %Matlab desktop
end

if isempty(parent) || isa(parent,'handle')
    %get current state of warnings
    w = warning;
    wstate = w(strcmp({w.identifier},'all')).state;
    if strcmp(wstate,'on')
        h = warndlg(warnstring,dlgname,'modal');
        mm_adjust(h,parent);
        uiwait(h);
    end
elseif parent
    warning(warnstring);
end

end %end function mm_warndlg

classdef SegyExtendedTextHeader < SegyTextHeader
%
%classdef SegyExtendedTextHeader
%
%Class to deal with SEG-Y extended textual file headers
%
% Usage: eh = SegyExtendedTextHeader(fid)
%   where fid is a valid file identifier provided by fopen
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%
% Authors: Kevin Hall, 2017, 2019
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

properties
    NumExtTxtHdrs = 0; %number of extended headers
end % end properties


methods %public methods    
    %Constructor
    function obj = SegyExtendedTextHeader(filename,permission,byteorder,segyrevision,numhdrs,gui)

        if nargin <1 || isempty(filename)
            filename = -1;
        end
        if nargin <2
            permission = [];
        end
        if nargin <3
            byteorder = [];
        end
        if nargin <4
            segyrevision = [];
        end
        if nargin <5 || isempty(numhdrs)
            numhdrs = 0;
        end        
        if nargin <6
            gui = 1;
        end
        
        %Call superclass constructor
        obj = obj@SegyTextHeader(filename,permission,byteorder,segyrevision,gui);
%         if obj.FileID < 1 %File.openFile failed
%             error(['@TextHeader: Unable to open file ' filename ' for ' permission]);
%         end
        
        obj.NumExtTxtHdrs = numhdrs;
        obj.OFFSET = 3600;
    end
    
    %Set methods
    function obj = set.NumExtTxtHdrs(obj, v)
        if isnumeric(v) && isscalar(v) && v >=0
            obj.NumExtTxtHdrs = v;
        else
            mm_errordlg('@SegyExtendedTextHeader: NumExtTxtHdrs must be numeric, scalar and positive',...
                'Error!',obj.GUI);
        end
    end    
    
end % end methods

methods (Static)
    %thead  = new(segrev,numhdrs);
end % end methods
    
end
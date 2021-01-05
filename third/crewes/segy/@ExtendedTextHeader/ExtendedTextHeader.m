classdef ExtendedTextHeader < TextHeader
%
%classdef ExtendedTextHeader
%
%Class to deal with SEG-Y extended textual file headers
%
% Usage: eh = ExtendedTextHeader(fid)
%   where fid is a valid file identifier provided by fopen
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%
% Authors: Kevin Hall, 2017
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

properties (Constant)
    EXTHDROFFSET = 3600;
end

properties
    NumExtHdrs = 0; %number of extended headers
end % end properties


methods %public methods    
    %Constructor
    function obj = ExtendedTextHeader(FileID,SegyRevision,GUI,varargin)
        obj = obj@TextHeader(FileID,SegyRevision,GUI,varargin{:});
        
        if File.size(FileID) >3600 && SegyRevision >= 1
            obj.NumExtHdrs = BinaryHeader.readNumExtHeaders(FileID);
        end
    end
    
    %Set methods
    function obj = set.NumExtHdrs(obj, v)
        if isnumeric(v) && v >=0
            obj.NumExtHdrs = v;
        elseif obj.NumExtHeaders > 0
            error(['@ExtendedTextHeader: File ''' obj.FileName,...
                ''' has a variable number of extended textual file headers']);
        end
    end    
    
end % end methods

methods (Static)
    %thead  = new(segrev,numhdrs);
end % end methods
    
end
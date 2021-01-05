classdef TextHeader 
%
%classdef TextHeader
%
%Class to deal with SEG-Y textual file headers
%
% Usage: th = TextHeader(fid)
%   where fid is a valid file identifier provided by fopen
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%
% Authors: Kevin Hall 2009, 2017
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

properties (Constant, Hidden = false)
    HDRSIZE   = 3200.0; %size in bytes
    HDROFFSET = 0; %bytes from BOF
end

properties
    TxtFormat    = 'ascii';
    FileID       = -1;
    SegyRevision = 1;
    GUI          = 1;    
end

methods %public methods
    
    %Constructor
    function obj = TextHeader(FileID,SegyRevision,GUI,varargin)
        if nargin <1
            FileID = -1;
        end
        if nargin <2
            SegyRevision = 1;
        end
        if nargin <3
            GUI = 1;
        end
        
        obj.FileID = FileID;
        obj.SegyRevision = SegyRevision;
        obj.GUI = GUI;
    
        if FileID > 0
            obj = obj.guessTextFormat;
        end
    
    end
    
    %Set methods
    function obj = set.FileID(obj,v)
        if isnumeric(v)
            obj.FileID=v;
        else
            error('@TextHeader: FileID must be numeric') 
        end
    end

    function obj = set.SegyRevision(obj,v)
        if isnumeric(v)
            obj.SegyRevision=v;
        else
            error('@TextHeader: SegyRevision must be numeric')
        end
    end
    
    function obj = set.GUI(obj, v)
        if isnumeric(v)
            obj.GUI = logical(v);
        elseif islogical(v)
            obj.GUI = v;
        elseif isempty(v) || isa(v,'handle')
            obj.GUI = v;
        else
            error('@TextHeader: GUI must be numeric, empty, or a figure handle')
        end
    end
    
    function obj = set.TxtFormat(obj,v)
        if ischar(v)
            v=lower(v);
            switch(v)
                case('ascii')
                    obj.TxtFormat = v;
                case('ebcdic')
                    obj.TxtFormat = v;
                otherwise
                    error('@TextHeader: TxtFormat must be ''ascii'' or ''ebcdic''');
            end
        else
            error('@TextHeader: TxtFormat must be char')
        end
    end    
    
end % end methods
    
end
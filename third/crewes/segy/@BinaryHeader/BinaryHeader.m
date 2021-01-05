classdef BinaryHeader < File2
%
%classdef BinaryHeader
%
% Class to deal with SEG-Y binary file headers
%
% Usage: bh = BinaryHeader(fid)
%   where fid is a valid file identifier provided by fopen
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%
% Authors: Kevin Hall, 2009, 2017
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
    HDRSIZE   = 400.0;  %bytes
    HDROFFSET = 3200.0;  %bytes
end

properties
    HdrDef = {}; %cell array containing the binary file header definition
   % FileID = -1; %valid file descriptor from fopen
    SegyRevision = 1;
 %   GUI    = 1;
    %ByteOrder = 'n';
%     FileSize = 0;
end

properties (Dependent)
    HdrFieldNames; %HdrDef col 1
    HdrDataTypes;  %HdrDef col 2
    HdrStartBytes; %HdrDef col 3
    HdrLongNames;  %HdrDef col 4    
end

methods
    function obj = BinaryHeader(FileID, SegyRevision, ByteOrder, GUI, varargin)
        if nargin <1
            FileID = -1;
        end
        if nargin <2
            SegyRevision = 1;
        end
        if nargin <3
            ByteOrder = 'n';
        end
        if nargin <4
            GUI = 1;
        end
        
        obj.FileID = FileID;
        obj.SegyRevision = SegyRevision;
        obj.ByteOrder = ByteOrder;
        obj.GUI = GUI;        
        
%         obj.FileSize = File.fileSize(FileID);        
        obj.HdrDef = obj.newDefinition;
    end %end constructor
    
%     function obj = set.FileID(obj,v)
%         if isnumeric(v)
%             obj.FileID=v;
%         else
%             error('@BinaryHeader: FileID must be numeric') 
%         end
%     end

    function obj = set.SegyRevision(obj,v)
        if isnumeric(v)
            obj.SegyRevision=v;
        else
            error('@BinaryHeader: SegyRevision must be numeric') 
        end
    end
    
%     function obj = set.ByteOrder(obj,v)
%         if ischar(v) && (isequal(v,'n') || isequal(v,'b') || isequal(v,'l'))
%             obj.ByteOrder=v;
%         else
%             error('@BinaryHeader: ByteOrder must be ''n,'' ''l,'' or ''b''')
%         end
%     end    

%     function obj=set.GUI(obj, v)
%         if isnumeric(v)
%             obj.GUI = logical(v);
%         elseif islogical(v)
%             obj.GUI = v;
%         elseif isempty(v) || isa(v,'handle')
%             obj.GUI = v;
%         else
%             error('@BinaryHeader: GUI must be numeric, empty, or a figure handle')
%         end
%     end      
    
    function obj = set.HdrDef(obj,v)
        if iscell(v) 
            obj.check(v)
            obj.HdrDef=v;
        else
            error('@BinaryHeader: HdrDef must be a valid cell array; see BinaryHeader/checkDefinition') 
        end
    end

    function fn = get.HdrFieldNames(obj)
        %returns contents of col 1 of obj.HdrDef
        fn = obj.HdrDef(:,1);
    end %end get.HdrFieldNames
    
    function st = get.HdrDataTypes(obj)
        %converts cols 1 and 2 of obj.HdrDef into a struct
        st = cell2struct(obj.HdrDef(:,2),obj.HdrDef(:,1));
    end %end get.HdrDataTypes
    
    function st = get.HdrStartBytes(obj)
        %converts cols 1 and 3 of obj.HdrDef into a struct
        st = cell2struct(obj.HdrDef(:,3),obj.HdrDef(:,1));        
    end %end get.HdrStartBytes
 
    function st = get.HdrLongNames(obj)
        %converts cols 1 and 4 of obj.HdrDef into a struct
        idx = cellfun(@(X) ~isempty(X),obj.HdrDef(:,4));
        st = cell2struct(obj.HdrDef(idx,4),obj.HdrDef(idx,1));        
    end %end get.HdrLongName
    
end %end methods

methods (Static)
    bd = newDefinition(segyrev);
    
    %Functions to read specific header words independent of obj.HdrDef
    function hw = readFormatCode(fid)
        File.seek(fid,3224,'bof');
        hw = File.read(fid, 1, 'uint16');
    end
    
    function hw = readSamplesPerTrace(fid)
        File.seek(fid,3220,'bof');
        hw = File.read(fid, 1, 'uint16');
    end
    
    function hw = readTracesPerRec(fid)
        %data traces
        File.seek(fid,3212,'bof');
        hw = File.read(fid, 1, 'uint16');
        %aux traces
        File.seek(fid,3214,'bof');
        hw = hw +File.read(fid, 1, 'uint16');
    end
    
    function hw = readSampleInterval(fid)
        File.seek(fid,3216,'bof');
        hw = File.read(fid, 1, 'uint16');
    end
    
    function hw = readSegyRevision(fid)
        obj.fseek(3500,'bof');
        hw = obj.fread(1, 'uint8');
        hw = hw + obj.fread(1, 'uint8')/10;        
    end
    
    function hw = readNumExtHeaders(fid)
        File.seek(fid,3504,'bof');
        hw = File.read(fid, 1, 'int16');       
    end
    
    function hw = readFixedTrcLength(fid)
        File.seek(fid,3502,'bof');
        hw = File.read(fid, 1, 'uint16');        
    end
    
    function hw = readHeaderWord(fid,startbyte,datatype,endian)
        %function readHeaderWord(fid,startbyte,datatype,endian)
        %
        % fid should be opened with 'ieee-le' or 'ieee-be'
        % endian is only applied in the case of 'int24' or 'uint24'
        ibmflag=false;
        int24flag=false;
        uint24flag=false;
        count=1;
        
        if nargin<4
            endian='b'; %default SEG-Y
        end
        
        switch(datatype)
            case 'int24'
                int24flag=true;
                datatype='uint8';
                count=3;
            case 'uint24'
                uint24flag=true;
                datatype='uint8';
                count=3;                
            case 'ibm32'
                ibmflag=true;
                datatype='uint32';
            case 'ieee32'
                datatype='single';
            case 'ieee64'
                datatype='double';
        end

        File.seek(fid,startbyte,'bof');
        hw = File.read(fid, count, [datatype '=>' datatype]);
        
        if int24flag
            hw = Trace.int242num(hw,endian);
        elseif uint24flag
            hw = Trace.uint242num(hw,endian);
        elseif ibmflag
            hw = Trace.ibm2num(hw);
        end
    end
end %end methods static

end %end classdef
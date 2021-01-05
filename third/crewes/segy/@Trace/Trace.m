classdef Trace
%classdef Trace
%
% Class for SEGY Trace Headers
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
    HDRSIZE = 240.0;  %bytes
end

properties
    TraceSize         = 0;
    TraceOneOffset    = 0;
    HdrDef            = {};
    ApplyCoordScalars = true; % logical true or false. true applies scalars to header words
    FormatCode        = 5; % SEG-Y data format code from the Binary File Header
    TrcDatFormatCode  = 5; % Guessed from data. Can be overwritten. If FormatCode = 1, could be 1 or 5
    SamplesPerTrace   = 0;
    TracesPerRec      = 0;
    TracesInFile      = 0;   
    SampleInterval    = 0;    
    FixedTrcLength    = 1;
end

properties
   FileID            = -1;    
   SegyRevision      = 1;    
   GUI               = true;
   ByteOrder         = 'n';  %file byte order, 'l','b','n' 
end

properties (Dependent)
    HdrFieldNames; %HdrDef col 1
    HdrDataTypes;  %HdrDef col 2
    HdrStartBytes; %HdrDef col 3
    HdrScalars;    %HdrDef col 4
    HdrLongName;   %HdrDef col 5
    FormatCodeType;
    BytesPerSample;
end

methods
    function obj = Trace(FileID, Offset, SegyRevision, ByteOrder, GUI, varargin)
        if nargin <1 || isempty(FileID)
            FileID = -1;
        end
        if nargin<2 || isempty(Offset)
            Offset = 3600;
        end
        if nargin<3 || isempty(SegyRevision)
            SegyRevision=1;
        end
        if nargin<5
           ByteOrder='n'; 
        end
        if nargin<4
            GUI=true;
        end
        
        obj.FileID = FileID;
        obj.TraceOneOffset = Offset;
        obj.SegyRevision = SegyRevision;
        obj.ByteOrder=ByteOrder;
        obj.GUI = GUI;
        
        obj.HdrDef = obj.newDefinition();
        
        if FileID < 0
            return
        end

        if File.size(obj.FileID) > TextHeader.HDRSIZE +BinaryHeader.HDRSIZE
            obj.SamplesPerTrace = BinaryHeader.readSamplesPerTrace(FileID);
            obj                 = obj.guessFormatCode;
            obj.TracesPerRec    = BinaryHeader.readTracesPerRec(FileID);                
            obj.SampleInterval  = BinaryHeader.readSampleInterval(FileID);
            obj.SegyRevision    = BinaryHeader.readSegyRevision(FileID);
            obj.FixedTrcLength  = BinaryHeader.readFixedTrcLength(FileID);                
            obj.TraceSize       = double(obj.SamplesPerTrace)...
                *double(obj.BytesPerSample)...
                +Trace.HDRSIZE;

            obj.TracesInFile = (File.size(obj.FileID)-Offset)/obj.TraceSize;
            
            if obj.TracesInFile-fix(obj.TracesInFile)>0

                if isempty(obj.GUI) || isa(obj.GUI,'handle')
                    a = mm_yesnodlg(['File may not contain fixed length traces! '...
                        'Assume fixed length and attempt to continue?'],...
                        'Warning!',...
                        'No',obj.GUI);
                elseif obj.GUI
                    disp('File may not contain fixed length traces!')
                    a = input('Assume fixed length and attempt to continue (y/n)? ','s');
                else
                    a='n';
                end
                
                if strncmpi(a,'n',1)
                    obj.FileID = -1;
                    return
                else
                    obj.TracesInFile = floor(obj.TracesInFile);
                end
            else
                obj.FixedTrcLength = 1;
            end
            
        end
    end

    function obj = set.FileID(obj,v)
        if isnumeric(v)
            obj.FileID=v;
        else
            error('@Trace: FileID must be numeric')
        end
    end   

    function obj = set.ByteOrder(obj,v)
        if ischar(v) && (isequal(v,'n') || isequal(v,'b') || isequal(v,'l'))
            obj.ByteOrder=v;
        else
            error('@Trace: ByteOrder must be ''n,'' ''l,'' or ''b''')
        end
    end
    
    function obj = set.TraceSize(obj,v)
        if isnumeric(v)
            obj.TraceSize=v;
        else
            error('@Trace: TraceSize must be numeric')
        end
    end
    
    function obj = set.TraceOneOffset(obj,v)
        if isnumeric(v)
            obj.TraceOneOffset=v;
        else
            error('@Trace: TraceOneOffset must be numeric')
        end
    end    
    
    function obj = set.HdrDef(obj,v)
        if iscell(v)
            obj.check(v);
            obj.HdrDef=v;
        else
            error('@Trace: HdrDef must be a valid cell array')
        end
    end

    function obj = set.ApplyCoordScalars(obj,v)
        if islogical(v)
            obj.ApplyCoordScalars=v;
        else
            error('@Trace: ApplyCoordScalars must be logical (true/false)')
        end
    end

    function obj = set.FormatCode(obj,v)
        if isnumeric(v)
            if (v>0 && v<13) || (v>14 && v<17)
                obj.FormatCode=v;
            else
                error(['@Trace: Unknown FormatCode: ' num2str(v)])
            end
        else
            error('@Trace: FormatCode must be numeric')
        end
    end

    
    function obj = set.TrcDatFormatCode(obj,v)
        if isnumeric(v)
            if (v>0 && v<13) || (v>14 && v<17)
                obj.TrcDatFormatCode=v;
            else
                error(['@Trace: Unknown FormatCode: ' num2str(v)])
            end            
        else
            error('@Trace: FormatCode must be numeric')
        end
    end
    
    function obj = set.SamplesPerTrace(obj,v)
        if isnumeric(v)
            obj.SamplesPerTrace=v;
        else
            error('@Trace: SamplesPerTrace must be numeric')
        end
    end    

    function obj = set.TracesPerRec(obj,v)
        if isnumeric(v)
            obj.TracesPerRec=v;
        else
            error('@Trace: TracesPerRec must be numeric')
        end
    end 

    function obj = set.TracesInFile(obj,v)
        if isnumeric(v)
            obj.TracesInFile=v;
        else
            error('@Trace: TracesInFile must be numeric')
        end
    end
    
    function obj = set.SampleInterval(obj,v)
        if isnumeric(v)
            obj.SampleInterval=v;
        else
            error('@Trace: SampleInterval must be numeric')
        end
    end    

    function obj = set.SegyRevision(obj,v)
        if isnumeric(v)
            obj.SegyRevision=v;
        else
            error('@Trace: SegyRevision must be numeric')
        end
    end    

    function obj = set.FixedTrcLength(obj,v)
        if isnumeric(v)
            obj.FixedTrcLength=v;
        else
            error('@Trace: FixedTrcLength must be numeric')
        end
    end    

    function obj=set.GUI(obj, v)
        if isnumeric(v)
            obj.GUI = logical(v);
        elseif islogical(v)
            obj.GUI = v;
        elseif isempty(v) || isa(v,'handle')
            obj.GUI = v;
        else
            error('@Trace: GUI must be numeric, empty, or a figure handle')
        end
    end    
    
    %Get functions
    function nb = get.BytesPerSample(obj)
        switch obj.TrcDatFormatCode        
            case 1 %ibm floating point
                nb = 4.0;
            case 2 %4-byte int
                nb = 4.0;
            case 3 %2-byte int
                nb = 2.0;
%             case 4 %4-byte fixed-point with gain (obsolete)
%                 nb = 4.0;;
            case 5 %4-byte IEEE
                nb = 4.0;
            case 6 %8-byte IEEE
                nb = 8.0;
%             case 7 %3-byte int
%                 nb = 3.0;
            case 8 %1-byte int
                nb = 1.0;
            case 9 %8-byte int
                nb = 8.0;
            case 10 %uint32
                nb = 4.0;                
            case 11 %uint16
                nb = 2.0;                
            case 12 %uint64
                nb = 8.0;               
%             case 15 %uint24
%                 nb = 3.0;
            case 16 %uint8
                nb = 1.0; 
            otherwise
                error(['@Trace: FormatCode ''' obj.FormatCode '''not supported ']);
        end        
    end %end get.bytesPerSample

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
 
    function st = get.HdrScalars(obj)
        %converts cols 1 and 4 of obj.HdrDef into a struct
        idx = cellfun(@(X) ~isempty(X),obj.HdrDef(:,4));
        st = cell2struct(obj.HdrDef(idx,4),obj.HdrDef(idx,1));        
    end %end get.HdrScalars

    function st = get.HdrLongName(obj)
        %converts cols 1 and 5 of obj.HdrDef into a struct
        st = cell2struct(obj.HdrDef(:,5),obj.HdrDef(:,1));
    end %end get.HdrLongName
    
    function dtype = get.FormatCodeType(obj)
        %for use with fread/fwrite
        switch obj.TrcDatFormatCode
            case 1 %ibm floating point
                dtype = 'uint32';
            case 2 %4-byte int
                dtype = 'int32';
            case 3 %2-byte int
                dtype = 'int16';
%             case 4 %4-byte fixed-point with gain (obsolete)
%                 dtype = 'fixed32';
            case 5 %4-byte IEEE
                dtype = 'single';
            case 6 %8-byte IEEE
                dtype = 'double';
            case 7 %3-byte int
                dtype = 'int24';
            case 8 %1-byte int
                dtype = 'int8';
            case 9 %8-byte int
                dtype = 'int64';
            case 10 %uint32
                dtype = 'uint32';                
            case 11 %uint16
                dtype = 'uint16';                
            case 12 %uint64
                dtype = 'uint64';                
            case 15 %uint24
                dtype = 'uint24';
            case 16 %uint8
                dtype = 'uint8';                
            otherwise
                error(['@Trace: FormatCode ''' num2str(obj.TrcDatFormatCode) ''' not supported ']);
        end
    end %end get.FormatCodeType

    function st = applyCoordinateScalars(obj, st)
        %apply coordinate scalars
        if obj.ApplyCoordScalars
            fnames = fieldnames(obj.HdrScalars);
            for ii = 1:length(fnames)
                hw = single(st.(fnames{ii})); %get header word values
                sc = single(st.(obj.HdrScalars.(fnames{ii}))); %get scalar values
                
                ps_idx = sc > 0;
                ns_idx = sc < 0;
                
                hw(ps_idx) = hw(ps_idx)./sc(ps_idx); %divide if scalar is positive
                hw(ns_idx) = hw(ns_idx).*abs(sc(ns_idx)); %multiply if scalar is negative
                
                st.(fnames{ii})=hw;
            end
        end        
    end
    
    function st=removeCoordinateScalars(obj, st)
        %remove coordinate scalars
        if obj.ApplyCoordScalars
            fnames = fieldnames(obj.HdrScalars);
            for ii = 1:length(fnames)
                hw = double(st.(fnames{ii})); %get header word values
                sc = double(st.(obj.HdrScalars.(fnames{ii}))); %get scalar values                
                
                ps_idx = sc > 0;
                ns_idx = sc < 0;
                
                hw(ps_idx) = hw(ps_idx).*sc(ps_idx); %multiply if scalar is positive
                hw(ns_idx) = hw(ns_idx)./abs(sc(ns_idx)); %divide if scalar is negative
                
                st.(fnames{ii})=hw;
            end
        end 
    end   
    
end%end methods

methods (Hidden)   

function [trcdata,trchead]=readBoth(obj,trcrange)
    ntrace = length(trcrange);
    [trcdata,trchead] = obj.new(ntrace); %pre-allocate memory
    if isempty(obj.GUI) || isa(obj.GUI,'handle')
        h = waitbar(0,['Reading ' num2str(ntrace) ' Trace(s): '],...
            'Name','SEG-Y Input',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0);
        mm_adjust(h);
    end
    for ii = 1:ntrace
        
        if isempty(obj.GUI) || isa(obj.GUI,'handle')
            %check for cancel button press
            if getappdata(h,'canceling')
                delete(h);
                break
            end            
            %update graphics progress bar
            waitbar(ii/ntrace,h);
            
        elseif obj.GUI
            %update text progress bar
            textbar(['Reading ' num2str(ntrace) ' Trace(s): '],...
                30,ii,ntrace);
        end
        
        %fseek to start of trace
        File.seek(obj.FileID,trcrange(ii),'bof');
        
        %read trace header
        for jj = 1:length(obj.HdrDef)
            ibmflag=false;
            fieldname = obj.HdrDef{jj,1};
            datatype = obj.HdrDef{jj,2};
            
            %take care of floating point and integer formats
            switch datatype
                case 'int24'
                    datatype='uint8';
                    int24flag=true;
                case 'uint24'
                    datatype='uint8';
                    uint24flag=true;                    
                case 'ibm32'
                    datatype='uint32';
                    ibmflag=true;
                case 'ieee32'
                    datatype='single';
                case 'ieee64'
                    datatype='double';
            end
            
            %Read header word and convert weird datatypes
            if int24flag
                hw = File.read(obj.FileID,3,datatype);
                trchead.(fieldname)(ii) = obj.int242num(hw,obj.FileEndian);
            elseif uint24flag
                hw = File.read(obj.FileID,3,datatype);
                trchead.(fieldname)(ii) = obj.uint242num(hw,obj.FileEndian);
            elseif ibmflag
                hw = File.read(obj.FileID,1,datatype);
                trchead.(fieldname)(ii) = obj.ibm2num(hw);
            else
                hw = File.read(obj.FileID,1,datatype);
                trchead.(fieldname)(ii) = hw;                
            end                                              
        end
        
        %read trace data
        td = File.read(obj.FileID,obj.SamplesPerTrace,obj.FormatCodeType);

        if isequal(obj.TrcDatFormatCode,1) %IBM floating point
            trcdata(:,ii) = obj.ibm2num(td);
        else
            trcdata(:,ii) = td;
        end

    end
    
    if isempty(obj.GUI) || isa(obj.GUI,'handle')
      %close waitbar
      delete(h);
    end
    
    %remove coordinate scalars
    trchead = obj.removeCoordinateScalars(trchead);
end

function trchead = readHeader(obj,trcrange)
    ntrace = length(trcrange);
    trchead  = obj.new(ntrace,0.0,'headers'); %pre-allocate memory

    if isempty(obj.GUI) || isa(obj.GUI,'handle')
        h = waitbar(0,['Reading Headers From ' num2str(ntrace) ' Trace(s): '],...
            'Name','SEG-Y Input',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0);
        mm_adjust(h);
    end
    
    for ii = 1:ntrace
        if isempty(obj.GUI) || isa(obj.GUI,'handle')
            %check for cancel button press
            if getappdata(h,'canceling')
                delete(h);
                break
            end   
            %update graphics progress bar
            waitbar(ii/ntrace,h);
        elseif obj.GUI
            %update text progress bar
            textbar(['Reading Headers From ' num2str(ntrace) ' Trace(s): '],...
                30,ii,length(trcrange))
        end
        
        %fseek to start of trace
        File.seek(obj.FileID,trcrange(ii),'bof');
        
        %read trace header
        for jj = 1:length(obj.HdrDef)
            ibmflag=false;
 
            fieldname = obj.HdrDef{jj,1};
            datatype = obj.HdrDef{jj,2};
            
            %take care of floating point formats
            switch datatype
                case 'ibm32'
                    datatype='uint32';
                    ibmflag=true;
                case 'ieee32'
                    datatype='single';
                case 'ieee64'
                    datatype='double';
            end
            
            %read header word
            hw = File.read(obj.FileID,1,datatype);           
            
            %take care of IBM floats and assign data to struct
            if(ibmflag)
                trchead.(fieldname)(ii) = obj.ibm2num(hw);
            else
                trchead.(fieldname)(ii) = hw;                
            end
        end              
    end
    
    if isempty(obj.GUI) || isa(obj.GUI,'handle')
      %close waitbar
      delete(h);
    end
                
    %remove coordinate scalars
    trchead = obj.removeCoordinateScalars(trchead);
end

function trcdata = readData(obj,trcrange)
    ntrace = length(trcrange);
    trcdata = obj.new(ntrace,0.0,'data'); %pre-allocate memory
   
    if isempty(obj.GUI) || isa(obj.GUI,'handle')
        h = waitbar(0,['Reading Data From ' num2str(ntrace) ' Trace(s): '],...
            'Name','SEG-Y Input',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0);
        mm_adjust(h);
    end
    
    for ii = 1:ntrace
        if isempty(obj.GUI) || isa(obj.GUI,'handle')
            %check for cancel button press
            if getappdata(h,'canceling')
                delete(h);
                break
            end 
          %graphics progress bar  
          waitbar(ii/ntrace,h);
        elseif obj.GUI
          %text progress bar
          textbar(['Reading Data From ' num2str(ntrace) ' Trace(s): '],...
              30,ii,ntrace)
        end
        
        %fseek to start of trace data
        File.seek(obj.FileID,trcrange(ii)+obj.HDRSIZE,'bof');
         
        %read trace data
        if isequal(obj.FormatCodeType,'int24') || isequal(obj.FormatCodeType,'uint24')
            nsamps = obj.SamplesPerTrace*3;
            fctype = 'uint8';
        else
            nsamps = obj.SamplesPerTrace;
            fctype = obj.FormatCodeType;           
        end
        
        td = File.read(obj.FileID,nsamps,fctype);

        if isequal(obj.TrcDatFormatCode,1) %IBM floating point
            trcdata(:,ii) = obj.ibm2num(td);
        elseif isequal(obj.TrcDatFormatCode,7) %int24
            trcdata(:,ii) = obj.int242num(td,obj.ByteOrder);
        elseif isequal(obj.TrcDatFormatCode,15) %uint24
            trcdata(:,ii) = obj.uint242num(td,obj.ByteOrder);
        else
            trcdata(:,ii) = td;
        end    
    end
    
    if isempty(obj.GUI) || isa(obj.GUI,'handle')
      %close waitbar
      delete(h);
    end    
end

function hw = readHeaderWord(obj,trcrange,whattoread)
    hw = readHeaderWordIgnoreScalars(obj,trcrange,whattoread);
    
    if obj.ApplyCoordScalars %remove coordinate scalars                    
        %Get header word scalar name that should be applied
        try
            hwsname = obj.HdrScalars.(whattoread);            
        catch ex
            %most likely we're here because the header word does not need to have a scalar applied
            %disp(ex.message)
            return
        end
        
        sc = readHeaderWordIgnoreScalars(obj,trcrange,hwsname,gui);
        ps_idx = sc > 0;
        ns_idx = sc < 0;
        
        hw=double(hw);
        sc=double(sc);
        
        hw(ps_idx) = hw(ps_idx).*sc(ps_idx); %multiply if scalar is positive
        hw(ns_idx) = hw(ns_idx)./abs(sc(ns_idx)); %divide if scalar is negative
    end   
end

function hw=readHeaderWordIgnoreScalars(obj,trcrange,whattoread)
    ibmflag=false;    
    
    %check to see if whattoread is a valid field
    if ~isfield(obj.HdrDataTypes,whattoread)
        error(['@Trace: Header word ''' whattoread ''' not found in obj.HdrDef']);
    end    
    
    datatype = obj.HdrDataTypes.(whattoread);
    hwoffset = obj.HdrStartBytes.(whattoread);
    
    %take care of floating point formats
    switch datatype
        case 'ibm32'
            datatype='uint32';
            ibmflag=true;
        case 'ieee32'
            datatype='single';
        case 'ieee64'
            datatype='double';
    end
        
    %pre-allocate memory
    ntrace = length(trcrange);
    hw=obj.newHeaderWord(length(trcrange),datatype);

    if isempty(obj.GUI) || isa(obj.GUI,'handle')
        h = waitbar(0,['Reading Header Word ''' whattoread ''' from ' num2str(ntrace) ' Trace(s): '],...
            'Name','SEG-Y Input',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0);
        mm_adjust(h);
    end
    
    for ii = 1:ntrace
        if isempty(obj.GUI) || isa(obj.GUI,'handle')
            %check for cancel button press
            if getappdata(h,'canceling')
                delete(h);
                break
            end     
          %graphics progress bar  
          waitbar(ii/ntrace,h);
        elseif obj.GUI
          %text progress bar
          textbar(['Reading Header Word From ' num2str(ntrace) ' Trace(s): '],...
              30,ii,ntrace)
        end        
        
        %fseek to start of header word
        File.seek(obj.FileID,trcrange(ii)+hwoffset,'bof');
        
        %read header word
        hw(ii) = File.read(obj.FileID,1,datatype);
    end
    
    if isempty(obj.GUI) || isa(obj.GUI,'handle')
        %close waitbar
        delete(h);
    end
    
    %convert IBM floats to 'single'
    if ibmflag %IBM floating point
        hw = obj.ibm2num(hw);
    end
       
end

function th = newHeader(obj,ntrace,sampint)
    for ii = 1:length(obj.HdrDef)
        th.(obj.HdrDef{ii,1}) = obj.newHeaderWord(ntrace,obj.HdrDef{ii,2});
    end
    if ~isempty(sampint)
        fieldname = obj.byte2word(116); %stored in byte 115; SEG-Y standard
        th.(fieldname)(1:end) = sampint*1e6; %microseconds
    end
end

function td = newData(obj,ntrace)
    if isequal(obj.FormatCode,1)
        td = zeros(obj.SamplesPerTrace,ntrace,'single');
    else
        td = zeros(obj.SamplesPerTrace,ntrace,obj.FormatCodeType);
    end
end

end %end methods (Hidden)

methods (Static)
    td = newDefinition(segyrev,numexthdrs);
    hw = newHeaderWord(ntrace,datatype);
    [d,f,t] = struct2double(s);
    s = double2struct(d,f,t);

end % end static methods


end %end classdef
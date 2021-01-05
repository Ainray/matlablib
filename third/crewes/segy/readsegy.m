function varargout = readsegy(varargin)
% function [trcdat,segyrevision,sampint,fmtcode,txtfmt,bytorder,txthdr,...
%           binhdr,exthdr,trchdr,bindef,trcdef] = ...
%    readsegy(filename,trcrange,segyrevision,sampint,nsamp,fmtcode,txtfmt,...
%           byteorder,bindef,trcdef,gui)
%                               
% Reads segy data into Matlab structures, arrays and scalars
%
% Required Inputs:
% filename   - filename (should end in .sgy or .segy)
%
% Optional Inputs ([] is accepted):
% trcrange  - Traces to read from SEG-Y file. eg. 1:2:10.
%             Default ([]) attempts to read all traces in the file
% segyrevision - segy revision (0,1,2); Overrides SEG-Y Binary File Header on
%             disk.
% sampint   - Sample interval in (s); Overrides SEG-Y Binary File Header on
%             disk.
% nsamp     - Samples per trace; Overrides SEG-Y Binary File Header on
%             disk.
% fmtcode   - SEG-Y trace data format code. eg. 1 = IBM float, 5 = IEEE
%             float
% txtfmt    - Textual file header format, 'ascii' or 'ebcdic'
% byteorder - byte order of disk file 'l'=little-endian, 'b'=big-endian
% bindef    - 4 column binary header definition cell array such as provided by
%             @BinaryHeader/new; See uiSegyDefinition().
%             NOTE! writesegy requires the same custom bindef used with 
%             readsegy unless you modify the binhdr struct to match!
% trcdef    - 5 column trace header definition cell array such as provided by
%             @BinaryHeader/new; See uiSegyDefinition()
%             NOTE! writesegy requires the same custom trcdef used with 
%             readsegy unless you modify the binhdr struct to match!
% gui       - 0 (no progress bar or prompts; guess and go...); 1 (text
%             progress bar and prompts; [] (default; gui progress bar and 
%             prompts, uses uiSegyFile); figure handle, same as [], 
%             but an attempt is made to center GUI prompts on the figure 
%             represented by figure handle; {figure handle}, same as figure
%             handle, but uses SegyFile() instead of uiSegyFile()
%
% Outputs:
% trcdat    - 2-D numeric array containing the trace data
% segyrevision - segy revision (0,1,2) that was used to read trcdat from
%             sgyfile
% sampint   - Sample interval from SEG-Y binary file header (s)
% fmtcode   - trace format code; **THIS may not match binary header in the
%             case of SEG-Y format code 1 (IBM float). If this script
%             determines the data is actually IEEE float it will return a 5
% txtfmt    - text file forma; 'ascii' or 'ebcdic'
% bytorder  - file byte-order; 'b'=big-endian, 'l'=little-endian
% txthdr    - 2-D char array containing SEG-Y textual file header (ASCII)
% binhdr    - Binary Header struct (see @BinaryHeader); Read off disk using
%             segy revision number in the disk file, OR, in
%             segyrev (input), OR using a custom bindef (input). Values are
%             NOT updated from the disk file and may not match readsegy
%             overrides such as 'sampint', 'segyrev', etc.
% exthdr    - 2-D char array containing SEG-Y SEG-Y extended textual file
%             headers. exthdr=[] if the SEG-Y file has no extended headers
% trchdr    - Trace header struct (see @Trace); Read off disk using
%             segy revision number in the disk file, OR, in
%             segyrev (input), OR using a custom trcdef (input). Values are
%             NOT updated from the disk file and may not match readsegy
%             overrides such as 'sampint', 'segyrev', etc.
% bindef    - The binary header definition that was used to read binhdr
%             NOTE! writesegy will require the same bindef unless you
%             modify trchdr!
% trcdef    - The trace header definition that was used to read trchdr
%             NOTE! writesegy will require the same trcdef unless you
%             modify trchdr!
%
% Example: 
%    [trcdat,dt,trchdr,txthdr,binhdr,exthdr] = readsegy('test.sgy',1:2:100)
%
% NOTE: This script is a wrapper for @SegyFile/read
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

narginchk(1,11)
guiflag = true;

if nargin<2
    trcrange=[];
elseif nargin>1
    trcrange=varargin{2};
end

if isequal(nargin,11) && iscell(varargin{11})
    varargin{11} = varargin{11}{1};
    guiflag = false;
end

% Instantiate a SegyFile object
if isequal(nargin,11) && (isempty(varargin{11}) || isa(varargin{11},'handle') && guiflag)
    sf = uiSegyFile(varargin{1},'r',varargin{3:end});
else
    sf = SegyFile(varargin{1},'r',varargin{3:end});
end

%Set Outputs
%trcdef
varargout{12} = sf.Trace.HdrDef;
%bindef
varargout{11} = sf.BinaryHeader.HdrDef;
%exthdr
varargout{9}  = sf.ExtendedTextHeader.read;
%binhdr
varargout{8}  = sf.BinaryHeader.read;
%txthdr
varargout{7}  = sf.TextHeader.read;
%bytord
varargout{6}  = sf.ByteOrder;
%txtfmt
varargout{5}  = sf.TextHeader.TextFormat;
%segfmt
varargout{4}  = sf.FormatCode;
%sampint (s)
varargout{3}  = double(sf.SampleInterval)*1e-6; %convert to seconds
%segyrev
varargout{2}  = sf.SegyRevision;
%[trchdr,trcdat]
[varargout{10}, varargout{1}] = sf.Trace.read(trcrange,'both');

%end function readsegy
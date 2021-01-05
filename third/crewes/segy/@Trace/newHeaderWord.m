function hw = newHeaderWord(ntrace,datatype)
%
% function td = newHeaderWord(ntrace,datatype)
%
% newHeaderWord() creates a zero filled vector of the appropriate header word
% data type. eg. newHeaderWord(100,'uint32');
%
% Authors: Kevin Hall, 2016, 2017
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

switch datatype
    case 'uint8'
        hw = zeros(1,ntrace,'uint8');
    case 'int8'
        hw = zeros(1,ntrace,'int8');
    case 'uint16'
        hw = zeros(1,ntrace,'uint16');
    case 'int16'
        hw = zeros(1,ntrace,'int16');
    case 'uint32'
        hw = zeros(1,ntrace,'uint32');
    case 'int32'
        hw = zeros(1,ntrace,'int32');
    case 'uint64'
        hw = zeros(1,ntrace,'uint64');
    case 'int64'
        hw = zeros(1,ntrace,'int64');        
    case 'ieee32'
        hw = zeros(1,ntrace,'single');
    case 'single'
        hw = zeros(1,ntrace,'single');       
    case 'ibm32'
        hw = zeros(1,ntrace,'single');
    case 'ieee64'
        hw = zeros(1,ntrace,'double');
    case 'double'
        hw = zeros(1,ntrace,'double');        
    otherwise
        error(['@Trace/newHeaderWord: Unknown data type: ' datatype])
end %end switch

end %end function



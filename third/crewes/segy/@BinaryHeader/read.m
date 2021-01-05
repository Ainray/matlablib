function bh = read ( obj )
%
% function bh = read ( obj )
%
% Read the binary file header from a SEG-Y file
% Returns:
%   bh as a struct
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

%position pointer at start of header
File.seek(obj.FileID,obj.HDROFFSET,'bof');

count=1;
ibmflag    = false;
int24flag  = false;
uint24flag = false;

for ii = 1:length(obj.HdrDef)
    switch obj.HdrDef{ii,2}
        case 'int24'
            datafmt = 'uint8';
            int24flag = true;
            count=3;
        case 'uint24'
            datafmt = 'uint8';
            uint24flag = true;
            count=3;            
        case 'ibm32'
            datafmt = 'uint32';
            ibmflag = true;
        case 'ieee32'            
            datafmt = 'single';
        case 'ieee64'
            datafmt = 'double';
        otherwise
            datafmt = obj.HdrDef{ii,2};
    end
       
    v = File.read(obj.FileID,count,datafmt);
    
    if int24flag
       v = int242num(v,obj.ByteOrder); 
       int24flag=false;
    elseif uint24flag
       v = uint242num(v,obj.ByteOrder);
       uint24flag=false;
    elseif ibmflag
       v = single(SegyFile.Trc.ibm2num(v));
       ibmflag=false;
    end
    
    bh.(obj.HdrDef{ii,1}) = v;
end
        
end
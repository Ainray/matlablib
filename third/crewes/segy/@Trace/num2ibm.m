function u = num2ibm(d)
%
% function u = num2ibm(d)
% Where:
%     u = IBM 4-byte float stored as a 32-bit unsigned integer
%     d = Any number(s) stored in any Matlab datatype. vectors and arrays
%         are OK
%
% WARNING! It is the users responsibility to make certain that:
%     d = 0.0 || IBM_MIN < d < IBM_MAX
%                 OR
%     d = 0.0 || IEEE_MIN < d < IEEE_MAX if the user
%     intends to read the encoded number using a typical commercial seismic
%     processing software
%
%   IBM_MIN = 16.0^-65.0;                % =~ 5.3976e-79 (+) min
%   IBM_MAX = (1.0-16.0^-6.0)*16.0^63.0; % =~ 7.2370e+75 (+) max
%  IEEE_MIN = realmin('single');         % =~ 1.1755e-38 (+) min
%  IEEE_MAX = realmax('single');         % =~ 3.4028e+38 (+) max
%
% Example:
%
% fid = fopen('test.ibm','w','ieee-be')
% u = num2ibm([realmin('single') realmax('single')])
% fwrite(fid,u,'uint32')
% fclose(fid)
%
% Authors: Kevin Hall, 2017
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%

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

%
%https://en.wikipedia.org/wiki/...
%   IBM_Floating_Point_Architecture#Single-precision_32-bit
%   Accessed Feb, 2017
%
%IBM 4-byte floats are encoded using the formula:
% (-1)^sign * 0.fraction * 16^(ibm_exponent +ibm_bias)
% where ibm_bias is defined to be +64.
%
% The sign is stored in bit 32 (the most significant bit of the most
%     significant byte)
% The exponent+bias is stored in bits 25-31 (the most significant byte)
% The normalized fraction is stored in bits 1-24 (three least significant bytes)
%

debug = false;

%Make sure we are playing with doubles
d = double(d);

%get signbit
sbit = floor((1-sign(d))/2.0); % 0 == (+), 1 == (-)

%get exponent and fraction that satisfy v = f*2^e 
[f,e] = log2(abs(d));

%convert e to equivalent ibm exponent, add exponent bias (+64), and encode
eibm = uint32(ceil(e/4) +64)*2^(24);

%normalize fraction, and shorten to 3 bytes with rounding (not rounded if
%bitshift is used).
zpad = mod(4-mod(e,4),4); % in range 0:3
fibm = uint32(f.*2.^(24-zpad)); % normalizes and pads 0:3 zeros to msbit end of fraction

%assemble answer
u = bitset(bitor(eibm,fibm),32,sbit);

if debug, printans(u,d); end

end

function printans(u,d)
    fprintf('%s\n', 'double to convert to IBM single = '); 
    fprintf('  %0.15g\n',d);    
    fprintf('%s\n', 'IBM single typecast as uint32 (hex) = '); 
    fprintf('  %08x\n',u);
    fprintf('%s\n', 'IBM uint32 converted back to double = ');
    fprintf('  %0.15g\n',ibm2num(u));
end







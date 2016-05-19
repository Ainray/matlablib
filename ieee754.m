function [s,e,f] = ieee754(x,fmt,pre)
% refer to:
%    http://www.mathworks.com/matlabcentral/fileexchange/25326-ieee-754-binary-representation
%  add single represention by Ainray(wwzhang0421@163.com)
%   example:
%       [s,e,f]=ieee754(-5.5);
%       [s,e,f]=ieee754(-5.5,'dec');
%       [s,e,f]=ieee754(-5.5,'dec','single')
%       [s,e,f]=ieee754(-5.5,'bin','single')
%       [s,e,f]=ieee754(1.316554e-36,'bin','single')
%       [s,e,f]=ieee754(0.00001233862713,'dec','single')
%       [s,e,f]=ieee754(1,'dec','single')
%       [s,e,f]=ieee754(1.996093750,'dec','single')
%       [s,e,f]=ieee754(636.0312500,'dec','single')
%       [s,e,f]=ieee754(217063424.0,'dec','single')


%IEEE754 Decompose a double precision floating point number.
% [S,E,F] = IEEE754(X) returns the sign bit, exponent, and mantissa of an
% IEEE 754 floating point value X, expressed as binary digit strings of
% length 1, 11, and 52, respectively. 
%
% S = IEEE754(X) returns one string of length 64.
%
% [S,E,F] = IEEE754(X,'dec') returns S, E, and F as floating-point numbers.
%
% X is equal to (in exact arithmetic and decimal notation)
%
%      (-1)^S * (1 + F/(2^52)) *  2^(E-1023),
%
% except for special values 0, Inf, NaN, and denormalized numbers (between
% 0 and REALMIN). 
%
% See also FORMAT, REALMAX, REALMIN, BIN2DEC.

% Copyright 2009 by Toby Driscoll (driscoll@udel.edu). 
% Thanks to Andreas Luettgens for the suggestion of NUM2HEX.

% Licence, moved from Licence file
% Copyright (c) 2013, Tobin Driscoll
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

if ~isreal(x) || numel(x) > 1 || ~isa(x,'double')
  error('Real, scalar, double input required.')
end
if nargin<3
    pre='double';
end
if strcmpi(pre,'double')
    N=64;
    seg=[2,13];
    hex = num2hex(x);        % string of 16 hex digits for x
else
    N=32;
    seg=[2,10];
    hex=num2hex(single(x));
end
hex=hex(1:N/4);
dec = hex2dec(hex');     % decimal for each digit (1 per row)
bin = dec2bin(dec,4);    % 4 binary digits per row
bitstr = reshape(bin',[1 N]);  % string of 64 bits in order

% Return options
if nargout<2
  s = bitstr;      
else
  s = bitstr(1);
  e = bitstr(seg(1):seg(2)-1);
  f = bitstr(seg(2):N);
  if nargin > 1 && isequal(lower(fmt),'dec')
    s = bin2dec(s);  
    e = bin2dec(e);
    f = eval(['Fr_bin2dec(.',f,')']);
  end
end
function tf = cellstr2logical(c, casesensitive)
%
% this LICENSE moved by Ainray, 20160321, it is also apply to logical2cellstr
% Copyright (c) 2009, Richie Cotton
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

% Converts cell arrays of 'true' or 'false' strings to logcal arrays.
% 
% TF = CELLSTR2LOGICAL(C) takes a cell array of strings and returns a
% logical array.  Where the input value is 'true' (matched case
% insensitively), then the corresponding return value is true.
% Likewise, where the input value is 'false' (matched case
% insensitively), then the corresponding return value is false.  An
% error is thrown if any other strings are contained in c.
% 
% TF = CELLSTR2LOGICAL(C, 1) is as above, but the strings are matched
% case sensitively.
% 
% EXAMPLES:
% cellstr2logical({'false', 'True'; 'TRUE' 'FAlsE'})
% ans =
%      0     1
%      1     0
% 
% cellstr2logical({'false', 'True'; 'TRUE' 'FAlsE'}, 1)
% ??? Error using ==> cellstr2logical at 30
% The input contained a string that wasn't 'true' or 'false'  
% 
% $ Author: Richard Cotton $		$ Date: 2009/07/10 $    $ Version 1.2 $
%
% See also LOGICAL2CELLSTR, CELL2MAT, CELL2STRUCT

if nargin < 1 || isempty(c)
   tf = [];
   return;
end

if nargin < 2 || isempty(casesensitive)
   casesensitive = false;
end

if casesensitive
   cmpfn = @strcmp;
else
   cmpfn = @strcmpi;
end

if ~iscellstr(c)
   error('cell2logical:NotCellstr', ...
      'The input was not a cell array of strings.');
end

tf = cmpfn(c, 'true');

if ~all(tf(:) | cmpfn(c(:), 'false'))
   error('cell2logical:BadString', ...
      'The input contained a string that wasn''t ''true'' or ''false''.');
end

end
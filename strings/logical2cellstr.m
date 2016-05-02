function c = logical2cellstr(tf)
% Converts logical arrays to cell array of strings.
% 
% C = LOGICAL2CELLSTR(TF) takes a logical array TF, and returns a cell
% array of strings, with the value 'true' wherever  TF is true, and
% 'false' wherever TF is false.
% 
% EXAMPLE:
% logical2cellstr([true false; false true])
% ans = 
%     'true'     'false'
%     'false'    'true' 
% 
% $ Author: Richard Cotton $		$ Date: 2009/07/09 $    $ Version 1.1 $
%
% See also CELLSTR2LOGICAL, NUM2CELL, MAT2CELL

if nargin < 1 || isempty(tf)
   c = {};
   return;
end

if ~islogical(tf)
   error('cell2logical:NotLogical', ...
      'The input was not logical.');
end

c = cell(size(tf));
c(:) = {'false'};
c(tf) = {'true'};
end
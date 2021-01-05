function word = getHeaderWord ( obj, wordname)
%
% function word = getHeaderWord(obj, wordname)
%
% I don't recall what this does.
%
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

%get row index in definitions spreadsheet for wordname
w = strmatch(upper(wordname),upper(obj.definitions.values(:,obj.definitions.n)));

%get info for header word
sbyte = str2double(obj.definitions.values{w,obj.definitions.s});
ebyte = str2double(obj.definitions.values{w,obj.definitions.e});
type  = obj.definitions.values{w,obj.definitions.t};

%get header words
word  = obj.header(sbyte:ebyte,:);
[m n] = size(word);
word  = typecast( reshape(word,m*n,1),type );

%byte order
[c m e] = computer;

%assume segy is big-endian
if (strcmp(e,'L'))
    word=swapbytes(word);
end

end
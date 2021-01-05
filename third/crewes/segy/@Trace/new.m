function varargout = new ( obj, ntrace, sampint, whatsnew )
%
%function varargout = new ( obj, ntrace, sampint, whatsnew )
%
% Returns zeroed trace header struct constructed using Trace.HdrDef and/or 
% a zeroed trace data matrix with dataype determined by Trace.FormatCode
%
%    ntrace   = number of traces to be represented (default = 1)
%    sampint  = sample interval in seconds or [] (default)
%    whatsnew = 'both' (default) | 'headers' | 'data'
%
% Examples:
%   [td,th] = new(10,'both')
%   th = new(10,'headers')
%   td = new(10,'data')
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

narginchk(1,4)

if nargin <2
    ntrace = 1;
end

if nargin <3
    sampint = [];
end

if nargin <4
    whatsnew = 'both';
end

switch(whatsnew)
    case 'both'
        varargout{1} = obj.newData(ntrace);
        varargout{2} = obj.newHeader(ntrace,sampint);
    case 'headers'
        varargout{1} = obj.newHeader(ntrace,sampint);
        varargout{2} = [];
    case 'data'
        varargout{1} = obj.newData(ntrace);
        varargout{2} = [];
    otherwise
        error(['@Trace/new: Unknown whatsnew: ' whatsnew]);
end

end  %end function
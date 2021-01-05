function trchdrout=tracehdr_subset(trchdr,indx)
% Given a trace header structure, extract a subset.
%
% trchdrout=tracehdr_subset(trchdr,indx)
%
% trchdr ... trace header structure as returned from SegyTrace or SegyFile or readsegy.
% indx ... vector of indicies of the desired subset. For example 1:10:ntraces gets every 10th trace
%       and 1:100 gets the first 100 traces. nan's present in indx indicate zero traces that were
%       not present in the original segy. Such traces will have an empty trace header returned.
% 
% G.F. Margrave, Margrave-Geo, 2017-2020
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

%check for nans in indx
%When using make3Dvol, zero traces may exist in the volume that were not part of the original SEGY
%and therefore have no trace header. These are flagged by make3Dvol with a kseq number of nan. For
%compatibility, indx is allowed to have nans and these are matched with empty trace headers.
inan=find(isnan(indx), 1);
nanflag=0;
if(~isempty(inan))
    nanflag=1;
end

fields=fieldnames(trchdr);
trchdrout=trchdr;
nx=length(trchdr.(fields{1}));
ind=find(indx>nx, 1);
if(~isempty(ind))
    error('Some requested traces numbers exceed the largest possible');
end
if(~nanflag)
    for k=1:length(fields)
        dat=trchdr.(fields{k});
        trchdrout.(fields{k})=dat(indx);
    end
else
    ind=~isnan(indx);
    for k=1:length(fields)
        dat=trchdr.(fields{k});%trace header values for field #k for all traces
        dat2=zeros(size(indx),'like',dat);%this will be larger than dat by the number of nans
        dat2(ind)=dat(indx(ind));
        trchdrout.(fields{k})=dat2;
    end
end
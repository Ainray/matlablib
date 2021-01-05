%
% SEG-Y
%
% Read, write or create SEG-Y files. Can handle SEG-Y revisions 0,1 and 2
% with the exceptions of extended textual file headers, variable length
% traces, extended trace headers, data trailers. Primary author and 
% maintainer: Kevin Hall
%
% Latest Documentation: 
% README.pdf
%
% Test Harness: 
% EXAMPLESEGYCODE - Test harness. Requires 1042.sgy, or edit line 5.
%
% Classes:
% SEGYBINARYHEADER - Read/write/new binary file headers
% SEGYTEXTHEADER - Read/write/new textual file headers
% SEGYEXTENDEDTEXTHEADER - Read/write/new extended textual file headers
% SEGYTRACE - Read/write/new segy trace headers and data
% SEGYFILE - Read/write/new segy file (includes all previous classes)
%
% Graphical user interfaces:
% UISEGYFILE - Inspect SEG-Y file and return SegyFile object
% UISEGYDEFINITION - Modify SEG-Y file and header definitions
% VIEWBINHEADER (Margrave) - View binary file header
% VIEWTEXTHEADER (Margrave) - View textual file header
% VIEWTRACEHEADERS (Margrave) - View trace headers
% SEGYTRACEINSPECTOR (Margrave) - Display traces
% TRACEHEADERDUMP (Margrave) - Dump trace headers
% TRACEHEADERDUMP_G (Margrave) - Interactive browsing of trace headers from
%      a SEGYFILE object
%
% Wrappers:
% READSEGY - Use SegyFile to read a SEG-Y file
% WRITESEGY - Use SegyFile to write a SEG-Y file
%
% Utilities:
% TRACEBYTE2WORD - Convert byte location to header word label 
%      (see UISEGYDEFINITON)
% TRACEWORD2BYTE - Convert header word label to byte location
% TRACEHDR_SUBSET (Margrave) - Given a trace header structure, extract a subset
% TRACEHEADERDUMP (Margrave) - Dump all trace headers from a SegyFile object
%
% Obsolete:
% ALTREADSEGY - Deprecated, to be removed in a future release
% ALTWRITESEGY - Deprecated, to be removed in a future release% 
%

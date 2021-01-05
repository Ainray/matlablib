function y = hilbm(x)
% HILBM: Hilbert transform
%
% HILBERT Hilbert transform.
%
% Modified from Matlab's version to require the input to be
% a power of 2 in length. by GFM 
%
%	HILBERT(X) is the Hilbert transform of the real part
%	of vector X.  The real part of the result is the original
%	real data; the imaginary part is the actual Hilbert
%	transform.  See also FFT and IFFT.
%
%	Charles R. Denham, January 7, 1988.
%	Revised by LS, 11-19-88.
%	Copyright (C) 1988 the MathWorks, Inc.
%
% Reference: Jon Claerbout, Introduction to
%            Geophysical Data Analysis.
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
nx=length(x);
nx2=2.^nextpow2(length(x));

yy = fft(real(x),nx2);
m = length(yy);
if m ~= 1
	h = [1; 2*ones(m/2,1); zeros(m-m/2-1,1)];
	yy(:) = yy(:).*h;
end
tmp = ifft(yy);
y=tmp(1:nx);
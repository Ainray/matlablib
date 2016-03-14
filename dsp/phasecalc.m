% function ph=phasecalc(X)
% author: Ainray
% date: v1,20160302
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: get phase angle of complex matrix, normalized into [-pi,pi),
%               if the absolute value is less than specified precision, the 
%               phase will be unset by zeros.
% input:
%         X, complex matrix
% output:
%        ph, the phase
%       pre, the specified precision; if not given, assumed to be 1e-5
function ph=phasecalc(X,pre)
    if nargin<2
        pre=eps;
    end
    ph=atan2(imag(X),real(X)); 
    ph(abs(X)<pre)=0;
function [fbw,fdom,fd]=freqbw(w,t,p)
%DOMFREQ ... Estimate the dominant frequency of a signal
%
% fbw=freqbw(w,t,p);
%
% If W is the Fourier transform of the input signal, then the dominant
% frequency is estimated by the centroid method
% fdom=Int(f*abs(W).^p)/Int(abs(W).^p)
% where f is frequency, Int is an integral over frequency, and p is
% typically 2.
%
% w ... input signal (maybe a wavelet)
% t ... time coordinate for w
% p ... small integer
% **********default p=2 ********
%
% fdom ... dominant frequency of w
%
% by G.F. Margrave, 2013
%
% NOTE: It is illegal for you to use this software for a purpose other
% than non-profit education or research UNLESS you are employed by a CREWES
% Project sponsor. By using this software, you are agreeing to the terms
% detailed in this software's Matlab source file.
 
% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by 
% its author (identified above) and the CREWES Project.  The CREWES 
% project may be contacted via email at:  crewesinfo@crewes.org
% 
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) Use of this SOFTWARE by any for-profit commercial organization is
%    expressly forbidden unless said organization is a CREWES Project
%    Sponsor.
%
% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the 
%    CREWES Project Sponsorship agreement.
%
% 3) A student or employee of a non-profit educational institution may 
%    use this SOFTWARE subject to the following terms and conditions:
%    - this SOFTWARE is for teaching or research purposes only.
%    - this SOFTWARE may be distributed to other students or researchers 
%      provided that these license terms are included.
%    - reselling the SOFTWARE, or including it or any portion of it, in any
%      software that will be resold is expressly forbidden.
%    - transfering the SOFTWARE in any form to a commercial firm or any 
%      other for-profit organization is expressly forbidden.
%
% END TERMS OF USE LICENSE

if(nargin<3)
    p=2;
end

if(sum(abs(w))==0)
    error('Input signal is all zero')
end
thresh=.5;
[W,f]=fftrl(w,t);
A=abs(W);
[Ad,id]=max(A);
fdom=f(id);
ind=find(A>thresh*Ad);
fd=mean(f(ind));
fbw=max(f(ind))-min(f(ind));

function [wall,twall]=toall2(w,tw,pctwht)

% [wall,tw]=toall(wavelet,twin,stab)
% wall=toall(wavelet,twin)
% wall=toall(wavelet)
%
% TOALL uses FFT to capture the phase spectrum of an arbitrary
% wavelet and outputs an 'all pass' equivalent.
%
% wavelet= input waveform to be converted
% twin=input time coordinate
% ************* default = not used and no output time coordinate
%               will be supplied *********
% stab=stab factor
% ************* default =.0001 ***********
%
% winv= output all pass wavelet
% tw= output time coordinate (only possible if twin is supplied)
%
% note: this result is not usually causal, use CONVZ to apply
% it (default time zero to length(winv)/2)
% 
% by G.F. Margrave, June 1991
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
% project may be contacted via email at:  crewes@geo.ucalgary.ca
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

 if(nargin<3) pctwht=50; end
 [W,f]=fftrl(w,tw);
 Wall=mwhalf(length(W),100-pctwht).*exp(i*angle(W));
 wall=ifftrl(Wall,f);
 
 env=abs(hilbert(wall));
 ind=find(env==max(env));
 dt=tw(2)-tw(1);
 nt=length(wall);
 twall=dt*((0:nt-1) - ind(1)+1);
 

 




 		
    

function phs=wavelet_phase(w,tw)
% Estimate the phase of any wavelet
%
% phs=wavelet_phase(w,tw)
%
% Method: If the wavelet is causal, it is first modified to include as much negative time as
% positive time to allow samples to rotate into negative time. Then the phase is estimated by
% comparing the wavelet to a unit spike placed at time zero in a same-length reference signal.
% Comparision is done with constphase3.m 
%
% w... the wavelet
% tw ... time coordinates for w (same size as w)
% 

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

izero=near(tw,0);
if(izero(1)==1)
    %causal so pad
    tmax=tw(end);
    tmp=tw;
    dt=tmp(2);
    tw=-tmax:dt:tmax;
    nzero=length(tw)-length(tmp);
    w=[zeros(nzero,1);w];
    izero=izero+nzero;
end
spike=impulse(w,izero)*max(abs(w));

phs=constphase3(spike,w);


function [wavelets,tws]=extract_wavelets_match(s,t,r,t0s,twins,wlen,mu,pctnotcausal)
% EXTRACT_WAVELETS_MATCH: extract time variant embedded wavelets with match filtering
%
% [wavelets,tws]=extract_wavelets_match(s,t,r,t0s,twins,wlen,mu,pctnotcausal)
%
% Given a seismic trace and a corresponding reflectivity, this function
% estimates the time-varying embedded wavelets at user-defined times and
% windows. The wavelets are not constrained to be causal. This function
% calls MATCHS to estimate the wavelet in each time zone after isolating
% trace segments in the defined windows. The windowed trace is compared to
% the windowed reflectivity to estimate each wavelet. Using MATCHS to
% estimate the wavelets means that they are derived by least-squares
% time-domain match filtering with a smoothness constraint. As a first step
% prior to windowing, both s and r are normalized to have a maximum of 1.
% After deriving the match filter, the overall amplitude of the wavelet is
% adjusted by least-squares subtraction. That is, the wavelet is convolved
% with the unnormalized reflectivity (in the window) and a scalar is found
% to minimize the L2 norm of the residual between this convolution and the
% original unnormalized trace (in the window).
%
% s ... input seismic trace
% t ... time coordinate for s
% r ... reflectivity (time domain)
% NOTE: s,t, and r must all be exactly the same size. This usually means
%       that you must isolate the position of your seismic that correlates to r.
% t0s ... vector of wavelet extraction times. These are the center times of
%       the extraction windows.
% twins ... vector of window widths. May be a vector the same length as t0s
%       or a single entry if the windows are the same length.
% NOTE: t0s and twins must be vectors of the same length, or twins must be
%       a scalar.
% wlen ... length of the estimated wavelet expressed as a fraction of
%          twins. Since the wavelets are least-squares match filters, it is
%          possible to prescribe this length and this acts as a control.
%          Allowing too long a wavelet will match anything to anything
%          else, while too short a wavelet can lead to overly pessimistic
%          results.
% *********** default = 0.2 ************
% mu ... tradeoff parameter between wavelet smoothness and data fitting.
%       Lower means less smooth with 0 being no smoothness constraint. 
%       Smoothness is imposed via a constraint in the match filter
%       inversion (see matchs). A value between 0 and 10 is recommended
% *********** default mu=0.01 ************
% pctnotcausal ... percentage of the estimated wavelet that is not causal. This means the
%           percenatge of the wavelets samples that occur before time t=0.
%   Examples
%           pctnotcausal=0 ... a fully causal operator is desired. t=0 is the first sample.
%           pctnotcausal=10 ... 10% of the samples will occur before t=0
%           pctnotcausal=50 ... 50% of the sample will be before t=0. This is the
%                   time-symmetric case.
% NOTE: Fully causal operators, even if the wavelet is known to be causal, are generally not as
%       good as those where pctnotcausal is slightly greater than 0 (say 2 through 10). If yhe
%       causality of the wavelet is unknown, the 50 is the recommended value.
% *********** default pctnotcausal=50 ***********
%
%
% wavelets ... cell array of extracted wavelets, the same length as t0s
% tws      ... cell array of wavelet time coordinates, the same length as t0s
%
% by: G.F. Margrave, CREWES, 2016
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

if(nargin<8)
   pctnotcausal=50;
end
if(nargin<7)
    mu=.01;
end
if(nargin<6)
    wlen=0.2;
end

nt=length(t);
if(length(s)~=nt)
    error('length of s and t not equal');
end
if(length(r)~=nt)
    error('length of r and t not equal');
end
if(length(twins)==1)
    twins=twins*ones(size(t0s));
end
if(length(t0s)~=length(twins))
    error('length of t0s and twins not equal')
end

if(pctnotcausal<0 || pctnotcausal>100)
    error('bad value for pctnotcausal');
end

%ensure column vectors
rn=r(:)/max(r);%normalize
sn=s(:)/max(s);%normalize
t=t(:);
dt=t(2)-t(1);

nwaves=length(t0s);
wavelets=cell(1,nwaves);
tws=wavelets;
for k=1:nwaves
    t1=t0s(k)-.5*twins(k);
    t2=t0s(k)+.5*twins(k);
    ind=near(t,t1,t2);
%     sg=s(ind).*mwindow(length(ind));
%     rg=r(ind).*mwindow(length(ind));
    sg=sn(ind).*mwindow(length(ind));
    rg=rn(ind).*mwindow(length(ind));
    mlen=wlen*twins(k);
    icausal=round(pctnotcausal*mlen/(100*dt))+1;
    [w,tws{k}]=matchs(rg,sg,t(ind),mlen,icausal,mu);
    if(icausal>=1)
        %sg1=convm(r(ind),w);
        izero=near(tws{k},0);
        sg1=convz(r(ind),w,izero);
    else
        sg1=convz(r(ind),w);
    end
    [~,a]=lsqsubtract(s(ind),sg1);
    wavelets{k}=a*w;
end

function [wavelets,tws,static,phs]=extract_wavelets_simple(s,t,r,t0s,twins,fsmo,wlen,fmin,fmax)
% EXTRACT_WAVELETS_SIMPLE: extract time variant embedded wavelets using a simple method
%
% [wavelets,tws,static,phs]=extract_wavelets_simple(s,t,r,t0s,twins,fsmo,wlen,fmin,fmax)
%
% Given a seismic trace and a corresponding reflectivity, this function estimates the
% time-varying embedded wavelets at user-defined times and windows. The windowed trace is
% compared to the windowed reflectivity to estimate each wavelet. Wavelets are estimated by a
% simple algorithm: the wavelet amplitude spectrum will be the smoothed seismic amplitude
% spectrum (with a butterworth bandpass filter (fmin-fmax) applied), the overall wavelet delay (+ or
% -) is estimated by crosscorrelation of envelopes, and the wavelet phase is assumed contant and
% estimated by comparing the time-shifted seismic with the reflectivity. Finally, the overall
% wavelet amplitude is estimated using least squares subtraction of real and synthetic traces. These
% operations are repeated for each window.
%
% s ... input seismic trace
% t ... time coordinate for s
% r ... reflectivity (time domain)
% NOTE: s,t, and r must all be exactly the same size.
% t0s ... vector of wavelet extraction times. These are the center times of
%       the Gaussian windows.
% twins ... vector of estimation window full-widths. Window is an mwindow
% NOTE: t0s and twins must be vectors of the same length
% fsmo ... size of frequency domain smoother (Hz) used to smooth the seismic amplitude
%       spectrum.
% ********** default 10 Hz ***********
% wlen ... length of the final wavelet specified as a fraction of the window size
% ********** default 0.4 ***********
% fmin ... lowest anticipated signal frequency
% ********** default = 5 Hz ********
% fmax ... highest anticipated signal frequency
% ********** default = .5*fnyq (half of Nyquist) **********
%
%
% wavelets ... cell array of extracted wavelets, the same length as t0s
% tws      ... cell array of wavelet time coordinates, the same length as t0s
% static ... derived time shift that was applied to the original zero phase wavelet
% phs ... derived phase rotation that was applied to the original shifted wavelet
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
dt=t(2)-t(1);
if(nargin<6)
    fsmo=10;
end
if(nargin<7)
    wlen=.4;
end
if(nargin<8)
    fmin=5;
end

if(nargin<9)
    fmax=.25/dt;
end

% sigma=.25;%this means the Gaussian windows will have a std=windowsize/4 

%ensure column vectors
r=r(:);
s=s(:);
t=t(:);

nwaves=length(t0s);
wavelets=cell(1,nwaves);
tws=wavelets;
for k=1:nwaves
    %build gaussian
%     sig=twins(k)*sigma;
%     g=exp(-(t-t0s(k)).^2/sig^2);
%     sg=s.*g;
%     rg=r.*g;
%     tg=t;
    ind=near(t,t0s(k)-.5*twins(k),t0s(k)+.5*twins(k));
    sg=s(ind).*mwindow(length(ind));% windowed trace
    rg=r(ind).*mwindow(length(ind));% windowed reflectivity
    tg=t(ind);
    wlen2=wlen*twins(k);%wavelet size in seconds
    [w,tw]=waveseis(sg,tg,fsmo,wlen2/6);%wavelet in seismic with zero phase
    w=butterband(w,tw,fmin,fmax,4,0);%apply butterworth bandpass
    % estimate delay
    nlags=round(.25*twins(k)/dt);%will look +/- this many lags
    sg2=convz(rg,w);%reflectivity with zero phase wavelet
    a=norm(sg)/norm(sg2);
    cc=maxcorr(env(sg2),env(sg),nlags);%get shift from envelopes
    static=-cc(2)*dt;%shift to apply to wavelet
    w2=a*stat(w,tw,static);%static shifted wavelet but still zero phase
    sg2=convz(rg,w2);%recompute sg2
%     sg2=stat(sg,t,static);
    %
%     w2=w;
    phs=constphase3(sg2,sg);%get phase rotation
    wp=phsrot(w2,phs);%apply phase to shifted wavelet, this is almost the final wavelet
    s1=convz(rg,wp);%model trace
    %mysterious additional lag. This is probably present because the wavelet estimate is imperfect
    cc2=maxcorr(sg,s1);%not using envelopes here. Should I?
    wp=stat(wp,tw,cc2(2)*dt);
    s1=convz(rg,wp);
    [~,a]=lsqsubtract(sg,s1);%adjust amplitude by least squares
    if(a<0)
       phs=atan2d(sind(180+phs),cosd(180+phs));
    end
    wp=a*wp;
    wavelets{k}=wp;
    tws{k}=tw;
end
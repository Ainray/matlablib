function [seis,tvs_op]=gabordecon_pro(seis,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,t1,fmin,fmax,fmaxlim,fphase,max_atten)
% GABORDECON_PRO: profile mode gabor decon
%
% [seis,tvs_op]=gabordecon_pro(seis,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,t1,fmin,fmax,fmaxlim,fphase,max_atten)
%
% This is a modified version of Gabor deconvolution as found in
% gabordecon.m . The difference is that gabordecon operates on a single
% trace while gabordecon_pro operates on a profile or gather of traces.
% This is intended to be useful poststack when trace-to-trace variaon of
% the deconvolution operator is not desired. Instead, in gabordecon_pro all
% traces are processed with the same average operator. The average operator
% is designed by computing the average Gabor amplitude spectrum of the
% entire input profile and then processing this average spectrum into a
% zero phase or minimum phase gabor decon operator. (This is done exactly
% the same way as gabordecon does it.) Then, this operator is applied to
% each trace in the profile. Because it is impractical to store the Gabor
% spectra of all traces in RAM, this process requires making two passes
% through the data computing the Gabor spectrum of each trace twice. Thus
% it will take roughly twice as long as running gabordecon on each trace
% with a for loop.
%
% seis ... input trace gather, this may have any number of traces
% t ... time coordinate for trin
% twin ... half width of gaussian temporal window (sec)
% tinc ... temporal increment between windows (sec)
% tsmo ... size of temporal smoother (sec)
% fsmo ... size of frequency smoother (Hz)
% ihyp ... 1 for hyperbolic smoothing, 0 for ordinary boxcar smoothing
%    Hyperbolic smoothing averages the gabor magnitude spectrum along
%    curves of t*f=constant. Use nan to get the default if later parameters are prescribed.
% ************** Default = 1 ***********
% stab ... stability constant. Use nan to get the default if later parameters are prescribed.
%   ************* Default = 0 **************
% phase ... 0 for zero phase, 1 for minimum phase. Use nan to get the default if later parameters are prescribed.
%   ************* Default = 0 **************
% p ... exponent that determines the analysis and synthesis windows. If g
%   is a modified Gaussian forming a partition, then the analysis window is
%   g.^p and the synthesis window is g.^(1-p). p mus lie in the interval
%   [0,1]. p=1 means the synthesis window is unity and p=0 means the
%   analysis window is unity. Use nan to get the default if later parameters are prescribed.
% ***************** default p=1 ********************************
% ********* values other than 1 not currently recommended ******
% gdb ... number of decibels below 1 at which to truncate the Gaussian
%   windows. Used by fgabor. This should be a positive number. Making this
%   larger increases the size of the Gabor transform but gives marginally
%   better performance. Avoid values smaller than 20. Note that many gdb
%   values will result in identical windows because the truncated windows
%   are always expanded to be a power of 2 in length. Use nan to get the default if later parameters are prescribed.
% ************** default = 60 ***************
% The following parameters prescribe a hyperbolic bandpass filter that is applied simultaneously
% with the Gabor decon operator. This is effectively a post decon bandpass filter designed to limit
% the frequency band that is whitened to the signal band. Without this, Gabor decon will blow up too
% much noise. It is a good idea to reject both extremely low frequencies and extermely high ones.
% This is a time variant filter and is called hyperbolic because the upper limit of the passband
% (fmax) follows a hyperbolic path in the time-frequency plane. This path is defined by t*f=constant
% so specifying the value of t*f at one point defines the path. This is done by specifying a
% reference time (t1) and the value of the maximum frequency at that time (fmax). Then, the value of
% the maximum frequency at any other time (t2) is given by fmax2= fmax*t1/t2. From this it follows
% that when t2<t1, fmax2>fmax and when t2>t1 fmax2<fmax. Note that fmin does not vary with time.
% It is recommended that you use seisplotgabdecon to interactively determine appropriate values for
% this filter.
% t1 ... time at which filter specs apply
% fmin ... a two element vector specifying:
%         fmin(1) : 3db down point of filter on low end (Hz)
%         fmin(2) : gaussian width on low end
%    note: if only one element is given, then fmin(2) defaults
%          to 5 Hz. Set to [0 0] for a low pass filter 
% fmax ... a two element vector specifying:
%         fmax(1) : 3db down point of filter on high end (Hz)
%         fmax(2) : gaussian width on high end
%    note: if only one element is given, then fmax(2) defaults
%          to 20% of (fnyquist-fmax(1)). Set to [0 0] for a high pass filter
% fmaxlim ... Two element vector. After adjusting fmax for t~=t1, it will not be allowed to
%           exceed fmaxlim(1) or fall below fmaxlim(2).
% fphase ... pahse of the hyperbolic bandpass filter, 0 for zero phase, 1 for minimum phase
%  ********* default = 0 **********
% max_atten ... maximum attenuation of the hyperbolic bandpass filter in decibels
%   ******* default= 80db *********
%
% seis ... deconvolved result, the same size as the input gather
% tvs_op ... complex-valued gabor spectrum of the operator. That is,
%   GaborSpectrum(trout) = GaborSpectrum(trin).*tvs_op
%
% by G.F. Margrave 2018
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

%hidden parameters
% transforms ... must be one of [1,2,3] with the meaning
%               1 : use old transforms without normalization
%               2 : use old transforms with normalization
%               3 : use new transforms without normalization
%               4 : use new transforms with normalization
% ************* default = 3 ************
% taperpct = size of taper applied to the end of the trace (max time)
%                 expressed as a percent of twin
% ************** default = 200% *********************
% taperpct has a mysteriously beneficial effect. Setting it to zero
% degrades the result in the latter half of the trace

transforms=3;
taperpct=50;

if(nargin<7); ihyp=nan; end
if(nargin<8); stab=nan; end
if(nargin<9); phase=nan; end
if(nargin<10); p=nan; end
if(nargin<11); gdb=nan; end

if(isnan(ihyp)); ihyp=1; end
if(isnan(stab)); stab=0; end
if(isnan(phase)); phase=0; end
if(isnan(p)); p=1; end
if(isnan(gdb)); gdb=60; end

if(nargin<16)
    fphase=0;
end
if(nargin<17)
    max_atten=80;
end

normflag=0;
if(transforms==2 || transforms == 4)
    normflag=1;%means we will normalize the Gaussians 
end

[nsamps,ntraces]=size(seis);

if(length(t)~=nsamps)
    error('invalid t coordinate vector');
end

if(length(fmin)==1)
    fmin=fmin*[1,.5];
end
dt=t(2)-t(1);
fnyq=.5/dt;
if(length(fmax)==1)
    fmax=[fmax .2*(fnyq-fmax)];
end


%scale taperpct to the trace length
taperpct=taperpct*twin/max(t);

%
%first pass: loop over all traces and compute the tvs of each, then average
%tvs of the profile is formed by cumulative stacking of the tvs's
%Then, smooth and process the average tvs
%
%second pass: loop over all traces again. Compute the tvs of each and
%divide by the average tvs computed in the first pass.
%

%pass 1
for k=1:ntraces
    
    s=seis(:,k);
    %taper trace
    if(taperpct>0)
        s=s.*mwhalf(length(s),taperpct);
    end
    
    
    
    %compute the tvs
    if(transforms==1 || transforms==2)
        padflag=1;
        [tvs,trow,fcol]=fgabor_old(s,t,twin,tinc,padflag,normflag,0);
    else
        [tvs,trow,fcol]=fgabor(s,t,twin,tinc,p,gdb,normflag);
    end
    
    if(k==1)
        tvs_ave=abs(tvs);
    else
        tvs_ave=(tvs_ave*(k-1)+abs(tvs))/k;
    end
    if(rem(k,50)==0)
        disp(['gabordecon_pro pass1: computed ' int2str(k) ' of ' int2str(ntraces) ...
            ' input Gabor spectra'])
    end
end

disp('gabordecon_pro pass1: finished computing average time-variant spectrum')

%now process this to create the operator
    
%stabilize
%find the minimum maximum
tmp=max(abs(tvs_ave),[],2);%Find the maxima of each spectrum
amax=abs(max(tmp));%adjusted to maximum maximum

dt=trow(2)-trow(1);
df=fcol(2)-fcol(1);
nt=round(tsmo/dt)+1;
nf=round(fsmo/df)+1;

if(~ihyp)
    % smooth with a boxcar
    tvs_op=conv2(tvs_ave+stab*amax,ones(nt,nf),'same')/(nt*nf);
    maskhyp=ones(size(tvs_op));
else
    %hyperbolic smoothing
    if(normflag==1)
        %[tvsh,smooth,smodev,tflevels]=hypersmooth(tvs_ave+stab*amax,trow,fcol,100);
        tvsh=hypersmooth(tvs_ave+stab*amax,trow,fcol,100);
    else
        tvsh=hypersmooth(tvs_ave,trow,fcol,100);
    end
    %hyperbolic filter
    %this is a filter designed to suppress the output at large t*f values.
    %These are values with high attenuation and usually show artefacts if not
    %suppressed. The idea is to define the supppression contour based on the
    %value of stab*amax which is the white noise level. The white noise level
    %is compared to tvsh to determine this.
    ind=near(tvsh(:,end),.5*stab*amax);
    maskhyp=hypfiltmask(trow,fcol,fcol(end)*trow(ind(1)),.1*fcol(end)*trow(ind(1)));
    
    %estimate wavelet

    w=conv2(tvs_ave./tvsh,ones(nt,nf),'same')/(nt*nf);

    tvs_op=w.*tvsh;

end

%phase if required and invert
if phase==1
    L1=1:length(fcol);L2=length(fcol)-1:-1:2;
    symspec=[tvs_op(:,L1) tvs_op(:,L2)];%create neg freqs for Hilbert transform
    symspec2=hilbert(log(symspec')).';%transposing to force hilbert to work along frequency
    tvs_op=exp(-conj(symspec2(:,L1)));%toss negative freqs
else
    tvs_op=1 ./tvs_op;
end
disp('gabordecon_pro pass1: finished computing decon operator')

filtmask=makegaborfilter(t,twin,tinc,gdb,t1,fmin,fmax,fmaxlim,fphase,max_atten);

%second pass, loop over all traces and again compute their tvs and
%deconvolve them
for k=1:ntraces
    
    s=seis(:,k);
    %taper trace
    if(taperpct>0)
        s=s.*mwhalf(length(s),taperpct);
    end
    
    %compute the tvs
    if(transforms==1 || transforms==2)
        padflag=1;
        [tvs,trow,fcol]=fgabor_old(s,t,twin,tinc,padflag,normflag,0);
    else
        [tvs,trow,fcol]=fgabor(s,t,twin,tinc,p,gdb,normflag);
    end
    
    %deconvolve
    tvs=tvs.*tvs_op;

    %hyperbolic filter
    %this is a filter designed to suppress the output at large t*f values.
    %These are values with high attenuation and usually show artefacts if not
    %suppressed. The idea is to define the supppression contour based on the
    %value of stab*amax which is the white noise level. The white noise level
    %is compared to tvsh to determine this.
    tvs=tvs.*maskhyp.*filtmask;

    % tvs=ones(size(tvs)).*tvs_op;

    %inverse transform
    if(transforms==1 || transforms==2 )
        sg=igabor_old(tvs,fcol);
    else
        sg=igabor(tvs,trow,fcol,twin,tinc,p,gdb,normflag);
    end
    sg=sg(1:nsamps);
%     i80=round(.2*nsamps):round(.8*nsamps);
%     sg=balans(sg,s,i80);%balance rms power to that of input
    
    seis(:,k)=sg;
    if(rem(k,50)==0)
        disp(['gabordecon_pro pass2: finished ' int2str(k) ...
            ' traces of ' int2str(ntraces) ' total'])
    end
end

function mask=hypfiltmask(trow,fcol,tfcut,tfwid)
trow=trow(:);
mask=ones(length(trow),length(fcol));
for k=1:length(fcol)
    tf=trow*fcol(k);
    ind=find(tf>tfcut);
    if(~isempty(ind))
        mask(ind,k)=mask(ind,k).*exp(-((tf(ind)-tfcut)/tfwid).^2);
    end
end
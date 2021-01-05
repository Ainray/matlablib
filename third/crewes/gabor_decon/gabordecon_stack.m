function stackg=gabordecon_stack(stack,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,ipow,iwait,ievery)
% GABORDECON_STACK: applies gabor decon to a stacked section
%
% stackg=gabordecon_stack(stack,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,ipow,iwait,ievery)
%
% GABORDECON_STACK applies gabordecon to all traces in a stack or other trace gather. 
%
% stack ... stacked section as a matrix of traces. 
% t ... time coordinate for stack
% twin ... half width of gaussian temporal window (sec)
% tinc ... temporal increment between windows (sec)
% tsmo ... size of temporal smoother (sec)
% fsmo ... size of frequency smoother (Hz)
% ihyp ... 1 for hyperbolic smoothing, 0 for ordinary boxcar smoothing
%    Hyperbolic smoothing averages the gabor magnitude spectrum along
%    curves of t*f=constant.
% ************** Default = 1 ***********
% stab ... stability constant
%   ************* Default = 0.000001 **************
% phase ... 0 for zero phase, 1 for minimum phase
%   ************* Default = 1 **************
% ipow ... 1 means the output trace will be balanced in power to the input, 0 means not balancing.
%   **************** default =1 ************
% iwait ... 1 means put up a GUI waitbar showing progress. 0 means print progress messages to
%       command window, -1 means no messages
%   ************* default = 0 *************
% ievery ... print a progress message (or update the waitbar) every this many traces
%   ************* default = 100 *************
% 
% 
% stackg ... deconvolved stack
%
% G.F. Margrave, Margrave-Geo, 2019
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

global WaitBarContinue

%check for 3D
sz=size(stack);
threeD=0;
if(length(sz)==3)
    threeD=1;
end

if(nargin<12)
    ievery=50;
end
if(nargin<11)
    iwait=0;
end
if(nargin<10)
    ipow=1;
end
if(nargin<9)
    phase=0;
end
if(nargin<8)
    stab=0.000001;
end
if(nargin<7)
    ihyp=1;
end

gdb=60;
p=1;

if(threeD)
    disp('Gabordecon on a 3D stack')
    
    nxlines=sz(2);
    nilines=sz(3);
    nt=sz(1);
    
    if(length(t)~=nt)
        error('invalid t coordinate vector')
    end
    
    if(isa(stack,'single'))
        stackg=single(zeros(nt,nxlines,nilines));
    else
        stackg=zeros(nt,nxlines,nilines);
    end
    
    small=100*eps;
    
    t0=clock;
    ievery=1;
    amax=0;
    for kx=1:nxlines
        for ki=1:nilines
            if(isa(stack,'single'))
                tmp=double(stack(:,kx,ki));
                if(sum(abs(tmp))>small)%avoid deconvolving a zero trace
                    tmp2=single(gabordecon(tmp,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,ipow));
                    stackg(:,kx,ki)=tmp2;
                    am=max(abs(tmp2));
                    if(am>amax)
                        amax=am;
                    end
                end                
            else
                tmp=stack(:,kx,ki);
                if(sum(abs(tmp))>small)%avoid deconvolving a zero trace
                    tmp2=gabordecon(tmp,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,ipow);
                    stackg(:,kx,ki)=tmp2;
                    am=max(abs(tmp2));
                    if(am>amax)
                        amax=am;
                    end
                end
            end
        end
        if(rem(kx,ievery)==0)
            tnow=clock;
            time_used=etime(tnow,t0);
            time_per_xline=time_used/kx;
            time_remaining=(nxlines-kx)*time_per_xline;
            disp(['finished xline ' int2str(kx) ' of ' int2str(nxlines)])
            disp(['time used ' int2str(time_used/60) ' min, which is ' num2str(time_used/3600) ' hrs']);
            disp(['estimated time remaining ' int2str(time_remaining/60) ' min, which is ' num2str(time_remaining/3600) ' hrs'])
            disp([])
        end
    end
    stackg=stackg/amax;
else
    disp('Gabordecon on a 2D stack')
    
    ntr=size(stack,2);
    
    if(length(t)~=size(stack,1))
        error('invalid t coordinate vector')
    end
    
    stackg=zeros(size(stack));
    
    small=100*eps;
    
    t0=clock;
    amax=0;
    hbar=[];
    if(iwait==1)
        hbar=WaitBar(0,ntr,'Please wait for Gabor decon to complete','Gabor Decon (post stack)');
        ievery=10;
    end
    cancelled=false;
    for k=1:ntr
        tmp=stack(:,k);
        if(sum(abs(tmp))>small)%avoid deconvolving a zero trace
            stackg(:,k)=gabordecon(stack(:,k),t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,ipow);
            am=max(abs(stackg(:,k)));
            if(am>amax)
                amax=am;
            end
        end
        if(rem(k,ievery)==0)
                tnow=clock;
                time_used=etime(tnow,t0);
                time_per_trace=time_used/k;
                time_remaining=(ntr-k)*time_per_trace;
                if(iwait==1)
                    if(WaitBarContinue)
                        WaitBar(k,hbar,['Estimated time remaining ' num2str(time_remaining,4) ' seconds']);
                    else
                        delete(hbar)
                        cancelled=true;
                        break 
                    end
                else
                    disp(['finished trace ' int2str(k) ' of ' int2str(ntr)])
                    disp(['estimated time remaining ' int2str(time_remaining) ' sec'])
                end       
        end
    end
    
    if(~cancelled)
        stackg=stackg/amax;
        if(isgraphics(hbar))
            delete(hbar);
        end
    else
       stackg=0; 
       disp('Gabor decon cancelled')
    end
    
end

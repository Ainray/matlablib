function datar=seisplotgabdecon(seis1,t1,x1,dname1)
% seisplotgabdecon: Interactive deconvolution of a seismic stack or gather
%
% datar=seisplotgabdecon(seis,t,x,dname)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The input seismic
% gather is platted as an image in the left-hand-side and a gabor deconvolved and TV (time-variant)
% bandpass filtered gather is plotted as an image in the right-hand-side. Initial display uses
% default parameters which will probably please no one. Controls are provided to adjust the
% deconvolution and filter and re-apply. The data should be regularly sampled in both t and x.
%
% seis ... seismic matrix
% t ... time coordinate vector for seis
% x ... space coordinate vector for seis
%   *********** default = 1:number_of_traces ************
% dname ... text string nameing the seismic matrix.
%   *********** default = 'Input data' **************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the input seismic axes
%           data{2} ... handle of the filter seismic axes
% These return data are provided to simplify plotting additional lines and
% text in either axes.
% 
% G.F. Margrave, Margrave-Geo, 2018-2020
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

%these globals control the dragline feature. See dragline.m
global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED %#ok<NUSED>
%these globals are used to enable multiple instances of seisplotgabdecon to share parameters
global GABOR_TWIN GABOR_TINC GABOR_TSMO GABOR_FSMO GABOR_IHYP GABOR_STAB GABOR_GPHASE GABOR_FMAX GABOR_FMIN GABOR_T1 GABOR_PHASE GABOR_DFMIN GABOR_DFMAX
global GABOR_FMAXMAX GABOR_FMAXMIN GABOR_TVFILT GABOR_TVFMAX GABOR_TVFMIN GABOR_TVDFMIN GABOR_TVDFMAX GABOR_IPOW
%NEWFIGVIS is used by SANE (Now ENHANCE) tocontrol when the seisplotgabdecon window becomes visible.
global NEWFIGVIS THISGABORFIG GABOR2


if(~ischar(seis1))
    action='init';
else
    action=seis1;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    %THISGABORFIG is a glabal that is used to capture the Figure number of the controlling window
    %durring a gabor decon. Without this, if the computation takes awhile, the user may browse away
    %and the current figure will no longer be the one that needs to be updated. This solves that
    %issue.
    THISGABORFIG=[];
    
    if(isempty(GABOR2))%flag to give option for Nassir's method
        GABOR2=0;
    end
    
    if(nargin<2)
        error('at least 3 inputs are required');
    end
    if(nargin<3)
        x1=1:size(seis1,2);
    end
    if(nargin<4)
        dname1='Input data';
    end
    
    %check for reversed x
    if(x1(1)>x1(end))
        x1=fliplr(x1);
        seis1=fliplr(seis1);
    end
    
    x2=x1;
    t2=t1;
    dt=t1(2)-t1(1);
    fnyq=.5/dt;
    if(isempty(GABOR_FMAX))
        fmax=round(.4*fnyq);
    else
        fmax=GABOR_FMAX;
    end
    if(isempty(GABOR_DFMAX))
        dfmax=nan;
    else
        dfmax=GABOR_DFMAX;
    end
    if(isempty(GABOR_TVFMAX))
        tvfmax=round(.4*fnyq);
    else
        tvfmax=GABOR_TVFMAX;
    end
    if(isempty(GABOR_TVDFMAX))
        tvdfmax=nan;
    else
        tvdfmax=GABOR_TVDFMAX;
    end
    if(isempty(GABOR_FMIN))
        fmin=5;
    else
        fmin=GABOR_FMIN;
    end
    if(isempty(GABOR_DFMIN))
        dfmin=nan;
    else
        dfmin=GABOR_DFMIN;
    end
    if(isempty(GABOR_TVFMIN))
        tvfmin=5;
    else
        tvfmin=GABOR_TVFMIN;
    end
    if(isempty(GABOR_TVDFMIN))
        tvdfmin=nan;
    else
       tvdfmin=GABOR_TVDFMIN;
    end
    if(isempty(GABOR_TWIN))
        twin=.2;
    else
        twin=GABOR_TWIN;
    end
    if(isempty(GABOR_TINC))
        tinc=twin/2;
    else
        tinc=GABOR_TINC;
    end
    if(isempty(GABOR_TSMO))
        tsmo=max(t1)/4;
    else
        tsmo=GABOR_TSMO;
    end
    if(isempty(GABOR_FSMO))
        fsmo=5;
    else
        fsmo=GABOR_FSMO;
    end
    if(isempty(GABOR_IHYP))
        ihyp=1;
    else
        ihyp=GABOR_IHYP;
    end
    if(isempty(GABOR_STAB))
        stab=.00001;
    else
        stab=GABOR_STAB;
    end
    if(isempty(GABOR_GPHASE))
        gphase=0;
    else
        gphase=GABOR_GPHASE;
    end
    if(isempty(GABOR_T1))
        T1=mean(t1);
    else
        T1=GABOR_T1;
    end
    if(isempty(GABOR_PHASE))
        phase=0;
    else
        phase=GABOR_PHASE;
    end
    if(isempty(GABOR_FMAXMAX))
        fmaxmax=min([1.25*fmax fnyq]);
    else
        fmaxmax=GABOR_FMAXMAX;
    end
    if(isempty(GABOR_FMAXMIN))
        fmaxmin=max([.8*fmax (fmin+20)]);
    else
        fmaxmin=GABOR_FMAXMIN;
    end
    if(isempty(GABOR_TVFILT))
        tvfilt=0;
    else
        tvfilt=GABOR_TVFILT;
    end
    statfilt=1;
    staton='on';
    tvon='off';
    if(tvfilt==1)
        statfilt=0;
        staton='off';
        tvon='on';
    end
    
    seis2=seis1;
    
    if(length(t1)~=size(seis1,1))
        error('time coordinate vector does not match first seismic matrix');
    end
    if(length(x1)~=size(seis1,2))
        error('space coordinate vector does not match first seismic matrix');
    end
    if(length(t2)~=size(seis2,1))
        error('time coordinate vector does not match second seismic matrix');
    end
    if(length(x2)~=size(seis2,2))
        error('space coordinate vector does not match second seismic matrix');
    end
    
    if(iscell(dname1))
        dname1=dname1{1};
    end

    xwid=.35;
    yht=.8;
    xsep=.05;
    xnot=.125;
    ynot=.1;
    
    %test to see if we are from enhance. This enables the fromenhance.m function to work
    ff=figs;%if there are no existing figs then we cannot be from enhance
    notfromenhance=true;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           notfromenhance=false;
           %so the current figure is from enhance and we assume it hase called this one
           enhancetag='fromenhance';
           udat={-999.25,gcf};
           [~,cmapname1,iflip1]=enhancecolormap('sections');
           [~,cmapname2,iflip2]=enhancecolormap('sections');
       end

    end
    if(notfromenhance)
       enhancetag='';
       udat=[]; 
       cmapname1='graygold';
       iflip1=0;
       cmapname2=cmapname1;
       iflip2=0;
    end

    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    
    
    
    set(hfig,'tag',enhancetag,'userdata',udat)
    
    hax1=subplot('position',[xnot ynot xwid yht]);
        
    hi=imagesc(x1,t1,seis1);colormap(goldgray);
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
    uimenu(hcm,'label','f-x phase','callback',@showfxphase);
    uimenu(hcm,'label','f-x amp','callback',@showfxamp);
    uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
    uimenu(hcm,'label','f-k filter','callback',@fkfilter);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm);
%     brighten(.5);
    grid
    ht=enTitle(dname1);
    ht.Interpreter='none';
    maxmeters=7000;
    if(max(t1)<10)
        ylabel('time (s)')
    elseif(max(t1)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    xlabel('line coordinate')
    
%   draw application gate
    lw=.5;
    ts=[t1(1) t1(end)];
    xdel=(x1(end)-x1(1));
    xleftmin=x1(1)+.01*xdel;
    xrightmax=x1(end)-.01*xdel;
    xleft=x1(1)+.4*xdel;
    xright=x1(end)-.4*xdel;
    line([xleft xleft],ts,'color','r','linestyle','--','buttondownfcn','seisplotgabdecon(''dragline'');','tag','xleft','linewidth',lw);
    line([xright xright],ts,'color','r','linestyle','--','buttondownfcn','seisplotgabdecon(''dragline'');','tag','xright','linewidth',lw);
    
    %make a clip control
    wid=.055;ht=.05;sep=.005;
    htclip=2*ht;
    xnow=xnot-2*wid;
    ynow=ynot+yht-htclip;
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip1',...
        'userdata',hax1,'title','Clipping');
    data={[-3 3],hax1};
    callback='';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;
    
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[.01,.97,.5*wid,.5*ht],'callback','seisplotgabdecon(''info'');',...
        'backgroundcolor','y');
    
    %right-click message
    annotation(hfig,'textbox','string','Right-click on either image for analysis tools',...
        'position',[.425,.95,.2,ht],'linestyle','none','fontsize',8,'color','r','fontweight','bold');
    
    
    set(hax1,'tag','seis1');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);
        
    hi=imagesc(x2,t2,seis2);colormap(goldgray);
    set(hi,'uicontextmenu',hcm);
    grid

    ht=.5*ht;
    %colormap control
    ynow=ynow-9*ht;
    pos=[xnow,ynow,1.2*wid,8*ht];
    cb1='';cb2='';
    cbflag=[0,1];
    cbcb='';
    cbaxe=[hax1,hax2];
    enhancecolormaptool(hfig,pos,hax1,hax2,cb1,cb2,cmapname1,cmapname2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    
    %the hide seismic button
    xnow=xnot;
    ynow=.97;
    uicontrol(hfig,'style','pushbutton','string','Hide input','tag','hideshow','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''hideshow'');','userdata','hide');
    %the toggle button
    ynow=ynow-ht;
    uicontrol(hfig,'style','pushbutton','string','Toggle','tag','toggle','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''toggle'');','visible','off');
    
    
%     dname2=dname1;
%     ht=enTitle(dname2);
%     ht.Interpreter='none';
    
    if(max(t2)<10)
        ylabel('time (s)')
    elseif(max(t2)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('(depth (ft)')
    end
%     if(max(x2)<maxmeters)
%         xlabel('distance (m)')
%     else
%         xlabel('distance (ft)')
%     end
    xlabel('line coordinate')
    %make a clip control
    xnow=xnot+2*xwid+xsep;
    ynow=ynot+yht-htclip;
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip2',...
        'userdata',hax2,'title','Clipping');
    data={[-3 3],hax2};
    callback='seisplotgabdecon(''clip2'');';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax2;
    
    %gabor parameters
    fnyq=.5/dt;
    ht=.02;
    wid=wid*.5;
    ynow=ynow-ht-sep;
    xnow=xnow+sep;
    uicontrol(hfig,'style','text','string','Gabor parameters:','units','normalized',...
        'position',[xnow,ynow,2.5*wid,ht],'tooltipstring','These are for Gabor decon');
    ynow=ynow-ht-sep;
    
    if(GABOR2==1)
       uicontrol(hfig,'style','radiobutton','string','Gabor2','tag','gabor2','units','normalized',...
           'position',[xnow,ynow,3*wid,ht],'value',0,'tooltipstring','Click for Nassir''s method');
       ynow=ynow-ht-sep;
    end
    uicontrol(hfig,'style','text','string','Twin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Gaussian window half-width in seconds');
    uicontrol(hfig,'style','edit','string',num2str(twin),'units','normalized','tag','twin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds between 0 and 0.5');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Tinc:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Temporal increment between windows');
    uicontrol(hfig,'style','edit','string',num2str(tinc),'units','normalized','tag','tinc',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds smaller than Twin');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Tsmo:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','time smoother length in seconds');
    uicontrol(hfig,'style','edit','string',num2str(tsmo),'units','normalized','tag','tsmo',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring',['Enter a value in seconds between 0 and ' time2str(t1(end))]);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fsmo:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','frequency smoother length in Hz');
    uicontrol(hfig,'style','edit','string',num2str(fsmo),'units','normalized','tag','fsmo',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Smoother:','units','normalized',...
        'position',[xnow,ynow,1.2*wid,ht],'tooltipstring','Type of spectral smoothing');
    uicontrol(hfig,'style','popupmenu','string',{'Boxcar','Hyperbolic'},'units','normalized','tag','hyp',...
        'position',[xnow+1.2*wid+sep,ynow,1.5*wid,ht],'tooltipstring','Choose one','value',ihyp+1);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Stab:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','stability or white noise constant');
    uicontrol(hfig,'style','edit','string',num2str(stab),'units','normalized','tag','stab',...
        'position',[xnow+wid+sep,ynow,1.5*wid,ht],'tooltipstring','Enter a value between 0 and 1');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Phase:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Phase of decon operation');
    uicontrol(hfig,'style','popupmenu','string',{'zero','minimum'},'units','normalized','tag','gphase',...
        'position',[xnow+wid+sep,ynow,1.5*wid,ht],'tooltipstring','Choose one','value',gphase+1);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','radiobutton','string','Preserve trace power','units','normalized',...
        'tag','tracepower','tooltipstring','Preserve trace-to-trace relative power variations',...
        'value',1,'position',[xnow ynow 3*wid ht]);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Apply GDecon+Filter','units','normalized',...
        'position',[xnow,ynow,3*wid,ht],'callback','seisplotgabdecon(''applydecon'');',...
        'tooltipstring','Apply current Gabor decon and filter specs','tag','deconbutton',...
        'backgroundcolor','y');
    
    %filter parameters
    ynow=ynow-1.5*ht-sep;
    %xnow=xnow+sep;
    wid=.07;
%     fmin=5;
%     fmax=round(.4*fnyq);
    uicontrol(hfig,'style','text','string','Filter parameters:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','These are for a post-decon bandpass');
    ynow=ynow-3*ht;
    widbg=1.25*wid;
    hbg1=uibuttongroup('position',[xnow,ynow,widbg,3*ht],'title','Filter type','tag','choices',...
        'selectionchangedfcn','seisplotgabdecon(''filterchoice'');');
    uicontrol(hbg1,'style','radiobutton','string','Stationary','units','normalized','position',...
        [0 .5 1 .5],'value',statfilt);
    uicontrol(hbg1,'style','radiobutton','string','Time variant','units','normalized','position',...
        [0 0 1 .5],'value',tvfilt);
    %First the stationary filter panel
    widpan=1.25*wid;
    htpan=5*ht;
    ynow=ynow-htpan;
    hpan1=uipanel(hfig,'units','normalized','position',[xnow,ynow,widpan,htpan],'tag','stat','visible',staton);
    ht2=.2*4/5;
    sep2=.01*4/5;
    wid2=.22;
    yn=1-ht2-sep2;
    xn=0;
    uicontrol(hpan1,'style','text','string','Fmin:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the minimum frequency (Hz) to pass, enter zero for a lowpass filter');
    uicontrol(hpan1,'style','edit','string',num2str(fmin),'units','normalized','tag','fmin',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
     uicontrol(hpan1,'style','text','string','dFmn:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the lowend. Leave blank for the default which is .5*Fmin');
    if(isnan(dfmin))
        val1='';
    else
        val1=num2str(dfmin);
    end
    uicontrol(hpan1,'style','edit','string',val1,'units','normalized','tag','dfmin',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fmin');
    yn=yn-ht2-sep2;
    uicontrol(hpan1,'style','text','string','Fmax:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the maximum frequency (Hz) to pass, enter zero for a highpass filter');
    uicontrol(hpan1,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(hpan1,'style','text','string','dFmx:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the high end. Leave blank for the default which is 10 Hz');
     if(isnan(dfmax))
        val2='';
    else
        val2=num2str(dfmax);
    end
    uicontrol(hpan1,'style','edit','string',val2,'units','normalized','tag','dfmax',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fnyq-Fmax');
    %Now the time-variant panel
    hpan2=uipanel(hfig,'units','normalized','position',[xnow,ynow,widpan,htpan],'tag','tv','visible',tvon);
    ht2=.2*4/5;sep2=.01*4/5;
    yn=1-ht2-sep2;
    xn=0;
    uicontrol(hpan2,'style','text','string','T1:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the time at which filter parameters are specified');
    uicontrol(hpan2,'style','edit','string',num2str(T1),'units','normalized','tag','t1',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in seconds between ' ...
        time2str(t1(1)) ' and ' time2str(t1(end))]);
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmin:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the minimum frequency (Hz) to pass, enter zero for a lowpass filter');
    uicontrol(hpan2,'style','edit','string',num2str(tvfmin),'units','normalized','tag','tvfmin',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
     uicontrol(hpan2,'style','text','string','dFmn:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the lowend. Leave blank for the default which is .5*Fmin');
    if(isnan(tvdfmin))
        val1='';
    else
        val1=num2str(tvdfmin);
    end
    uicontrol(hpan2,'style','edit','string',val1,'units','normalized','tag','tvdfmin',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fmin');
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmax:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the maximum frequency (Hz) to pass, enter zero for a highpass filter');
    uicontrol(hpan2,'style','edit','string',num2str(tvfmax),'units','normalized','tag','tvfmax',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(hpan2,'style','text','string','dFmx:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the high end. Leave blank for the default which is 10 Hz');
    if(isnan(tvdfmax))
        val2='';
    else
        val2=num2str(tvdfmax);
    end
    uicontrol(hpan2,'style','edit','string',val2,'units','normalized','tag','tvdfmax',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fnyq-Fmax');
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmaxmax:','units','normalized',...
        'position',[xn,yn,2*wid2,ht2],'tooltipstring','Maximimum allowed value of Fmax');
    uicontrol(hpan2,'style','edit','string',num2str(fmaxmax),'units','normalized','tag','fmaxmax',...
        'position',[xn+2*wid2+sep2,yn,1.5*wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmaxmin:','units','normalized',...
        'position',[xn,yn,2*wid2,ht2],'tooltipstring','Minimum allowed value of Fmax');
    uicontrol(hpan2,'style','edit','string',num2str(fmaxmin),'units','normalized','tag','fmaxmin',...
        'position',[xn+2*wid2+sep2,yn,1.5*wid2,ht2],'tooltipstring','Enter a value in Hz between Fmin and Fmax');
    
    %phase
    ynow=ynow-ht-sep;
    wid=0.03;
    uicontrol(hfig,'style','text','string','Phase:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Phase of post-decon filter');
    uicontrol(hfig,'style','popupmenu','string',{'zero','minimum'},'units','normalized','tag','phase',...
        'position',[xnow+wid+sep,ynow,1.3*wid,ht],'tooltipstring','Usually choose zero','value',phase+1);
    ynow=ynow-ht-sep;
    wid=0.07;
    uicontrol(hfig,'style','pushbutton','string','Apply Filter Only','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''applyfilter'');',...
        'tooltipstring','Apply current filter specs to selected Gabor result','backgroundcolor','y');
    %spectra
    ynudge=1.5;
    ynow=ynow-ynudge*ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Show spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''spectra'');',...
        'tooltipstring','Show spectra in separate window','tag','spectra','userdata',[]);
    
    
    ynow=ynow-ynudge*ht-sep;
     uicontrol(hfig,'style','text','string','Compute performace:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','For decon only');
    ynow=ynow-1.5*ht-sep;
     uicontrol(hfig,'style','text','string','','units','normalized','tag','performance',...
        'position',[xnow,ynow,wid,1.5*ht]);
    
    ynow=ynow-ynudge*ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Publish parameters','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tag','pubparms','callback','seisplotgabdecon(''vals2globals'');');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Receive parameters','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tag','pubparms','callback','seisplotgabdecon(''globals2vals'');');
    
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(hfig,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplotgabdecon(''equalzoom'');',...
        'userdata',[xleftmin xrightmax]);
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplotgabdecon(''equalzoom'');');
    
    %results popup
    xnow=pos(1);
    ynow=pos(2)+pos(4)-ht;
    wid=pos(3)+.5*wid;
    ht=3*ht;
    fs=10;
    fontops={'x2','x1.5','x1.25','x1.11','x0.9','x1','x0.8','x0.67','x0.5'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange,'userdata',hax2);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
    uicontrol(hfig,'style','popupmenu','string','No computation yet (input data shown)','units','normalized','tag','results',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm)
    uicontrol(hfig,'style','popupmenu','string','No computation yet (input data shown)','units','normalized','tag','shortresults',...
        'position',[xnow+.25*wid,ynow,.5*wid,ht],'callback','seisplotgabdecon(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm,'visible','off')
    
    %delete button
    xnow=xnow+wid-.075;
    ynow=.95;
    wid=.075;
    ht=ht/3;
    
    %userdata of the delete button is the number of the current selection
    uicontrol(hfig,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    %shortnames
    uicontrol(hfig,'style','radiobutton','string','Short names','units','normalized',...
        'tag','shortnames','position',[xnow,ynow+ht,wid,ht],'callback','seisplotgabdecon(''shortnames'');',...
        'tooltipstring','Use short names','value',0);
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.4,1); %enlarge the fonts in the figure
    boldlines(hax1,4,2); %make lines and symbols "fatter"
%     whitefig;
    
    set(hax2,'tag','seis2');
    seisplotgabdecon('applydecon');
    figure(hfig)
    set(hfig,'name',['Gabor decon analysis for ' dname1],'closerequestfcn','seisplotgabdecon(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
% elseif(strcmp(action,'clip1'))

elseif(strcmp(action,'clip2'))
    hmasterfig=gcf;
    hclip=findobj(hmasterfig,'tag','clip2');
    clim=cliptool('getlims',hclip);
    hresult=findobj(hmasterfig,'tag','results');
    results=get(hresult,'userdata');
    if(~isempty(results))
        iresult=get(hresult,'value');
        results.clims{iresult}=clim;
        set(hresult,'userdata',results)    
    end  

elseif(strcmp(action,'equalzoom'))
    hbut=gcbo;
    hseis1=findobj(gcf,'tag','seis1');
    hseis2=findobj(gcf,'tag','seis2');
    tag=get(hbut,'tag');
    switch tag
        case '1like2'
            xl=get(hseis2,'xlim');
            yl=get(hseis2,'ylim');
            set(hseis1,'xlim',xl,'ylim',yl);
            
        case '2like1'
            xl=get(hseis1,'xlim');
            yl=get(hseis1,'ylim');
            set(hseis2,'xlim',xl,'ylim',yl);
    end
elseif(strcmp(action,'hideshow'))
    hbut=gcbo;
    option=get(hbut,'userdata');
    hclip1=findobj(gcf,'tag','clip1');
    %     udat1=get(hclip1,'userdata');
    hax1=findobj(gcf,'tag','seis1');
    hclip2=findobj(gcf,'tag','clip2');
    %udat2=get(hclip2,'userdata');
    hax2=findobj(gcf,'tag','seis2');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    htoggle=findobj(gcf,'tag','toggle');
    hresults=findobj(gcf,'tag','results');
    hdelete=findobj(gcf,'tag','delete');
    htools=findobj(gcf,'tag','tools');
    hcpanel=findobj(gcf,'tag','colorpanel');
    
    switch option
        case 'hide'
            enhancecolormaptool('colorbarsoff');drawnow
            pos1=get(hax1,'position');
            pos2=get(hax2,'position');
            x0=pos1(1);
            y0=pos1(2);
            wid=pos2(1)+pos2(3)-pos1(1);
            ht=pos1(4);
            set(hax1,'visible','off','position',[x0,y0,wid,ht]);
            set(hi1,'visible','off');
            set(hclip1,'visible','off');
            set(hax2,'position',[x0,y0,wid,ht]);
            set(htoggle,'userdata',{pos1 pos2})
            set(hbut,'string','Show input','userdata','show')
            set(htoggle,'visible','on');
            set([htools hcpanel],'visible','off');
        case 'show'
            udat=get(htoggle,'userdata');
            pos1=udat{1};
            pos2=udat{2};
            set(hax1,'visible','on','position',pos1);
            set([hi1 hclip1],'visible','on');
            set(hax2,'visible','on','position',pos2);
            set(htoggle','visible','off')
            set(hbut,'string','Hide input','userdata','hide');
            set([hi2 hclip2],'visible','on');
            set([hresults hdelete htools hcpanel],'visible','on');
    end
elseif(strcmp(action,'toggle'))
    hfig=gcf;
    hax1=findobj(hfig,'tag','seis1');
    hclip1=findobj(hfig,'tag','clip1');
    hclip2=findobj(hfig,'tag','clip2');
    hax2=findobj(hfig,'tag','seis2');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    
    option=get(hax1,'visible');

    hresults=findobj(hfig,'tag','results');
    hdelete=findobj(hfig,'tag','delete');
    
    switch option
        case 'off'
            %ok, turning on seismic
            xl=hax2.XLim;
            yl=hax2.YLim;
            hax1.XLim=xl;
            hax1.YLim=yl;
            hfig.CurrentAxes=hax1;
            set([hax1 hi1 hclip1],'visible','on');
            set([hax2 hclip2 hi2],'visible','off');
            set([hresults hdelete],'visible','off');
        case 'on'
            %ok, turning off seismic
            xl=hax1.XLim;
            yl=hax1.YLim;
            hax2.XLim=xl;
            hax2.YLim=yl;
            hfig.CurrentAxes=hax2;
            set([hax1 hi1 hclip1],'visible','off');
            set([hax2 hclip2 hi2],'visible','on');
            set([hresults hdelete],'visible','on');
    end
elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    
    hseis1=findobj(gcf,'tag','seis1');

    h1=findobj(hseis1,'tag','xleft');
    xx=get(h1,'xdata');
    xleft=xx(1);
   
    h2=findobj(hseis1,'tag','xright');
    xx=get(h2,'xdata');
    xright=xx(1);


    h12=findobj(gcf,'tag','1like2');
    xx=get(h12,'userdata');
    xmin=xx(1);
    xmax=xx(2);
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on xleft
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[xmin xright];
        DRAGLINE_PAIRED=h2;
    elseif(hnow==h2)
        %clicked on tbot
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[xleft xmax];
        DRAGLINE_PAIRED=h1;
    end
    
    dragline('click')
elseif(strcmp(action,'applydecon'))
    %plan: apply the decon parameters and update the performace label. Then put the result in
    %userdata of the decon button and call 'apply filter'. Apply filter will produce the label and
    %the saved result. The most-recent decon without a filter remains in the button's user data so
    %that a different filter can be applied. Save results will always have both decon and filter
    hgaborfig=gcf;
    THISGABORFIG=hgaborfig;
    hseis1=findobj(hgaborfig,'tag','seis1');
    hi=findobj(hseis1,'type','image');
    seis=get(hi,'cdata');
    t=get(hi,'ydata');
    x=get(hi,'xdata');
    fnyq=.5/(t(2)-t(1));
    %check for Gabor2
    if(GABOR2==1)
        hgabor2=findobj(hgaborfig,'tag','gabor2');
        TWO=get(hgabor2,'value');
    else
        TWO=0;
    end
  
    %get the window size
    hop=findobj(hgaborfig,'tag','twin');
    val=get(hop,'string');
    twin=str2double(val);
    if(isnan(twin))
        msgbox('Twin is not recognized as a number','Oh oh ...');
        return;
    end
    if(twin<=0 || twin>1)
        msgbox('Twin is unreasonable, enter a value in seconds, 0<Twin<=1');
        return;
    end
    %get the window increment
    hop=findobj(hgaborfig,'tag','tinc');
    val=get(hop,'string');
    tinc=str2double(val);
    if(isnan(tinc))
        msgbox('Tinc is not recognized as a number','Oh oh ...');
        return;
    end
    if(tinc<=0 || tinc>twin)
        msgbox('Tinc is unreasonable, enter a value in seconds, 0<Tinc<=Twin');
        return;
    end
    %get the temporal smoother
    hop=findobj(hgaborfig,'tag','tsmo');
    val=get(hop,'string');
    tsmo=str2double(val);
    if(isnan(tsmo))
        msgbox('Tsmo is not recognized as a number','Oh oh ...');
        return;
    end
    if(tsmo<=0 || tsmo>max(t))
        msgbox('Tsmo is unreasonable, enter a value in seconds, 0<Tsmo<=max time');
        return;
    end
    %get the frequency smoother
    hop=findobj(hgaborfig,'tag','fsmo');
    val=get(hop,'string');
    fsmo=str2double(val);
    if(isnan(fsmo))
        msgbox('Fsmo is not recognized as a number','Oh oh ...');
        return;
    end
    if(fsmo<=0 || fsmo>.5*fnyq)
        msgbox('Fsmo is unreasonable, enter a value in Hz, 0<Fsmo<=.5*Fnyq');
        return;
    end
    %get the stab 
    hop=findobj(hgaborfig,'tag','stab');
    val=get(hop,'string');
    stab=str2double(val);
    if(isnan(stab))
        msgbox('stab is not recognized as a number','Oh oh ...');
        return;
    end
    if(stab<0 || stab>1)
        msgbox('stab is unreasonable, enter a value between 0 and 1');
        return;
    end
    %get the smoother choice
    hop=findobj(hgaborfig,'tag','hyp');
    val=get(hop,'value');
    ihyp=val-1;
    %get the phase choice
    hop=findobj(hgaborfig,'tag','gphase');
    val=get(hop,'value');
    phase=val-1;
    %get the preserve power option
    hpow=findobj(hgaborfig,'tag','tracepower');
    ipow=get(hpow,'value');
    %get the application traces
    hleft=findobj(hgaborfig,'tag','xleft');
    hright=findobj(hgaborfig,'tag','xright');
    xx=get(hleft,'xdata');
    xleft=xx(1);%position of the left red line
    xx=get(hright,'xdata');
    xright=xx(1);%position of the right red line
    h12=findobj(hgaborfig,'tag','1like2');
    xx=get(h12,'userdata');
    xleftmin=xx(1);
    xrightmax=xx(2);
    small=(max(x)-xrightmax)*1.5;
    if(abs(xleft-xleftmin)<small && abs(xright-xrightmax)<small)
        ix=1:length(x);
    else
        ix=near(x,xleft,xright);
    end
    %deconvolve
    t1=clock;
    if(TWO==1)
        seisd=gabordecon_stack2(seis(:,ix),t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,ipow,1);
    else
        seisd=gabordecon_stack(seis(:,ix),t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,ipow,1);
    end
    %seisd=gabordecon_stackPar(seis(:,ix),t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,1);
    if(seisd==0)
       THISGABORFIG=[];
       return; 
    end
    t2=clock;
    timeused=etime(t2,t1);
%     timepertrace=round(1000*etime(t2,t1)/length(ix));
%     hperf=findobj(gcf,'tag','performance');
%     set(hperf,'string',[num2str(timepertrace) ' ms/trace'])
    hdbut=findobj(hgaborfig,'tag','deconbutton');
    set(hdbut,'userdata',{seisd,twin,tinc,tsmo,fsmo,stab,ihyp,phase,ix,timeused});
    seisplotgabdecon('applyfilter');
elseif(strcmp(action,'applyfilter'))
    %determine filter choice
    if(isempty(THISGABORFIG))
        hchoice=findobj(gcf,'tag','choices');
    else
        hchoice=findobj(THISGABORFIG,'tag','choices');
    end
    choice=hchoice.SelectedObject.String;
    switch choice
        case 'Stationary'
            seisplotgabdecon('applyfilterstat');
        case 'Time variant'
            seisplotgabdecon('applyfiltertv');
    end
    hseis1=findobj(gcf,'tag','seis1');
    hi=findobj(hseis1,'type','image');
    hcm=hi.ContextMenu;
    hseis2=findobj(gcf,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    hi.ContextMenu=hcm;
elseif(strcmp(action,'applyfiltertv'))
    if(isempty(THISGABORFIG))
        hgaborfig=gcf;
    else
        hgaborfig=THISGABORFIG;
    end
    %check for Gabor2
    TWO='';
    if(GABOR2==1)
        hgabor2=findobj(hgaborfig,'tag','gabor2');
        gabor2=get(hgabor2,'value');
        if(gabor2==1)
            TWO='2';
        end
    end
    hdbut=findobj(hgaborfig,'tag','deconbutton');
    udat=get(hdbut,'userdata');
    if(isempty(udat))
        msgbox('First run a decon, then apply a filter');
        return;
    end
    seisd=udat{1};
    twin=udat{2};
    tinc=udat{3};
    tsmo=udat{4};
    fsmo=udat{5};
    stab=udat{6};
    ihyp=udat{7};
    gphase=udat{8};
    ix=udat{9};
    timedecon=udat{10};
    hseis2=findobj(hgaborfig,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    t=get(hi,'ydata');
    x=get(hi,'xdata');
    fnyq=.5/(t(2)-t(1));
    hobj=findobj(hgaborfig,'tag','t1');
    val=get(hobj,'string');
    t1=str2double(val);
    if(isnan(t1))
        msgbox('T1 is not recognized as a number','Oh oh ...');
        return;
    end
    if(t1<t(1) || t1>t(end))
        msgbox(['t1 must be between ' time2str(t(1)) ' and ' time2str(t(end))],'Oh oh ...');
        return;
    end
    hobj=findobj(hgaborfig,'tag','tvfmin');
    val=get(hobj,'string');
    fmin=str2double(val);
    if(isnan(fmin))
        msgbox('Fmin is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmin<0 || fmin>fnyq)
        msgbox(['Fmin must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    hobj=findobj(hgaborfig,'tag','tvdfmin');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmin=str2double(val);
        if(isnan(dfmin))
            msgbox('dFmin is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmin<0 || dfmin>fmin)
            msgbox(['dFmin must be greater than 0 and less than ' num2str(fmin)],'Oh oh ...');
            return;
        end
    else
        dfmin=.5*fmin;
    end
    hobj=findobj(hgaborfig,'tag','tvfmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        msgbox('Fmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmax<0 || fmax>fnyq)
        msgbox(['Fmax must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    if(fmax<=fmin && fmax~=0)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    hobj=findobj(hgaborfig,'tag','tvdfmax');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmax=str2double(val);
        if(isnan(dfmax))
            msgbox('dFmax is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmax<0 || dfmax>fnyq-fmax)
            msgbox(['dFmax must be greater than 0 and less than ' num2str(fnyq-fmax)],'Oh oh ...');
            return;
        end
    else
        dfmax=10;
    end
    hobj=findobj(hgaborfig,'tag','fmaxmax');
    val=get(hobj,'string');
    fmaxmax=str2double(val);
    if(isnan(fmaxmax))
        msgbox('Fmaxmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmaxmax<fmax || fmaxmax>fnyq)
        msgbox('Fmaxmax must be greater than Fmax and less than Fnyq','Oh oh ...');
        return;
    end
    hobj=findobj(hgaborfig,'tag','fmaxmin');
    val=get(hobj,'string');
    fmaxmin=str2double(val);
    if(isnan(fmaxmin))
        msgbox('Fmaxmin is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmaxmin<fmin || fmaxmin>fmax)
        msgbox('Fmaxmin must be greater than Fmin and less than Fmax','Oh oh ...');
        return;
    end

    hobj=findobj(hgaborfig,'tag','phase');
    ival=get(hobj,'value');
    phase=ival-1;
    tstart=clock;
    if(length(ix)==length(x))
        seis2=filt_hyp(seisd,t,t1,[fmin dfmin],[fmax,dfmax],[fmaxmax fmaxmin],phase,80,1,2*twin,10,1);
        if(seis2==0)
            THISGABORFIG=[];
            return;
        end
    else
        seisd2=filt_hyp(seisd,t,t1,[fmin dfmin],[fmax,dfmax],[fmaxmax fmaxmin],phase,80,1,2*twin,10,1);
        if(seisd2==0)
            THISGABORFIG=[];
            return;
        end
        hseis1=findobj(hgaborfig,'tag','seis1');
        hi1=findobj(hseis1,'type','image');
        seis2=get(hi1,'cdata');
        seisd2=seisd2*mean(abs(seis2(:)))/mean(abs(seisd2(:)));
        seis2(:,ix)=seisd2;
    end
    tnow=clock;
    timef=etime(tnow,tstart);
    totaltime=timedecon+timef;
    timepertrace=round(1000*totaltime/length(ix));%in ms/trace
    hperf=findobj(hgaborfig,'tag','performance');
    if(timedecon==0)
        tptstr=[num2str(timepertrace) ' ms/trace (filter only)'];
        set(hperf,'string',tptstr)
    else
        tptstr=[num2str(timepertrace) ' ms/trace (decon+filter)'];
        set(hperf,'string',tptstr)
    end
%     DECON_FMIN=fmin;
%     DECON_FMAX=fmax;
    set(hi,'cdata',seis2);
    hgaborfig.CurrentAxes=hseis2;
    dname=['GDecon' TWO ' Twin,Tinc,Tsmo,Fsmo,stab,ihyp,phase=' num2str(twin) ','  num2str(tinc) ',' num2str(tsmo) ',' ...
        num2str(fsmo) ',' num2str(stab) ',' num2str(ihyp) ',' num2str(phase)];
    name=[dname ', & [' num2str(fmin) ',' num2str(dfmin) ']-[' num2str(fmax) ',' num2str(dfmax) '] at time ' time2str(t1) ' filter'];
    %update clipping
    clip=3;
    clim=clip*[-1 1];
    hclip2=findobj(hgaborfig,'tag','clip2');
    set(hclip2,'userdata',hseis2);
    clipdat={clim,hseis2};
    cliptool('refresh',hclip2,clipdat);
    %save the results and update hresults
    hresults=findobj(hgaborfig,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.shortnames={'Gabor decon #1'};
        results.expnumber=1;
        results.data={seis2};
        results.datanf={seisd};%deconvolved no filter
        results.twin={twin};
        results.tinc={tinc};
        results.tsmo={tsmo};
        results.fsmo={fsmo};
        results.ihyp={ihyp};
        results.gphase={gphase};
        results.stab={stab};
        results.filtertype={2};
        results.t1={t1};
        results.fmins={fmin};
        results.dfmins={dfmin};
        results.fmaxs={fmax};
        results.dfmaxs={dfmax};
        results.fmaxmax={fmaxmax};
        results.fmaxmin={fmaxmin};
        results.phases={phase};
        results.clipdats={clipdat};
        results.clims={clim};
        results.ix={ix};
        results.tpt={tptstr};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.expnumber(nresults)=results.expnumber(nresults-1)+1;
        results.shortnames{nresults}=['Gabor Decon #' int2str(results.expnumber(nresults))];
        results.data{nresults}=seis2;
        results.datanf{nresults}=seisd;
        results.twin{nresults}=twin;
        results.tinc{nresults}=tinc;
        results.tsmo{nresults}=tsmo;
        results.fsmo{nresults}=fsmo;
        results.ihyp{nresults}=ihyp;
        results.gphase{nresults}=gphase;
        results.stab{nresults}=stab;
        results.filtertype{nresults}=2;
        results.t1{nresults}=t1;
        results.fmins{nresults}=fmin;
        results.dfmins{nresults}=dfmin;
        results.fmaxs{nresults}=fmax;
        results.dfmaxs{nresults}=dfmax;
        results.fmaxmax{nresults}=fmaxmax;
        results.fmaxmin{nresults}=fmaxmin;
        results.phases{nresults}=phase;
        results.clipdats{nresults}=clipdat;
        results.clims{nresults}=clim;
        results.ix{nresults}=ix;
        results.tpt{nresults}=tptstr;
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hshortresults=findobj(gcf,'tag','shortresults');
    set(hshortresults,'string',results.shortnames,'value',nresults)
    %see if spectra window is open
    hspec=findobj(hgaborfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotgabdecon('spectra');
    end
    THISGABORFIG=[];
elseif(strcmp(action,'applyfilterstat'))
    if(isempty(THISGABORFIG))
        hgaborfig=gcf;
    else
        hgaborfig=THISGABORFIG;
    end
    %check for Gabor2
    TWO='';
    if(GABOR2==1)
        hgabor2=findobj(hgaborfig,'tag','gabor2');
        gabor2=get(hgabor2,'value');
        if(gabor2==1)
            TWO='2';
        end
    end
    hdbut=findobj(hgaborfig,'tag','deconbutton');
    udat=get(hdbut,'userdata');
    if(isempty(udat))
        msgbox('First run a decon, then apply a filter');
        return;
    end
    seisd=udat{1};
    twin=udat{2};
    tinc=udat{3};
    tsmo=udat{4};
    fsmo=udat{5};
    stab=udat{6};
    ihyp=udat{7};
    gphase=udat{8};
    ix=udat{9};
    timedecon=udat{10};
    hseis2=findobj(hgaborfig,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    t=get(hi,'ydata');
    x=get(hi,'xdata');
    fnyq=.5/(t(2)-t(1));
    hobj=findobj(hgaborfig,'tag','fmin');
    val=get(hobj,'string');
    fmin=str2double(val);
    if(isnan(fmin))
        msgbox('Fmin is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmin<0 || fmin>fnyq)
        msgbox(['Fmin must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    hobj=findobj(hgaborfig,'tag','dfmin');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmin=str2double(val);
        if(isnan(dfmin))
            msgbox('dFmin is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmin<0 || dfmin>fmin)
            msgbox(['dFmin must be greater than 0 and less than ' num2str(fmin)],'Oh oh ...');
            return;
        end
    else
        dfmin=.5*fmin;
    end
    hobj=findobj(hgaborfig,'tag','fmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        msgbox('Fmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmax<0 || fmax>fnyq)
        msgbox(['Fmax must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    if(fmax<=fmin && fmax~=0)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    hobj=findobj(hgaborfig,'tag','dfmax');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmax=str2double(val);
        if(isnan(dfmax))
            msgbox('dFmax is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmax<0 || dfmax>fnyq-fmax)
            msgbox(['dFmax must be greater than 0 and less than ' num2str(fnyq-fmax)],'Oh oh ...');
            return;
        end
    else
        dfmax=10;
    end
    hobj=findobj(hgaborfig,'tag','phase');
    ival=get(hobj,'value');
    phase=ival-1;
    t1=clock;
    if(length(ix)==length(x))
        seis2=filter_stack(seisd,t,fmin,fmax,'method','filtf','phase',phase,'dflow',dfmin,'dfhigh',dfmax);
    else
        seisd2=filter_stack(seisd,t,fmin,fmax,'method','filtf','phase',phase,'dflow',dfmin,'dfhigh',dfmax);
        hseis1=findobj(hgaborfig,'tag','seis1');
        hi1=findobj(hseis1,'type','image');
        seis2=get(hi1,'cdata');
        seisd2=seisd2*mean(abs(seis2(:)))/mean(abs(seisd2(:)));
        seis2(:,ix)=seisd2;
    end
    t2=clock;
    timef=etime(t2,t1);
    totaltime=timedecon+timef;
    timepertrace=round(1000*totaltime/length(ix));%in ms/trace
    hperf=findobj(hgaborfig,'tag','performance');
    if(timedecon==0)
        tptstr=[num2str(timepertrace) ' ms/trace (filter only)'];
        set(hperf,'string',tptstr)
    else
        tptstr=[num2str(timepertrace) ' ms/trace (decon+filter)'];
        set(hperf,'string',tptstr)
    end
%     DECON_FMIN=fmin;
%     DECON_FMAX=fmax;
    set(hi,'cdata',seis2);
    hgaborfig.CurrentAxes=hseis2;
    dname=['GDecon' TWO ' Twin,Tinc,Tsmo,Fsmo,stab,ihyp,phase=' num2str(twin) ','  num2str(tinc) ',' num2str(tsmo) ',' ...
        num2str(fsmo) ',' num2str(stab) ',' num2str(ihyp) ',' num2str(phase)];
    name=[dname ', & [' num2str(fmin) ',' num2str(dfmin) ']-[' num2str(fmax) ',' num2str(dfmax) '] filter'];
    %update clipping
    clip=3;
    clim=clip*[-1 1];
    hclip2=findobj(hgaborfig,'tag','clip2');
    set(hclip2,'userdata',hseis2);
    clipdat={clim,hseis2};
    cliptool('refresh',hclip2,clipdat);
    %save the results and update hresults
    hresults=findobj(hgaborfig,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.shortnames={'Gabor decon #1'};
        results.expnumber=1;
        results.data={seis2};
        results.datanf={seisd};
        results.twin={twin};
        results.tinc={tinc};
        results.tsmo={tsmo};
        results.fsmo={fsmo};
        results.ihyp={ihyp};
        results.gphase={gphase};
        results.stab={stab};
        results.filtertype={1};
        results.t1={[]};
        results.fmins={fmin};
        results.dfmins={dfmin};
        results.fmaxs={fmax};
        results.dfmaxs={dfmax};
        results.fmaxmax={[]};
        results.fmaxmin={[]};
        results.phases={phase};
        results.clipdats={clipdat};
        results.clims={clim};
        results.ix={ix};
        results.tpt={tptstr};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.expnumber(nresults)=results.expnumber(nresults-1)+1;
        results.shortnames{nresults}=['Gabor Decon #' int2str(results.expnumber(nresults))];
        results.data{nresults}=seis2;
        results.datanf{nresults}=seisd;
        results.twin{nresults}=twin;
        results.tinc{nresults}=tinc;
        results.tsmo{nresults}=tsmo;
        results.fsmo{nresults}=fsmo;
        results.ihyp{nresults}=ihyp;
        results.gphase{nresults}=gphase;
        results.stab{nresults}=stab;
        results.filtertype{nresults}=1;
        results.t1{nresults}=[];
        results.fmins{nresults}=fmin;
        results.dfmins{nresults}=dfmin;
        results.fmaxs{nresults}=fmax;
        results.dfmaxs{nresults}=dfmax;
        results.fmaxmax{nresults}=[];
        results.fmaxmin{nresults}=[];
        results.phases{nresults}=phase;
        results.clipdats{nresults}=clipdat;
        results.clims{nresults}=clim;
        results.ix{nresults}=ix;
        results.tpt{nresults}=tptstr;
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hshortresults=findobj(gcf,'tag','shortresults');
    set(hshortresults,'string',results.shortnames,'value',nresults)
    %see if spectra window is open
    hspec=findobj(hgaborfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotgabdecon('spectra');
    end  
    THISGABORFIG=[];
elseif(strcmp(action,'spectra'))
    hfig=gcf;
    name=get(hfig,'name');
    ind=strfind(name,'Spectral display');
    if(isempty(ind)) %#ok<STREMP>
        hmaster=hfig;
    else
        hmaster=get(hfig,'userdata');
    end
    hseis1=findobj(hmaster,'tag','seis1');
    hseis2=findobj(hmaster,'tag','seis2');
    hi=findobj(hseis1,'type','image');
    seis1=get(hi,'cdata');
    hi=findobj(hseis2,'type','image');
    seis2=get(hi,'cdata');
    t=get(hi,'ydata');
    x=get(hi,'xdata');
    %determine x range
    hleft=findobj(hmaster,'tag','xleft');
    hright=findobj(hmaster,'tag','xright');
    h12=findobj(hmaster,'tag','1like2');
    xmin=hleft.XData(1);
    xmax=hright.XData(2);
    xminmin=h12.UserData(1);
    xmaxmax=h12.UserData(2);
    small=1000*eps;
    if(abs(xmin-xminmin)<small && abs(xmax-xmaxmax)<small)
        ix=1:length(x);
    else
        ix=near(x,xmin,xmax);
    end
    name1='Input';
    name2='Gabor Decon';
    hspec=findobj(hmaster,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    CRcallback='seisplotgabdecon(''closespec'');';
    Winname=[];
    spectralview(seis1(:,ix),seis2(:,ix),t,name1,name2,hspecwin,CRcallback,Winname)
    hspecwin=gcf;
    set(hspec,'userdata',hspecwin);
    
    
    
%     hspec=findobj(hmaster,'tag','spectra');
%     hspecwin=get(hspec,'userdata');
%     if(isempty(hspecwin))
%         %make the spectral window if it does not already exist
%         pos=get(hmaster,'position');
%         wid=pos(3)*.5;ht=pos(4)*.5;
%         x0=pos(1)+pos(3)-wid;y0=pos(2);
%         hspecwin=figure('position',[x0,y0,wid,ht],'closerequestfcn','seisplotgabdecon(''closespec'');','userdata',hmaster);
%         set(hspecwin,'name','Spectral display window')
%         
%         whitefig;
%         x0=.1;y0=.1;awid=.7;aht=.8;
%         subplot('position',[x0,y0,awid,aht]);
%         sep=.01;
%         ht=.05;wid=.075;
%         ynow=y0+aht-ht;
%         xnow=x0+awid+sep;
%         uicontrol(gcf,'style','text','string','Tmin:','units','normalized',...
%             'position',[xnow,ynow,wid,ht])
%         ntimes=10;
%         tinc=round(10*(t(end)-t(1))/ntimes)/10;
%         %times=[fliplr(0:-tinc:t(1)) tinc:tinc:t(end)-tinc];
%         times=t(1):tinc:t(end)-tinc;
%         %times=t(1):tinc:t(end)-tinc;
%         stimes=num2strcell(times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','popupmenu','string',stimes,'units','normalized','tag','tmin',...
%             'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''spectra'');','userdata',times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','text','string','Tmax:','units','normalized',...
%             'position',[xnow,ynow,wid,ht])
%         times=t(end):-tinc:tinc;
%         stimes=num2strcell(times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','popupmenu','string',stimes,'units','normalized','tag','tmax',...
%             'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''spectra'');','userdata',times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','text','string','db range:','units','normalized',...
%             'position',[xnow,ynow,wid,ht])
%         db=-20:-20:-160;
%         idb=near(db,-100);
%         dbs=num2strcell(db);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','popupmenu','string',dbs,'units','normalized','tag','db','value',idb,...
%             'position',[xnow,ynow,wid,ht],'callback','seisplotgabdecon(''spectra'');','userdata',db);
%         set(hspec,'userdata',hspecwin);
%     else
%         figure(hspecwin);
%     end
%     htmin=findobj(gcf,'tag','tmin');
%     times=get(htmin,'userdata');
%     it=get(htmin,'value');
%     tmin=times(it);
%     htmax=findobj(gcf,'tag','tmax');
%     times=get(htmax,'userdata');
%     it=get(htmax,'value');
%     tmax=times(it);
%     if(tmin>=tmax)
%         return;
%     end
%     %determine x range
%     hleft=findobj(hmaster,'tag','xleft');
%     hright=findobj(hmaster,'tag','xright');
%     h12=findobj(hmaster,'tag','1like2');
%     xmin=hleft.XData(1);
%     xmax=hright.XData(2);
%     xminmin=h12.UserData(1);
%     xmaxmax=h12.UserData(2);
%     small=1000*eps;
%     if(abs(xmin-xminmin)<small && abs(xmax-xmaxmax)<small)
%         ix=1:length(x);
%     else
%         ix=near(x,xmin,xmax);
%     end
%     ind=near(t,tmin,tmax);
%     hdb=findobj(gcf,'tag','db');
%     db=get(hdb,'userdata');
%     dbmin=db(get(hdb,'value'));
%     pct=10;
%     if(length(ind)<10)
%         return;
%     end
%     [S1,f]=fftrl(seis1(ind,ix),t(ind),pct);
%     S2=fftrl(seis2(ind,ix),t(ind),pct);
%     A1=mean(abs(S1),2);
%     A2=mean(abs(S2),2);
%     hh=plot(f,todb(A1),f,todb(A2));
%     set(hh,'linewidth',2)
%     xlabel('Frequency (Hz)')
%     ylabel('decibels');
%     ylim([dbmin 0])
%     grid on
%     legend('Input','Decon+filter'); 
%     enTitle(['Average ampltude spectra, tmin=' time2str(tmin) ', tmax=' time2str(tmax)]);
elseif(strcmp(action,'closespec'))
    hfig=gcf;
    hdaddy=get(hfig,'userdata');
    hspec=findobj(hdaddy,'tag','spectra');
    set(hspec,'userdata',[]);
    delete(hfig);
    if(isgraphics(hdaddy))
        figure(hdaddy);
    end
elseif(strcmp(action,'select'))
    hfig=gcf;
    hdelete=findobj(gcf,'tag','delete');%this has the previous selection
    iprev=get(hdelete,'userdata');
    hresults=findobj(hfig,'tag','results');
    hshortresults=findobj(hfig,'tag','shortresults');
    results=get(hresults,'userdata');
    hshort=findobj(hfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort==1)
        iresult=get(hshortresults,'value');%the new selection
        set(hresults,'value',iresult);
    else
        iresult=get(hresults,'value');%the new selection
        set(hshortresults,'value',iresult);
    end
    hseis2=findobj(hfig,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    set(hi,'cdata',results.data{iresult});
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
    uimenu(hcm,'label','f-x phase','callback',@showfxphase);
    uimenu(hcm,'label','f-x amp','callback',@showfxamp);
    uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
    uimenu(hcm,'label','f-k filter','callback',@fkfilter);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm);
    hop=findobj(hfig,'tag','twin');
    set(hop,'string',num2str(results.twin{iresult}));
    hop=findobj(hfig,'tag','tinc');
    set(hop,'string',num2str(results.tinc{iresult}));
    hop=findobj(hfig,'tag','tsmo');
    set(hop,'string',num2str(results.tsmo{iresult}));
    hop=findobj(hfig,'tag','fsmo');
    set(hop,'string',num2str(results.fsmo{iresult}));
    hstab=findobj(hfig,'tag','stab');
    set(hstab,'string',num2str(results.stab{iresult}));
    hop=findobj(hfig,'tag','hyp');
    set(hop,'value',results.ihyp{iresult}+1);
    hop=findobj(hfig,'tag','gphase');
    set(hop,'value',results.gphase{iresult}+1);
    set(hdelete,'userdata',iresult);
    ftype=results.filtertype{iresult};
    hpanstat=findobj(gcf,'tag','stat');
    hpantv=findobj(gcf,'tag','tv');
    hchoice=findobj(gcf,'tag','choices');
    hk=get(hchoice,'children');
    switch ftype
        case 1 %stationary
            set(hpanstat,'visible','on');
            set(hpantv,'visible','off');
            set(hk(2),'value',1)
            hfmin=findobj(hfig,'tag','fmin');
            set(hfmin,'string',num2str(results.fmins{iresult}));
            hdfmin=findobj(hfig,'tag','dfmin');
            set(hdfmin,'string',num2str(results.dfmins{iresult}));
            hfmax=findobj(hfig,'tag','fmax');
            set(hfmax,'string',num2str(results.fmaxs{iresult}));
            hdfmax=findobj(hfig,'tag','dfmax');
            set(hdfmax,'string',num2str(results.dfmaxs{iresult}));
        case 2 %time variant
            set(hpanstat,'visible','off');
            set(hpantv,'visible','on');
            set(hk(1),'value',1)
            hfmin=findobj(hfig,'tag','tvfmin');
            set(hfmin,'string',num2str(results.fmins{iresult}));
            hdfmin=findobj(hfig,'tag','tvdfmin');
            set(hdfmin,'string',num2str(results.dfmins{iresult}));
            hfmax=findobj(hfig,'tag','tvfmax');
            set(hfmax,'string',num2str(results.fmaxs{iresult}));
            hdfmax=findobj(hfig,'tag','tvdfmax');
            set(hdfmax,'string',num2str(results.dfmaxs{iresult}));
            ht1=findobj(gcf,'tag','t1');
            set(ht1,'string',time2str(results.t1{iresult}));
            hmm=findobj(gcf,'tag','fmaxmax');
            set(hmm,'string',num2str(results.fmaxmax{iresult}));
            hmm=findobj(gcf,'tag','fmaxmin');
            set(hmm,'string',num2str(results.fmaxmin{iresult}));
    end
    
    hphase=findobj(hfig,'tag','phase');
    set(hphase,'value',results.phases{iresult}+1);
    %reset the application boundaries
    hleft=findobj(gcf,'tag','xleft');
    hright=findobj(gcf,'tag','xright');
    ix=results.ix{iresult};
    hax1=findobj(gcf,'tag','seis1');
    hi=findobj(hax1,'type','image');
    x=get(hi,'xdata');
    if(length(ix)==length(x))
        h12=findobj(gcf,'tag','1like2');
        xx=get(h12,'userdata');
        xmin=xx(1);
        xmax=xx(2);
    else
        xmin=min(x(ix));
        xmax=max(x(ix));
    end
    set(hleft,'xdata',[xmin xmin]);
    set(hright,'xdata',[xmax xmax]);
    %reset the perf display
    hperf=findobj(gcf,'tag','performance');
    set(hperf,'string',results.tpt{iresult})
    %load up the decon button. This is needed so that a filter gets applied to the right result
    hdbut=findobj(gcf,'tag','deconbutton');
    udat={results.datanf{iresult},results.twin{iresult},results.tinc{iresult},results.tsmo{iresult},...
        results.fsmo{iresult},results.stab{iresult},results.ihyp{iresult},results.gphase{iresult},results.ix{iresult},0};
    set(hdbut,'userdata',udat);
    %update clipping
    clipdat=results.clipdats{iresult};
    clim=results.clims{iresult};
    clipdat{1}=clim;
    hclip2=findobj(gcf,'tag','clip2');
    cliptool('refresh',hclip2,clipdat);
    %see if spectra window is open
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotgabdecon('spectra');
    end
    set(hresults,'userdata',results);
elseif(strcmp(action,'shortnames'))
    hfig=gcf;
    hshortnames=findobj(hfig,'tag','shortnames');
    hresults=findobj(hfig,'tag','results');
    hshortresults=findobj(hfig,'tag','shortresults');
    ishort=hshortnames.Value;
    if(ishort)
        hshortresults.Visible='on';
        hresults.Visible='off';
    else
        hshortresults.Visible='off';
        hresults.Visible='on';
    end
elseif(strcmp(action,'delete'))
    hfig=gcf;
    hdelete=gcbo;
    hresults=findobj(hfig,'tag','results');
    hshortresults=findobj(hfig,'tag','shortresults');
    results=get(hresults,'userdata');
    if(length(results.names)==1)
        msgbox('You cannot delete the only result!');
        return;
    end
    iresult=get(hresults,'value');
    fn=fieldnames(results);
    for k=1:length(fn)
        results.(fn{k})(iresult)=[];
    end
    iresult=iresult-1;
    if(iresult<1); iresult=1; end
    set(hresults,'string',results.names,'value',iresult,'userdata',results);
    set(hshortresults,'string',results.shortnames,'value',iresult);
    hdelete.UserData=max([hdelete.UserData-1 1]);
    seisplotgabdecon('select');
elseif(strcmp(action,'close'))
    hfig=gcf;
    %this is the close request function for the Figure
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    delete(hspecwin);
    hbrighten=findobj(hfig,'tag','brighten');
    hfigs=get(hbrighten,'userdata');
    for k=1:length(hfigs)
        if(isgraphics(hfigs(k)))
            close(hfigs(k));
        end
    end
    tmp=get(gcf,'userdata');
    if(iscell(tmp))
        hfigs=tmp{1};
    else
        hfigs=tmp;
    end
    for k=1:length(hfigs)
        if(isgraphics(hfigs(k)))
                close(hfigs(k))
        end
    end
    hclip=findobj(hfig,'tag','clip1');
    ud=get(hclip,'userdata');
    if(length(ud)>6)
        if(isgraphics(ud{7}))
            close(ud{7});
        end
    end
    hclip=findobj(hfig,'tag','clip2');
    ud=get(hclip,'userdata');
    if(length(ud)>6)
        if(isgraphics(ud{7}))
            close(ud{7});
        end
    end
    he=findobj(hfig,'tag','enhancebutton');
    if(isgraphics(he))
       enhance('deleteview',hfig); 
    end
    crf=get(hfig,'closerequestfcn');
    ind=strfind(crf,';');
    if(ind(1)==length(crf))
        delete(hfig);
    end
elseif(strcmp(action,'filterchoice'))
    hchoice=findobj(gcf,'tag','choices');
    choice=hchoice.SelectedObject.String;
    hpanstat=findobj(gcf,'tag','stat');
    hpantv=findobj(gcf,'tag','tv');
    switch choice
        case 'Stationary'
            set(hpanstat,'visible','on');
            set(hpantv,'visible','off');
        case 'Time variant'
            set(hpanstat,'visible','off');
            set(hpantv,'visible','on');
    end
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    msg1={'Overview',{['This is nonstationary Gabor decon. Be sure to experiment with the "Gabor decon" ',...
            'analysis tool in PI3D or PI2D before running this task.'],' ',['Gabor deconvolution was ',...
            'developed as a direct extension of stationary frequency domain spiking deconvolution ',...
            'to nonstationarity. In reality, all seismic data is nonstationary because the earth is ',...
            'not a perfect elastic solid. As seismic waves propagate, higher frequencies are progressively ',...
            'attenuated and gradually sink below the background noise level. The result is that the signal ',...
            'bandwidth of all seismic data is nonstationary, meaning that it varies with time. If data were ',...
            'single fold, the highest signal frequency would decrease uniformly with increasing time. ',...
            'However, because stacked data have high fold (multiplicity), the highest signal frequency ',...
            'tends to increase with time until the data reach full fold and thereafter decreases.'],' ',...
            ['Most seismic datasets are deconvolved with stationary deconvolution, which explicitly ',...
            'ignores the essential nonstationarity of seismic data. As an adaptation, stationary methods ',...
            'use a "design window" over which the process is optimized but it rapidly becomes non-optimal ',...
            'outside this window. In contrast, Gabor decon uses the time-variant Gabor transform to produce ',...
            'local spectra in a great many time windows. In each time window a local operator is designed. ',...
            'In this way Gabor decon directly measures and calibrates itself against the "attenuation surface" '...
            'in the data. Here, "attenuation surface" refers to the smoothed measured amplitude of a seismic trace ',...
            'as a function of time and frequency. Essentially, the attenuation surface is the magnitude of ',...
            'the Gabor transform of the trace but smoothed in both time and frequency. '],' ',['Once this ',...
            'attenuation surface has been determined, it is optionally associated with a minimum-phase ',...
            'spectrum. Then the original Gabor transform of the trace (both amplitude and phase, and unsmoothed) ',...
            'is divided by this attenuation surface to complete the deconvolution. '],' ',...
            ['Gabor decon produces data with an extremely whitened and stationary spectrum. Since the ',...
            'signal band is time variant, the result from Gabor will always require a post-Gabor filter and ',...
            'the filter will usually need to be time variant. Therefore, a complete parameterization ',...
            'requires both Gabor decon parameters and post-Gabor filter parameters.'],' ',...
            ['In theory, the attenuation process is minimum phase and therefore the method designed to ',...
            'reverse attenuation should also be minimum phase. However, using minimum-phase Gabor decon ',...
            'on final seismic volumes will produce results that can be difficult to tie with legacy data. ',...
            'For this reason, the process is usually run with zero phase when Bandwidth Enhancement of ',...
            'final volumes is the goal.']}};
        msg2={'Gabor parameters',{['Although important, the Gabor decon parameters have fairly robust ',...
            'default values that will serve for most purposes. The filter parameters are actually more ',...
            'difficult to determine and play a stronger role in creating an acceptable result. To experience ',...
            'this, it is worth spending time with the 2D Gabor decon Analysis Tool in either PI3D or PI2D. ',...
            'There it is easy to demonstrate that an initial Gabor decon with default parameters can lead ',...
            'to many different results depending on the post-Gabor filter. Moreover, you will find that ',...
            'changing the Gabor parameters by a factor of 2 (larger or smaller) has much less effect ',...
            'than the filter.'],' ',['The parameters Twin and Tinc control the Gabor transform. Twin is ',...
            'the half-width of the sliding time window (a Gaussian) and Tinc is the increment between ',...
            'the centers of adjacent windows. Twin should be larger than the expected wavelet size and ',...
            'a good choice for Tinc is 1/2 to 1/4 of Twin. Computation time rises dramatically with ',...
            'smaller Tinc but is more weakly afftected by Twin.'],' ',['Parameters Tsmo, Fsmo, Stab, ',...
            'and Smoother determine how the attenuation surface (and implicitly the propagating wavelet) ',...
            'is estimated from the Gabor magnitude spectrum. These are described in detail in the ',...
            'Geophysics paper "Margrave et al. 2011". Again the defaults are fairly robust. The ',...
            'choice of Hyperbolic for Smoother means that the spectrum is smoothed along hyperbolic ',...
            'contours in the time-frequency plane. This choice is consistent with the physics of the ',...
            'constant-Q model. Hyperbolic smoothing tends to preserve relative event amplitudes better ',...
            'than the alternative Boxcar smoothing. For Hyperbolic smoothing choose Tsmo around 1/3 '...
            'to 1/2 of the trace length while for Boxcar smoothing chose a factor of 5 or so smaller. Fsmo '...
            'is roughly the inverse of the corresponding time-domain decon operator length. Thus 10 Hz ',...
            'is roughly a 100 mil operator while 5 Hz is a 200 mil. As mentioned in the overview, ',...
            'zero phase is usually the preferred choice for data that will be tied with legacy volumes. '],...
            ' ',['"Preserve trace power" means that the output trace will rescaled to have the same total ',...
            'power as the input. This tends to preserve gross trace-to-trace amplitude variations while ',...
            '"No" tends to remove them. ']}};
        msg3={'Filter parameters',{['The stationary filter is a filter whose properties are the same ',...
            'at all times. Here the filter is usually a bandpass ',...
            'The specification of a time-variant filter is done using the "hyperbolic" concept ',...
        'which is that Fmax, the upper frequency of the bandpass, follows a hyperbolic trajectory in ',...
        'time-frequency space given by t*Fmax(t)=constant. The main reason for this is that the theoretical ',...
        'description of constant-Q attenuation shows that the forward Q operator gives constant attenuation ',...
        'along such curves.'],' ',['A second reason is that the specification of Fmax at any one time then ',...
        'determines Fmax at all times via the formula Fmax(t)=Fmax(t1)*t1/t2 where t1 is the specified time ',...
        'and t2 is any other time. This then implies that for t2<t1, we have Fmax(t2)>Fmax(t1) and for t2>t1, ',...
        'then Fmax(t2)<Fmax(t1). Thus Fmax shows progressive decay with increasing time.'],' ',['In this algorithm ',...
        'Fmax is the only parameter that is adjusted with time. This model can be easily pushed too far, ',...
        'and can predict unacceptably high values at early times and unacceptably low values at later ',...
        'times. Therefore parameters Fmaxmax and Fmaxmin are provided to limit the hyperbolic behavior. '],' ',...
        ['The parameter dFmax spcifies the width of the filter roll-off on the high end (roughly this is the ',...
        'half-width of a Gaussian) and similarly for the low end. This filter is specified and applied in the ',...
        'frequency domain using a Gabor transform. As a result it varies Fmax smoothly and essentially ',...
        'continuously and has very high rejection levels outside the passband.']}};
       
    msg4={'Tool layout',{['The axis at left (the input axis) shows the input sesimic and the axis at right ',...
        '(decon axis) shows the result of the application of Gabor decon. To the right of the '...
        'decon axis are controls for the Gabor deconvolution and the post-decon filter. Each unique '...
        'decon/filter application is considered a "result". The tool remembers your results and ' ...
        'any number of results can be computed. The tool automatically remembers the unfiltered ',...
        'and filtered results but you only ever see the later. Clicking the "Apply Filter Only" ',...
        'button generates a new result by applying the current filter specs to the unfiltered decon ',...
        'for the currently selected result. This allows a variety of filters to be tested on any ',...
        'decon result.'],' ',['Above the decon axes is a popup menu used to ' ...
        'select a result for viewing. Each new computation adds another entry to this menu. The ',...
        'menu names are composed from the parameters of the computation. This can lead to very ',...
        'long names that may be difficult to comprehend and don''t fit well in the display. There are ',...
        'two ways to deal with this. First, by right clicking on the name you will see a menu that ',...
        'allows you to scale the font size or type a new title. Second, short names are also ',...
        'generated automatically and can be chosen by clicking the "Short names" button.'],' ',...
        ['Above the left edge of the input is a button labelled "Hide input". Clicking this causes ',...
        'the input axis to disappear and the decon axis expands to cover the entire window. Also ',...
        'the button label is changed to "Show seismic" and a new button appears labelled "Toggle". ',...
        'The "Show seismic" button will restore the previous view showing both axes. The "Toggle" ',...
        'button allows you to rapidly toggle between the two axes which facilitates a better ',...
        'understanding of the results.'],' ',...
        ['The vertical red lines in the input axis denote the application window which is the trace '...
        'range over which Gabor decon ',...
        'will be applied. The initial position of these lines indicates the entire section is '...
        'the application window. Because Gabor decon takes awhile to run, it is often convenient '...
        'to restrict the application window to a zone of interest. When you launch this tool, it immediately ',...
        'begins to apply Gabor decon to the entire section. If a more limited application is desired, ',...
        'just click "cancel". Then adjust the red lines and click "Apply Gabor Decon".'],' ',['Just to the right of each axes '...
        'are clipping controls for the displays. Smaller clip numbers mean greater clipping. Selection of ',...
        '"graphical" clipping causes a small window to appear showing an amplitude histogram with two ',...
        'red vertical lines indicating the extent of the colorbar. These lines can be clicked and dragged ',...
        'and the colorbar, and hence the data display, will change simultaneously. (If you do not see the ',...
        'red lines, this means their current position, as determined by the clip value, is outside ',...
        'the range of the x axis of the histogram. Should this happen, then a right-click in the white space ',...
        'of the window will allow you to set the maximum and minimum amplitudes. Be sure to set the minimum less than ',...
        'the maximum.) Like many other Enhance tools, the red lines can either be dragged separately ',...
        'with the left mouse button or together with the right button.'],' ',...
        ['The Gabor parameters and the filter parameters each have a short description that will appear ',...
        'if you hover the pointer over the parameter name. Note that all "time" values must be ',...
        'specified in seconds, not milliseconds. Both stationary and time-variant bandpass filters ',...
        'are available as the post-decon filter. The time-variant filter is a called a hyperbolic ',...
        'filter because the Fmax value is specified at a single time and then extrapolated along ',...
        'a hyperbolic contour in the time-frequency plane. If you specify Fmax1 at time T1, then ',...
        'at time T2, Fmax2 is found from the relation T1*Fmax1=T2*Fmax2 so that Fmax2=Fmax1*T1/T2. ',...
        'This means that for T2<T1 Fmax2 is greater than Fmax1, while for T2>T1 the situation is reversed. ',...
        'This method is consistent with Q attenuation theory but, if extended too far, can lead to ',...
        'unacceptable values. Therefore parameters Fmaxmax and Fmaxmin are provided to restrict ',...
        'the possible range of Fmax values.'],' ',['After you have run a deconvolution, you can apply a ',...
        'different filter without re-running the decon. Just change the filter parameters and click ',...
        '"Apply Filter". The filter is always applied to the (unfiltered) deconvolution result being displayed.'],...
        ' ',['The "Show spectra" button allows comparison of spectra before and after ',...
        'deconvolution. Spectra are averages taken over the application window (that is, between the dashed red ',...
        'lines on the input seismic data).'],' ',['At the very bottom right of the window are two ',...
        'buttons labelled "Publish parameters" and "Receive parameters". These allow the Gabor ',...
        'and filter parameters that are current in one instance of the tool to be communicated to ',...
        'another instance. So if dataset A is diplayed in Window A and dataset B in Window B ',...
        'then the parameters that give favorable results for A can be easily tested on B.']}};
     msg={msg1,msg4,msg2,msg3};
    
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        if(isgraphics(udat{1}))
            figure(udat{1});
        else
            hinfo=showinfo(msg,'Instructions for Gabor Decon tool',nan,[600 400],[3 5 2 2]);
            udat{1}=hinfo;
        end
    else
        if(isgraphics(udat))
            figure(udat);
        else
            hinfo=showinfo(msg,'Instructions for Gabor Decon tool',nan,[600 400]);
            udat=hinfo;
        end
    end
    set(hthisfig,'userdata',udat);
elseif(strcmp(action,'vals2globals'))
    hseis2=findobj(gcf,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    t=get(hi,'ydata');
    fnyq=.5/(t(2)-t(1));
    %get the window size
    hop=findobj(gcf,'tag','twin');
    val=get(hop,'string');
    twin=str2double(val);
    if(isnan(twin))
        twin=.2;
    end
    if(twin<=0 || twin>1)
        twin=.2;
    end
    GABOR_TWIN=twin;
    %get the window increment
    hop=findobj(gcf,'tag','tinc');
    val=get(hop,'string');
    tinc=str2double(val);
    if(isnan(tinc))
        tinc=twin/4;
    end
    if(tinc<=0 || tinc>twin)
        tinc=twin/4;
    end
    GABOR_TINC=tinc;
    %get the temporal smoother
    hop=findobj(gcf,'tag','tsmo');
    val=get(hop,'string');
    tsmo=str2double(val);
    if(isnan(tsmo))
        tsmo=1;
    end
    if(tsmo<=0 || tsmo>max(t))
        tsmo=1;
    end
    GABOR_TSMO=tsmo;
    %get the frequency smoother
    hop=findobj(gcf,'tag','fsmo');
    val=get(hop,'string');
    fsmo=str2double(val);
    if(isnan(fsmo))
        fsmo=5;
    end
    if(fsmo<=0 || fsmo>.5*fnyq)
        fsmo=5;
    end
    GABOR_FSMO=fsmo;
    %get the stab 
    hop=findobj(gcf,'tag','stab');
    val=get(hop,'string');
    stab=str2double(val);
    if(isnan(stab))
        stab=.00001;
    end
    if(stab<0 || stab>1)
        stab=.00001;
    end
    GABOR_STAB=stab;
    %get the smoother choice
    hop=findobj(gcf,'tag','hyp');
    val=get(hop,'value');
    ihyp=val-1;
    GABOR_IHYP=ihyp;
    %get the phase choice
    hop=findobj(gcf,'tag','gphase');
    val=get(hop,'value');
    phase=val-1;
    GABOR_GPHASE=phase;
    %get preserve power flag
    hpow=findobj(gcf,'tag','tracepower');
    GABOR_IPOW=get(hpow,'value');
    
    %TVfilter params
    fnyq=.5/(t(2)-t(1));
    hobj=findobj(gcf,'tag','t1');
    val=get(hobj,'string');
    t1=str2double(val);
    if(isnan(t1))
        t1=mean(t);
    end
    if(t1<t(1) || t1>t(end))
        t1=mean(t);
    end
    GABOR_T1=t1;
    hobj=findobj(gcf,'tag','tvfmin');
    val=get(hobj,'string');
    fmin=str2double(val);
    if(isnan(fmin))
        fmin=5;
    end
    if(fmin<0 || fmin>fnyq)
        fmin=5;
    end
    GABOR_TVFMIN=fmin;
    hobj=findobj(gcf,'tag','tvdfmin');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmin=str2double(val);
        if(isnan(dfmin))
            dfmin=fmin/2;
        end
        if(dfmin<0 || dfmin>fmin)
            dfmin=fmin/2;
        end
    else
        dfmin=.5*fmin;
    end
    GABOR_TVDFMIN=dfmin;
    hobj=findobj(gcf,'tag','tvfmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        fmax=100;
    end
    if(fmax<0 || fmax>fnyq)
        fmax=100;
    end
    if(fmax<=fmin && fmax~=0)
        fmax=100;
    end
    GABOR_TVFMAX=fmax;
    hobj=findobj(gcf,'tag','tvdfmax');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmax=str2double(val);
        if(isnan(dfmax))
            dfmax=10;
        end
        if(dfmax<0 || dfmax>fnyq-fmax)
            dfmax=10;
        end
    else
        dfmax=10;
    end
    GABOR_TVDFMAX=dfmax;
    hobj=findobj(gcf,'tag','fmaxmax');
    val=get(hobj,'string');
    fmaxmax=str2double(val);
    if(isnan(fmaxmax))
        fmaxmax=1.2*fmax;
    end
    if(fmaxmax<fmax || fmaxmax>fnyq)
        fmaxmax=1.2*fmax;
    end
    GABOR_FMAXMAX=fmaxmax;
    hobj=findobj(gcf,'tag','fmaxmin');
    val=get(hobj,'string');
    fmaxmin=str2double(val);
    if(isnan(fmaxmin))
        fmaxmin=.8*fmax;
    end
    if(fmaxmin<fmin || fmaxmin>fmax)
        fmaxmin=.8*fmax;
    end
    GABOR_FMAXMIN=fmaxmin;
    hobj=findobj(gcf,'tag','phase');
    ival=get(hobj,'value');
    phase=ival-1;
    GABOR_PHASE=phase;
    
    %stationary filter
    hobj=findobj(gcf,'tag','fmin');
    val=get(hobj,'string');
    fmin=str2double(val);
    if(isnan(fmin))
        fmin=5;
    end
    if(fmin<0 || fmin>fnyq)
        fmin=5;
    end
    GABOR_FMIN=fmin;
    
    hobj=findobj(gcf,'tag','dfmin');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmin=str2double(val);
        if(isnan(dfmin))
            dfmin=fmin/2;
        end
        if(dfmin<0 || dfmin>fmin)
            dfmin=fmin/2;
        end
    else
        dfmin=.5*fmin;
    end
    GABOR_DFMIN=dfmin;
    
    hobj=findobj(gcf,'tag','fmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        fmax=100;
    end
    if(fmax<0 || fmax>fnyq)
        fmax=100;
    end
    if(fmax<=fmin && fmax~=0)
       fmax=100;
    end
    GABOR_FMAX=100;
    
    hobj=findobj(gcf,'tag','dfmax');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmax=str2double(val);
        if(isnan(dfmax))
            dfmax=10;
        end
        if(dfmax<0 || dfmax>fnyq-fmax)
            dfmax=10;
        end
    else
        dfmax=10;
    end
    GABOR_DFMAX=dfmax;
    
elseif(strcmp(action,'globals2vals'))
    %window size
    hop=findobj(gcf,'tag','twin');
    if(~isempty(GABOR_TWIN))
        set(hop,'string',time2str(GABOR_TWIN))
    end
    %window increment
    hop=findobj(gcf,'tag','tinc');
    if(~isempty(GABOR_TINC))
       set(hop,'string',time2str(GABOR_TINC)); 
    end
    %temporal smoother
    hop=findobj(gcf,'tag','tsmo');
    if(~isempty(GABOR_TSMO))
       set(hop,'string',time2str(GABOR_TSMO)) 
    end
    %frequency smoother
    hop=findobj(gcf,'tag','fsmo');
    if(~isempty(GABOR_FSMO))
       set(hop,'string',num2str(GABOR_FSMO)) 
    end
    %stab 
    hop=findobj(gcf,'tag','stab');
    if(~isempty(GABOR_STAB))
        set(hop,'string',num2str(GABOR_STAB))
    end
    %smoother choice
    hop=findobj(gcf,'tag','hyp');
    if(~isempty(GABOR_IHYP))
        set(hop,'value',GABOR_IHYP+1);
    end
    %phase choice
    hop=findobj(gcf,'tag','gphase');
    if(~isempty(GABOR_PHASE))
        set(hop,'value',GABOR_GPHASE+1)
    end
    %power preservation
    hpow=findobj(gcf,'tag','tracepower');
    if(~isempty(GABOR_IPOW))
        set(hpow,'value',GABOR_IPOW);
    end
    
    %TVfilter params
    %T1
    hobj=findobj(gcf,'tag','t1');
    if(~isempty(GABOR_T1))
        set(hobj,'string',time2str(GABOR_T1));
    end
    %fmin
    hobj=findobj(gcf,'tag','tvfmin');
    if(~isempty(GABOR_TVFMIN))
        set(hobj,'string',num2str(GABOR_TVFMIN));
    end
    %dfmin
    hobj=findobj(gcf,'tag','tvdfmin');
    if(~isempty(GABOR_TVDFMIN))
        set(hobj,'string',num2str(GABOR_TVDFMIN))
    end
    %fmax
    hobj=findobj(gcf,'tag','tvfmax');
    if(~isempty(GABOR_TVFMAX))
       set(hobj,'string',num2str(GABOR_TVFMAX)) 
    end
    %dfmax
    hobj=findobj(gcf,'tag','tvdfmax');
    if(~isempty(GABOR_TVDFMAX))
        set(hobj,'string',num2str(GABOR_TVDFMAX))
    end
    %fmaxmax
    hobj=findobj(gcf,'tag','fmaxmax');
    if(~isempty(GABOR_FMAXMAX))
        set(hobj,'string',num2str(GABOR_FMAXMAX))
    end
    %fminmin
    hobj=findobj(gcf,'tag','fmaxmin');
    if(~isempty(GABOR_FMAXMIN))
        set(hobj,'string',num2str(GABOR_FMAXMIN))
    end
    %phase
    hobj=findobj(gcf,'tag','phase');
    if(~isempty(GABOR_PHASE))
        set(hobj,'value',GABOR_PHASE+1)
    end
    
    %stationary filter
    %fmin
    hobj=findobj(gcf,'tag','fmin');
    if(~isempty(GABOR_FMIN))
        set(hobj,'string',num2str(GABOR_FMIN))
    end
    %dfmin
    hobj=findobj(gcf,'tag','dfmin');
    if(~isempty(GABOR_DFMIN))
        set(hobj,'string',num2str(GABOR_DFMIN))
    end
    %fmax
    hobj=findobj(gcf,'tag','fmax');
    if(~isempty(GABOR_FMAX))
        set(hobj,'string',num2str(GABOR_FMAX))
    end
    %dfmax
    hobj=findobj(gcf,'tag','dfmax');
    if(~isempty(GABOR_DFMAX))
       set(hobj,'string',num2str(GABOR_DFMAX)) 
    end
end
end

%% functions

function show2dspectrum(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
pos=get(hmasterfig,'position');
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
fmax=.25/(t(2)-t(1));
haxe=get(hi,'parent');
if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        hresults=findobj(hmasterfig,'tag','results');
        idata=get(hresults,'value');
        dnames=get(hresults,'string');
        dname=dnames{idata};
    end
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfk(seis,t,x,dname,fmax);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on')
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);

    set(hppt,'userdata',dname);

end
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end

end

function fkfilter(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
pos=get(hmasterfig,'position');
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
fmax=.5/(t(2)-t(1));
haxe=get(hi,'parent');
if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        hresults=findobj(hmasterfig,'tag','results');
        idata=get(hresults,'value');
        dnames=get(hresults,'string');
        dname=dnames{idata};
    end
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfkfilt(seis,t,x,dname,fmax);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on')
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname);
end
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function showtvspectrum(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis2=findobj(hmasterfig,'tag','seis2');
hi=gco;
%hi=findobj(hseis2,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');

if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        hresults=findobj(hmasterfig,'tag','results');
        idata=get(hresults,'value');
        dnames=get(hresults,'string');
        dname=dnames{idata};
    end
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplottvs(seis,t,x,dname,nan,nan);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname);

end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function showfxamp(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis2=findobj(hmasterfig,'tag','seis2');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        hresults=findobj(hmasterfig,'tag','results');
        idata=get(hresults,'value');
        dnames=get(hresults,'string');
        dname=dnames{idata};
    end
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfx(seis,t,x,dname);
NEWFIGVIS='on';
colormap(datar{1},cmap)
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname);
end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function showfxphase(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis2=findobj(hmasterfig,'tag','seis2');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        hresults=findobj(hmasterfig,'tag','results');
        idata=get(hresults,'value');
        dnames=get(hresults,'string');
        dname=dnames{idata};
    end
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfx(seis,t,x,dname,nan,nan,nan,nan,1);
NEWFIGVIS='on';
colormap(datar{1},cmap)
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname);
end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function showtraces(~,~,flag)
hmasterfig=gcf;
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        haxe1=findobj(hmasterfig,'tag','seis1');
        dname1=haxe1.Title.String;
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname2=dnames{idata};
        dname=[dname1 ' ' dname2];
    end
else
    dname=haxe.Title.String;
end

%get current point
pt=seisplottraces('getlocation',flag);
ixnow=near(x,pt(1,1));

%determine pixels per second
un=get(haxe,'units');
set(gca,'units','pixels');
pos=get(haxe,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(haxe,'units',un);

iuse=ixnow(1)-0:ixnow(1)+0;
% iuse=ixnow;
pos=get(hmasterfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);
% dname2=dname(ind(1)+4:end);

seisplottraces(double(seis(:,iuse)),t,x(iuse),dname,pixpersec);
hfig=gcf;
customizetoolbar(hfig);
if(fromenhance(hmasterfig))
    seisplottraces('addpptbutton');
    set(gcf,'tag','fromenhance');
    pos2=get(hfig,'position');
    pos2(1)=xc-.5*pos2(3);
    pos2(2)=yc-.5*pos2(4);
    set(hfig,'position',pos2,'visible','on');
end

hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);

%register the figure
seisplottraces('register',hmasterfig,hfig);

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.8,.930,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end

end

function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','enhance(''makepptslide'');');
%the title string will be stored as userdata
end

function fontchange(~,~)
hm=gcbo;
tag=hm.Label;
scalar=str2double(tag(2:end));
haxe=hm.UserData;
ht=haxe.Title;
fs=ht.UserData;
hresults=findobj(gcf,'tag','results');
if(isempty(fs))
    fs=hresults.FontSize;
    ht.UserData=fs;
end
hshortresults=findobj(gcf,'tag','shortresults');
hshortnames=findobj(gcf,'tag','shortnames');
ishort=hshortnames.Value;
if(ishort)
    hshortresults.FontSize=scalar*fs;
else
    hresults.FontSize=scalar*fs;
end

end

function retitle(~,~)
hresults=findobj(gcf,'tag','results');
hshortresults=findobj(gcf,'tag','shortresults');
hshortnames=findobj(gcf,'tag','shortnames');
ishort=hshortnames.Value;
iresult=hresults.Value;
if(ishort)
    names=hshortresults.String;
else
    names=hresults.String;
end
if(ischar(names))
    a=askthingsle('questions',{'New Title'},'answers',{names});
else
    a=askthingsle('questions',{'New Title'},'answers',names(iresult));
end
if(isempty(a))
    return;
else
    results=hresults.UserData;
    if(ischar(names))
        names=a{1};
        if(ishort)
            hshortresults.String=names;
            results.shortnames{1}=names;
        else
            hresults.String=names;
            results.names{1}=names;
        end
    else
        names{iresult}=a{1};
        if(ishort)
            hshortresults.String=names;
            results.shortnames{iresult}=names{iresult};
        else
            hresults.String=names;
            results.names{iresult}=names{iresult};
        end
    end
    hresults.UserData=results;
end
end

function [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(data)
% data ... input data
%
% 
% clips ... determined clip levels
% clipstr ... cell array of strings for each clip level for use in popup menu
% clip ... starting clip level
% iclip ... index into clips where clip is found
% sigma ... standard deviation of data
% am ... mean of data
% amax ... max of data
% amin ... min of data

ind=find(data~=0);
sigma=std(data(ind));
am=mean(data(ind));
amin=min(data(ind));
amax=max(data(ind));
nsigma=ceil((amax-amin)/sigma);%number of sigmas that span the data

%clips=linspace(nsigma,1,nclips)';
clips=[20 15 10 9 8 7 6 5 4 3 2 1 .75 .5 .25 .1]';
if(nsigma<clips(1))
    %ind= clips<nsigma;
    %clips=[nsigma;clips(ind)];
    clips=linspace(nsigma,.1,length(clips));
else
    n=floor(log10(nsigma/clips(1))/log10(2));
    newclips=zeros(n,1);
    newclips(1)=nsigma;
    for k=n:-1:2
        newclips(k)=2^(n+1-k)*clips(1);
    end
    clips=[newclips;clips];
end

ind=find(clips>=1);
clips(ind)=round(clips(ind));
ind=find(clips<1);
clips(ind)=round(clips(ind)*10)/10;


clipstr=cell(size(clips));
nclips=length(clips);
clipstr{1}='graphical';
for k=2:nclips
    clipstr{k}=['clip= ' num2str(sigfig(clips(k),3))];
end
iclip=near(clips,3);
iclip=iclip(1);
clip=clips(iclip);

end
function datar=seisplotspecd(seis,t,x,dname)
% seisplotspecd: provides interactive spectral decomp of a 2D seismic section
%
% datar=seisplotspecd(seis,t,x,dname)
%
% A new figure is created and divided into three axes (side-by-side). The first axes shows the
% seismic gather on which spectral decomp was performed, the second shows the spectral decomp one
% frequency at a time with controls to step through the frequencies, and the third axis shows the
% spectral decomp at a single x location as a function of frequency.
%
% seis ... 2D seismic matrix that spectral decomp was done on
% t ... time coordinate vector for seis
% x ... space coordinate vector for seis
% dname ... text string nameing the first seismic matrix. Enter [] or '' for no name.
% ******** default = '' ************
%
% datar ... Return data which is a length 3 cell array containing
%           datar{1} ... handle of the first seismic axes
%           datar{2} ... handle of the first spectral decomp axis (section)
%           datar{3} ... handle of the second spectral decomp axis (gather)
% These return data are provided to simplify plotting additional lines and text.
%
% NOTE: The key parameters for the spectral decomp computation are twin, tinc, fmin, fmax, and delf
% and the starting values for these can be controlled by defining the global variables below. These
% globals have names that are all caps. The default value applies when the corresponding global is
% either undefined or empty.
% SPECD_TWIN ... half-width of the Gaussian windows (standard deviation) in seconds
%  ************ default = 0.01 seconds ************
% SPECD_TINC ... increment between adjacent Gaussians
%  ************ default = 2*dt seconds (dt is the time sample size of the data) ***********
% SPECD_FMIN ... minimum frequency in the SpecD volume.  (in Hertz)
%  ************ default 5 Hz *************
% SPECD_FMAX ... maximum signal frequency in the dataset. (in Hertz)
%  ************ default 0.25/dt Hz which is 1/2 of Nyquist *************
% SPECD_DELF ... increment between frequencies in Hertz
% ************* default 5 Hz ***************
% 
% G.F. Margrave, Margrave-Geo, 2018
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

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED %#ok<NUSED>
global NEWFIGVIS
global SPECD_TWIN SPECD_TINC SPECD_FMIN SPECD_FMAX SPECD_DELF
% global HMFIG
if(~ischar(seis))
    action='init';
else
    action=seis;
end

% HMFIG=gcf;%debugging tool

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match seismic matrix');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match seismic matrix');
    end
    
    if(nargin<4)
        dname=[];
    end
    
    if(iscell(dname))
        error('dname must be a simple string not a cell')
    end
    
    %establish initial parameter defaults
    dt=t(2)-t(1);
    fnyq=.5/dt;
    if(isempty(SPECD_FMAX))
        fmax=round(.5*fnyq);
    else
        fmax=SPECD_FMAX;
    end
    fmax2=.5*fmax;%display fmax
    if(isempty(SPECD_FMIN))
        fmin=5;
    else
        fmin=SPECD_FMIN;
    end
    if(isempty(SPECD_DELF))
        delf=2;
    else
        delf=SPECD_DELF;
    end
    if(isempty(SPECD_TWIN))
        twin=0.01;
    else
        twin=SPECD_TWIN;
    end
    if(isempty(SPECD_TINC))
        tinc=2*dt;
    else
        tinc=SPECD_TINC;
    end
    
    %do initial spectral decomp
    %do the spectral decomp
    phaseflag=3;
    tmin=t(1);tmax=t(end);
    [seissd,phs,tsd,fsd]=specdecomp(seis,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,1); %#ok<ASGLU>
    name=['SPECD ' 'Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ', Fmin= ', num2str(fmin) ...
        ', Fmax= ', num2str(fmax) ', delF= ', num2str(delf),', agc=0'];
    
    
    %determine a few things about the spectral decomp
    nfsd=length(fsd);
    mnfsd=zeros(1,nfsd);
    maxfsd=mnfsd;
    minfsd=mnfsd;
    sfsd=mnfsd;
%     %test for amp or phase
%     ind=find(seissd(:,:,round(nfsd/2))<0, 1);
%     if(isempty(ind))
%         amp=true;
%     else
%         amp=false;
%     end
    for k=1:nfsd
        tmp=seissd(:,:,k);
        mnfsd(k)=mean(tmp(:));
        maxfsd(k)=max(tmp(:));
        minfsd(k)=mean(tmp(:));
        sfsd(k)=std(tmp(:));
    end

    %establish window geometry
    xwid=.41;
    xwid2=.41;
    xwid3=.1;
    yht=.8;
    xsep=.05;
    
    ynot=.1;
    xshrink=.76;
    xwid=xshrink*xwid;
    xwid2=xshrink*xwid2;
    xwid3=xshrink*xwid3;
%     xwid4=.1;
%     xnot=.75*(1-xwid-xwid2-xwid3-xwid4-1.5*xsep);
    xnot=.11;
    
    %test to see if we are from enhance. This enables the fromenhance local logical function to work
    ff=figs;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           %so the current figure is from enhance and we assume it hase called this one
           enhancetag='fromenhance';
           udat={-999.25,gcf};
       else
           enhancetag='';
           udat=[];
       end
    else
        enhancetag='';
        udat=[];
    end
    
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat);
    hax1=subplot('position',[xnot ynot xwid yht]);

%     [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis); %#ok<ASGLU>
%     clim=[am-clip*sigma am+clip*sigma];
        
    hi=imagesc(x,t,seis);
    set(hi,'userdata',[0 0]);%spaceflag=0 dataflag=0
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','Time-variant spectra','callback',@showtvs);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    uimenu(hcm,'label','SPECD Investigator','callback',@showwin);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap);
    
    %brighten(.5);
    grid
    enTitle(dname,'interpreter','none')
    maxmeters=7000;
    if(max(t)<10)
        ylabel('time (s)')
    elseif(max(t)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    if(max(x)<maxmeters)
        xlabel('distance')
    else
        xlabel('distance')
    end
    
    %make a clip control
    wid2=.04;nudge=.5*xsep;
    wid=.055;ht=.05;
    htclip=2*ht;
    xnow=xnot-1.85*wid;
    ynow=ynot+yht-htclip;
    %make a clip control
    climxt=[-3 3];
    hclip1=uipanel(hfig,'position',[xnow,ynow,1.45*wid,htclip],'tag','clip1',...
        'userdata',{climxt,hax1},'title','Clipping');
    data={climxt,hax1};
    callback='';
    cliptool(hclip1,data,callback);
    hfig.CurrentAxes=hax1;

    %make a help button
    ynow=ynot+yht;
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+ht,.5*wid,.5*ht],'callback','seisplotspecd(''info'');',...
        'backgroundcolor','y');
    
    %the hide seismic button
    xnoww=xnot-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Hide seismic','tag','hideshow','units','normalized',...
        'position',[xnoww,ynow+ht,wid,.5*ht],'callback','seisplotspecd(''hideshow'');','userdata','hide');
    %the toggle button
%     xnoww=xnoww+1.1*wid;
    uicontrol(hfig,'style','pushbutton','string','Toggle','tag','toggle','units','normalized',...
        'position',[xnoww,ynow+.5*ht,wid,.5*ht],'callback','seisplotspecd(''toggle'');','visible','off');
    
    %aec controls
    uicontrol(hfig,'style','pushbutton','string','Apply AGC:','tag','appagc','units','normalized','position',...
        [xnot-wid2-nudge,ynow+ht,wid2,.5*ht],'callback','seisplotspecd(''agc'');',...
        'tooltipstring','Push to apply Automatic gain correction','userdata',0);
    %the userdata of the above is the operator length of the actually applied agc
    uicontrol(hfig,'style','edit','string','0','tag','agc','units','normalized','position',...
        [xnot-wid2-nudge,ynow+.5*ht,wid2,.5*ht],'tooltipstring','Define an operator length in seconds (0 means no AGC)',...
        'userdata',{seis,t},'callback','seisplotspecd(''agc'');');
    
    set(hax1,'tag','seis');
    
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid2 yht]);

    ifsd=near(fsd,fmax2/2);
    ifsd=ifsd(1);
    hi=imagesc(x,tsd,seissd(:,:,ifsd));
    set(hi,'userdata',[0 1]);%spaceflag=0 dataflag=1
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','RGB Blend','callback',@RGB);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap );
    grid
%     if(amp)
%         enTitle(['specD amplitude, frequency= ' num2str(fsd(ifsd)) ' Hz'],'interpreter','none')
%     else
%         enTitle(['specD phase, frequency= ' num2str(fsd(ifsd)) ' Hz'],'interpreter','none')
%     end
    set(hax2,'tag','seissd','nextplot','add');
    %draw line indicating gather position
    tmin=min(t);
    tmax=max(t);
    klr='r';
    xm=mean(x);
    ix=near(x,xm);
    xm=x(ix(1));
    lw=1;
    line([xm xm],[tmin tmax],[1 1],'color',klr,'linestyle','--','buttondownfcn',...
        'seisplotspecd(''dragline'');','tag','1','linewidth',lw);
    
    if(max(tsd)<10)
        ylabel('time (s)')
    elseif(max(tsd)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('(depth (ft)')
    end
    if(max(x)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    
    %gather axis
    df=fsd(2)-fsd(1);
    hax3=subplot('position',[xnot+xwid+xwid2+2*xsep ynot xwid3 yht]);
    hi=imagesc(fsd,tsd,squeeze(seissd(:,ix(1),:)));
    set(hi,'userdata',[0 1]);%spaceflag=0 dataflag=1
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'}); 
    uimenu(hcm,'label','Average spectrum','callback',@avespec);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap );
    xlim([fsd(1)-df fmax2+df])
    xlabel('frequency (Hz)')
    ylabel('time (sec)')
    brighten(.5);
    set(hax3,'tag','sdgather','nextplot','add');
    %draw line indicating frequency position
    tmin=min(t);
    tmax=max(t);
    %klrs=get(hax1,'colororder');
    klr='r';
    lw=1;
    line([fsd(ifsd) fsd(ifsd)],[tmin tmax],[1 1],'color',klr,'linestyle','--',...
        'buttondownfcn','seisplotspecd(''dragline'');','tag','2','linewidth',lw);
    
    enTitle(['freq= ' num2str(fsd(ifsd)) ' Hz'])
    grid
    
    %right-click message
    wmsg=.2;
    xmsg=xnot+xwid+.5*xsep-.5*wmsg;
    annotation(hfig,'textbox','string','Right-click on any image for analysis tools',...
        'position',[xmsg,.955,wmsg,.05],'linestyle','none','fontsize',7,'color','r','fontweight','bold');
    
    %make a clip control
    xnow=xnot+xwid+xwid2+xwid3+2*xsep+.1*wid;
    wid=.055;ht=.05;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    climsd=[-.5 7];%default for new results
    hclip2=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip2',...
        'userdata',{climsd,[hax2,hax3],x,t,fsd,seissd,seis},'title','Clipping');
    data={climsd,hax2,[],0,1,1};
    callback='seisplotspecd(''clip2'');';
    cliptool(hclip2,data,callback);
    hfig.CurrentAxes=hax2;

    %frequency stepping controls
%     xnow=xnow+.1*wid;
    ht=.025;
    ynow=ynow-1*ht;
    df=fsd(2)-fsd(1);
    uicontrol(hfig,'style','text','string','Step freq:','units','normalized',...
        'position',[xnow,ynow,wid,.75*ht],'tooltipstring','step through frequencies');
    xnow=xnow+wid;
    uicontrol(hfig,'style','pushbutton','string','<','tag','stepd','units','normalized',...
        'position',[xnow,ynow,.2*wid,ht],'callback','seisplotspecd(''step'');',...
        'tooltipstring',['step down ' num2str(df) ' Hz']);
    xnow=xnow+.22*wid;
    uicontrol(hfig,'style','pushbutton','string','>','tag','stepu','units','normalized',...
        'position',[xnow,ynow,.2*wid,ht],'callback','seisplotspecd(''step'');',...
        'tooltipstring',['step up ' num2str(df) ' Hz']);

    %fmax control
    ynow=ynow-.5*(ht+xsep);
    xnow=xnot+xwid+xwid2+xwid3+2*xsep+.1*wid;
    uicontrol(hfig,'style','text','string','Max freq:','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'tooltipstring','Maximum frequency in  Hz to display');
%     ynow=ynow-.5*ht;
    uicontrol(hfig,'style','edit','string',num2str(fmax2),'tag','fmaxdisp','units','normalized',...
        'position',[xnow+.75*wid,ynow,.5*wid,ht],'callback','seisplotspecd(''fmax'');',...
        'tooltipstring',['enter a value between ' num2str(fsd(1)) ' and ' num2str(fsd(end))]);
    
    %specd parameters
    sep=.005; 
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','SpecD parms:','units','normalized',...
        'position',[xnow,ynow,1.25*wid,ht],'tooltipstring','Change these values and then click "Compute SpecD"');
    ynow=ynow-ht-sep;
    wid=wid*.5;
    uicontrol(hfig,'style','text','string','Twin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Gaussian window half-width in seconds');
    uicontrol(hfig,'style','edit','string',num2str(twin),'units','normalized','tag','twin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds corresponding to a few samples');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Tinc:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Increment between consequtive windows in seconds');
    uicontrol(hfig,'style','edit','string',num2str(tinc),'units','normalized','tag','tinc',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds smaller than Twin');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fmin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Minimum frequency of interest');
    uicontrol(hfig,'style','edit','string',num2str(fmin),'units','normalized','tag','fmin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Maximum frequency to compute');
    uicontrol(hfig,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring',['Enter a value in Hertz less than ' num2str(fnyq)]);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','delF:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Frequency increment');
    uicontrol(hfig,'style','edit','string',num2str(delf),'units','normalized','tag','delf',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Compute SpecD','units','normalized',...
        'position',[xnow,ynow,2.5*wid,ht],'callback','seisplotspecd(''computespecd'');',...
        'tooltipstring','Compute SpecD with current parameters','tag','specdbutton','backgroundcolor','y');
    
    %colormaps
    ynow=ynow-8.5*ht;
    pos=[xnow,ynow,2.5*wid,8*ht];
    cb1='';cb2='';
    cmapdefaults=cell(1,2);
    cmapdefaults{1}=enhance('getdefaultcolormap','sections');
    cmapdefaults{2}=enhance('getdefaultcolormap','ampspectra');
    cm1=cmapdefaults{1}{1};
    iflip1=cmapdefaults{1}{2};
    cm2=cmapdefaults{2}{1};
    iflip2=cmapdefaults{2}{2};
    cbflag=[0,2];
    cbcb='seisplotspecd(''colorbars'');';
    cbaxe=[hax1,hax2];
    enhancecolormaptool(hfig,pos,hax1,[hax2,hax3],cb1,cb2,cm1,cm2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    
    %spectra
    ynow=ynow-2*ht-sep;
    wid=2.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Browse spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotspecd(''browse'');',...
        'tooltipstring','Start browsing spectra at specific points','tag','browse',...
        'userdata',{[],[],'Point Set New'});
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Save spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotspecd(''savespec'');',...
        'tooltipstring','Save the current set of points for recall later','tag','savespec',...
        'visible','off');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','popupmenu','string','Point Set New','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotspecd(''choosespec'');',...
        'tooltipstring','Choose the set of point to work with','tag','choosespec',...
        'userdata',{[]},'visible','off');
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(hfig,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplotspecd(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplotspecd(''equalzoom'');');
    
    %results popup
    xnow=pos(1)-.025;
    ynow=pos(2)+pos(4)-ht;
    wid2=pos(3)+.05;
    ht=3*ht;
    fs=11;
    fontops={'x2','x1.5','x1.25','x1.11','x1','x0.9','x0.8','x0.67','x0.5'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange,'userdata',hax2);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
    uicontrol(hfig,'style','popupmenu','string','...','units','normalized','tag','results',...
        'position',[xnow,ynow,wid2,ht],'callback','seisplotspecd(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm);
    
    %delete button
    wid=.1;
    ht=ht/3;
    xnow=xnow+wid2-wid;
    ynow=ynow+ht+sep;
    
    %userdata of the delete button is the number of the current selection
    uicontrol(hfig,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnow,ynow+1.75*ht,wid,ht],'callback','seisplotspecd(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    %save result
    seisplotspecd('newresult',{name,seissd,twin,tinc,fmin,fmax,delf,fsd,climsd});
%     seisplotspecd('clip1');
%     seisplotspecd('clip2');
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.4,1); %enlarge the fonts in the figure
    boldlines([hax2 hax3],4,2); %make lines and symbols "fatter"
%     whitefig;
    
   

    set(hfig,'name',['Spectral decomp for ' dname],'closerequestfcn','seisplotspecd(''close'');');%userdata here is just a placeholder to cause plotimage3D to do the right thing
    if(nargout>0)
        datar=cell(1,3);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=hax3;
    end
    
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    msg0={'Spectral Decomp',{['Spectral decomposition is a mapping of a seismic dataset into the ',...
        'time-frequency domain. This means that a 2D seismic section or gather, which is a function of ',...
        'say (x,t), becomes a 3D display as a function of (x,t,f)  (f is frequency). Similarly, a 3D ',...
        'dataset becomes 4D after spectral decomposition. In the present case, your 2D seismic view ',...
        'has become 3D and it helps to think of the frequency axis as being perpendicular to the computer ',...
        'monitor screen. '],' ',['There are different ways of doing the spectral decomposition and here ',...
        'it has been accomplished by a Gabor transform (aka the short-time Fourier transform). ',...
        'This transform works by defining a narrow time window that moves progressivly down a trace. ',...
        'At each window position, a short segment of the trace is Fourier transformed to produce a ',...
        'local frequency spectrum. Nominally there are both amplitude and phase in this spectrum but here ',...
        'only the amplitude is shown. The idea is to produce a decomposition that has a useful resolution ',...
        'in both time and frequency.'],' ',['The key parameters of the decomposition are the window width ',...
        'and the time increment between successive window positions. Called Twin and Tinc respectively, ',...
        'the current values are displayed in the control panel at the far right. Twin is the more important and ',...
        'Tinc can be reliably set to two or three samples. Windowing a trace is a multiplication operation ',...
        'and the corresponding operation in the Frequency domain is a convolution with the Fourier transform ',...
        'of the time window. The time window used is a Gaussian and its Fourier transform is also a Gaussian. ',...
        'Convolution with a Gaussian is a smoothing process so temporal windowing causes spectral smoothing. ',...
        'The important point is that the width of the time-Gaussian is inversely proportional to the width ',...
        'of the frequency-Gaussian. This means that the smaller the time window, which gives better ',...
        'time resolution, the larger the frequency-Gaussian which gives a smoother, less resolved, spectrum. '],...
        ' ',['So it is not possible to get maximal resolution in both time and frequency simlutaneously. It''s ',...
        'always a tradeoff (this is the famous Heisenberg uncertainty principle) and Twin is the main control. ',...
        'Make it small for the best time resolution and there will be very little distinction between ',...
        'frequencies. Make it large and you will get good frequency resolution but the time view will blur. ',...
        'A reasonable choice seems to be a Twin of 5-10 samples. Twin is the half-width of the Gaussian so ',...
        'you will really have twice this many samples determining the spectrum. Also, it''s a Gaussian ',...
        'and that means there is no sharp window edge. ']}};
    msg1={'Tool layout',{['The axes at left (the seismic axes) shows the ordinary sesimic,',...
        'the middle axes (the specd axes) shows the spectral decomp for a single frequency ',...
        '(section view) and the rightmost axes (the frequency axes) shows the spectral decomp at ',...
        'a single location (gather view). The vertical dashed red line in the specd axes indicates the ',...
        'location being displayed in the frequency axes. Similarly, the red dashed line in the ',...
        'frequency axes indicates the frequency being highlighted in the specd axes. Either red line ',...
        'can be changed by simply clicking a dragging it.'],' ',['At far left above the seismic axes is a ',...
        'button labelled "Hide seismic". Clicking this removes the seismic axes from the display ',...
        'allows the specd axes to fill the window. This action also displays a new button labelled ',...
        '"Toggle" which allows the display to be switched back and forth bwtween seismic and specd. '],' ',...
        ['When both seismic and specd are shown, there are two clipping controls, the left one being for the ',...
        'seismic and the right one being for the specd. Feel free to adjust these. Smaller clip ',...
        'numbers mean greater clipping. Selecting "graphical" for clipping opens a small window ',...
        'to allow interactive adjustment of the clipping controls. This window shows a histogram ',...
        'of the amplitudes in the current view along with two red vertical lines. The colobar extends ',...
        'from one line to the other and amplitudes not between these lines are clipped. ']}};
    msg2={'Control Panel',{['On the far right are shown the parameters of the current spectral decomp. Changing any of ',...
        'values and pressing "Compute SpecD" creates a new spectral decomp. This tool retains any ',...
        'number of spectral decomps in memory unless they are expolicitly deleted. Above the section ',...
        'spectral decomp display is a popup menu displaying the name of the current spectral view. ',...
        'Clicking on this menu allows any of the current spectral decomps to be displayed. ']}};
    msg3={'Browsing Spectra',{['The "Browse spectra" button allows interactive examination of the spectra at any point in ',...
        'the section view. Clicking this button opens a new axes to display spectra. Next click on ',...
        'any point in the spectral decomp section view (not the frequency gather) and the spectrum at that location will be ',...
        'displayed. Clicking the same button (now labelled "Stop browse" closes the spectral browsing '...
        'window. After clicking at a number of points, the browser window can get quite full. To clear it, ',...
        'simply stop and restart the browsing.']}};
    msg={msg0,msg1,msg2,msg3};
    hinfo=showinfo(msg,'Instructions for spectral decomp tool',nan,[600,400]);
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        if(isgraphics(udat{1}))
            delete(udat{1});
        end
        udat{1}=hinfo;
    else
        if(isgraphics(udat))
            delete(udat);
        end
        udat=hinfo;
    end
    set(hthisfig,'userdata',udat);
elseif(strcmp(action,'delete'))
    hfig=gcf;
    hresults=findobj(hfig,'tag','results');
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
    seisplotspecd('select');

elseif(strcmp(action,'colorbars'))
    hfig=gcf;
    hbars=findobj(hfig,'tag','colorbars');
    ibars=get(hbars,'value');
%     hseis=findobj(hfig,'tag','seis');
    hseissd=findobj(hfig,'tag','seissd');
    hgather=findobj(hfig,'tag','sdgather');
    if(ibars)
        set(hseissd,'yticklabel','');
        ylabel(hseissd,'');
        set(hgather,'yticklabel','');
        ylabel(hgather,'');
    else
%         colorbar2(hseis,'off');
%         colorbar2(hseissd,'off');
        set(hseissd,'yticklabelmode','auto');
        ylabel(hseissd,'time (s)');
        set(hgather,'yticklabelmode','auto');
        ylabel(hgather,'time (s)');
    end

elseif(strcmp(action,'fmax'))
    hfmax=findobj(gcf,'tag','fmaxdisp');
    fmax=str2double(get(hfmax,'string'));
    hgather=findobj(gcf,'tag','sdgather');
    hspec=findobj(gcf,'tag','spectra');
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    fsd=udat{5};
    if(isnan(fmax)||fmax<=fsd(1)||fmax>fsd(end))
        fmax=fsd(end);
        set(hfmax,'string',num2str(fmax))
    end
    if(~isempty(hgather))
        axes(hgather);
        xlim([fsd(1) fmax])
    end
    if(~isempty(hspec))
        axes(hspec);
        xlim([fsd(1) fmax])
    end
%elseif(strcmp(action,'clip1'))

    
    
elseif(strcmp(action,'clip2'))
    hmasterfig=gcf;
%     hz21=findobj(hmasterfig,'tag','2like1');
    hresults=findobj(hmasterfig,'tag','results');
    hclip=findobj(hmasterfig,'tag','clip2');
    udat=get(hclip,'userdata');
    haxes=udat{2};
    set(haxes(2),'clim',get(haxes(1),'clim'));

    
    results=get(hresults,'userdata');
    if(~isempty(results))
        climsd=cliptool('getlims',hclip);
        iresult=get(hresults,'value');
        results.climsd{iresult}=climsd;
        set(hresults,'userdata',results);
    end

elseif(strcmp(action,'equalzoom'))
    hbut=gcbo;
    hseis=findobj(gcf,'tag','seis');
    hseissd=findobj(gcf,'tag','seissd');
    tag=get(hbut,'tag');
    switch tag
        case '1like2'
            xl=get(hseissd,'xlim');
            yl=get(hseissd,'ylim');
            set(hseis,'xlim',xl,'ylim',yl);
            
        case '2like1'
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            set(hseissd,'xlim',xl,'ylim',yl);
    end
elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    haxes=udat{2};
    
    h1=findobj(haxes(1),'tag','1');
%     xx=get(h1,'xdata');
%     x1=xx(1);

    h2=findobj(haxes(2),'tag','2');
%     xx=get(h2,'xdata');
%     f2=xx(2);
    
    
    hi=findobj(haxes(1),'type','image');
    x=get(hi,'xdata');
    xmin=min(x);xmax=max(x);
    
    hi=findobj(haxes(2),'type','image');
    f=get(hi,'xdata');
    fmin=f(1);fmax=f(end);
    
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on h1
        dx=abs(x(2)-x(1));
        n=.01*length(x);
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[xmin+n*dx xmax-n*dx];
        DRAGLINE_MOTIONCALLBACK='seisplotspecd(''changeloc'');';
    elseif(hnow==h2)
        %clicked on h2
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[fmin fmax];
        DRAGLINE_MOTIONCALLBACK='seisplotspecd(''changefreq'');';
    end
    
    dragline('click')
elseif(strcmp(action,'changeloc'))
    hobj=gco;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    x=udat{3};
    %fsd=udat{10};
    haxes=udat{2};
    seissd=udat{6};
    if(strcmp(get(hobj,'type'),'line'))
        xx=get(hobj,'xdata');
        xnow=xx(1);
        ix=near(x,xnow);
        hi=findobj(haxes(2),'type','image');
        set(hi,'cdata',squeeze(seissd(:,ix(1),:)));
%         ht=get(haxes(2),'title');
%         xnow=x(ix);
%         ht.String=['loc= ' num2str(xnow)];
    end
    
elseif(strcmp(action,'changefreq'))
    hobj=gco;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    fsd=udat{5};
    haxes=udat{2};
    seissd=udat{6};
    if(~strcmp(get(hobj,'type'),'line'))
       hobj=findobj(haxes(2),'tag','2'); 
    end
    xx=get(hobj,'xdata');
    fnow=xx(1);
    ix=near(fsd,fnow);
    fnow=fsd(ix(1));
    hi=findobj(haxes(1),'type','image');
    set(hi,'cdata',squeeze(seissd(:,:,ix(1))));
    %refresh cliptool
    climsd=udat{1};
    clipdata={climsd,haxes(1),[],0,1,1};
    cliptool('refresh',hclip2,clipdata);
    
    ht=get(haxes(2),'title');
%     str=get(ht,'string');
%     ind=strfind(str,'=');
    set(ht,'string',['freq= ' num2str(fnow) ' Hz'])
elseif(strcmp(action,'step'))
    hstep=gcbo;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    %x=udat{7};
    fsd=udat{5};
    df=fsd(2)-fsd(1);
    haxes=udat{2};
    hline=findobj(haxes(2),'tag','2');
    ff=get(hline,'xdata');
    fnow=round(ff(1));
    if(strcmp(get(hstep,'tag'),'stepd'))
        fnow=fnow-df;
    else
        fnow=fnow+df;
    end
    set(hline,'xdata',[fnow fnow]);
    seisplotspecd('changefreq');
    
elseif(strcmp(action,'close'))
    hfig=gcf;
    haveamp=findobj(hfig,'tag','aveamp');
    hspec=get(haveamp,'userdata');
    if(isgraphics(hspec))
        delete(hspec);
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
    he=findobj(hfig,'tag','enhancebutton');
    if(isgraphics(he))
       enhance('deleteview',hfig); 
    end
    %this last bit avoids deleting the tool figure if there is another close function to be called
    %(usually PI2D or PI3D)
    crf=get(hfig,'closerequestfcn');
    ind=strfind(crf,';');
    if(ind(1)==length(crf))
        delete(hfig);
    end       
elseif(strcmp(action,'hideshow'))
    enhancecolormaptool('colorbarsoff');
    hbut=gcbo;
    option=get(hbut,'userdata');
    hclip1=findobj(gcf,'tag','clip1');
    udat1=get(hclip1,'userdata');
    hax1=udat1{2};
    hclip2=findobj(gcf,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax2=udat2{2}(1);
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    htoggle=findobj(gcf,'tag','toggle');
    
    switch option
        case 'hide'
            enhancecolormaptool('colorbarsoff');drawnow
            pos1=get(hax1,'position');
            pos2=get(hax2,'position');
            colorbar2(hax1,'off');
            set(hax2,'yticklabelmode','auto');ylabel(hax2(1),'time (s)');
            x0=pos1(1);
            y0=pos1(2);
            wid=pos2(1)+pos2(3)-pos1(1);
            ht=pos1(4);
            set(hax1,'visible','off','position',[x0,y0,wid,ht]);
            set(hi1,'visible','off');
            set(hclip1,'visible','off');
            set(hax2,'position',[x0,y0,wid,ht]);
            set(htoggle,'userdata',{pos1 pos2})
            set(hbut,'string','Show seismic','userdata','show')
            set(htoggle,'visible','on');
        case 'show'
            udat=get(htoggle,'userdata');
            pos1=udat{1};
            pos2=udat{2};
            set(hax1,'visible','on','position',pos1);
            set([hi1 hclip1],'visible','on');
            set(hax2,'visible','on','position',pos2);
            set(htoggle','visible','off')
            set(hbut,'string','Hide seismic','userdata','hide');
            set([hi2 hclip2],'visible','on');
    end
elseif(strcmp(action,'toggle'))
    hfig=gcf;
    hclip1=findobj(hfig,'tag','clip1');
    udat1=get(hclip1,'userdata');
    hax1=udat1{2};
    hclip2=findobj(hfig,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax2=udat2{2}(1);
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    
    option=get(hax1,'visible');
    switch option
        case 'off'
            %ok, turning on seismic
            xl=hax2.XLim;
            yl=hax2.YLim;
            hax1.XLim=xl;
            hax1.YLim=yl;
            set([hax1 hclip1 hi1],'visible','on');
            set([hax2 hclip2 hi2],'visible','off');
            hfig.CurrentAxes=hax1;
        case 'on'
            %ok, turning off seismic
            xl=hax1.XLim;
            yl=hax1.YLim;
            hax2.XLim=xl;
            hax2.YLim=yl;
            set([hax1 hclip1 hi1],'visible','off');
            set([hax2 hclip2 hi2],'visible','on');
            hfig.CurrentAxes=hax2;
    end
elseif(strcmp(action,'computespecd'))
    seisplotspecd('stopbrowse');
    %plan: apply the specd parameters and display the results for the mean frequency
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis');
    hseis2=findobj(hfig,'tag','seissd');
    hgather=findobj(hfig,'tag','sdgather');
    hclip2=findobj(hfig,'tag','clip2');
    udat=get(hclip2,'userdata');
    %after implementation of agc, we get seis from 'cdata' of the image
    hi=findobj(hseis,'type','image');
    seis=get(hi,'cdata');
    t=udat{4};
    x=udat{3};
    %dname=udat{5};
    tmax=max(t);
    tmin=min(t);
    tlen=tmax-tmin;
    dt=t(2)-t(1);
    fnyq=.5/dt;
    
    %get the window size
    hw=findobj(gcf,'tag','twin');
    val=get(hw,'string');
    twin=str2double(val);
    if(isnan(twin))
        msgbox('Twin is not recognized as a number','Oh oh ...');
        return;
    end
    if(twin<0 || twin>.25*tlen)
        msgbox('twin is unreasonable, must be positive and less than (Tmax-Tmin)/4');
        return;
    end
    %get the window increment
    hw=findobj(gcf,'tag','tinc');
    val=get(hw,'string');
    tinc=str2double(val);
    if(isnan(tinc))
        msgbox('Tinc is not recognized as a number','Oh oh ...');
        return;
    end
    if(tinc<0 || tinc>twin)
        msgbox('tinc is unreasonable, must be positive and less than Twin');
        return;
    end
    %get fmin
    hobj=findobj(gcf,'tag','fmin');
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
    %get fmax
    hobj=findobj(gcf,'tag','fmax');
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
    if(fmax<=fmin)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    %get delf
    hobj=findobj(gcf,'tag','delf');
    val=get(hobj,'string');
    delf=str2double(val);
    if(isnan(delf))
        msgbox('delF is not recognized as a number','Oh oh ...');
        return;
    end
    if(delf<0 )%|| length(fmin:delf:fmax)==0)
        msgbox('dFmin must be greater than 0','Oh oh ...');
        return;
    end
    fout=fmin:delf:fmax;
    if( isempty(fout))
        msgbox('Fmin:delF:Fmax is empty','Oh oh ...');
        return;
    end

    %do the spectral decomp
    phaseflag=3;
    tmin=t(1);tmax=t(end);
    [seissd,phs,tsd,fsd]=specdecomp(seis,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,1); %#ok<ASGLU>
    %tsd and t are the same because of the input after phaseflag
    
    %determine gather location and frequency to show
    h1=findobj(hseis2,'tag','1');
    h2=findobj(hgather,'tag','2');
    tmp=get(h1,'xdata');
    xgath=tmp(1);
    tmp=get(h2,'xdata');
    fshow=tmp(1);
    tmp=near(x,xgath);
    igath=tmp(1);
    if(~between(fsd(1),fsd(end),fshow))
        fshow=.5*(fsd(1)+fsd(end));
    end
    tmp=near(fsd,fshow);
    ifshow=tmp(1);

    set(hfig,'currentaxes',hseis2)
    
    udat{5}=fsd;
    udat{6}=seissd;
    set(hclip2,'userdata',udat);
    
    hfig.CurrentAxes=hseis2;
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    set(hseis2,'nextplot','add');
    hi=findobj(hseis2,'type','image');
    delete(hi);
    hi=imagesc(x,t,seissd(:,:,ifshow));
    set(hi,'userdata',[0 1]);%spaceflag=0 dataflag=1 
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','RGB Blend','callback',@RGB);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    grid
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap );
%     xlabel('crossline');ylabel('inline');
    happagc=findobj(gcf,'tag','appagc');
    oplen=get(happagc,'userdata');
    name=['SPECD ' 'Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ', Fmin= ', num2str(fmin) ...
        ', Fmax= ', num2str(fmax) ', delF= ', num2str(delf),', agc=' num2str(oplen)];
    set(hseis2,'tag','seissd','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    
    set(hfig,'currentaxes',hgather)
    xdir=get(hgather,'xdir');
    ydir=get(hgather,'ydir');
    xg=get(hgather,'xgrid');
    yg=get(hgather,'ygrid');
    ga=get(hgather,'gridalpha');
    gc=get(hgather,'gridcolor');
    set(hgather,'nextplot','add');
    hi=findobj(hgather,'type','image');
    delete(hi);
    hi=imagesc(fsd,t,squeeze(seissd(:,igath,:)));
    set(hi,'userdata',[0 1]);%spaceflag=0 dataflag=1
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    grid
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap );
%     xlabel('crossline');ylabel('inline');

    set(hgather,'tag','sdgather','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    
    %save result
    climsd=udat{1};
    seisplotspecd('newresult',{name,seissd,twin,tinc,fmin,fmax,delf,fsd,climsd});
    
    %refresh the cliptool
    clipdata={climsd,hseis2,[],0,1,1};
    cliptool('refresh',hclip2,clipdata);
    
%     seisplotspecd('setcolormap','seissd');%set the specd colormap
elseif(strcmp(action,'newresult'))
    hfig=gcf;
    hdelete=findobj(gcf,'tag','delete');
    result=t;%second argument
    %result is a cell array with the following contents: 
    %   name, specd, twin, tinc, fmin, fmax, delf, fout, clipdat
    
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        nresults=1;
        results.names=result(1);
        results.data=result(2);
        results.twins=result(3);
        results.tincs=result(4);
        results.fmins=result(5);
        results.fmaxs=result(6);
        results.delfs=result(7);
        results.fsds=result(8);
        results.climsd=result(9);
    else
        nresults=length(results.names)+1;
        results.names{nresults}=result{1};
        results.data{nresults}=result{2};
        results.twins{nresults}=result{3};
        results.tincs{nresults}=result{4};
        results.fmins{nresults}=result{5};
        results.fmaxs{nresults}=result{6};
        results.delfs{nresults}=result{7};
        results.fsds{nresults}=result{8};
        results.climsd{nresults}=result{9};
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hcompute=findobj(hfig,'tag','specdbutton');
    set(hcompute,'userdata',nresults);%the current result number stored here
    set(hdelete,'userdata',nresults);
    
elseif(strcmp(action,'select'))
    seisplotspecd('stopbrowse');
    hfig=gcf;
    hdelete=findobj(gcf,'tag','delete');%this has the previous selection
%     iprev=get(hdelete,'userdata');
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    hcompute=findobj(hfig,'tag','specdbutton');
%     iresultold=get(hcompute,'userdata');
    set(hcompute,'userdata',iresult);
    hseis2=findobj(hfig,'tag','seissd');
    hgather=findobj(hfig,'tag','sdgather');
    %     hi=findobj(hseis2,'type','image');
    %     seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
    %     set(hi,'cdata',seis2);
    hop=findobj(hfig,'tag','twin');
    set(hop,'string',num2str(results.twins{iresult}));
    hstab=findobj(hfig,'tag','tinc');
    set(hstab,'string',num2str(results.tincs{iresult}));
    hfmin=findobj(hfig,'tag','fmin');
    set(hfmin,'string',num2str(results.fmins{iresult}));
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(results.fmaxs{iresult}));
    hdfmax=findobj(hfig,'tag','delf');
    set(hdfmax,'string',num2str(results.delfs{iresult}));
    
    %determine gather location and frequency to show
    hclip2=findobj(hfig,'tag','clip2');
    udat=get(hclip2,'userdata');
%     seissd=udat{6};
    t=udat{4};
    x=udat{3};
    fsd=results.fsds{iresult};
    h1=findobj(hseis2,'tag','1');
    h2=findobj(hgather,'tag','2');
    tmp=get(h1,'xdata');
    xgath=tmp(1);
    tmp=get(h2,'xdata');
    fshow=tmp(1);
    tmp=near(x,xgath);
    igath=tmp(1);
    if(~between(fsd(1),fsd(end),fshow))
        fshow=.5*(fsd(1)+fsd(end));
    end
    tmp=near(fsd,fshow);
    ifshow=tmp(1);
    seissd=results.data{iresult};
    
    
    %update images
    set(hfig,'currentaxes',hseis2)
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    hi=findobj(hseis2,'type','image');
    hcm=hi.ContextMenu;
    delete(hi);%delete previous image
    hi=imagesc(x,t,seissd(:,:,ifshow));
    set(hi,'userdata',[0 1]);%spaceflag=0 dataflag=1
%     hcm=uicontextmenu;
%     uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
%     uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'contextmenu',hcm,'buttondownfcn',@showcolormap);
    if(strcmp(get(hseis2,'yticklabelmode'),'manual'))
        xlabel('distance');
    else
        xlabel('distance');ylabel('time (s)');
    end
    set(hseis2,'tag','seissd','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    
    set(hfig,'currentaxes',hgather)
    xdir=get(hgather,'xdir');
    ydir=get(hgather,'ydir');
    xg=get(hgather,'xgrid');
    yg=get(hgather,'ygrid');
    ga=get(hgather,'gridalpha');
    gc=get(hgather,'gridcolor');
    hi=findobj(hgather,'type','image');
    hcm=hi.ContextMenu;
    delete(hi);%delete previous
    hi=imagesc(fsd,t,squeeze(seissd(:,igath,:)));
    set(hi,'userdata',[0 0]);%spaceflag=0 dataflag=1
%     hcm=uicontextmenu;
%     uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'contextmenu',hcm,'buttondownfcn',@showcolormap);
    if(strcmp(get(hgather,'yticklabelmode'),'manual'))
        xlabel('frequency (Hz)');
    else
        xlabel('frequency (Hz)');ylabel('time (s)');
    end
    set(hgather,'tag','sdgather','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);

    %refresh clipping
    climsd=results.climsd{iresult};
    climdata={climsd,hseis2,[],0,1,1};
    cliptool('refresh',hclip2,climdata);
    udat{6}=seissd;
    udat{5}=fsd;
    hclip2.UserData=udat;
    
    seisplotspecd('updatespectra');
    set(hresults,'userdata',results);
    set(hdelete,'userdata',iresult);
elseif(strcmp(action,'stopbrowse'))
    hbrowse=findobj(gcf,'tag','browse');
    mode=hbrowse.String;
    switch mode
        case 'Browse spectra'
            return;
        case 'Stop browse'
            seisplotspecd('browse',mode);
    end
        
elseif(strcmp(action,'browse'))
    if(nargin<2)
        hbrowse=gcbo;
        mode=get(hbrowse,'string');
    else
        hbrowse=findobj(gcf,'tag','browse');
        mode=t;
    end
    
    hclip2=findobj(gcf,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax1=findobj(gcf,'tag','seis');
    hax2=udat2{2}(1);
    switch mode
        case 'Browse spectra'
            set(hbrowse,'string','Stop browse');
            
            %determine if specD is full or half
            pos=get(hax2,'position');
            if(pos(3)>.4)
                %full
                bdy=.05;
                fact=1;
                hback=axes('position',[pos(1)-fact*bdy,pos(2)+.75*pos(4)-bdy, .2*pos(3)+fact*bdy, .25*pos(4)+bdy],...
                    'tag','back');
                haxspec=axes('position',[pos(1),pos(2)+.75*pos(4), .2*pos(3), .25*pos(4)],...
                    'tag','spectra');
                disableDefaultInteractivity(haxspec)
            else
                %half
                pos1=get(hax1,'position');
                bdy=.05;
                fact=.75;
                hback=axes('position',[pos1(1)+.6*pos1(3)-fact*bdy,pos1(2)+.25*pos1(4)-bdy, .4*pos1(3)+fact*bdy,...
                    .35*pos1(4)+bdy],'tag','back');
                haxspec=axes('position',[pos1(1)+.6*pos1(3),pos1(2)+.25*pos1(4), .4*pos1(3),...
                    .35*pos1(4)],'tag','spectra');
                disableDefaultInteractivity(haxspec)
            end
            set(hback,'xtick',[],'ytick',[],'xcolor',[1 1 1],'ycolor',[1 1 1]);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','seisplotspecd(''specpt'');');
        case 'Stop browse'
            set(hbrowse,'string','Browse spectra');
            hback=findobj(gcf,'tag','back');
            delete(hback);
            haxspec=findobj(gcf,'tag','spectra');
            delete(haxspec);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','');
            udat=get(hbrowse,'userdata');
            if(~isempty(udat))
                delete(udat{1});
            end
            set(hbrowse,'userdata',[]);
    end
elseif(strcmp(action,'specpt'))
    kols=get(gca,'colororder');
    mkrs={'.','o','x','+','*','s','d','v','^','<','>','p','h'};
    nk=size(kols,1);
    nm=length(mkrs);
    hbrowse=findobj(gcf,'tag','browse');
    udatb=get(hbrowse,'userdata');
    if(isempty(udatb))
       nlines=1;
    else
       nlines=length(udatb{1})+1; 
    end
    ik=nlines;
    if(ik>nk)
        ik=nlines-nk;
        if(ik>nk)
            ik=nlines-2*nk;
        end
    end
    im=nlines;
    if(im>nm)
        im=nlines-nm;
        if(im>nm)
            im=nlines-2*nm;
        end
    end
    hseissd=gca;
    pt=get(hseissd,'currentpoint');
    hm=line(pt(1,1),pt(1,2),'linestyle','none','marker',mkrs{im},'color',kols(ik,:),'markersize',10,'linewidth',1);
    
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    x=udat{3};
    t=udat{4};
    hresult=findobj(gcf,'tag','results');
    results=get(hresult,'userdata');
    iresult=get(hresult,'value');
    seissd=results.data{iresult};
    fsd=results.fsds{iresult};
    %haxes=udat{6};
    it=near(t,pt(1,2));
    ix=near(x,pt(1,1));
    spec=squeeze(seissd(it,ix,:));
    haxspec=findobj(gcf,'tag','spectra');
    axes(haxspec)
    hs=line(fsd,spec,'linestyle','-','marker',mkrs{im},'color',kols(ik,:));
    disableDefaultInteractivity(haxspec)
    if(isempty(udatb))
        udatb={hm,hs};
        xlabel('Frequency');ylabel('Amplitude')
    else
        udatb={[udatb{1} hm],[udatb{2} hs]};
    end
    set(hbrowse,'userdata',udatb);
elseif(strcmp(action,'agc'))
    hagc=findobj(gcf,'tag','agc');
    hseis=findobj(gcf,'tag','seis');
    udat=get(hagc,'userdata');
    seis=udat{1};
    t=udat{2};
    tmp=get(hagc,'string');
    oplen=str2double(tmp);
    if(isnan(oplen)||oplen<0||oplen>t(end))
        set(hagc,'string','0');
        msgbox(['Bad value for operator length. enter a value between 0 and ' num2str(t(end))]);
        return;
    end
    hi=findobj(hseis,'type','image');
    happagc=findobj(gcf,'tag','appagc');
    if(oplen==0)
        seis2=seis;
    else
        seis2=aec(seis,t(2)-t(1),oplen);
    end
    set(hi,'cdata',seis2);
    set(happagc,'userdata',oplen);
    hclip1=findobj(gcf,'tag','clip1');
    clim=cliptool('getlims',hclip1);
    clipdat={clim,hseis};
    cliptool('refresh',hclip1,clipdat);
    
end

end

%% functions
% 

function showcolormap(~,~,hax)
if(nargin<3)
    hax=gca;
end
hfig=gcf;
if(ischar(hax))
    hax=findobj(hfig,'tag',hax);
end

enhancecolormaptool('showcolormap',hax);

end

function showtvs(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis=findobj(hmasterfig,'tag','seis');
hsd=findobj(hmasterfig,'tag','seissd');
hg=findobj(hmasterfig,'tag','sdgather');

hi=gco;
seis=get(hi,'cdata');
t=get(hi,'ydata');
x=get(hi,'xdata');

dname=hseis.Title.String;
NEWFIGVIS='off'; 
datar=seisplottvs(seis,t,x,dname,nan,nan);
NEWFIGVIS='on';
colormap(datar{1},cmap)
hfig=gcf;
customizetoolbar(hfig);

%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
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

function showwin(~,~)
global NEWFIGVIS
hmasterfig=gcf;
haxe=gca;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis=findobj(gcf,'tag','seis');
hsd=findobj(hmasterfig,'tag','seissd');
hg=findobj(hmasterfig,'tag','sdgather');

switch haxe.Tag
    case 'seis'
        dname=hseis.Title.String;
    case 'seissd'
        dname1=hseis.Title.String;
        hresults=findobj(hmasterfig,'tag','results');
        iresult=hresults.Value;
        str=hresults.String;
        dname2=str{iresult};
        dname={dname1,dname2};
    case 'sdgather'
        dname1=hseis.Title.String;
        dname2=haxe.Title.String;
        dname={dname1,['SPECD gather ',dname2]};
end

hi=gco;
seis=get(hi,'cdata');
t=get(hi,'ydata');
x=get(hi,'xdata');
dt=t(2)-t(1);

% if(nargin<5)
%     nx=11;
%     dx=abs(x(2)-x(1));
%     x1=mean(x)-floor(nx/2)*dx;
%     x2=mean(x)+floor(nx/2)*dx;
% end
if(nargin<3)
    nx=11;
    dx=abs(x(2)-x(1));
    xm=round(mean(x)/dx)*dx;
    x1=xm-floor(nx/2)*dx;
    x2=xm+floor(nx/2)*dx;
    t1=round((mean(t)-(t(end)-t(1))*.1)/dt)*dt;
    t2=round((mean(t)+(t(end)-t(1))*.1)/dt)*dt;
    fnyq=.5/dt;
    ok=false;
    name='Define analysis zone';
    while ~ok
        %put up a dialog to ask questions
        q={'Start time','End time','Start x','End x','Frequency'};
        a={time2str(t1),time2str(t2),num2str(x1),num2str(x2),'30'};
        tt={'Minimum time of analysis zone.','Maximum time of analysis zone.',...
            'Minimum x coordinate of analysis zone.','Maximum x coordinate of analysis zone.',...
            'Frequency of interest'};
        
        ansfini=askthingsle('name',name,'questions',q,'answers',a,'tooltips',tt,...
            'masterfig',hmasterfig);
        
        if(isempty(ansfini))
            return
        end
        aa=ansfini;
        t1=str2double(ansfini{1});
        if(isnan(t1))
            ok1=false; %#ok<*NASGU>
        elseif(t1<0 || t1>t(end))
            ok1=false;
        else
            ok1=true;
        end
        t2=str2double(ansfini{2});
        if(isnan(t2))
            ok2=false;
        elseif(t2<t1 || t2>t(end))
            ok2=false;
        else
            ok2=true;
        end
        x1=str2double(ansfini{3});
        if(isnan(x1))
            ok3=false;
        elseif(x1<min(x) || x1>max(x))
            ok3=false;
        else
            ok3=true;
        end
        x2=str2double(ansfini{4});
        if(isnan(x2))
            ok4=false;
        elseif(x2<x1 || x2>max(x))
            ok4=false;
        else
            ok4=true;
        end
        fint=str2double(ansfini{5});
        if(isnan(fint))
            ok5=false;
        elseif(fint<0 || fint>fnyq)
            ok5=false;
        else
            ok5=true;
        end
        if(~any([ok1 ok2 ok3 ok4 ok5]))
            ok=false;
        else
            ok=true;
        end
        if(~ok)
            name='Bad parameters,try again';
        end
    end
end
    
hwin=findobj(hmasterfig,'tag','twin');
twin=str2double(hwin.String);
if(isnan(twin) || twin>t(end) || twin<=dt)
    msgbox('Bad value for twin');
    return;
end
hinc=findobj(hmasterfig,'tag','tinc');
tinc=str2double(hinc.String);
if(isnan(tinc) || tinc>twin || tinc<=dt)
    msgbox('Bad value for tinc');
    return;
end

% it=near(t,t1,t2);
% ix=near(x,x1,x2);
% s=seis(it,ix);


dname1=hseis.Title.String;
NEWFIGVIS='off';
analysisplot(seis,t,x,dname,t1,t2,x1,x2,twin,tinc,fint);
hfig=gcf;
NEWFIGVIS='on';
% colormap(hfig,cmap)

customizetoolbar(hfig);

%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);

    set(hppt,'userdata',dname);
end

set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

% if(strcmp(get(hfig,'tag'),'fromenhance'))
%     enhancebutton(hfig,[.95,.920,.05,.025]);
%     enhance('newview',hfig,hmasterfig);
% end

end

function analysisplot(seis,t,x,dname,t1,t2,x1,x2,twin,tinc,fshow)
% global SPECDANALYSISPLOT
global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK

if(nargin>1)
    if(ischar(x))
        action=x;
    else
        action='init';
    end
else
    action=seis;
end

if(strcmp(action,'init'))
    hmasterfig=gcf;
    %get frequency parameters
    hf=findobj(hmasterfig,'tag','fmin');
    fmin=str2double(hf.String);
    hf=findobj(hmasterfig,'tag','fmax');
    fmax=str2double(hf.String);
    hf=findobj(hmasterfig,'tag','delf');
    df=str2double(hf.String);
    f=fmin:df:fmax;
    ishow=near(f,fshow);%frequency of the Sd
    ishow=ishow(1);
    if(f(ishow)~=fshow)
        fshow=f(ishow);
    end
    % get the gather from the main window
    hsdgath=findobj(hmasterfig,'tag','sdgather');
    hi=findobj(hsdgath,'type','image');
    sdgath=hi.CData;
    tgath=hi.YData;
    fgath=hi.XData;
    cmap=get(hsdgath,'colormap');
    clim=get(hsdgath,'clim');
    newfig=true;
%     if(~isempty(SPECDANALYSISPLOT))
%         if(isgraphics(SPECDANALYSISPLOT))
%             hfig=SPECDANALYSISPLOT;
%             set(0,'currentfigure',hfig);
%             clf
%             newfig=false;
%         end
%     end
    if(newfig)
        figure;
        hfig=gcf;
    end
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
        end
        
    end
    if(notfromenhance)
        enhancetag='';
        udat=[];
    end
    
    
%     if(~isempty(NEWFIGVIS))
%         figure('visible',NEWFIGVIS);
%     else
%         figure
%     end

    set(hfig,'tag',enhancetag,'userdata',udat)
    
    xnot=.1;
    ynot=.1;
    xwid=.6;
    yht=.8;
    
    hseis=subplot('position',[xnot,ynot,xwid,yht]);
    it=near(t,t1,t2);
    trange=t2-t1;
    ix=near(x,x1,x2);
    xrange=x2-x1;
    ss=seis(it,ix);
    tt=t(it);
    xx=x(ix);
    plotseis(ss,tt,xx,1,[1.5 max(abs(ss(:)))]);grid
    hseis.XAxisLocation='bottom';
    title(dname);
    %build window tool
    tmid=.5*(t2+t1);
    it2=near(t,tmid-.25*trange,tmid+.25*trange);
    tau=t;
    nt=length(tau);
    xmid=.5*(x1+x2);
%     stmp=[impulse(tt,round(nt/4))+impulse(tt,round(3*nt/4)),impulse(tt,round(nt/2)),...
%         impulse(tt,round(nt/4))+impulse(tt,round(3*nt/4))];
    stmp=impulse(tau,round(nt/2));
    %make gaussian
    dt=t(2)-t(1);
    n0=round(8*twin/dt);
    n2=2^nextpow2(n0);
    tg=dt*(0:n2)';
    t0=mean(tg);
    gwin=exp(-(tg-t0).^2/(twin^2));
    %tool
    gtool=convz(stmp,gwin);
    %drawtool
    ntr=size(gtool,2);
%     xtool=linspace(x1+.25*xrange,x2-.25*xrange,ntr);
    ind=near(xx,mean(x));
    xtool=xx(ind(1));
    line(xtool+gtool,tau,'color','r','linewidth',2.0,'tag','1',...
        'buttondownfcn',{@analysisplot,'dragline'});
%     for k=1:ntr
%        hl=line(xtool(k)+gtool(:,k),tau,'color','r','linewidth',2.0,'tag',int2str(k),...
%            'buttondownfcn',{@analysisplot,'dragline'});
%     end
%     [Gwin,fwin]=fftrl(gwin,tg,0,nt);
    Gwin=fftshift(fft(pad_trace(gwin,tau)));
    fwin=freqfft(tg,nt);
    
    
    set(hseis,'userdata',{ss,tt,xx,gtool,xtool,tau,twin,tinc,fmin,fmax,df,fshow,sdgath,tgath,fgath})
    xnow=.85;ynow=.85;
%     xnow=xnot+xwid+sep;
    wid=.15;ht=.2;
    ynow=.9-ht;
    htg=uitabgroup('units','normalized','position',[xnow,ynow,wid,ht],'tag','axes');
    hwave=uitab(htg,'title','Window');
    hspec=uitab(htg,'title','Window Spectrum');
    haxw=axes(hwave,'tag','window','units','normalized','position',[.2 .2 .6 .6]);
    plot(tg-t0,gwin);grid
    xtick(twin*(-3:1:3));xlim(twin*[-4 4]);
    set(haxw,'XTickLabelRotation',-90)
    haxws=axes(hspec,'tag','window','units','normalized','position',[.2 .2 .6 .6]);
    plot(fwin,abs(Gwin));grid
    fwid=.5/twin;
    xtick(fwid*(-2:1:2));xlim(fwid*[-3 3]);
    wid=.05;ht=.025;sep=.003;
    ynow=ynow-2*ht;
    uicontrol(hfig,'style','text','string','Twin:','units','normalized','position',[xnow,ynow,wid,ht])
    uicontrol(hfig,'style','edit','string',num2str(twin),'units','normalized','tag','twin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'enable','off');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Tinc:','units','normalized','position',[xnow,ynow,wid,ht])
    uicontrol(hfig,'style','edit','string',num2str(tinc),'units','normalized','tag','tinc',...
        'position',[xnow+wid+sep,ynow,wid,ht],'enable','off');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fshow:','units','normalized','position',[xnow,ynow,wid,ht])
    uicontrol(hfig,'style','edit','string',num2str(fshow),'units','normalized','tag','fshowui',...
        'position',[xnow+wid+sep,ynow,wid,ht],'enable','on');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fmin:','units','normalized','position',[xnow,ynow,wid,ht])
    uicontrol(hfig,'style','edit','string',num2str(fmin),'units','normalized','tag','fmin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'enable','off');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fmax:','units','normalized','position',[xnow,ynow,wid,ht])
    uicontrol(hfig,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'enable','off');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','delF:','units','normalized','position',[xnow,ynow,wid,ht])
    uicontrol(hfig,'style','edit','string',num2str(df),'units','normalized','tag','delf',...
        'position',[xnow+wid+sep,ynow,wid,ht],'enable','off');
    
    xnow=xnot+xwid+sep;
    ynow=ynot;
    %SpecD axes
    hsd=axes(hfig,'units','normalized','position',[xnow,ynow,.1*xwid,yht]);
    ind=near(fgath,fshow);
    it=near(tgath,tt(1),tt(end));
    Sd0=sdgath(it,ind(1));
    Sd=zeros(size(tt));
    h=plot(Sd,tt,Sd0,tt);flipy;
    title(['SpecD f= ' num2str(fshow) ' Hz']);
    set(h(1),'Tag','sd','zdata',ones(size(tt)),'color','r');
    set(h(2),'tag','sd0','color',.5*ones(1,3),'linewidth',2);
%     set(hsd,'yticklabel',[],'xticklabel',[]);
    ylim([tt(1) tt(end)]);
    %gather axes
    hsg=axes(hfig,'units','normalized','position',[xnow+.1*xwid+sep,ynow,.13*xwid,yht]);
    Sg=zeros(length(tt),length(f));
    hi=imagesc(f,tt,Sg);
    title('SpecD Gather')
    set(hsg,'colormap',cmap,'clim',clim);
    set(hsg,'yticklabel',[]);
    xlabel('frequency')
    hi.ButtonDownFcn={@analysisplot,'plotspec'};
    hshow=line(fshow*[1 1],[tt(1) t(end)],'color','r','linestyle','--','linewidth',2,...
        'buttondownfcn',{@analysisplot,'dragline'},'tag','fshow');
%     hcm=uicontextmenu;
%     uimenu(hcm,'Label','Plot spectrum','callback',);
%     hi.ContextMenu=hcm;
    
    %spectra axes
    xnow=.85;ynow=.25;
    wid=.15;ht=.2;
    hspec=axes(hfig,'units','normalized','position',[xnow+.1*wid,ynow,.8*wid,.9*ht]);
    
    htg.UserData=[hseis,hwave,hspec,hsd,hsg,hspec];
    
    bigfig;
    bigfont(hseis,1.25,1)
    

elseif(strcmp(action,'dragline'))
    hfig=gcf;
    hnow=gcbo;
    tag=hnow.Tag;
    
    switch tag
        case '1'
            
            hseis=hnow.Parent;
            ud=hseis.UserData;
            t=ud{2};
            x=ud{3};
            tmin=min(t);
            tmax=max(t);
            tpad=(tmax-tmin)*.01;
            xmin=min(x);
            xmax=max(x);
            xpad=(xmax-xmin)*.01;
            DRAGLINE_CALLBACK={@analysisplot,'snap2grid'};
            DRAGLINE_MOTIONCALLBACK='';
            DRAGLINE_MOTION='free';
            DRAGLINE_YLIMS=[tmin+tpad tmax-tpad];
            DRAGLINE_XLIMS=[xmin+xpad xmax-xpad];
            
            dragline('click')
            
        case 'fshow'
            hsgax=hnow.Parent;
            xl=hsgax.XLim;
            xpad=1;
            DRAGLINE_CALLBACK='';
            DRAGLINE_MOTIONCALLBACK={@analysisplot,'changefshow'};
            DRAGLINE_MOTION='xonly';
            DRAGLINE_YLIMS=[];
            DRAGLINE_XLIMS=[xl(1)+xpad xl(2)-xpad];
            
            dragline('click')
    end
    
elseif(strcmp(action,'snap2grid'))
    hline=gco;
    hseis=gca;
    hfig=gcf;
    xline=hline.XData;
    tline=hline.YData;
    udat=get(hseis,'userdata');
    t=udat{2};
    x=udat{3};
    ix=near(x,xline(1));
    xline=xline-xline(1)+x(ix(1));
    htinc=findobj(hfig,'tag','tinc');
    tinc=str2double(htinc.String);
    t2=t(1):tinc:t(end);
    [~,it]=max(xline);
    t0=tline(it(1));
    it=near(t2,t0);
    t2=t2-t0+t2(it(1));
    hline.XData=xline;
    hline.YData=tline;
    ud=hseis.UserData;
    ud{4}=xline-xline(1);%g
    ud{5}=x(ix(1));%x position
    ud{6}=tline;%tg
    hseis.UserData=ud;
    
    analysisplot('compute');
    
elseif(strcmp(action,'changefshow'))
    hfig=gcf;
    hfshowline=gco;
    htg=findobj(hfig,'tag','axes');
    axs=htg.UserData;
    hsdax=axs(4);
    hsgax=axs(5);
    hspec=axs(6);
    %Get gather
    hi=findobj(hsgax,'type','image');
    Sg=hi.CData;
    f=hi.XData;
    %get the new fshow
    xx=hfshowline.XData;
    tmp=xx(1);
    ishow=near(f,tmp);
    fshow=f(ishow(1));
    %update GUI
    hfshow=findobj(hfig,'tag','fshowui');
    hfshow.String=num2str(fshow);
    %Update Sd axes
    Sd=Sg(:,ishow);
    hsd=findobj(hsdax,'tag','sd');
    hsd.XData=Sd;
    haax=hfig.CurrentAxes;
    hfig.CurrentAxes=hsdax;
    title(['SpecD f= ' num2str(fshow) ' Hz'])
    hfig.CurrentAxes=haax;
    %update spec axes
    hk=hspec.Children;
    if(~isempty(hk))
        hsd=findobj(hspec,'tag','fshowsp');
        hsd.XData=fshow*[1 1];
    end
    
    
    
elseif(strcmp(action,'compute'))
    hfig=gcf;
    htg=findobj(hfig,'tag','axes');
    axs=htg.UserData;
    hseis=axs(1);
    hsdax=axs(4);
    hsgax=axs(5);
    ud=hseis.UserData;
    ss=ud{1};
    t=ud{2};dt=t(2)-t(1);
    x=ud{3};
    g=ud{4};%g is the length of the original seismic so it needs to be shortened to apply
    xt=ud{5};
    tau=ud{6};
    tinc=ud{8};
    kinc=round(tinc/dt);
    fmin=ud{9};fmax=ud{10};df=ud{11};
    f=fmin:df:fmax;
    nf=length(f);
    %Starting at t(1), always calculate from the last done level to the current.
    %determine starting point
    hsd=findobj(hsdax,'tag','sd');%find the sd curve
    Sd=hsd.XData;%the SpecD
    ind=find(Sd==0);
    if(ind(1)==1)
        kstart=ind(1);
    else
        kstart=ind(1)+kinc-1;%starting index
    end
    [~,jnot]=max(g);%loc of max
    tnot=tau(jnot);%current time position of g
    knot=near(t,tnot);%ending index
    hsg=findobj(hsgax,'type','image');
    Sg=hsg.CData;%the gather image
    ixnot=near(x,xt);
    xnot=x(ixnot);%x position of g
    hfshow=findobj(hfig,'tag','fshowui');
    fshow=str2double(hfshow.String);
    ishow=near(f,fshow);
    ishow=ishow(1);
%     kprev=kstart-kinc;
    if(kstart>1)
        if(sum(abs(Sg(kstart-1,:)))==0)
            kprev=kstart-2;
        else
            kprev=kstart-1;
        end
    end
    if(kstart>knot)
        %this means we delete computed samples
       ic=hsd.UserData;%flags computed values
       ind=find(ic==1);
       ind2=near(t(ind),tnot);
       tnot2=t(ind(ind2));
%        knot2=round((tnot2-t(1))/dt)+1;
       knot2=max([round((tnot2-t(1))/dt),1]);
       izero=knot2:kstart;
       Sd(izero)=0;
       ic(izero)=0;
       hsd.XData=Sd;
       hsd.UserData=ic;
       Sg(izero,:)=0;
       hsg.CData=Sg;
       return;
    end
    if(isempty(hsd.UserData))
        ic=zeros(size(Sd));%a flag indicating computed samples
    else
        ic=hsd.UserData;
    end
    for k=kstart:kinc:knot
        %shift g to k by simply changing tau
        ic(k)=1;
        tnotk=t(k);
        tk=tau-tnot+tnotk;
        ind=near(tk,t(1),t(end));
        gg=g(ind)';
        %fourier transform
        [Ss,ff]=fftrl(ss(:,ixnot).*gg,t);
        Asg=interp1(ff,abs(Ss),f)';%gather
        Asd=Asg(ishow(1));%decomp
        Sg(k,:)=Asg;
        if(kinc>1 && k>1)%interpolate
            kk=kprev+1:k-1;
            for j=1:nf
                Sg(kk,j)=interp1([kprev,k],[Sg(kprev,j),Sg(k,j)],kk);
            end
        end
        if(k==1)
            Sd(k)=Sg(k,ishow);
        else
            Sd(kprev+1:k)=Sg(kprev+1:k,ishow);
        end
        kprev=k;
    end

    hsd.XData=Sd;
    hsd.UserData=ic;
    hsg.CData=Sg;
%     clim=[0 max(Sg(:))];
%     set(hsgax,'clim',clim);
%     set(hsdax,'xlim',[0 1.1*max(Sd)])

elseif(strcmp(action,'plotspec'))
    haxe=gca;
    hfig=gcf;
    htg=findobj(hfig,'tag','axes');
    axs=htg.UserData;
    hseis=axs(1);
    hsdax=axs(4);
    hsgax=axs(5);
    hspec=axs(6);
    hi=gco;
    pt=haxe.CurrentPoint;
    fnow=pt(1,1);
    tnow=pt(1,2);
    Sg=hi.CData;
    t=hi.YData;
    f=hi.XData;
    it=near(t,tnow);
    tnow=t(it(1));
    cols=hspec.ColorOrder;
    ud=hspec.UserData;
    if(isempty(ud))
        nl=0;
    else
        nl=length(ud.lines);
    end
    if(nl<size(cols,1))
        ncol=nl+1;
    else
        ncol=nl-size(cols,1)+1;
    end
    hfig.CurrentAxes=hspec;
    h1=line(f,Sg(it,:),'color',cols(ncol,:));
    hfig.CurrentAxes=hsdax;
    xl=xlim;
    h2=line(xl,tnow*[1 1],'color',cols(ncol,:),'linestyle','--');
    hfig.CurrentAxes=hseis;
    xl=xlim;
    h3=line(xl,tnow*[1 1],'color',cols(ncol,:),'linestyle','--');
    hfig.CurrentAxes=hsgax;
    h4=line(pt(1,1),pt(1,2),'color',cols(ncol,:),'linestyle','none','marker','*');
    h1.UserData=[h2 h3 h4];
    h1.ButtonDownFcn={@analysisplot,'delete'};
    xlabel('frequency');
    name=['t= ' time2str(tnow)];
    hfig.CurrentAxes=hspec;
    
    if(isempty(ud))
        ud.lines=h1;
        ud.names={name};
    else
        n=length(ud.lines);
        ud.lines(n+1)=h1;
        ud.names{n+1}=name;
    end
    hspec.UserData=ud;
    legend(ud.lines,ud.names);
    if(nl==0)
       %fshow line
       hshow=findobj(hfig,'tag','fshowui');
       fshow=str2double(hshow.String);
       yl=ylim;
       line(fshow*[1 1],yl,'color','r','linestyle','--','tag','fshowsp');
    else
       hfshow=findobj(hspec,'tag','fshowsp');
       yl=ylim;
       hfshow.YData=yl;
    end


elseif(strcmp(action,'delete'))
    hax=gca;
    ud=hax.UserData;
    h1=gcbo;
    ikill=find(ud.lines==h1);
    ud.lines(ikill)=[];
    ud.names(ikill)=[];
    hax.UserData=ud;
    hh=h1.UserData;
    delete([h1 hh])
end


end

function avespec(~,~)
global NEWFIGVIS
hmasterfig=gcf;

% hgath=findobj(gcf,'tag','sdgather');

hi=gco;
specd=get(hi,'cdata');
t=get(hi,'ydata');
fsd=get(hi,'xdata');

hresults=findobj(gcf,'tag','results');
iresult=get(hresults,'value');
results=hresults.UserData;
dname=['SpecD: ' results.names{iresult}];
NEWFIGVIS='off'; 
datar=specdave(specd,t,fsd,dname); 
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);

%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
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
hseis=findobj(gcf,'tag','seis');
hseissd=findobj(gcf,'tag','seissd');
hgather=findobj(gcf,'tag','sdgather');
name=hseis.Title.String;

hi=gco;
seis=get(hi,'cdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');

if(haxe==hseis)
    x=get(hi,'xdata');
    dname=name;
    %get current point
%     pt=get(haxe,'currentpoint');
    pt=seisplottraces('getlocation',flag);
    ixnow=near(x,pt(1,1));
    xnow=x(ixnow(1));
    dname2=dname;
    mode=1;
elseif(haxe==hseissd)
    x=get(hi,'xdata');
    dname=[name '_SPECD'];
    %get current point
%     pt=get(haxe,'currentpoint');
    pt=seisplottraces('getlocation',flag);
    ixnow=near(x,pt(1,1));
    xnow=x(ixnow(1));
    %get frequency from gather
    hline=findobj(hgather,'tag','2');
    tmp=get(hline,'xdata');
    fnow=tmp(1);
    dname2=[dname ' @f=' num2str(fnow)];
    mode=2;
else
    f=get(hi,'xdata');
    dname=[name '_SPECD_gather'];
    %get current point
%     pt=get(haxe,'currentpoint');
    pt=seisplottraces('getlocation',flag);
    ifnow=near(f,pt(1,1));
    fnow=f(ifnow(1));
    %get xnow from specd
    hline=findobj(hseissd,'tag','1');
    tmp=get(hline,'xdata');
    xnow=tmp(1);
    dname2=[dname ' @x=' num2str(xnow)];
    mode=3;
end

%determine pixels per second
un=get(haxe,'units');
set(gca,'units','pixels');
pos=get(haxe,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(haxe,'units',un);


pos=get(hmasterfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);
switch mode
    case 1
        iuse=ixnow(1);
        seisplottraces(double(seis(:,iuse)),t,xnow,dname2,pixpersec);
    case 2
        iuse=ixnow(1);
        seisplottraces(double(seis(:,iuse)),t,xnow,dname2,pixpersec);
    case 3
        iuse=ifnow(1);
        seisplottraces(double(seis(:,iuse)),t,fnow,dname2,pixpersec);
end
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

%register the figure
seisplottraces('register',hmasterfig,hfig);

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.8,.930,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function RGB(~,~)
global NEWFIGVIS
hmasterfig=gcf;
hseis=findobj(hmasterfig,'tag','seis');
cmap=get(hseis,'colormap');
pos=get(hmasterfig,'position');
% hseis2=findobj(gcf,'tag','seis2');
hi=findobj(hseis,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
y=get(hi,'ydata');
dname=hseis.Title.String;

%get the specd
hresults=findobj(gcf,'tag','results');
iresult=get(hresults,'value');
results=hresults.UserData;
specd=results.data{iresult};
f=results.fsds{iresult};
specname=['SpecD: ' results.names{iresult}];
f1=10;f2=20;f3=30;
i1=near(f,f1);i2=near(f,f2);i3=near(f,f3);
frgb=[f(i1(1)) f(i2(1)) f(i3(1))];
units='Hz';
xdir=hseis.XDir;
ydir=hseis.YDir;
NEWFIGVIS='off'; 
datar=seisplot_RGB(seis,y,x,specd,f,dname,specname,frgb,units,xdir,ydir);
xlbl=hseis.XLabel.String;
ylbl='time (ms)';
for k=1:5
    datar{k}.XLabel.String=xlbl;
    datar{k}.YLabel.String=ylbl;
end
colormap(datar{1},cmap);
NEWFIGVIS='on';
hfig=gcf;
pos2=hfig.Position;
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);
pos2(1:2)=[xc-.5*pos2(3) yc-.5*pos2(4)];
% customizetoolbar(hfig);
set(hfig,'position',pos2,'visible','on')
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance','userdata',henhance);
    hppt=addpptbutton([.92,.95,.05,.025]);
    set(hppt,'userdata',get(hfig,'name'));
end
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.92,.924,.05,.025]);
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
hresults.FontSize=scalar*fs;
end

function retitle(~,~)
hresults=findobj(gcf,'tag','results');
iresult=hresults.Value;
names=hresults.String;
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
        hresults.String=names;
        results.names{1}=names;
    else
        names{iresult}=a{1};
        hresults.String=names;
        results.names{iresult}=names{iresult};
    end
    hresults.UserData=results;
end
    
end


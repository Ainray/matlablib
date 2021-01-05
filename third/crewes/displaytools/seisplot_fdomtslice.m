function datar=seisplot_fdomtslice(slices,t,x,y,dname)
% seisplot_fdomtslice: Interactactive dominant freqeuncy computation on time slices
%
% datar=seisplot_fdomtslice(slices,t,x,y,dname)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The input seismic
% volume is displayed in the left-hand-side and the corresponding dominant frequency volume is shown
% the the right-hand side. Initial fdom parameters come either from internal defaults or global
% variables. Controls are provided to explore both volumes and to compute new fdom volumes with
% different parameters.
%
% slices ... 3D seismic matrix of time slices, should be short in the first dimension (time)
% t ... first dimension (time) coordinate vector for slices
% x ... second dimension (xline) coordinate vector for slices
% y ... third dimension (inline) coordinate vector for slices
% dname ... text string nameing the slices matrix.
%   *********** default = 'Input data' **************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the input seismic axes
%           data{2} ... handle of the fdom axes
% These return data are provided to simplify plotting additional lines and text in either axes.
% 
% NOTE: The key parameters for the dominant frequency computation are twin, tinc, fmax, and tfmax
% and the starting values for these can be controlled by defining the global variables below. These
% globals have names that are all caps. The default value applies when the corresponding global is
% either undefined or empty.
% FDOM_TWIN ... half-width of the Gaussian windows (standard deviation) in seconds
%  ************ default = 0.01 seconds ************
% FDOM_TINC ... increment between adjacent Gaussians
%  ************ default = 2*dt seconds (dt is the time sample size of the data) ***********
% FDOM_FMAX ... maximum signal frequency in the dataset. specified at the reference time  (in Hertz)
%  ************ default 0.25/dt Hz which is 1/2 of Nyquist *************
% FDOM_TFMAX ... reference time at which FDOM_FMAX is specified (in seconds)
% ************* default mean(t) seconds ***************
%
% 
% G.F. Margrave, CREWES, 2018
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

global FDOM_TWIN FDOM_TINC FDOM_FMAX FDOM_TFMAX
global NEWFIGVIS WaitBarContinue XCFIG YCFIG BIGFIG_WIDTH BIGFIG_HEIGHT  %#ok<NUSED>
if(~ischar(slices))
    action='init';
else
    action=slices;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(nargin<4)
        error('at least 4 inputs are required');
    end
    if(nargin<5)
        dname='Input data';
    end
    
%     x2=x1;
%     t2=t1;
    dt=t(2)-t(1);
    fnyq=.5/dt;
    if(isempty(FDOM_FMAX))
        fmax=round(.25*fnyq);
    else
        fmax=FDOM_FMAX;
    end
    if(isempty(FDOM_TFMAX))
        tfmax=mean(t);
    else
        tfmax=FDOM_TFMAX;
    end
    if(isempty(FDOM_TWIN))
        twin=0.01;
    else
        twin=FDOM_TWIN;
    end
    if(isempty(FDOM_TINC))
        tinc=2*dt;
    else
        tinc=FDOM_TINC;
    end

    
    if(length(t)~=size(slices,1))
        error('time coordinate vector does not match time slices matrix');
    end
    if(length(x)~=size(slices,2))
        error('xline coordinate vector does not match time slices matrix');
    end
    if(length(y)~=size(slices,3))
        error('inline coordinate vector does not match time slices matrix');
    end
    [nt,nx,ny]=size(slices); %#ok<ASGLU>
    
    if(iscell(dname))
        dname=dname{1};
    end

    xwid=.35;
    yht=.8;
    xsep=.05;
    xnot=.11;
    ynot=.1;
    
    %test to see if we are from enhance. This enables the fromenhance local logical function to work
    ff=figs;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           %so the current figure is from enhance and we assume it has called this one
           enhancetag='fromenhance';
           udat={-999.25,gcf};
       else
           enhancetag='';
           udat=[];
       end
    end

%     if(~isempty(NEWFIGVIS))
%         figure('visible',NEWFIGVIS);
%     else
%         figure
%     end
    if(~isempty(XCFIG))
        if(isempty(BIGFIG_WIDTH))
            figwid=1900;
            fight=900;
        else
            figwid=BIGFIG_WIDTH;
            fight=BIGFIG_HEIGHT;
        end
        figx=XCFIG-.5*figwid;
        figy=YCFIG-.5*fight;
        figure('position',[figx,figy,figwid,fight]);
    else
        figure;
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat);
    
    hax1=subplot('position',[xnot ynot xwid yht]);

    inot=near(t,t(round(nt/2)));
    inot=inot(1);
    seis1=squeeze(slices(inot,:,:))';
        
    hi=imagesc(x,y,seis1);
    hcm=uicontextmenu;
    uimenu(hcm,'label','2D Spectrum','callback',@spec2d); 
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap);
    brighten(.5);
    grid
    ht=title({dname,['time= ' time2str(t(inot))]});
    ht.Interpreter='none';
    xlabel('crossline')
    ylabel('inline')
    


    %make a clip control
    wid=.055;ht=.05;sep=.005;  
    xnow=xnot-1.85*wid;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    climxt=[-3 3];
    hclip1=uipanel(hfig,'position',[xnow,ynow,1.45*wid,htclip],'tag','clip1',...
        'userdata',{climxt,hax1},'title','Clipping');
    data={climxt,hax1};
    callback='';
    cliptool(hclip1,data,callback);
    hfig.CurrentAxes=hax1;
%     uicontrol(hfig,'style','popupmenu','string',clipstr,'tag','clip1','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplot_fdomtslice(''clip1'')','value',iclip,...
%         'userdata',{clips,am,sigma,amax,amin,hax1,[]},'tooltipstring',...
%         'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    ht=.5*ht;
%     ynow=ynow-sep;
%     ilive=seis1~=0;
%     uicontrol(hfig,'style','radiobutton','string','Auto adjust clip','tag','autoclip1','units','normalized',...
%         'position',[xnow,ynow,1.5*wid,ht],'value',0,'userdata',ilive,...
%         'tooltipstring','clip level auto adjusted with each time slice')
     
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+5.5*ht,.5*wid,ht],'callback','seisplot_fdomtslice(''info'');',...
        'backgroundcolor','y');
    
    set(hax1,'tag','seis1');
    
    %time location thermometer
%     xnow=xnow+.25*wid;
    xnow=xnow+.25*wid-sep;
    widtherm=.9*wid;
    httherm=16*ht;
    ytherm=ynow-ht-httherm;
    htherm=uithermometer(hfig,[xnow,ytherm,widtherm,httherm],'Time slice',t,30,'seisplot_fdomtslice(''jump'');');
    set(htherm,'tag','thermt');
    
    %prev and next buttons
    ynow=ytherm-5*sep;
    %prev and next buttons
    wid=.055;ht=.05;sep=.005;
    
%     xnow=xnot+xwid+sep;
    uicontrol(hfig,'style','pushbutton','string','Lesser time','tag','prev','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_fdomtslice(''step'');',...
        'tooltipstring','Step to lesser time');
    ynow=ynow-.5*ht;
    uicontrol(hfig,'style','pushbutton','string','Greater time','tag','next','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_fdomtslice(''step'');',...
        'tooltipstring','Step to greater time','userdata',{slices,t,x,y,dname,inot});
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);

    xlabel('line coordinate')
    
    
    %make a clip control
    xnow=xnot+2*xwid+xsep+sep;
    wid=.055;ht=.05;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    climafd=[-.5 3];
    hclip2=uipanel(hfig,'position',[xnow,ynow,2*wid,htclip],'tag','clip2',...
        'userdata',{[],hax2,[],[],climafd,[]},'title','Clipping');
    %userdata is {currentclim,axes,climfd,climbw,climafd,sigma_afd}
    data={[0 100],hax2,[],0,1,1};
    callback='seisplot_fdomtslice(''clip2'');';
%     cliptool(hclip2,data,callback);
    hfig.CurrentAxes=hax2;

%     uicontrol(hfig,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplot_fdomtslice(''clip2'');','value',iclip,...
%         'userdata',{clips,am,sigma,amax,amin,hax2,[]},'tooltipstring',...%the values here in userdata are placeholders. See 'computefdom' for the real thing
%         'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    ht=.5*ht;
    ynow=ynow-sep;
%     %ynow=ynow-ht;
%     uicontrol(hfig,'style','radiobutton','string','Auto adjust clip','tag','autoclip2','units','normalized',...
%         'position',[xnow,ynow,1.5*wid,ht],'value',0,'userdata',ilive,...
%         'tooltipstring','clip level auto adjusted with each time slice')
    %controls to choose the dominant frequency display section 
    ynow=ynow-3*ht-sep;
    hbg=uibuttongroup('position',[xnow,ynow,1.5*wid,3*ht],'title','Display choice','tag','choices',...
        'selectionchangedfcn','seisplot_fdomtslice(''choice'');');
    ww=1;
    hh=.333;
    uicontrol(hbg,'style','radiobutton','string','Dom. Freq.','units','normalized','tag','freq',...
        'position',[0,2*hh,ww,hh],'value',1,'tooltipstring','Display dominant frequency');
    uicontrol(hbg,'style','radiobutton','string','Bandwidth','units','normalized','tag','bw',...
        'position',[0,hh,ww,hh],'value',0,'tooltipstring','Display bandwidth about dominant frequency');
    uicontrol(hbg,'style','radiobutton','string','Amp at Fdom','units','normalized','tag','amp',...
        'position',[0,0,ww,hh],'value',0,'tooltipstring','Display amplitude at dominant frequency');
    
    %fdom parameters
    ht=.025;
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fdom parameters:','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'tooltipstring','Change these values and then click "Compute Fdom"');
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
    uicontrol(hfig,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Maximum frequency of interest at time Tfmax');
    uicontrol(hfig,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Tfmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Reference time at which Fmax applies');
    uicontrol(hfig,'style','edit','string',num2str(tfmax),'units','normalized','tag','tfmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Compute Fdom','units','normalized',...
        'position',[xnow,ynow,3*wid,ht],'callback','seisplot_fdomtslice(''computefdom'');',...
        'tooltipstring','Compute Fdom with current parameters','tag','fdombutton',...
        'backgroundcolor','y');
    
    %colormaps
    ynow=.3;
    pos=[xnow,ynow,2.5*wid,8*ht];
    cb1='';cb2='';
    cmapdefaults=cell(1,2);
    cmapdefaults{1}=enhance('getdefaultcolormap','timeslices');
    cmapdefaults{2}=enhance('getdefaultcolormap','frequencies');
    cmapdefaults{3}=enhance('getdefaultcolormap','ampspectra');
    cm1=cmapdefaults{1}{1};
    iflip1=cmapdefaults{1}{2};
    cm2=cmapdefaults{2}{1};
    iflip2=cmapdefaults{2}{2};
    cbflag=[0,1];
    cbcb='';
    cbaxe=[hax1,hax2];
    hcpan=enhancecolormaptool(hfig,pos,hax1,hax2,cb1,cb2,cm1,cm2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    set(hcpan,'userdata',cmapdefaults);
    
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(hfig,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplot_fdomtslice(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplot_fdomtslice(''equalzoom'');');
    
    %results popup
%     wida=.065;
    xnow=pos(1);
    ynow=pos(2)+pos(4)-ht;
    wid2=pos(3);
    ht=3*ht;
    fs=10;
    fontops={'x2','x1.5','x1.25','x1.11','x1','x0.9','x0.8','x0.67','x0.5'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange,'userdata',hax2);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
    uicontrol(hfig,'style','popupmenu','string','...','units','normalized','tag','results',...
        'position',[xnow,ynow,wid2,ht],'callback','seisplot_fdomtslice(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm);
    
    %delete button
    wid=.075;
    xnow=pos(1)+pos(3)+sep;
    ht=ht/3;
    ynow=ynow+2.5*ht;
    %userdata of the delete button is the number of the current selection
    uicontrol(hfig,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnow,ynow-.75*ht,wid,ht],'callback','seisplot_fdomtslice(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
    
    %fire up clip tool
    cliptool(hclip2,data,callback);
    
    set(hax2,'tag','seis2');
    seisplot_fdomtslice('computefdom');
    set(hfig,'name',['Dominant frequency for ' dname ],...
        'closerequestfcn','seisplot_fdomtslice(''close'');','menubar','none','toolbar',...
        'figure','numbertitle','off');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
elseif(strcmp(action,'choice'))
    hfig=gcf;
    hchoice=findobj(hfig,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    hnext=findobj(hfig,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    hresults=findobj(hfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hseis2=findobj(hfig,'tag','seis2');
    hclip2=findobj(hfig,'tag','clip2');
    ud=hclip2.UserData;
    sigma=ud{6};
    switch choice
        case 'freq'
            i4=1;
            clim=results.climfd{iresult};
            climdata={clim,hseis2,1,0,1,1};
            set(hchoice,'userdata',1)
        case 'bw'
            i4=3;
            clim=results.climbw{iresult};
            climdata={clim,hseis2,1,0,1,1};
            set(hchoice,'userdata',2)
        case 'amp'
            i4=2;
            clim=results.climafd{iresult};
            climdata={clim,hseis2,sigma,0,1,1};
            set(hchoice,'userdata',0)
    end
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    ud{1}=clim;
    cliptool('refresh',hclip2,climdata);
    hclip2.UserData=ud;
    seisplot_fdomtslice('setcolormap','seis2');
    showcolormap;
% elseif(strcmp(action,'clip1'))
%     hmasterfig=gcf;
%     hclip=findobj(hmasterfig,'tag','clip1');
%     udat=get(hclip,'userdata');

    
% elseif(strcmp(action,'autoclip1'))
%     hfig=gcf;
    
elseif(strcmp(action,'clip2'))
    hmasterfig=gcf;
    hclip=findobj(hmasterfig,'tag','clip2');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    udat{1}=clim;

    hresults=findobj(hmasterfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults','value');
    choice=nowshowing;
    if(~isempty(results))
        switch choice
            case 'freq'
                results.climfd{iresult}=clim;
            case 'bw'
                results.climbw{iresult}=clim;
            case 'amp'
                results.climafd{iresult}=clim;
        end
        set(hresults,'userdata',results);
    end

    hclip.UserData=udat;

% elseif(strcmp(action,'autoclip2'))
%     hfig=gcf;
        
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

elseif(strcmp(action,'step'))
    %activated by the 'Lesser time' and 'Greater time' buttons
    hmasterfig=gcf;
    hbut=gcbo;
    step='d';
    if(strcmp(get(hbut,'tag'),'prev'))
        step='u';
    end
    %step the seismic
    hseis1=findobj(hmasterfig,'tag','seis1');
    hnext=findobj(hmasterfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    inot=udat{6};
    if(step=='u')
        inot=max([1,inot-1]);
    else
        inot=min([length(t),inot+1]);
    end
    udat{6}=inot;
    set(hnext,'userdata',udat);
    tnot=t(inot);
    ht=hseis1.Title.String;
    ht{2}=['time= ' time2str(tnot)];
    hseis1.Title.String=ht;
    seis1=squeeze(slices(inot,:,:))';
    hi=findobj(hseis1,'type','image');
    hi.CData=seis1;
    %update cliptool
    hclip1=findobj(hmasterfig,'tag','clip1');
    uc=get(hclip1,'userdata');
    clim=uc{1};
    clipdata={clim,hseis1};
    cliptool('refresh',hclip1,clipdata);
    %step the fdom
    hseis2=findobj(hmasterfig,'tag','seis2');
    %determine the display choice
    hchoice=findobj(hmasterfig,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    hclip2=findobj(hmasterfig,'tag','clip2');
    uc=get(hclip2,'userdata');
    clim=uc{1};
    switch choice
        case 'freq'
            i4=1;
            clipdata={clim,hseis2,1,0,1,1};
        case 'bw'
            i4=3;
            clipdata={clim,hseis2,1,0,1,1};
        case 'amp'
            i4=2;
            clipdata={clim,hseis2,uc{6},0,1,1};
    end
    hresults=findobj(hmasterfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update cliptool
    cliptool('refresh',hclip2,clipdata);
    %update thermometer
    hthermt=findobj(hmasterfig,'tag','thermt');
    uithermometer('set',hthermt,tnot);
elseif(strcmp(action,'jump'))
    %activated by the '^' and 'v' buttons 
    hmasterfig=gcf;
    hbut=gcbo;
    tnot=get(hbut,'userdata');
    %step the seismic
    hseis1=findobj(hmasterfig,'tag','seis1');
    hnext=findobj(hmasterfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    dt=abs(t(2)-t(1));
    inot=round((tnot-t(1))/dt)+1;
    udat{6}=inot;
    set(hnext,'userdata',udat);
    ht=hseis1.Title.String;
    ht{2}=['time= ' time2str(tnot)];
    hseis1.Title.String=ht;
    seis1=squeeze(slices(inot,:,:))';
    hi=findobj(hseis1,'type','image');
    hi.CData=seis1;
    %update cliptool
    hclip1=findobj(hmasterfig,'tag','clip1');
    uc=get(hclip1,'userdata');
    clim=uc{1};
    clipdata={clim,hseis1};
    cliptool('refresh',hclip1,clipdata);
    %step the fdom
    hseis2=findobj(hmasterfig,'tag','seis2');
    %determine the display choice
    hchoice=findobj(hmasterfig,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    hclip2=findobj(hmasterfig,'tag','clip2');
    uc=get(hclip2,'userdata');
    clim=uc{1};
    switch choice
        case 'freq'
            i4=1;
            clipdata={clim,hseis2,1,0,1,1};
        case 'bw'
            i4=3;
            clipdata={clim,hseis2,1,0,1,1};
        case 'amp'
            i4=2;
            clipdata={clim,hseis2,uc{6},0,1,1};
    end
    hresults=findobj(hmasterfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update cliptool
    cliptool('refresh',hclip2,clipdata);

elseif(strcmp(action,'computefdom'))
    %plan: apply the fdom parameters and display the results
    hfig=gcf;
    hseis2=findobj(hfig,'tag','seis2');
    hnext=findobj(hfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    x=udat{3};
    y=udat{4};
    %dname=udat{5};
    inot=udat{6};
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
        msgbox({'Twin is unreasonable, must be positive and less than (Tmax-Tmin)/4',['Here Tmax= ' ...
            num2str(tmax) ', and Tmin= ' num2str(tmin) '.'],'You chose these values when you launched this tool.'});
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
    %get fmax
    hobj=findobj(gcf,'tag','fmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        msgbox('Fmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmax<0 || fmax>fnyq)
        if((fmax-fnyq)>10000*eps)
            msgbox(['Fmax must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
            return;
        else
            fmax=fnyq;
        end
    end
    %get tfmax
    hobj=findobj(gcf,'tag','tfmax');
    val=get(hobj,'string');
    tfmax=str2double(val);
    if(isnan(tfmax))
        msgbox('tfmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(tfmax<t(1) || tfmax>t(end))
        msgbox('tfmax must be greater than t(1) and less than t(end)','Oh oh ...');
        return;
    end
    
    %compute fdom
    t0=clock;
    ievery=1;
    nt=length(t);
    ny=length(y);
    nx=length(x);
    fdom=zeros(nt,nx,ny,3);%In the 4th dim, 1 is fd, 2 is afd, 3 is bwfd
    if(isempty(XCFIG))
       posw=[400 100];
    else
       posw=[XCFIG-200,YCFIG-50,400,100];
    end
    hbar=WaitBar(0,ny,'Fdom computation','Computing dominant frequency',posw);
    for k=1:ny %loop over inlines
        s2d=squeeze(slices(:,:,k));
        if(sum(abs(s2d(:)))>0) %avoid all zeros s2d
            [fd,afd,bwfd]=tv_afdom(s2d,t,twin,tinc,[fmax tfmax],1,2,1);
            %Accumulate results
            fdom(:,:,k,1)=fd;
            fdom(:,:,k,2)=afd;
            fdom(:,:,k,3)=bwfd;
            if(rem(k,ievery)==0)
                time_used=etime(clock,t0);
                time_per_line=time_used/k;
                timeleft=(ny-k-1)*time_per_line/60;
                timeleft=round(100*timeleft)/100;
                WaitBar(k,hbar,['Estimated time remaining ' num2str(timeleft) ' minutes']);
            end
            if(~WaitBarContinue)
                break;
            end
        end
    end
    delete(hbar);
    set(hfig,'currentaxes',hseis2)
    %get the current display choice
    hchoice=findobj(gcf,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    switch choice
        case 'freq'
            i4=1;
        case 'bw'
            i4=3;
        case 'amp'
            i4=2;
    end
    seis2=squeeze(fdom(inot,:,:,i4))';
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    hi=imagesc(x,y,seis2);
    hcm=uicontextmenu;
    uimenu(hcm,'label','2D Spectrum','callback',@spec2d);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap);
    xlabel('crossline');ylabel('inline');
    name=['Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ...
        ', Fmax= ', num2str(fmax) ', Tfmax= ', num2str(tfmax)];
    set(hseis2,'tag','seis2','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    %choose 10 time slices
    nr=min([10 nt]);
    irt=randi(nt,nr);
    
    %calculate 3 different clipdata
    hclip2=findobj(hfig,'tag','clip2');
    udat=hclip2.UserData;
    climfd=[0 round(.8*max(fd(:)))];
    climbw=[0 round(.8*max(bwfd(:)))];
    udat{3}=climfd;
    udat{4}=climbw;
    for j=1:3
        A=squeeze(fdom(irt,:,:,j));
        inz=A~=0;
%         [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(A(:));
        if(j==1)
            %frequency
            [N,xn]=hist(A(inz),400); %#ok<*HIST>
            thresh=max([10,.01*max(N)]);
            ind=find(N>thresh);
            clim1=[xn(ind(1)) xn(ind(end))];
%             clim1=[round(.8*min(A(inz))) round(.8*max(A(inz)))];
            udat{3}=clim1;
            if(j==i4) %test for display choice
                clipdata={clim1,hseis2,1,0,1,1};
            end
        elseif(j==2)
            %amp
            sigma=std(A(:));
            clim2=udat{5};
            udat{6}=sigma;
            if(j==i4)%test for display choice
                clipdata={clim2,hseis2,sigma,0,1,1};
            end
        elseif(j==3)
            %bandwidth
            [N,xn]=hist(A(inz),400); %#ok<*HIST>
            thresh=max([10,.01*max(N)]);
            ind=find(N>thresh);
            clim3=[xn(ind(1)) xn(ind(end))];
%             clim3=[round(.8*min(A(inz))) round(.8*max(A(inz)))];
            udat{4}=clim3;
            if(j==i4)%test for display choice
                clipdata={clim3,hseis2,1,0,1,1};
            end
        end
        if(j==i4) %this is the display choice
            udat{1}=clipdata{1};
            cliptool('refresh',hclip2,clipdata);
        end
    end
    hclip2.UserData=udat;
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.data={fdom};
        results.twins={twin};
        results.tincs={tinc};
        results.fmaxs={fmax};
        results.tfmaxs={tfmax};
        results.climfd={clim1};
        results.climafd={clim2};
        results.climbw={clim3};
        results.sigma={sigma};%this is just for amplitude
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.data{nresults}=fdom;
        results.twins{nresults}=twin;
        results.tincs{nresults}=tinc;
        results.fmaxs{nresults}=fmax;
        results.tfmaxs{nresults}=tfmax;
        results.climfd{nresults}=clim1;
        results.climafd{nresults}=clim2;
        results.climbw{nresults}=clim3;
        results.sigma{nresults}=sigma;%this is just for amplitude
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hcompute=findobj(hfig,'tag','fdombutton');
    set(hcompute,'userdata',nresults);%the current result number stored here
    enhancecolormaptool('setcmap',hseis2);

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
    seisplot_fdomtslice('select');
elseif(strcmp(action,'select'))
    hfig=gcf;
    hdelete=findobj(hfig,'tag','delete');
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    hcompute=findobj(hfig,'tag','fdombutton');
    set(hcompute,'userdata',iresult);
    hseis2=findobj(hfig,'tag','seis2');
    hop=findobj(hfig,'tag','twin');
    set(hop,'string',num2str(results.twins{iresult}));
    hstab=findobj(hfig,'tag','tinc');
    set(hstab,'string',num2str(results.tincs{iresult}));
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(results.fmaxs{iresult}));
    htfmax=findobj(hfig,'tag','tfmax');
    set(htfmax,'string',num2str(results.tfmaxs{iresult}));
    %get the proper time slice
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %determine the display choice
    hchoice=findobj(gcf,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    hclip2=findobj(gcf,'tag','clip2');
    udat=hclip2.UserData;
    switch choice
        case 'freq'
            i4=1;
            clim=results.climfd{iresult};
            sigma=1;
        case 'bw'
            i4=3;
            clim=results.climbw{iresult};
            sigma=1;
        case 'amp'
            i4=2;
            clim=results.climafd{iresult};
            sigma=results.sigma{iresult};
    end
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    %update image
    hi=findobj(hseis2,'type','image');
    hi.CData=seis2;
    %update cliptool
    clipdata={clim,hseis2,sigma,0,1,1};
    cliptool('refresh',hclip2,clipdata);
    udat{6}=results.sigma{iresult};
    hclip2.UserData=udat;
    %update hdelete userdata
    set(hdelete,'userdata',iresult);

elseif(strcmp(action,'setcolormap'))
    % call seisplotfdom('setcolormap',axetag)
    %this is called when a section choice is made or at init
    %the assigned colormap is determined by userdata of hcmap
    %If the axis is 'seis' then the section colormap is default. If the axis is 'seisfd', then
    %the colormap depends on the selected button in hchoices
    hfig=gcf;
    hcpan=findobj(hfig,'tag','colorpanel');
%     cmaps=hcpan.String;
    cmapchoices=hcpan.UserData;
    hchoices=findobj(gcf,'tag','choices');
    axetag=t;%second argument
    hax=findobj(hfig,'tag',axetag);
    if(strcmp(axetag,'seis1'))
        cmapname=cmapchoices{1}{1};
        iflip=cmapchoices{1}{2};
    elseif(strcmp(hchoices.SelectedObject.Tag,'amp'))
        cmapname=cmapchoices{3}{1};
        iflip=cmapchoices{3}{2};
    else
        cmapname=cmapchoices{2}{1};
        iflip=cmapchoices{2}{2};
    end
    enhancecolormaptool('setcmap',hax,cmapname,iflip);
    
elseif(strcmp(action,'close'))
    hfig=gcf;
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    delete(hspecwin);
    hi=findobj(hfig,'tag','info');
    hinfo=get(hi,'userdata');
    if(isgraphics(hinfo))
        delete(hinfo);
    end
        tmp=get(hfig,'userdata');
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
elseif(strcmp(action,'info'))
    hi=gcbo;
    msg0={'Dominant Frequency',{['Most geophysicists are well acquainted with the concept of the ',...
        'frequency spectrum but, when asked to define "dominant frequency" most will say it''s the ',...
        'maximum peak in the spectrum. That certainly is an important element of the spectrum but the ',...
        'dominant frequency actually has a more generalized mathematical definition. Let "f" denote ',...
        'frequency and "A(f)" denote the amplitude spectrum. Then the dominant frequency is defined as ',...
        'fdom=sum(f*A^2)/sum(A^2). Let''s dissect that cryptic formula. The word "sum" simply means add up ',...
        'possible values. Since we are speaking of the spectrum of sampled data, then this is a sum ',...
        'from 0 Hz to the Nyquist frequency. The denominator of the formula, sum(A^2) means sum up the ',...
        'squared values of the amplitude spectrum (you might know that A^2 is also called the power ',...
        'spectrum). Then the numerator, sum(f*A^2), means sum up the product of f times A^2. This can ',...
        'be viewed as forming a weighted average of "f" where the weights are A^2. The denominator of ',...
        'the formula is just what is needed to ensure we get an answer in Hertz. '],' ',...
        ['There is some arbitrariness in the formula. Why use A^2? Why not A" or A^3?. Numerical experiments ',...
        'performed on synthetic data have led to a preference for A^2 because it most often agrees with ',...
        'intuition. Imagine a synthetic trace with a Ricker wavelet and additive noise. The Ricker means ',...
        'that the spectrum will have a single peak and we would like that fdom comes close to choosing ',...
        'this peak. Any of the 3 mentioned weights (A,A^2,and A^3) work well without noise but with ',...
        'reasonable noise levels, A^2 seems to work better. This is still a subjective choice ',...
        'but it is what this software does. '],' ',...
        ['To compute an entire section of dominant frequency values, a Gabor transform can be used. This ',...
        'is just a Fourier transform computed repeatedly in a moving temporal window. This window is ',... 
        'a Gaussian whose half-width is the parameter "Twin" seen at the far right. For definiteness, '...
        'suppose Twin is 10ms and the window is initially centered at t=0. The product of window and trace ',...
        'selects the samples at the beginning of the trace and the corresponding spectrum is "local" to ',...
        'to that time. Now increment the window by say 2 samples (4ms for most data) compute the spectrum ',...
        'again. Repeat this process until a local spectrum has been defined for every 4ms along the entire ',...
        'trace. Then use these local spectra to compute the dominate frequency and, repeating this for every trace, we have an fdom section. '],...
        ' ',['The sample amplitudes of an fdom section are values in Hertz and give the local dominant frequency at ',...
        'each position. An fdom section is not very sensitive to the amplitude balancing of the dataset ',...
        'because the definition of fdom has A^2 contributing equally in numerator and denominator. When ',...
        'Twin is chosen quite small, perhaps 2 to 5 samples, then the fdom section shows a great deal ',...
        'of stratigraphic influence. This can be thought of as a generalized way to examine tuning. ',...
        'When the window is 10 to 20 times longer, then the stratigraphic information is mostly ',...
        'suppressed and the influences of attenuation, focussing, defocussing, and other wave propagation ',...
        'effects are seen. You should examine both extremes of window width.'],' ',...
        ['Two other related sections can be exmined here. The first is bandwidth ',...
        'and the second is (spectral) amplitude. Bandwidth is defined as BW=sum(|f-fdom|*A^2)/sum(A^2) and is a measure ',...
        'of spectral width about fdom. (Here the vertical bars, |x|, mean the absolute value of x.)',...
        'Amplitude, really dominant amplitude, is the actual spectral amplitude at the dominant frequency. ',...
        'Bandwidth sections tend to look a lot like fdom sections. Dominant amplitude sections tend to look like a ',...
        'frequency slice from a spectral decomposition, but rather than being a slice at a constant frequency, ',...
        'it is evaluated at the dominant frequency at each point.']}};
    msg1={'Tool layout',{['The axes at left (the seismic axes) shows the input sesimic and the axes at right ',...
        '(Fdom axes) shows any of three dominant frequency attributes. Both axes are showing the ',...
        'same time slice and controls to change the time are just to the right of the seismic axes. ',...
        'There are two buttons labelled "Next lesser time" and "Next deeper time" that step one time sample ',...
        'in either direction. Above these buttons is a tall rectangle labeled "Time slice" that ',...
        'enables a quick jump to any of 30 positions within the set of time slices. Hover the mouse over ',...
        'one of the tiny buttons and you will see the time for that button. Pressing the button ',...
        'gets you there. Within this rectangle at the bottom are buttons to step up or down ',...
        'through the 30 jump points.'],[],...
        ['To the right of the Fdom axes are controls to choose the Fdom attribute to display and ',...
        'to change the Fdom computation.  The three Fdom attributes are (1) "Dom. Freq." in which ',...
        ' the ampltude is the numerical value of the dominant frequency in Hz, (2) "Bandwidth" in ',...
        'which the amplitude is the numerical value of the bandwidth in Hz and centered at the ',...
        'dominant frequency, and (3) "Amp at Fdom" where the amplitude is the value of the amplitude ',...
        'spectrum at the dominant frequency. The third attribute is closely related to a spectral ',...
        'decomposition.'],[],['If you change one of the four Fdom parameters, you can then push ',...
        '"Compute Fdom" to compute a new Fdom result. The previous result remains in memory and ',...
        'can be returned to by simply using the popup menu above the Fdom axes. You can have any ',...
        'number of results in memory at the same time. The most important parameters are Twin, which ',...
        'is the halfwidth of the Gaussian time window that "localizes" the computation, and "Tinc", ',...
        'which is the separation between adjacent window centers. Making these smaller causes the ',...
        'computation to be more local but also reduces the resolution of the frequency spectrum which ',...
        'makes the Fdom values less distinct. Tinc should be no larger than Twin and preferably smaller.'],[],...
        ['The colormap tool is easy to figure out and can assign one ',...
        'of a list of pre-built colormaps to either axis. The colormaps that do not have a central discontinuity ',...
        'tend to work best to display dominant frequency attributes. This is because Fdom is always positive ',...
        'and does not have zero crossings, and the same is true for the other attributes. ',...
        'Examples of good colormaps for this are seisclrs, blueblack, '...
        'greenblack, jet, parula, copper, bone, gray, and winter. Colormaps with a central discontinuity ',...
        'are most useful for data with both positive and negative values where the 0 value is ',...
        'important to discern. Examples of such colormaps are bluebrown, bluered2, bluered3, greenblue, ',...
        'and greenblue. These work best in the seismic axes.'],[],...
        ['The clipping controls have a strong effect on what you see. If you choose a numeric ',...
        'clipping level, x, then the colorbar stretches from -x*sigma to +x*sigma centered at the data ',...
        'mean value. Here x is the clip number and sigma is the standard deviation of the data. ',...
        'For more control, choose "graphical" instead of a numerical value and a small window will ',...
        'appear showing an amplitude histogram and two red lines. The colorbar stretchs between ',...
        'these lines. You can click and drag these lines as desired. ']}};
    hinfo=showinfo({msg0 msg1},'Dominant Frequency on time slices',nan,[600 400],[4 3]);
    ud=get(hi,'userdata');
    if(isgraphics(ud))
        delete(ud);
    end
    set(hi,'userdata',hinfo);
end
end

%% functions

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


function spec2d(~,~)
global NEWFIGVIS
hmasterfig=gcf;
pos=get(hmasterfig,'position');
hseis2=findobj(gcf,'tag','seis2');
cmap=get(hmasterfig.CurrentAxes,'colormap');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
y=get(hi,'ydata');
dx=abs(x(2)-x(1));
dy=abs(y(2)-y(1));
kymax=.5/(y(2)-y(1));
haxe=get(hi,'parent');
ydir=get(haxe,'ydir');
hresults=findobj(gcf,'tag','results');
idata=get(hresults,'value');
dnames=get(hresults,'string');
if(haxe==hseis2)
    dname=dnames{idata};
else
    dname=haxe.Title.String;
    if(iscell(dname))
        dname=dname{1};
    end
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfk(seis,y,x,dname,kymax,dx,dy,2);
datar{1}.XLabel.String=hseis2.XLabel.String;
datar{1}.YLabel.String=hseis2.YLabel.String;
datar{1}.YDir=ydir;
colormap(datar{1},cmap);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on');
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
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dnames{idata});
end
%register the new figure with parent
udat=get(hmasterfig,'userdata');
if(udat{1}==-999.25)
    udat{1}=hfig;
else
    udat{1}=[udat{1} hfig];
end
set(hmasterfig,'userdata',udat);
if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','enhance(''makepptslide'');');
%the title string will be stored as userdata
end

function choice=nowshowing
hbg=findobj(gcf,'tag','choices');
choice=hbg.SelectedObject.Tag;
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
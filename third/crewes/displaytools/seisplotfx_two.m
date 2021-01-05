function datar=seisplotfx_two(ds1,ds2,t1s,twins,fmax,xname,flag)
% seisplotfx_two: plots a seismic gather and its f-x spectrum in time windows
%
% datar=seisplotfx_two(ds1,ds2,t1s,twins,fmax,xname,flag)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The seismic gather is
% plotted as an image in the left-hand-side and its temporal amplitude spectra in different time
% windows are plotted in the right-hand-side. Controls are provided to adjust the clipping and to
% brighten or darken the image plots.
%
% ds1,ds2 ... length 10 cell arrays specifying dataset #1 and dataset #2. Must be length 10 but
%           entries can be null (i.e. [] ).
%           The contents of each are:
%             {seis,t,x,dname,xname,yname,xdir,ydir,spaceflag,dataflag}
%             seis ... seismic matrix
%             t,x ... time and space coordinate directions
%             dname,xname,yname ... strings with dataset name and x and y axis labels
%             spaceflag, dataflag 
%               spaceflag meanings:
%               0 -> x,t space
%               1 -> x,z space
%               2 -> x,y space
%               3 -> y,t space
%               4 -> y,z space
%               dataflag meanings
%               0 -> normal seismic
%               1 -> spectra (like f-k or SpecD)
%               2 -> frequencies (like fdom)
% t1s ... vector of 3 window start times. Enter nan for the default.
% ********** default = [t(1) t(1)+twin t(2)+2*twin] where twin=(t(end)-t(1))/3 *********
% twins ... vector of 3 window lengths. Enter nan for the default.
% ********** default = [twin twin twin] *************
% fmax ... maximum frequency to include on the frequency axis. Enter nan for the default.
% ************ default = .25/(t(2)-t(1)) which is half-Nyquist ***********
% xname ... name of the x coordinate. nan gets the default
% ************ default = 'x coordinate' **********
% flag ... either 0 or 1. 0 means amplitude spectra and 1 means phase
% ************ default flag = 0 ************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the spectral axes
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
global SANE_TIMEWINDOWS
global FMAX
global NEWFIGVIS
global FXNAME
if(~ischar(ds1))
    action='init';
else
    action=ds1;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    %{seis,t,x,dname,xname,yname,xdir,ydir,spaceflag,dataflag}
    seis1=ds1{1};
    t1=ds1{2};
    x1=ds1{3};
    dname1=ds1{4};
    xname1=ds1{5};
    yname1=ds1{6};
    xdir1=ds1{7};
    ydir2=ds1{8};
    spaceflag1=ds1{9};
    dataflag1=ds1{10};
    seis2=ds2{1};
    t2=ds2{2};
    x2=ds2{3};
    dname2=ds2{4};
    xname2=ds2{5};
    yname2=ds2{6};
    xdir2=ds2{7};
    ydir2=ds2{8};
    spaceflag2=ds2{9};
    dataflag2=ds2{10};
    
    if(length(t1)~=size(seis1,1))
        error('time coordinate vector does not match seismic #1');
    end
    if(length(x1)~=size(seis1,2))
        error('space coordinate vector does not match seismic #1');
    end
    if(length(t2)~=size(seis2,1))
        error('time coordinate vector does not match seismic #2');
    end
    if(length(x2)~=size(seis2,2))
        error('space coordinate vector does not match seismic #2');
    end
    
    if(nargin<3)
        t1s=nan;
    end
    if(isnan(t1s))
        if(~isempty(SANE_TIMEWINDOWS))
            t1s=SANE_TIMEWINDOWS(:,1);
        else
            twin=(t(end)-t(1))/3;
            t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
        end
    end
    if(nargin<6)
        twins=nan;
    end
    if(isnan(twins))
        if(~isempty(SANE_TIMEWINDOWS))
            t2s=SANE_TIMEWINDOWS(:,2);
            twins=t2s-t1s;
        else
            twin=(t(end)-t(1))/3;
            twins=twin*ones(1,3);
        end
    end
    
    if(length(t1s)~=3 || length(twins)~=3)
        error('t1s and twins must be length 3');
    end
    
    t2s=t1s+twins;
    if((any(t1s)<t(1)) || any(t2s>t(end)))
        %somethings wrong. Make up 3 new windows
        twin=(t(end)-t(1))/3;
        t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
        twins=twin*ones(1,3);
    end
    
    
    fnyq=.5/(t(2)-t(1));
    if(nargin<7)
        fmax=nan;
    end
    
    if(isnan(fmax))
        if(isempty(FMAX))
            fmax=.5*fnyq;
        else
            fmax=FMAX;
        end
    end
    
    
    if(fmax>fnyq)
        fmax=fnyq;
    end
    
    if(nargin < 8)
        xname=nan;
    end
    if(isnan(xname))
        xname='x coordinate';
    end
    if(nargin<9)
        flag=0;
    end
    
    rflucstring={'50','40','30','20','10','5','2','1','0'};
    irfluc=5;
    
    xwid=.35;
    yht=.8;
    xsep=.05;
    xnot=.15;
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
           if(flag==0)
               [~,cmapname2,iflip2]=enhancecolormap('ampspectra');
           else
               [~,cmapname2,iflip2]=enhancecolormap('phsspectra');
           end
       end

    end
    if(notfromenhance)
       enhancetag='';
       udat=[]; 
       cmapname1='goldgray';
       iflip1=0;
       cmapname2='blueblack';
       iflip2=1;
    end
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat);
    hax1=subplot('position',[xnot ynot xwid yht]);
        
    imagesc(x,t,seis);
%     brighten(.5);
    grid
    if(length(dname)<30)
        htitle=enTitle(dname ,'interpreter','none');
        htFontSize=16;
    elseif(length(dname)<50)
        htitle=enTitle(dname ,'interpreter','none');
        htFontSize=14;
    else
        N=length(dname);
        N2=round(N/2);
        htitle=enTitle({dname(1:N2),dname(N2+1:end)} ,'interpreter','none');
        htFontSize=12;
    end
    
    %draw window start times
    xmin=min(x);
    xmax=max(x);
    klrs=get(hax1,'colororder');
    lw=1;
    line([xmin xmax],[t1s(1) t1s(1)],'color',klrs(2,:),'linestyle','--','buttondownfcn','seisplotfx_two(''dragline'');','tag','1','linewidth',lw);
    line([xmin xmax],[t1s(1)+twins(1) t1s(1)+twins(1)],'color',klrs(2,:),'linestyle',':','buttondownfcn','seisplotfx_two(''dragline'');','tag','1b','linewidth',lw);
    line([xmin xmax],[t1s(2) t1s(2)],'color',klrs(3,:),'linestyle','--','buttondownfcn','seisplotfx_two(''dragline'');','tag','2','linewidth',lw);
    line([xmin xmax],[t1s(2)+twins(2) t1s(2)+twins(2)],'color',klrs(3,:),'linestyle',':','buttondownfcn','seisplotfx_two(''dragline'');','tag','2b','linewidth',lw);
    line([xmin xmax],[t1s(3) t1s(3)],'color',klrs(4,:),'linestyle','--','buttondownfcn','seisplotfx_two(''dragline'');','tag','3','linewidth',lw);
    line([xmin xmax],[t1s(3)+twins(3) t1s(3)+twins(3)],'color',klrs(4,:),'linestyle',':','buttondownfcn','seisplotfx_two(''dragline'');','tag','3b','linewidth',lw);
    
    maxmeters=7000;
    
    if(max(t)<10)
        ylabel('time (s)')
    elseif(max(t)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    if(max(x)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    
    %make a button to reset time windows to the global values
    wid=.055;ht=.05;sep=.005;
    xnow=xnot-.125;
    ynow=ynot+yht+sep;
    uicontrol(hfig,'style','pushbutton','string','Reset windows to globals','units','normalized',...
        'position',[xnow,ynow,1.7*wid,.5*ht],'callback','seisplotfx_two(''resetwindows'')','tag','resetwin',...
        'tooltipstring','Resets windows to the most recent published values');
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+ht,.5*wid,.5*ht],'callback','seisplotfx_two(''info'');',...
        'backgroundcolor','y');

    %make a clip control
    wid=.1;ht=.05;sep=.005;
%     nudge=.1*wid;
    htclip=2*ht;
%     xnow=xnot-3*wid;
    ynow=ynot+yht-htclip;
    %make a clip control
    climxt=[-3 3];
    pos=[xnot+xwid+xsep ynot-.025*yht xwid 1.025*yht];
    hclip=uipanel(hfig,'position',[xnow,ynow,wid,htclip],'tag','clipxt',...
        'userdata',{hax1,t1s,twins,fnyq,dname,xname,flag,pos,x},'title','Clipping');
    data={climxt,hax1};
    callback='';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;
    
    ynow=ynow-sep;
%     uicontrol(hfig,'style','pushbutton','string','brighten','tag','brightenxt','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplotfx_two(''brightenxt'');',...
%         'tooltipstring','push once or multiple times to brighten the images');
%     ynow=ynow-ht-sep;
%     uicontrol(hfig,'style','pushbutton','string','darken','tag','darkenxt','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplotfx_two(''brightenxt'');',...
%         'tooltipstring','push once or multiple times to darken the images');
%     ynow=ynow-ht-sep;
%     uicontrol(hfig,'style','text','string','lvl 0','tag','brightnessxt','units','normalized',...
%         'position',[xnow,ynow,wid,ht],...
%         'tooltipstring','image brightness (both images)','userdata',0);
    ycolor=ynow;%for colormaptool installed later
    xcolor=xnow;
    widcolor=wid;
    
    set(hax1,'tag','seis');

    hax2=axes('position',pos,'xtick',[],'ytick',[],'xcolor',.999*ones(1,3),'ycolor',.999*ones(1,3)); 
    t2s=t1s+twins;

    rfluc=str2double(rflucstring{irfluc});
    [hfigs,phs,fphs,amp,famp]=fxanalysis(seis,t,t1s,t2s,fnyq,'',x,xname,nan,flag,hax2,rfluc); %#ok<ASGLU>
    if(flag==0)
        result={flag,amp,famp,t1s,t2s,rfluc,fmax};
    else
        result={flag,phs,fphs,t1s,t2s,rfluc,fmax};
    end
    fxname=FXNAME;

    htxt=zeros(1,3);
    htxt(1)=findobj(hfig,'tag','z1');
    set(htxt(1),'backgroundcolor',klrs(2,:),'fontweight','bold');
    htxt(2)=findobj(hfig,'tag','z2');
    set(htxt(2),'backgroundcolor',klrs(3,:),'fontweight','bold');
    htxt(3)=findobj(hfig,'tag','z3');
    set(htxt(3),'backgroundcolor',klrs(4,:),'fontweight','bold','foregroundcolor',[1 1 1]);
%     set(hax2,'xtick',[],'ytick',[],'xcolor',.9*ones(1,3),'ycolor',.9*ones(1,3));
    
    %make 3 zoom buttons
    ynudge=0;
    xnow=xnot+2*xwid+xsep+.01;
    ynow=ynot+.17*yht+ynudge;
    wid=.075;ht=.025;
    uicontrol(hfig,'style','pushbutton','string','zoom 1&2 like 3','units','normalized','tag','z12',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx_two(''zoom'');');
    ynow=ynow+.33*yht;
    uicontrol(hfig,'style','pushbutton','string','zoom 1&3 like 2','units','normalized','tag','z13',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx_two(''zoom'');');
    ynow=ynow+.33*yht;
    uicontrol(hfig,'style','pushbutton','string','zoom 2&3 like 1','units','normalized','tag','z23',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx_two(''zoom'');');
    

    xnow=xnot+2*xwid+xsep+.01;
    ht=.025;
    ynow=ynot+yht-.75*ht;
%     nudge=.25*ht;
    uicontrol(hfig,'style','text','string','PctRand:','units','normalized',...
        'position',[xnow,ynow,.5*wid,.75*ht],'tooltipstring',...
        'Amount of random fluctuation in window size as a percent','horizontalalignment','right');
    
    uicontrol(hfig,'style','popupmenu','string',rflucstring,'units','normalized','position',...
        [xnow+.5*wid,ynow,.5*wid,ht],'tag','rfluc','value',irfluc);
    ynow=ynow-ht;
    uicontrol(hfig,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,.5*wid,.75*ht],'tooltipstring','The maximum frequency to show',...
        'horizontalalignment','right');
    uicontrol(hfig,'style','edit','string',num2str(round(fmax)),'units','normalized','tag','fmax',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],'tooltipstring','Enter a value in Hz.',...
        'callback','seisplotfx_two(''changefmax'');','userdata',fnyq);
    if(flag==0)
        ynow=ynow-ht-sep;
        uicontrol(hfig,'style','radiobutton','string','show ave amp','units','normalized','tag','showave',...
            'position',[xnow,ynow,wid,ht],'callback','seisplotfx_two(''showave'');','value',1);
    end
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','recompute','tag','recompute','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx_two(''recompute'');',...
        'tooltipstring','recompute the spectra','backgroundcolor','y');

%results popup
    haxspec1=findobj(hfig,'tag','spec1');
    pos=get(haxspec1,'position');
    xnow=pos(1);
    ynow=pos(2)+pos(4)+ht;
    wid=pos(3);
    fs=12;
    fontops={'x4','x2','x1.5','x1.25','x1.11','x0.9','x0.8','x0.67','x0.5','x0.25'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
    uicontrol(hfig,'style','popupmenu','string',{fxname},'units','normalized','tag','results',...
        'position',[xnow,ynow,wid,2*ht],'callback','seisplotfx_two(''select'');','fontsize',fs,...
        'fontweight','bold','value',1,'uicontextmenu',hcm)
    
    seisplotfx_two('newresult',result);
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.6,1); %enlarge the fonts in the figure
    set(htxt,'fontweight','bold')
    boldlines(hax1,4,2); %make lines and symbols "fatter"
    htitle.FontSize=htFontSize;
    whitefig;
    
    if(flag==0)
        if(~iscell(dname))
            dname2=dname;
        else
            dname2=[dname{1} ' ' dname{2}];
        end
        set(hfig,'name',['F-X amplitude analysis for ' dname2],'closerequestfcn','seisplotfx_two(''close'');');
    else
        if(~iscell(dname))
            dname2=dname;
        else
            dname2=[dname{1} ' ' dname{2}];
        end
        set(hfig,'name',['F-X phase analysis for ' dname2],'closerequestfcn','seisplotfx_two(''close'');');
    end
    
    hfxax1=findobj(hfig,'tag','spec1');
    hfxax2=findobj(hfig,'tag','spec2');
    hfxax3=findobj(hfig,'tag','spec3');

    %colormap control
    ynow=ycolor-8*ht;
    pos=[xcolor,ynow,widcolor,8*ht];
    cb1='';cb2='';
    cbflag=[0,1];
    cbcb='';
    cbaxe=hax1;
    enhancecolormaptool(hfig,pos,hax1,[hfxax1,hfxax2,hfxax3],cb1,cb2,cmapname1,cmapname2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    
    if(nargout>0)
        datar={hax1,hfxax1,hfxax2,hfxax3};
    end
    seisplotfx_two('clipxt');
    seisplotfx_two('changefmax');
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    if(strcmp(get(hthisfig,'tag'),'fromenhance'))
        session=' ENHANCE ';
    else
        session=' MATLAB ';
    end
    msg={['The spectral windows are indicated by the colored horizontal lines on the seismic data. ',...
        'The red lines define the window for the upper f-x spectum, the orange lines define ',...
        'the middle window, and the purple lines the lower spectral window. For each spectral window, the dashed ',...
        'line is the top and the dotted line is the bottom. Click (left button) on any of these ',...
        'lines and drag them to new positions.'],' ',['If you wish to move the window but retain its size ',...
        'then right-click on either the top or bottom and drag.'],' ',['After adjusting the lines, push "recompute" to recalculate ',...
        'the spectra.'],' ',['When you adjust the windows, the window positions are saved (for the ',...
        'current' session 'session) so that the next invocation of this tool will start with the ',...
        'newly defined windows. The button "reset windows to globals" matters only if you have ',...
        'several of these tools running at once. If you adjust the windows in tool#1 and then ',...
        'wish tool#2 to grab these same windows, then push this button in tool#2 and then push ',...
        '"recompute".'],' ',['The presence of signal is indicated by spatial continuity of the spectra, ',...
        'either amplitude or phase.  The amplitude spectra can seem easier to interprete but they ',...
        'only show signal where the spectral strength is strong. Examining the phase spectra as ',...
        'well alllows a judgement of whether the band of spectral whitening corresponds to the ',...
        'signal band. If the phase spectra show coherence at frequencies where the spectrum is not ',...
        'whitened, then such signal is wasted.'],' ',['The use of this tool to identify signal relies ',...
        'on signal being correlated from trace-to-trace while noise is not. Certain seismic processing ',...
        'steps tend to result in spatially correlated noise and such processes can defeat this fx technique. ',...
        'The most common example of such a process is migration. The correlation induced by migration is ',...
        'usually only a problem near the bottom of a seismic section where the migration impulse response ',...
        'is spatially wide. If this is a concern, then often a less biased estimate of signal band can ',...
        'be obtained from an unmigrated stack.'],' ',['The physics of attenuation argues strongly that ',...
        'the seismic signal bandwidth should always become more narrow as time increases. Only the ',...
        'time-variant increase of effective "fold", which occurs near the top of a seismic section, ',...
        'can counter this effect. Therefore, you should always be suspiscious of any signal estimate ',...
        'that shows increasing bandwidth with increasing time provided that "fold" is not also increasing.']};
    hinfo=showinfo(msg,'Instructions for f-x spectra tool');
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
elseif(strcmp(action,'showave'))
    val=get(gco,'value');
    vis='on';
    if(~val); vis='off'; end
    
    ha=findobj(gcf,'tag','Aamp1');
    hk=get(ha,'children');
    set(ha,'visible',vis);
    for k=1:length(hk)
        set(hk(k),'visible',vis);
    end
    
    ha=findobj(gcf,'tag','Aamp2');
    hk=get(ha,'children');
    set(ha,'visible',vis);
    for k=1:length(hk)
        set(hk(k),'visible',vis);
    end
    
    ha=findobj(gcf,'tag','Aamp3');
    hk=get(ha,'children');
    set(ha,'visible',vis);
    for k=1:length(hk)
        set(hk(k),'visible',vis);
    end
elseif(strcmp(action,'clipxt'))
%     hclip=findobj(gcf,'tag','clipxt');
%     udat=get(hclip,'userdata');
%     iclip=get(hclip,'value');    
%     clips=udat{1};
%     am=udat{2};
%     amax=udat{4};
%    % amin=udat{5};
%     sigma=udat{3};
%     hax=udat{6};
%     if(iclip==1)
%         clim=[-amax amax];
%     else
%         clip=clips(iclip);
%         clim=[am-clip*sigma,am+clip*sigma];
%     end
%     set(hax,'clim',clim);
%     %adjust the spectral axes
%     for k=1:3
%         hax=findobj(gcf,'tag',['spec' int2str(k)]);
%         htxt=findobj(gcf,'tag',['z' int2str(k)]);
%         udat=get(htxt,'userdata');
%         amean=udat(1);
%         amax=udat(2);
%         sigma=udat(3);
%         flag=udat(4);
%         if(flag==0)
%             if(iclip~=1)
%                 set(hax,'clim',[-.5*sigma clip*sigma+amean]);
%             else
%                 set(hax,'clim',[-.5*sigma amax]);
%             end
%         else
%             if(iclip~=1)
%                 c1=max([amean-clip*sigma -1]);
%                 c2=min([clip*sigma+amean 1]);
%                 set(hax,'clim',[c1 c2]);
%             else
%                 set(hax,'clim',[-amax amax]);
%             end
%         end
%     end

% elseif(strcmp(action,'brightenxt'))
%     hbut=gcbo;
%     hbright=findobj(gcf,'tag','brightenxt');
%     if(hbut==hbright)
%         inc=.1;
%     else
%         inc=-.1;
%     end
%     brighten(inc);
%     hbrightness=findobj(gcf,'tag','brightnessxt');
%     brightlvl=get(hbrightness,'userdata');
%     brightlvl=brightlvl+inc;
%     if(abs(brightlvl)<.01)
%         brightlvl=0;
%     end
%     set(hbrightness,'string',['lvl ' num2str(brightlvl)],'userdata',brightlvl)

elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{1};
%     t1s=udat{7};
    twins=udat{2};
    twin=.25*min(twins);
    
    h1=findobj(haxe,'tag','1');
    yy=get(h1,'ydata');
    t1=yy(1);
    h1b=findobj(haxe,'tag','1b');
    yy=get(h1b,'ydata');
    t1b=yy(1);
    h2=findobj(haxe,'tag','2');
    yy=get(h2,'ydata');
    t2=yy(2);
    h2b=findobj(haxe,'tag','2b');
    yy=get(h2b,'ydata');
    t2b=yy(2);
    h3=findobj(haxe,'tag','3');
    yy=get(h3,'ydata');
    t3=yy(1);
    h3b=findobj(haxe,'tag','3b');
    yy=get(h3b,'ydata');
    t3b=yy(1);
    
    hi=findobj(haxe,'type','image');
    t=get(hi,'ydata');
    tmin=t(1);tmax=t(end);
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on t1
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin t1b];
        DRAGLINE_PAIRED=h1b;
    elseif(hnow==h2)
        %clicked on t2
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin t2b];
        DRAGLINE_PAIRED=h2b;
    elseif(hnow==h3)
        %clicked on t3
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin t3b];
        DRAGLINE_PAIRED=h3b;
    elseif(hnow==h1b)
        %clicked on t1b
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t1 tmax-twin];
        DRAGLINE_PAIRED=h1;
    elseif(hnow==h2b)
        %clicked on t2b
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t2 tmax-twin];
        DRAGLINE_PAIRED=h2;
    elseif(hnow==h3b)
        %clicked on t3b
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t3 tmax-twin];
        DRAGLINE_PAIRED=h3;
    end
    
    dragline('click')
    
elseif(strcmp(action,'resetwindows'))
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{1};
    
    tglobal=SANE_TIMEWINDOWS;
    t1s=tglobal(:,1);
    t2s=tglobal(:,2);
    
    h1=findobj(haxe,'tag','1');
    set(h1,'ydata',[t1s(1) t1s(1)]);
    h1b=findobj(haxe,'tag','1b');
    set(h1b,'ydata',[t2s(1) t2s(1)]);
    h2=findobj(haxe,'tag','2');
    set(h2,'ydata',[t1s(2) t1s(2)]);
    h2b=findobj(haxe,'tag','2b');
    set(h2b,'ydata',[t2s(2) t2s(2)]);
    h3=findobj(haxe,'tag','3');
    set(h3,'ydata',[t1s(3) t1s(3)]);
    h3b=findobj(haxe,'tag','3b');
    set(h3b,'ydata',[t2s(3) t2s(3)]);
    
elseif(strcmp(action,'changefmax'))
    hfmax=findobj(gcf,'tag','fmax');
    tmp=get(hfmax,'string');
    fmax=str2double(tmp);
    fnyq=get(hfmax,'userdata');
    if(isnan(fmax))
        fmax=fnyq;
        set(hfmax,'string',num2str(fmax));
    end
    if(fmax<0 || fmax>fnyq)
        fmax=fnyq;
        set(hfmax,'string',num2str(fmax));
    end
    hax=findobj(gcf,'tag','spec1');
    set(hax,'ylim',[0 fmax]);
    hax=findobj(gcf,'tag','spec2');
    set(hax,'ylim',[0 fmax]);
    hax=findobj(gcf,'tag','spec3');
    set(hax,'ylim',[0 fmax]);
    
    hax=findobj(gcf,'tag','Aamp1');
    if(~isempty(hax))
        set(hax,'xlim',[0 fmax]);
        ht=flipud(findobj(hax,'tag','xt'));
        xt=cell2mat(get(ht,'userdata'));
        ind=find(xt<=fmax);
        inc=1;
        if(length(ind)>5)
            inc=ceil(length(ind)/5);
        end
        set(ht,'visible','off');
        for k=ind(1:inc:end)
            set(ht(k),'visible','on');
        end
        xlbl=findobj(hax,'tag','xlbl');
        pos=xlbl.Position;
        set(xlbl,'position',[xt(ind(end))+xt(2) pos(2:3)]);
    end
    hax=findobj(gcf,'tag','Aamp2');
    if(~isempty(hax))
        set(hax,'xlim',[0 fmax]);
        ht=flipud(findobj(hax,'tag','xt'));
        xt=cell2mat(get(ht,'userdata'));
        ind=find(xt<=fmax);
        inc=1;
        if(length(ind)>5)
            inc=ceil(length(ind)/5);
        end
        set(ht,'visible','off');
        for k=ind(1:inc:end)
            set(ht(k),'visible','on');
        end
        xlbl=findobj(hax,'tag','xlbl');
        pos=xlbl.Position;
        
        set(xlbl,'position',[xt(ind(end))+xt(2) pos(2:3)]);
    end
    hax=findobj(gcf,'tag','Aamp3');
    if(~isempty(hax))
        set(hax,'xlim',[0 fmax]);
        ht=flipud(findobj(hax,'tag','xt'));
        xt=cell2mat(get(ht,'userdata'));
        ind=find(xt<=fmax);
        inc=1;
        if(length(ind)>5)
            inc=ceil(length(ind)/5);
        end
        set(ht,'visible','off');
        for k=ind(1:inc:end)
            set(ht(k),'visible','on');
        end
        xlbl=findobj(hax,'tag','xlbl');
        pos=xlbl.Position;
        set(xlbl,'position',[xt(ind(end))+xt(2) pos(2:3)]);
    end
    
    FMAX=fmax;
    
    hresults=findobj(gcf,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    results.fmaxs{iresult}=fmax;
    set(hresults,'userdata',results);
    
elseif(strcmp(action,'recompute'))
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    hax1=udat{1};
    t1s=udat{2};
    twins=udat{3};
    fnyq=udat{4};
    %dname=udat{10};
    xname=udat{6};
    flag=udat{7};
    pos=udat{8};
    x=udat{9};
    
    hfmax=findobj(gcf,'tag','fmax');
    val=get(hfmax,'string');
    fmax=str2double(val);
    
    hrand=findobj(gcf,'tag','rfluc');
    flucs=get(hrand,'string');
    ifluc=get(hrand,'value');
    rfluc=str2double(flucs{ifluc});
%     if(isnan(fmax)||fmax<0||fmax>fnyq)
%         msgbox('Invalid value for fmax, correct and try again');
%         return;
%     end
    
    %for some unknown reason, when a recompute occurs, the fontsize changes (gets smaller) in all
    %of the fx axes. So, the fix is to grab the previous fontsizes and then reset them after
    haxes=findobj(gcf,'type','axes');
    fs=zeros(size(haxes));
    fw=cell(size(haxes));
    tags=cell(size(haxes));
    cm=tags;
    for k=1:length(haxes)
        fs(k)=get(haxes(k),'fontsize');
        fw{k}=get(haxes(k),'fontweight');
        tags{k}=get(haxes(k),'tag');
        cm{k}=get(haxes(k),'colormap');
    end
    if(flag==0)
        hax3=findobj(gcf,'tag','spec3');
    else
        hax3=findobj(gcf,'tag','spec3');
    end
    htxt=get(hax3,'userdata');
    fstxt=zeros(size(htxt));
    fwtxt=cell(size(htxt));
    for k=1:length(htxt)
        fstxt(k)=get(htxt(k),'fontsize');
        fwtxt{k}=get(htxt(k),'fontweight');
    end
    
    h1=findobj(hax1,'tag','1');
    yy=get(h1,'ydata');
    t1s(1)=yy(1);
    h1b=findobj(hax1,'tag','1b');
    yy=get(h1b,'ydata');
    twins(1)=yy(1)-t1s(1);
    
    h2=findobj(hax1,'tag','2');
    yy=get(h2,'ydata');
    t1s(2)=yy(1);
    h2b=findobj(hax1,'tag','2b');
    yy=get(h2b,'ydata');
    twins(2)=yy(1) -t1s(2);
    
    h3=findobj(hax1,'tag','3');
    yy=get(h3,'ydata');
    t1s(3)=yy(1);
    h3b=findobj(hax1,'tag','3b');
    yy=get(h3b,'ydata');
    twins(3)=yy(1)-t1s(3);
    
    udat{2}=t1s;
    udat{3}=twins;
    set(hclipxt,'userdata',udat);
    
    hi=findobj(hax1,'type','image');
    seis=get(hi,'cdata');
    t=get(hi,'ydata');
    
    hax2=subplot('position',pos);
    t2s=t1s+twins;
    %delete the window text labels so that fxanalysis can make new ones
    for k=1:3
        htxt=findobj(gcf,'tag',['z' int2str(k)]);
        if(isgraphics(htxt))
            delete(htxt);
        end
    end
    
    SANE_TIMEWINDOWS=[t1s(:) t2s(:)];
    
%     if(flag==0)
%         cm=get(gcf,'colormap');
%     end
%     cm=get(gcf,'colormap');
    [hfigs,phs,fphs,amp,famp]=fxanalysis(seis,t,t1s,t2s,fnyq,'',x,xname,nan,flag,hax2,rfluc); %#ok<ASGLU>
%     set(gcf,'colormap',cm);
    if(flag==0)
        result={flag,amp,famp,t1s,t2s,rfluc,fmax};
    else
        result={flag,phs,fphs,t1s,t2s,rfluc,fmax};
    end
    %update results menu
    hresults=findobj(gcf,'tag','results');
    names=get(hresults,'string');
    nresults=length(names);
    names{nresults+1}=FXNAME;
    set(hresults,'string',names,'value',nresults+1);
    seisplotfx_two('newresult',result);
     
    if(flag==0)
       
        hax=findobj(gcf,'tag','spec1');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec2');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec3');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','Aamp1');
        hl=findobj(hax,'type','line');
        set(hl,'linewidth',4*get(hl,'linewidth'));
        hax=findobj(gcf,'tag','Aamp2');
        hl=findobj(hax,'type','line');
        set(hl,'linewidth',4*get(hl,'linewidth'));
        hax=findobj(gcf,'tag','Aamp3');
        hl=findobj(hax,'type','line');
        set(hl,'linewidth',4*get(hl,'linewidth'));
    end
    if(flag==1)
        hax=findobj(gcf,'tag','spec1');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec2');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec3');
        set(hax,'ylim',[0 fmax]);
    end
    klrs=get(hax1,'colororder');
    h=findobj(gcf,'tag','z1');
    set(h,'backgroundcolor',klrs(2,:),'fontweight','bold');
    h=findobj(gcf,'tag','z2');
    set(h,'backgroundcolor',klrs(3,:),'fontweight','bold');
    h=findobj(gcf,'tag','z3');
    set(h,'backgroundcolor',klrs(4,:),'fontweight','bold','foregroundcolor',[1 1 1]);
    haxes=findobj(gcf,'type','axes');
    hax3=findobj(gcf,'tag','spec3');
%     if(flag==0)
%         hax3=findobj(gcf,'tag','spec3');
%     else
%         hax3=findobj(gcf,'tag','spec3');
%     end
    htxt=get(hax3,'userdata');
    for k=1:length(haxes)
        thistag=get(haxes(k),'tag');
        for kk=1:length(tags)
            if(strcmp(thistag,tags{kk}))
                set(haxes(k),'fontsize',fs(kk));
                set(haxes(k),'fontweight',fw{kk});
                set(haxes(k),'colormap',cm{kk});
                break
            end
        end
        tmp=strfind(thistag,'Aamp');
        if(~isempty(tmp)) %#ok<STREMP>
           set(haxes(k),'xlim',[0 fmax]); 
        end
        
    end
    for k=1:length(htxt)
       set(htxt(k),'fontsize',fstxt(k),'fontweight',fwtxt{k}) 
    end
    
    seisplotfx_two('clipxt');
    seisplotfx_two('changefmax');
elseif(strcmp(action,'newresult'))
    result=t;%second argument
    %result{1}=flag ... 0 for amp 1 for phase
    %result{2}=fxspec ... cell array of 3 fx spectra
    %result{3}=fs ... cell array of 3 frequency coord vectors
    %result{4}=t1s ... ord array of window start times
    %result{5}=t2s ... ord array of window end times
    %result{6}=rfluc ... value of rfluc
    hresults=findobj(gcf,'tag','results');
    results=get(hresults,'userdata');
    nresults=get(hresults,'value');
%     if(isempty(results))
%         nresults=1;
%     else
%         nresults=length(results)+1;
%     end
    results.flags{nresults}=result{1};
    results.fxspecs{nresults}=result{2};
    results.fss{nresults}=result{3};
    results.t1ss{nresults}=result{4};
    results.t2ss{nresults}=result{5};
    results.rflucs{nresults}=result{6};
    results.fmaxs{nresults}=result{7};
    
    set(hresults,'userdata',results)

elseif(strcmp(action,'select'))
    hfig=gcf;
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    %loop over spectra
    flag=results.flags{iresult};
    fmax=results.fmaxs{iresult};
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(fmax));
    hseis=findobj(hfig,'tag','seis');
    for k=1:length(results.fxspecs{iresult})
        fxspec=results.fxspecs{iresult}{k};
        f=results.fss{iresult}{k};
        t1s=results.t1ss{iresult};
        t2s=results.t2ss{iresult};
        rfluc=results.rflucs{iresult};
        %update spectra
        hax=findobj(hfig,'tag',['spec' int2str(k)]);
        hi=findobj(hax,'type','image');
        set(hi,'ydata',f,'cdata',fxspec);
        set(hax,'ylim',[0 fmax]);
        %update average amplitude
        if(flag==0)
            aveamp=sum(fxspec,2);
            haxa=findobj(hfig,'tag',['Aamp', int2str(k)]);
            hl=findobj(haxa,'type','line');
            set(hl,'xdata',f,'ydata',todb(aveamp));
        end
        %update time label
        htxt=findobj(hfig,'tag',['z' int2str(k)]);
        set(htxt,'string',[time2str(t1s(k)) ' to ' time2str(t2s(k)) ' sec']);
        %update amplitude info
        amean=mean(fxspec(:));
        amax=max(fxspec(:));
        sigma=std(fxspec(:));
        set(htxt,'userdata',[amean amax sigma flag]);
        %update line positions
        hlinea=findobj(hseis,'tag',int2str(k));
        hlineb=findobj(hseis,'tag',[int2str(k) 'b']);
        set(hlinea,'ydata',[t1s(k) t1s(k)]);
        set(hlineb,'ydata',[t2s(k) t2s(k)]);
        %update rfluc
        hrfluc=findobj(gcf,'tag','rfluc');
        rflucstring=get(hrfluc,'string');
        for j=1:length(rflucstring)
           if(str2double(rflucstring{j})==rfluc)
              set(hrfluc,'value',j); 
           end
        end
    end

elseif(strcmp(action,'zoom'))
    hbut=gcbo;
    tag=get(hbut,'tag');
    switch tag
        case 'z12'
            haxnow=findobj(gcf,'tag','spec3');
            yl=get(haxnow,'ylim');
            xl=get(haxnow,'xlim');
            haxa=findobj(gcf,'tag','spec1');
            haxb=findobj(gcf,'tag','spec2');
            set([haxa haxb],'xlim',xl,'ylim',yl);
            
        case 'z13'
            haxnow=findobj(gcf,'tag','spec2');
            yl=get(haxnow,'ylim');
            xl=get(haxnow,'xlim');
            haxa=findobj(gcf,'tag','spec1');
            haxb=findobj(gcf,'tag','spec3');
            set([haxa haxb],'xlim',xl,'ylim',yl);
            
        case 'z23'
            haxnow=findobj(gcf,'tag','spec1');
            yl=get(haxnow,'ylim');
            xl=get(haxnow,'xlim');
            haxa=findobj(gcf,'tag','spec2');
            haxb=findobj(gcf,'tag','spec3');
            set([haxa haxb],'xlim',xl,'ylim',yl);
    end
elseif(strcmp(action,'close'))
    hfig=gcf;
    tmp=get(hfig,'userdata');
    if(iscell(tmp))
        hfigs=tmp{1};
    else
        hfigs=tmp;
    end
    for k=1:length(hfigs)
        if(isgraphics(hfigs(k)))
            delete(hfigs(k))
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
    
end
end

%% functions

function val=fromenhance
hfig=gcf;
val=false;
if(strcmp(get(hfig,'tag'),'fromenhance'))
    val=true;
end
end

function fontchange(~,~)
hm=gcbo;
tag=hm.Label;
scalar=str2double(tag(2:end));
hresults=findobj(gcf,'tag','results');
hresults.FontSize=scalar*hresults.FontSize;
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
%     results=hresults.UserData;
    if(ischar(names))
        names=a{1};
        hresults.String=names;
%         results.names{1}=names;
    else
        names{iresult}=a{1};
        hresults.String=names;
%         results.names{iresult}=names{iresult};
    end
%     hresults.UserData=results;
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

sigma=std(data(:));
am=mean(data(:));
amin=min(data(:));
amax=max(data(:));
nsigma=ceil((amax-amin)/sigma);%number of sigmas that span the data

clips=[20 15 10 8 6 4 3 2 1 .1 .01 .001 .0001]';
if(nsigma<clips(1))
    ind= clips<nsigma;
    clips=[nsigma;clips(ind)];
else
    n=floor(log10(nsigma/clips(1))/log10(2));
    newclips=zeros(n,1);
    newclips(1)=nsigma;
    for k=n:-1:2
        newclips(k)=2^(n+1-k)*clips(1);
    end
    clips=[newclips;clips];
end

clipstr=cell(size(clips));
nclips=length(clips);
clipstr{1}='none';
for k=2:nclips
    clipstr{k}=['clip= ' num2str(sigfig(clips(k),3))];
end
iclip=near(clips,3);
iclip=iclip(1);
clip=clips(iclip(1));

end
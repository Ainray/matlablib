function datar=seisplottvs_two(arg1,arg2,t1,t2,x1,x2,dname1,dname2,tnots,twins,fmax)
% SEISPLOTTVS: plots a seismic gather and its frequency spectrum in time windows
%
% datar=seisplottvs_two(seis,seis2,t1,t2,x1,x2,dname1,dname2.tnots,twins,fmax)
%
% A new figure is created and divided into three same-sized axes (side-by-side). The seismic gathers
% are plotted as images in the left-hand-side and their temporal amplitude spectra in different time
% windows are plotted in the two axes to the right. The seismic data are displayed in a single axes
% one-at-a-time with a menu to toggle.
%
%
% seis1... input seismic matrix #1
%           Can also be a length 2 cell array where the first entry is the seismic matrix and the
%           second if the colormap to display it.
% seis2... input seismic matrix #2
%           Can also be a length 2 cell array where the first entry is the seismic matrix and the
%           second if the colormap to display it.
% t1 ... time coordinate vector for seis1. This is the row coordinate of seis1. 
% t2 ... time coordinate vector for seis2. This is the row coordinate of seis2. 
% x1 ... space coordinate vector for seis1
% x2 ... space coordinate vector for seis2
% dname1 ... text string giving a name for dataset #1 that will annotate
%       the plots.
% dname2 ... text string giving a name for dataset #2 that will annotate
%       the plots.
% tnots ... vector of 3 window start times (nan gets default)
% ********** default = [t(1) t(1)+twin t(2)+2*twin] where twin=(t(end)-t(1))/3 *********
% twins ... vector of 3 window lengths (nan gets default)
% ********** default = [twin twin twin] *************
% fmax ... maximum frequency to include on the frequency axis.
% ************ default = .5/(t(2)-t(1)) which is Nyquist ***********
%
% datar ... Return data which is a length 3 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the first spectral axes
%           data{3} ... handle of the second spectral axes
%
% G.F. Margrave, Margrave-Geo, 2020
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

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED
global SANE_TIMEWINDOWS
global FMAX DBLIM
global NEWFIGVIS

if(~ischar(arg1))
    action='init';
else
    action=arg1;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(iscell(arg1))
        seis1=arg1{1};
        cmap1=arg1{2};
    else
        seis1=arg1;
        cmap1=seisclrs(128);
    end
    if(iscell(arg2))
        seis2=arg2{1};
        cmap2=arg2{2};
    else
        seis2=arg2;
        cmap2=seisclrs(128);
    end
    
    if(length(t1)~=size(seis1,1))
        error('time coordinate vector does not match seismic 1');
    end
    if(length(x1)~=size(seis1,2))
        error('space coordinate vector does not match seismic 1');
    end
    if(length(t2)~=size(seis2,1))
        error('time coordinate vector does not match seismic 2');
    end
    if(length(x2)~=size(seis2,2))
        error('space coordinate vector does not match seismic 2');
    end

    if(nargin<9)
        tnots=nan;
    end
    if(nargin<10)
        twins=nan;
    end
    tmin=max([min(t1),min(t2)]);
    tmax=min([max(t1),max(t2)]);
    if(any(isnan(tnots)) && any(isnan(twins)))
        if(~isempty(SANE_TIMEWINDOWS))
            tmp=SANE_TIMEWINDOWS(:,2);
            if(all(tmp<tmax))
                tnots=SANE_TIMEWINDOWS(:,1);
                t2s=SANE_TIMEWINDOWS(:,2);
                twins=t2s-tnots;
            else
                twin=(tmax-tmin)/3;
                twins=twin*ones(1,3);
            end
        else
            twin=(tmax-tmin)/3;
            tnots=[tmin+.05*twin tmin+twin tmin+1.95*twin];
            twins=twin*ones(1,3);
        end
    end
    
    if(any(isnan(tnots)))
        twin=(tmax-tmin)/3;
        tnots=[tmin+.05*twin tmin+twin tmin+1.95*twin];
    end
    if(any(isnan(twins)))
        twin=(tmax-tmin)/3;
        twins=twin*ones(1,3);
    end
    
    if(length(tnots)~=3 || length(twins)~=3)
        error('tnots and twins must be length 3');
    end
    
    fnyq1=.5/(t1(2)-t1(1));
    fnyq2=.5/(t2(2)-t2(1));
    fnyq=max([fnyq1,fnyq2]);
    if(nargin<11)
        if(isempty(FMAX))
            fmax=fnyq;
        else
            fmax=FMAX;
        end
    end
    
    if(fmax>fnyq)
        fmax=fnyq;
    end
    
    xwid=.35;
    yht=.75;
    xsep=.1;
    xnot=.125;
    ynot=.1;
    

    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    hax1=subplot('position',[xnot ynot xwid yht]);

    inz=seis1~=0;
    sigma=std(seis1(inz));
    am=mean(seis1(inz));
    amax=max(seis1(inz));
    amin=min(seis1(inz));
    ampinfo1=[sigma,am,amax,amin];
    inz=seis2~=0;
    sigma=std(seis2(inz));
    am=mean(seis2(inz));
    amax=max(seis2(inz));
    amin=min(seis2(inz));
    ampinfo2=[sigma,am,amax,amin];
        
    imagesc(x1,t1,seis1);colormap(seisclrs)

    grid
    %section popup
    ht=.1;
    xnow=xnot;
    ynow=ynot+yht-.5*ht;
    wid=xwid;
    fs=12;
    fontops={'x4','x2','x1.5','x1.25','x1.11','x0.9','x0.8','x0.67','x0.5','x0.25'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
%     nc=1;
    if(iscell(dname1))
        dname1=[dname1{1} dname1{2}];
    end
    dn1=dname1;
%     n2=round((nc-length(dname1))/2);
%     if(n2>0)
%         dn1=[blanks(n2) dname1];
%     else
%         dn1=dname1;
%     end
    if(iscell(dname2))
        dname2=[dname2{1} dname2{2}];
    end
    dn2=dname2;
%     n2=round((nc-length(dname2))/2);
%     if(n2>0)
%         dn2=[blanks(n2) dname2];
%     else
%         dn2=dname2;
%     end
    uicontrol(hfig,'style','popupmenu','string',{dn1,dn2},'units','normalized','tag','sections',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottvs_two(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm,'userdata',{seis1,seis2,t1,t2,x1,x2,dname1,dname2,cmap1,cmap2})
    
    %draw window start times
    xmin=min(x1);
    xmax=max(x1);
    klrs=get(hax1,'colororder');
    lw=1;
    line([xmin xmax],[tnots(1) tnots(1)],'color',klrs(2,:),'linestyle','--','buttondownfcn','seisplottvs_two(''dragline'');','tag','1','linewidth',lw);
    line([xmin xmax],[tnots(1)+twins(1) tnots(1)+twins(1)],'color',klrs(2,:),'linestyle',':','buttondownfcn','seisplottvs_two(''dragline'');','tag','1b','linewidth',lw);
    line([xmin xmax],[tnots(2) tnots(2)],'color',klrs(3,:),'linestyle','--','buttondownfcn','seisplottvs_two(''dragline'');','tag','2','linewidth',lw);
    line([xmin xmax],[tnots(2)+twins(2) tnots(2)+twins(2)],'color',klrs(3,:),'linestyle',':','buttondownfcn','seisplottvs_two(''dragline'');','tag','2b','linewidth',lw);
    line([xmin xmax],[tnots(3) tnots(3)],'color',klrs(4,:),'linestyle','--','buttondownfcn','seisplottvs_two(''dragline'');','tag','3','linewidth',lw);
    line([xmin xmax],[tnots(3)+twins(3) tnots(3)+twins(3)],'color',klrs(4,:),'linestyle',':','buttondownfcn','seisplottvs_two(''dragline'');','tag','3b','linewidth',lw);
    
    %x boundary lines
    xdel=.01*(xmax-xmin);
    line([xmin+xdel xmin+xdel],[tmin tmax],'color','k','linestyle','--','buttondownfcn','seisplottvs_two(''dragline'');','tag','x1','linewidth',lw);
    line([xmax-xdel xmax-xdel],[tmin tmax],'color','k','linestyle','--','buttondownfcn','seisplottvs_two(''dragline'');','tag','x2','linewidth',lw);
    boldlines(hfig,4,2); %make lines and symbols "fatter"
    maxmeters=7000;
    
    if(max(t1)<10)
        ylabel('time (s)')
    elseif(max(t1)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    if(max(x1)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    %make a button to reset time windows to the global values
    xnow=xnot+xwid;
    wid=.055;ht=.05;sep=.005;
    ynow=ynot+yht+sep;
    uicontrol(hfig,'style','pushbutton','string','Reset windows to globals','units','normalized',...
        'position',[xnow,ynow+ht,1.5*wid,.5*ht],'callback','seisplottvs_two(''resetwindows'')','tag','resetwin',...
        'tooltipstring','Resets windows to the most recent published values');
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+2*ht,.5*wid,.5*ht],'callback','seisplottvs_two(''info'');',...
        'backgroundcolor','y');
    %make a clip control
    wid=.055;ht=.05;
    ynow=ynot+yht-ht;
    xnow=xnot-2*wid;
    wid=.055;ht=.05;
    htclip=2*ht;
    clim1=[-3 3];
    clim2=clim1;
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clipxt',...
        'userdata',{ampinfo1,ampinfo2,hax1,tnots,twins,fmax,clim1,clim2},'title','Clipping');
    data={clim1,hax1};
    callback='seisplottvs_two(''clipxt'');';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;
%     ynow=ynot+yht-ht;
%     uicontrol(hfig,'style','popupmenu','string',clipstr,'tag','clipxt','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplottvs_two(''clipxt'');','value',iclip,...
%         'userdata',{ampinfo1,ampinfo2,hax1,tnots,twins,fmax},'tooltipstring',...
%         'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid+.75*xsep ynot .5*xwid yht]);
    set(hax2,'tag','tvs1');
    
    hax3=subplot('position',[xnot+1.5*xwid+xsep ynot .5*xwid yht]);
    set(hax3,'tag','tvs2');

    %make a clip control
    xnow=xnot+2*xwid+xsep;
    ht=.025;
    ynow=ynot+yht-ht;
    uicontrol(hfig,'style','pushbutton','string','recompute','tag','recompute','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottvs_two(''recompute'');',...
        'tooltipstring','recompute the spectra');
    ynow=ynow-ht;
    uicontrol(hfig,'style','pushbutton','string','separate spectra','tag','separate','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottvs_two(''separate'');',...
        'tooltipstring','separate the spectra for easier viewing','userdata',0);
     ynow=ynow-ht;
    uicontrol(hfig,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,.5*wid,ht],'tooltipstring','The maximum frequency to show');
    uicontrol(hfig,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],'tooltipstring','Enter a value in Hz.',...
        'callback','seisplottvs_two(''setlims'');','userdata',fnyq);
    ynow=ynow-ht;
    uicontrol(hfig,'style','text','string','db limit:','units','normalized',...
        'position',[xnow,ynow,.5*wid,ht],'tooltipstring','The minimum decibel level to show');
    
    
    bigfig; %enlarge the figure to get more pixels
    seisplottvs_two('recompute');
    yl=get(gca,'ylim');
    dblimmin=yl(1);
    if(~isempty(DBLIM))
        dblim=DBLIM;
    else
        dblim=dblimmin;
    end
    xlim([hax2,hax3],[0 fmax])
    ylim([hax2,hax3],[dblim 0])
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
%     boldlines(hfig,4,2); %make lines and symbols "fatter"
    whitefig;
    uicontrol(hfig,'style','edit','string',num2str(dblim),'units','normalized','tag','dblim',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],'tooltipstring','Enter a negative number',...
        'callback','seisplottvs_two(''setlims'');','userdata',dblimmin);
%     htitle.FontSize=htFontSize;
    
    set(hfig,'name',['TVS analysis for ' dname1 ' & ' dname2],'closerequestfcn','seisplottvs_two(''close'');',...
        'menubar','none','toolbar','figure','numbertitle','off',...
        'userdata',-999.25);%userdata here is just a placeholder to cause plotimage3D to do the right thing
    if(nargout>0)
        datar=cell(1,3);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=hax3;
    end
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    %see if one already exists
    udat=get(hthisfig,'userdata');
    for k=1:length(udat{1})
       if(isgraphics(udat{1}(k)))
          if(strcmp(get(udat{1}(k),'tag'),'info'))
              figure(udat{1}(k))
              return;
          end
       end
    end
    if(strcmp(get(hthisfig,'tag'),'fromenhance'))
        session=' ENHANCE ';
    else
        session=' MATLAB ';
    end
    msg={['The spectral windows are indicated by the colored horizontal lines on the seismic image. ',...
        'The colors of the spectra match the colors of the corresponding lines except for the ',...
        'blue spectrum which is always the total trace. For each spectral window, the dashed ',...
        'line is the top and the dotted line is the bottom. Click (left button) on any of these ',...
        'lines and drag them to new positions.'],' ',['If you wish to move the window but retain its size ',...
        'then right-click on either the top or bottom and drag.'],' ',['The computed spectra are always ',...
        'spatial averages over the traces bounded by the vertical dashed black lines. You can ',...
        'click and drag these also.'],' ',['After adjusting the lines, push "recompute" to recalculate ',...
        'the spectra.'],' ',['When you adjust the windows, the window positions are saved (for the ',...
        'current' session 'session) so that the next invocation of this tool will start with the ',...
        'newly defined windows. The button "reset windows to globals" matters only if you have ',...
        'several of these tools running at once. If you adjust the windows in tool#1 and then ',...
        'wish tool#2 to grab these same windows, then push this button in tool#2 and then push ',...
        '"recompute".'],' ',['The "separate spectra" button simply shifts the spectra apart (vertically) ',...
        'for better viewing. Only when the spectra are combined (not shifted) are they in true ',...
        'relative amplitude to one another. If the legend on the spectra is in the way, you can ',...
        'drag it to a new position.']};
    hinfo=showinfo(msg,'Instructions for Time-variant spectra');
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        ikill=length(udat{1});
        for k=1:length(udat{1})
           if(~isgraphics(udat{1}))
               ikill(k)=1;
           end
        end
        udat{1}(ikill)=[];
        udat{1}=[udat{1} hinfo];
    else
        udat={hinfo udat};
    end
    set(hthisfig,'userdata',udat);
    
elseif(strcmp(action,'clipxt'))
    hfig=gcf;
    hsections=findobj(hfig,'tag','sections');
    isect=hsections.Value;
    hclip=findobj(hfig,'tag','clipxt');
    udat=hclip.UserData;
    clim=cliptool('getlims',hclip);
    if(isect==1)
        udat{7}=clim;
    else
        udat{8}=clim;
    end
    hclip.UserData=udat;

elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{3};
%     tnots=udat{7};
    twins=udat{5};
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
    hx1=findobj(haxe,'tag','x1');
    xx=get(hx1,'xdata');
    x1=xx(1);
    hx2=findobj(haxe,'tag','x2');
    xx=get(hx2,'xdata');
    x2=xx(1);
    
    hi=findobj(haxe,'type','image');
    t=get(hi,'ydata');
    x=get(hi,'xdata');
    tmin=t(1);tmax=t(end);
    xmin=min(x);xmax=max(x);
    xdel=.01*(xmax-xmin);
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
    elseif(hnow==hx1)
        %clicked on x1
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[xmin+xdel x2-xdel];
        DRAGLINE_PAIRED=hx2;
    elseif(hnow==hx2)
        %clicked on x2
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[x1+xdel xmax-xdel];
        DRAGLINE_PAIRED=hx1;
    end
    
    dragline('click')
    
elseif(strcmp(action,'resetwindows'))
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{6};
    
    tglobal=SANE_TIMEWINDOWS;
    tnots=tglobal(:,1);
    t2s=tglobal(:,2);
    
    h1=findobj(haxe,'tag','1');
    set(h1,'ydata',[tnots(1) tnots(1)]);
    h1b=findobj(haxe,'tag','1b');
    set(h1b,'ydata',[t2s(1) t2s(1)]);
    h2=findobj(haxe,'tag','2');
    set(h2,'ydata',[tnots(2) tnots(2)]);
    h2b=findobj(haxe,'tag','2b');
    set(h2b,'ydata',[t2s(2) t2s(2)]);
    h3=findobj(haxe,'tag','3');
    set(h3,'ydata',[tnots(3) tnots(3)]);
    h3b=findobj(haxe,'tag','3b');
    set(h3b,'ydata',[t2s(3) t2s(3)]);
    
elseif(strcmp(action,'setlims'))
    hfmax=findobj(gcf,'tag','fmax');
    hdblim=findobj(gcf,'tag','dblim');
    tmp=get(hfmax,'string');
    fmax=str2double(tmp);
    fnyq1=get(hfmax,'userdata');
    if(isnan(fmax) || fmax>fnyq1 || fmax<0)
        fmax=fnyq1;
        set(hfmax,'string',num2str(fmax));
    end
    tmp=get(hdblim,'string');
    dblim=str2double(tmp);
    if(isnan(dblim))
        dblim=get(hdblim,'userdata');
        set(hdblim,'string',num2str(dblim));
    end
    if(dblim>0)
        dblim=-dblim;
        set(hdblim,'string',num2str(dblim));
    end
    htvs=findobj(gcf,'tag','tvs1');
    axes(htvs);
    xlim([0 fmax]);
    ylim([dblim 0]);
    htvs=findobj(gcf,'tag','tvs2');
    axes(htvs);
    xlim([0 fmax]);
    ylim([dblim 0]);
    
    FMAX=fmax;
    DBLIM=dblim;
    
elseif(strcmp(action,'recompute'))
    hfig=gcf;
    hclipxt=findobj(hfig,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    hax1=udat{3};
    tnots=udat{4};
    twins=udat{5};
%     dname=udat{10};
    dbflag=1;
    %fmax
    hfmax=findobj(hfig,'tag','fmax');
    fmax=str2double(get(hfmax,'string'));

    %dblim
    hdblim=findobj(hfig,'tag','dblim');
    dblim=str2double(get(hdblim,'string'));
    
    h1=findobj(hax1,'tag','1');
    yy=get(h1,'ydata');
    tnots(1)=yy(1);
    h1b=findobj(hax1,'tag','1b');
    yy=get(h1b,'ydata');
    twins(1)=yy(1)-tnots(1);
    
    h2=findobj(hax1,'tag','2');
    yy=get(h2,'ydata');
    tnots(2)=yy(1);
    h2b=findobj(hax1,'tag','2b');
    yy=get(h2b,'ydata');
    twins(2)=yy(1) -tnots(2);
    
    h3=findobj(hax1,'tag','3');
    yy=get(h3,'ydata');
    tnots(3)=yy(1);
    h3b=findobj(hax1,'tag','3b');
    yy=get(h3b,'ydata');
    twins(3)=yy(1)-tnots(3);
    
    %space limits
    hx1=findobj(hax1,'tag','x1');
    xx=get(hx1,'xdata');
    x1=xx(1);
    hx2=findobj(hax1,'tag','x2');
    xx=get(hx2,'xdata');
    x2=xx(1);
    
    
    udat{4}=tnots;
    udat{5}=twins;
    set(hclipxt,'userdata',udat);
    
    t2s=tnots+twins;
    
    SANE_TIMEWINDOWS=[tnots(:) t2s(:)];
    %first axis
    hsection=findobj(hfig,'tag','sections');
    udat=hsection.UserData;
    seis=udat{1};
    t=udat{3};
    x=udat{5};
    ix=near(x,x1,x2);
    [dname,fs]=processname(udat{7});
%     hi=findobj(hax1,'type','image');
%     seis=get(hi,'cdata');
%     t=get(hi,'ydata');
%     x=get(hi,'xdata');
%     indx=near(x,x1,x2);
    
    hax2=findobj(hfig,'tag','tvs1');
    tpad=2*max(twins);
    tvdbspec(t,seis(:,ix),tnots,twins,tpad,'',hax2,dbflag);
    ht=enTitle(dname,'interprete','none');
    ht.FontSize=fs;
    set(hax2,'tag','tvs1');
    boldlines(hax2,4,2);
%     bigfont(hax2,1.08,1);
    xlim([0 fmax])
    if(isnan(dblim))
        dblim=-100;
    end
    ylim([dblim 0])
    xt=hax2.XTick;
    hax2.XTick=xt(1:end-1);
    
    %second axis
    seis=udat{2};
    t=udat{4};
    x=udat{6};
    ix=near(x,x1,x2);
    [dname,fs]=processname(udat{8});
%     hi=findobj(hax1,'type','image');
%     seis=get(hi,'cdata');
%     t=get(hi,'ydata');
%     x=get(hi,'xdata');
%     indx=near(x,x1,x2);
    
    hax3=findobj(hfig,'tag','tvs2');
    tpad=2*max(twins);
    tvdbspec(t,seis(:,ix),tnots,twins,tpad,'',hax3,dbflag);
    ht=enTitle(dname,'interprete','none');
    ht.FontSize=fs;
    set(hax3,'tag','tvs2');
    boldlines(hax3,4,2);
%     bigfont(hax3,1.08,1);
    xlim([0 fmax])
    if(isnan(dblim))
        dblim=-100;
    end
    ylim([dblim 0])
    hax3.YTickLabel='';
    ylabel('');
    
    
    hsep=findobj(hfig,'tag','separate');
    set(hsep,'string','separate spectra','userdata',0)
elseif(strcmp(action,'select'))
    hfig=gcf;
    hclip=findobj(hfig,'tag','clipxt');
    udat=hclip.UserData;
    hsections=findobj(hfig,'tag','sections');
    ud=hsections.UserData;
    isect=hsections.Value;
    if(isect==1)
        seis=ud{1};
        t=ud{3};
        x=ud{5};
        cmap=ud{9};
        clim=udat{7};
    else
        seis=ud{2};
        t=ud{4};
        x=ud{6};
        cmap=ud{10};
        clim=udat{8};
    end
    hax=findobj(hfig,'tag','seis');
    hi=findobj(hax,'type','image');
    set(hi,'xdata',x,'ydata',t,'cdata',seis);
    set(hax,'colormap',cmap);
    xl=[min(x) max(x)];
    xlim(hax,xl);
    h=findobj(hax,'tag','1');
    h.XData=xl;
    h=findobj(hax,'tag','1b');
    h.XData=xl;
    h=findobj(hax,'tag','2');
    h.XData=xl;
    h=findobj(hax,'tag','2b');
    h.XData=xl;
    h=findobj(hax,'tag','3');
    h.XData=xl;
    h=findobj(hax,'tag','3b');
    h.XData=xl;
    del=.01*diff(xl);
    h=findobj(hax,'tag','x1');
    h.XData=[xl(1)+del xl(1)+del];
    h=findobj(hax,'tag','x2');
    h.XData=[xl(2)-del xl(2)-del];
    clipdat={clim,hax};
    cliptool('refresh',hclip,clipdat);
elseif(strcmp(action,'separate'))
    hsep=gcbo;
    sep=get(hsep,'userdata');
    if(sep==0)
        %we are separating
        hax=findobj(gcf,'tag','tvs1');
        yl=get(hax,'ylim');
        sep=round(abs(diff(yl))/10);
        hl=findobj(hax,'type','line');
        yl=get(hl(1),'ydata');
        set(hl(1),'ydata',yl-3*sep);
        yl=get(hl(2),'ydata');
        set(hl(2),'ydata',yl-2*sep);
        yl=get(hl(3),'ydata');
        set(hl(3),'ydata',yl-sep);
        hax=findobj(gcf,'tag','tvs2');
        yl=get(hax,'ylim');
        sep=round(abs(diff(yl))/10);
        hl=findobj(hax,'type','line');
        yl=get(hl(1),'ydata');
        set(hl(1),'ydata',yl-3*sep);
        yl=get(hl(2),'ydata');
        set(hl(2),'ydata',yl-2*sep);
        yl=get(hl(3),'ydata');
        set(hl(3),'ydata',yl-sep);
        set(hsep,'userdata',sep);
        set(hsep,'string','combine spectra')
    else
        %we are un-separating
        hax=findobj(gcf,'tag','tvs1');
        hl=findobj(hax,'type','line');
        yl=get(hl(1),'ydata');
        set(hl(1),'ydata',yl+3*sep);
        yl=get(hl(2),'ydata');
        set(hl(2),'ydata',yl+2*sep);
        yl=get(hl(3),'ydata');
        set(hl(3),'ydata',yl+sep);
        hax=findobj(gcf,'tag','tvs2');
        hl=findobj(hax,'type','line');
        yl=get(hl(1),'ydata');
        set(hl(1),'ydata',yl+3*sep);
        yl=get(hl(2),'ydata');
        set(hl(2),'ydata',yl+2*sep);
        yl=get(hl(3),'ydata');
        set(hl(3),'ydata',yl+sep);
        set(hsep,'userdata',0);
        set(hsep,'string','separate spectra')
    end
elseif(strcmp(action,'close'))
    hfig=gcf;
    tmp=get(gcf,'userdata');
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

function fontchange(~,~)
hm=gcbo;
tag=hm.Label;
scalar=str2double(tag(2:end));
hsection=findobj(gcf,'tag','sections');
hsection.FontSize=scalar*hsection.FontSize;
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

function [dname,fs]=processname(dname)
if(iscell(dname))
    dname=[dname{1} ' ' dname{2}];
end
Nd=length(dname);
fs=16;
if(Nd>30 && Nd<40)
    fs=12;
elseif(Nd>30 && Nd<50)
    fs=9;
    ind=strfind(dname,',');
    if(~isempty(ind))
        ii=near(ind,round(Nd/2));
        str1=dname(1:ind(ii(1)));
        str2=dname(ind(ii(1))+1:end);
    else
        str1=dname(1:round(Nd/2));
        str2=dname(round(Nd/2)+1:end);
    end
    dname={str1,str2};
elseif(Nd>30)
    fs=7;
    ind=strfind(dname,',');
    if(~isempty(ind))
        ii=near(ind,round(Nd/2));
        str1=dname(1:ind(ii(1)));
        str2=dname(ind(ii(1))+1:end);
    else
        str1=dname(1:round(Nd/2));
        str2=dname(round(Nd/2)+1:end);
    end
    dname={str1,str2};
end
end

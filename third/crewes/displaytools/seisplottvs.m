function datar=seisplottvs(seis,t,x,dname,t1s,twins,fmax)
% SEISPLOTTVS: plots a seismic gather and its frequency spectrum in time windows
%
% datar=seisplottvs(seis,t,x,dname,t1s,twins,fmax)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The seismic gather is
% plotted as an image in the left-hand-side and its temporal amplitude spectra in different time
% windows are plotted in the right-hand-side. Controls are provided to adjust the clipping and to
% brighten or darken the image plots.
%
% seis ... input seismic matrix
% t ... time coordinate vector for seis. This is the row coordinate of seis. 
% x ... space coordinate vector for seis
% dname ... text string giving a name for the dataset that will annotate
%       the plots.
% ************ default dname =[] ************
% t1s ... vector of 3 window start times (nan gets default)
% ********** default = [t(1) t(1)+twin t(2)+2*twin] where twin=(t(end)-t(1))/3 *********
% twins ... vector of 3 window lengths (nan gets default)
% ********** default = [twin twin twin] *************
% fmax ... maximum frequency to include on the frequency axis.
% ************ default = .5/(t(2)-t(1)) which is Nyquist ***********
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the spectral axes
%
% G.F. Margrave, Margrave-Geo, 2017-2019
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

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_XLIMSR DRAGLINE_YLIMS DRAGLINE_YLIMSR DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED
global SANE_TIMEWINDOWS
global FMAX DBLIM
global NEWFIGVIS

if(~ischar(seis))
    action='init';
else
    action=seis;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    cmap=get(gca,'colormap');
    if(isdeployed)
        if(length(t)~=size(seis,1))
            hm=msgbox({'Array dimension mismatch',['Length(t) = ' int2str(length(t))],...
                [' size(seis,1)= ' int2str(size(seis,1))],'Try exiting and restarting Enhance'});
            WinOnTop(hm,true)
            return;
        end
        
        
        if(length(x)~=size(seis,2))
            hm=msgbox({'Array dimension mismatch',['Length(x) = ' int2str(length(x))],...
                [' size(seis,2)= ' int2str(size(seis,2))],'Try exiting and restarting Enhance'});
            WinOnTop(hm,true)
            return;
        end
    else
        if(length(t)~=size(seis,1))
            error('time coordinate vector does not match seismic');
        end
        if(length(x)~=size(seis,2))
            error('space coordinate vector does not match seismic');
        end
    end
    
    if(nargin<4)
        dname=[];
    end
    if(nargin<5)
        t1s=nan;
    end
    if(nargin<6)
        twins=nan;
    end
    
    if(any(isnan(t1s)) || any(isnan(twins)))
        if(~isempty(SANE_TIMEWINDOWS))
            tmp=SANE_TIMEWINDOWS(:,2);
            if(all(tmp<t(end)))
                t1s=SANE_TIMEWINDOWS(:,1)';
                t2s=SANE_TIMEWINDOWS(:,2)';
                twins=t2s-t1s;
            else
                twin=(t(end)-t(1))/3;
                twins=twin*ones(1,3);
            end
        else
            twin=(t(end)-t(1))/3;
            t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
            twins=twin*ones(1,3);
        end
    end
    
    if(any(t1s<t(1)))
        t1s=nan;
    end
    if(any(t1s>t(end)))
        t1s=nan;
    end
    
    if(any(isnan(t1s)))
        twin=(t(end)-t(1))/3;
        t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
        twins=twin*ones(1,3);
    end
    if(any(isnan(twins)))
        twin=(t(end)-t(1))/3;
        twins=twin*ones(1,3);
    end
    
    if(length(t1s)~=3 || length(twins)~=3)
        error('t1s and twins must be length 3');
    end
    
    fnyq=.5/(t(2)-t(1));
    
    if(nargin<7)
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
%            [~,cmapname1,iflip1]=enhancecolormap('sections');
       end

    end
    if(notfromenhance)
       enhancetag='';
       udat=[]; 
    end

    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    
    set(hfig,'tag',enhancetag,'userdata',udat);
    
    hax1=subplot('position',[xnot ynot xwid yht]);

    imagesc(x,t,seis);colormap(cmap);
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
    line([xmin xmax],[t1s(1) t1s(1)],'color',klrs(2,:),'linestyle','--','buttondownfcn','seisplottvs(''dragline'');','tag','1','linewidth',lw);
    line([xmin xmax],[t1s(1)+twins(1) t1s(1)+twins(1)],'color',klrs(2,:),'linestyle',':','buttondownfcn','seisplottvs(''dragline'');','tag','1b','linewidth',lw);
    line([xmin xmax],[t1s(2) t1s(2)],'color',klrs(3,:),'linestyle','--','buttondownfcn','seisplottvs(''dragline'');','tag','2','linewidth',lw);
    line([xmin xmax],[t1s(2)+twins(2) t1s(2)+twins(2)],'color',klrs(3,:),'linestyle',':','buttondownfcn','seisplottvs(''dragline'');','tag','2b','linewidth',lw);
    line([xmin xmax],[t1s(3) t1s(3)],'color',klrs(4,:),'linestyle','--','buttondownfcn','seisplottvs(''dragline'');','tag','3','linewidth',lw);
    line([xmin xmax],[t1s(3)+twins(3) t1s(3)+twins(3)],'color',klrs(4,:),'linestyle',':','buttondownfcn','seisplottvs(''dragline'');','tag','3b','linewidth',lw);
    
    %x boundary lines
    tmin=min(t);
    tmax=max(t);
    xdel=.01*(xmax-xmin);
    line([xmin+xdel xmin+xdel],[tmin tmax],'color','k','linestyle','--','buttondownfcn','seisplottvs(''dragline'');','tag','x1','linewidth',lw);
    line([xmax-xdel xmax-xdel],[tmin tmax],'color','k','linestyle','--','buttondownfcn','seisplottvs(''dragline'');','tag','x2','linewidth',lw);
    boldlines(hfig,4,2); %make lines and symbols "fatter"
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
    xnow=xnot-2.5*wid;
    ynow=ynot+yht+sep;
    uicontrol(hfig,'style','pushbutton','string','Reset windows to globals','units','normalized',...
        'position',[xnow,ynow+ht,1.7*wid,.5*ht],'callback','seisplottvs(''resetwindows'');','tag','resetwing',...
        'tooltipstring','Resets windows to the most recent published values');
    uicontrol(hfig,'style','pushbutton','string','Reset windows to default','units','normalized',...
        'position',[xnow,ynow+.5*ht,1.7*wid,.5*ht],'callback','seisplottvs(''resetwindows'');','tag','resetwind',...
        'tooltipstring','Resets windows to the default values');
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+2*ht,.5*wid,.5*ht],'callback','seisplottvs(''info'');',...
        'backgroundcolor','y');
    %make a clip control
    htclip=2*ht;
    ynow=ynot+yht-htclip;
%     [N,xn,sigma,am,amax,amin]=getampinfo(seis1);
    hclip=uipanel(hfig,'position',[xnow,ynow,2*wid,htclip],'tag','clipxt',...
        'userdata',hax1,'title','Clipping','userdata',{hax1,t1s,twins,fmax,dname});
    data={[-3 3],hax1};
    callback='';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;
    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);
    set(hax2,'tag','tvs');
    
    xnow=xnot+2*xwid+xsep;
    ht=.025;
    ynow=ynot+yht-ht;
    uicontrol(hfig,'style','pushbutton','string','recompute','tag','recompute','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottvs(''recompute'');',...
        'tooltipstring','recompute the spectra');
    ynow=ynow-ht;
    uicontrol(hfig,'style','pushbutton','string','separate spectra','tag','separate','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottvs(''separate'');',...
        'tooltipstring','separate the spectra for easier viewing','userdata',0);
     ynow=ynow-ht;
    uicontrol(hfig,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow-.25*ht,.5*wid,ht],'tooltipstring','The maximum frequency to show');
    uicontrol(hfig,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],...
        'tooltipstring',['Enter a value in Hz. between 0 and ' num2str(fnyq)],...
        'callback','seisplottvs(''setlims'');','userdata',fnyq);
    ynow=ynow-ht;
    uicontrol(hfig,'style','radiobutton','string','decibels','units','normalized','tag','decibels',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','decibels or normal amplitude',...
        'value',1,'callback','seisplottvs(''recompute'');');
    ynow=ynow-ht;
    uicontrol(hfig,'style','text','string','db limit:','units','normalized',...
        'position',[xnow,ynow-.25*ht,.5*wid,ht],'tooltipstring','The minimum decibel level to show');
    
    
    bigfig; %enlarge the figure to get more pixels
    seisplottvs('recompute');
    yl=get(gca,'ylim');
    dblimmin=yl(1);
    if(~isempty(DBLIM))
        dblim=DBLIM;
    else
        dblim=dblimmin;
    end
    xlim([0 fmax])
    ylim([dblim 0])
%     bigfont(hfig,1.2,1); %enlarge the fonts in the figure
%     boldlines(hfig,4,2); %make lines and symbols "fatter"
%     whitefig;
    uicontrol(hfig,'style','edit','string',num2str(dblim),'units','normalized','tag','dblim',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],'tooltipstring','Enter a negative number',...
        'callback','seisplottvs(''setlims'');','userdata',dblimmin);
    htitle.FontSize=htFontSize;
    
    set(hfig,'name',['TVS analysis for ' dname],'closerequestfcn','seisplottvs(''close'');',...
        'menubar','none','toolbar','figure','numbertitle','off');%userdata here is just a placeholder to cause plotimage3D to do the right thing
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    %see if one already exists
    udat=get(hthisfig,'userdata');
    if(~isempty(udat))
        for k=1:length(udat{1})
            if(isgraphics(udat{1}(k)))
                if(strcmp(get(udat{1}(k),'tag'),'info'))
                    figure(udat{1}(k))
                    return;
                end
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

elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{1};
%     t1s=udat{2};
    twins=udat{3};
    twinmin=.1*min(twins);
    
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
        tsep=t1b-t1;
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin+twinmin t1b-twinmin];
        DRAGLINE_YLIMSR=[tmin+twinmin tmax-tsep-twinmin];
        DRAGLINE_PAIRED=h1b;
    elseif(hnow==h2)
        %clicked on t2
        tsep=t2b-t2;
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin+twinmin t2b-twinmin];
        DRAGLINE_YLIMSR=[tmin+twinmin tmax-twinmin-tsep];
        DRAGLINE_PAIRED=h2b;
    elseif(hnow==h3)
        %clicked on t3
        tsep=t3b-t3;
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin+twinmin t3b-twinmin];
        DRAGLINE_YLIMSR=[tmin+twinmin tmax-twinmin-tsep];
        DRAGLINE_PAIRED=h3b;
    elseif(hnow==h1b)
        %clicked on t1b
        tsep=t1b-t1;
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t1+twinmin tmax-twinmin];
        DRAGLINE_YLIMSR=[tmin+twinmin+tsep tmax-twinmin];
        DRAGLINE_PAIRED=h1;
    elseif(hnow==h2b)
        %clicked on t2b
        tsep=t2b-t2;
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t2+twinmin tmax-twinmin];
        DRAGLINE_YLIMSR=[tmin+twinmin+tsep tmax-twinmin];
        DRAGLINE_PAIRED=h2;
    elseif(hnow==h3b)
        %clicked on t3b
        tsep=t3b-t3;
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t3+twinmin tmax-twinmin];
        DRAGLINE_YLIMSR=[tmin+twinmin+tsep tmax-twinmin];
        DRAGLINE_PAIRED=h3;
    elseif(hnow==hx1)
        %clicked on x1;
        xsep=x2-x1;
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[xmin+xdel x2-xdel];
        DRAGLINE_XLIMSR=[xmin+xdel xmax-xdel-xsep];
        DRAGLINE_PAIRED=hx2;
    elseif(hnow==hx2)
        %clicked on x2
        xsep=x2-x1;
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[x1+xdel xmax-xdel];
        DRAGLINE_XLIMSR=[xmin+xdel+xsep xmax-xdel];
        DRAGLINE_PAIRED=hx1;
    end
    
    dragline('click')
    
elseif(strcmp(action,'resetwindows'))
    hreset=gcbo;
    tag=hreset.Tag;
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{1};
    switch tag
        case 'resetwing'
            tglobal=SANE_TIMEWINDOWS;
            t1s=tglobal(:,1);
            t2s=tglobal(:,2);
            
        case 'resetwind'
            hi=findobj(haxe,'type','image');
            t=get(hi,'ydata');
            twin=(t(end)-t(1))/3;
            t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
            t2s=t1s+twin;
    end
    
    
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
    
    udat{2}=t1s;
    udat{3}=t2s-t1s;
    hclipxt.UserData=udat;
    
    seisplottvs('recompute');
elseif(strcmp(action,'setlims'))
    hfmax=findobj(gcf,'tag','fmax');
    hdblim=findobj(gcf,'tag','dblim');
    tmp=get(hfmax,'string');
    fmax=str2double(tmp);
    fnyq=get(hfmax,'userdata');
    if(isnan(fmax) || fmax>fnyq || fmax<0)
        fmax=fnyq;
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
    htvs=findobj(gcf,'tag','tvs');
    axes(htvs);
    xlim([0 fmax]);
    ylim([dblim 0]);
    
    FMAX=fmax;
    DBLIM=dblim;
    
elseif(strcmp(action,'recompute'))
    hfig=gcf;
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    hax1=udat{1};
    t1s=udat{2};
    twins=udat{3};
    hdb=findobj(hfig,'tag','decibels');
    dbflag=hdb.Value;
    %fmax
    hfmax=findobj(hfig,'tag','fmax');
    fmax=str2double(get(hfmax,'string'));
    %dblim
    hdblim=findobj(hfig,'tag','dblim');
    dblim=str2double(get(hdblim,'string'));
    
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
    
    hx1=findobj(hax1,'tag','x1');
    xx=get(hx1,'xdata');
    x1=xx(1);
    hx2=findobj(hax1,'tag','x2');
    xx=get(hx2,'xdata');
    x2=xx(1);
    
    
    udat{2}=t1s;
    udat{3}=twins;
    set(hclipxt,'userdata',udat);
    
    t2s=t1s+twins;
    
    SANE_TIMEWINDOWS=[t1s(:) t2s(:)];
    
    hi=findobj(hax1,'type','image');
    seis=get(hi,'cdata');
    t=get(hi,'ydata');
    x=get(hi,'xdata');
    indx=near(x,x1,x2);
    
    hax2=findobj(hfig,'tag','tvs');
    tpad=2*max(twins);
    tvdbspec(t,seis,t1s,twins,tpad,'',hax2,dbflag,indx);
    ht=get(hax2,'title');
    str=ht.String;
    ht.String={str,'Spatial average between the vertical black lines'};
    set(hax2,'tag','tvs');
    boldlines(hax2,4,2);
    bigfont(hax2,1.08,1);
    xlim([0 fmax])
    if(dbflag)
        if(isnan(dblim))
            dblim=-100;
        end
        ylim([dblim 0])
    end
    
    hsep=findobj(gcf,'tag','separate');
    set(hsep,'string','separate spectra','userdata',0)

elseif(strcmp(action,'separate'))
    hsep=gcbo;
    sep=get(hsep,'userdata');
    if(sep==0)
        %we are separating
        hax2=findobj(gcf,'tag','tvs');
        yl=get(hax2,'ylim');
        sep=round(abs(diff(yl))/10);
        hl=findobj(hax2,'type','line');
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
        hax2=findobj(gcf,'tag','tvs');
        hl=findobj(hax2,'type','line');
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


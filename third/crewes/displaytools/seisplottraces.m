function rarg=seisplottraces(seis,t,x,dname,arg5)
%
% on the initial call, arg5 determines pixels per second for vertical size.
% on later call it is a secondary name (dname2=>string).
%
% Have only one possible seisplottraces window. First call opens the window. 
% Subsequent calls add additional traces.
% 1) plot one or more traces each in its own axes
% 2) spectra option by right click on trace
% 3) accept additional traces
% 4) delete traces
% 5) each trace has a name
% 6) plottraces (internal) plots each trace in its own axis
% 7) window size adapts to the number of traces
% 8) use tab panels to separate time and depth and frequency traces
% 
% Secondary external calls:
% seisplottraces('register',hthisfig,hfig); register the figure
% pt=seisplottraces('getlocation',flag); %get the current location
% seisplottraces('addpptbutton'); guess what?
% 
global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED %#ok<NUSED>
global SEISPLOTTRACES_FIG
if(~ischar(seis))
    action='init';
else
    action=seis;
end
rarg=[];
if(strcmp(action,'init'))
    if(isgraphics(SEISPLOTTRACES_FIG))
        seisplottraces('more',seis,t,x,dname);
        return;
    end
    if(iscell(dname))
        dname=dname{1};
    end
    ylbl=get(get(gca,'ylabel'),'string');
    ntraces=1;%this may not be the actual number of traces but it means 1 group.
    %determine window size and orientation
    hfigm=gcf;%masterfig
    U=hfigm.Units;
    hfigm.Units='pixels';
    posfig=get(hfigm,'position');%dimensions of calling figure in pixels
    hfigm.Units=U;
    FHT=posfig(4);
    FWDM=posfig(3);
    ss=get(0,'screensize');
    %plan. Initial height of the figure will match the calling figure. Width will be determined by
    %the "number of traces" which is really groups of traces since browsers can pass a group. Each
    %trace group TG will get the same amount of space which is wdtg=pixpertrace*(1+xfact) where
    %pixpertrace is the pixels allocated to trace display (~150) and xfact~.6 allows space for annotation.
    %Let FHT=height of calling figure, then the top .075*FHT is reserved for controls. This leaves
    %.925*FHT=PHT for the trace panel. Then, the axis height inside the panel is .8*FHT =
    %.8*PHT/.925 = 
    %.865*PHT. This leaves (1-.865)*PHT for annotation which I split evenly on top and on bottom. 
    %The panel width PWD will be nor larger than the figure width less 10 pixels on either side. Put
    %another way PWD=NTG*wdtg (NTG is number of trace groups) and FWD=PWD+20 in pixels. If FWDM is
    %the max allowed width (==width of calling figure) then when PWD>FWDM-20 the panel wis placed in
    %replaced by a scrolling panel using uiscrollpanel_hor.
    pixpertrace=150;
    pixpersec=arg5;
    xfact=.75;
    TGWD=pixpertrace*(1+xfact);%width per TG
    PWD=TGWD;%initially there is one trace group. The "more" action accounts for more.
    PWBDR=10;%border width around panel
    FWD=PWD+2*PWBDR;
    CHT=.075*FHT;%space at top for controls
    PHT=.925*FHT;%panel height
    AHT=min([.865*PHT pixpersec*(t(end)-t(1))]);%Axis height
    ABDR=PHT-AHT;%border axes space.
    SLDRVALUE=1;%just a place holder until there are enough traces to fill the panel and a slider is created
    geom=[pixpersec,pixpertrace,FWD,FHT,xfact,TGWD,PWD,PHT,CHT,AHT,ABDR,FWDM,PWBDR,SLDRVALUE];
    
    %the "more" action updates PWD and FWD and resizes the figure
    %plottraces makes the trace panel and decides if it needs to be scrolling or not.
    border=200;
    x0=round(max([.5*(ss(3)-FWD) .5*border]));%position of lower left corner of figure
    y0=round(max([.5*(ss(4)-FHT) .5*border]));

    hfig=figure;
    SEISPLOTTRACES_FIG=hfig; 
    set(hfig,'position',[x0 y0 FWD FHT],'name','Trace Inspector','numbertitle','off',...
        'menubar','none','toolbar','figure','closerequestfcn','seisplottraces(''close'');',...
        'tag','');
    mtraces=size(seis,2);
    names=cell(1,mtraces);
    tmin=t(1);
    tmax=t(end);
    for k=1:mtraces
        names{k}=[dname ' @ ' num2str(x(k))];%trace names
    end
    inorm=0;
    ttop=tmin+(tmax-tmin)/4;
    tbot=tmax-(tmax-tmin)/4;
    tnorms=[ttop tbot];
    ind=near(t,ttop,tbot);
    amax=0;
    amaxall=0;
    for k=1:ntraces
        a1=max(abs(seis(ind,k)));
        a2=max(abs(seis(:,k)));
        if(a1>amax)
            amax=a1;
        end
        if(a2>amaxall)
            amaxall=a2;
        end
    end
    
    %info button
    pixht=25;
    pixwid=50;
    ht=pixht/FHT;
    wid=pixwid/FWD;
    xsep=wid/2;
    xnow=.5*wid;
%     ynow=(htax-2*hybdr)/ysize;
    ynow=.930;
    hinfo=uicontrol(hfig,'style','pushbutton','string','info','backgroundcolor','y','units','normalized',...
        'tag','info','position',[xnow,ynow,wid,ht],'callback','seisplottraces(''info'');');
    set(hinfo,'userdata',{{seis},{t},{x},{names},tmin,tmax,[],[],{ylbl},{tnorms}});
    %location display
    iloc=ceil(length(x)/2);
    uicontrol(hfig,'style','text','string',['Location: ' num2str(x(iloc))],'units','normalized','position',...
        [xnow,ynow+ht,1.5*wid,ht],'tag','location','tooltipstring','This is the current "location", left-click on any trace to set.',...
        'userdata',x(end),'horizontalalignment','left');
    %normalize button
    xnow=xnow+wid+xsep;ynow=ynow+.5*ht;
    uicontrol(hfig,'style','radiobutton','string','Normalize traces',...
        'tag','norm','value',inorm,'callback','seisplottraces(''replot'');','units','normalized',...
        'position',[xnow,ynow,3*wid,.6*ht],'tooltipstring','Adjust each trace to max amp of 1',...
        'userdata',geom);

    %show names button
    uicontrol(hfig,'style','radiobutton','string','Show names',...
        'tag','names','value',0,'callback','seisplottraces(''replot'');','units','normalized',...
        'position',[xnow,ynow+.8*ht,3*wid,.6*ht],'tooltipstring','Show the names of each trace');
    
%     set(hnorm,'userdata',[htfig,wdfig,htax,wdax,wxbdr,hybdr,pixpertrace,pixpersec,xfact]);
    
    [htraces,hnames]=plottraces;

    ud=hinfo.UserData;
    ud{7}=htraces;
    ud{8}=hnames;
    hinfo.UserData=ud;
    
%     bigfont(gcf,1.5,1)
    boldlines(gcf,2);
    
elseif(strcmp(action,'close'))
    hfig=gcf;
%     hreplot=findobj(hfig,'tag','replot');
%     hsubfigs=get(hreplot,'userdata');
    ud=get(hfig,'userdata');
    if(isempty(ud))
        delete(hfig)
        return;
    end
    if(iscell(ud))
        hsubfigs=ud{1};
    else
        hsubfigs=ud;
    end
    for k=1:length(hsubfigs)
        if(isgraphics(hsubfigs(k)))
            delete(hsubfigs(k));
        end
    end
    SEISPLOTTRACES_FIG=[];
    if(fromenhance(hfig))
        enhance('deleteview',hfig);
    end
    %this last bit avoids deleting the tool figure if there is another close function to be called
    %(usually PI2D or PI3D)
    crf=get(hfig,'closerequestfcn');
    ind=strfind(crf,';');
    if(ind(1)==length(crf))
        delete(hfig);
    end
elseif(strcmp(action,'more'))
    if(~isgraphics(SEISPLOTTRACES_FIG))
        return;
    end
    ylbl2={get(get(gca,'ylabel'),'string')};
    hfig=SEISPLOTTRACES_FIG;
    figure(hfig);
    %new data
    seis2=t;
    t2=x;
    x2=dname;
    dname2=arg5;
    if(iscell(dname2))
        dname2=dname2{1};
    end
    ntraces2=length(x2);
    names2=cell(1,ntraces2);
    sc2={seis2};
    tc2={t2};
    xc2={x2};
    for k=1:ntraces2
        names2{k}=[dname2 ' @ ' num2str(x2(k))];
    end
    tmin2=t2(1);tmax2=t2(end);
    tnorms2={[tmin2+(tmax2-tmin2)/4, tmax2-(tmax2-tmin2)/4]};
    %get existing data
    hinfo=findobj(hfig,'tag','info');
    udat=get(hinfo,'userdata');
    sc=udat{1};
    tc=udat{2};
    xc=udat{3};
    names=udat{4};
    tmin=udat{5};
    tmax=udat{6};
    ylbl=udat{9};
    tnorms=udat{10};
    %merge data
    scnew=[sc sc2];
    tcnew=[tc tc2];
    xcnew=[xc xc2];
    ylblnew=[ylbl ylbl2];
    tnormsnew=[tnorms tnorms2];
    namesnew=[names {names2}];
    if(tmin2<tmin)
        tmin=tmin2;
    end
    if(tmax2>tmax)
        tmax=tmax2;
    end

    %change buttons to pixels so they don't resize in plottraces
    hbuttons=findobj(hfig,'type','uicontrol');
    posbuttons=get(hbuttons,'position');
    set(hbuttons,'units','pixels');%so buttons don't enlarge
    
    %compute new panel width and figure width, resize figure 
    hnorm=findobj(hfig,'tag','norm');
    geom=hnorm.UserData;
    TGWD=geom(6);%trace group width
    FWDM=geom(12);%maximum allowed figure width
    PWBDR=geom(13);%panel border
    NTG=length(tcnew);%number of trace groups
    PWD=NTG*TGWD;%width of innerpanel
    FWD=min([PWD+2*PWBDR FWDM]);
%     PWD2=FWD-2*PWBDR;
    geom(7)=PWD;
    geom(3)=FWD;
    %for new traces we set the slider value to 1
    geom(14)=1;
    hnorm.UserData=geom;
    
    pos=hfig.Position;
    pos(3)=FWD;
    hfig.Position=pos;
    
    %plot
    ud={scnew,tcnew,xcnew,namesnew,tmin,tmax,[],[],ylblnew,tnormsnew};
    hinfo.UserData=ud;
    [htraces,hnames]=plottraces;
    ud{7}=htraces;
    ud{8}=hnames;
    hinfo.UserData=ud;

    %fix buttons
    %check that all buttons are live because we might have deleted a scrollbar
    for k=1:length(hbuttons)
        if(~isgraphics(hbuttons(k)))
            hbuttons(k)=[];
            posbuttons(k)=[];
        end
    end
    set(hbuttons,'units','normalized')
    for k=1:length(hbuttons)
        pos=get(hbuttons(k),'position');
        pos=[posbuttons{k}(1:2) pos(3:4)];
        set(hbuttons(k),'position',pos);
    end
    
    %update location
    hloc=findobj(hfig,'tag','location');
    iloc=ceil(length(x2)/2);
    set(hloc,'string',['Location: ' num2str(x2(iloc))],'userdata',x2(iloc));
%     bigfont(hfig,1.5,1)
    boldlines(hfig,2);
    

    
elseif(strcmp(action,'replot'))
    if(~isgraphics(SEISPLOTTRACES_FIG))
        return;
    end
    hfig=SEISPLOTTRACES_FIG;
    figure(hfig);
    
    %get existing data
    hinfo=findobj(hfig,'tag','info');
    udat=get(hinfo,'userdata');
    tnorms=udat{10};
    %update tnorms in case the gates have changed
    haxes=findobj(hfig,'type','axes');
    for k=1:length(haxes)
        ht1=findobj(haxes(k),'tag','ttop');
        ht2=findobj(haxes(k),'tag','tbot');
        y1=ht1.YData;
        y2=ht2.YData;
        kay=str2double(haxes(k).Tag);
        tnorms{kay}=[y1(1) y2(1)];
    end
    udat{10}=tnorms;
    
    %preserve slider position
    hnorm=findobj(hfig,'tag','norm');
    geom=hnorm.UserData;
    hseis=findobj(hfig,'tag','seis');
    hslider=findobj(hseis.Parent,'style','slider');
    if(isempty(hslider))
        geom(14)=1;
    else
        geom(14)=hslider.Value;
    end
    hnorm.UserData=geom;
    
    %replot
    hinfo.UserData=udat;
    [htraces,hnames]=plottraces;
    udat{7}=htraces;
    udat{8}=hnames;
    hinfo.UserData=udat;
%     bigfont(gcf,1.5,1)
    boldlines(gcf,2);
elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    
    hseis=gca;
    
    h1=findobj(hseis,'tag','ttop');
    yy=get(h1,'ydata');
    ttop=yy(1);
    
    h2=findobj(hseis,'tag','tbot');
    yy=get(h2,'ydata');
    tbot=yy(2);
    
    tlim=get(hseis,'ylim');
    tmin=tlim(1);tmax=tlim(2);
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='seisplottraces(''replot'');';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on ttop
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin tbot];
        DRAGLINE_PAIRED=h2;
    elseif(hnow==h2)
        %clicked on tbot
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[ttop tmax];
        DRAGLINE_PAIRED=h1;
    end
    
    dragline('click')
    
elseif(strcmp(action,'addpptbutton'))
    hfig=SEISPLOTTRACES_FIG;
    if(~isgraphics(hfig))
        return;
    end
    hppt=findobj(hfig,'tag','ppt');
    if(isempty(hppt))
        %need 30 pixels wide and 25 high
        pos=get(hfig,'position');
        wid=35/pos(3);
        ht=25/pos(4);
        hppt=uicontrol(hfig,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
            'position',[.8,.96,wid,ht],'backgroundcolor','y','callback','enhance(''makepptslide'');');
        set(hppt,'userdata','Trace Inspector');
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
    msg={['The Trace Inspector allows examination of individual traces from most Enhance tool ',...
        'windows. Tools that do not show traces such as those operating on time slices are a major ',...
        'exception. There is always only one Trace Inspector window that accepts traces from any ',...
        'enabled tool. As traces are added to the trace inspector window its width grows to fill ',...
        'the available screen.'],' ',['At the lower right of each trace is a name (if "Show names" is checked) which gives the seismic ',...
        'section name followed by the spatial coordinate of the trace. By default, traces are ',...
        'normalized in the Trace Inspector display meaning that their RMS amplitudes are equalized ',...
        'in the temporal window denoted by the horizontal red lines. You can move these lines to ',...
        'change the equalization window by simply clicking and dragging them. To see the true ',...
        'relative amplitudes of the traces, simply de-select the button labelled "Normalize traces".'],' ',...
        ['A right mouse click on any trace brings up a context menu of available actions. At present ',...
        'there are only two choices, either "Time-variant spectrum" or "Delete". The former brings ',...
        'up a tool with its own help information showing spectral variation with time while the latter simply removes the trace from the ',...
        'window. If the Trace Inspector window becomes too full, you can simply close it to cause ',...
        'a new one to open at the next Trace Inspector invocation.'],' ',...
        ['The "Location" display at the top of the Trace Inspector window shows the x coordinate that ',...
        'has been designated as the current location. When you click on a trace in another window to send ',...
        'to the Trace Inspector, if you have the option "At location" the the trace is selected closest ',...
        'to the displayed location instead of where you have clicked. This enables a trace to be ',...
        'selected at exactly the same location as a previously selected trace. The "Location" is set ',...
        'one of two ways: (1) When you send a new trace to the Inspector, that trace''s location  ',...
        'becomes the "Location". (2) When you click (left mouse button) on any trace in the Inspector ',...
        'that trace''s location becomes the "Location".'] };
    hinfo=showinfo(msg,'Instructions for Trace Inspector');
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        ikill=zeros(1,length(udat{1}));
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
elseif(strcmp(action,'getlocation'))
    flag=t;
    if(~isgraphics(SEISPLOTTRACES_FIG))
        flag='pt';
    elseif(isempty(SEISPLOTTRACES_FIG))
        flag='pt';
    end
    if(strcmp(flag,'loc'))
        hloc=findobj(SEISPLOTTRACES_FIG,'tag','location');
        rarg=hloc.UserData;
    else
        pt=get(gca,'currentpoint');
        rarg=pt(1,1);
    end
elseif(strcmp(action,'register'))
    hthisfig=t;
    hfig=x;
    %determine is PI3D or PI2D called this decon tool
    udat=get(hthisfig,'userdata');
    windowentry=false;
    if(length(udat)==2)
        if(iscell(udat))
            if(isgraphics(udat{2}))
                name=get(udat{2},'name');
                if(contains(name,'PI2D')||contains(name,'PI3D'))
                    windowentry=true;%mean it was called by PI3D or PI2D (don't care which)
                    hpifig=udat{2};
                end
            end
        else
            if(isgraphics(udat(2)))
                name=get(udat(2),'name');
                if(contains(name,'PI2D')||contains(name,'PI3D'))
                    windowentry=true;%mean it was called by PI3D or PI2D (don't care which)
                    hpifig=udat(2);
                end
            end
        end
    end
    if(windowentry)
        %Make entry in windows list and set closerequestfcn
        winname='Trace Inspector';
        hwin=findobj(hpifig,'tag','windows');
        
        currentwindows=get(hwin,'string');
        if(~iscell(currentwindows))
            currentwindows={currentwindows};
        end
        %see if its already listed
        addwin=true;
        for k=1:length(currentwindows)
            if(strcmp(winname,currentwindows{k}))
                addwin=false;
            end
        end
        if(addwin)
            currentfigs=get(hwin,'userdata');
            
            nwin=length(currentwindows);
            if(nwin==1)
                if(strcmp(currentwindows{1},'None'))
                    currentwindows{1}=winname;
                    currentfigs(1)=hfig;
                    nwin=0;
                else
                    currentwindows{2}=winname;
                    currentfigs(2)=hfig;
                end
            else
                currentwindows{nwin+1}=winname;
                currentfigs(nwin+1)=hfig;
            end
            set(hwin,'string',currentwindows,'value',nwin+1,'userdata',currentfigs)
        end
        udat=get(hfig,'userdata');
        if(isempty(udat))
            udat={[], hpifig};%-999.25 is just a dummy placeholder
        elseif(length(udat)==1)
            %this is the case with only a single owner and no subwindows. Should be rare
            udat={udat hpifig};
        elseif(length(udat)==2)
            %here there is one owner already and we add a second.
            udat{2}=[udat{2} hpifig];
        end
        crf=get(hfig,'closerequestfcn');
        if(~isempty(crf))
            if(crf(end)~=';')
                crf=[crf ';'];
            end
        end
        % both PI3D and PI2D may be effectively owners of the same window. This is a problem. We want both
        % to be able to remove the window from the windows list, but only the last one should delete the
        % tool. So, the userdata of the Trace Inspector Window is a two element cell array where the first
        % element contains the array of windows spawned by the TIW and the second is the owner of the TIW
        % normally a single window either PI3D or PI2D. However, in this case it may be two entries if both
        % PI3D and PI2D have claimed the TIW. In that case, only the last entry will delete the tool. This
        % requires additional intelligence in the 'closewindow' action of both PI3D and PI2D.
        ind=strfind(crf,';');
        if(length(ind)>2)
            return;%this means there are already two owners. Don't want more
        end
        set(hfig,'closerequestfcn',[crf 'PI2D(''closewindow'')'],'userdata',udat);
        % if(fromenhance)
        %     %the only purpose of this is to store the enhance figure handle
        %     uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        %         'tag','fromenhance','userdata',henhance);
        % end
    else
        %register the new figure with parent
        updatefigureuserdata(hthisfig,hfig)
    end
end
end

%% internal functions

function [htraces,hnames]=plottraces
global SEISPLOTTRACES_FIG
hfig=SEISPLOTTRACES_FIG;
%get geom info
hnorm=findobj(hfig,'tag','norm');
geom=hnorm.UserData;
AWD=geom(2);
FWD=geom(3);%figure width (updated in "more")
FHT=geom(4);%figure height
TGWD=geom(6);%trace group width
PWD=geom(7);%inner panel width (updated in "more") includes all TG
PWBDR=geom(13);%pixel border on either sides
PWD2=min([PWD FWD-2*PWBDR]);%width of visible axes panel
PHT=geom(8);%panel height
AHT=geom(10);%axes ht
AHTBDR=geom(11);%axes vertical border
Value=geom(14);%slider setting
inorm=hnorm.Value;
%get traces
%t ... cell array of time coordinates
%x ... cell array of x coordinates
%seis ... cell array of traces
%names ... cell array of names for the traces 
%inorm ... normalize flag
%tnorms ... length 2 vector giveing the normalized window
hinfo=findobj(hfig,'tag','info');
info=hinfo.UserData;
seis=info{1};%cell array
t=info{2};%cell array
x=info{3};%cell array
names=info{4};%cell array
% tmin=info{5};
% tmax=info{6};
ylbl=info{9};%labels for y axes
tnorms=info{10};
%get exisiting panel
copyannotation=false;
hpan_old=findobj(hfig,'tag','seis');
if(isgraphics(hpan_old))
    copyannotation=true;
    haxes_old=findobj(hpan_old,'type','axes');
end

%determine trace panel width and size
NTG=length(t);%need this many trace axes

%make new panel
wxbdr=PWBDR/FWD;%normalized border width
wid_outerpanel=PWD2/FWD;%normalized panel width
htpan=PHT/FHT;%normalized ht of panel

if(PWD2==PWD)
    slider=false;
    hpan=uipanel(hfig,'title','Traces','fontsize',10,'units','normalized',...
        'position',[wxbdr,0,wid_outerpanel,htpan]);
else
    slider=true;
    htmp=uiscrollpanel_hor(hfig,[wxbdr,0,wid_outerpanel,htpan],PWD/PWD2,.025);
%     hslider=htmp(3);
    set(htmp(1),'title','Traces');
    hpan=htmp(2);
end
set(hpan,'tag','seis','units','pixels');

%context menu for panel
hcmp=uicontextmenu;
uimenu(hcmp,'label','Comment','callback',{@annotate,'textbox',hpan});
hpan.ContextMenu=hcmp;
%context menu for axes
hcma=uicontextmenu;
uimenu(hcma,'label','Comment','callback',{@annotate,'textaxes',hpan});
uimenu(hcma,'label','Set X Lims','callback',{@setlims,'x'});
uimenu(hcma,'label','Set Y Lims','callback',{@setlims,'y'});
%plot traces

% dax=daxpix;
% wax=pixpertrace;
% xax=.75*dax;
% htax=.8*htpanpix;
% yax=.1*htpanpix;

kol='k';
htraces=cell(1,NTG);
hnames=htraces;
hshownames=findobj(hfig,'tag','names');
visnames=hshownames.Value;
%context menu for traces
hcm=uicontextmenu;
uimenu(hcm,'label','Time-variant spectrum','callback',@showtvspec);
uimenu(hcm,'label','Delete','callback',@deletetrace);
hcm0=uicontextmenu;
uimenu(hcm0,'label','Delete','callback',@deletetrace);

haxes=zeros(1,NTG);
Units='pixels';
% width=0;
dax=(TGWD-AWD);
xax=.67*dax;
for k=1:NTG
    haxes(k)=axes(hpan,'units',Units,'position',[xax,AHTBDR/2,AWD,AHT],'ydir','reverse',...
        'tag',int2str(k),'contextmenu',hcma,'fontsize',12,'box','on');
    s=seis{k};
    ntr=size(s,2);%number of traces
    ts=t{k};
%     xs=x{k}-min(x{k});
    xs=x{k};
    nn=names{k};
    tnorm=tnorms{k};
    ind=near(ts,tnorm(1),tnorm(2));
    smax=max(abs(s(ind)));
    %determine trace type
    trtype=1;%this is a normal trace (usually zero mean)
    if(strfind(nn{1},'SPECD'))
        trtype=0;%a spectral trace
    elseif(strfind(nn{1},'Fdom'))
        trtype=-1;%a FDOM trace
    end
    if(inorm)
        s=s/smax;
        xs=0:1:ntr-1;
        dx=1;
    elseif(ntr>1)
        dx=xs(2)-xs(1);
        %adjust max(s) to 1 trace spacing
        s=s*dx/smax;
    else
        dx=max(abs(s));
    end
    if(length(xs)==1)
        if(trtype==-1)
            xs=xs-xs(1);%this causes fdom amplitudes to appear in HZ.
        end
    end
    
    
%     smin=min(s(:));%if positive then we are plotting spectra
    htr=zeros(1,ntr);
    hn=htr;
    
    lw=.5;%linewidth
    jtext=ceil(ntr/2);
    xxx=xs-min(xs);
    for j=1:ntr
        if(ntr>1)
%             xxx=xs(j)-min(xs);
            [htr(j),~]=wtva(s(:,j)+xxx(j),ts,kol,xxx(j),1,1,1);
%             [htr(j),~]=wtva(s(:,j)+xs(j)-min(xs),ts,kol,xs(j),1,1,1);
        else
%             htr(j)=line(s(:,j)+xs(j),ts,'color',kol,'linewidth',lw);
%             xxx=0;
            htr(j)=line(s(:,j),ts,'color',kol,'linewidth',lw);
        end
        if(trtype==1)
            set(htr(j),'uicontextmenu',hcm,'buttondownfcn',@setloc,'userdata',xs(j));%set line properties
        else
            set(htr(j),'uicontextmenu',hcm0,'buttondownfcn',@setloc,'userdata',xs(j));%set line properties
        end
        if(j==jtext)
            if(iscell(nn))
                nnn=nn{j};
            else
                nnn=nn;
            end
            sm=mean(s(:,j));
            hn(j)=text(sm+xxx(j)+.5*dx,ts(end),nnn,'rotation',-90,'horizontalalignment','right','color','r',...
                'visible',visnames,'interpreter','none','backgroundcolor','w');
        end
    end
    
    ht=titlein(int2str(k),'b',.05);
    ht.Color='r';
    
    %draw TE gate
    xl=xlim;
    lw=1;
    line(1.5*xl,tnorm(1)*ones(1,2),'color','r','linestyle','--','buttondownfcn',...
        'seisplottraces(''dragline'');','tag','ttop','linewidth',lw);
    line(1.5*xl,tnorm(2)*ones(1,2),'color','r','linestyle',':','buttondownfcn',...
        'seisplottraces(''dragline'');','tag','tbot','linewidth',lw);
    set(haxes(k),'color',.94*ones(1,3),'userdata',xxx);%userdata is used by @showtvspec to remove dc bias
    xlim(xl)
    %tidy up
    ylabel(ylbl{k});
    hnames{k}=hn;
    htraces{k}=htr;
    grid
    xax=xax+TGWD;
%     width=width+TGWD;
end
if(slider)
    %figure out slide position
%     width=width-1.2*dax+wax;
%     p=hpan.Position;
%     value=width/(p(3)-p(1));
%     if(isnan(Value))
%         Value=1;
%     end
    uiscrollpanel_hor('setValue',hpan.Parent,Value);
end
if(copyannotation)
    %first the panel level stuff
    ha=findobj(hpan_old,'tag','anno');
    nax=length(haxes_old);
    for k=1:length(ha)
       hp=ha(k).Parent.Type;
       switch hp
           case 'uipanel'
               copyobj(ha(k),hpan);
           case 'axes'
               id=str2double(ha(k).Parent.Tag); %integer number of the axes
               hnew=copyobj(ha(k),haxes(id));
               %check for normalization
               xlold=haxes_old(nax-id+1).XLim;
               xlnew=get(haxes(id),'XLim');
               if(abs(diff(xlnew)-diff(xlold))>.1*diff(xlnew))
                  pold=ha(k).Position;
                  xold=pold(1);
                  xnew=interp1(xlold,xlnew,xold);
                  pold(1)=xnew;
                  hnew.Position=pold;
               end
       end
       
    end
end
if(~isempty(hpan_old))
    if(hpan_old.Parent==hfig)
        delete(hpan_old)
    else
        delete(hpan_old.Parent)
    end
end

end

function setloc(~,~)
htrace=gco;
hfig=gcf;
hloc=findobj(hfig,'tag','location');
x=htrace.UserData;
set(hloc,'string',['Location: ' num2str(x)],'userdata',x);
end

function showtvspec(~,~)
global NEWFIGVIS
fromenhance=false;
if(strcmp(get(gcf,'tag'),'fromenhance'))
    fromenhance=true;
end
htrace=gco;
s=get(htrace,'xdata');
t=get(htrace,'ydata');
xs=get(gca,'userdata');
ix=near(xs,mean(s));
s=s-xs(ix(1));
hmasterfig=gcf;
hinfo=findobj(hmasterfig,'tag','info');
udat=get(hinfo,'userdata');
htraces=udat{7};
hnames=udat{8};
for k=1:length(htraces)
    for j=1:length(htraces{k})
%         if(htraces{k}(j)==htrace)
            if(strcmp(get(hnames{k}(j),'type'),'text'))
                dname=get(hnames{k}(j),'String');
            end
%         end
    end
end

NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplottvs1(s,t,dname,nan,nan,nan);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
htrace2=findobj(datar{1},'type','line');
set(htrace2(end),'color',get(htrace,'color'));
if(fromenhance)
    %add powerpoint button
    hinfo2=findobj(hfig,'tag','info');
    pos=get(hinfo2,'position');
    pos(2)=pos(2)+pos(4);
    hppt=uicontrol(hfig,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
        'position',pos,'backgroundcolor','y','callback','enhance(''makepptslide'');');
    set(hppt,'userdata',dname);
end
set(hfig,'visible','on');
% hreplot=findobj(hmasterfig,'tag','replot');
% ud=get(hreplot,'userdata');
% set(hreplot,'userdata',[ud hfig]);

%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

enhancebutton(hfig,[.95,.920,.05,.025]);
end

function deletetrace(~,~)
global SEISPLOTTRACES_FIG
hfig=SEISPLOTTRACES_FIG;
hinfo=findobj(hfig,'tag','info');
udat=get(hinfo,'userdata');
sc=udat{1};
tc=udat{2};
xc=udat{3};
names=udat{4};
tmin=udat{5};
tmax=udat{6};
htraces=udat{7};
hnames=udat{8};
ylbl=udat{9};
tnorms=udat{10};
hkill=get(gco,'parent');%We kill the entire axes 
haxes=findobj(hfig,'type','axes');
kkill=str2double(get(hkill,'tag'));
for k=1:length(haxes)
    %this is in case the killed trace was setting the time range
    %THIS DOES NOT SEEM TO MATTER AS OF OCT 1 2020
    if(min(tc{k})<tmin)
        tmin=min(tc{k});
    end
    if(max(tc{k})>tmax)
        tmax=max(tc{k});
    end
end

htraces(kkill)=[];
hnames(kkill)=[];
sc(kkill)=[];
tc(kkill)=[];
xc(kkill)=[];
names(kkill)=[];
ylbl(kkill)=[];
tnorms(kkill)=[];

if(isempty(xc))
    delete(hfig)
    SEISPLOTTRACES_FIG=[];
else
    %redo the geometry calculations
    hnorm=findobj(hfig,'tag','norm');
    geom=hnorm.UserData;
    TGWD=geom(6);%trace group width
    FWDM=geom(12);%maximum allowed figure width
    PWBDR=geom(13);%panel border
    NTG=length(tc);%number of trace groups
    PWD=NTG*TGWD;%width of innerpanel
    FWD=min([PWD+2*PWBDR FWDM]);
%     PWD2=FWD-2*PWBDR;
    geom(7)=PWD;
    geom(3)=FWD;
    %for trace deletion we keep the slider value at its present value
    hseis=findobj(hfig,'tag','seis');
    hslider=findobj(hseis.Parent,'style','slider');
    if(isempty(hslider))
        geom(14)=1;
    else
        geom(14)=hslider.Value;
    end
    hnorm.UserData=geom;
    
    %change buttons to pixels so they don't resize in plottraces
    hbuttons=findobj(hfig,'type','uicontrol');
    posbuttons=get(hbuttons,'position');
    set(hbuttons,'units','pixels');%so buttons don't enlarge
    ud={sc,tc,xc,names,tmin,tmax,htraces,hnames,ylbl,tnorms};
    hinfo.UserData=ud;
    [htraces,hnames]=plottraces;
    ud{7}=htraces;
    ud{8}=hnames;
    hinfo.UserData=ud;
    %fix buttons
    %check that all buttons are live because we might have deleted a scrollbar
    for k=1:length(hbuttons)
        if(~isgraphics(hbuttons(k)))
            hbuttons(k)=[];
            posbuttons(k)=[];
        end
    end
    set(hbuttons,'units','normalized')
    for k=1:length(hbuttons)
        pos=get(hbuttons(k),'position');
        pos=[posbuttons{k}(1:2) pos(3:4)];
        set(hbuttons(k),'position',pos);
    end
%     bigfont(hfig,1.5,1)
    boldlines(hfig,2);
end



end



% 
% function expand(~,~)
% hax=gca;
% xl=hax.XLim;
% dx=.25*diff(xl);
% hax.XLim=[xl(1)-dx xl(2)+dx];
% end
% 
% function contract(~,~)
% hax=gca;
% xl=hax.XLim;
% dx=.25*diff(xl);
% hax.XLim=[xl(1)+dx xl(2)-dx];
% end

% function ntr=numtraces
% global SEISPLOTTRACES_FIG
% hfig=SEISPLOTTRACES_FIG;
% ntr=length(findobj(hfig,'type','line'));
% end
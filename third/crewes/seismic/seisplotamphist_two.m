function datar=seisplotamphist_two(seis1,t1,x1,dname1,xname1,yname1,xdir1,ydir1,spaceflag1,...
    seis2,t2,x2,dname2,xname2,yname2,xdir2,ydir2,spaceflag2)
% SEISPLOTAMPHIST_TWO: plots a two seismic gathers and their amplitude histograms side-by-side
%
% datar=seisplotamphist_two(seis1,t1,x1,dname1,seis2,t2,x2,dname2)
%
% A new figure is created and divided into two rows with two same-sized axes (side-by-side) in each.
% Each seismic gather is plotted as an image in the left-hand-side of a row and its amplitude
% histogram is plotted as a bar graph in the right-hand-side. Controls are provided to adjust the
% clipping and to brighten or darken the image plots.
%
% seis1... input seismic matrix #1
% t1 ... time coordinate vector for seis1. This is the row coordinate of seis1. 
% x1 ... space coordinate vector for seis1
% dname1 ... text string giving a name for dataset #1 that will annotate
%       the plots.
% xname1 ... name for the x axis
% yname1 ... name for the y axis
% xdir1 ... direction for the x axis
% ydir1 ... direction for the y axis
% seis2... input seismic matrix #2
% t2 ... time coordinate vector for seis2. This is the row coordinate of seis2. 
% x2 ... space coordinate vector for seis2
% dname2 ... text string giving a name for dataset #2 that will annotate
%       the plots.
% xname2 ... name for the x axis
% yname2 ... name for the y axis
% xdir2 ... direction for the x axis
% ydir2 ... direction for the y axis
% 
%
% datar ... Return data which is a length 4 cell array containing
%           data{1} ... handle of the first seismic axes
%           data{3} ... handle of the first amplitude histogram axes
%           data{2} ... handle of the second seismic axes
%           data{4} ... handle of the second amplitude histogram axes
% These return data are provided to simplify plotting additional lines and
% text in either axes.
%
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

global DRAGBOX_CALLBACK DRAGBOX_MOTIONCALLBACK DRAGBOX_XLIMS DRAGBOX_YLIMS
global DRAGBOX_CALLBACK2 DRAGBOX_MOTIONCALLBACK2 DRAGBOX_XLIMS2 DRAGBOX_YLIMS2
global DRAGBOX_MAXWID DRAGBOX_MINWID DRAGBOX_MAXHT DRAGBOX_MINHT
global DRAGBOX_MAXWID2 DRAGBOX_MINWID2 DRAGBOX_MAXHT2 DRAGBOX_MINHT2
global NEWFIGVIS

if(~ischar(seis1))
    action='init';
else
    action=seis1;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
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
    
    xwid1=.4;
    xwid2=.25;
    yht=.35;
    xsep=.1;
    ysep=.1;
    xnot=.125;
    ynot=.1;
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
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
    
    %first seismic axis
    hax1=subplot('position',[xnot ynot+yht+ysep xwid1 yht]);    
    hi=imagesc(x1,t1,seis1);
    
    hcm=uicontextmenu(hfig);
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    set(hi,'uicontextmenu',hcm);
    
    grid
    
    %draw first amp box
    pct=20;
    tinc=pct*(t1(end)-t1(1))/100;
    xinc=pct*abs(x1(end)-x1(1))/100;
    tmin=t1(1)+tinc;
    tmax=t1(end)-tinc;
    xmin=min(x1)+xinc;
    xmax=max(x1)-xinc;
    dragbox_two('draw1',[xmin xmin xmax xmax tmin tmax tmax tmin],'seisplotamphist_two(''box1'')','r',.5);
%     dragbox_two('labels',{'Max X','Min X','Max T','Min T'})
    annotation(hfig,'textbox','string','Click and drag the red box to define the analysis region.',...
        'linestyle','none','fontsize',10,'color','r','fontweight','bold','units','normalized',...
        'position',[xnot, .975, xwid1, .02],'tag','instruct','horizontalalignment','center');
    annotation(hfig,'textbox','string','Use the corners to resize and the edges to move.',...
        'linestyle','none','fontsize',10,'color','r','fontweight','bold','units','normalized',...
        'position',[xnot, .96, xwid1, .02],'tag','instruct2','horizontalalignment','center');
%     if(iscell(dname1))
%         dname1=dname1{1};
%     end
%     if(length(dname1)>80)
%         fs=15;
%     else
%         fs=17;
%     end
    [dname1,fs]=processname(dname1);
    ht=enTitle(dname1,'interpreter','none');
    ht.FontSize=fs;
    
    xlabel(xname1)
    ylabel(yname1)
    
%     %amp control
%     wid=.04;ht=.05;
%     ampchoices={'Independent','#1 master','#2 master'};
%     xnow=xnot-2*wid;
%     ynow=ynot+2*yht+ysep;
%     uicontrol(hfig,'style','text','string','Amp. Control:','units','normalized','position',...
%         [xnow,ynow+.75*ht,1.5*wid,.75*ht],'backgroundcolor','w','fontweight','bold','horizontalalignment','left',...
%         'tooltipstring','This determines if the seismic displays are scaled independently or jointly.');
%         
%     uicontrol(hfig,'style','popupmenu','string',ampchoices,'tag','ampcontrol','units','normalized',...
%         'position',[xnow,ynow,1.5*wid,ht],'callback','seisplotamphist_two(''ampcontrol'')','value',1,...
%         'tooltipstring','Choosing #1 to be master means that the amplitude statistics of #1 control both displays.');
        
    
    %make a clip control
    wid=.055;ht=.05;
    xnow=xnot-2*wid;
    htclip=2*ht;
    ynow=ynot+2*yht+ysep-htclip;
    clim=[-3 3];
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip1',...
        'userdata',{ampinfo1,ampinfo2,hax1,pct,clim},'title','Clipping');
    data={clim,hax1};
    callback='seisplotamphist_two(''clip1'');';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;

    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnot+xwid1,.95,.5*wid,.5*ht],'callback','seisplotamphist_two(''info'');',...
        'backgroundcolor','y');
    
    set(hax1,'tag','seis1','xdir',xdir1,'ydir',ydir1);
    
    %second seismic axis
    hax2=subplot('position',[xnot ynot xwid1 yht]);    
    hi=imagesc(x2,t2,seis2);
    set(hi,'uicontextmenu',hcm);
    grid
    
    %draw second amp box
    pct=20;
    tinc=pct*(t2(end)-t2(1))/100;
    xinc=pct*abs(x2(end)-x2(1))/100;
    tmin=t2(1)+tinc;
    tmax=t2(end)-tinc;
    xmin=min(x2)+xinc;
    xmax=max(x2)-xinc;
    dragbox_two('draw2',[xmin xmin xmax xmax tmin tmax tmax tmin],'seisplotamphist_two(''box2'')','r',.5);
%     if(iscell(dname2))
%         dname2=dname2{1};
%     end
%     if(length(dname2)>80)
%         fs=15;
%     else
%         fs=17;
%     end
    dname2=processname(dname2);
    ht=enTitle(dname2,'interpreter','none');
    ht.FontSize=fs;
    xlabel(xname2)
    ylabel(yname2)
    
    %equlize boxes button
    wid=.04;ht=.05;
    xnow=xnot-2*wid;
    ynow=ynot+yht;
    enable='off';
    if(spaceflag1==spaceflag2)
        enable='on';
    end
    uicontrol(hfig,'style','radiobutton','string','equalize boxes','tag','equal','units','normalized',...
        'position',[xnow ynow 1.5*wid ht],'value',0,'backgroundcolor','w','tooltipstring',...
        'After clicking this, adjust one box and the other with be adjusted to match',...
        'enable',enable);
    %make a clip control
    ynow=ynow-htclip;
    wid=.055;
    xnow=xnot-2*wid;
    clim=[-3 3];
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip2',...
        'userdata',{ampinfo1,ampinfo2,hax2,pct,clim},'title','Clipping');
    data={clim,hax2};
    callback='seisplotamphist_two(''clip2'');';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax2;
%     
    set(hax2,'tag','seis2','xdir',xdir2,'ydir',ydir2);
    
    hax3=subplot('position',[xnot+xwid1+xsep ynot+yht+ysep xwid2 yht]);
    set(hax3,'tag','amp1');
    
    wid=.05;
    ht=.025;
    ys=ht/5;
    xs=wid/10;
    xnow=xnot+xwid1+xwid2+xsep+xs;
    ynow=ynot+2*yht+ysep-ht;
    uicontrol(hfig,'style','text','string','Max amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','max1');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Min amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','min1');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Mean amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','mean1');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Std dev','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','std1');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','radiobutton','string','Exclude hard zeros','units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'value',1,'tag','exclude1','callback','seisplotamphist_two(''amp1'');',...
        'tooltipstring','Hard zeros are samples with amplitude exactly equal to zero.',...
        'backgroundcolor','w');
    
    ynow=ynot+yht+ysep;
    uicontrol(hfig,'style','radiobutton','string','Equalize histogram x axes','tag','xequal',...
        'units','normalized','position',[xnow,ynow,3*wid,ht],'value',0,...
        'callback','seisplotamphist_two(''xequal'');','backgroundcolor','w');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','radiobutton','string','Equalize histogram y axes','tag','yequal',...
        'units','normalized','position',[xnow,ynow,3*wid,ht],'value',0,...
        'callback','seisplotamphist_two(''yequal'');','backgroundcolor','w');
    
    hax4=subplot('position',[xnot+xwid1+xsep ynot xwid2 yht]);
    set(hax4,'tag','amp2');
    
    wid=.05;
    ht=.025;
    ys=ht/5;
    xs=wid/10;
    xnow=xnot+xwid1+xwid2+xsep+xs;
    ynow=ynot+yht-ht;
    uicontrol(hfig,'style','text','string','Max amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','max2');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Min amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','min2');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Mean amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','mean2');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Std dev','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','std2');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','radiobutton','string','Exclude hard zeros','units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'value',1,'tag','exclude2','callback','seisplotamphist_two(''amp2'');',...
        'tooltipstring','Hard zeros are samples with amplitude exactly equal to zero.',...
        'backgroundcolor','w');
    
        
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
    boldlines([hax1 hax2],4,2); %make lines and symbols "fatter"
    whitefig;
    
    seisplotamphist_two('amp1');
    set(hax3,'tag','amp1');
    seisplotamphist_two('amp2');
    set(hax4,'tag','amp2');
    DRAGBOX_CALLBACK='seisplotamphist_two(''amp1'');';
    DRAGBOX_MOTIONCALLBACK='';
    DRAGBOX_CALLBACK2='seisplotamphist_two(''amp2'');';
    DRAGBOX_MOTIONCALLBACK2='';
%     DRAGBOX_MOTIONCALLBACK='seisplotamphist_two(''amp'');';
    
    if(iscell(dname1))
        dn1=dname1{1};
    else
        dn1=dname1;
    end
    if(iscell(dname2))
        dn2=dname2{1};
    else
        dn2=dname2;
    end
    set(hfig,'name',['Amplitude analysis for ' dn1 ' and ' dn2],'closerequestfcn','seisplotamphist_two(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,4);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=hax3;
        datar{4}=hax4;
    end
elseif(strcmp(action,'box1'))
    hax=gca;
    DRAGBOX_CALLBACK='seisplotamphist_two(''amp1'');';
    DRAGBOX_MOTIONCALLBACK='';
    DRAGBOX_MINWID=[];
    DRAGBOX_MAXWID=[];
    DRAGBOX_MAXHT=[];
    DRAGBOX_MINHT=[];
    xl=hax.XLim;
    pct=.01;
    dx=pct*diff(xl);
    DRAGBOX_XLIMS=[xl(1)+dx xl(2)-dx];
    yl=hax.YLim;
    dy=pct*diff(yl);
    DRAGBOX_YLIMS=[yl(1)+dy yl(2)-dy];
elseif(strcmp(action,'box2'))
    hax=gca;
    DRAGBOX_CALLBACK2='seisplotamphist_two(''amp2'');';
    DRAGBOX_MOTIONCALLBACK2='';
    DRAGBOX_MINWID2=[];
    DRAGBOX_MAXWID2=[];
    DRAGBOX_MAXHT2=[];
    DRAGBOX_MINHT2=[];
    xl=hax.XLim;
    pct=.01;
    dx=pct*diff(xl);
    DRAGBOX_XLIMS2=[xl(1)+dx xl(2)-dx];
    yl=hax.YLim;
    dy=pct*diff(yl);
    DRAGBOX_YLIMS2=[yl(1)+dy yl(2)-dy];
% elseif(strcmp(action,'lims'))
%     hax=findobj(gcf,'tag','fk');
% %     axis(hax);
%     hxlim=findobj(gcf,'tag','xlim');
%     hylim=findobj(gcf,'tag','ylim');
%     xval=get(hxlim,'value');
%     yval=get(hylim,'value');
%     xlimfactors=get(hxlim,'userdata');
%     ylimfactors=get(hylim,'userdata');
%     hax.XLim=[-xlimfactors(xval) xlimfactors(xval)];
%     hax.YLim=[0 ylimfactors(yval)];
elseif(strcmp(action,'clip1'))
    hfig=gcf;
    hclip=findobj(hfig,'tag','clip1');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    udat{5}=clim;
    set(hclip,'userdata',udat);
elseif(strcmp(action,'clip2'))
    hfig=gcf;
    hclip=findobj(hfig,'tag','clip2');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    udat{5}=clim;
    set(hclip,'userdata',udat);
elseif(strcmp(action,'ampcontrol'))
    seisplotamphist_two('clip1');
    seisplotamphist_two('clip2');
elseif(strcmp(action,'amp1'))
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis1');
    hbox=findobj(hseis,'tag','box1');
    xbox=hbox.XData;
    tbox=hbox.YData;
    xmax=max(xbox);
    xmin=min(xbox);
    tmax=max(tbox);
    tmin=min(tbox);
    hi=findobj(hseis,'type','image');
    x1=hi.XData;
    t1=hi.YData;
    seis1=hi.CData;
    ix=near(x1,xmin,xmax);
    it=near(t1,tmin,tmax);
    hex=findobj(hfig,'tag','exclude1');
    iex=hex.Value;
    A=seis1(it,ix);
    hamp=findobj(hfig,'tag','amp1');
    hfig.CurrentAxes=hamp;
    if(iex==1)
        iuse=A~=0;
        [Ah,xn]=hist(A(iuse),200); %#ok<*HIST>
    else
        [Ah,xn]=hist(A(:),200);
    end
    bar(xn,Ah,'barwidth',1)
    xl=hamp.XLim;
    xm=max(abs(xl));
    xlim([-xm xm]);
    enTitle('Amplitude Histogram #1')
    xlabel('Amplitude');
    ylabel('Number of samples');
    grid
    Amax=max(A(:));
    Amin=min(A(:));
    Amean=mean(A(:));
    sd=std(A(:));
    h=findobj(hfig,'tag','max1');
    set(h,'string',num2str(Amax));
    h=findobj(hfig,'tag','min1');
    set(h,'string',num2str(Amin));
    h=findobj(hfig,'tag','mean1');
    set(h,'string',num2str(Amean));
    h=findobj(hfig,'tag','std1');
    set(h,'string',num2str(sd));
    set(hamp,'tag','amp1');
    %check for equalize
    hequal=findobj(hfig,'tag','equal');
    ieq=hequal.Value;
    if(ieq && nargin<2)
       dragbox_two('setbox',2,xmin,xmax,tmin,tmax);
       seisplotamphist_two('amp2',0);
    end
    heq=findobj(hfig,'tag','xequal');
    if(heq.Value==1)
        seisplotamphist_two('xequal');
    end
    heq=findobj(hfig,'tag','yequal');
    if(heq.Value==1)
        seisplotamphist_two('yequal');
    end
    %update clipping
    hclip=findobj(hfig,'tag','clip1');
    udat1=hclip.UserData;

    clim=udat1{5};
    clipdat={clim,hseis,sd};

    cliptool('refresh',hclip,clipdat);
elseif(strcmp(action,'amp2'))
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis2');
    hbox=findobj(hseis,'tag','box2');
    xbox=hbox.XData;
    tbox=hbox.YData;
    xmax=max(xbox);
    xmin=min(xbox);
    tmax=max(tbox);
    tmin=min(tbox);
    hi=findobj(hseis,'type','image');
    x=hi.XData;
    t=hi.YData;
    seis=hi.CData;
    ix=near(x,xmin,xmax);
    it=near(t,tmin,tmax);
    hex=findobj(hfig,'tag','exclude2');
    iex=hex.Value;
    A=seis(it,ix);
    hamp=findobj(hfig,'tag','amp2');
    hfig.CurrentAxes=hamp;
    if(iex==1)
        iuse=A~=0;
        [Ah,xn]=hist(A(iuse),200);
    else
        [Ah,xn]=hist(A(:),200);
    end
    bar(xn,Ah,'barwidth',1)
    xl=hamp.XLim;
    xm=max(abs(xl));
    xlim([-xm xm]);
    enTitle('Amplitude Histogram #2')
    xlabel('Amplitude');
    ylabel('Number of samples');
    grid
    Amax=max(A(:));
    Amin=min(A(:));
    Amean=mean(A(:));
    sd=std(A(:));
    h=findobj(hfig,'tag','max2');
    set(h,'string',num2str(Amax));
    h=findobj(hfig,'tag','min2');
    set(h,'string',num2str(Amin));
    h=findobj(hfig,'tag','mean2');
    set(h,'string',num2str(Amean));
    h=findobj(hfig,'tag','std2');
    set(h,'string',num2str(sd));
    set(hamp,'tag','amp2');
    %check for equalize
    hequal=findobj(hfig,'tag','equal');
    ieq=hequal.Value;
    if(ieq && nargin<2)
       dragbox_two('setbox',1,xmin,xmax,tmin,tmax);
       seisplotamphist_two('amp1',0);
    end
    heq=findobj(hfig,'tag','xequal');
    if(heq.Value==1)
        seisplotamphist_two('xequal');
    end
    heq=findobj(hfig,'tag','yequal');
    if(heq.Value==1)
        seisplotamphist_two('yequal');
    end
    %update clipping
    hclip=findobj(hfig,'tag','clip2');
    udat2=hclip.UserData;

    clim=udat2{5};
    clipdat={clim,hseis,sd};

    cliptool('refresh',hclip,clipdat);
elseif(strcmp(action,'xequal'))
    hfig=gcf;
    hxeq=findobj(hfig,'tag','xequal');
    ieq=hxeq.Value;
    hamp1=findobj(hfig,'tag','amp1');
    hamp2=findobj(hfig,'tag','amp2');
    if(ieq==1)
       xl1=hamp1.XLim;
       xl2=hamp2.XLim;
       xlmax=max(abs([xl1 xl2]));
       hamp1.XLim=[-xlmax xlmax];
       hamp2.XLim=[-xlmax xlmax];
    else
       h=findobj(hfig,'tag','max1');
       xmax=str2double(h.String);
       hamp1.XLim=[-xmax xmax];
       h=findobj(hfig,'tag','max2');
       xmax=str2double(h.String);
       hamp2.XLim=[-xmax xmax];
    end
elseif(strcmp(action,'yequal'))
    hfig=gcf;
    hyeq=findobj(hfig,'tag','yequal');
    ieq=hyeq.Value;
    hamp1=findobj(hfig,'tag','amp1');
    hamp2=findobj(hfig,'tag','amp2');
    if(ieq==1)
       yl1=hamp1.YLim;
       yl2=hamp2.YLim;
       ymax=max(abs([yl1 yl2]));
       hamp1.YLim=[0 ymax];
       hamp2.YLim=[0 ymax];
       set(hyeq,'userdata',[yl1 yl2]);
    else
       udat=hyeq.UserData;
       hamp1.YLim=udat(1:2);
       hamp2.YLim=udat(3:4);
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
    msg={['This amplitude histogram tool enables the comparison of the amplitude histograms (distributions) ',...
        'of two datasets. The red boxes define the regions being analyzed. The boxes can be moved to other ',...
        'locations by clicking and dragging an edge or they can be resized by clicking and dragging a ',...
        'corner. Clicking the "equalize boxes" buttons will cause the other box to assume the same ',...
        'position and shape when either box is adjusted. The two seismic images are displayed in "equalized" ',...
        'coordinates as defined in the "Compare Tool". Initially they have independent amplitude scaling ',...
        'meaning that the amplitude statistics (mean and standard deviation) that define the clipping ',...
        'are determined independently for each image. Choosing "#1 master" causes the first dataset ',...
        '(upper left image) to control the scaling of both. Similarly, you can also choose "#2 master". '],...
        ' ',['A well processed dataset should show stationary statistics. In practice, this means that ',...
        'the amplitude distributions, and their corresponding statistics (as shown to the right of each ',...
        'histogram) should not change much as you move the boxes around. Also, the local distribution ',...
        'seen in a small box at any location should be similar to the general distribution seen in ',...
        'the largest box.']};
    hinfo=showinfo(msg,'Instructions for amplitude analysis',nan,nan,2);
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
end
end

function showtraces(~,~,flag)
hthisfig=gcf;
fromenhance=false;
if(strcmp(get(gcf,'tag'),'fromenhance'))
    fromenhance=true;
end
% hseis1=findobj(hthisfig,'tag','seis1');
% hseis2=findobj(hthisfig,'tag','seis2');
%get the data
hax=gca;
hi=findobj(hax,'type','image');
x=get(hi,'xdata');
t=get(hi,'ydata');
seis=get(hi,'cdata');

dname=hax.Title.String;

%get current point
pt=seisplottraces('getlocation',flag);
ixnow=near(x,pt(1,1));

%determine pixels per second
un=get(gca,'units');
set(gca,'units','pixels');
pos=get(gca,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(gca,'units',un);

iuse=ixnow(1)-0:ixnow(1)+0;
% iuse=ixnow;
pos=get(hthisfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);

% if(hseis1==gca)
%     nametrace=[dname2 ' no decon'];
% else
%     nametrace=[dname2 ' after decon']; 
% end

seisplottraces(double(seis(:,iuse)),t,x(iuse),dname,pixpersec);
hfig=gcf;
customizetoolbar(hfig);
if(fromenhance)
    seisplottraces('addpptbutton');
    pos2=get(hfig,'position');
    pos2(1)=xc-.5*pos2(3);
    pos2(2)=yc-.5*pos2(4);
    set(hfig,'position',pos2,'visible','on');
    set(hfig,'tag','fromenhance');
end

%determine if PI3D or PI2D called this decon tool
udat=get(hthisfig,'userdata');
if(length(udat)==2)
    if(isgraphics(udat{2}))
        windowentry=true;%mean it was called by PI3D or PI2D (don't care which)
        hpifig=udat{2};
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
        udat={-999.25 hpifig};%-999.25 is just a dummy placeholder
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
    % requires additional 9intelligence in the 'closewindow' action of both PI3D and PI2D.
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
end
if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.8,.920,.05,.025]);
    enhance('newview',hfig,hthisfig);
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
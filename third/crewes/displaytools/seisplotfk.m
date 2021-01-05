function datar=seisplotfk(seis,t,x,dname,fmax,gridy,gridx,spaceflag)
% SEISPLOTFK: plots a seismic gather and its fk spectrum side-by-side
%
% datar=seisplotfk(seis,t,x,dname,fmax,gridy,gridx,spaceflag)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The seismic
% gather is plotted as an image in the left-hand-side and its f-k transform (amplitude spectrum)
% is plotted as an image in the right-hand-side. Controls are provided to adjust the clipping
% and to brighten or darken the image plots. The data should be regularly sampled in both t and
% x. This can also be used to create the 2D spatial transform of a time slice, in which case, t
% becomes y the row coordinate (usually inline) of the slice.
%
% seis ... input seismic matrix
% t ... time coordinate vector for seis. This is the row coordinate of seis. 
% x ... space coordinate vector for seis
% dname ... text string giving a name for the dataset that will annotate
%       the plots.
% ************ default dname =[] ************
% fmax ... maximum frequency to include on the frequency axis. (nan gets the default)
% ************ default = .5/(t(2)-t(1)) which is Nyquist ***********
% gridy ... grid spacing in the row direction in physical units.
% ************ default abs(t(2)-t(1)) ***********
% gridx ... grid spacing in the column direction in physical units.
% ************ default abs(x(2)-x(1)) ***********
% NOTE: gridy and gridx are useful when analyzing a time slice and the x and y coordinates are line
%       numbers. In this case the defaults for gridy and gridx will give unphysical values for
%       wavenumbers. This can be especially misleading if the x and y grid spacings are not equal
%       in physical units.
% spaceflag ... 0 means input is in (x,t) space, 1 means (x,z) space, 2 means (x,y) space, 3 means
%       (y,t) space, 4 means (y,z) space
% ************ default 0 ***********
% 
%
% datar ... Return data which is a length 4 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the f-k axes
%           data{3} ... f coordinate vector for the spectrum
%           data{4} ... k coordinate vector for the spectrum
% These return data are provided to simplify plotting additional lines and
% text in either axes.
%
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

global DRAGBOX_XLIMS DRAGBOX_YLIMS DRAGBOX_CALLBACK DRAGBOX_MOTIONCALLBACK
global DRAGBOX_MAXWID DRAGBOX_MINWID DRAGBOX_MAXHT DRAGBOX_MINHT
global NEWFIGVIS

if(~ischar(seis))
    action='init';
else
    action=seis;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match seismic');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match seismic');
    end
    fmaxfactors=[1,.5,.333,.25];%possible fmax limits as fractions of Fnyq
    if(nargin<4)
        dname=[];
    end
    if(nargin<5)
        fmax=nan;
    end
    if(nargin<6)
        gridy=abs(t(2)-t(1));
    end
    if(nargin<7)
        gridx=abs(x(2)-x(1));
    end
    if(nargin<8)
        spaceflag=0;
    end
    if(isnan(fmax))
        fmax=fmaxfactors(2)*.5/(t(2)-t(1));
    end
    fnyq=.5/gridy;
    iffactor=near(fmaxfactors*fnyq,fmax);
    fmax=fmaxfactors(iffactor)*fnyq;
    
    xwid=.35;
    yht=.75;
    xsep=.05;
    xnot=.125;
    ynot=.1;
    
    %test to see if we are from enhance. This enables the fromenhance.m function to work
    ff=figs;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           %so the current figure is from enhance and we assume it hase called this one
           enhancetag='fromenhance';
           udat={[],gcf};
       else
           enhancetag='';
           udat=[];
       end
    end
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat);
    
    hax1=subplot('position',[xnot ynot xwid yht]);
    
    if(fromenhance)
       cmapdefaults1=enhance('getdefaultcolormap','sections');
       cmapdefaults2=enhance('getdefaultcolormap','ampspectra');
       cmapname1=cmapdefaults1{1};
       iflip1=cmapdefaults1{2};
       cmapname2=cmapdefaults2{1};
       iflip2=cmapdefaults2{2};
    else
       cmapname1='graygold';
       cmapname2='blueblack'; 
       iflip1=0;
       iflip2=1;
    end
    
    
    hi=imagesc(x,t,seis);
    hcm=uicontextmenu(hfig);
    uimenu(hcm,'label','Amplitude histogram','callback',@amphist);
    hi.ContextMenu=hcm;
    grid
    
    
    %draw bounding box
    pct=1;
    tinc=pct*(t(end)-t(1))/100;
    xinc=pct*abs(x(end)-x(1))/100;
    tmin=t(1)+tinc;
    tmax=t(end)-tinc;
    xmin=min(x)+xinc;
    xmax=max(x)-xinc;
    dragbox('draw',[xmin xmin xmax xmax tmin tmax tmax tmin],'seisplotfk(''box'')','r',.5);
    
    annotation(hfig,'textbox','string','Click and drag the red box to define the analysis region.',...
        'fontsize',10,'color','r','units','normalized','position',[xnot, .975, xwid, .02],...
        'fontweight','bold','tag','instruct','linestyle','none','horizontalalignment','center');
    annotation(hfig,'textbox','string','Use the corners to resize and the edges to move.',...
        'fontsize',10,'color','r','units','normalized','position',[xnot, .95, xwid, .02],...
        'fontweight','bold','tag','instruct2','linestyle','none','horizontalalignment','center');
    %right-click message
    annotation(hfig,'textbox','string','Right-click on either image for analysis tools.',...
        'position',[.41,.9,.2,.02],'linestyle','none','fontsize',8,'color','r','fontweight','bold');
    if(length(dname)>80)
        fs=15;
    else
        fs=17;
    end
    switch spaceflag
        case 0
            ht=enTitle({dname ,['x-t space dx=' num2str(gridx) ', dt=' num2str(gridy)]},'interpreter','none');
        case 1
            ht=enTitle({dname ,['x-z space dx=' num2str(gridx) ', dz=' num2str(gridy)]},'interpreter','none');
        case 2
            ht=enTitle({dname ,['x-y space dx=' num2str(gridx) ', dy=' num2str(gridy)]},'interpreter','none');
        case 3
            ht=enTitle({dname ,['y-t space dy=' num2str(gridx) ', dt=' num2str(gridy)]},'interpreter','none');
    end
    ht.Interpreter='none';
    ht.FontSize=fs;
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
    
    %make a clip control
    pctfk=5;
    wid=.04;ht=.05;
%     nudge=.1*wid;
    htclip=2*ht;
    xnow=xnot-3*wid;
    ynow=ynot+yht-htclip;
    %make a clip control
    hclip1=uipanel(hfig,'position',[xnow,ynow,2.5*wid,htclip],'tag','clipxt',...
        'userdata',{hax1,pctfk,fmax,gridx,gridy},'title','Clipping');
    data={[-3 3],hax1};
    callback='';
    cliptool(hclip1,data,callback);
    hfig.CurrentAxes=hax1;
    %colormap control
    ynow=ynow-4.5*ht;
    poscolormap=[xnow+.5*wid,ynow,1.5*wid,4*ht];
    
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,.95,.5*wid,.5*ht],'callback','seisplotfk(''info'');',...
        'backgroundcolor','y');

    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);
    
    
    
    if(t(2)>t(1))
        tt=gridy*(0:length(t)-1)';
    else
        tt=gridy*(length(t)-1:-1:0)';
    end
    if(x(2)>x(1))
        xx=gridx*(0:length(x)-1);
    else
        xx=gridx*(length(x)-1:-1:0);
    end
    indx=near(x,xmin,xmax);
    indt=near(t,tmin,tmax);

    [seisfk,f,k]=fktran(seis(indt,indx),tt(indt),xx(indx),nan,nan,pctfk);

    Afk=abs(seisfk);
    
       
    hi=imagesc(k,f,Afk);
    hcm=uicontextmenu(hfig);
    uimenu(hcm,'label','Amplitude histogram','callback',@amphist);
    hi.ContextMenu=hcm;
%     seisplotfk('recompute')
%     hi=findobj(hax2,'type','image');
%     k=hi.XData;
%     f=hi.YData;
    grid
    knyq=max(abs(k));
    fnyq=max(f);
    switch spaceflag
        case 0
            enTitle(['kx-f space, kxnyq=' num2str(knyq) ', fnyq=' num2str(fnyq)],'interpreter','none');
            xlabel('kx wavenumber (m^{-1})');
            ylabel('frequency (Hz)');
        case 1
            enTitle(['kx-kz space, kxnyq=' num2str(knyq) ', kznyq=' num2str(fnyq)],'interpreter','none');
            xlabel('kx wavenumber (m^{-1})');
            ylabel('kz wavenumber (m^{-1})');
        case 2
            enTitle(['kx-ky space, kxnyq=' num2str(knyq) ', kynyq=' num2str(fnyq)],'interpreter','none');
            xlabel('kx wavenumber (m^{-1})');
            ylabel('ky wavenumber (m^{-1})');
        case 3
            enTitle(['ky-f space, kynyq=' num2str(knyq) ', fnyq=' num2str(fnyq)],'interpreter','none');
            xlabel('ky wavenumber (m^{-1})');
            ylabel('frequency (Hz)');
    end
    
    %colormap control
    cb1='';cb2='';
    cbflag=[0,1];
    cbcb='';
    cbaxe=[hax1,hax2];
    enhancecolormaptool(hfig,poscolormap,hax1,hax2,cb1,cb2,cmapname1,cmapname2,iflip1,iflip2,cbflag,cbcb,cbaxe);
            
    %make a clip control
    nudge=.1*wid;
    xnow=xnot+2*xwid+xsep+nudge;
    ht=.025;
    ynow=ynot+yht-htclip;
    climfk=[-2 18];%in sigma
    climdb=[-80 5];%in db
    hclip=uipanel(hfig,'position',[xnow,ynow,2.5*wid,htclip],'tag','clipfk',...
        'userdata',{hax2,climfk,climdb},'title','Clipping');%the second and third entries in userdata
    %are clim settings for normal spectra and db spectra.
    data={climfk,hax2,[],0,0};
%     callback='seisplotdecon(''clip2'');';
    callback='seisplotfk(''clipfk'');';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax2;
    %wid=.045;sep=.005;
    
    
    ynow=ynow-1.25*ht;
%     fs=10;
    width=wid;
    ynudge=0;
    uicontrol(hfig,'style','radiobutton','string','Decibels','tag','decibels','value',0,...
        'units','normalized','position',[xnow ynow+ynudge 1.5*width ht],...
        'callback','seisplotfk(''recompute'');','backgroundcolor','w');
    lims={'Nyq','Nyq/2','Nyq/3','Nyq/4'};
    xlimfactors=[1,.5,.333,.25]/(2*gridx);
    ylimfactors=fmaxfactors/(2*gridy);
    switch spaceflag
        case 0
            xname='kx axis lims:';
            yname='f axis lims:';
        case 1
            xname='kx axis lims:';
            yname='kz axis lims:';
        case 2
            xname='kx axis lims:';
            yname='ky axis lims:';
        case 3
            xname='ky axis lims:';
            yname='f axis lims:';
    end
    ynow=ynow-ht;
    uicontrol(hfig,'style','text','string',xname,'units','normalized','position',...
        [xnow,ynow-.25*ht,1.25*wid,ht],'backgroundcolor',.99*ones(1,3));
    uicontrol(hfig,'style','popupmenu','string',lims,'units','normalized','position',...
        [xnow+1.25*wid,ynow,wid,ht],'callback','seisplotfk(''lims'');','tag','xlim',...
        'userdata',xlimfactors,'value',2);
    ynow=ynow-ht;
    uicontrol(hfig,'style','text','string',yname,'units','normalized','position',...
        [xnow,ynow-.25*ht,1.25*wid,ht],'backgroundcolor',.99*ones(1,3));
    uicontrol(hfig,'style','popupmenu','string',lims,'units','normalized','position',...
        [xnow+1.25*wid,ynow,wid,ht],'callback','seisplotfk(''lims'');','tag','ylim',...
        'userdata',ylimfactors,'value',iffactor);
        
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
    boldlines(hax1,4,2); %make lines and symbols "fatter"

    whitefig;
    
    set(hax2,'tag','fk');
    
    switch spaceflag
        case 0
            titstr=['f-kx analysis for ' dname];
        case 1
            titstr=['kx-kz analysis for ' dname];
        case 2
            titstr=['kx-ky analysis for ' dname];
        case 3
            titstr=['f-ky analysis for ' dname];
    end
    
    set(hfig,'name',titstr,'closerequestfcn','seisplotfk(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,4);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=f;
        datar{4}=k;
    end
    seisplotfk('lims');

elseif(strcmp(action,'box'))
    hax=gca;
    DRAGBOX_CALLBACK='seisplotfk(''recompute'');';
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
elseif(strcmp(action,'lims'))
    hax=findobj(gcf,'tag','fk');
%     axis(hax);
    hxlim=findobj(gcf,'tag','xlim');
    hylim=findobj(gcf,'tag','ylim');
    xval=get(hxlim,'value');
    yval=get(hylim,'value');
    xlimfactors=get(hxlim,'userdata');
    ylimfactors=get(hylim,'userdata');
    hax.XLim=[-xlimfactors(xval) xlimfactors(xval)];
    hax.YLim=[0 ylimfactors(yval)];

elseif(strcmp(action,'clipfk'))
    hfig=gcf;
    hdb=findobj(hfig,'tag','decibels');
    db=get(hdb,'value');
    hclip=findobj(gcf,'tag','clipfk');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    if(db)
        udat{3}=clim;
    else
        udat{2}=clim;
    end
    set(hclip,'userdata',udat);

elseif(strcmp(action,'recompute'))
    hfig=gcf;
    hclipxt=findobj(hfig,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{1};
    pctfk=udat{2};
    fmax=udat{3};
    gridx=udat{4};
    gridy=udat{5};
    hbox=findobj(haxe,'tag','box');
    xbox=hbox.XData;
    tbox=hbox.YData;
    xmax=max(xbox);
    xmin=min(xbox);
    tmax=max(tbox);
    tmin=min(tbox);
    
    hdb=findobj(hfig,'tag','decibels');
    db=get(hdb,'value');
    if(isempty(db))
        db=0;
    end
    
    hi=findobj(haxe,'type','image');
    seis=get(hi,'cdata');
    x=get(hi,'xdata');
    t=get(hi,'ydata');
    
    if(t(2)>t(1))
        tt=gridy*(0:length(t)-1)';
    else
        tt=gridy*(length(t)-1:-1:0)';
    end
    if(x(2)>x(1))
        xx=gridx*(0:length(x)-1);
    else
        xx=gridx*(length(x)-1:-1:0);
    end
    it=near(t,tmin,tmax);
    ix=near(x,xmin,xmax);
    [seisfk,f,k]=fktran(seis(it,ix),tt(it),xx(ix),nan,nan,pctfk);
    ind=near(f,0,fmax);
    if(db==1)
        Afk=real(todb(seisfk(ind,:)));
    else
        Afk=abs(seisfk(ind,:));
    end

    hclip2=findobj(hfig,'tag','clipfk');
    udatfk=get(hclip2,'userdata');
    haxefk=udatfk{1};

    axes(haxefk);
    hi=findobj(haxefk,'type','image');
    hcm=hi.ContextMenu;
    ht=get(haxefk,'title');
    titstr=get(ht,'string');
    fw=get(haxefk,'fontweight');
    fs=get(haxefk,'fontsize');
    xlbl=get(get(haxefk,'xlabel'),'string');
    ylbl=get(get(haxefk,'ylabel'),'string');
    tag=get(haxefk,'tag');
    cmap=get(haxefk,'colormap');
    hi=imagesc(k,f(ind),Afk);
    hi.ContextMenu=hcm;
    colormap(haxefk,cmap);
    set(haxefk,'fontweight',fw,'fontsize',fs,'tag',tag);
    xlabel(xlbl);
    ylabel(ylbl);
    grid
    enTitle(titstr,'interpreter','none');
    if(db==1)
       pos=get(haxefk,'position');
       hc=colorbar;
       posc=get(hc,'position');
       set(haxefk,'position',pos);
       set(hc,'position',[.9 posc(2:3) .7*posc(4)]);
       hc.Label.String='decibels';
    end
    seisplotfk('lims');
    hrecompute=findobj(hfig,'tag','recompute');
    set(hrecompute,'backgroundcolor',.94*ones(1,3));
    
    %update clipping
    if(db)
        sigma=1;
        clim=udatfk{3};
        clipdat={clim,haxefk,sigma,0};
    else
        clim=udatfk{2};
        clipdat={clim,haxefk,[],0,0};
    end
    
    cliptool('refresh',hclip2,clipdat);
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
    msg={['The f-k analysis tool shows the amplitude spectrum of the 2D Fourier transform of a seismic ',...
        'matrix. The left plot shows the seismic matrix and the Fourier transform is taken oven the ',...
        'region defined by the red box. The box can be moved to another ',...
        'location by clicking and dragging an edge. It can be resized by clicking and dragging a ',...
        'corner. '],' ',['By default the spectrum is displayed with a linear amplitude scale but ',...
        'a decibel scale is available by clicking the "Decibels" button. Each image plot has its own ',...
        'clipping control. '],' ',['Also, the default is to display only out to half-Nyquist on both axes',...
        'Popup menus are provides to modify the deipaly range.']};
    hinfo=showinfo(msg,'Instructions for f-k analysis');
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
%% functions

function val=fromenhance
hfig=gcf;
val=false;
if(strcmp(get(hfig,'tag'),'fromenhance'))
    val=true;
end
end

function amphist(~,~)
global NEWFIGVIS
hmasterfig=gcf;
hi=gco;
haxe=get(hi,'parent');
cmap=get(haxe,'colormap');
pos=get(hmasterfig,'position');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
dname1=hmasterfig.Name;
dname2=haxe.Title.String;
if(iscell(dname2))
    dname=[dname1 ' ' dname2{2}];
else
    dname=[dname1 ' ' dname2];
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotamphist(seis,t,x,dname);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on')

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
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

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
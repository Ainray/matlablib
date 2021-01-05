function seisplot(seis,t,x,dname)
% seisplot ... create a sesimic image plot in a new figure window
%
% seisplot(seis,t,x,dname)
%
% This function provides a similar display to that of plotimage but without the extra features (such
% as picking). This is suitable when you want a quick seismic display in a new figure but don't nead
% the extra features of plotimage. Seisplot also gives interactive ability to choose the clip level.
% Use seisplota for a similar display in the current axes. You might also consider seisplotfk and
% seisplottwo. The former shows a seismic section and its f-k spectrum while the latter shows two
% seismic sections in a single window for comparison.
%
% seis ... seismic matrix (gather).One trace per column
% t ... time coordinate vector. length(t) must equal size(seis,1)
% x ... space coordinate vector. length(x) must equal size(seis,2)
% dname ... dataset name (string). Used to title the plot and to label the figure
% ************** default = [] ****************
%
% NOTE: The image is plotted with Matlab's imagesc. This function only annotates the axes
% precisely correctly if the x and t vectors are regularly sampled. This is usually the case
% with t but less often so with x. For precisly annotated tick marks when x is not regular, the
% only current option is to uses plotseis or plotseismic which both plot wiggle traces not
% images.
% 
% G.F. Margrave, CREWES, 2017
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

global ZOOM_VALUE

if(~ischar(seis))
    action='init';
else
    action=seis;
end

if(strcmp(action,'init'))
    
    if(nargin<4)
        dname=[];
    end
    xname='';
    yname='';
    if(nargin<3)
        x=1:size(seis,2);
        xname='column number';
    end
    if(nargin<2)
        t=(1:size(seis,1))';
        yname='row number';
    end
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match seismic');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match seismic');
    end
    

    figtag='';
    udat=[];
    cmapname='graygold';
    iflip=0;
    
    
%     figure('menubar','none','toolbar','figure');
    figure
    hfig=gcf;
    set(hfig,'tag',figtag,'userdata',udat,'closerequestfcn','seisplot(''close'');',...
        'menubar','none','toolbar','figure');
    customizetoolbar(hfig)
    
    xnot=.05;
    xwid=.8;
    ynot=.1;
    yht=.8;
    sep=.005;
    hseis=subplot('position',[xnot,ynot,xwid,yht]);
    hseis.Tag='seis'; 
    
    hi=imagesc(x,t,seis);
%     brighten(.5);
    grid
    hcm=uicontextmenu;
    uimenu(hcm,'label','Time-variant spectrum','callback',@showtvspectrum);
    uimenu(hcm,'label','UI Time-variant spectrum','callback',@showtvspectrumui);
    uimenu(hcm,'label','2D spectrum','callback',@showfkspectrum);
    set(hi,'uicontextmenu',hcm);
    
    if(~isempty(dname))
        ht=title(dname);
        set(ht,'interpreter','none');
        if(~iscell(dname))
            set(gcf,'name',dname);
        else
            set(gcf,'name',dname{1});
        end
    end
    maxmeters=7000;
    if(isempty(yname))
        if(max(t)<10)
            yname='time (s)';
        elseif(max(t)<maxmeters)
            yname='depth (m)';
        else
            yname='(depth (ft)';
        end
    end
    ylabel(yname);
    if(isempty(xname))
        if(max(x)<maxmeters)
            xname='distance (m)';
        else
            xname='distance (ft)';
        end
    end
    xlabel(xname);
    
    %compute the average Hilbert envelope
    aveenv=zeros(size(seis,1),1);
    for k=1:length(x)
        aveenv=aveenv+env(double(seis(:,k)));
    end
    aveenv=aveenv/length(x);
    
    %make a clip control
    ilive=seis~=0;
    sigma=std(seis(ilive));
    amax=max(seis(ilive));
    amin=min(seis(ilive));
    am=mean(seis(ilive));
    [N,xn]=hist(seis(ilive),500); %#ok<HIST>
    xnow=xnot+xwid+sep;wid=.055;ht=.1;
    ynow=ynot+yht-ht;
    hclip=uipanel(hfig,'position',[xnow,ynow,2*wid,ht],'tag','clip',...
        'userdata',{[N;xn],am,sigma,amax,amin,dname,aveenv,yname,xname},'title','Clipping');
    data={[-3 3],hseis,sigma};
    callback='';
    cliptool(hclip,data,callback);
    
    
    
    ht=.25*ht;
    ynow=ynow-sep-ht;
    uicontrol(hfig,'style','pushbutton','string','brighten','tag','brighten','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot(''brighten'')',...
        'tooltipstring','push once or multiple times to brighten the image');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','darken','tag','darken','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot(''brighten'')',...
        'tooltipstring','push once or multiple times to darken the image');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','lvl 0','tag','brightness','units','normalized',...
        'position',[xnow,ynow,wid,ht],...
        'tooltipstring','current image brightness','userdata',0);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Amp histogram','tag','histogram','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot(''histogram'')',...
        'tooltipstring','show amplitude histogram');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Publish zoom','tag','histogram','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot(''publish'')',...
        'tooltipstring','Publish current zoom limits');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Match zoom','tag','histogram','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot(''match'')',...
        'tooltipstring','Match zoom to published limits');
    ynow=ynow-ht-sep;
    xl=get(gca,'xlim');
    yl=get(gca,'ylim');
    uicontrol(hfig,'style','pushbutton','string','Un-zoom','tag','histogram','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot(''unzoom'')',...
        'tooltipstring','Un-zoom to original view','userdata',{xl yl});
    
    annotation(hfig,'textbox','string','Right-click on the image for analysis tools',...
        'position',[.35,.975,.2,ht],'linestyle','none');
    %colormap control
    ynow=ynow-4*ht-sep;
    pos=[xnow,ynow,1.3*wid,4*ht];
    cback='';
    cbflag=[0,1];
    cbcb='';
    colormaptool(hfig,pos,hseis,cback,cmapname,iflip,cbflag,cbcb);
    
%     disableDefaultInteractivity(gca);
%     addToolbarExplorationButtons(gcf);
    bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.2,1); %enlarge the fonts in the figure
%     boldlines(gcf,4,2); %make lines and symbols "fatter"
    whitefig;
elseif(strcmp(action,'close'))
    hfig=gcf;
    udat=hfig.UserData;
    if(~isempty(udat))
        for k=1:length(udat)
           if(isgraphics(udat(k)))
               close(udat(k));
           end
        end
    end
    delete(hfig)

elseif(strcmp(action,'brighten'))
    hbut=gcbo;
    hbright=findobj(gcf,'tag','brighten');
    if(hbut==hbright)
        inc=.1;
    else
        inc=-.1;
    end
    brighten(inc);
    hbrightness=findobj(gcf,'tag','brightness');
    brightlvl=get(hbrightness,'userdata');
    brightlvl=brightlvl+inc;
    if(abs(brightlvl)<.01)
        brightlvl=0;
    end
    set(hbrightness,'string',['lvl ' num2str(brightlvl)],'userdata',brightlvl)
elseif(strcmp(action,'histogram'))
    hmasterfig=gcf;
    p=get(hmasterfig,'position');
    hi=findobj(gca,'type','image');
%     seis=get(hi,'cdata');
    t=get(hi,'ydata');
%     nsamps=numel(seis);
    hclip=findobj(gcf,'tag','clip');
    udat=get(hclip,'userdata');
    histinfo=udat{1};
    N=histinfo(1,:);
    xn=histinfo(2,:);
    am=udat{2};
    amax=udat{4};
    amin=udat{5};
    dname=udat{6};
    aveenv=udat{7};
    yname=udat{8};
    sigma=udat{3};
    figure
    hfig=gcf;
    q3=.5*p(3);
    q4=.5*p(4);
    q1=p(1)+.5*(p(3)-q3);
    q2=p(2)+.5*(p(4)-q4);
    set(hfig,'position',[q1 q2 q3 q4],'name',['Amplitude histogram ' dname])
%     nbins=nsamps/500;
%     if(nbins<100); nbins=100; end
%     if(nbins>1000);nbins=1000;end
    subplot(1,2,1)
%     inonzero=seis~=0;
%     hist(seis(inonzero),nbins); %#ok<HIST>
    bar(xn,N);
    ht=title({dname 'Amplitude histogram'});
    set(ht,'interpreter','none');
    xlabel('Amplitude');
    ylabel('Number of samples');
    xl=get(gca,'xlim');
    yl=get(gca,'ylim');
    yinc=diff(yl)/10;
    xinc=diff(xl)/20;
    fs=9;
    ynow=yl(2)-yinc;
    text(xl(1)+xinc,ynow,['Max amp= ' num2str(amax)],'fontsize',fs)
    ynow=ynow-yinc;
    text(xl(1)+xinc,ynow,['Min amp= ' num2str(amin)],'fontsize',fs)
    ynow=ynow-yinc;
    text(xl(1)+xinc,ynow,['Mean amp= ' num2str(am)],'fontsize',fs)
    ynow=ynow-yinc;
    text(xl(1)+xinc,ynow,['Std dev= ' num2str(sigma)],'fontsize',fs)
    subplot(1,2,2)
    %fit exponential
    nt2=round(length(t)/1);
    ind=near(t,t(1),t(nt2));
    Emax=max(aveenv);
    p=polyfit(t(ind),log(aveenv(ind)+.0001*Emax),2);
    expfit=exp(polyval(p,t(ind)));
    plot(t,aveenv,t(ind),expfit(ind),'r')
    legend('average envelope',['ln(env)= ' num2str(sigfig(p(1),2)) 't^2 + ' num2str(sigfig(p(2),2)) 't + ' num2str(sigfig(p(3),2))])
    title('Average trace envelope')
    xlabel(yname)
    ylabel('Amplitude')
    
    udat=hmasterfig.UserData;
    nf=length(udat);
    udat(nf+1)=hfig;
    hmasterfig.UserData=udat;
elseif(strcmp(action,'publish'))
    yl=get(gca,'ylim');
    xl=get(gca,'xlim');
    ZOOM_VALUE{1}=xl;
    ZOOM_VALUE{2}=yl;
elseif(strcmp(action,'match'))
    if(isempty(ZOOM_VALUE))
        return;
    end
    xl=ZOOM_VALUE{1};
    yl=ZOOM_VALUE{2};
    hi=findobj(gca,'type','image');
    x=get(hi,'xdata');
    y=get(hi,'ydata');
    fudge=diff(xl)*.1;
    x1=min(x)-fudge;
    x2=max(x)+fudge;
    if(~between(x1,x2,xl(1),2) && ~between(x1,x2,xl(2),2))
        msgbox('Published zoom limits are incompatible with this data');
        return;
    end
    fudge=diff(yl)*.1;
    y1=min(y)-fudge;
    y2=max(y)+fudge;
    if(~between(y1,y2,yl(1),2) && ~between(y1,y2,yl(2),2))
        msgbox('Published zoom limits are incompatible with this data');
        return;
    end
    set(gca,'xlim',xl,'ylim',yl)
elseif(strcmp(action,'unzoom'))
    udat=get(gco,'userdata');
    xl=udat{1};
    yl=udat{2};
    set(gca,'xlim',xl,'ylim',yl);
    
end

end


function showtvspectrum(~,~)
hmasterfig=gcf;
%get the data
hi=findobj(gca,'type','image');
x=get(hi,'xdata');
t=get(hi,'ydata');
seis=get(hi,'cdata');


dname=get(gcf,'name');

seisplottvs(seis,t,x,dname)
hfig=gcf;
udat=hmasterfig.UserData;
nf=length(udat);
udat(nf+1)=hfig;
hmasterfig.UserData=udat;

end

function showtvspectrumui(~,~)
hmasterfig=gcf;
%get the data
hi=findobj(gca,'type','image');
x=get(hi,'xdata');
t=get(hi,'ydata');
seis=get(hi,'cdata');


dname=get(gcf,'name');

seisplottvsui(seis,t,x,dname)
hfig=gcf;
udat=hmasterfig.UserData;
nf=length(udat);
udat(nf+1)=hfig;
hmasterfig.UserData=udat;

end

function showfkspectrum(~,~)
hmasterfig=gcf;
%get the data
hi=findobj(gca,'type','image');
x=get(hi,'xdata');
t=get(hi,'ydata');
seis=get(hi,'cdata');

dname=get(gcf,'name');

time=1;
if(max(t)>30)
    time=0;
end

seisplotfk(seis,t,x,dname);
hfig=gcf;
udat=hmasterfig.UserData;
nf=length(udat);
udat(nf+1)=hfig;
hmasterfig.UserData=udat;

if(time==1)
    xlabel('Wavenumber');ylabel('Frequency (Hz)');
else
    xlabel('Wavenumber');ylabel('Wavenumber');
end

end
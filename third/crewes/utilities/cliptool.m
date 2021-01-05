function a=cliptool(hpan,data,callback)
%
% cliptool(hpan,data,callback)
%
% This implements simplified graphical clipping. CLIPTOOL installs a small GUI control in a panel in
% the same Figure that contains the axis under control. The basic idea is to create a small panel in
% an existing Figure, typically 200 pixels wide and 150 tall, and pass the handle of the panel,
% together with the axes handle containing the image to be controlled to this function. It then puts
% a GUI in the small panel which shows the amplitude histogram, drawn by bar.m, of the data
% comprising the image and places two vertical red lines on the histogram indicating the CLIM
% values. CLIM value are the limits of the colorbar and control amplitude clipping. The redlines can
% be dragged to interactivly change the clipping. There are additional functions accessible through
% a right click in the background (i.e. a context menu). Search for 'cliptool' in seisplot.m for a
% simple example of its use.
%
% NOTE: The clim values provided to cliptool, as well as those retrieved by the 'getlims' option,
% are expressed in "normalized" fashion in terms of sigma which is usually the standard deviation.
% So for example, providing the first element of "data" as [-3 3] means that the clim actually set in
% the axes containing the image is [-3 3]*sigma. Usually, when sigma is not prescribed in "data",
% the first action of cliptool is to access the image in the axes and calculate its standard
% deviation. The setting set(hseis,'clim',[-3 3]*sigma) will then cause the colormap to extend from
% -3 standard deviations to +3 standard deviations about 0. This is appropriate for normal seismic
% data which are essentially zero mean. For data like amplitude spectra, which are never negative, a
% clim setting of something like [-.5 6] is more appropriate. For decibel spectra, it is usually
% best to prescribe sigma=1.
%
% NOTE: There should be only one image plot in the axes whose handle is passed to cliptool. To
% control more than one image, use the callback option and extract the clime from the controlled
% axes like Clim=get(hseis,'clim') and then set the second axes with set(haxes2,'clim',Clim). The
% clim extracted with the get command will contain the sigma multiplier whereas the the clim
% obtained by clim=cliptool('getlims',hseis) will be normalized. This means that sigma is given by
% the ratio sigma=Clim(k)/clim(k) where k is 1 or 2.
%
% hpan ... handle of the panel to put the tool in. The parent of hpan must be a Figure.
% data ... length=2 to length=6 cell array containing {clim,hseis,sigma,motionflag,plotflag,cbflag} 
%           where clim=[cl1 cl2]= initial clim values expressed as standard deviations like [-3,3],
%           hseis=handle of the axes to control, sigma=value to use for standard deviation (this
%           bypasses measurement), motionflag (1 for symmetric, 0 for independent, default is 1),
%           plotflag (1 for linear, 0 for log, default is 1),cbflag of 1 means execute the callback
%           on creation, 0 means don't. Default is zero on creation, 1 on refresh.
%           data must be at least length 2 but longer is optional.
%           Example: data={[-3 3],hax} means clipping at +/- 3 sigma and the data is in axis hax.
%               sigma and the amplitude histogram will be measured and motionflag and plotflag are
%               defaulted.
%           Example: data={[-3 3],hax,sigma} means clipping at +/- 3*sigma and the data is in axis
%               hax. Sigma is specified by the third entry (if sigma is empty it will be measured)
%               and the amplitude histogram will be measured and motionflag and plotflag are
%               defaulted.
%           Example: data={[-80 1],hax,1,0,0} means clipping between -80 and 1 with sigma=1 and the
%               data is in axis hax. This is appropriate for a decibel spectral display. Sigma is
%               specified as 1 (db) and the amplitude histogram will be measured. motionflag and
%               plotflag are ate set to independent and log.
% callback ... callback to execute whenever clipping is changed. The current clim values are
%           retrieved by lims=cliptool('getlims',hpan). Often a callback is not needed so this can
%           be specified as ''. Callbacks are useful when the application needs to remember the clim
%           settings or when more than one image is to be controlled by the setting.
%
% - Refresh the histogram
%       cliptool('refresh',hpan,data)
%           here hpan is the handle of the panel containing the cliptool, and
%           data={clim,hseis,sigma,motionflag,plotflag} as above. Read the examples!!
% - Get the clim values from the slider window
%       lims=cliptool('getlims',hpan)
%           Again hpan is the handle of the panel containing the cliptool while lims will be a
%           length 2 vector containing the slider limit positions (smallest first)
% - Set the clim values
%       cliptool('setlims',hpan,clim)
%           First two arguments as in previous case. clim is length 2 with the secon value larger
%           than the first. These are the sigma values at which clipping occurs 

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED
global CLIPTOOLHELP CLIMTOOLDATA
if(ischar(hpan))
    action=hpan;
else
    action='init';
end

a=[];


if(strcmp(action,'init'))
    hfig=gcf;
    %search for other clip objects
    hclipother=findobj(hpan.Parent,'tag','clipobj');
    if(~isempty(hclipother))
        ico=0;
        for k=1:length(hclipother)
            tmp=hclipother(k).UserData;
            ico=max([tmp{3} ico]);
        end
        ico=ico+1;
    else
        ico=1;
    end
    clim=data{1};
    haxseis=data{2};
    %measure stats
    if(length(data)<3)
        [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        motionflag=1;
        plotflag=1;
        cbflag=0;
    elseif(length(data)<4)
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=1;
        plotflag=1;
        cbflag=0;
    elseif(length(data)<5)
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=data{4};
        plotflag=1;
        cbflag=0;
    elseif(length(data)<6)
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=data{4};
        plotflag=data{5};
        cbflag=0;
    else
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=data{4};
        plotflag=data{5};
        cbflag=data{6};
    end
    %check clim
    dA=.1*(Amax-Amin);
    if(clim(2)*sigma>Amax+dA)
        clim(2)=(Amax+dA)/sigma;
    end
    if(clim(1)*sigma<Amin-dA)
        clim(1)=(Amin-dA)/sigma;
    end
    
    symmetric='on';
    indep='off';
    if(motionflag==0)
        symmetric='off';
        indep='on';
        motionflag=0; %1 for symmetric, 0 for independent
    end
    %
    hclim=uipanel(hpan,'position',[0 0 1 1]);
    
    set(hclim,'tag','clipobj','userdata',{callback,clim,ico,haxseis,sigma,motionflag,Amax,Amin,N,xn,[]});
    axsize=[.1 .1 .8 .7];
    hax=axes(hclim,'position',axsize);
    disableDefaultInteractivity(hax);
    kol2=[1 0 0];%color of clim lines
    %horizontal orientation
    hfig.CurrentAxes=hax;
%     bar(hax,xn/sigma,N,'k');
    if(plotflag)
        y=N;
        plotlin='on';
        plotlog='off';
    else
        y=log(N+2);
        plotlin='off';
        plotlog='on';
    end
    bar(hax,xn/sigma,y,'k','barwidth',1);
    yl=[0 1.1*max(y)];
    if(sum(abs(yl))==0); yl=[0 1];end
    set(hax,'ytick',[],'xticklabel',[],'ylim',yl);
    line([0 0],yl,'color','g','linestyle',':','tag','zeroline','linewidth',3);%zero line
    line([clim(1) clim(1)],yl,[1 1],'color',kol2,'buttondownfcn','cliptool(''dragline'');',...
        'tag','clim1');
    text(clim(1),.5*diff(yl),textstr(clim(1)),'horizontalalignment','right','tag','txt1',...
        'fontsize',6,'color','r');
    line([clim(2) clim(2)],yl,[1 1],'color',kol2,'buttondownfcn','cliptool(''dragline'');',...
        'tag','clim2');
    text(clim(2),.5*diff(yl),textstr(clim(2)),'horizontalalignment','left','tag','txt2',...
        'fontsize',6,'color','r');
    if(Amin>=0)
        nc=round(Amax/sigma/clim(2));
        set(hax,'xlim',[-Amin/sigma .5*nc*clim(2)]);
    else
        delc=.5*diff(clim);
        set(hax,'xlim',[clim(1)-delc clim(2)+delc]);
    end
    xl=xlim;
    delcl=diff(clim);
    factor=.2;
    if(clim(1)<xl(1)||clim(2)>xl(2))
        x2=clim(2)+factor*delcl;
        x1=clim(1)-factor*delcl;
        xlim([x1 x2]);
    end
    xl=xlim;
%     xp=hp.XData;
    if(xl(1)<clim(1)-factor*delcl)
        xl(1)=clim(1)-factor*delcl;
    end
    if(xl(2)>clim(2)+factor*delcl)
        xl(2)=clim(2)+factor*delcl;
    end
    xlim(xl);
    hcm=uicontextmenu(hfig);
    uimenu(hcm,'label','Symmetric motion','callback','cliptool(''motion'');','checked',symmetric);
    uimenu(hcm,'label','Independent motion','callback','cliptool(''motion'');','checked',indep);
    uimenu(hcm,'label','Set Max','callback','cliptool(''setmax'');');
    uimenu(hcm,'label','Set Min','callback','cliptool(''setmin'');');
    uimenu(hcm,'label','Set Symmetric','callback','cliptool(''setminmax'');');
    hex=uimenu(hcm,'label','Expand axes');
    uimenu(hex,'label','Min&Max','callback','cliptool(''expand'');');
    uimenu(hex,'label','Max','callback','cliptool(''expandmax'');');
    uimenu(hex,'label','Min','callback','cliptool(''expandmin'');');
    hcon=uimenu(hcm,'label','Contract axes');
    uimenu(hcon,'label','Min&Max','callback','cliptool(''contract'');');
    uimenu(hcon,'label','Max','callback','cliptool(''contractmax'');');
    uimenu(hcon,'label','Min','callback','cliptool(''contractmin'');');

    uimenu(hcm,'label','Linear plot','callback','cliptool(''replot'');','checked',plotlin);
    uimenu(hcm,'label','Log plot','callback','cliptool(''replot'');','checked',plotlog);
    uimenu(hcm,'label','Plot distribution in sep window','callback','cliptool(''sepplot'');');
    set(hax,'uicontextmenu',hcm)
    hax.FontSize=6;
    factor=.5;
    annotation(hclim,'textbox','position',[factor*axsize(1),axsize(2)+axsize(4),axsize(1)+.5*axsize(3),1-axsize(2)-axsize(4)],...
        'string','min','horizontalalignment','left','verticalalignment','middle','linestyle','none',...
        'fontsize',8);
    annotation(hclim,'textbox','position',[.5,axsize(2)+axsize(4),.5*axsize(3)+factor*axsize(1),1-axsize(2)-axsize(4)],...
        'string','max','horizontalalignment','right','verticalalignment','middle','linestyle','none',...
        'fontsize',8);
    %help button
    h=.25;w=.08;
    uicontrol(hclim,'style','pushbutton','string','?','units','normalized','tag','helpclip',...
        'position',[axsize(1)+axsize(3),axsize(2)+.5*axsize(4),w,h],...
        'callback','cliptool(''help'');','backgroundcolor','y');
    %line to mark zero amp
%     xl=xlim;
%     xzero=interp1(xl,[axsize(1),axsize(1)+axsize(3)],0);
%     annotation(hclim,'line',[xzero,xzero],[axsize(2)+axsize(4),1],'linewidth',1);
    %     title('drag the red lines or right-click in white space','fontsize',8,'fontweight','normal');
    %     if(~isempty(callback))
    %         cbflag=1;
    %     end
    cliptool('setclim',cbflag,hclim);
elseif(strcmp(action,'help'))
    hfig=gcf;
    hbut=gcbo;
    posfig=hfig.Position;
    hpan=get(get(hbut,'parent'),'parent');
    units=hpan.Units;
    hpan.Units='pixels';
    pospan=hpan.Position;
    hpan.Units=units;
    xfig=posfig(1)+pospan(1)+pospan(3);
    yfig=posfig(2)+pospan(2)+pospan(4);
    scrn=get(0,'screensize');
    if(~isempty(CLIPTOOLHELP))
        if(isgraphics(CLIPTOOLHELP))
            poshelp=get(CLIPTOOLHELP,'position');
            if(yfig+poshelp(4)>scrn(4))
                yfig=scrn(4)-1.1*poshelp(4);
            end
            set(CLIPTOOLHELP,'position',[xfig,yfig,poshelp(3:4)]);
            figure(CLIPTOOLHELP)
            return
        end
    end
    msg={['This tool enables interactive control of clipping for an image display. The graph ',...
        'shows the distribution of amplitudes in the image and the vertical red lines show the ',...
        'current extent of the colorbar. The dotted green line shows the position of zero ',...
        'amplitude. The x axis is amplitude and the y axis is number of samples. ',...
        'The text labels for the red lines give their position as ',...
        'a number of characteristic distances from zero amplitude. For normal seismic data this characteristic ',...
        'distance is the standard deviation of the ampltude distribution. For linear display of amplitude ',...
        'spectra it is also the standard deviation but for decibel display it is 1 db. '],' ',[...
        'Amplitudes between the red lines are faithfully mapped to ',...
        'color in the current colormap as displayed by the colorbar (if available). Amplitudes outside this range ',...
        'are "clipped" meaning that they are assigned to either end of the colorbar. ',...
        'The extent of the colorbar can be adjusted by clicking and dragging the red lines to new positions. '],...
        ' ',['Usually, the red lines move symmetrically meaning, for example, a displacment of one by X to the right ',...
        'will cause the other to move X to the left. This can be changed to independent movement by ',...
        'right-clicking in the white space of the axes and making the appropriate selection from the ',...
        'context menu. However, for amplitude spectra, which are never negative, ',...
        'the initial setting is for independent movement. '],' ',...
        ['Additional functionality accessed by right-clicking in the white space allows the x axis ',...
        'to be expanded or contracted and the min and max clipping locations to be set at the ',...
        'point of the mouse click. The "Set Symmetric" option sets both min and max symmetrically.'],' ',...
        ['The statistics used by this tool (the amplitude distribution and the standard devaition) ',...
        'are calculated excluding hard zeros. For 2D data, the standard deviation is always that of ',...
        'image being analyzed. For 3D data, the standard deviation is that of the entire 3D dataset ',...
        'which may differ from that of the display.']};  
    w=400;h=600;
    if(yfig+h>scrn(4))
       yfig=scrn(4)-1.1*h;
    end
    xc=xfig+.5*w;
    yc=yfig+.5*h;
    CLIPTOOLHELP=showinfo(msg,'Clipping Help',[xc,yc],[w,h],2);
    %register the new figure with parent
    updatefigureuserdata(hfig,CLIPTOOLHELP)
elseif(strcmp(action,'setclim'))
    %this action interrogates the red lines to determine clim and then sets the clim property in the
    %controlled axes. It also sets the text labels of the lines and calls the user callback
    if(nargin<3)
        cbflag=CLIMTOOLDATA{1};
        hclim=CLIMTOOLDATA{2};
    else
        cbflag=data;
        hclim=callback;
    end
    hax=findobj(hclim,'type','axes');
    h1=findobj(hax,'tag','clim1');%red line #1
    h2=findobj(hax,'tag','clim2');%red line #2
    htxt1=findobj(hax,'tag','txt1');%text #1
    txt1pos=htxt1.Position;
    htxt2=findobj(hax,'tag','txt2');%text #2
    txt2pos=htxt2.Position;
    xx=h1.XData;
    clim1=xx(1);%position of h1
    xx=h2.XData;
    clim2=xx(1);%position of h2
    %hclim=get(gca,'parent');
    ud=hclim.UserData;
    callback=ud{1};
    clim_prev=ud{2};
    motionflag=ud{6};
    if(~isempty(DRAGLINE_PAIRED))
        if(motionflag && isgraphics(DRAGLINE_PAIRED))
            %symmetric motion. We determine which line moved and move the other in similar fashion
            hother=DRAGLINE_PAIRED;
            if(hother==h1)
                displacement=clim2-clim_prev(2);
                clim1=clim_prev(1)-displacement;
                h1.XData=[clim1 clim1];
            else
                displacement=clim1-clim_prev(1);
                clim2=clim_prev(2)-displacement;
                h2.XData=[clim2 clim2];
            end
        end
    end
    set(htxt1,'position',[clim1 txt1pos(2:3)],'string',textstr(clim1));
    set(htxt2,'position',[clim2 txt2pos(2:3)],'string',textstr(clim2));
    ud{2}=[clim1 clim2];
    hclim.UserData=ud;
    %when creating a cliptool with an image not yet formed, the clim value can be invalid and the
    %diff test ensures that we don't attempt to set an invalid clim
    if(diff(ud{2})>0)
        set(ud{4},'clim',ud{2}*ud{5})%ud{5} is sigma
    end
    if(cbflag)
        eval(callback);
    end
elseif(strcmp(action,'dragline'))
    hh=gco;
    xl=get(gca,'xlim');
    dxl=.05*diff(xl);
    h1=findobj(gca,'tag','clim1');
    h2=findobj(gca,'tag','clim2');
    xx=get(h1,'xdata');
    clim1=xx(1);
    xx=get(h2,'xdata');
    clim2=xx(1);
    DRAGLINE_MOTION='xonly';
    hclim=get(gca,'parent');
    ud=hclim.UserData;
    motionflag=ud{6};
    symmetric=false;
    if(~isempty(DRAGLINE_PAIRED))
        if(motionflag && isgraphics(DRAGLINE_PAIRED))
            symmetric=true;
        end
    end
    if(hh==h1)
        %we are dragging h1
        if(symmetric)
            DRAGLINE_XLIMS=[xl(1)+dxl .5*(clim2+clim1)-.05*(clim2-clim1)];
        else
            DRAGLINE_XLIMS=[xl(1)+dxl clim2];
        end
        DRAGLINE_PAIRED=h2;
    else
        %we are dragging h2
        if(symmetric)
            DRAGLINE_XLIMS=[.5*(clim1+clim2)+.05*(clim2-clim1) xl(2)-dxl];
        else
            DRAGLINE_XLIMS=[clim1 xl(2)-dxl];
        end
        DRAGLINE_PAIRED=h1;
    end
    DRAGLINE_YLIMS=[];
    DRAGLINE_SHOWPOSN='off';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='cliptool(''setclim'');';
    hclim=get(gca,'parent');
    CLIMTOOLDATA={1,hclim};
    dragline('click')
elseif(strcmp(action,'refresh'))
    % This action is invoked by the user whenever the image under control has changed and the
    % statistics must be reset.
    hfig=gcf;
    haxcurr=hfig.CurrentAxes;
    hpan=data;
    data=callback;
    clim=data{1};
    haxseis=data{2};
    %measure stats
    if(length(data)<3)
        [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        motionflag=1;
        plotflag=1;
        cbflag=1;
    elseif(length(data)<4)
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=1;
        plotflag=1;
        cbflag=1;
    elseif(length(data)<5)
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=data{4};
        plotflag=1;
        cbflag=1;
    elseif(length(data)<6)
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=data{4};
        plotflag=data{5};
        cbflag=1;
    else
        sigma=data{3};
        if(isempty(sigma))
            [N,xn,sigma,Amax,Amin]=measurestats(haxseis);
        else
            [N,xn,~,Amax,Amin]=measurestats(haxseis,sigma);
        end
        motionflag=data{4};
        plotflag=data{5};
        cbflag=data{6};
    end
    figure(hfig);
    hax=findobj(hpan,'type','axes');
    %set the motion menus
    hcm=hax.UIContextMenu;
    hsm=findobj(hcm,'label','Symmetric motion');
    him=findobj(hcm,'label','Independent motion');
    if(motionflag==1)
        hsm.Checked='on';
        him.Checked='off';
    else
        hsm.Checked='off';
        him.Checked='on';
    end
    hfig.CurrentAxes=hax;
    hbar=findobj(hax,'type','bar');
    delete(hbar);
    haxecurr=hfig.CurrentAxes;
    hfig.CurrentAxes=hax;
    hold on
    hlin=findobj(hcm,'label','Linear plot');
    hlog=findobj(hcm,'label','Log plot');
    if(plotflag)
        y=N;
        hlin.Checked='on';
        hlog.Checked='off';
    else
        y=log(N+2);
        hlin.Checked='off';
        hlog.Checked='on';
    end
    bar(hax,xn/sigma,y,'k','barwidth',1);
    hold off
    yl=[0 1.1*max(y)];
    ylim(yl)
    h1=findobj(hax,'tag','clim1');%red line #1
    h1.YData=yl;
    h2=findobj(hax,'tag','clim2');%red line #2
    h2.YData=yl;
    htxt1=findobj(hax,'tag','txt1');%text #1
    txt1pos=htxt1.Position;
    htxt1.Position=[txt1pos(1),.5*diff(yl),txt1pos(3)];
    htxt2=findobj(hax,'tag','txt2');%text #2
    txt2pos=htxt2.Position;
    htxt2.Position=[txt2pos(1),.5*diff(yl),txt2pos(3)];
    hz=findobj(hax,'tag','zeroline');
    hz.YData=yl;
    hfig.CurrentAxes=haxecurr;
    hclim=findobj(hpan,'tag','clipobj');
    ud=hclim.UserData;
    ud{4}=haxseis;
    ud{5}=sigma;
    ud{6}=motionflag;
    ud{7}=Amax;
    ud{8}=Amin;
    ud{9}=N;
    ud{10}=xn;
    %check clim
%     dA=.05*(Amax-Amin);
%     if(clim(2)*sigma>Amax+dA)
%         clim(2)=(Amax+dA)/sigma;
%     end
%     if(clim(1)*sigma<Amin-dA)
%         clim(1)=(Amin-dA)/sigma;
%     end
    ud{2}=clim;
    hclim.UserData=ud;
    yl=hax.YLim;
    set(h1,'ydata',yl,'xdata',[clim(1) clim(1)])
    set(h2,'ydata',yl,'xdata',[clim(2) clim(2)])
    xl=xlim;
    delcl=diff(clim);
    if(clim(1)<xl(1)||clim(2)>xl(2))
        x2=clim(2)+.5*delcl;
        x1=clim(1)-.5*delcl;
        xlim([x1 x2]);
    end
    xl=xlim;
%     xp=hp.XData;
    if(xl(1)<clim(1)-.5*delcl)
        xl(1)=clim(1)-.5*delcl;
    end
    if(xl(2)>clim(2)+.5*delcl)
        xl(2)=clim(2)+.5*delcl;
    end
    xlim(xl);
    %     set(hax,'clim',clim)
    cliptool('setclim',cbflag,hclim);
    hfig.CurrentAxes=haxcurr;
elseif(strcmp(action,'replot'))
    % This is invoked by the context menu selection of linear plot or log plot
    hfig=gcf;
    haxcurr=hfig.CurrentAxes;
    hp=gcbo;
    hp.Checked='on';
    hcm=hp.Parent;
    hax=gca;
    hpan=hax.Parent;
    if(contains(hp.Label,'Linear'))
        hpb=findobj(hcm,'label','Log plot');
        hpb.Checked='off';
        plotflag=1;
    else
        hpb=findobj(hcm,'label','Linear plot');
        hpb.Checked='off';
        plotflag=0;
    end
    hclim=findobj(hpan,'tag','clipobj');
    ud=hclim.UserData;
    clim=ud{2};
    sigma=ud{5};
    N=ud{9};
    xn=ud{10};
    hb=findobj(hax,'type','bar');
    delete(hb);
    hold on
    if(plotflag)
        y=N;
    else
        y=log(N+2);
    end
    bar(hax,xn/sigma,y,'k','barwidth',1);
    hold off
    yl=[0 1.1*max(y)];
    ylim(yl)
    h1=findobj(hax,'tag','clim1');%red line #1
    h1.YData=yl;
    h2=findobj(hax,'tag','clim2');%red line #2
    h2.YData=yl;
    htxt1=findobj(hax,'tag','txt1');%text #1
    txt1pos=htxt1.Position;
    htxt1.Position=[txt1pos(1),.5*diff(yl),txt1pos(3)];
    htxt2=findobj(hax,'tag','txt2');%text #2
    txt2pos=htxt2.Position;
    htxt2.Position=[txt2pos(1),.5*diff(yl),txt2pos(3)];
    hz=findobj(hax,'tag','zeroline');
    hz.YData=yl;
    xl=xlim;
    
    delcl=diff(clim);
    if(clim(1)<xl(1)||clim(2)>xl(2))
        x2=clim(2)+.5*delcl;
        x1=clim(1)-.5*delcl;
        xlim([x1 x2]);
    end
    xl=xlim;
    if(xl(1)<clim(1)-.5*delcl)
        xl(1)=clim(1)-.5*delcl;
    end
    if(xl(2)>clim(2)+.5*delcl)
        xl(2)=clim(2)+.5*delcl;
    end
    xlim(xl);
    hfig.CurrentAxes=haxcurr;
elseif(strcmp(action,'getlims'))
    %this action returns the normalized clim values.
    hpan=data;
    hcaxe=findobj(hpan,'type','axes');
    h1=findobj(hcaxe,'tag','clim1');
    h2=findobj(hcaxe,'tag','clim2');
    if(isempty(h1) || isempty (h2))
        return;
    end
    xx=get(h1,'xdata');
    clim1=xx(1);
    xx=get(h2,'xdata');
    clim2=xx(2);
    a=[clim1 clim2];
    % elseif(strcmp(action,'setlims'))
    %     hfig=gcf;
    %     hcaxe=get(hfig,'currentaxes');%using second argument
    %     h1=findobj(hcaxe,'tag','clim1');
    %     h2=findobj(hcaxe,'tag','clim2');
    %     if(isempty(h1) || isempty (h2) || nargin~=3)
    %         return;
    %     end
    %     clims=pos;%third argument
    %     set(h1,'xdata',clims(1)*ones(1,2));
    %     set(h2,'xdata',clims(2)*ones(1,2));
    %     figure(hfig);
    %     cliptool('setclim');
elseif(strcmp(action,'setmax'))
    haxe=gca;
    hclim=get(gca,'parent');
    h1=findobj(haxe,'tag','clim1');
    Amin=h1.XData(1);
    h2=findobj(haxe,'tag','clim2');
    pt=haxe.CurrentPoint;
    DRAGLINE_PAIRED=[];
    if(pt(1)<Amin)
        hm=msgbox('You cannot set the maximum less than the minimum');
        WinOnTop(hm,true);
    else
        set(h2,'xdata',[pt(1) pt(1)]);
        cliptool('setclim',1,hclim);
    end
elseif(strcmp(action,'setmin'))
    haxe=gca;
    hclim=get(gca,'parent');
    h1=findobj(haxe,'tag','clim1');
    h2=findobj(haxe,'tag','clim2');
    Amax=h2.XData(1);
    pt=haxe.CurrentPoint;
    DRAGLINE_PAIRED=[];
    if(pt(1)>Amax)
        hm=msgbox('You cannot set the minimum greater than the maximum');
        WinOnTop(hm,true);
    else
        set(h1,'xdata',[pt(1) pt(1)]);
        cliptool('setclim',1,hclim);
    end
elseif(strcmp(action,'setminmax'))
    haxe=gca;
    hclim=get(gca,'parent');
    h1=findobj(haxe,'tag','clim1');
%     Amin=h1.XData(1);
    h2=findobj(haxe,'tag','clim2');
    pt=haxe.CurrentPoint;
    if(pt(1)<0)
        set(h1,'xdata',[pt(1) pt(1)]);
        set(h2,'xdata',[-pt(1) -pt(1)]);
        cliptool('setclim',1,hclim);
    else
        set(h1,'xdata',[-pt(1) -pt(1)]);
        set(h2,'xdata',[pt(1) pt(1)]);
        cliptool('setclim',1,hclim);
    end
elseif(strcmp(action,'expand'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)-.5*dx xl(2)+.5*dx];
elseif(strcmp(action,'contract'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)+.25*dx xl(2)-.25*dx];
elseif(strcmp(action,'contractmin'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)+.33*dx xl(2)];
elseif(strcmp(action,'expandmin'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)-.5*dx xl(2)];
elseif(strcmp(action,'contractmax'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1) xl(2)-.33*dx];
elseif(strcmp(action,'expandmax'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1) xl(2)+.5*dx];
elseif(strcmp(action,'motion'))
    hm=gcbo;
    hcntx=get(hm,'Parent');
    label=get(hm,'label');
    hclim=get(gca,'parent');
    ud=hclim.UserData;
    switch label
        case 'Symmetric motion'
            state=get(hm,'checked');
            hm2=findobj(hcntx,'label','Independent motion');
            switch state
                case 'on'
                    set(hm,'checked','off');
                    set(hm2,'checked','on');
                    ud{6}=0;
                case 'off'
                    set(hm,'checked','on');
                    set(hm2,'checked','off');
                    ud{6}=1;
            end
            
        case 'Independent motion'
            state=get(hm,'checked');
            hm2=findobj(hcntx,'label','Symmetric motion');
            switch state
                case 'on'
                    set(hm,'checked','off');
                    set(hm2,'checked','on');
                    ud{6}=1;
                case 'off'
                    set(hm,'checked','on');
                    set(hm2,'checked','off');
                    ud{6}=0;
            end
    end
    hclim.UserData=ud;
elseif(strcmp(action,'sepplot'))
    hfig=gcf;
    posfig=hfig.Position;
    hax=gca;
    hclipobj=hax.Parent;
    units=hclipobj.Units;
    hclipobj.Units='pixels';
    pospan=hclipobj.Position;
    hclipobj.Units=units;
    xfig=posfig(1)+pospan(1)+pospan(3);
    yfig=posfig(2)+pospan(2)+pospan(4);
    scrn=get(0,'screensize');
    udat=hclipobj.UserData;
%     sigma=udat{5};
    Amax=udat{7};
    Amin=udat{8};
    if(~isempty(udat{11}))
        if(isgraphics(udat{11}))
            delete(udat{11});
        end
    end
    hbar=findobj(hax,'type','bar');
    xn=hbar.XData;
    N=hbar.YData;
    w=600;h=600;
    if(yfig+h>scrn(4))
       yfig=scrn(4)-1.1*h;
    end
    name=hfig.Name;
    figure;
    hfignew=gcf;
    set(hfignew,'numbertitle','off','menubar','none','toolbar','figure',...
        'name',['Amplitude histogram for ' name]);
    udat{11}=hfignew;
    hclipobj.UserData=udat;
    set(udat{11},'position',[xfig,yfig,w,h]);
    sigma=udat{5};
    bar(xn*sigma,N,'k','barwidth',1);
    xlabel('Amplitude');ylabel('Number of Samples');
    grid
    title(['Max amp: ' num2str(Amax) ', Min amp: ' num2str(Amin) ', Stdev: ' num2str(sigma)])
    %register the new figure with parent
    updatefigureuserdata(hfig,hfignew,['Amplitude histogram for ' name])
end
end

function [N,xn,sigma,Amax,Amin]=measurestats(hax,sigma)
    hi=findobj(hax,'type','image');
    if(isempty(hi))
       N=zeros(1,500);
       xn=1:500;
       if(nargin<2)
        sigma=.1;
       end
       Amax=10*sigma;
       Amin=-Amax;
       return
    end
    D=hi.CData;
    Amin=min(D);
    if(Amin>-0)
        %this means its something like a spectrum
        [nr,nc]=size(D);
        ir=1:round(.5*nr);
        ic=1:nc;
        npts=1000;
    else
        %probably normal data
        [nr,nc]=size(D);
        ir=round(.1*nr):round(.9*nr);
        ic=round(.1*nc):round(.9*nc);
        npts=400;
    end
    D2=D(ir,ic);
    inonzero=D2~=0;
    Amax=max(D2(inonzero));
    Amin=min(D2(inonzero));
    if(nargin<2)
        sigma=std(D2(inonzero));
    end
    [N,xn]=hist(D2(inonzero),npts); %#ok<HIST>
end

function tstr=textstr(climval)%determines the appearance of the text labels for the red lines
tstr=num2str(round(climval*10)/10,3);
end


function a=climgraphical(hpan,data,callback)
%
% climgraphical(hpan,data,callback)
%
% This implements graphical clipping in Enhance browsers and tools. This differs from climslider in
% that it installs the GUI in a panel in the same Figure that contains the axis under control.  For
% any app, the basic idea is to create a small panel in an existing Figure, typically 200 pixels
% wide and 150 tall, and pass the handle of the panel, together with the axes handle containing the
% image to be controlled and the outputs from hist.m, to this function. It then puts a GUI in the
% small panel which shows the amplitude histogram, drawn by bar.m, of the data comprising the image
% and places two vertical red lines on the histogram indicating the CLIM values. CLIM value are the
% limits of the colorbar and control amplitude clipping. The redlines can be dragged to interactivly
% change the clipping. There are additional functions accessible through a right click in the
% background (i.e. a context menu). See the 'clip' action in PI3D for an example. For reasons having
% to do with RGB blends, this function does not set the CLIM directly. Rather, the callback is
% expected to do that.
%
% hpan ... handle of the panel to put the tool in. This function will set the tag to be 'clim'. The
%           parent of hpan must be a Figure
% data ... length=3 cell array containing {N,xn,clim} where
%           [N,xn]=hist(data(:),100);
%           clim=[cl1 cl2]= initial clim values
% callback ... callback to execute whenever clipping is changed. The current clim values are
%           retrieved by lims=climgraphical('getlims',hpan)
%
% - Refresh the histogram
%       climgraphical('refresh',hpan,data)
%           here hfig is the handle of the Figure containing the slider, N and xn are the new histogram
% - Get the clim values from the slider window
%       lims=climgraphical('getlims',hpan)
%           Again hfig is the handle of the Figure containing the slider while lims will be a length2 vector
%           containing the slider limit positions (smallest first)
% - Set the clim values
%       climgraphical('setlims',hpan,lims)
%           Arguments as in previous example

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED 

if(ischar(hpan))
    action=hpan;
else
    action='init';
end

a=[];
axsize=[.1 .3 .8 .5];

if(strcmp(action,'init'))
    clim=data{3};
    set(hpan,'tag','clim','userdata',{callback,clim});
    hax=axes(hpan,'position',axsize);
    kol2=[1 0 0];%color of clim lines
    %horizontal orientation
%     bar(data{2},data{1},'k');
    patch(data{2},data{1},'k');
    set(hax,'ytick',[]);ylabel('amplitude');%xlabel('amplitude')
    yl=get(gca,'ylim');
    line([clim(1) clim(1)],yl,'color',kol2,'buttondownfcn','climgraphical(''dragline'');',...
        'tag','clim1');
    line([clim(2) clim(2)],yl,'color',kol2,'buttondownfcn','climgraphical(''dragline'');',...
        'tag','clim2');
    delc=.5*diff(clim);
    set(hax,'xlim',[clim(1)-delc clim(2)+delc]);
    hcm=uicontextmenu(hpan.Parent);
    uimenu(hcm,'label','Set max amp line','callback','climgraphical(''setmax'');');
    uimenu(hcm,'label','Set min amp line','callback','climgraphical(''setmin'');');
    hex=uimenu(hcm,'label','Expand axes');
    uimenu(hex,'label','Min&Max','callback','climgraphical(''expand'');');
    uimenu(hex,'label','Max','callback','climgraphical(''expandmax'');');
    uimenu(hex,'label','Min','callback','climgraphical(''expandmin'');');
    hcon=uimenu(hcm,'label','Contract axes');
    uimenu(hcon,'label','Min&Max','callback','climgraphical(''contract'');');
    uimenu(hcon,'label','Max','callback','climgraphical(''contractmax'');');
    uimenu(hcon,'label','Min','callback','climgraphical(''contractmin'');');
    set(hax,'uicontextmenu',hcm)
    hax.FontSize=8;
    title('drag the red lines or right-click in white space','fontsize',8,'fontweight','normal');
%     set(hpan,'userdata',haxe);
%     xn=.9;yn=.9;
%     w=.1;h=.1;
%     uicontrol(hfig,'style','pushbutton','string','?','units','normalized','position',[xn,yn,w,h],...
%         'callback','climgraphical(''info'');','tag','info','backgroundcolor','y');

    climgraphical('setclim',0);
% elseif(strcmp(action,'info'))
%     hclim=findobj(gcf,'tag','clim');
%     ud=get(hclim,'userdata');
%     for k=1:length(ud)
%         if(isgraphics(ud(k)))
%             if(strcmp(get(ud(k),'tag'),'info'))
%                 figure(ud(k))
%                 return;
%             end
%         end
%     end
%     msg={'This window enables interactive control of clipping for an image display. The histogram ',...
%         'shows the distribution of amplitudes in the image and the vertical red lines show the ',...
%         'current extent of the colorbar. Amplitudes between the red lines are faithfully mapped to ',...
%         'color in the current colormap as displayed by the colorbar. Amplitudes outside this range ',...
%         'are "clipped" meaning that they are assigned to either end of the colorbar. You can adjust ',...
%         'the extent of the colorbar by clicking and dragging the red lines to new positions. ',...
%         'The initial placment of the red lines, and the extent of the amplitude axis of the histogram ',...
%         'are determined by the choice of a numerical clipping value displayed before choosing "graphical"',...
%         'clipping. For example, if this "clip" value was 3, then the red lines are placed a +/- 3 standard ',...
%         'deviations from the mean value and the axis range is triple the "clip" value. Therefore if ',...
%         'you wish to drag the red lines beyond the range of the axis, first choose a larger numerical ',...
%         'clip value and then choose graphical clipping. Similarly, if you need more detail in the ',...
%         'central part of the histogram, then first choose a smaller clip value and the choose "graphical".'};
%     pos=get(hclim,'position');
%     xc=pos(1)+.5*pos(3);
%     yc=pos(2)+.5*pos(4);
%     w=pos(3);h=pos(4);
%     hinfo=showinfo(msg,'Graphical clipping',[xc+.2*w,yc-1.2*h],[1.2*w,h],6);
%     ud=hclim.UserData;
%     set(hclim,'userdata',[ud hinfo],'tag','info');
elseif(strcmp(action,'setclim'))
    if(nargin<2)
        cbflag=1;
    else
        cbflag=data;
    end
    hclim=findobj(gcf,'tag','clim');
    hax=findobj(hclim,'type','axes');
    h1=findobj(hax,'tag','clim1');%red line #1
    %hclim=get(gca,'parent');
    ud=hclim.UserData;
    callback=ud{1};
    xx=h1.XData;
    clim1=xx(1);
    h2=findobj(hax,'tag','clim2');%red line #2
    xx=h2.XData;
    clim2=xx(2);
    ud{2}=[clim1 clim2];
    hclim.UserData=ud;
    if(cbflag)
        eval(callback)
    end
elseif(strcmp(action,'dragline'))
    hh=gco;
    xl=get(gca,'xlim');
    h1=findobj(gca,'tag','clim1');
    h2=findobj(gca,'tag','clim2');
    xx=get(h1,'xdata');
    clim1=xx(1);
    xx=get(h2,'xdata');
    clim2=xx(1);
    DRAGLINE_MOTION='xonly';
    if(hh==h1)
        %we are dragging h1
        DRAGLINE_XLIMS=[xl(1) clim2];
        DRAGLINE_PAIRED=h2;
    else
        %we are dragging h2
        DRAGLINE_XLIMS=[clim1 xl(2)];
        DRAGLINE_PAIRED=h1;
    end
    DRAGLINE_YLIMS=[];
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='climgraphical(''setclim'');';
    DRAGLINE_MOTIONCALLBACK='';
    dragline('click')
elseif(strcmp(action,'refresh'))
    xn=N;
    N=pos;
    figure(hfig);
    hax=findobj(hfig,'type','axes');
    hbar=findobj(hax,'type','bar');
    delete(hbar);
    set(hfig,'currentaxes',hax);
    hold on
    bar(xn,N,'k');
    hold off
    hclim=findobj(gcf,'tag','clim');
    haxe=get(hclim,'userdata');%the axes under control
    clim=get(haxe(1),'clim');
    hcaxe=get(hfig,'currentaxes');
    h1=findobj(hcaxe,'tag','clim1');
    h2=findobj(hcaxe,'tag','clim2');
    y1=0;y2=sigfig(1.2*max(N),2);
    set(h1,'ydata',[y1 y2],'xdata',[clim(1) clim(1)])
    set(h2,'ydata',[y1 y2],'xdata',[clim(2) clim(2)])
    ylim([y1 y2])
    delcl=diff(clim);
    x2=clim(2)+.2*delcl;
    x1=clim(1)-.2*delcl;
    xlim([x1 x2]);
elseif(strcmp(action,'getlims'))
    hcaxe=get(hfig,'currentaxes');
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
elseif(strcmp(action,'setlims'))
    hcaxe=get(hfig,'currentaxes');%using second argument
    h1=findobj(hcaxe,'tag','clim1');
    h2=findobj(hcaxe,'tag','clim2');
    if(isempty(h1) || isempty (h2) || nargin~=3)
        return;
    end
    clims=pos;%third argument
    set(h1,'xdata',clims(1)*ones(1,2));
    set(h2,'xdata',clims(2)*ones(1,2));
    figure(hfig);
    climgraphical('setclim');
elseif(strcmp(action,'close'))
    hfig=gcf;
    ud=get(hfig,'userdata');
    for k=1:length(ud)
        if(isgraphics(ud(k)))
            if(strcmp(get(ud(k),'tag'),'info'))
                delete(ud(k));
            end
        end
    end
    delete(hfig);
elseif(strcmp(action,'setmax'))
    haxe=gca;
    h1=findobj(haxe,'tag','clim1');
    Amin=h1.XData(1);
    h2=findobj(haxe,'tag','clim2');
    pt=haxe.CurrentPoint;
    if(pt(1)<Amin)
        hm=msgbox('You cannot set the maximum less than the minimum');
        WinOnTop(hm,true);
    else
        set(h2,'xdata',[pt(1) pt(1)]);
        climgraphical('setclim');
    end
elseif(strcmp(action,'setmin'))
    haxe=gca;
    h1=findobj(haxe,'tag','clim1');
    h2=findobj(haxe,'tag','clim2');
    Amax=h2.XData(1);
    pt=haxe.CurrentPoint;
    if(pt(1)>Amax)
        hm=msgbox('You cannot set the minimum greater than the maximum');
        WinOnTop(hm,true);
    else
        set(h1,'xdata',[pt(1) pt(1)]);
        climgraphical('setclim');
    end
elseif(strcmp(action,'expand'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)-.125*dx xl(2)+.125*dx];
elseif(strcmp(action,'contract'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)+.125*dx xl(2)-.125*dx];
elseif(strcmp(action,'contractmin'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)+.125*dx xl(2)];
elseif(strcmp(action,'expandmin'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1)-.125*dx xl(2)];
elseif(strcmp(action,'contractmax'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1) xl(2)-.125*dx];
elseif(strcmp(action,'expandmax'))
    haxe=gca;
    xl=haxe.XLim;
    dx=diff(xl);
    haxe.XLim=[xl(1) xl(2)+.125*dx];
end
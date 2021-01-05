function test_dragbox(arg)
global DRAGBOX_MOTION DRAGBOX_XLIMS DRAGBOX_YLIMS DRAGBOX_SHOWPOSN DRAGBOX_POSNTXT 
global DRAGBOX_CALLBACK DRAGBOX_PAIRED DRAGBOX_MOTIONCALLBACK DRAGBOX_PT
global DRAGBOX_MAXWID DRAGBOX_MINWID DRAGBOX_MAXHT DRAGBOX_MINHT
persistent hp
if(nargin<1)
    figure
    axis([1000 1400 0 3]);
    x=1000:1400;
    t=0:.001:3;
    pct=25;
    tinc=pct*(t(end)-t(1))/100;
    xinc=pct*abs(x(end)-x(1))/100;
    tmin=t(1)+tinc;
    tmax=t(end)-tinc;
    xmin=min(x)+xinc;
    xmax=max(x)-xinc;
    dragbox('draw',[xmin xmax xmax xmin tmin tmin tmax tmax],'test_dragbox(''click'')');
    dragbox('labels',{'Max X','Min X','Max Y','Min Y'});
    grid
    title({'Drag a side to reposition, drag a corner to resize','The green infill is not part of Dragbox'})
    DRAGBOX_MAXWID=xmax-xmin;
    DRAGBOX_MINWID=.1*(xmax-xmin);
    DRAGBOX_MAXHT=tmax-tmin;
    DRAGBOX_MINHT=.1*(tmax-tmin);
elseif(strcmp(arg,'click'))
    xl=get(gca,'xlim');
    dx=diff(xl);
    p=.01;
    DRAGBOX_XLIMS=[xl(1)+p*dx xl(2)-p*dx];
    yl=get(gca,'ylim');
    dy=diff(yl);
    DRAGBOX_YLIMS=[yl(1)+p*dy yl(2)-p*dy];
    DRAGBOX_CALLBACK='test_dragbox(''done'');';
    DRAGBOX_MOTIONCALLBACK='test_dragbox(''color'');';
elseif(strcmp(arg,'color'))
    if(isgraphics(hp))
        delete(hp)
    end
    hbox=findobj(gcf,'tag','box');
    xb=hbox.XData;
    yb=hbox.YData;
    hp=patch(xb,yb,'g','edgecolor','w');
elseif(strcmp(arg,'done'))
    if(isgraphics(hp))
        delete(hp)
    end
end
    
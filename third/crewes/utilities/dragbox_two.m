function dragbox_two(action,arg2,bdf,kol,lw,ls)
% dragbox ... allows constrained dragging of a box with the mouse
%
% dragbox_two('draw1',coords,bdf,kol,lw,ls) %draws the initial box in the current axes
% dragbox_two('draw2',coords,bdf,kol,lw,ls) %draws the second box in the current axes
%   where   coords ... length 8 vector with coordinates of 3 corners. first 4 are x, then y
%           bdf=buttondownfcn to be assigned to the box when drawn
%           kol ... color of the box (default 'r')
%           lw ... linewidth (default 1)
%           ls ... linestyle (default '-' or solid)
% dragbox_two('labels',labels) %provides labels for the four sides of the box
%   where labels ... length 4 cell array with labels{1} the min-x label, labels{2} is max-x
%                    labels{3} is min-y and labels{4} is max-y. All are strings and will be attached
%                    to the corresponding sides of the box and will move with the box. Must be
%                    length 4, if certain labels are not desired, then provide them as ''.
%dragbox_two('setbox',nbox,xmin,xmax,ymin,ymax) %sets a box to a specified size and position
%                    nbox is either 1 or 2 as the box number. 
%   
%           
%
% dragbox is designed to allow the user to click on an existing rectangle object and move or
% resize it. The initial rectangle must be drawn by dragbox using the call given above. Behaviour is
% controlled by globals. The motion can be 'free' in both x and y or constrained to x or y. Limits
% on the motion can also be prescribed. To use this, set the 'buttondownfcn' of the box to call
% your code. Then in your callback, define the globals to get the desired behaviour and then your
% callback should call dragbox_two('click'). When the drag is finished, you can have your code called
% again by providing the callback global. For an example of using this, run the function
% test_dragbox with no inputs. Edit test_dragbox to see the code.
%
% Dragbox assigns tags to the box and the corner points. To find the handle of the box use
%   hbox=findobj(gcf,'tag','box');
% The four corners of the box are assigned the tags 'pt1', 'pt2', 'pt3', and 'pt4'. However, since
% coordinates of these corners are identical to the coordinates of the box, this is a bit redundant.
%
% Globals: 
%         DRAGBOX_MOTION: either 'xonly','yonly' or 'free'
%         DRAGBOX_MOTION2: either 'xonly','yonly' or 'free'
%         DRAGBOX_CALLBACK: callback to execute at the conclusion of the drag. This should be a matlab
%                            command as a string as it is passed to eval.
%         DRAGBOX_CALLBACK2: callback to execute at the conclusion of the drag. This should be a matlab
%                            command as a string as it is passed to eval.                        
%         DRAGBOX_MOTIONCALLBACK: callback to execute while the line is moving.  This should
%                           be a matlab command as a string as it is passed to eval.
%         DRAGBOX_MOTIONCALLBACK2: callback to execute while the line is moving.  This should
%                           be a matlab command as a string as it is passed to eval.
%         The next two are automatically set to the axes limits
%         DRAGBOX_XLIMS: [xmin xmax] being the min and max x coordinates allowed in the drag.
%                           Applies to any point on the box. 
%         DRAGBOX_XLIMS2: [xmin xmax] being the min and max x coordinates allowed in the drag.
%                           Applies to any point on the box. 
%         DRAGBOX_YLIMS: [ymin ymax] being the min and max y coordinates allowed in the drag.
%                           Applies to any point on the box. 
%         DRAGBOX_YLIMS2: [ymin ymax] being the min and max y coordinates allowed in the drag.
%                           Applies to any point on the box. 
%         The next four can control the allowed sizes of the box.
%         DRAGBOX_MAXWID: maximum allowed width for the box. If not provided then it is set to the
%                           width of the x axis.
%         DRAGBOX_MAXWID2: maximum allowed width for the box. If not provided then it is set to the
%                           width of the x axis.
%         DRAGBOX_MINWID: minimum allowed width for the box. If not provided then it is set to zero.
%         DRAGBOX_MINWID2: minimum allowed width for the box. If not provided then it is set to zero.
%         DRAGBOX_MAXHT: maximum allowed height for the box. If not provided then it is set to the
%                           height of the y axis.
%         DRAGBOX_MAXHT2: maximum allowed height for the box. If not provided then it is set to the
%                           height of the y axis.
%         DRAGBOX_MINHT: minimum allowed height for the box. If not provided then it is set to zero.
%         DRAGBOX_MINHT2: minimum allowed height for the box. If not provided then it is set to zero.
%
% NOTE: This function uses the userdata of the box so you should not.
% NOTE2: Good practice is to set any globals that you are not using to null so that there is no
%       conflict with other programs that may be using dragbox. For example, suppose that
%       program A uses both DRAGBOX_CALLBACK and DRAGBOX_MOTIONCALLBACK and sets them both
%       while program B uses only DRAGBOX_CALLBACK. If program B neglects to set
%       DRAGBOX_MOTIONCALLBACK to null (i.e. to '') then, if program A has been run first,
%       DRAGBOX_MOTIONCALLBACK may still be set to call program A when program B is used.
%       Program B should set this global to null to avoid this conflict.
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

%

% if(nargin<1) action='init'; end
% if(strcmp(action,'init'))
%   set(gcf,'windowbuttondownfcn','dragbox_two(''click'')');
%   return;
% end

global DRAGBOX_MOTION DRAGBOX_SHOWPOSN DRAGBOX_POSNTXT DRAGBOX_CALLBACK DRAGBOX_MOTIONCALLBACK
global DRAGBOX_MOTION2 DRAGBOX_SHOWPOSN2 DRAGBOX_POSNTXT2 DRAGBOX_CALLBACK2 DRAGBOX_MOTIONCALLBACK2
global DRAGBOX_PAIRED DRAGBOX_PT DRAGBOX_XLIMS DRAGBOX_YLIMS 
global DRAGBOX_PAIRED2 DRAGBOX_PT2 DRAGBOX_XLIMS2 DRAGBOX_YLIMS2 
global DRAGBOX_MAXWID DRAGBOX_MINWID DRAGBOX_MAXHT DRAGBOX_MINHT
global DRAGBOX_MAXWID2 DRAGBOX_MINWID2 DRAGBOX_MAXHT2 DRAGBOX_MINHT2
% DRAGBOX_POSNTXT is used internally and should not be set by user.

if(strcmp(action,'draw1'))
    if(nargin<3)
        bdf='';
    end
    if(nargin<4)
        kol='r';
    end
    if(nargin<5)
        lw=1;
    end
    if(nargin<6)
        ls='-';
    end
    n2=floor(length(arg2)/2);
    if(2*n2~=length(arg2))
        error('bad coordinate set');
    end
    box=arg2;%8 numbers, x then y of 4 corners
    xmin=min(box(1:4));
    xmax=max(box(1:4));
    ymin=min(box(5:8));
    ymax=max(box(5:8));
    x=[xmin xmin xmax xmax xmin];
    y=[ymin ymax ymax ymin ymin];
    z=ones(size(x));
    hline=line(x,y,z,'color',kol,'linestyle',ls','linewidth',lw,'tag','box1');
    hpts=zeros(1,4);
    for k=1:4
        hpts(k)=line(x(k),y(k),z(k)+1,'linestyle','none','marker','o','markersize',9,'tag',['pt' int2str(k)],'color',kol);
    end
    %define connections
    ix=[2 1 4 3];iy=[4 3 2 1];
    
    %invisible storage
    hb=[hline hpts];
    uicontrol(gcf,'style','text','units','normalized','position',[0,0,.05,.05],'visible','off',...
        'tag','handles1','userdata',{hb,ix,iy});
    if(isempty(bdf))
        set(hb,'buttondownfcn','dragbox_two(''click1'');');
    else
        if(bdf(end)~=';')
            bdf=[bdf ';'];
        end
        set(hb,'buttondownfcn',[bdf 'dragbox_two(''click1'');']);
    end
    return;
end
if(strcmp(action,'draw2'))
    if(nargin<3)
        bdf='';
    end
    if(nargin<4)
        kol='r';
    end
    if(nargin<5)
        lw=1;
    end
    if(nargin<6)
        ls='-';
    end
    n2=floor(length(arg2)/2);
    if(2*n2~=length(arg2))
        error('bad coordinate set');
    end
    box=arg2;%8 numbers, x then y of 4 corners
    xmin=min(box(1:4));
    xmax=max(box(1:4));
    ymin=min(box(5:8));
    ymax=max(box(5:8));
    x=[xmin xmin xmax xmax xmin];
    y=[ymin ymax ymax ymin ymin];
    z=ones(size(x));
    hline=line(x,y,z,'color',kol,'linestyle',ls','linewidth',lw,'tag','box2');
    hpts=zeros(1,4);
    for k=1:4
        hpts(k)=line(x(k),y(k),z(k)+1,'linestyle','none','marker','o','markersize',9,'tag',['pt' int2str(k)],'color',kol);
    end
    %define connections
    ix=[2 1 4 3];iy=[4 3 2 1];
    
    %invisible storage
    hb=[hline hpts];
    uicontrol(gcf,'style','text','units','normalized','position',[0,0,.05,.05],'visible','off',...
        'tag','handles2','userdata',{hb,ix,iy});
    if(isempty(bdf))
        set(hb,'buttondownfcn','dragbox_two(''click2'');');
    else
        if(bdf(end)~=';')
            bdf=[bdf ';'];
        end
        set(hb,'buttondownfcn',[bdf 'dragbox_two(''click2'');']);
    end
    return;
end
if(strcmp(action,'labels1'))
    labels=arg2;
    if(length(labels)~=4)
        return;
    end
    if(isempty(arg2))
        return;
    end
    hstor=findobj(gcf,'tag','handles1');
    if(isempty(hstor))
        return;
    end
    ud=hstor.UserData;
    hb=ud{1};
    xbox=hb.XData;
    ybox=hb.YData;
    xmin=min(xbox);
    xmax=max(xbox);
    ymin=min(ybox);
    ymax=max(ybox);
    xmean=.5*(xmax+xmin);
    ymean=.5*(ymax+ymin);
    z=.9;
    %                   h2
    %      pt2 +------------------+ pt3
    %          |                  |
    %          |                  |
    %          |h1                |h3
    %          |                  |
    %          |                  |
    %      pt1 +------------------+ pt4
    %                   h4
    % The diagram above is the numbering scheme for the points and the labels. Because of this,
    % the label handles do not have the same index as the strings in labels
    %
    hlabels=nan*zeros(1,4);
    if(~isempty(labels{1}))
        hlabels(3)=text(xmax,ymean,z,labels{1},'rotation',90,'horizontalalignment','center');
    end
    if(~isempty(labels{2}))
        hlabels(1)=text(xmin,ymean,z,labels{2},'rotation',90,'horizontalalignment','center');
    end
    if(~isempty(labels{3}))
        hlabels(2)=text(xmean,ymax,z,labels{3},'horizontalalignment','center');
    end
    if(~isempty(labels{4}))
        hlabels(4)=text(xmean,ymin,z,labels{4},'horizontalalignment','center');
    end
    ud{4}=hlabels;
    hstor.UserData=ud;
end
if(strcmp(action,'labels2'))
    labels=arg2;
    if(length(labels)~=4)
        return;
    end
    if(isempty(arg2))
        return;
    end
    hstor=findobj(gcf,'tag','handles2');
    if(isempty(hstor))
        return;
    end
    ud=hstor.UserData;
    hb=ud{1};
    xbox=hb.XData;
    ybox=hb.YData;
    xmin=min(xbox);
    xmax=max(xbox);
    ymin=min(ybox);
    ymax=max(ybox);
    xmean=.5*(xmax+xmin);
    ymean=.5*(ymax+ymin);
    z=.9;
    %                   h2
    %      pt2 +------------------+ pt3
    %          |                  |
    %          |                  |
    %          |h1                |h3
    %          |                  |
    %          |                  |
    %      pt1 +------------------+ pt4
    %                   h4
    % The diagram above is the numbering scheme for the points and the labels. Because of this,
    % the label handles do not have the same index as the strings in labels
    %
    hlabels=nan*zeros(1,4);
    if(~isempty(labels{1}))
        hlabels(3)=text(xmax,ymean,z,labels{1},'rotation',90,'horizontalalignment','center');
    end
    if(~isempty(labels{2}))
        hlabels(1)=text(xmin,ymean,z,labels{2},'rotation',90,'horizontalalignment','center');
    end
    if(~isempty(labels{3}))
        hlabels(2)=text(xmean,ymax,z,labels{3},'horizontalalignment','center');
    end
    if(~isempty(labels{4}))
        hlabels(4)=text(xmean,ymin,z,labels{4},'horizontalalignment','center');
    end
    ud{4}=hlabels;
    hstor.UserData=ud;
end
if(strcmp(action,'click1'))
    
    pt=get(gca,'currentpoint');
    DRAGBOX_PT=pt(1,1:2);
    
    hstor=findobj(gcf,'tag','handles1');
    ud=hstor.UserData;
    hb=ud{1};
    
    hbox=gco;
    obj=get(hbox,'tag');
    if(length(obj)<2)
        return;
    end
    if(strcmp(obj(1:2),'pt'))
%         disp('expand');
        set(gcf,'windowbuttonmotionfcn','dragbox_two(''expand1'')');
        set(gcf,'windowbuttonupfcn','dragbox_two(''fini1'')');
    else
%         disp('move');
        set(gcf,'windowbuttonmotionfcn','dragbox_two(''move1'')');
        set(gcf,'windowbuttonupfcn','dragbox_two(''fini1'')');
        DRAGBOX_PAIRED=hb(2:5);
    end
    
    
    return;
end
if(strcmp(action,'click2'))
    
    pt=get(gca,'currentpoint');
    DRAGBOX_PT2=pt(1,1:2);
    
    hstor=findobj(gcf,'tag','handles2');
    ud=hstor.UserData;
    hb=ud{1};
    
    hbox=gco;
    obj=get(hbox,'tag');
    if(length(obj)<2)
        return;
    end
    if(strcmp(obj(1:2),'pt'))
%         disp('expand')
        set(gcf,'windowbuttonmotionfcn','dragbox_two(''expand2'')');
        set(gcf,'windowbuttonupfcn','dragbox_two(''fini2'')');
    else
%         disp('move')
        set(gcf,'windowbuttonmotionfcn','dragbox_two(''move2'')');
        set(gcf,'windowbuttonupfcn','dragbox_two(''fini2'')');
        DRAGBOX_PAIRED2=hb(2:5);
    end
    
    
    return;
end
if(strcmp(action,'move1'))
    hbox=gco;
    xbox=hbox.XData;
    ybox=hbox.YData;
    motion=DRAGBOX_MOTION;
    if(isempty(motion))
        motion='free';
    end
    xlims=DRAGBOX_XLIMS;
    if(isempty(xlims))
        xlims=get(gca,'xlim');
    end
    ylims=DRAGBOX_YLIMS;
    if(isempty(ylims))
        ylims=get(gca,'ylim');
    end
    showposn=DRAGBOX_SHOWPOSN;
    if(isempty(showposn))
        showposn='off';
    end
    ptxt=DRAGBOX_POSNTXT;
    mcb=DRAGBOX_MOTIONCALLBACK;
    pt1=DRAGBOX_PT;
    pt2=get(gca,'currentpoint');
    pt2=pt2(1,1:2);
    %compute displacements
    if(length(pt2)~=2 || length(pt1)~=2)
        return;
    end
    delx=pt2(1)-pt1(1);
    dely=pt2(2)-pt1(2);
    xbox2=xbox+delx;
    ybox2=ybox+dely;
    %check bounds
    ii=find(xbox2<xlims(1));
    if(~isempty(ii))
        tmp=xbox2(ii)-xlims(1);
        delx=delx-min(tmp);
    end
    ii=find(xbox2>xlims(2));
    if(~isempty(ii))
        tmp=xbox2(ii)-xlims(2);
        delx=delx-max(tmp);
    end
    ii=find(ybox2<ylims(1));
    if(~isempty(ii))
        tmp=ybox2(ii)-ylims(1);
        dely=dely-min(tmp);
    end
    ii=find(ybox2>ylims(2));
    if(~isempty(ii))
        tmp=ybox2(ii)-ylims(2);
        dely=dely-max(tmp);
    end
    
    %contrained motion
    if(strcmp(motion,'free'))
        DRAGBOX_PT=pt2;
        set(hbox,'xdata',xbox+delx,'ydata',ybox+dely);
        pstring=['(' num2str(pt2(1)) ',' num2str(pt2(2)) ')'];
        xshift=delx;yshift=dely;
    elseif(strcmp(motion,'xonly'))
        DRAGBOX_PT=[pt2(1) pt1(2)];
        set(hbox,'xdata',xbox+delx);
        pstring=['(' num2str(pt2(1)) ')'];
        xshift=delx;yshift=0;
    elseif(strcmp(motion,'yonly'))
        DRAGBOX_PT=[pt1(1) pt2(2)];
        set(hbox,'ydata',ybox+dely); 
        pstring=['(' num2str(pt2(2)) ')'];
        xshift=0;yshift=dely;
    end
    if(strcmp(showposn,'on'))
        if(isempty(ptxt))
            ptxt=text(pt2(1),pt2(2),pstring,...
                'backgroundcolor','w');
            DRAGBOX_POSNTXT=ptxt;
        else
            set(ptxt,'position',[pt2 0],'string',pstring);
        end
    end
% 
%     Handle any paired objects
        nlines=length(DRAGBOX_PAIRED);
        for k=1:nlines
            if(isgraphics(DRAGBOX_PAIRED(k)))
                if(DRAGBOX_PAIRED(k)~=hbox)
                    x=get(DRAGBOX_PAIRED(k),'xdata');
                    y=get(DRAGBOX_PAIRED(k),'ydata');
                    set(DRAGBOX_PAIRED(k),'xdata',x+xshift,'ydata',y+yshift);
                end
            end
        end
%    Handle any labels
    hstor=findobj(gcf,'tag','handles1');
    ud=hstor.UserData;
    if(length(ud)>3)
       hlabels=ud{4};
       if(length(hlabels)~=4)
           return;
       end
       for k=1:length(hlabels)
          if(isgraphics(hlabels(k)))
              p=get(hlabels(k),'position');
              p(1)=p(1)+xshift;
              p(2)=p(2)+yshift;
              set(hlabels(k),'position',p)
          end
       end
    end
    if(~isempty(mcb))
        eval(mcb);
    end
    return;
end
if(strcmp(action,'move2'))
    hbox=gco;
    xbox=hbox.XData;
    ybox=hbox.YData;
    motion=DRAGBOX_MOTION2;
    if(isempty(motion))
        motion='free';
    end
    xlims=DRAGBOX_XLIMS2;
    if(isempty(xlims))
        xlims=get(gca,'xlim');
    end
    ylims=DRAGBOX_YLIMS2;
    if(isempty(ylims))
        ylims=get(gca,'ylim');
    end
    showposn=DRAGBOX_SHOWPOSN2;
    if(isempty(showposn))
        showposn='off';
    end
    ptxt=DRAGBOX_POSNTXT2;
    mcb=DRAGBOX_MOTIONCALLBACK2;
    pt1=DRAGBOX_PT2;
    pt2=get(gca,'currentpoint');
    pt2=pt2(1,1:2);
    %compute displacements
    if(length(pt2)~=2 || length(pt1)~=2)
        return;
    end
    delx=pt2(1)-pt1(1);
    dely=pt2(2)-pt1(2);
    xbox2=xbox+delx;
    ybox2=ybox+dely;
    %check bounds
    ii=find(xbox2<xlims(1));
    if(~isempty(ii))
        tmp=xbox2(ii)-xlims(1);
        delx=delx-min(tmp);
    end
    ii=find(xbox2>xlims(2));
    if(~isempty(ii))
        tmp=xbox2(ii)-xlims(2);
        delx=delx-max(tmp);
    end
    ii=find(ybox2<ylims(1));
    if(~isempty(ii))
        tmp=ybox2(ii)-ylims(1);
        dely=dely-min(tmp);
    end
    ii=find(ybox2>ylims(2));
    if(~isempty(ii))
        tmp=ybox2(ii)-ylims(2);
        dely=dely-max(tmp);
    end
    
    %contrained motion
    if(strcmp(motion,'free'))
        DRAGBOX_PT2=pt2;
        set(hbox,'xdata',xbox+delx,'ydata',ybox+dely);
        pstring=['(' num2str(pt2(1)) ',' num2str(pt2(2)) ')'];
        xshift=delx;yshift=dely;
    elseif(strcmp(motion,'xonly'))
        DRAGBOX_PT2=[pt2(1) pt1(2)];
        set(hbox,'xdata',xbox+delx);
        pstring=['(' num2str(pt2(1)) ')'];
        xshift=delx;yshift=0;
    elseif(strcmp(motion,'yonly'))
        DRAGBOX_PT2=[pt1(1) pt2(2)];
        set(hbox,'ydata',ybox+dely); 
        pstring=['(' num2str(pt2(2)) ')'];
        xshift=0;yshift=dely;
    end
    if(strcmp(showposn,'on'))
        if(isempty(ptxt))
            ptxt=text(pt2(1),pt2(2),pstring,...
                'backgroundcolor','w');
            DRAGBOX_POSNTXT2=ptxt;
        else
            set(ptxt,'position',[pt2 0],'string',pstring);
        end
    end
% 
%     Handle any paired objects
        nlines=length(DRAGBOX_PAIRED2);
        for k=1:nlines
            if(isgraphics(DRAGBOX_PAIRED2(k)))
                if(DRAGBOX_PAIRED2(k)~=hbox)
                    x=get(DRAGBOX_PAIRED2(k),'xdata');
                    y=get(DRAGBOX_PAIRED2(k),'ydata');
                    set(DRAGBOX_PAIRED2(k),'xdata',x+xshift,'ydata',y+yshift);
                end
            end
        end
%    Handle any labels
    hstor=findobj(gcf,'tag','handles2');
    ud=hstor.UserData;
    if(length(ud)>3)
       hlabels=ud{4};
       if(length(hlabels)~=4)
           return;
       end
       for k=1:length(hlabels)
          if(isgraphics(hlabels(k)))
              p=get(hlabels(k),'position');
              p(1)=p(1)+xshift;
              p(2)=p(2)+yshift;
              set(hlabels(k),'position',p)
          end
       end
    end
    if(~isempty(mcb))
        eval(mcb);
    end
    return;
end
if(strcmp(action,'expand1'))
    hpt=gco;
    xpt=hpt.XData;
    ypt=hpt.YData;
    motion=DRAGBOX_MOTION;
    if(isempty(motion))
        motion='free';
    end
    xlims=DRAGBOX_XLIMS;
    if(isempty(xlims))
        xlims=get(gca,'xlim');
    end
    ylims=DRAGBOX_YLIMS;
    if(isempty(ylims))
        ylims=get(gca,'ylim');
    end
    showposn=DRAGBOX_SHOWPOSN;
    if(isempty(showposn))
        showposn='off';
    end
    maxwid=DRAGBOX_MAXWID;
    if(isempty(maxwid))
       maxwid=diff(get(gca,'xlim')); 
    end
    minwid=DRAGBOX_MINWID;
    if(isempty(minwid))
       minwid=0; 
    end
    maxht=DRAGBOX_MAXHT;
    if(isempty(maxht))
       maxht=diff(get(gca,'ylim')); 
    end
    minht=DRAGBOX_MINHT;
    if(isempty(minht))
       minht=0; 
    end
    ptxt=DRAGBOX_POSNTXT;
    mcb=DRAGBOX_MOTIONCALLBACK;
    pt1=DRAGBOX_PT;
    pt2=get(gca,'currentpoint');
    pt2=pt2(1,1:2);
    %compute displacements
    if(length(pt2)~=2 || length(pt1)~=2)
        return;
    end
    delx=pt2(1)-pt1(1);
    dely=pt2(2)-pt1(2);
    xpt2=xpt+delx;
    ypt2=ypt+dely;
    %check bounds
    if(xpt2<xlims(1))
        tmp=xpt2-xlims(1);
        delx=delx-tmp;
    end
    if(xpt2>xlims(2))
        tmp=xpt2-xlims(2);
        delx=delx-tmp;
    end
    if(ypt2<ylims(1))
        tmp=ypt2-ylims(1);
        dely=dely-tmp;
    end
    if(ypt2>ylims(2))
        tmp=ypt2-ylims(2);
        dely=dely-tmp;
    end
    
    hstor=findobj(gcf,'tag','handles1');
    ud=hstor.UserData;
    hb=ud{1};
    jx=ud{2};
    jy=ud{3};
    hbox=hb(1);
    hpts=hb(2:5);
    
    tag=hpt.Tag;
    if(strcmp(tag,hpts(1).Tag))
        ixy=[1 5];%ixy are points that move in x&y
        ix=jx(1);%points that move in x
        iy=jy(1);%points that move in y
        ilblx=[1 .5 0 .5];
        ilbly=[.5 0 .5 1];
    elseif(strcmp(tag,hpts(2).Tag))
        ixy=2;
        ix=jx(2);
        iy=jy(2);
        ilblx=[1 .5 0 .5];
        ilbly=[.5 1 .5 0];
    elseif(strcmp(tag,hpts(3).Tag))
        ixy=3;
        ix=jx(3);
        iy=jy(3);
        ilblx=[0 .5 1 .5];
        ilbly=[.5 1 .5 0];
    elseif(strcmp(tag,hpts(4).Tag))
        ixy=4;
        ix=jx(4);
        iy=jy(4);
        ilblx=[0 .5 1 .5];
        ilbly=[.5 0 .5 1];
    end
    if(ix==1)
        ix=[1 5];
    end
    if(iy==1)
        iy=[1 5];
    end
          
    xbox=hbox.XData;
    ybox=hbox.YData;
    
        
    %check width
    testxbox=xbox;
    testxbox([ixy ix])=testxbox([ixy ix])+delx;
    wid=max(testxbox)-min(testxbox);
    if(wid>maxwid)
        if(delx>0)
            delx=delx-(wid-maxwid);
        else
            delx=delx+(wid-maxwid);
        end
    elseif(wid<minwid)
        if(delx>0)
            delx=delx+(wid-minwid);
        else
            delx=delx-(wid-minwid);
        end
    end
    
    %check height
    testybox=ybox;
    testybox([ixy iy])=testybox([ixy iy])+dely;
    ht=max(testybox)-min(testybox);
    if(ht>maxht)
        if(dely>0)
            dely=dely-(ht-maxht);
        else
            dely=dely+(ht-maxht);
        end
    elseif(ht<minht)
        if(dely>0)
            dely=dely+(ht-minht);
        else
            dely=dely-(ht-minht);
        end
    end
    
    %contrained motion
    if(strcmp(motion,'free'))
        DRAGBOX_PT=pt2;
        xbox([ixy ix])=xbox([ixy ix])+delx;
        ybox([ixy iy])=ybox([ixy iy])+dely;
        set(hbox,'xdata',xbox,'ydata',ybox);
        hpts(ixy(1)).XData=hpts(ixy(1)).XData+delx;
        hpts(ix(1)).XData=hpts(ix(1)).XData+delx;
        hpts(ixy(1)).YData=hpts(ixy(1)).YData+dely;
        hpts(iy(1)).YData=hpts(iy(1)).YData+dely;
        pstring=['(' num2str(pt2(1)) ',' num2str(pt2(2)) ')'];
    elseif(strcmp(motion,'xonly'))
        DRAGBOX_PT=[pt2(1) pt1(2)];
        xbox([ixy ix])=xbox([ixy ix])+delx;
        set(hbox,'xdata',xbox);
        hpts(ixy).XData=hpts(ixy).XData+delx;
        hpts(ix).XData=hpts(ix).XData+delx;
        pstring=['(' num2str(pt2(1)) ')'];
    elseif(strcmp(motion,'yonly'))
        DRAGBOX_PT=[pt1(1) pt2(2)];
        ybox([ixy iy])=ybox([ixy iy])+dely;
        set(hbox,'ydata',ybox);
        hpts(ixy).YData=hpts(ixy).YData+dely;
        hpts(iy).YData=hpts(iy).YData+dely;
        pstring=['(' num2str(pt2(2)) ')'];
    end
    if(strcmp(showposn,'on'))
        if(isempty(ptxt))
            ptxt=text(pt2(1),pt2(2),pstring,...
                'backgroundcolor','w');
            DRAGBOX_POSNTXT=ptxt;
        else
            set(ptxt,'position',[pt2 0],'string',pstring);
        end
    end
    
    %    Handle any labels
    hstor=findobj(gcf,'tag','handles1');
    ud=hstor.UserData;
    if(length(ud)>3)
       hlabels=ud{4};
       if(length(hlabels)~=4)
           return;
       end
       for k=1:length(hlabels)
          if(isgraphics(hlabels(k)))
              p=get(hlabels(k),'position');
              p(1)=p(1)+ilblx(k)*delx;
              p(2)=p(2)+ilbly(k)*dely;
              set(hlabels(k),'position',p)
          end
       end
    end

    if(~isempty(mcb))
        eval(mcb);
    end
    return;
end
if(strcmp(action,'expand2'))
    hpt=gco;
    xpt=hpt.XData;
    ypt=hpt.YData;
    motion=DRAGBOX_MOTION2;
    if(isempty(motion))
        motion='free';
    end
    xlims=DRAGBOX_XLIMS2;
    if(isempty(xlims))
        xlims=get(gca,'xlim');
    end
    ylims=DRAGBOX_YLIMS2;
    if(isempty(ylims))
        ylims=get(gca,'ylim');
    end
    showposn=DRAGBOX_SHOWPOSN2;
    if(isempty(showposn))
        showposn='off';
    end
    maxwid=DRAGBOX_MAXWID2;
    if(isempty(maxwid))
       maxwid=diff(get(gca,'xlim')); 
    end
    minwid=DRAGBOX_MINWID2;
    if(isempty(minwid))
       minwid=0; 
    end
    maxht=DRAGBOX_MAXHT2;
    if(isempty(maxht))
       maxht=diff(get(gca,'ylim')); 
    end
    minht=DRAGBOX_MINHT2;
    if(isempty(minht))
       minht=0; 
    end
    ptxt=DRAGBOX_POSNTXT2;
    mcb=DRAGBOX_MOTIONCALLBACK2;
    pt1=DRAGBOX_PT2;
    pt2=get(gca,'currentpoint');
    pt2=pt2(1,1:2);
    %compute displacements
    if(length(pt2)~=2 || length(pt1)~=2)
        return;
    end
    delx=pt2(1)-pt1(1);
    dely=pt2(2)-pt1(2);
    xpt2=xpt+delx;
    ypt2=ypt+dely;
    %check bounds
    if(xpt2<xlims(1))
        tmp=xpt2-xlims(1);
        delx=delx-tmp;
    end
    if(xpt2>xlims(2))
        tmp=xpt2-xlims(2);
        delx=delx-tmp;
    end
    if(ypt2<ylims(1))
        tmp=ypt2-ylims(1);
        dely=dely-tmp;
    end
    if(ypt2>ylims(2))
        tmp=ypt2-ylims(2);
        dely=dely-tmp;
    end
    
    hstor=findobj(gcf,'tag','handles2');
    ud=hstor.UserData;
    hb=ud{1};
    jx=ud{2};
    jy=ud{3};
    hbox=hb(1);
    hpts=hb(2:5);
    
    tag=hpt.Tag;
    if(strcmp(tag,hpts(1).Tag))
        ixy=[1 5];%ixy are points that move in x&y
        ix=jx(1);%points that move in x
        iy=jy(1);%points that move in y
        ilblx=[1 .5 0 .5];
        ilbly=[.5 0 .5 1];
    elseif(strcmp(tag,hpts(2).Tag))
        ixy=2;
        ix=jx(2);
        iy=jy(2);
        ilblx=[1 .5 0 .5];
        ilbly=[.5 1 .5 0];
    elseif(strcmp(tag,hpts(3).Tag))
        ixy=3;
        ix=jx(3);
        iy=jy(3);
        ilblx=[0 .5 1 .5];
        ilbly=[.5 1 .5 0];
    elseif(strcmp(tag,hpts(4).Tag))
        ixy=4;
        ix=jx(4);
        iy=jy(4);
        ilblx=[0 .5 1 .5];
        ilbly=[.5 0 .5 1];
    end
    if(ix==1)
        ix=[1 5];
    end
    if(iy==1)
        iy=[1 5];
    end
          
    xbox=hbox.XData;
    ybox=hbox.YData;
    
        
    %check width
    testxbox=xbox;
    testxbox([ixy ix])=testxbox([ixy ix])+delx;
    wid=max(testxbox)-min(testxbox);
    if(wid>maxwid)
        if(delx>0)
            delx=delx-(wid-maxwid);
        else
            delx=delx+(wid-maxwid);
        end
    elseif(wid<minwid)
        if(delx>0)
            delx=delx+(wid-minwid);
        else
            delx=delx-(wid-minwid);
        end
    end
    
    %check height
    testybox=ybox;
    testybox([ixy iy])=testybox([ixy iy])+dely;
    ht=max(testybox)-min(testybox);
    if(ht>maxht)
        if(dely>0)
            dely=dely-(ht-maxht);
        else
            dely=dely+(ht-maxht);
        end
    elseif(ht<minht)
        if(dely>0)
            dely=dely+(ht-minht);
        else
            dely=dely-(ht-minht);
        end
    end
    
    %contrained motion
    if(strcmp(motion,'free'))
        DRAGBOX_PT2=pt2;
        xbox([ixy ix])=xbox([ixy ix])+delx;
        ybox([ixy iy])=ybox([ixy iy])+dely;
        set(hbox,'xdata',xbox,'ydata',ybox);
        hpts(ixy(1)).XData=hpts(ixy(1)).XData+delx;
        hpts(ix(1)).XData=hpts(ix(1)).XData+delx;
        hpts(ixy(1)).YData=hpts(ixy(1)).YData+dely;
        hpts(iy(1)).YData=hpts(iy(1)).YData+dely;
        pstring=['(' num2str(pt2(1)) ',' num2str(pt2(2)) ')'];
    elseif(strcmp(motion,'xonly'))
        DRAGBOX_PT2=[pt2(1) pt1(2)];
        xbox([ixy ix])=xbox([ixy ix])+delx;
        set(hbox,'xdata',xbox);
        hpts(ixy).XData=hpts(ixy).XData+delx;
        hpts(ix).XData=hpts(ix).XData+delx;
        pstring=['(' num2str(pt2(1)) ')'];
    elseif(strcmp(motion,'yonly'))
        DRAGBOX_PT2=[pt1(1) pt2(2)];
        ybox([ixy iy])=ybox([ixy iy])+dely;
        set(hbox,'ydata',ybox);
        hpts(ixy).YData=hpts(ixy).YData+dely;
        hpts(iy).YData=hpts(iy).YData+dely;
        pstring=['(' num2str(pt2(2)) ')'];
    end
    if(strcmp(showposn,'on'))
        if(isempty(ptxt))
            ptxt=text(pt2(1),pt2(2),pstring,...
                'backgroundcolor','w');
            DRAGBOX_POSNTXT2=ptxt;
        else
            set(ptxt,'position',[pt2 0],'string',pstring);
        end
    end
    
    %    Handle any labels
    hstor=findobj(gcf,'tag','handles2');
    ud=hstor.UserData;
    if(length(ud)>3)
       hlabels=ud{4};
       if(length(hlabels)~=4)
           return;
       end
       for k=1:length(hlabels)
          if(isgraphics(hlabels(k)))
              p=get(hlabels(k),'position');
              p(1)=p(1)+ilblx(k)*delx;
              p(2)=p(2)+ilbly(k)*dely;
              set(hlabels(k),'position',p)
          end
       end
    end

    if(~isempty(mcb))
        eval(mcb);
    end
    return;
end
if(strcmp(action,'fini1'))
    
    set(gcf,'windowbuttondownfcn','');
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','');
    ptxt=DRAGBOX_POSNTXT;
    if(~isempty(ptxt))
        delete(ptxt);
        DRAGBOX_POSNTXT=[];
    end
    cb=DRAGBOX_CALLBACK;
    if(~isempty(cb))
        eval(cb);
    end

    return;
end	
if(strcmp(action,'fini2'))
    
    set(gcf,'windowbuttondownfcn','');
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','');
    ptxt=DRAGBOX_POSNTXT2;
    if(~isempty(ptxt))
        delete(ptxt);
        DRAGBOX_POSNTXT2=[];
    end
    cb=DRAGBOX_CALLBACK2;
    if(~isempty(cb))
        eval(cb);
    end

    return;
end
if(strcmp(action,'setbox'))
    hfig=gcf;
    boxno=arg2;
    xmin=bdf;
    xmax=kol;
    ymin=lw;
    ymax=ls;
    if(boxno==1)
        hstor=findobj(hfig,'tag','handles1');
        ud=hstor.UserData;
        hbox=ud{1};
        hax=hbox.Parent;
        x=[xmin xmin xmax xmax xmin];
        y=[ymin ymax ymax ymin ymin];
        set(hbox(1),'xdata',x,'ydata',y);
        for k=1:4
            set(hbox(k+1),'xdata',x(k),'ydata',y(k));
        end
        hfig.CurrentAxes=hax;
    else
        hstor=findobj(hfig,'tag','handles2');
        ud=hstor.UserData;
        hbox=ud{1};
        hax=hbox.Parent;
        x=[xmin xmin xmax xmax xmin];
        y=[ymin ymax ymax ymin ymin];
        set(hbox(1),'xdata',x,'ydata',y);
        for k=1:4
            set(hbox(k+1),'xdata',x(k),'ydata',y(k));
        end
        hfig.CurrentAxes=hax;
    end
end
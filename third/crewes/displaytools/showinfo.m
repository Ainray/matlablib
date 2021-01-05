function hshow=showinfo(infocell,name,posxy,figdims,innerpanelheight,scrollbarwidth)
%
% hshow=showinfo(infocell,name,posxy,figdims,innerpanelheight,scrollbarwidth)
% 
% infocell ... cell array of text strings. If the cell array contains more cell arrays where the
%       text is inside the second level, then the dialog constructs tabbed panels, one for each
%       interior cell array. Each interior array should consist of {titlestring,infocell} where the
%       title string becomes the tab title and the infocell is a cell array of strings. Thus, in the
%       most general case, infocell looks like
% infocell={{titleTab1,{stringset1}},{titleTab2,{stringset2}},...{titleTabN,{stringsetN}}}
%       whereas in the simplest case, which produces no tabs, it is
%       infocell={stringset}
% Here string set looks like [string1],' ',[string2],' ',[string3],' ' ...
% The notation [string1] indicates a string that may extend over many lines and the [] forms a
% concatenation. The ,' ', between string sets creates a blank line separating paragraphs.
%
% name ... name of the window
% **** default '' ******* (nan also gets the default)
% posxy ... 2 element vector giving x,y position of the desired window center in pixels
% **** default = center of the current figure ***** (nan also gets the default)
% figdims ... 2 element vector giving width and ht of the figure in pixels
% ******* default =[400,400] ******* (nan also gets the default)
% innerpanelheight ... inner panel height as a multiple of the outer panel size. Outer panel will
%       have a height that is .85 times the window height. Can be a vector of values, one per tab.
% ******* default = 4 ********** (nan also gets the default)
% scrollbarwidth ... width of the scrollbar as a fraction of the outer panel width.
% ************ default =.05 ************* (nan also gets the default)
%


if(iscell(infocell))
    action='init';
else
    action=infocell;
    hshow=[];
end

if(strcmp(action,'init'))
    hparent=gcf;
    if(nargin<2)
        name=nan;
    end
    if(isnan(name))
        name='';
    end
    if(nargin<3)
        posxy=nan;
    end
    if(isnan(posxy))
        pos=get(hparent,'position');
        posxy=[pos(1)+.5*pos(3),pos(2)+.5*pos(4)];
    end
    if(nargin<4)
        figdims=nan;
    end
    if(isnan(figdims))
        figdims=[400,400];
    end
    if(nargin<5)
        innerpanelheight=nan;
    end
    if(isnan(innerpanelheight))
        innerpanelheight=4;
    end
    if(nargin<6)
        scrollbarwidth=nan;
    end
    if(isnan(scrollbarwidth))
        scrollbarwidth=.05;
    end
    fs=9;
    figwid=figdims(1);
    fight=figdims(2);
    hshow=figure;
    x0=posxy(1)-.5*figwid;
    y0=posxy(2)-.5*fight;
    set(hshow,'position',[x0,y0,figwid,fight],'menubar','none','toolbar','none','numbertitle','off',...
        'name',name,'closerequestfcn','showinfo(''close'');','userdata',[],'tag','info');
    %determine if we are tabbing or not
    if(ischar(infocell{1}))
        x0=.1;
        y0=.1;
        wid=.8;
        ht=.85;
        hpan=uiscrollpanel(hshow,[x0,y0,wid,ht],innerpanelheight,scrollbarwidth);
        
        uicontrol(hpan(2),'style','text','string',infocell,'units','normalized','position',[0,0,1,1],...
            'tag','info','horizontalalignment','left','fontsize',fs);
        
    else
%         subcells=infocell{1};
        ntabs=length(infocell);
        if(length(innerpanelheight)==1)
            innerpanelheight=innerpanelheight*ones(1,ntabs);
        elseif(length(innerpanelheight)~=ntabs)
            error('innerpanelheight must be either a scalar or has one value per tab');
        end
        x0=.05;
        y0=.1;
        wid=.9;
        ht=.85;
        htg=uitabgroup(hshow,'position',[x0,y0,wid,ht]);
        for k=1:ntabs
            htab=uitab(htg,'title',infocell{k}{1});
            hpan=uiscrollpanel(htab,[x0,y0,wid,ht],innerpanelheight(k),scrollbarwidth);
            uicontrol(hpan(2),'style','text','string',infocell{k}{2},'units','normalized',...
                'position',[0,0,1,1],'horizontalalignment','left','fontsize',fs);
        end
        
    end
    w=.15;h=.075;
    x0=.5-.5*w;
    y0=.05-.5*h;
    uicontrol(hshow,'style','pushbutton','string','Close','units','normalized','position',[x0,y0,w,h],...
        'callback','showinfo(''close'');','tag','closebutton');

    
elseif(strcmp(action,'close'))
    crf=get(gcf,'closerequestfcn');
    if(strcmp(get(gcbo,'tag'),'closebutton'))
        ind=strfind(crf,';');
        if(length(ind)==1)
        	delete(gcf);
        else
            eval(crf(ind(1)+1:end));
        end
    else
        ind=strfind(crf,';');
        if(length(ind)<2)
            delete(gcf);
        end
    end
end
    
end
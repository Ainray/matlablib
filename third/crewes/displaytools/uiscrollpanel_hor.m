function hpan=uiscrollpanel_hor(parent,position,innerpanelwidth,scrollbarheight)
% UISCROLLPANEL_HOR ... create a scrollable panel UI tool. Panel scrolls horizontally.
%
% hpan=uiscrollpanel_hor(parent,position,innerpanelwidth,scrollbarwidth)
% 
% parent ... handle of the parent object
% position ... 4 element vector giving position of the scrollpanel in the parent object. In
%       normalized coordinates.
% innerpanelwidth ... scalar giving the width of the scrolling inner panel as a multiple of the
%       width of the outer panel. Should be greater than 1.
% ************ default =4 ************
% scrollbarheight ... height of the scrollbar as a fraction of the outer panel height
% ************ default =.05 *************
% hpan ... vector of handles. hpan(1) is the handle of the outer panel, hpan(2) is the inner panel,
%       and hpan(3) is the scrollbar.
%
% External call:
% uiscrollpanel_hor('setValue',houterpanel,value) ... set the slider value
%

if(~ischar(parent))
    action='init';
else
    action=parent;
end

if(strcmp(action,'init'))
    
    if(nargin<3)
        innerpanelwidth=4;
    end
    if(nargin<4)
        scrollbarheight=.05;
    end
    sep=scrollbarheight/5;
    hpan1=uipanel(parent,'tag','outer_panel','units','normalized','position',...
        position);
    
    hpan2=uipanel(hpan1,'tag','innerpanel','units','normalized','position',...
        [1-innerpanelwidth,scrollbarheight,innerpanelwidth,1-scrollbarheight-sep]);
    
    hpan3=uicontrol(hpan1,'style','slider','tag','scrollbar','units','normalized','position',...
        [0,0,1,scrollbarheight],'value',1,'Callback',{@scslider,hpan2},'backgroundcolor',.5*ones(1,3));
    
    hpan=[hpan1 hpan2 hpan3];
    
elseif(strcmp(action,'setValue'))
    hpan1=position;
    value=innerpanelwidth;
    hslider=findobj(hpan1,'tag','scrollbar');
    hpan2=findobj(hpan1,'type','uipanel');
    hslider.Value=value;
    scslider(hslider,1,hpan2(1));
    
end
end

function scslider(src,eventdata,arg1) %#ok<INUSL>
hpar=get(arg1,'parent');
U=hpar.Units;
hpar.Units='normalized';
val = get(src,'Value');
u=get(arg1,'units');
set(arg1,'units','normalized');
pos=get(arg1,'position');
% pospar=get(hpar,'position');
% widthdif=pospar(3)-pos(3)*pospar(3);
p1=interp1([0 1],[0 1-pos(3)],val);
set(arg1,'Position',[p1 pos(2:4)])
hpar.Units=U;
set(arg1,'units',u);
end
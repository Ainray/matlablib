function hcbtool=enhancecolormaptool(hfig,pos,hax1,hax2,cb1,cb2,cm1,cm2,iflip1,iflip2,cbflag,cbcb,cbaxe)
%
% hcbtool=enhancecolormaptool(hfig,pos,hax1,hax2,cb1,cb2,cm1,cm2,iflip1,iflip2,cbflag,cbcb)
% 
% Designed to control the colomaps for multiple separate axes. The axes will be in two groups with
% each group getting a different colormap. Individual axes in a group will not have separate
% control.
% 
% hfig ... handle of the figure to install into
% pos ... position (normalized coords) of the cbtool in hfig. This will be the position of the
%           hcbtool panel.
% hax1 ... handle of the axes on the left (can be a vector)
% hax2 ... handle of the axes on the right (can be a vector)
% cb1 ... function handle or string of callback to be run after installing colormap on the left
% cb2 ... function handle or string of callback to be run after installing colormap on the right
% cm1 ... name of iniital colormap (string) for left
% cm2 ... name of initial colormap (string) for right
% iflip1 ... flip flag for cm1
% iflip2 ... flip flag for cm2
% cbflag ... length two vector of flags. 
%           cbflag(1)=0 means no colorbars at startup
%           cbflag(1)=1 means colorbars at startup
%           cbflag(2)=1 means show colorbars but resize the images using colorbar.m
%           cbflag(2)=2 means show colorbars but resize the images using colorbar2.m
% cbcb ... callback for when colorbars are shown or not
% cbaxe ... array of axes for which colorbars are displayed
%
% hcbtool ... handle of the enclosing panel, tag is 'colorpanel'
%
% Tool is installed in a panel. UserData of the color panel is available for external use
%
% Works best when width is about 100-120 pixels and height is 150-180 pixels
%
% EXTERNAL CALLS
% 1) cmapnames=enhancecolormaptool('getcolormaplist'); ... retrieve the list of colormapnames as a cell array
% 2) enhancecolormaptool('setcmap',hax,colormapname,iflip) updates settings (the maps and the flips)
%       alt syntax: enhancecolormaptool('setcmap',hax,colormapnumber,iflip) updates settings
%       alt-alt syntax: enhancecolormaptool('setcmap',hax) applies current settings
%       syntax: enhancecolormaptool('showcolormap',hax) ... toggle the gui to show the colormap of hax
% 3) enhancecolormaptool('colorbarsoff');
% 3b) enhancecolormaptool('colorbarson');
%
if(~ischar(hfig))
    action='init';
else
    action=hfig;
end

if(nargout>0)
    hcbtool=[];%initialize return data to null
end

if(strcmp(action,'init'))
    
    hpan=uipanel(hfig,'position',pos,'tag','colorpanel');
    
    if(fromenhance)
        colormaps=enhance('getcolormaplist');
    else
    colormaps=listcolormaps;
        
    end
    for k=1:length(colormaps)
       if(strcmp(cm1,colormaps{k}))
           icm1=k;
       end
       if(strcmp(cm2,colormaps{k}))%initially the menu points to section 2
           icm2=k;
       end
    end
    if(iflip1)
        cname1=[cm1 '-f(left)'];
    else
        cname1=[cm1 '(left)'];
    end
    if(iflip2)
        cname2=[cm2 '-f(left)'];
    else
        cname2=[cm2 '(left)'];
    end
    ht=.125;
    ynow=1;
    xnow=0;
    wid=1;
    sep=.005; 
    ynow=ynow-2*ht;
    uicontrol(hpan,'style','text','string',{'Colormaps:',cname1,cname2},'tag','colormaplabel',...
        'units','normalized','position',[xnow ynow wid 2*ht],...
        'horizontalalignment','left');
    ynow=ynow-ht;
    uicontrol(hpan,'style','radiobutton','string','Colorbars','tag','colorbars',...
        'units','normalized','position',[xnow ynow wid ht],'value',cbflag(1),...
        'callback','enhancecolormaptool(''colorbars'');');
    
    ynow=ynow-ht;
    %record original cbaxes positions
    cbaxepos=zeros(length(cbaxe),4);
    for k=1:length(cbaxe)
        cbaxepos(k,:)=get(cbaxe(k),'position');
    end
    cmapstuff={hax1,hax2,cb1,cb2,cm1,cm2,icm1,icm2,iflip1,iflip2,cbflag,cbcb,cbaxe,cbaxepos};
    uicontrol(hpan,'style','popupmenu','string',colormaps,'tag','colormap',...
        'units','normalized','position',[xnow ynow wid ht],'callback',...
        'enhancecolormaptool(''colormap'');','value',icm2,'userdata',cmapstuff);
    ynow=ynow-ht-.5*sep;
    uicontrol(hpan,'style','radiobutton','string','Flip colormap','tag','flipcolor',...
        'units','normalized','position',[xnow ynow wid ht],'callback',...
        'enhancecolormaptool(''flipcolor'');','value',iflip2);
    ynow=ynow-3*ht;
    hbg=uibuttongroup(hpan,'position',[xnow,ynow,wid,3*ht],'title','Colormap goes to','tag','cmapgt',...
        'selectionchangedfcn','enhancecolormaptool(''cmapgoto'');');
    uicontrol(hbg,'style','radiobutton','string','AxesLeft','tag','left','units','normalized',...
        'position',[0 2/3 1 1/3],'value',0);
    uicontrol(hbg,'style','radiobutton','string','AxesRight','tag','right','units','normalized',...
        'position',[0 1/3 1 1/3],'value',1);
    uicontrol(hbg,'style','radiobutton','string','both','tag','both','units','normalized',...
        'position',[0 0 1 1/3],'value',0);
    
    enhancecolormaptool('setcolormap',cmapstuff{1});
    enhancecolormaptool('setcolormap',cmapstuff{2});
    if(cbflag(1))
        enhancecolormaptool('colorbars',hfig);
    end
    hcbtool=hpan;
elseif(strcmp(action,'showcolormap'))
% syntax: enhancecolormaptool('showcolormap',hax) ... toggle the gui to show the colormap of hax
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hflip=findobj(hpan,'tag','flipcolor');
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    %cmapstuff={hax1,hax2,cb1,cb2,cm1,cm2,icm1,icm2,iflip1,iflip2,cbflag,cbcb,cbaxe};
    hax=pos;
    if(any(hax==cmapstuff{1}))
        icm=cmapstuff{7};
        iflip=cmapstuff{9};
        hleft=findobj(hpan,'tag','left');
        hcmap.Value=icm;
        hflip.Value=iflip;
        hleft.Value=1;
    elseif(any(hax==cmapstuff{2}))
        icm=cmapstuff{8};
        iflip=cmapstuff{10};
        hright=findobj(hpan,'tag','right');
        hcmap.Value=icm;
        hflip.Value=iflip;
        hright.Value=1;
    end
elseif(strcmp(action,'getcolormaplist'))
    %called externally to get the list of colormap names under use by this tool
    %syntax: cmapnames=enhancecolormaptool('getcolormaplist');
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hcmap=findobj(hpan,'tag','colormap');
    hcbtool=hcmap.String;
elseif(strcmp(action,'setcmap'))
    %called by an external function to set a colormap
    %syntax: enhancecolormaptool('setcmap',hax,colormapname,iflip) updates settings
    %alt syntax: enhancecolormaptool('setcmap',hax,colormapnumber,iflip) updates settings
    %alt-alt syntax: enhancecolormaptool('setcmap',hax) applies current settings
    %assumes: hax.Parent is a figure window and hax is one of the axes assigned to the tool
    %assumes: colormapname is found in the string of the colormap popupmenu. 
    hax=pos;
    if(nargin==4)
        icolor=nan;
        colormapname=nan;
        if(ischar(hax1))
            colormapname=hax1;
        else
            icolor=round(hax1);
        end
        iflip=hax2;
        hfig=hax.Parent;
        hpan=findobj(hfig,'tag','colorpanel');
        hcmap=findobj(hpan,'tag','colormap');
        cmapstuff=hcmap.UserData;
        cmaps=hcmap.String;
        if(isnan(icolor))
            for k=1:length(cmaps)
                if(strcmp(cmaps{k},colormapname))
                    icolor=k;
                end
            end
            if(isnan(icolor))
                error('invalid colormapname');
            end
        else
            if(icolor>=1 && icolor<=length(cmaps))
                colormapname=cmaps{icolor};
            else
                error('invalid colormap number');
            end
        end
        
        %cmapstuff={hax1,hax2,cb1,cb2,cm1,cm2,icm1,icm2,iflip1,iflip2,cbflag,cbcb,cbaxe};
        if(any(hax==cmapstuff{1}))
            cmapstuff{5}=colormapname;
            cmapstuff{7}=icolor;
            cmapstuff{9}=iflip;
        elseif(any(hax==cmapstuff{2}))
            cmapstuff{6}=colormapname;
            cmapstuff{8}=icolor;
            cmapstuff{10}=iflip;
        else
            error('invalid axes in colormap assignment');
        end
        set(hcmap,'userdata',cmapstuff);
    end
    enhancecolormaptool('setcolormap',hax);
elseif(strcmp(action,'flipcolor'))
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hflip=findobj(hpan,'tag','flipcolor');
    iflip=get(hflip,'value');
    hcmpgt=findobj(hpan,'tag','cmapgt');
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    cmaps=hcmap.String;
    hcmaplbl=findobj(hpan,'tag','colormaplabel');
    lbl=hcmaplbl.String;
    switch hcmpgt.SelectedObject.Tag
        case 'left'
            cmapname=cmaps{cmapstuff{7}};
            cmapstuff{9}=iflip;
            hcmap.UserData=cmapstuff;
            hax=cmapstuff{1};
            enhancecolormaptool('setcolormap',hax);
            if(iflip)
                lbl{2}=[cmapname '-f(left)'];
            else
                lbl{2}=[cmapname '(left)'];
            end
        case 'right'
            cmapname=cmaps{cmapstuff{8}};
            cmapstuff{10}=iflip;  
            hcmap.UserData=cmapstuff;
            hax=cmapstuff{2};
            enhancecolormaptool('setcolormap',hax);
            if(iflip)
                lbl{3}=[cmapname '-f(left)'];
            else
                lbl{3}=[cmapname '(left)'];
            end
        case 'both'
            cmapnameL=cmaps{cmapstuff{7}};
            cmapnameR=cmaps{cmapstuff{8}};
            cmapstuff{9}=iflip;
            cmapstuff{10}=iflip;
            hcmap.UserData=cmapstuff;
            enhancecolormaptool('setcolormap',cmapstuff{1});
            enhancecolormaptool('setcolormap',cmapstuff{2});
            if(iflip)
                lbl{2}=[cmapnameL '-f(left)'];
                lbl{3}=[cmapnameR '-f(right)'];
            else
                lbl{2}=[cmapnameL '(left)'];
                lbl{3}=[cmapnameR '(right)'];
            end
    end
    hcmaplbl.String=lbl;
elseif(strcmp(action,'colorbarsoff'))
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hbars=findobj(hpan,'tag','colorbars');
    ibars=get(hbars,'value');
    if(ibars==0)
        return;
    end
    hbars.Value=0;
    enhancecolormaptool('colorbars');
elseif(strcmp(action,'colorbars'))
    if(nargin<2)
        hfig=gcf;
    else
        hfig=pos;
    end
    hpan=findobj(hfig,'tag','colorpanel');
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    cbflag=cmapstuff{11};
    cbcb=cmapstuff{12};
    hbars=findobj(hpan,'tag','colorbars');
    ibars=get(hbars,'value');
%     cmapstuff{11}=ibars;
%     hseis1=cmapstuff{1};
%     hseis2=cmapstuff{2};
    cbaxe=cmapstuff{13};
    cbaxepos=cmapstuff{14};
    if(ibars)
        if(cbflag(2)==1)
            for k=1:length(cbaxe)
                hc=colorbar(cbaxe(k));
                drawnow;
                checkcolorbar(cbaxe(k),hc,cbaxepos(k,:));
            end
        else
            for k=1:length(cbaxe)
                colorbar2(cbaxe(k));
            end
        end
    else
        if(cbflag(2)==1)
            for k=1:length(cbaxe)
                colorbar(cbaxe(k),'off');
                set(cbaxe(k),'position',cbaxepos(k,:));
            end
        else
            for k=1:length(cbaxe)
                colorbar2(cbaxe(k),'off');
            end
        end
    end
    if(ischar(cbcb))
        eval(cbcb);
    else
        cbcb; %#ok<VUNUS>
    end
elseif(strcmp(action,'colorbarsoff'))
    if(nargin<2)
        hfig=gcf;
    else
        hfig=pos;
    end
    hpan=findobj(hfig,'tag','colorpanel');
    hbars=findobj(hpan,'tag','colorbars');
    hbars.Value=0;
    enhancecolormaptool('colorbars');
elseif(strcmp(action,'cmapgoto'))
    % this is called by the radio buttons that say where the colormap is going to. All it does is
    % change the popup menu and the flip button to show the correct colormap.
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hbg=gcbo;%the buttongroup
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    hflip=findobj(hpan,'tag','flipcolor');
    hb=hbg.SelectedObject;
    if(strcmp(hb.String,'AxesLeft'))
        hcmap.Value=cmapstuff{7};
        if(cmapstuff{9})
            hflip.Value=1;
        else
            hflip.Value=0;
        end
    elseif(strcmp(hb.String,'AxesRight'))
        hcmap.Value=cmapstuff{8};
        if(cmapstuff{10})
            hflip.Value=1;
        else
            hflip.Value=0;
        end
    end
elseif(strcmp(action,'colormap'))
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    cmaps=get(hcmap,'string');
    icmap=get(hcmap,'value');
    if(exist(cmaps{icmap},'file'))
        cmap=eval(cmaps{icmap});
    else
        cmap=enhance('getcolormap',cmaps{icmap}); 
    end
    hflip=findobj(hpan,'tag','flipcolor');
    iflip=hflip.Value;
    if(iflip)
        cm=flipud(cmap);
    else
        cm=cmap;
    end
    hseis1=cmapstuff{1};
    hseis2=cmapstuff{2};
    hleft=findobj(hpan,'tag','left');
    ileft=get(hleft,'value');
    hright=findobj(hpan,'tag','right');
    iright=get(hright,'value');
    hboth=findobj(hpan,'tag','both');
    iboth=get(hboth,'value');
    hbars=findobj(hpan,'tag','colorbars');
    ibars=get(hbars,'value');
    hcmaplabel=findobj(hpan,'tag','colormaplabel');
    lbl=hcmaplabel.String;
    %update choices
    if(ileft || iboth)
        for k=1:length(hseis1)
            colormap(hseis1(k),cm);
        end
        cmapstuff{5}=cmaps{icmap};
        cmapstuff{7}=icmap;
        cmapstuff{9}=iflip;
        if(iflip)
            lbl{2}=[cmaps{icmap} '-f(right)'];
        else
            lbl{2}=[cmaps{icmap} '(right)'];
        end
    end
    if(iright || iboth)
        for k=1:length(hseis2)
            colormap(hseis2(k),cm);
        end
        cmapstuff{6}=cmaps{icmap};
        cmapstuff{8}=icmap;
        cmapstuff{10}=iflip;
        if(iflip)
            lbl{3}=[cmaps{icmap} '-f(left)'];
        else
            lbl{3}=[cmaps{icmap} '(left)'];
        end
    end
    hcmap.UserData=cmapstuff;
    hcmaplabel.String=lbl;
    if(ibars)
        enhancecolormaptool('colorbars');
    end

elseif(strcmp(action,'setcolormap'))
    %this is called when a section choice is made or at init
    %the assigned colormap is determined by userdata of hcmap
    hax=pos;%second argument
    hfig=hax.Parent;
    hpan=findobj(hfig,'tag','colorpanel');
    hcmap=findobj(hpan,'tag','colormap');
    cmaps=hcmap.String;
    cmapstuff=hcmap.UserData;
    hcmaplabel=findobj(hpan,'tag','colormaplabel');
    lbl=hcmaplabel.String;
    hax=pos;%second argument
%     hax=findobj(hpan,'tag',axetag);
    if(any(hax==cmapstuff{1}))
        if(exist(cmapstuff{5},'file'))
            cmap=eval(cmapstuff{5});
        else
            cmap=enhance('getcolormap',cmapstuff{5});
        end
        hcmap.Value=cmapstuff{7};
        iflip=cmapstuff{9};
        if(iflip)
            cm=flipud(cmap);
            lbl{2}=[cmaps{cmapstuff{7}} '-f(left)'];
        else
            cm=cmap;
            lbl{2}=[cmaps{cmapstuff{7}} '(left)'];
        end
    else
        if(exist(cmapstuff{6},'file'))
            cmap=eval(cmapstuff{6});
        else
            cmap=enhance('getcolormap',cmapstuff{6});
        end
        hcmap.Value=cmapstuff{8};
        iflip=cmapstuff{10};
        if(iflip)
            cm=flipud(cmap);
            lbl{3}=[cmaps{cmapstuff{8}} '-f(right)'];
        else
            cm=cmap;
            lbl{3}=[cmaps{cmapstuff{8}} '(right)'];
        end
    end
    hflip=findobj(hpan,'tag','flipcolor');
    hflip.Value=iflip;
    for k=1:length(hax)
        colormap(hax(k),cm);
    end
    hcmaplabel.String=lbl;
end

end

function checkcolorbar(hax,hc,pos)
pos2=hax.Position;
poscb=hc.Position;
if(pos2(3)==pos(3))
   %correction needed
   fact=2.5;
   pos2(3)=pos(3)-fact*poscb(3);%new axes width
   poscb(1)=poscb(1)-1.25*fact*poscb(3);%newcb location
   hax.Position=pos2;
   hc.Position=poscb;
end
end
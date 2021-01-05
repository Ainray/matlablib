function hcbtool=colormaptool(hfig,pos,haxe,cback,cmap,iflip,cbflag,cbcb,cbaxe)
%
% hcbtool=colormaptool(hfig,pos,haxe,cback,cmap,iflip,cbflag,cbcb)
% 
% Designed to control the colormap for a single axes. A group of axes can be controlled if they all
% get the same colormap.
%
% hfig ... handle of the figure to install into
% pos ... position (normalized coords) of the cbtool in hfig. This will be the position of the
%           hcbtool panel.
% haxe ... handle of the axes on the left (can be a vector)
% cback ... function handle or string of callback to be run after installing colormap on the left
% cmap ... name of iniital colormap (string) for left
% iflip ... flip flag for cmap
% cbflag ... length two vector of flags. 
%           cbflag(1)=0 means no colorbars at startup
%           cbflag(1)=1 means colorbars at startup
%           cbflag(2)=1 means show colorbars but resize the images using colorbar.m
%           cbflag(2)=2 means show colorbars but resize the images using colorbar2.m
% cbcb ... callback for when colorbars are shown or not
% cbaxe ... array of axes for which colorbars are displayed
% ********** default = haxe ****************
%
% hcbtool ... handle of the enclosing panel, tag is 'colorpanel'
%
% Tool is installed in a panel. UserData of the color panel is available for external use
%
% Works best when width is about 100-120 pixels and height is 70-100 pixels
%
% EXTERNAL CALLS
% cmapnames=colormaptool('getcolormaplist'); ... retieve the list of colormapnames as a cell array
% syntax: colormaptool('setcmap',colormapname,iflip) updates settings
% alt syntax: colormaptool('setcmap',colormapnumber,iflip) updates settings
% alt-alt syntax: colormaptool('setcmap') applies current settings

if(~ischar(hfig))
    action='init';
else
    action=hfig;
end

if(nargout>0)
    hcbtool=[];%initialize return data to null
end

if(strcmp(action,'init'))
    
    if(nargin<9)
        cbaxe=haxe;
    end
    
    hpan=uipanel(hfig,'position',pos,'tag','colorpanel');
    
    if(fromenhance)
        colormaps=enhance('getcolormaplist');
    else

    colormaps=listcolormaps;
        
    end
    for k=1:length(colormaps)
       if(strcmp(cmap,colormaps{k}))
           icmap=k;
       end
    end
    
    ht=.2;
    ynow=1;
    xnow=0;
    wid=1;
    sep=.005; 
    ynow=ynow-ht;
    uicontrol(hpan,'style','text','string','Colormaps:','tag','colormaplabel',...
        'units','normalized','position',[xnow ynow wid ht],...
        'horizontalalignment','left');
    ynow=ynow-ht;
    cmapstuff={haxe,cback,cmap,icmap,iflip,cbflag,cbcb,cbaxe};
    uicontrol(hpan,'style','popupmenu','string',colormaps,'tag','colormap',...
        'units','normalized','position',[xnow ynow wid ht],'callback',...
        'colormaptool(''colormap'');','value',icmap,'userdata',cmapstuff);
    ynow=ynow-1.5*ht-.5*sep;
    uicontrol(hpan,'style','radiobutton','string','Flip colormap','tag','flipcolor',...
        'units','normalized','position',[xnow ynow wid ht],'callback',...
        'colormaptool(''flipcolor'');','value',iflip); 
    ynow=ynow-ht;
    uicontrol(hpan,'style','radiobutton','string','Colorbars','tag','colorbars',...
        'units','normalized','position',[xnow ynow wid ht],'value',cbflag(1),...
        'callback','colormaptool(''colorbars'');');
    
    colormaptool('setcolormap',cmapstuff{1});
    if(cbflag(1))
        colormaptool('colorbars',hfig);
    end
    hcbtool=hpan;

elseif(strcmp(action,'getcolormaplist'))
    %called externally to get the list of colormap names under use by this tool
    %syntax: cmapnames=colormaptool('getcolormaplist');
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hcmap=findobj(hpan,'tag','colormap');
    hcbtool=hcmap.String;
elseif(strcmp(action,'setcmap'))
    %called by an external function to set a colormap
    %syntax: colormaptool('setcmap',colormapname,iflip) updates settings
    %alt syntax: colormaptool('setcmap',colormapnumber,iflip) updates settings
    %alt-alt syntax: colormaptool('setcmap') applies current settings
    %assumes: colormapname is found in the string of the colormap popupmenu.
    hfig=gcf;
    hcmap=findobj(hfig,'tag','colormap');
    cmapstuff=hcmap.UserData;
    if(nargin==3)
        icolor=nan;
        colormapname=nan;
        if(ischar(pos))
            colormapname=pos;
        else
            icolor=round(pos);
        end
        iflip=haxe;
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
        
        %cmapstuff={haxe,cback,cmap,icmap,iflip,cbflag,cbcb,cbaxe};
        cmapstuff{3}=colormapname;
        cmapstuff{4}=icolor;
        cmapstuff{5}=iflip;
        
        set(hcmap,'userdata',cmapstuff);
    end
    colormaptool('setcolormap');
elseif(strcmp(action,'flipcolor'))
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hflip=findobj(hpan,'tag','flipcolor');
    iflip=get(hflip,'value');
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    cmapstuff{5}=iflip;
    hcmap.UserData=cmapstuff;
    colormaptool('setcolormap');
        
elseif(strcmp(action,'colorbars'))
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    cbflag=cmapstuff{6};
    cbcb=cmapstuff{7};
    hbars=findobj(hpan,'tag','colorbars');
    ibars=get(hbars,'value');
    cbaxe=cmapstuff{8};
    if(ibars)
        if(cbflag(2)==1)
            for k=1:length(cbaxe)
                colorbar(cbaxe(k));
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
    haxe=cmapstuff{1};
    hbars=findobj(hpan,'tag','colorbars');
    ibars=get(hbars,'value');
    %update choices
    
    for k=1:length(haxe)
        colormap(haxe(k),cm);
    end
    cmapstuff{3}=cmaps{icmap};
    cmapstuff{4}=icmap;
    cmapstuff{5}=iflip;
    
    hcmap.UserData=cmapstuff;
    if(ibars)
        colormaptool('colorbars');
    end

elseif(strcmp(action,'setcolormap'))
    %this is called when a section choice is made or at init
    %the assigned colormap is determined by userdata of hcmap
    hfig=gcf;
    hpan=findobj(hfig,'tag','colorpanel');
    hcmap=findobj(hpan,'tag','colormap');
    cmapstuff=hcmap.UserData;
    haxe=cmapstuff{1};
    %     hax=findobj(hpan,'tag',axetag);
    if(exist(cmapstuff{3},'file'))
        cmap=eval(cmapstuff{3});
    else
        cmap=enhance('getcolormap',cmapstuff{5});
    end
    hcmap.Value=cmapstuff{4};
    iflip=cmapstuff{5};
    if(iflip)
        cm=flipud(cmap);
    else
        cm=cmap;
    end
    hflip=findobj(hpan,'tag','flipcolor');
    hflip.Value=iflip;
    for k=1:length(haxe)
        colormap(haxe(k),cm);
    end

end
function comparetool(~,~)
global NEWFIGVIS COMPARE COMPAREDATA1 COMPAREDATA2
%
% COMPARE ultimately must have 4 values: [hax1,hax2,spaceflag1,spaceflag2]
%
% spaceflag ... 0 means input is in (x,t) space, 1 means (x,z) space, 2 means (x,y) space, 3 means
%       (y,t) space, 4 means (y,z) space, 5 means (x,f) or (y,f) space, 6 means (k,f) space, 
% dataflag ... 0 means normal seismic, 1 means amp spectra, -1 means phase spectra, 2 means frequencies (fdom), 
% the userdata of an image is then set to [spaceflag dataflag]
hmasterfig=gcf;
if(isempty(COMPARE))
    COMPARE=nan*zeros(1,6);%entries are {hax1,hax2,spaceflag1,spaceflag2,dataflag1,dataflag2}
    COMPARE(1)=gca;
    hi=findobj(COMPARE(1),'type','image');
    if(isempty(hi.UserData))
        spaceflag=0;
        dataflag=0;
    elseif(length(hi.UserData)==1)
        spaceflag=hi.UserData;
        dataflag=0;
    else
        spaceflag=hi.UserData(1);
        dataflag=hi.UserData(2);
    end
    COMPARE(3)=spaceflag;
    COMPARE(5)=dataflag;
    %get the first data
    t1=get(hi,'ydata');
    x1=get(hi,'xdata');
    seis1=get(hi,'cdata');
    ht=get(COMPARE(1),'title');
    dname1=ht.String;
    if(isempty(dname1))
        par=get(COMPARE(1),'parent');
        hresults=findobj(par,'tag','results');
        if(~isempty(hresults))
            iresult=hresults.Value;
            names=hresults.String;
            dname1=names{iresult};
        end
    end
    xlbl=get(COMPARE(1),'xlabel');
    xname1=xlbl.String;
    ylbl=get(COMPARE(1),'ylabel');
    yname1=ylbl.String;
    xdir1=get(COMPARE(1),'XDir');
    ydir1=get(COMPARE(1),'YDir');
    COMPAREDATA1={seis1,t1,x1,dname1,xname1,yname1,xdir1,ydir1};
    hm=msgbox(['One dataset selected. Now go the another display and select "compare" again ',...
        'and the comparison tool will launch']);
    WinOnTop(hm,true);
    return;
end
if(isnan(COMPARE(2)))
    COMPARE(2)=gca;
    hi=findobj(COMPARE(2),'type','image');
    if(isempty(hi.UserData))
        spaceflag=0;
        dataflag=0;
    elseif(length(hi.UserData)==1)
        spaceflag=hi.UserData;
        dataflag=0;
    else
        spaceflag=hi.UserData(1);
        dataflag=hi.UserData(2);
    end
    COMPARE(4)=spaceflag;
    COMPARE(6)=dataflag;
    %get the second data
    t2=get(hi,'ydata');
    x2=get(hi,'xdata');
    seis2=get(hi,'cdata');
    ht=get(COMPARE(2),'title');
    dname2=ht.String;
    if(isempty(dname2))
        par=get(COMPARE(2),'parent');
        hresults=findobj(par,'tag','results');
        if(~isempty(hresults))
            iresult=hresults.Value;
            names=hresults.String;
            dname2=names{iresult};
        end
    end
    xlbl=get(COMPARE(2),'xlabel');
    xname2=xlbl.String;
    ylbl=get(COMPARE(2),'ylabel');
    yname2=ylbl.String;
    xdir2=get(COMPARE(2),'XDir');
    ydir2=get(COMPARE(2),'YDir');
    COMPAREDATA2={seis2,t2,x2,dname2,xname2,yname2,xdir2,ydir2};
elseif(isnan(COMPARE(1)))
    COMPARE(1)=gca;
    hi=findobj(COMPARE(1),'type','image');
    if(isempty(hi.UserData))
        spaceflag=0;
        dataflag=0;
    elseif(length(hi.UserData)==1)
        spaceflag=hi.UserData;
        dataflag=0;
    else
        spaceflag=hi.UserData(1);
        dataflag=hi.UserData(2);
    end
    COMPARE(3)=spaceflag;
    COMPARE(5)=dataflag;
    %get the first data
    t1=get(hi,'ydata');
    x1=get(hi,'xdata');
    seis1=get(hi,'cdata');
    ht=get(COMPARE(1),'title');
    dname1=ht.String;
    if(isempty(dname1))
        par=get(COMPARE(1),'parent');
        hresults=findobj(par,'tag','results');
        if(~isempty(hresults))
            iresult=hresults.Value;
            names=hresults.String;
            dname1=names{iresult};
        end
    end
    xlbl=get(COMPARE(1),'xlabel');
    xname1=xlbl.String;
    ylbl=get(COMPARE(1),'ylabel');
    yname1=ylbl.String;
    xdir1=get(COMPARE(1),'XDir');
    ydir1=get(COMPARE(1),'YDir');
    COMPAREDATA1={seis1,t1,x1,dname1,xname1,yname1,xdir1,ydir1};
end
hax1=COMPARE(1);
hax2=COMPARE(2);
flags1=[COMPARE(3),COMPARE(5)];
flags2=[COMPARE(4),COMPARE(6)];
if(~isgraphics(hax1))
    COMPARE(1)=nan;
    return;
end
if(~isgraphics(hax2))
    COMPARE(2)=nan;
    return;
end
%so hax1 and hax2 are both live axes and we are comparing the data in them

%get the data
t1=COMPAREDATA1{2};
x1=COMPAREDATA1{3};
seis1=COMPAREDATA1{1};
dname1=COMPAREDATA1{4};
xname1=COMPAREDATA1{5};
yname1=COMPAREDATA1{6};
xdir1=COMPAREDATA1{7};
ydir1=COMPAREDATA1{8};
COMPAREDATA1={};
t2=COMPAREDATA2{2};
x2=COMPAREDATA2{3};
seis2=COMPAREDATA2{1};
dname2=COMPAREDATA2{4};
xname2=COMPAREDATA2{5};
yname2=COMPAREDATA2{6};
xdir2=COMPAREDATA2{7};
ydir2=COMPAREDATA2{8};
COMPAREDATA2={};


xlbl1=get(hax1,'xlabel');
if(isempty(xname1))
    if(~isempty(xlbl1))
        xname1=xlbl1.String;
    end
end
ylbl1=get(hax1,'ylabel');
if(isempty(yname1))
    if(~isempty(ylbl1))
        yname1=ylbl1.String;
    end
end
xlbl2=get(hax2,'xlabel');
if(isempty(xname2))
    if(~isempty(xlbl2))
        xname2=xlbl2.String;
    end
end
ylbl2=get(hax2,'ylabel');
if(isempty(yname2))
    if(~isempty(ylbl2))
        yname2=ylbl2.String;
    end
end

% cmap=get(hmasterfig,'colormap');

% pos=get(hmasterfig,'position');
NEWFIGVIS='off';  %#ok<NASGU>
%flags1 has [spaceflag dataflag] and similar for flags2
datar=seisplotcompare(seis1,t1,x1,dname1,flags1,seis2,t2,x2,dname2,flags2);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
hppt=uicontrol(hfig,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
            'position',[.95,.95,.025,.025],'backgroundcolor','y','callback','enhance(''makepptslide'');');
set(hppt,'userdata',get(hfig,'name'));
% colormap(cmap);
xlabel(datar{1},xname1);ylabel(datar{1},yname1);
xlabel(datar{2},xname2);ylabel(datar{2},yname2);

set(datar{1},'xdir',xdir1,'ydir',ydir1);
set(datar{2},'xdir',xdir2,'ydir',ydir2);

set(hfig,'visible','on');
xlabel(datar{1},getxname(get(hax1,'Parent')));
xlabel(datar{2},getxname(hmasterfig));
%Make entry in windows list and set closerequestfcn
winname=get(hfig,'name');

%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig,winname)
name=get(hmasterfig,'name');
if(contains(name,'PI2D'))
    set(hfig,'closerequestfcn',[get(hfig,'closerequestfcn') 'PI2D(''closewindow'');']);
elseif(contains(name,'PI3D'))
    set(hfig,'closerequestfcn',[get(hfig,'closerequestfcn') 'PI3D(''closewindow'');']);
end
if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
COMPARE=[];

end

function xn=getxname(hfig)
if(nargin<1)
    hfig=gcf;
end
hax=hfig.CurrentAxes;
xn=hax.XLabel.String;
if(isempty(xn))
    hmenu=findobj(hfig,'tag','xax');
    if(~isempty(hmenu))
        ix=hmenu.Value;
        names=hmenu.String;
        xn=names{ix};
    end
end
end
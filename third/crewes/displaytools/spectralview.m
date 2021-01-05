function spectralview(seis1,seis2,t,name1,name2,hspecwin,CRcallback,Winname)
%
% seis1 ... first seismic matrix
% seis2 ... second seismic matrix
% t ... time coordinate for both seismics
% name1 ... name for seis1
% name2 ... name for seis2
% hspecwin ... handle of already existing spectral window (will be updated)
% hmaster ... handle of master figure which calls this
% CRcallback ... close request callback
% Winname ... name of the spectral window
%

global SPECWINdbmin SPECWINtmin SPECWINtmax SPECWINfmax SPECWINlw SPECWINfw

if(ischar(seis1))
    hspecwin=gcf;
    hstor=findobj(hspecwin,'tag','store');
    ud=hstor.UserData;
    seis1=ud{1};
    seis2=ud{2};
    t=ud{3};
    name1=ud{4};
    name2=ud{5};
    namemaster=ud{6};
else
    if(nargin<8)
        Winname=[];
    end
    if(isempty(Winname))
        Winname='Spectral display window';
    end
    
    hfig=gcf;
    
    name=get(hfig,'name');
    ind=strfind(name,'Spectral display');
    if(isempty(ind)) %#ok<STREMP>
        hmaster=hfig;
    else
        hmaster=get(hfig,'userdata');
    end
    namemaster=get(hmaster,'name');
    makewin=false;
    if(isempty(hspecwin))
        makewin=true;
    end
    if(~isgraphics(hspecwin))
        makewin=true;
    end
    if(makewin)
        pos=get(hmaster,'position');
        wid=pos(3)*.5;ht=pos(4)*.5;
        x0=pos(1)+pos(3)-wid;y0=pos(2);
        hspecwin=figure('position',[x0,y0,wid,ht],'closerequestfcn',CRcallback,'userdata',hmaster,'name',Winname);
        set(hspecwin,'menubar','none','toolbar','figure','numbertitle','off')
        customizetoolbar(hspecwin);
        x0=.1;y0=.1;awid=.7;aht=.8;
        axes('position',[x0,y0,awid,aht]);
        ntimes=10;
        tinc=round(10*t(end)/ntimes)/10;
        times=[fliplr(0:-tinc:t(1)) tinc:tinc:t(end)-tinc];
        %times=t(1):tinc:t(end)-tinc;
        stimes=num2strcell(times);
        sep=.02;
        ht=.05;wid=.075;
        ynow=y0+aht-ht;
        xnow=x0+awid+sep;
        x1=xnow;
        hstor=uicontrol(hspecwin,'style','text','string','tmin:','units','normalized',...
            'position',[xnow,ynow,wid,ht],'tag','store','tooltipstring',...
            'Start of the spectral time window');
        %         ynow=ynow-ht-sep;
        xnow=xnow+wid;
        if(isempty(SPECWINtmin))
            val=1;
        else
            val=near(times,SPECWINtmin);
        end
        uicontrol(hspecwin,'style','popupmenu','string',stimes,'units','normalized','tag','tmin',...
            'position',[xnow,ynow+.25*ht,wid,ht],'callback','spectralview(''recomp'');',...
            'value',val,'userdata',times);
        ynow=ynow-ht-sep;
        xnow=x1;
        uicontrol(hspecwin,'style','text','string','tmax:','units','normalized',...
            'position',[xnow,ynow,wid,ht],'tooltipstring',...
            'End of the spectral time window')
        times=t(end):-tinc:tinc;
        stimes=num2strcell(times);
        %         ynow=ynow-ht-sep;
        xnow=xnow+wid;
        if(isempty(SPECWINtmax))
            val=1;
        else
            val=near(times,SPECWINtmax);
        end
        uicontrol(hspecwin,'style','popupmenu','string',stimes,'units','normalized','tag','tmax',...
            'position',[xnow,ynow+.25*ht,wid,ht],'callback','spectralview(''recomp'');',...
            'value',val,'userdata',times);
        ynow=ynow-ht-sep;
        xnow=x1;
        uicontrol(hspecwin,'style','text','string','db minimum:','units','normalized',...
            'position',[xnow,ynow,wid,ht],'tooltipstring',...
            'Smallest decibel level to display')
        db=-20:-20:-160;
        dbs=num2strcell(db);
        %         ynow=ynow-ht-sep;
        xnow=xnow+wid;
        if(isempty(SPECWINdbmin))
            idb=near(db,-100);
        else
            idb=near(db,SPECWINdbmin);
        end
        uicontrol(hspecwin,'style','popupmenu','string',dbs,'units','normalized','tag','db','value',idb,...
            'position',[xnow,ynow+.25*ht,wid,ht],'callback','spectralview(''recomp'');','userdata',db);
        ynow=ynow-ht-sep;
        xnow=x1;
        uicontrol(hspecwin,'style','text','string','db ref:','units','normalized',...
            'position',[xnow,ynow,wid,ht],'tooltipstring',...
            'Independent means each curve referes to its own maximum, relative means both are relative to the max amp')
        xnow=xnow+wid;
        uicontrol(hspecwin,'style','popupmenu','string',{'independent','relative'},'units','normalized','tag','dbref','value',1,...
            'position',[xnow,ynow+.25*ht,wid,ht],'callback','spectralview(''recomp'');');
        ynow=ynow-ht-sep;
        xnow=x1;
        uicontrol(hspecwin,'style','text','string','fmax:','units','normalized',...
            'position',[xnow,ynow,wid,ht],'tooltipstring',...
            'Maximum frequency to display')
        fnyq=.5/(t(2)-t(1));
        fmax=fnyq*[1 .75 .5 .4 .3 .25];
        fmaxs=num2strcell(fmax);
        xnow=xnow+wid;
        if(isempty(SPECWINfmax))
            ifm=1;
        else
            ifm=near(fmax,SPECWINfmax);
        end
        uicontrol(hspecwin,'style','popupmenu','string',fmaxs,'units','normalized','tag','fmax','value',ifm,...
            'position',[xnow,ynow+.25*ht,wid,ht],'callback','spectralview(''recomp'');','userdata',fmax);
        
        
        hstor.UserData={seis1,seis2,t,name1,name2,namemaster};
        
        ynow=ynow-ht-sep;
        xnow=x1;
        uicontrol(hspecwin,'style','text','string','line width:','units','normalized',...
            'position',[xnow,ynow,wid,ht])
        xnow=xnow+wid;
        if(isempty(SPECWINlw))
            lw=1;
        else
            lw=SPECWINlw;
        end
        lws=[1,1.5,2,2.5,3];
        lwss=num2strcell(lws);
        ilw=near(lws,lw);
        uicontrol(hspecwin,'style','popupmenu','string',lwss,'units','normalized','tag','lw','value',ilw,...
            'position',[xnow,ynow+.25*ht,wid,ht],'callback',@lw);
        
        if(isempty(SPECWINfw))
            fw=1;
        else
            fw=SPECWINfw;
        end
        ynow=ynow-ht-sep;
        xnow=x1;
        uicontrol(hspecwin,'style','text','string','font:','units','normalized',...
            'position',[xnow,ynow,wid,ht])
        xnow=xnow+wid;
        uicontrol(hspecwin,'style','popupmenu','string',{'normal','bold'},'units','normalized','tag','fw','value',fw,...
            'position',[xnow,ynow+.25*ht,wid,ht],'callback',@font);
        
        hppt=uicontrol(hspecwin,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
            'position',[.95,.95,.05,.05],'backgroundcolor','y','callback','enhance(''makepptslide'');');
        set(hppt,'userdata',['Spectra for ' namemaster]);
    else
        figure(hspecwin);
    end
end
htmin=findobj(hspecwin,'tag','tmin');
times=get(htmin,'userdata');
it=get(htmin,'value');
tmin=times(it);
SPECWINtmin=tmin;
htmax=findobj(hspecwin,'tag','tmax');
times=get(htmax,'userdata');
it=get(htmax,'value');
tmax=times(it);
SPECWINtmax=tmax;
if(tmax<=tmin)
    return;
end
ind=near(t,tmin,tmax);
hdb=findobj(hspecwin,'tag','db');
db=get(hdb,'userdata');
dbmin=db(get(hdb,'value'));
SPECWINdbmin=dbmin;
hfm=findobj(hspecwin,'tag','fmax');
ifm=hfm.Value;
fmaxs=hfm.UserData;
fmax=fmaxs(ifm);
SPECWINfmax=fmax;
hdbref=findobj(hspecwin,'tag','dbref');
dbflag=hdbref.Value;
pct=10;
if(length(ind)<10)
    return;
end
[S1,f]=fftrl(seis1(ind,:),t(ind),pct);
S2=fftrl(seis2(ind,:),t(ind),pct);
A1=mean(abs(S1),2);
A2=mean(abs(S2),2);
switch dbflag
    case 1
        A1max=max(A1);
        A2max=max(A2);
    case 2
        tmp1=max(A1);
        tmp2=max(A2);
        Am=max([tmp1 tmp2]);
        A1max=Am;
        A2max=Am;
end
hh=plot(f,todb(A1,A1max),f,todb(A2,A2max));
hlw=findobj(hspecwin,'tag','lw');
ilw=hlw.Value;
lws=hlw.String;
lw=str2double(lws{ilw});
set(hh,'linewidth',lw);
xlim([0 fmax]);
xlabel('Frequency (Hz)')
ylabel('decibels');
ylim([dbmin 0])
hfw=findobj(hspecwin,'tag','fw');
ifw=hfw.Value;
fws=hfw.String;
fw=fws{ifw};
set(gca,'fontweight',fw);
grid on
legend(name1,name2);
enTitle({namemaster,['Average ampltude spectra, tmin=' time2str(tmin) ', tmax=' time2str(tmax)]});

end

function lw(hlw,~)
global SPECWINlw
lws=hlw.String;
ilw=hlw.Value;
lw=str2double(lws{ilw});
hlines=findobj(gca,'type','line');
set(hlines,'linewidth',lw)
SPECWINlw=lw;
end

function font(hf,~)
global SPECWINfw
fws=hf.String;
ifw=hf.Value;
fw=fws{ifw};
set(gca,'fontweight',fw)
SPECWINfw=ifw;
end
function waveex(action,vars)
%
% Main data structure:
% wavestruc.s ... the seismic trace
% NOTUSED wavestruc.sp ... the modelled trace: conv(w,r), same length as r
% wavestruc.r ... the reflectivity, this will be an array to accomodate shifting. The original r is
%       always column 1 with shifted/stretched versions in later columns.
% wavestruc.str ... array the same size as r giving the stretch functions for each shifted r. The 
%       first column is always zeros.
% NOTUSED wavestruc.rp ... the estimated reflectivity conv(w^-1,s), same length as s
% wavestruc.t ... time coordinate for sw
% wavestruc.tr ... time coordinate for r
% wavestruc.I ... impedance in depth
% wavestruc.z ... depth coordinates for impedance
% wavestruc.tz ... time coordinates for impedance. This is th original
% wavestruc.tvphase ... save size as r. time-variant phase between r and s
% wavestruc.tvdelay ... save size as r. time-variant delay between r and s
% wavestruc.name ... name of this experiment (string)
% wavestruc.defparams ... default parameters as cell array of name-value pairs
% wavestruc.results ... cell array of results structures
% wavestruc.iresult ... number of current result
% wavestruc.ireflec ... number of the current reflectivity
% wavestruc.fmin ... default min frequency (for filter)
% wavestruc.fmax ... default max frequency (for filter)
% wavestruc.haxes ... axes handles: htraces,htracesf,hwavelets,hampspec,hphspec,htvphase,htvdelay,htvpep,htvcc
%
% wavestruc is stored in UserData of the wavelet control panel
% hcntl=findobj(gcf,'tag','control')
%
% Results structure. These are accumulated in the wavestruc structure.
% result.w ... estimated wavelet
% result.tw ... time coordinate for w
% result.tw1 ... start of estimation time zone
% result.tw2 ... end of estimation time zone
% result.tvphaseSR ... estimated time variant phase between trace and reflectivity
% result.tvdelaySR ... estimated time variant delay between trace and reflectivity
% result.tvphaseSS ... estimated time variant phase between trace and model trace
% result.tvdelaySS ... estimated time variant delay between trace and model trace
% result.tvphaseRR ... estimated time variant phase between reflectivity and reflectivity est
% result.tvdelayRR ... estimated time variant delay between reflectivity and reflectivity est
% result.tvpep ... estimated time variant pep (proportion of energy predicted)
% result.tvprr ... estimated time variant prr (proportion of reflectivity resolved)
% result.tvccSS ... time variant CC between real and synthetic traces
% result.tvccRR ... time variant CC between real and estimated reflectivity
% result.params ... cell array of name-value pairs with extraction parameters
% result.tinc ... time increment used in time-variant estimations
% result.twin ... window size used in time-variant estimations
% result.fmin ... min frequency (for filter)
% result.fmax ... max frequency (for filter)
% result.name ... unique name for the result (used in legend)
% result.sp ... model trace: reflectivity convolved with wavelet
% result.rp ... reflectivity estimate: trace convolved with wavelet inverse (filter applied)
% result.r ... original reflectivity. We save this for each result because it might be shifted
% result.rf ... filtered true reflectivity
% result.icausal ... 1 for causal, 0 for noncausal
% result.ccs ... output from maxcorr for s versus sp
% result.pep ... pep fofr s versus sp
% result.ccr ... output from maxcorr for rf versus rp (r filtered)
% result.prr ... portion of reflectivity resolved for rf versus rp
% result.wavelabel ... text string summarizing the above four measures
% result.phase ... best constant phase of the wavelet
%
% Actions:
% 'build' ... create the basic GUI
% 'legendtoggle' ... toggle legends on and off
% 'septoggle' ... toggle between separate and overlay plotting
% 'dragline' ... drag change of wavelet gate
% 'waveletgatechangeline' ... called after 'dragline'
% 'waveletgatechangetext' ... wavelet gate change from textbox
% 'traceplot' ... plot the traces in time domain
% 'tvphsdelay' ... measure tv phase and delay, also tv CC, tv PEP, tv PRR, _AND_ plot all
% 'waveletplot' ... plot the latest wavelet in time and frequency
% 'deletewavelet' ... delete a wavelet
% 'selectwavelet' ... select a wavelet
% 'receivenewref' ... get a new reflectivity from align_ref, also applies current wavelet method to it
% 'help' ... show the Help PDF
% 'close' ... shut down the APP including align_ref if open
%
% Functions:
% getcurrentresult ... retrieve the latest result from the wavestruc
% setcurrentresult ... put a changed result in the wavestruc
% setnewresult ... put a new result in the wavestruc
% getwavestruc ... get the wavestruc
% setwaevstruc ... put a changed wavestruc back in storage
% getwaveletgate ... get the current wavelet estimation gate
% setwaveletgate ... update the window for a changed wavelet gate
% gettvparms ... get twin and tinc 
% alignment ... either launch the align_ref window or retireve it if already open
% padtrace ... not used
% setparms ... called when a result is selected by clicking on a wavelet
% getaxis ... get one of the axes by name
% 
% 

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED
global ALIGN_REF_RNEW ALIGN_REF_STR
global TGATE1 TGATE2

if(strcmp(action,'build'))
    %on this call, vars should be a structure with fields: s,r,str,t,tr,name,w,tw
    hfig=figure;
    set(hfig,'menubar','none','toolbar','figure','closerequestfcn','waveex(''close'');')
%     whitefig;

    
    figsize(.9,.7);
    
    x0=.1;y0=.1;
    htwave=.3;%height of wavelet axes
    httr=.45;%height of traces axes;
    wwave=.4;%width of wavelet axes
    wspec=.4;%width of wavelet spectra axes
    wtr=.375;%width of traces axes
    wstatsax=.375;%width of stats axes
    hstatsax=.45;%height of stats axes
%     wtvphs=.1;%width of tv phase axes
%     wtvdel=.1;
%     wtvpep=.1;
    wcntl=.1;
    sep=.15;%big separation
    smsep=.01;%small separation
    
    %info button
    xnow=.02;ynow=.93;
    width=.2;
    xnow=xnow+1.1*width;
    ynow=ynow+.02;
    width=.05;fs=12;ht=.03;
    hinfo=uicontrol(hfig,'style','pushbutton','string','Info?','tag','info','units','normalized',...
        'position',[xnow,ynow,width,ht],'callback','waveex(''help'')',...
        'backgroundcolor',.95*[1 1 0],'fontsize',fs);
    %determine path to help file
    helpfile='Waveex_Help.pdf';
    if(isdeployed)
        [status,result]=system('path'); %#ok<ASGLU>
        s = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));%truncate
        %check "for_testing"
        ichk=strfind(s,'for_testing');
        ind=strfind(s,'\');
        if(~isempty(ichk)) %#ok<STREMP>
            helppath=[s(1:ind(end)) 'for_redistribution_files_only\'];
        else
            helppath=[s '\'];
        end
    else
        thispath=which('waveex');
        ind=strfind(thispath,'\');
        helppath=thispath(1:ind(end));
    end
    hinfo.UserData=[helppath helpfile];
    
    %name object
    xnow=xnow+2*width;
%     ynow=ynow-.02;
    width=.4;fs=12;ht=.03;
    uicontrol(hfig,'style','text','string',vars.name,'tag','name','units','normalized',...
        'position',[xnow,ynow,width,ht],...
        'backgroundcolor',.95*[1 1 0],'fontsize',fs,'fontweight','bold',...
        'horizontalalignment','center','backgroundcolor',[1 1 1]);
    
    %trace axes
    fs=12;
    fs2=12;
    xnow=x0;
    ynow=y0+htwave+.5*sep;
    htg=uitabgroup(hfig,'position',[xnow,ynow,wtr,httr]);
    htrtime=uitab(htg,'title','Time domain','tag','trtimetab');
    htraces=axes(htrtime,'position',[.05 .1 .9 .8],'tag','trtime','fontsize',fs);
    htrfreq=uitab(htg,'title','Frequency domain','tag','trfreqtab');
    htracesf=axes(htrfreq,'position',[.1 .1 .85 .8],'tag','trfreq','fontsize',fs);
%     title('traces (right-click for alignment tool)');
    title('Traces')
    %alignment tool button
    cht=.05;
    widbut=.15*wtr;
    uicontrol(hfig,'style','pushbutton','string','Alignment tool','units','normalized',...
       'position',[x0-1.1*widbut,ynow+.3*httr,widbut,.5*cht],'callback',@alignment,...
       'backgroundcolor',.95*[1 1 0],'tag','aligntool','userdata',[]);%user data is the tool window handle
   
    %legend toggle button
    uicontrol(hfig,'style','pushbutton','string','Legends off','units','normalized',...
       'position',[x0-1.1*widbut,ynow+.3*httr-.6*cht,widbut,.5*cht],'callback','waveex(''legendtoggle'')',...
       'backgroundcolor',.95*[1 1 0],'tag','legendtoggle','userdata',1);%1 for on 0 for off
   
    %separation toggle button
    uicontrol(hfig,'style','pushbutton','string','Overplot','units','normalized',...
       'position',[x0-1.1*widbut,ynow+.3*httr-1.2*cht,widbut,.5*cht],'callback','waveex(''septoggle'')',...
       'backgroundcolor',.95*[1 1 0],'tag','septoggle','userdata',1);%1 for separate 0 for overplot
   
    %wavelet axes
    xnow=x0;ynow=y0;
    hwavelets=axes('position',[xnow,ynow,wwave,htwave],'tag','wavelets','fontsize',fs);
    title('wavelets');
    %text annotation
    msg='Right click on a wavelet to select or delete it';
    uicontrol(hfig,'style','text','string',msg,'units','normalized','tag','waveletmsg',...
        'position',[.5*x0,ynow+.5*htwave,.05,.5*htwave],'fontsize',12);
    %spectra axes
    xnow=xnow+.5*sep+wwave;
    htgs=uitabgroup('position',[xnow-.5*widbut,ynow-.5*cht,wspec+.5*widbut,htwave+cht]);
    htabamp=uitab(htgs,'title','Amplitude spectra');
    hampspec=axes(htabamp,'position',[.1 .1 .8 .8],'tag','spectra','fontsize',fs);
    htabphs=uitab(htgs,'title','Phase spectra');
    hphspec=axes(htabphs,'position',[.1 .1 .8 .8],'tag','phspectra','fontsize',fs);
%     titlein('wavelet amplitude spectra');
    %new tab group
    ynow=y0+htwave+.5*sep;
    xnow=x0+wtr+smsep;
    htg2=uitabgroup('position',[xnow,ynow,wstatsax,hstatsax]);
    htabpd=uitab(htg2,'title','Phase and Shift');
    htvphase=axes(htabpd,'position',[.1,.125,.85,.4],'tag','tvphase','fontsize',fs2);
    htvdelay=axes(htabpd,'position',[.1,.55,.85,.4],'tag','tvdelay','fontsize',fs2);
    htabpepcc=uitab(htg2,'title','PEP and CC');
    htvpep=axes(htabpepcc,'position',[.1,.125,.85,.4],'tag','tvpep','fontsize',fs2);
    htvcc=axes(htabpepcc,'position',[.1,.55,.85,.4],'tag','tvcc','fontsize',fs2);
    
    %build the control panel
    xnow=xnow+smsep+wstatsax;
    ynow=ynow-2*smsep;
    factor=.9;
    hcntl=uipanel(hfig,'title','Wavelet control panel','position',[xnow,ynow,wcntl,factor*httr+smsep],...
        'tag','control','backgroundcolor',[1 1 1]);
    
    %build the tvcontrolpanel
    ynow=ynow+factor*httr+2*smsep;
    htvcntl=uipanel(hfig,'title','Time-variant analysis controls','position',[xnow,ynow,wcntl,.25*httr],...
        'tag','tvcontrol','backgroundcolor',[1 1 1]);
    ht=1/3;
    sep=.5*ht;
    wlbl=.6;
    wtxt=.3;
    wsep=.05;
    xxnow=wsep;
    yynow=1-ht-sep;
    fs=11;
    uicontrol(htvcntl,'style','text','string','Time window size:','units','normalized',...
        'position',[xxnow,yynow,wlbl,ht],...
        'tooltipstring','Half width of Gaussian window (sec)','backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xxnow=xxnow+wlbl+wsep;
    %ynow=ynow+.25*ht;
    uicontrol(htvcntl,'style','edit','string',num2str(.3),'tag','twin',...
        'units','normalized','position',[xxnow,yynow,wtxt,ht],...
        'tooltipstring','Longer windows mean lower resolution but greater reliability',...
        'backgroundcolor',[1 1 1],'fontsize',fs);
    
    xxnow=wsep;
    yynow=yynow-ht-sep;
    uicontrol(htvcntl,'style','text','string','Window increment:','units','normalized',...
        'position',[xxnow,yynow,wlbl,ht],...
        'tooltipstring','Time separation between adjacent windows (sec)','backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xxnow=xxnow+wlbl+wsep;
    %ynow=ynow+.25*ht;
    uicontrol(htvcntl,'style','edit','string',num2str(.1),'tag','tinc',...
        'units','normalized','position',[xxnow,yynow,wtxt,ht],...
        'tooltipstring','This should be smaller than the window size','backgroundcolor',[1 1 1],...
        'fontsize',fs);
    
    %bigfont;
    
    
    %build the wavestruc and store in control panel
    wavestruc.s=vars.s;
%     wavestruc.sp=zeros(size(vars.r));
    %wavestruc.sp=vars.s;
    wavestruc.r=vars.r;
    wavestruc.str=vars.str;
    wavestruc.ireflec=1;
%     wavestruc.rp=zeros(size(vars.s));
    wavestruc.t=vars.t;
    wavestruc.tr=vars.tr;
    wavestruc.I=vars.I;
    wavestruc.z=vars.z;
    wavestruc.tz=vars.tz;
    wavestruc.iresult=0;
    wavestruc.results=[];
    wavestruc.twin=.3;%make sure this is consistent with the value seeded in the GUI
    wavestruc.tinc=.05;%make sure this is consistent with the value seeded in the GUI
    if(isfield(vars,'name'))
        wavestruc.name=vars.name;
    else
        wavestruc.name=[];
    end
    if(isfield(vars,'w'))
        wavestruc.w=vars.w;
    else
        wavestruc.w=nan;
    end
    if(isfield(vars,'tw'))
        wavestruc.tw=vars.tw;
    else
        wavestruc.tw=nan;
    end
    wavestruc.haxes=[htraces,htracesf,hwavelets,hampspec,hphspec,htvphase,htvdelay,htvpep,htvcc];
    
    set(hcntl,'userdata',wavestruc);
    
elseif(strcmp(action,'legendtoggle'))
    haxe=findobj(gcf,'type','axes');
    hbutton=gco;
    val=get(hbutton,'userdata');
    %set(gcf,'currentaxes',haxe);
    for k=1:length(haxe)
        if(val==0)
            %turn legend on
            legend(haxe(k),'show');
            set(hbutton,'string','Legends off','userdata',1);
        else
            %turn legend off
            legend(haxe(k),'hide')
            set(hbutton,'string','Legends on','userdata',0);
        end
    end
elseif(strcmp(action,'septoggle'))
    hbutton=gco;
    val=get(hbutton,'userdata');
    
    if(val==0)
        set(hbutton,'string','Overplot','userdata',1);
    else
        set(hbutton,'string','Separate','userdata',0);
    end
    waveex('traceplot')
    disableDA(gcf);
elseif(strcmp(action,'dragline'))
    hline=gco;
    wavestruc=getwavestruc;
    tr=wavestruc.tr;
    lineid=get(hline,'tag');
    [tw1,tw2]=getwaveletgate;
    factor=.1;
    if(strcmp(lineid,'tw1'))
        del=(tw2-tw1)*factor;
        xlims=[tr(1) tw2-del];
        hlineother=findobj(gca,'tag','tw2');
    elseif(strcmp(lineid,'tw2'))
        del=(tw2-tw1)*factor;
        xlims=[tw1+del tr(end)];
        hlineother=findobj(gca,'tag','tw1');
    else
        return;
    end
    DRAGLINE_MOTION='xonly';
    DRAGLINE_XLIMS=xlims;
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='waveex(''waveletgatechangeline'')';
    DRAGLINE_MOTIONCALLBACK='';
    DRAGLINE_PAIRED=hlineother;
    dragline('click');
elseif(strcmp(action,'waveletgatechangeline'))
    %called when the lines are moved
    hline1=gco;
    id1=get(hline1,'tag');
    hcntl=findobj(gcf,'tag','control');
    hbox1=findobj(hcntl,'tag',id1);
    if(strcmp(id1,'tw1'))
        id2='tw2';
    else
        id2='tw1';
    end
    hline2=findobj(gca,'tag',id2);
    hbox2=findobj(hcntl,'tag',id2);
    
    x1=get(hline1,'xdata');
    set(hbox1,'string',num2str(x1(1),4));
    x2=get(hline2,'xdata');
    set(hbox2,'string',num2str(x2(1),4));
    if(strcmp(id1,'tw1'))
        TGATE1=x1(1);
        TGATE2=x2(1);
    else
        TGATE2=x1(1);
        TGATE1=x2(1);
    end
    
    
elseif(strcmp(action,'waveletgatechangetext'))
    %called when the text box entry is changed
    [tw1,tw2]=getwaveletgate;%gets the values of the lines
    hbox=gco;%this box was changed
    id=get(hbox,'tag');%will be 'tw1' or 'tw2'
    val=get(hbox,'string');
    y=str2double(val);
    wavestruc=getwavestruc;
    tr=wavestruc.tr;
    if(~isnumeric(y)||isnan(y))
        msgbox(['bad value in ' id])
        return;
    end
    del=tw2-tw1;
    factor=.1;
    htraces=findobj(gcf,'tag','trtime');
    hline=findobj(htraces,'tag',id);
    switch id
        case 'tw1'
            %tw1 cannot be less than tr(1) or greater than tw2
            if(y<tr(1))
                y=tr(1);
            end
            if(y>=tw2)
                y=tw2-factor*del;
            end
            set(hline,'xdata',[y y]);
            TGATE1=y;
        case 'tw2'
            %tw2 cannot be greater than tr(end) or less than tw1
            if(y>tr(end))
                y=tr(end);
            end
            if(y<=tw1)
                y=tw1+factor*del;
            end
            set(hline,'xdata',[y y]);
            TGATE2=y;
    end

    set(hbox,'string',num2str(y,4));
         
elseif(strcmp(action,'traceplot'))
    hcntl=findobj(gcf,'tag','control');
    wavestruc=get(hcntl,'userdata');
    s=wavestruc.s;
%     r=wavestruc.r(:,wavestruc.ireflec);
    result=getcurrentresult;
    r=result.r;
    sp=result.sp;
    rp=result.rp;
    t=wavestruc.t;
    tr=wavestruc.tr;
    %name=wavestruc.name;
    htraxe=getaxis('traces');
    set(gcf,'currentaxes',htraxe);
    hsep=findobj(gcf,'tag','septoggle');
    separate=hsep.UserData;
    [tw1,tw2]=getwaveletgate;
    ind=near(t,tw1,tw2);
    co=get(gca,'colororder');
    co(3,:)=zeros(1,3);
    colororder(co);
    if(separate)
       as=max(abs(s(ind)));
       ar=max(abs(r(ind)));
       as2=max(abs(sp(ind)));
       ar2=max(abs(rp(ind)));
       plot(t,s/as,t,sp/as2+1,tr,r/ar+2,tr,rp/ar2+3);
       set(gca,'ytick',[],'fontsize',12)
       ylim([-1 4])
    else
       as=max(abs(s(ind)));
       ar=max(abs(r(ind)));
       as2=max(abs(sp(ind)));
       ar2=max(abs(rp(ind)));
       hh=plot(t,s/as,t,sp/as2,tr,r/ar+1,tr,rp/ar2+1);
       set(hh(3),'color',.5*zeros(1,3),'linewidth',2);
       set(gca,'ytick',[],'fontsize',12)
       ylim([-1 2])
    end
    grid
    xlabel('time (sec)','position',[.5*(t(end)-t(1)) -1,1],'verticalalignment','bottom')
    title('traces')
    set(htraxe,'tag','trtime');
    
    %draw wavelet gate
    
    yl=ylim;
    hl=line([tw1 tw1],yl,[1 1],'linestyle',':','color','g','buttondownfcn',...
        'waveex(''dragline'')','tag','tw1','linewidth',2);
    set(hl,'zdata',[10 10]);
    hl=line([tw2 tw2],yl,[1 1],'linestyle',':','color','g','buttondownfcn',...
        'waveex(''dragline'')','tag','tw2','linewidth',2);
    set(hl,'zdata',[10 10]);
    legend('S1=trace','S2=model trace','R1=reflectivity','R2=estimated r','start CC window','end CC window',...
        'location','northwest');
    %frequency display
    htraxef=getaxis('tracesf');
    set(gcf,'currentaxes',htraxef);
    ind=near(t,tr(1),tr(end));
    colororder(co);
    dbspec(tr,[s(ind)/as sp/as r/ar rp(ind)/ar]);
    title('spectra')
    xl=xlim;
    yl=ylim;
    xlabel('frequency (Hz)','position',[.5*diff(xl) yl(1),1],'verticalalignment','bottom')
    legend('S1=trace','S2=model trace','R1=reflectivity','R2=reflectivity est','location','southwest');
    set(htraxef,'tag','trfreq','fontsize',12);
    %determine legend status
    hlegendbutton=findobj(gcf,'tag','legendtoggle');
    val=get(hlegendbutton,'userdata');
    if(val==0)
        legend(htraxe,'hide');
        legend(htraxef,'hide');
    end
    
   
elseif(strcmp(action,'tvphsdelay'))
    %measure time-variant phase and delay
    wavestruc=getwavestruc;
    s=wavestruc.s;
    r=wavestruc.r(:,wavestruc.ireflec);
    thisresult=getcurrentresult;
    sp=thisresult.sp;%current trace model
    rp=thisresult.rp;%current inverted reflectivity
    t=wavestruc.t;
    tr=wavestruc.tr;
    %measure on current result
    if(~isempty(thisresult))
        twinr=thisresult.twin;
        tincr=thisresult.tinc;
        [twin,tinc]=gettvparms;
        %measure time-variant phase and delay
        doit=1;
        if(isfield(thisresult,'tvdelaySR'))
            doit=0;
            if(isempty(thisresult.tvdelaySR))
                doit=1;
            end
        else
            thisresult.tvdelaySR=[];
            thisresult.tvphaseSR=[];
            thisresult.tvdelaySS=[];
            thisresult.tvphaseSS=[];
            thisresult.tvdelayRR=[];
            thisresult.tvphaseRR=[];
        end
        %compute over nonzero r
%         [tg1,tg2]=getwaveletgate;
        tg1=thisresult.tw1;
        tg2=thisresult.tw2;
        ind=near(t,tg1,tg2);
        if((doit)||(twin~=twinr)||(tinc~=tincr)||isempty(thisresult.tvdelaySR))
            %recompute if twin or tinc have changed
            mw=mwindow(length(ind));
            [thisresult.tvdelayRR,thisresult.tvphaseRR]=tvdelayphs(r(ind).*mw,t(ind),rp(ind).*mw,twin,tinc);
            [thisresult.tvdelaySS,thisresult.tvphaseSS]=tvdelayphs(s(ind).*mw,t(ind),sp(ind).*mw,twin,tinc);
            [thisresult.tvdelaySR,thisresult.tvphaseSR]=tvdelayphs(s(ind).*mw,t(ind),r(ind).*mw,twin,tinc);
        end
        %measure pep
        %measure time-variant pep and prr
        doit=1;
        if(isfield(thisresult,'tvpep'))
            doit=0;
        end
        if((doit)||(twin~=twinr)||(tinc~=tincr)||isempty(thisresult.tvpep))
            %recompute if twin or tinc have changed
            thisresult.tvpep=tvpep(s(ind),sp(ind),tr(ind),twin,tinc);
            rf=butterband(r,tr,thisresult.fmin,thisresult.fmax,4,0);
            thisresult.tvprr=tvprr(rf(ind),rp(ind),tr(ind),twin,tinc);
        end
        
        %measure time variant CC
        if((doit)||(twin~=twinr)||(tinc~=tincr)||isempty(thisresult.tvccSS))
            %recompute if twin or tinc have changed
            tmp=tvmaxcorr(s(ind),sp(ind),tr(ind),twin,tinc);
            thisresult.tvccSS=tmp(:,1);
            rf=butterband(r,tr,thisresult.fmin,thisresult.fmax,4,0);
            tmp=tvmaxcorr(rf(ind),rp(ind),tr(ind),twin,tinc);
            thisresult.tvccRR=tmp(:,1);
        end
        
        thisresult.twin=twin;
        thisresult.tinc=tinc;
        setcurrentresult(thisresult);
    end
    
    
    %plot the stuff
    htvphs=getaxis('tvphase');
    htvdelay=getaxis('tvdelay');
    htvpep=getaxis('tvpep');
    htvcc=getaxis('tvcc');
    set(gcf,'currentaxes',htvphs);
    co=get(gca,'colororder');
    co(3,:)=zeros(1,3);
    colororder(co);
    if(~isempty(thisresult))
        plot(t(ind),thisresult.tvphaseSR,t(ind),thisresult.tvphaseSS,t(ind),thisresult.tvphaseRR);
        legend('S1-R1','S1-S2','R1-R2');
        xlim([t(1) t(end)])
    end
    grid
    ylim([-180 180])
    set(htvphs,'tag','tvphase','fontsize',12)
    titlein('phase')
    xl=xlim;
    yl=ylim;
    xlabel('time (sec)','position',[.5*diff(xl) yl(1) 1],'verticalalignment','bottom')
    ylabel('degrees')
    
    set(gcf,'currentaxes',htvdelay);
    colororder(co);
    if(~isempty(thisresult))
        factor=1000;
        plot(t(ind),factor*thisresult.tvdelaySR,t(ind),factor*thisresult.tvdelaySS,t(ind),factor*thisresult.tvdelayRR);
        legend('S1-R1','S1-S2','R1-R2');
        xlim([t(1) t(end)])
    end
    grid
    set(htvdelay,'tag','tvdelay','xticklabel',[],'fontsize',12)
    yl=xlim;
    yl=max(abs(yl));
    if(yl<50);yl=50;end
    ylim([-yl yl])
    ytick([-yl/2 0 yl/2])
    titlein('time shift')
    ylabel('time (msec)')
    
    set(gcf,'currentaxes',htvpep);
    colororder(co);
    if(~isempty(thisresult))
       noplot=false;
       if(length(thisresult.tvpep)==length(tr(ind)))
            plot(tr(ind),thisresult.tvpep,tr(ind),thisresult.tvprr);
       elseif(length(thisresult.tvpep)==length(t(ind)))
            plot(t(ind),thisresult.tvpep,t(ind),thisresult.tvprr);
       else
            noplot=true;
       end
       xlim([t(1) t(end)])
       if(~noplot)
        legend('pep','prr');
        grid
        xlim([t(1) t(end)])
        set(htvpep,'tag','tvpep','fontsize',12)
%         ylim([0 1.1])
        titlein('PEP & PRR')
        xl=xlim;
        yl=ylim;
        if(yl(1)<0)
            ylim([1.1*yl(1) 1.1]);
        else
            ylim([0 1.1])
        end
        xlabel('time (sec)','position',[.5*diff(xl) yl(1) 1],'verticalalignment','bottom')
       end
    end
    
    set(gcf,'currentaxes',htvcc);
    colororder(co);
    if(~isempty(thisresult))
       noplot=false;
       if(length(thisresult.tvccSS)==length(tr(ind)))
            plot(tr(ind),thisresult.tvccSS,tr(ind),thisresult.tvccRR);
       elseif(length(thisresult.tvccSS)==length(t(ind)))
            plot(t,thisresult.tvccSS,t(ind),thisresult.tvccRR);
       else
            noplot=true;
       end
       xlim([t(1) t(end)])
       if(~noplot)
        legend('ccss','ccrr');
        grid
        xlim([t(1) t(end)])
        set(htvcc,'tag','tvcc','fontsize',12,'xticklabel',[])
        yl=ylim;
        if(yl(1)<0)
            ylim([-1.1 1.1]);
        else
            ylim([0 1.1])
        end
        titlein('CCss & CCrr')
        
        xl=xlim;
        yl=ylim;
        xlabel('time (sec)','position',[.5*diff(xl) yl(1) 1],'verticalalignment','bottom')
       end
    end
    
%     disableDA(gcf);
elseif(strcmp(action,'waveletplot'))
    hfig=gcf;
    wavestruc=getwavestruc;
    iresult=wavestruc.iresult;
    nresults=length(wavestruc.results);
    hwaveaxe=getaxis('wavelets');
    hspecaxe=getaxis('ampspec');
    hspecaxephs=getaxis('phspec');
    if(nresults==0)
        haxe=get(hfig,'currentaxes');
        set(hfig,'currentaxes',hwaveaxe);
        cla;
        set(hwaveaxe,'tag','wavelets');
        set(hfig,'currentaxes',hspecaxe);
        cla
        set(hspecaxe,'tag','spectra');
        set(hfig,'currentaxes',haxe);
        return;
    end
    wavelets=cell(1,nresults);
    tws=wavelets;
    names=wavelets;
    windowflags=ones(1,nresults+1);%used in dbspec
    labels=cell(1,nresults);
    normwin=[-inf,inf];
    for k=1:nresults
        wavelets{k}=wavestruc.results{k}.w;
        tws{k}=wavestruc.results{k}.tw;
        t1=min(tws{k});
        normwin(1)=max([normwin(1) t1]);
        t2=max(tws{k});
        normwin(2)=min([normwin(2) t2]);
        names{k}=wavestruc.results{k}.name;
        windowflags(k)=wavestruc.results{k}.icausal+1;
        labels{k}=wavestruc.results{k}.wavelabel;
    end
    set(hfig,'currentaxes',hwaveaxe);
    co=get(gca,'colororder');
    co(3,:)=zeros(1,3);
    colororder(co);
    hh=trplot(tws,wavelets,'order','d','zerolines','y','names',labels,...
        'namesalign','left','nameslocation','middle','nameshift',-.3,'fontsize',12,...
        'normalize',1,'normwindow',normwin);
    lw=get(hh{iresult},'linewidth');
    if(iscell(lw))
        set(hh{iresult},'linewidth',3*lw{1});
    else
        set(hh{iresult},'linewidth',3*lw);
    end
    hh2=zeros(size(hh));
    for k=1:length(hh2)
        hh2(k)=hh{k}(1);
    end
    legend(hh2,names,'interpreter','none','location','northwest')
    set(hwaveaxe,'tag','wavelets','fontsize',12);
    title('wavelets (thick line is selected wavelet)')
    %set context menu's and tags on each wavelet
    for k=1:length(hh)
       hc=uicontextmenu;
       set(hh{k},'uicontextmenu',hc,'tag',int2str(k));
       uimenu(hc,'label','select','callback','waveex(''selectwavelet'')');
       uimenu(hc,'label','delete','callback','waveex(''deletewavelet'')');
    end
    
    set(hfig,'currentaxes',hspecaxe);
    s=wavestruc.s;
    t=wavestruc.t;
    [tw1,tw2]=getwaveletgate;
    ind=near(t,tw1,tw2);
    colororder(co);
    hh=dbspec(tws{1},[wavelets s(ind)],'windowflags',windowflags,'normoption',1);
    title('decibels are relative each wavelets maximum','fontweight','normal');
    yl=ylim;
    xl=xlim;
    xlabel('Frequency (Hz)','position',[.5*diff(xl) yl(1) 1],'verticalalignment','bottom')
    legend([names {'Trace (in gate)'}],'interpreter','none','location','southwest')
    %hh=dbspec(tws{1},[wavelets s(ind)],'windowflags',ones(1,nresults+1));
    ylim([-100 0])
    lw=get(hh{iresult},'linewidth');
    xd=get(hh{iresult},'xdata');
    set(hh{iresult},'linewidth',3*lw,'zdata',(length(wavelets)+1)*ones(size(xd)));
    xd=get(hh{end},'xdata');
    set(hh{end},'zdata',-1*ones(size(xd)),'color',[.7 .7 .7])
    set(hspecaxe,'tag','spectra','fontsize',12);
    
    set(hfig,'currentaxes',hspecaxephs);
    colororder(co);
    hh=phspec(tws,wavelets,2,0,1);
    title('');
    yl=ylim;
    xl=xlim;
    xlabel('Frequency (Hz)','position',[.5*diff(xl) yl(1) 1],'verticalalignment','bottom')
    legend(names,'interpreter','none','location','northeast')
    title('phases are relative to max(envelope) for each wavelet','fontweight','normal');
    %hh=dbspec(tws{1},[wavelets s(ind)],'windowflags',ones(1,nresults+1));
    lw=get(hh(iresult),'linewidth');
    xd=get(hh(iresult),'xdata');
    set(hh(iresult),'linewidth',3*lw,'zdata',(length(wavelets)+1)*ones(size(xd)));
    set(hspecaxephs,'tag','phspectra','fontsize',12);
%     bigfont(gca,1.5,1);
%     disableDA(gcf);
elseif(strcmp(action,'deletewavelet'))
    %determine which wavelet
    tag=get(gco,'tag');
    ikill=str2double(tag);
    if(isnan(ikill))
        return;
    end
    wavestruc=getwavestruc;
    wavestruc.results(ikill)=[];
    iresult=wavestruc.iresult;
    if(iresult>ikill)
        iresult=iresult-1;
    end
    if(iresult==ikill)
        if(ikill==1)
            iresult=1;
        else
            iresult=iresult-1;
        end
    end
    wavestruc.iresult=iresult;
    setwaveletgate(wavestruc.results{iresult}.tw1,wavestruc.results{iresult}.tw2);
    setwavestruc(wavestruc);
    waveex('traceplot');
    waveex('tvphsdelay');
    waveex('waveletplot');
    disableDA(gcf);
elseif(strcmp(action,'selectwavelet'))
    %determine which wavelet
    tag=get(gco,'tag');
    iselect=str2double(tag);
    if(isnan(iselect))
        return;
    end
    wavestruc=getwavestruc;
    wavestruc.iresult=iselect;
    setwavestruc(wavestruc);
    
%     fillcontrolpanel(wavestruc.results{iselect}.params);
    setparms(wavestruc.results{iselect}.params);
    setwaveletgate(wavestruc.results{iselect}.tw1,wavestruc.results{iselect}.tw2);
    %settvparms(wavestruc.results{iselect}.twin,wavestruc.results{iselect}.tinc);
    waveex('traceplot');
    waveex('tvphsdelay');
    waveex('waveletplot');
    disableDA(gcf);
elseif(strcmp(action,'receivenewref'))
%     rtmp=ALIGN_REF_RNEW;%the new r
    rnew=ALIGN_REF_RNEW;%the new r
    stretch=ALIGN_REF_STR;%the stretch function. Column 1 is time and column 2 is times of new r.
    % put another way, the shift of r is given by stretch(:,2)-stretch(:,1)
    wavestruc=getwavestruc;
    %the call below is probably no longer needed. It is a vestage of the original design when I allowed
    %r to be shorter than s. Now they are always the same length but r will generally have a zero pad
    %on both ends
%     tmp=padtrace(trtmp,[rtmp strtmp],wavestruc.t);%internal function
%     rnew=tmp(:,1);
%     strnew=tmp(:,2);
    trnew=wavestruc.t;
    nref=size(wavestruc.r,2);
    wavestruc.r=[wavestruc.r rnew];
    wavestruc.str=[wavestruc.str stretch];
    wavestruc.ireflec=nref+1;
    wavestruc.tr=trnew;%should always be the same length as t
    setwavestruc(wavestruc);
    %want to define a new wavelet gate because the reflectivity has shifted
    [tw1,tw2]=getwaveletgate;%the old gate
    twnew=interp1(stretch(:,1),stretch(:,2),[tw1,tw2]);%interpolate stretches at the gate times
    setwaveletgate(twnew(1),twnew(2));
    
    % start a new result
    thisresult=getcurrentresult;
    result.w=zeros(size(thisresult.w));
    result.tw=zeros(size(thisresult.tw));
    result.tw1=twnew(1);
    result.tw2=twnew(2);
    result.tvphaseSR=[];
    result.tvdelaySR=[];
    result.tvphaseSS=[];
    result.tvdelaySS=[];
    result.tvphaseRR=[];
    result.tvdelayRR=[];
    result.tvpep=[];
    result.tvprr=[];
    result.tvccSS=[];
    result.tvccRR=[];
    result.params=thisresult.params;
    result.tinc=thisresult.tinc;
    result.twin=thisresult.twin;
    result.fmin=thisresult.fmin;
    result.fmax=thisresult.fmax;
    result.name=[];
    result.sp=zeros(size(wavestruc.t));
    result.rp=zeros(size(wavestruc.t));
    result.r=rnew;
    result.rf=butterband(rnew,trnew,thisresult.fmin,thisresult.fmax,4,0);
    result.icausal=0;
    result.ccs=0;
    result.pep=0;
    result.ccr=0;
    result.prr=0;
    result.wavelabel=[];
    result.phase=0;
    setnewresult(result);
    
    %call wavelet update
    happly=findobj(gcf,'tag','apply');
    eval(happly.UserData);%applies current method to new reflectivity
    disableDA(gcf);
elseif(strcmp(action,'help'))
    hinfo=findobj(gcf,'tag','info');
    ud=hinfo.UserData;
    winopen(ud);
elseif(strcmp(action,'close'))
    halign=findobj(gcf,'tag','aligntool');
    if(isgraphics(halign.UserData))
        close(halign.UserData');
    end
    delete(gcf)
end

end

function thisresult=getcurrentresult
wavestruc=getwavestruc;
if(~isempty(wavestruc.results))
    ir=wavestruc.iresult;
    thisresult=wavestruc.results{ir};
else
    thisresult=[];
end
end

function setcurrentresult(thisresult)
%this is called in 'tvphsdelay'
wavestruc=getwavestruc;
ir=wavestruc.iresult;
if(ir>0)
    wavestruc.results{ir}=thisresult;
    setwavestruc(wavestruc);
end
end

function setnewresult(thisresult)
%this is called in 'receivenewref'
wavestruc=getwavestruc;
ir=wavestruc.iresult+1;
if(ir>0)
    wavestruc.results{ir}=thisresult;
    wavestruc.iresult=ir;
    setwavestruc(wavestruc);
end
end

function wavestruc=getwavestruc
hcntl=findobj(gcf,'tag','control');
wavestruc=get(hcntl,'userdata');
end

function setwavestruc(wavestruc)
hcntl=findobj(gcf,'tag','control');
set(hcntl,'userdata',wavestruc);
end

function [tw1,tw2]=getwaveletgate
global TGATE1 TGATE2
%if the lines are not drawn, then the boxes rule. Otherwise its the lines
wavestruc=getwavestruc;
htw1=findobj(gca,'tag','tw1');
if(isempty(htw1))
    %go to text boxes
    hcntl=findobj(gcf,'tag','control');
    hbox=findobj(hcntl,'tag','tw1');
    if(isempty(hbox))
        tr=wavestruc.tr;
        tdel=tr(end)-tr(1);
        tw1=tr(1)+.1*tdel;
        tw2=tr(end)-.1*tdel;
    else
        val=get(hbox,'string');
        tw1=str2double(val);
        hbox=findobj(hcntl,'tag','tw2');
        val=get(hbox,'string');
        tw2=str2double(val);
    end

else
    htw2=findobj(gca,'tag','tw2');
    x=get(htw1,'xdata');
    tw1=x(1);
    x=get(htw2,'xdata');
    tw2=x(1);
end
TGATE1=tw1;
TGATE2=tw2;
end

% function fillcontrolpanel(parms)
% hcntl=findobj(gcf,'tag','control');
% for k=1:2:length(parms)
%     tag=parms{k};
%     hobj=findobj(hcntl,'tag',tag);
%     if(~isempty(hobj))
%         if(strcmp(get(hobj,'style'),'edit'))
%             %so fill in the edit text box
%             set(hobj,'string',num2str(parms{k+1}));
%         else
%             %this will mean a popupmenu
%             choices=get(hobj,'string');
%             thischoice=parms{k+1};
%             for kk=1:length(choices)
%                 if(strcmp(choices{kk},thischoice))
%                     val=kk;
%                 end
%             end
%             set(hobj,'value',val);
%         end
%     end
% end
% end

function setwaveletgate(tw1,tw2)
global TGATE1 TGATE2
hcntl=findobj(gcf,'tag','control');
htw=findobj(hcntl,'tag','tw1');
set(htw,'string',num2str(tw1));
htw=findobj(hcntl,'tag','tw2');
set(htw,'string',num2str(tw2));
%now change the green lines
htraces=findobj(gcf,'tag','trtime');
hline=findobj(htraces,'tag','tw1');
if(isempty(hline))
    return
end
set(hline,'xdata',[tw1 tw1]);
hline=findobj(htraces,'tag','tw2');
set(hline,'xdata',[tw2 tw2]);
TGATE1=tw1;
TGATE2=tw2;
end

function [twin,tinc]=gettvparms
wavestruc=getwavestruc;
t=wavestruc.t;
htvcntl=findobj(gcf,'tag','tvcontrol');
hobj=findobj(htvcntl,'tag','twin');
val=get(hobj,'string');
twin=str2double(val);
if(isnan(twin)||twin>.5*(t(end)-t(1))||twin<0)
    msgbox('Bad value for time window, cannot proceed');
    twin=nan;
    tinc=nan;
    return;
end
hobj=findobj(htvcntl,'tag','tinc');
val=get(hobj,'string');
tinc=str2double(val);
if(isnan(tinc)||tinc>twin||tinc<0)
    msgbox('Bad value for window increment, cannot proceed');
    twin=nan;
    tinc=nan;
    return;
end
end

% function settvparms(twin,tinc)
% htvcntl=findobj(gcf,'tag','tvcontrol');
% hobj=findobj(htvcntl,'tag','twin');
% set(hobj,'string',time2str(twin));
% hobj=findobj(htvcntl,'tag','tinc');
% set(hobj,'string',time2str(tinc));
% end

function alignment(~,~)
global TGATE1 TGATE2
%invoke the alignment tool
[tw1,tw2]=getwaveletgate;
TGATE1=tw1;
TGATE2=tw2;
hmfig=gcf;
halign=findobj(hmfig,'tag','aligntool');
if(isgraphics(halign.UserData))
    figure(halign.UserData);
    return;
end
wavestruc=getwavestruc;
s=wavestruc.s;
r=wavestruc.r(:,wavestruc.ireflec);
t=wavestruc.t;
tr=wavestruc.tr;
I=wavestruc.I;
z=wavestruc.z;
tz=wavestruc.tz;
cb='waveex(''receivenewref'')';
wfact=.5;
hfact=.8;
name1=get(hmfig,'name');%name of wavelet explorer window
align_ref(r,tr,s,t,I,z,tz,cb,wfact,hfact);
harfig=gcf;
name2=get(harfig,'name');%name of alignment tool window
ind=strfind(name1,':');
set(harfig,'name',[name1(:,1:ind(1)) ' ' name2 '>>' wavestruc.name])
halign.UserData=harfig;
end

function s2=padtrace(t,s,tref)
% pads s to be the same length as tref. Assume same sample rate in both
% s can be multi column.
ncols=size(s,2);
dt=t(2)-t(1);
nzeros_beg=round((t(1)-tref(1))/dt);
nzeros_end=round((tref(end)-t(end))/dt);
if(nzeros_beg>0)
    stmp=[zeros(nzeros_beg,ncols);s];
elseif(nzeros_beg<0)
    stmp=s(abs_(nzeros_beg)+1:end);
else
    stmp=s;
end
if(nzeros_end>0)
    s2=[stmp;zeros(nzeros_end,ncols)];
elseif(nzeros_end<0)
    s2=stmp(1:end-abs(nzeros_end));
else
    s2=stmp;
end
if(size(s2,1)<length(tref))
    s2=[s2;zeros(length(tref)-size(s2,1),ncols)];
elseif(size(s2,1)>length(tref))
    s2=s2(1:length(tref),1:ncols);
end

end

function setparms(parms)
% called when a result is selected by clicking on a wavelet
% it loads the parameters with those for the selected result
hfig=gcf;
for k=1:2:length(parms)
   hobj=findobj(hfig,'tag',parms{k});
   if(length(hobj)==2)
       %means we are setting gate
       for j=1:2
           switch hobj(j).Type
               case 'UIcontrol'
                   hobj(j).String=num2str(parms{k+1});
               case 'Line'
                   hobj.XData=parms{k+1}*ones(1,2);
           end
       end
   else
       style=hobj.Style;
       switch style
           case 'edit'
               hobj.String=num2str(parms{k+1});
           case 'popupmenu'
               hobj.Value=parms{k+1}+1;
       end
   end
   
           
end

end

function haxe=getaxis(name)
% name must be one of 'traces','tracesf','wavelets','ampspec','phspec','tvphase','tvdelay','tvpep','tvcc'
hcntl=findobj(gcf,'tag','control');
switch name
    case 'traces'
        haxe=hcntl.UserData.haxes(1);
    case 'tracesf'
        haxe=hcntl.UserData.haxes(2);
    case 'wavelets'
        haxe=hcntl.UserData.haxes(3);
    case 'ampspec'
        haxe=hcntl.UserData.haxes(4);
    case 'phspec'
        haxe=hcntl.UserData.haxes(5);
    case 'tvphase'
        haxe=hcntl.UserData.haxes(6);
    case 'tvdelay'
        haxe=hcntl.UserData.haxes(7);
    case 'tvpep'
        haxe=hcntl.UserData.haxes(8);
    case 'tvcc'
        haxe=hcntl.UserData.haxes(9);
    otherwise
        error('Unknown axes request');
end
        
end
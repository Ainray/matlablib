function datar=seisplotfilt(seis1,t1,x1,dname1)
% SEISPLOTFILT: Interactive filtering of a seismic stack or gather
%
% datar=seisplotfilt(seis,t,x,dname)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The input seismic
% gather is platted as an image in the left-hand-side and a band[pass filtered gather is plotted as
% an image in the right-hand-side. Initial display uses default parameters which will probably
% please no one. Controls are provided to adjust the filter and re-apply. The data should be
% regularly sampled in both t and x.
%
% seis ... seismic matrix
% t ... time coordinate vector for seis
% x ... space coordinate vector for seis
%   *********** default = 1:number_of_traces ************
% dname ... text string nameing the seismic matrix.
%   *********** default = 'Input data' **************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the input seismic axes
%           data{2} ... handle of the filter seismic axes
% These return data are provided to simplify plotting additional lines and
% text in either axes.
% 
% G.F. Margrave, Margrave-Geo, 2017-2020
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
global NEWFIGVIS
if(~ischar(seis1))
    action='init';
else
    action=seis1;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(nargin<2)
        error('at least 3 inputs are required');
    end
    if(nargin<3)
        x1=1:size(seis1,2);
    end
    if(nargin<4)
        dname1='Input data';
    end
    
    x2=x1;
    t2=t1;
    dt=t1(2)-t1(1);
    tmin=t1(1);
    tmax=t1(end);
    T1=(tmax-tmin)/2;
    fnyq=.5/dt;
    fmax=round(.25*fnyq);
    fmin=10;
    
    dfmin=5;
    dfmax=20;
    phase=0;
    tvfmin=fmin;
    tvdfmin=dfmin;
    tvfmax=fmax;
    tvdfmax=dfmax;
    fmaxmax=2*fmax;
    fmaxmin=.5*fmax;
    
    seis2=seis1;
    
    if(length(t1)~=size(seis1,1))
        error('time coordinate vector does not match first seismic matrix');
    end
    if(length(x1)~=size(seis1,2))
        error('space coordinate vector does not match first seismic matrix');
    end
    if(length(t2)~=size(seis2,1))
        error('time coordinate vector does not match second seismic matrix');
    end
    if(length(x2)~=size(seis2,2))
        error('space coordinate vector does not match second seismic matrix');
    end
    
    if(iscell(dname1))
        dname1=dname1{1};
    end

    xwid=.35;
    yht=.8;
    xsep=.05;
    xnot=.125;
    ynot=.1;
    tvfilt=0;
    statfilt=1;
    staton='on';
    tvon='off';
    if(tvfilt==1)
        statfilt=0;
        staton='off';
        tvon='on';
    end

    %test to see if we are from enhance. This enables the fromenhance.m function to work
    ff=figs;%if there are no existing figs then we cannot be from enhance
    notfromenhance=true;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           notfromenhance=false;
           %so the current figure is from enhance and we assume it hase called this one
           enhancetag='fromenhance';
           udat={-999.25,gcf};
           [~,cmapname1,iflip1]=enhancecolormap('sections');
           [~,cmapname2,iflip2]=enhancecolormap('sections');
       end

    end
    if(notfromenhance)
       enhancetag='';
       udat=[]; 
       cmapname1='goldgray';
       iflip1=0;
       cmapname2=cmapname1;
       iflip2=0;
    end
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    

    
    set(hfig,'tag',enhancetag,'userdata',udat)
    
    %the hide seismic button
    xnow=xnot;
    ynow=.97;
    wid=.055;ht=.05;sep=.005;
    ht2=.5*ht;
    uicontrol(hfig,'style','pushbutton','string','Hide input','tag','hideshow','units','normalized',...
        'position',[xnow,ynow,wid,ht2],'callback','seisplotfilt(''hideshow'');','userdata','hide');
    %the toggle button
    ynow=ynow-ht2;
    uicontrol(hfig,'style','pushbutton','string','Toggle','tag','toggle','units','normalized',...
        'position',[xnow,ynow,wid,ht2],'callback','seisplotfilt(''toggle'');','visible','off');
    
    
    hax1=subplot('position',[xnot ynot xwid yht]);
        
    hi=imagesc(x1,t1,seis1);
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
    uimenu(hcm,'label','f-x phase','callback',@showfxphase);
    uimenu(hcm,'label','f-x amp','callback',@showfxamp);
    uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm);
    grid
    htit=enTitle(dname1);
    htit.Interpreter='none';
    maxmeters=7000;
    if(max(t1)<10)
        ylabel('time (s)')
    elseif(max(t1)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    xlabel('line coordinate')
    
    %make a clip control
    xnow=xnot-2*wid;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip1',...
        'userdata',hax1,'title','Clipping');

    data={[-3 3],hax1};
    callback='';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;
    
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+2.5*ht,.5*wid,.5*ht],'callback','seisplotfilt(''info'');',...
        'backgroundcolor','y');
    
    %right-click message
    annotation(hfig,'textbox','string','Right-click on either image for analysis tools',...
        'position',[.425,.95,.2,ht],'linestyle','none','fontsize',8,'color','r','fontweight','bold');
    
    ht=.5*ht;

    
    set(hax1,'tag','seis1');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);

    imagesc(x2,t2,seis2);
    grid
    
    %colormap control
    ynow=ynow-9*ht;
    pos=[xnow,ynow,1.2*wid,8*ht];
    cb1='';cb2='';
    cbflag=[0,1];
    cbcb='';
    cbaxe=[hax1,hax2];
    enhancecolormaptool(hfig,pos,hax1,hax2,cb1,cb2,cmapname1,cmapname2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    
    if(max(t2)<10)
        ylabel('time (s)')
    elseif(max(t2)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('(depth (ft)')
    end
    xlabel('line coordinate')
    
    %make a clip control
    xnow=xnot+2*xwid+xsep;
    ynow=ynot+yht-htclip;
    hclip2=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip2',...
        'userdata',hax2,'title','Clipping');
    data={[-3 3],hax2};
    callback='seisplotfilt(''clip2'');';
    cliptool(hclip2,data,callback);
    hfig.CurrentAxes=hax2;

    ht=.025;
    ynow=ynow-ht-sep;
    xnow=xnow+sep;
    uicontrol(hfig,'style','text','string','Filter parameters:','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'tooltipstring','Choose stationary or time-variant');
    ynow=ynow-3*ht;
    widbg=1.5*wid;
    hbg1=uibuttongroup('position',[xnow,ynow,widbg,3*ht],'title','Filter type','tag','choices',...
        'selectionchangedfcn','seisplotfilt(''filterchoice'');');
    uicontrol(hbg1,'style','radiobutton','string','Stationary','units','normalized','position',...
        [0 .5 1 .5],'value',statfilt);
    uicontrol(hbg1,'style','radiobutton','string','Time variant','units','normalized','position',...
        [0 0 1 .5],'value',tvfilt);
    %First the stationary filter panel
    widpan=widbg;
    htpan=5*ht;
    ynow=ynow-htpan;
    hpan1=uipanel(hfig,'units','normalized','position',[xnow,ynow,widpan,htpan],'tag','stat','visible',staton);
    ht2=.2*4/5;
    sep2=.01*4/5;
    wid2=.22;
    yn=1-ht2-sep2;
    xn=0;
    uicontrol(hpan1,'style','text','string','Fmin:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the minimum frequency (Hz) to pass, enter zero for a lowpass filter');
    uicontrol(hpan1,'style','edit','string',num2str(fmin),'units','normalized','tag','fmin',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
     uicontrol(hpan1,'style','text','string','dFmn:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the lowend. Leave blank for the default which is .5*Fmin');
    if(isnan(dfmin))
        val1='';
    else
        val1=num2str(dfmin);
    end
    uicontrol(hpan1,'style','edit','string',val1,'units','normalized','tag','dfmin',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fmin');
    yn=yn-ht2-sep2;
    uicontrol(hpan1,'style','text','string','Fmax:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the maximum frequency (Hz) to pass, enter zero for a highpass filter');
    uicontrol(hpan1,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(hpan1,'style','text','string','dFmx:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the high end. Leave blank for the default which is 10 Hz');
     if(isnan(dfmax))
        val2='';
    else
        val2=num2str(dfmax);
    end
    uicontrol(hpan1,'style','edit','string',val2,'units','normalized','tag','dfmax',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fnyq-Fmax');
    %Now the time-variant panel
    hpan2=uipanel(hfig,'units','normalized','position',[xnow,ynow,widpan,htpan],'tag','tv','visible',tvon);
    ht2=.2*4/5;
    sep2=.01*4/5;
    yn=1-ht2-sep2;
    xn=0;
    uicontrol(hpan2,'style','text','string','T1:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the time at which filter parameters are specified');
    uicontrol(hpan2,'style','edit','string',num2str(T1),'units','normalized','tag','T1',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in seconds between ' ...
        time2str(t1(1)) ' and ' time2str(t1(end))]);
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmin:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the minimum frequency (Hz) to pass, enter zero for a lowpass filter');
    uicontrol(hpan2,'style','edit','string',num2str(tvfmin),'units','normalized','tag','tvfmin',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
     uicontrol(hpan2,'style','text','string','dFmn:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the lowend. Leave blank for the default which is .5*Fmin');
    if(isnan(tvdfmin))
        val1='';
    else
        val1=num2str(tvdfmin);
    end
    uicontrol(hpan2,'style','edit','string',val1,'units','normalized','tag','tvdfmin',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fmin');
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmax:','units','normalized',...
        'position',[xn,yn,wid2,ht2],'tooltipstring',...
        'This is the maximum frequency (Hz) to pass, enter zero for a highpass filter');
    uicontrol(hpan2,'style','edit','string',num2str(tvfmax),'units','normalized','tag','tvfmax',...
        'position',[xn+wid2+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(hpan2,'style','text','string','dFmx:','units','normalized',...
        'position',[xn+2*(wid2+sep2),yn,wid2,ht2],'tooltipstring',...
        'This is the rolloff width on the high end. Leave blank for the default which is 10 Hz');
    if(isnan(tvdfmax))
        val2='';
    else
        val2=num2str(tvdfmax);
    end
    uicontrol(hpan2,'style','edit','string',val2,'units','normalized','tag','tvdfmax',...
        'position',[xn+3*(wid2+sep2),yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fnyq-Fmax');
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmaxmax:','units','normalized',...
        'position',[xn,yn,2*wid2,ht2],'tooltipstring','Maximimum allowed value of Fmax');
    uicontrol(hpan2,'style','edit','string',num2str(fmaxmax),'units','normalized','tag','fmaxmax',...
        'position',[xn+2*wid2+sep2,yn,1.5*wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','Fmaxmin:','units','normalized',...
        'position',[xn,yn,2*wid2,ht2],'tooltipstring','Minimum allowed value of Fmax');
    uicontrol(hpan2,'style','edit','string',num2str(fmaxmin),'units','normalized','tag','fmaxmin',...
        'position',[xn+2*wid2+sep2,yn,1.5*wid2,ht2],'tooltipstring','Enter a value in Hz between Fmin and Fmax');
    
    %phase
    ynow=ynow-ht-sep;
    wid=0.03;
    uicontrol(hfig,'style','text','string','Phase:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Phase of filter');
    uicontrol(hfig,'style','popupmenu','string',{'zero','minimum'},'units','normalized','tag','phase',...
        'position',[xnow+wid+sep,ynow,1.3*wid,ht],'tooltipstring','Usually choose zero','value',phase+1);
    ynow=ynow-ht-sep;
    wid=0.055;
    uicontrol(hfig,'style','pushbutton','string','Apply Filter','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfilt(''applyfilter'');',...
        'tooltipstring','Apply current filter specs','backgroundcolor','y');
    
    ynow=ynow-2*ht-sep;
    
    uicontrol(hfig,'style','pushbutton','string','Show spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfilt(''spectra'');',...
        'tooltipstring','Show spectra in separate window','tag','spectra','userdata',[]);
    
    
    ynow=ynow-2*ht-sep;
     uicontrol(hfig,'style','text','string','Compute performace:','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht]);
    ynow=ynow-ht-sep;
     uicontrol(hfig,'style','text','string','','units','normalized','tag','performance',...
        'position',[xnow,ynow,1.5*wid,ht]);
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(hfig,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplotfilt(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplotfilt(''equalzoom'');');
    
    %results popup
    xnow=pos(1);
    ynow=pos(2)+pos(4)-ht;
    wid=pos(3);
    ht=3*ht;
    fs=12;
    fontops={'x2','x1.5','x1.25','x1.11','x1','x0.9','x0.8','x0.67','x0.5'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange,'userdata',hax2);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
    uicontrol(hfig,'style','popupmenu','string','Diddley','units','normalized','tag','results',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfilt(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm)
     uicontrol(hfig,'style','popupmenu','string','Diddley','units','normalized','tag','shortresults',...
        'position',[xnow+.25*wid,ynow,.5*wid,ht],'callback','seisplotfilt(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm,'visible','off')
    
    %delete button
    xnow=xnow+wid+sep;
    wid=.075;
    ht=ht/3;
    %userdata of the delete button is the number of the current selection
    uicontrol(hfig,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnow,ynow+1.75*ht,wid,ht],'callback','seisplotfilt(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    %shortnames
    uicontrol(hfig,'style','radiobutton','string','Short Names','units','normalized',...
        'tag','shortnames','position',[xnow,ynow+2.75*ht,wid,ht],'callback','seisplotfilt(''shortnames'');',...
        'tooltipstring','Use short names','value',0);
    
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
    
    set(hax2,'tag','seis2');

    set(hfig,'name',['Filter analysis for ' dname1],'closerequestfcn','seisplotfilt(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
    seisplotfilt('applyfilter');

elseif(strcmp(action,'clip2'))
    hmasterfig=gcf;
    hclip=findobj(hmasterfig,'tag','clip2');
    clim=cliptool('getlims',hclip);
    hresult=findobj(hmasterfig,'tag','results');
    results=get(hresult,'userdata');
    if(~isempty(results))
        iresult=get(hresult,'value');
        results.clims{iresult}=clim;
        set(hresult,'userdata',results)    
    end  

elseif(strcmp(action,'equalzoom'))
    hbut=gcbo;
    hseis1=findobj(gcf,'tag','seis1');
    hseis2=findobj(gcf,'tag','seis2');
    tag=get(hbut,'tag');
    switch tag
        case '1like2'
            xl=get(hseis2,'xlim');
            yl=get(hseis2,'ylim');
            set(hseis1,'xlim',xl,'ylim',yl);
            
        case '2like1'
            xl=get(hseis1,'xlim');
            yl=get(hseis1,'ylim');
            set(hseis2,'xlim',xl,'ylim',yl);
    end
elseif(strcmp(action,'filterchoice'))
    hchoice=findobj(gcf,'tag','choices');
    choice=hchoice.SelectedObject.String;
    hpanstat=findobj(gcf,'tag','stat');
    hpantv=findobj(gcf,'tag','tv');
    switch choice
        case 'Stationary'
            set(hpanstat,'visible','on');
            set(hpantv,'visible','off');
        case 'Time variant'
            set(hpanstat,'visible','off');
            set(hpantv,'visible','on');
    end
elseif(strcmp(action,'applyfilter'))
    %determine filter choice
    hchoice=findobj(gcf,'tag','choices');
    choice=hchoice.SelectedObject.String;
    switch choice
        case 'Stationary'
            seisplotfilt('applyfilterstat');
        case 'Time variant'
            seisplotfilt('applyfiltertv');
    end

elseif(strcmp(action,'applyfiltertv'))
    hfig=gcf;
    hseis1=findobj(hfig,'tag','seis1');
    hi=findobj(hseis1,'type','image');
    hcm=hi.ContextMenu;
    seis1=get(hi,'cdata');
    t=get(hi,'ydata');
    hseis2=findobj(hfig,'tag','seis2');
    fnyq=.5/(t(2)-t(1));
    hobj=findobj(hfig,'tag','T1');
    val=get(hobj,'string');
    T1=str2double(val);
    if(isnan(T1))
        msgbox('T1 is not recognized as a number','Oh oh ...');
        return;
    end
    if(T1<t(1) || T1>t(end))
        msgbox(['T1 must be between ' time2str(t(1)) ' and ' time2str(t(end))],'Oh oh ...');
        return;
    end
    hobj=findobj(hfig,'tag','tvfmin');
    val=get(hobj,'string');
    fmin=str2double(val);
    if(isnan(fmin))
        msgbox('Fmin is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmin<0 || fmin>fnyq)
        msgbox(['Fmin must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    hobj=findobj(hfig,'tag','tvdfmin');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmin=str2double(val);
        if(isnan(dfmin))
            msgbox('dFmin is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmin<0 || dfmin>fmin)
            msgbox(['dFmin must be greater than 0 and less than ' num2str(fmin)],'Oh oh ...');
            return;
        end
    else
        dfmin=.5*fmin;
    end
    hobj=findobj(hfig,'tag','tvfmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        msgbox('Fmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmax<0 || fmax>fnyq)
        msgbox(['Fmax must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    if(fmax<=fmin && fmax~=0)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    hobj=findobj(hfig,'tag','tvdfmax');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmax=str2double(val);
        if(isnan(dfmax))
            msgbox('dFmax is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmax<0 || dfmax>fnyq-fmax)
            msgbox(['dFmax must be greater than 0 and less than ' num2str(fnyq-fmax)],'Oh oh ...');
            return;
        end
    else
        dfmax=10;
    end
    hobj=findobj(hfig,'tag','fmaxmax');
    val=get(hobj,'string');
    fmaxmax=str2double(val);
    if(isnan(fmaxmax))
        msgbox('Fmaxmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmaxmax<fmax || fmaxmax>fnyq)
        msgbox('Fmaxmax must be greater than Fmax and less than Fnyq','Oh oh ...');
        return;
    end
    hobj=findobj(hfig,'tag','fmaxmin');
    val=get(hobj,'string');
    fmaxmin=str2double(val);
    if(isnan(fmaxmin))
        msgbox('Fmaxmin is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmaxmin<fmin || fmaxmin>fmax)
        msgbox('Fmaxmin must be greater than Fmin and less than Fmax','Oh oh ...');
        return;
    end

    hobj=findobj(hfig,'tag','phase');
    ival=get(hobj,'value');
    phase=ival-1;
    t1=clock;
    twin=.4;
    seis2=filt_hyp(seis1,t,T1,[fmin dfmin],[fmax,dfmax],[fmaxmax fmaxmin],phase,80,1,twin,10,1);  
    t2=clock;
    timepertrace=round(100000*etime(t2,t1)/size(seis1,2))/1000;
    hperf=findobj(hfig,'tag','performance');
    set(hperf,'string',[num2str(timepertrace) ' ms/trace'])
    hi=findobj(hseis2,'type','image');
    set(hi,'cdata',seis2);
    hfig.CurrentAxes=hseis2;
    %update clipping
%     [N,xn,sigma,am,amax,amin]=getampinfo(seis2);
    clip=3;
    clim=clip*[-1 1];
    hclip2=findobj(hfig,'tag','clip2');
%     set(hclip2,'userdata',{[N;xn],am,sigma,amax,amin,hseis2});
    set(hclip2,'userdata',hseis2);
    clipdat={clim,hseis2};
    cliptool('refresh',hclip2,clipdat);
    %save results
    if(phase==0)
        dname='Zero-phase, ';
    else
        dname='Min-phase, ';
    end
    name=[dname ' TV, T1=' num2str(T1) ', fmin=[' num2str(fmin) ',' num2str(dfmin) '], fmax=[' num2str(fmax) ...
        ',' num2str(dfmax) '], fmaxmax=' num2str(fmaxmax) ', fmaxmin=' num2str(fmaxmin)];
    set(hi,'uicontextmenu',hcm);
    %save the results and update hresults
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.expnumber=1;
        results.shortnames={'Filter #1'};
        results.data={seis2};
        results.choice={'TV'};
        results.T1s={T1};
        results.fmins={fmin};
        results.dfmins={dfmin};
        results.fmaxs={fmax};
        results.dfmaxs={dfmax};
        results.fmaxmaxs={fmaxmax};
        results.fmaxmins={fmaxmin};
        results.phases={phase};
        results.clipdats={clipdat};
        results.clims={clim};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.expnumber(nresults)=results.expnumber(nresults-1)+1;
        results.shortnames{nresults}=['Filter #' int2str(results.expnumber(nresults))];
        results.data{nresults}=seis2;
        results.choice{nresults}='TV';
        results.T1s{nresults}=T1;
        results.fmins{nresults}=fmin;
        results.dfmins{nresults}=dfmin;
        results.fmaxs{nresults}=fmax;
        results.dfmaxs{nresults}=dfmax;
        results.fmaxmaxs{nresults}=fmaxmax;
        results.fmaxmins{nresults}=fmaxmin;
        results.phases{nresults}=phase;
        results.clipdats{nresults}=clipdat;
        results.clims{nresults}=clim;
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hshortresults=findobj(gcf,'tag','shortresults');
    set(hshortresults,'string',results.shortnames,'value',nresults)
    %update the userdata of hdelete
    hdelete=findobj(gcf,'tag','delete');
    set(hdelete,'userdata',nresults);
    %see if spectra window is open
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotfilt('spectra');
    end
elseif(strcmp(action,'applyfilterstat'))
    hfig=gcf;
    hseis1=findobj(hfig,'tag','seis1');
    hseis2=findobj(hfig,'tag','seis2');
    hi=findobj(hseis1,'type','image');
    hcm=hi.ContextMenu;
    seis=get(hi,'cdata');
    t=get(hi,'ydata');
    fnyq=.5/(t(2)-t(1));
    hobj=findobj(hfig,'tag','fmin');
    val=get(hobj,'string');
    fmin=str2double(val);
    if(isnan(fmin))
        msgbox('Fmin is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmin<0 || fmin>fnyq)
        msgbox(['Fmin must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    hobj=findobj(hfig,'tag','dfmin');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmin=str2double(val);
        if(isnan(dfmin))
            msgbox('dFmin is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmin<0 || dfmin>fmin)
            msgbox(['dFmin must be greater than 0 and less than ' num2str(fmin)],'Oh oh ...');
            return;
        end
    else
        dfmin=.5*fmin;
    end
    hobj=findobj(hfig,'tag','fmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        msgbox('Fmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmax<0 || fmax>fnyq)
        msgbox(['Fmax must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    if(fmax<=fmin && fmax~=0)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    hobj=findobj(hfig,'tag','dfmax');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmax=str2double(val);
        if(isnan(dfmax))
            msgbox('dFmax is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmax<0 || dfmax>fnyq-fmax)
            msgbox(['dFmax must be greater than 0 and less than ' num2str(fnyq-fmax)],'Oh oh ...');
            return;
        end
    else
        dfmax=10;
    end
    hobj=findobj(hfig,'tag','phase');
    ival=get(hobj,'value');
    phase=ival-1;
    t1=clock;
    seis2=filter_stack(seis,t,fmin,fmax,'method','filtf','phase',phase,'dflow',dfmin,'dfhigh',dfmax);
    t2=clock;
    timepertrace=round(100000*etime(t2,t1)/size(seis,2))/1000;
    hperf=findobj(hfig,'tag','performance');
    set(hperf,'string',[num2str(timepertrace) ' ms/trace'])
    hi=findobj(hseis2,'type','image');
    set(hi,'cdata',seis2);
    hfig.CurrentAxes=hseis2;
    %update clipping
    clip=3;
    clim=clip*[-1 1];
    hclip2=findobj(gcf,'tag','clip2');
    set(hclip2,'userdata',hseis2);
    clipdat={clim,hseis2};
    cliptool('refresh',hclip2,clipdat);
    
    if(phase==0)
        dname='Zero-phase bandpass filter, ';
    else
        dname='Minimum-phase bandpass filter, ';
    end
    name=[dname 'STAT, ' 'fmin=[' num2str(fmin) ',' num2str(dfmin) '], fmax=[' num2str(fmax) ',' num2str(dfmax) ']'];
    set(hi,'uicontextmenu',hcm);
    %save the results and update hresults
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.expnumber=1;
        results.shortnames={'Filter #1'};
        results.data={seis2};
        results.choice={'STAT'};
        results.T1s={};
        results.fmaxmaxs={};
        results.fmaxmins={};
        results.fmins={fmin};
        results.dfmins={dfmin};
        results.fmaxs={fmax};
        results.dfmaxs={dfmax};
        results.phases={phase};
        results.clipdats={clipdat};
        results.clims={clim};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.expnumber(nresults)=results.expnumber(nresults-1)+1;
        results.shortnames{nresults}=['Filter #' int2str(results.expnumber(nresults))];
        results.data{nresults}=seis2;
        results.choice{nresults}='STAT';
        results.T1s{nresults}=[];
        results.fmaxmaxs{nresults}=[];
        results.fmaxmins{nresults}=[];
        results.fmins{nresults}=fmin;
        results.dfmins{nresults}=dfmin;
        results.fmaxs{nresults}=fmax;
        results.dfmaxs{nresults}=dfmax;
        results.phases{nresults}=phase;
        results.clipdats{nresults}=clipdat;
        results.clims{nresults}=clim;
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hshortresults=findobj(gcf,'tag','shortresults');
    set(hshortresults,'string',results.shortnames,'value',nresults)
    %update the userdata of hdelete
    hdelete=findobj(gcf,'tag','delete');
    set(hdelete,'userdata',nresults);
    %see if spectra window is open
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotfilt('spectra');
    end
    
elseif(strcmp(action,'spectra'))
    hfig=gcf;
    
    name=get(hfig,'name');
    ind=strfind(name,'Spectral display');
    if(isempty(ind)) %#ok<STREMP>
        hmaster=hfig;
    else
        hmaster=get(hfig,'userdata');
    end
    hseis1=findobj(hmaster,'tag','seis1');
    hseis2=findobj(hmaster,'tag','seis2');
    hi=findobj(hseis1,'type','image');
    seis1=get(hi,'cdata');
    hi=findobj(hseis2,'type','image');
    seis2=get(hi,'cdata');
    t=get(hi,'ydata');
    name1='Input';
    name2='Filtered';
    hspec=findobj(hmaster,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    CRcallback='seisplotfilt(''closespec'');';
    Winname=[];
    spectralview(seis1,seis2,t,name1,name2,hspecwin,CRcallback,Winname)
    hspecwin=gcf;
    set(hspec,'userdata',hspecwin);
elseif(strcmp(action,'closespec'))
    hfig=gcf;
    hdaddy=get(hfig,'userdata');
    hspec=findobj(hdaddy,'tag','spectra');
    set(hspec,'userdata',[]);
    delete(hfig);
    if(isgraphics(hdaddy))
        figure(hdaddy);
    end
elseif(strcmp(action,'select'))
    hfig=gcf;
%     hdelete=findobj(gcf,'tag','delete');%this has the previous selection
%     iprev=get(hdelete,'userdata');
    hresults=findobj(hfig,'tag','results');
    hshortresults=findobj(hfig,'tag','shortresults');
    results=get(hresults,'userdata');
    hshort=findobj(hfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort==1)
        iresult=get(hshortresults,'value');%the new selection
        set(hresults,'value',iresult);
    else
        iresult=get(hresults,'value');%the new selection
        set(hshortresults,'value',iresult);
    end
    hseis2=findobj(hfig,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    set(hi,'cdata',results.data{iresult});
    hpanstat=findobj(gcf,'tag','stat');
    hpantv=findobj(gcf,'tag','tv');
    hchoice=findobj(gcf,'tag','choices');
    hk=get(hchoice,'children');
    choice=results.choice{iresult};
    switch choice
        case 'STAT'
            set(hpanstat,'visible','on');
            set(hpantv,'visible','off');
            set(hk(2),'value',1)
            hfmin=findobj(hfig,'tag','fmin');
            set(hfmin,'string',num2str(results.fmins{iresult}));
            hdfmin=findobj(hfig,'tag','dfmin');
            set(hdfmin,'string',num2str(results.dfmins{iresult}));
            hfmax=findobj(hfig,'tag','fmax');
            set(hfmax,'string',num2str(results.fmaxs{iresult}));
            hdfmax=findobj(hfig,'tag','dfmax');
            set(hdfmax,'string',num2str(results.dfmaxs{iresult}));
        case 'TV'
            set(hpanstat,'visible','off');
            set(hpantv,'visible','on');
            set(hk(1),'value',1)
            ht1=findobj(hfig,'tag','T1');
            set(ht1,'string',num2str(results.T1s{iresult}));
            hfmin=findobj(hfig,'tag','tvfmin');
            set(hfmin,'string',num2str(results.fmins{iresult}));
            hfmin=findobj(hfig,'tag','tvfmin');
            set(hfmin,'string',num2str(results.fmins{iresult}));
            hdfmin=findobj(hfig,'tag','tvdfmin');
            set(hdfmin,'string',num2str(results.dfmins{iresult}));
            hfmax=findobj(hfig,'tag','tvfmax');
            set(hfmax,'string',num2str(results.fmaxs{iresult}));
            hdfmax=findobj(hfig,'tag','tvdfmax');
            set(hdfmax,'string',num2str(results.dfmaxs{iresult}));
            hfmaxmax=findobj(hfig,'tag','fmaxmaxs');
            set(hfmaxmax,'string',num2str(results.fmaxmaxs{iresult}));
            hfmaxmin=findobj(hfig,'tag','fmaxmins');
            set(hfmaxmin,'string',num2str(results.fmaxmins{iresult}));
    end
    hphase=findobj(hfig,'tag','phase');
    set(hphase,'value',results.phases{iresult}+1);
    %update clipping
    clipdat=results.clipdats{iresult};
    clim=results.clims{iresult};
    clipdat{1}=clim;
    hclip2=findobj(gcf,'tag','clip2');
    cliptool('refresh',hclip2,clipdat);
    %see if spectra window is open
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotfilt('spectra');
    end
elseif(strcmp(action,'hideshow'))
    hbut=gcbo;
    option=get(hbut,'userdata');
    hclip1=findobj(gcf,'tag','clip1');
    %     udat1=get(hclip1,'userdata');
    hax1=findobj(gcf,'tag','seis1');
    hclip2=findobj(gcf,'tag','clip2');
    %udat2=get(hclip2,'userdata');
    hax2=findobj(gcf,'tag','seis2');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    htoggle=findobj(gcf,'tag','toggle');
%     hbrite=findobj(gcf,'tag','brighten');
%     hdark=findobj(gcf,'tag','darken');
%     hbness=findobj(gcf,'tag','brightness');
    hresults=findobj(gcf,'tag','results');
    hdelete=findobj(gcf,'tag','delete');
%     hsetgate=findobj('tag','setgate');
    htools=findobj(gcf,'tag','tools');
    hcpanel=findobj(gcf,'tag','colorpanel');
    
    switch option
        case 'hide'
            pos1=get(hax1,'position');
            pos2=get(hax2,'position');
            x0=pos1(1);
            y0=pos1(2);
            wid=pos2(1)+pos2(3)-pos1(1);
            ht=pos1(4);
            set(hax1,'visible','off','position',[x0,y0,wid,ht]);
            set(hi1,'visible','off');
            set(hclip1,'visible','off');
            set(hax2,'position',[x0,y0,wid,ht]);
            set(htoggle,'userdata',{pos1 pos2})
            set(hbut,'string','Show input','userdata','show')
            set(htoggle,'visible','on');
            set([htools hcpanel],'visible','off');
        case 'show'
            udat=get(htoggle,'userdata');
            pos1=udat{1};
            pos2=udat{2};
            set(hax1,'visible','on','position',pos1);
            set([hi1 hclip1],'visible','on');
            set(hax2,'visible','on','position',pos2);
            set(htoggle','visible','off')
            set(hbut,'string','Hide input','userdata','hide');
            set([hi2 hclip2],'visible','on');
            set([hresults hdelete htools hcpanel],'visible','on');
    end
elseif(strcmp(action,'toggle'))
    hfig=gcf;
    hclip1=findobj(gcf,'tag','clip1');
%     udat1=get(hclip1,'userdata');
    hax1=findobj(hfig,'tag','seis1');
    hclip2=findobj(hfig,'tag','clip2');
%     udat2=get(hclip2,'userdata');
    hax2=findobj(hfig,'tag','seis2');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    
    option=get(hax1,'visible');

    hresults=findobj(gcf,'tag','results');
    hdelete=findobj(gcf,'tag','delete');
    
    switch option
        case 'off'
            %ok, turning on seismic
            xl=hax2.XLim;
            yl=hax2.YLim;
            hax1.XLim=xl;
            hax1.YLim=yl;
            hfig.CurrentAxes=hax1;
            set([hax1 hi1 hclip1],'visible','on');
            set([hax2 hclip2 hi2],'visible','off');
            set([hresults hdelete],'visible','off');
        case 'on'
            %ok, turning off seismic
            xl=hax1.XLim;
            yl=hax1.YLim;
            hax2.XLim=xl;
            hax2.YLim=yl;
            hfig.CurrentAxes=hax2;
            set([hax1 hi1 hclip1],'visible','off');
            set([hax2 hclip2 hi2],'visible','on');
            set([hresults hdelete],'visible','on');
    end
elseif(strcmp(action,'shortnames'))
    hfig=gcf;
    hshortnames=findobj(hfig,'tag','shortnames');
    hresults=findobj(hfig,'tag','results');
    hshortresults=findobj(hfig,'tag','shortresults');
    ishort=hshortnames.Value;
    if(ishort)
        hshortresults.Visible='on';
        hresults.Visible='off';
    else
        hshortresults.Visible='off';
        hresults.Visible='on';
    end
elseif(strcmp(action,'delete'))
    hfig=gcf;
    hdelete=gcbo;
    
    hresults=findobj(hfig,'tag','results');
    hshortresults=findobj(hfig,'tag','shortresults');
    results=get(hresults,'userdata');
    if(length(results.names)==1)
        msgbox('You cannot delete the only result!');
        return;
    end
    iresult=get(hresults,'value');
    fn=fieldnames(results);
    for k=1:length(fn)
        results.(fn{k})(iresult)=[];
    end
    iresult=iresult-1;
    if(iresult<1); iresult=1; end
    set(hresults,'string',results.names,'value',iresult,'userdata',results);
    set(hshortresults,'string',results.shortnames,'value',iresult);
    hdelete.UserData=max([hdelete.UserData-1 1]);
    seisplotfilt('select');
elseif(strcmp(action,'close'))
    hfig=gcf;
    hspec=findobj(gcf,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        delete(hspecwin);
    end
    tmp=get(hfig,'userdata');
    if(iscell(tmp))
        hfigs=tmp{1};
    else
        hfigs=tmp;
    end
    for k=1:length(hfigs)
        if(isgraphics(hfigs(k)))
            close(hfigs(k))
        end
    end
    hclip=findobj(hfig,'tag','clip1');
    ud=get(hclip,'userdata');
    if(length(ud)>6)
        if(isgraphics(ud{7}))
            close(ud{7});
        end
    end
    hclip=findobj(hfig,'tag','clip2');
    ud=get(hclip,'userdata');
    if(length(ud)>6)
        if(isgraphics(ud{7}))
            close(ud{7});
        end
    end
    he=findobj(hfig,'tag','enhancebutton');
    if(isgraphics(he))
       enhance('deleteview',hfig); 
    end
    %this last bit avoids deleting the tool figure if there is another close function to be called
    %(usually PI2D or PI3D)
    crf=get(hfig,'closerequestfcn');
    ind=strfind(crf,';');
    if(ind(1)==length(crf))
        delete(hfig);
    end
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    %see if one already exists
    udat=get(hthisfig,'userdata');
    if(~isempty(udat))
        for k=1:length(udat{1})
            if(isgraphics(udat{1}(k)))
                if(strcmp(get(udat{1}(k),'tag'),'info'))
                    figure(udat{1}(k))
                    return;
                end
            end
        end
    end
    msg1={'Tool layout',{['The axis at left (the input axis) shows the input sesimic and the axis at right ',...
        '(filter axis) shows the result of the application of filter. To the right of the '...
        'filter axis are controls for the filter which can be either stationary or time variant. Each unique '...
        'filter application is considered a "result". The tool remembers your results and ' ...
        'any number of results can be computed. Clicking the "Apply Filter" ',...
        'button generates a new result by applying the current filter specs to the unfiltered data. '],...
        ' ',['Above the filter axes is a popup menu used to ' ...
        'select a result for viewing. Each new computation adds another entry to this menu. The ',...
        'menu names are composed from the parameters of the computation. This can lead to very ',...
        'long names that may be difficult to comprehend and don''t fit well in the display. There are ',...
        'two ways to deal with this. First, by right clicking on the name you will see a menu that ',...
        'allows you to scale the font size or type a new title. Second, short names are also ',...
        'generated automatically and can be chosen by clicking the "Short names" button.'],' ',...
        ['Above the left edge of the input is a button labelled "Hide input". Clicking this causes ',...
        'the input axis to disappear and the filter axis expands to cover the entire window. Also ',...
        'the button label is changed to "Show seismic" and a new button appears labelled "Toggle". ',...
        'The "Show seismic" button will restore the previous view showing both axes. The "Toggle" ',...
        'button allows you to rapidly toggle between the two axes which facilitates a better ',...
        'understanding of the results.'],' ',...
        ['Just to the right of each axes '...
        'are clipping controls for the displays. Smaller clip numbers mean greater clipping. ',...
        'Consider the distribution of amplitudes in the data as a histogram with a mean, Am, and ',...
        'standard deviation, sigma. The clip value defines the extent of the color bar above and below the ',...
        'mean in terms of the number of standard deviations. For example, clip=2 means that the ',...
        'colorbar covers the amplitude range Am-2*sigma->Am+2*sigma where the first entry of the ',...
        'colorbar is asigned to the largest value in this range and the last entry to the smallest ',...
        'value. Amplitude values above Am+2*sigma will',...
        'will all receive the first color while those below Am-2*sigma will recive the last color. '],' ',...
        ['The the filter parameters each have a short description that will appear ',...
        'if you hover the pointer over the parameter name. Note that all "time" values must be ',...
        'specified in seconds, not milliseconds. Both stationary and time-variant bandpass filters ',...
        'are available. The time-variant filter is a called a hyperbolic ',...
        'filter because the Fmax value is specified at a single time and then extrapolated along ',...
        'a hyperbolic contour in the time-frequency plane. If you specify Fmax1 at time T1, then ',...
        'at time T2, Fmax2 is found from the relation T1*Fmax1=T2*Fmax2 so that Fmax2=Fmax1*T1/T2. ',...
        'This means that for T2<T1 Fmax2 is greater than Fmax1, while for T2>T1 the situation is reversed. ',...
        'This method is consistent with Q attenuation theory but, if extended too far, can lead to ',...
        'unacceptable values. Therefore parameters Fmaxmax and Fmaxmin are provided to restrict ',...
        'the possible range of Fmax values.'],...
        ' ',['The "Show spectra" button allows comparison of spectra before and after ',...
        'filtering. Spectra are averages taken over all traces.']}};
    msg2={'Filter parameters',{['The filter analysis tool allows the interactive investigation of different bandpass ',...
        'filters appled to a seismic matrix. The filters can be either stationary or time-varuiant. '],...
        ' ',['The stationary filter is applied in the frequency domain and has ',...
        'strong rejection outside the passband. The image on the left shows the input data and that ',...
        'on the right shows the result after filtering. To the right of the right image are controls ',...
        'that define the parameters of the filter. There are five parameters: Fmin, Fmax, dFmin, dFmax, ',...
        'and Phase. The first four are always values in Hertz (Hz.) and the last is either "zero" or ',...
        '"minimum". The filter passband is the region between Fmin and Fmax and these normally have ',...
        'values between 0 and Nyquist. (Recall that the Nyquist frequency is .5/dt, where dt is the ',...
        'time sample size in seconds, and is the highest possible unaliased frequency.) Setting Fmin ',...
        'to zero gives a lowpass filter (passing every frequency lower than Fmax) while setting Fmax ',...
        'to zero gives a highpass filter (passing every frequency higher than Fmin). '],' ',['Outside the ',...
        'passband the filter rolloff has a Gaussian shape with standard deviation defined by dFmin ',...
        'on the low end and by dFmax on the high end. This means that for f=Fmax+n*dFmax the filter ',...
        'amplitude is -8.69*n^2 dB which for n=1 is -8.69 dB, for n=2 is -34.76 dB and for n=3 is ',...
        '-78.2 dB. Thus at 2 or 3 times the filter width from the passband, the rejection is very strong. '],...
        ' ',['The specification of a time-variant filter is done using the "hyperbolic" concept ',...
        'which is that Fmax, the upper frequency of the bandpass, follows a hyperbolic trajectory in ',...
        'time-frequency space given by t*Fmax(t)=constant. The main reason for this is that the theoretical ',...
        'description of constant-Q attenuation shows that the forward Q operator gives constant attenuation ',...
        'along such curves.'],' ',['A second reason is that the specification of Fmax at any one time then ',...
        'determines Fmax at all times via the formula Fmax(t)=Fmax(t1)*t1/t2 where t1 is the specified time ',...
        'and t2 is any other time. This then implies that for t2<t1, we have Fmax(t2)>Fmax(t1) and for t2>t1, ',...
        'then Fmax(t2)<Fmax(t1). Thus Fmax shows progressive decay with increasing time.'],' ',['In this algorithm ',...
        'Fmax is the only parameter that is adjusted with time. This model can be easily pushed too far, ',...
        'and can predict unacceptably high values at early times and unacceptably low values at later ',...
        'times. Therefore parameters Fmaxmax and Fmaxmin are provided to limit the hyperbolic behavior. '],' ',...
        ['The parameter dFmax spcifies the width of the filter roll-off on the high end (roughly this is the ',...
        'half-width of a Gaussian) and similarly for the low end. This filter is specified and applied in the ',...
        'frequency domain using a Gabor transform. As a result it varies Fmax smoothly and essentially ',...
        'continuously and has very high rejection levels outside the passband.'],...
        ' ',['Above the filtered section is a popup menu giving a title for the current filter result. ',...
        'Each time the "Apply" button is pressed a new result is obtained. The title for a given result ',...
        'is determined by the filter parameters. You can toggle between two different filter results ',...
        'by simply selecting their names from the popup menu. When you select such a result, the filter ',...
        'parameter controls are populated with the parameters for that particular filter. Clicking ',...
        'the "Show spectra" button causes a new window to appear showing the average amplitude spectra ',...
        'before and after the filter. If this window is open when a previous result is selected then ',...
        'it will refresh with the newly chosen spectra. By default the spectra are taken over the ',...
        'temporal length of the seismic data but a smaller time window can be defined using the controls ',...
        'to the right of the spectra. The spectra will only be computed when tmax is greater ',...
        'than tmin.']}};
    msg={msg1,msg2};
    hinfo=showinfo(msg,'Instructions for Filter tool',nan,[600 400],[4 4]);
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        ikill=length(udat{1});
        for k=1:length(udat{1})
           if(~isgraphics(udat{1}))
               ikill(k)=1;
           end
        end
        udat{1}(ikill)=[];
        udat{1}=[udat{1} hinfo];
    else
        udat={hinfo udat};
    end
    set(hthisfig,'userdata',udat);
end
end

%% start of functions

function show2dspectrum(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
pos=get(hmasterfig,'position');
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
fmax=.25/(t(2)-t(1));
haxe=get(hi,'parent');
if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        hresults=findobj(hmasterfig,'tag','results');
        idata=get(hresults,'value');
        dnames=get(hresults,'string');
        dname=dnames{idata};
    end
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfk(seis,t,x,dname,fmax);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on')
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    hsane=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',hsane);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname);
end
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

enhancebutton(hfig,[.95,.920,.05,.025])
end

function showtvspectrum(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
%hi=findobj(hseis2,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
if(haxe==hseis2)
    hshort=findobj(hmasterfig,'tag','shortnames');
    ishort=hshort.Value;
    if(ishort)
        hshortresults=findobj(hmasterfig,'tag','shortresults');
        idata=get(hshortresults,'value');
        dnames=get(hshortresults,'string');
        dname=dnames{idata};
    else
        hresults=findobj(hmasterfig,'tag','results');
        idata=get(hresults,'value');
        dnames=get(hresults,'string');
        dname=dnames{idata};
    end
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplottvs(seis,t,x,dname,nan,nan);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    hsane=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',hsane);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    if(haxe==hseis2)
        set(hppt,'userdata',dnames{idata});
    else
        set(hppt,'userdata',dname);
    end
end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

enhancebutton(hfig,[.95,.920,.05,.025]);
end

function showfxamp(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis2=findobj(hmasterfig,'tag','seis2');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
hresults=findobj(gcf,'tag','results');
    idata=get(hresults,'value');
    dnames=get(hresults,'string');
if(haxe==hseis2)
    dname=dnames{idata};
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfx(seis,t,x,dname);
NEWFIGVIS='on';
colormap(datar{1},cmap)
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    hsane=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',hsane);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname);
end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

enhancebutton(hfig,[.95,.920,.05,.025]);
end

function showfxphase(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hseis2=findobj(hmasterfig,'tag','seis2');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
if(haxe==hseis2)
    hresults=findobj(gcf,'tag','results');
    idata=get(hresults,'value');
    dnames=get(hresults,'string');
    dname=dnames{idata};
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfx(seis,t,x,dname,nan,nan,nan,nan,1);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    hsane=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',hsane);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);

    set(hppt,'userdata',dname);
end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

enhancebutton(hfig,[.95,.920,.05,.025]);
end

function showtraces(~,~,flag)
hthisfig=gcf;
hseis1=findobj(hthisfig,'tag','seis1');
%get the data
hi=findobj(gca,'type','image');
x=get(hi,'xdata');
t=get(hi,'ydata');
seis=get(hi,'cdata');

dname=get(hthisfig,'name');

ind=strfind(dname,' for ');
dname2=dname(ind(1)+5:end);

%get current point
pt=seisplottraces('getlocation',flag);
ixnow=near(x,pt(1,1));

%determine pixels per second
un=get(gca,'units');
set(gca,'units','pixels');
pos=get(gca,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(gca,'units',un);

iuse=ixnow(1)-0:ixnow(1)+0;
% iuse=ixnow;
pos=get(hthisfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);

if(hseis1==gca)
    nametrace=[dname2 ' no filter'];
else
    nametrace=[dname2 ' after filter']; 
end

seisplottraces(double(seis(:,iuse)),t,x(iuse),nametrace,pixpersec);
hfig=gcf;
customizetoolbar(hfig);
if(fromenhance(hthisfig))
    seisplottraces('addpptbutton');
    pos2=get(hfig,'position');
    pos2(1)=xc-.5*pos2(3);
    pos2(2)=yc-.5*pos2(4);
    set(hfig,'position',pos2,'visible','on');
    set(hfig,'tag','fromenhance');
end

%register the figure
seisplottraces('register',hthisfig,hfig);

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.8,.930,.05,.025]);
    enhance('newview',hfig,hthisfig);
end

end

function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','enhance(''makepptslide'');');
%the title string will be stored as userdata
end

function fontchange(~,~)
hm=gcbo;
tag=hm.Label;
scalar=str2double(tag(2:end));
haxe=hm.UserData;
ht=haxe.Title;
fs=ht.UserData;
hresults=findobj(gcf,'tag','results');
if(isempty(fs))
    fs=hresults.FontSize;
    ht.UserData=fs;
end
hresults.FontSize=scalar*fs;
end

function retitle(~,~)
hresults=findobj(gcf,'tag','results');
iresult=hresults.Value;
names=hresults.String;
if(ischar(names))
    a=askthingsle('questions',{'New Title'},'answers',{names});
else
    a=askthingsle('questions',{'New Title'},'answers',names(iresult));
end
if(isempty(a))
    return;
else
    results=hresults.UserData;
    if(ischar(names))
        names=a{1};
        hresults.String=names;
        results.names{1}=names;
    else
        names{iresult}=a{1};
        hresults.String=names;
        results.names{iresult}=names{iresult};
    end
    hresults.UserData=results;
end
    
end

% function [N,xn,sigma,am,amax,amin]=getampinfo(data)
% % data ... input data
% %
% % 
% % N,xn ... histogram info for 500 levels 
% % sigma ... standard deviation of data
% % am ... mean of data
% % amax ... max of data
% % amin ... min of data
% 
% ind=data~=0;
% sigma=std(data(ind));
% am=mean(data(ind));
% amin=min(data(ind));
% amax=max(data(ind));
% [N,xn]=hist(data(ind),500); %#ok<HIST>
% 
% end
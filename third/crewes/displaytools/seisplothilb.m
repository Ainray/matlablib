function datar=seisplothilb(seis,t,x,dname)
% seisplothilb: examine time-variant Hilbert attributes
%
% datar=seisplothilb(seis,t,x,dname)
%
% A new figure is created and divided into two axes (side-by-side). The first axes shows the
% input seismic gather and the second shows the Hilbert attributes sections.
%
% seis ... 2D seismic matrix for which Hilbert attributes are desired
% t ... time coordinate vector for seis
% x ... space coordinate vector for seis
% dname ... text string nameing the first seismic matrix. Enter [] or '' for no name.
%
% datar ... Return data which is a length 2 cell array containing
%           datar{1} ... handle of the first seismic axes
%           datar{2} ... handle of the Hilbert attributes axis
% 
% G.F. Margrave, Margrave-Geo, 2020
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

%global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED %#ok<NUSED>
global NEWFIGVIS
if(~ischar(seis))
    action='init';
else
    action=seis;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match seismic matrix');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match seismic matrix');
    end
%     dt=t(2)-t(1);
%     fnyq=.5/dt;
%     fmax=.5*fnyq;
%     tfmax=mean(t);
    
    if(nargin<4)
        dname=[];
    end
%     if(nargin<5)
%         tinc=nan;
%     end
%     if(nargin<4)
%         twin=nan;
%     end
%     
%     if(isnan(twin))
%         twin=5*dt;
%     end
%     if(isnan(tinc))
%         tinc=max([twin/4 dt]);
%     end

    xwid=.375;
    xwid2=.375;
    yht=.8;
    xsep=.04;
%     xnot=.5*(1-xwid-xwid2-1.5*xsep);
    xnot=.11;
    ynot=.1;
    
    %test to see if we are from enhance. This enables the fromenhance local logical function to work
    ff=figs;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           %so the current figure is from enhance and we assume it hase called this one
           enhancetag='fromenhance';
           udat={-999.25,gcf};
       else
           enhancetag='';
           udat=[];
       end
    else
        enhancetag='';
        udat=[];
    end
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat)
    hax1=subplot('position',[xnot ynot xwid yht]);
        
    hi=imagesc(x,t,seis);
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap);
    brighten(.5);
    grid
    enTitle(dname,'interpreter','none')
    maxmeters=7000;
    if(max(t)<10)
        ylabel('time (s)')
    elseif(max(t)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    if(max(x)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    %make a clip control
    wid=.055;ht=.05;
    htclip=2*ht;
    xnow=xnot-1.85*wid;
    ynow=ynot+yht-htclip;
    %make a clip control
    climxt=[-3 3];
    hclip1=uipanel(hfig,'position',[xnow,ynow,1.45*wid,htclip],'tag','clip1',...
        'userdata',{climxt,hax1},'title','Clipping');
    data={climxt,hax1};
    callback='';
    cliptool(hclip1,data,callback);
    hfig.CurrentAxes=hax1;
    
    %make a help button
    ynow=ynot+yht;
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+1.0*ht,.5*wid,.5*ht],'callback','seisplothilb(''info'');',...
        'backgroundcolor','y');
    
    %the hide seismic button
    xnow=xnot;
    uicontrol(hfig,'style','pushbutton','string','Hide seismic','tag','hideshow','units','normalized',...
        'position',[xnow,ynow+ht,wid,.5*ht],'callback','seisplothilb(''hideshow'');','userdata','hide');
    %the toggle button
    ynow=ynow+.5*ht;
    uicontrol(hfig,'style','pushbutton','string','Toggle','tag','toggle','units','normalized',...
        'position',[xnow,ynow,wid,.5*ht],'callback','seisplothilb(''toggle'');','visible','off');
    %aec controls
    uicontrol(hfig,'style','pushbutton','string','Apply AGC:','tag','appagc','units','normalized','position',...
        [xnot-wid,ynow+.5*ht,wid,.5*ht],'callback','seisplothilb(''agc'');',...
        'tooltipstring','Push to apply Automatic gain correction','userdata',0);
    %the userdata of the above is the operator length of the actually applied agc
    uicontrol(hfig,'style','edit','string','0','tag','agc','units','normalized','position',...
        [xnot-wid,ynow,wid,.5*ht],'tooltipstring','Define an operator length in seconds (0 means no AGC)',...
        'userdata',{seis,t},'callback','seisplothilb(''agc'');');
    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid2 yht]);
    set(hax2,'tag','seishilb');
%     [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seissd);
    
    
    
    %make a clip control
    sep=.005;
    xnow=xnot+2*xwid+xsep+sep;
%     ht=.05;
%     ynow=ynot+yht-1.5*ht;
    %make a clip control
%     xnow=xnot+xwid+xwid2+xwid3+2*xsep+.1*wid;
    wid=.055;ht=.05;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    hclip2=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip2',...
        'userdata',{[],hax2,[],[],[],[],[]},'title','Clipping');
    %first entry in userdata is the current clim, entries 3,4,5,6,7 are the defaults for new results
    %for amp,phs,freq,bw,Q. These are calculated in 'apply'
    data={[0 100],hax2,1,0,1,1};
    callback='seisplothilb(''clip2'');';
    %cliptool is called later
    hfig.CurrentAxes=hax2;
    
    %temporal averaging parameters
    ht=.025;wid=.04;
    ynow=ynow-ht-3*sep;
    wfact=.5;
    nudge=.25*ht;
    uicontrol(hfig,'style','text','string','Smo:','units','normalized',...
        'position',[xnow,ynow-nudge,wfact*wid,ht],'tooltipstring','Smoother is a moving average with this window shape');
    uicontrol(hfig,'style','popupmenu','string',{'Boxcar','Triangle'},'units','normalized',...
        'position',[xnow+wfact*wid+sep,ynow,wid,ht],'value',1,'tag','smoother');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Tsmo:','units','normalized',...
        'position',[xnow,ynow-nudge,wfact*wid,ht],'tooltipstring','length of temporal smoother in seconds');
    uicontrol(hfig,'style','edit','string','0.01','tag','tsmo','units','normalized',...
        'position',[xnow+wfact*wid+sep,ynow,wid,ht],'callback',@checktsmo,'tooltipstring',...
        'Enter a nonnegative number, values greater than 1 treated as milliseconds');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Compute Fdom','units','normalized',...
        'position',[xnow+.25*wid,ynow,1.4*wid,ht],'callback','seisplothilb(''apply'');',...
        'tooltipstring','Apply current fdom specs','backgroundcolor','y');
    %controls to choose the Hilbert attributes display section 
    ynow=ynow-5*ht-4*sep;
    hbg=uibuttongroup('position',[xnow,ynow,2*wid,5*ht],'title','Display choice:','tag','choices',...
        'selectionchangedfcn','seisplothilb(''choice'');','userdata',2);%user data indicates display choice 
    ww=1;
    hh=.2;
    uicontrol(hbg,'style','radiobutton','string','Amplitude','units','normalized','tag','amp',...
        'position',[0,4*hh,ww,hh],'value',0,'tooltipstring','Display instantaneous amplitude');
    uicontrol(hbg,'style','radiobutton','string','Phase','units','normalized','tag','phs',...
        'position',[0,3*hh,ww,hh],'value',1,'tooltipstring','Display instantaneous phase');
    uicontrol(hbg,'style','radiobutton','string','Frequency','units','normalized','tag','freq',...
        'position',[0,2*hh,ww,hh],'value',0,'tooltipstring','Display instantaneous frequency');
    uicontrol(hbg,'style','radiobutton','string','Bandwidth','units','normalized','tag','bw',...
        'position',[0,hh,ww,hh],'value',0,'tooltipstring','Display instantaneous bandwidth');
    uicontrol(hbg,'style','radiobutton','string','Q','units','normalized','tag','q',...
        'position',[0,0,ww,hh],'value',0,'tooltipstring','Display instantaneous Q');
 
    %colormaps
    ht=.025;
    ynow=ynow-9*ht;
%     wid=1.4*wid;
    poscolor=[xnow,ynow,2*wid,8*ht];
    cb1='';cb2='';
    cmapdefaults=cell(1,3);
    cmapdefaults{1}=enhance('getdefaultcolormap','sections');
    cmapdefaults{2}=enhance('getdefaultcolormap','frequencies');
    cmapdefaults{3}=enhance('getdefaultcolormap','ampspectra');
    cm1=cmapdefaults{1}{1};
    iflip1=cmapdefaults{1}{2};
    cm2=cmapdefaults{2}{1};
    iflip2=cmapdefaults{2}{2};
    cbflag=[1,1];
    cbcb='';
    cbaxe=[hax1 hax2];
    %enhancecolormaptool tool called later

    set(0,'currentfigure',hfig);%don't understand why this is necessary
    
    ynow=ynow-2*ht-sep;
    uicontrol(hfig,'style','text','string','Compute performace:','units','normalized',...
        'position',[xnow,ynow,2*wid,1.5*ht]);
    ynow=ynow-1.2*ht;
    uicontrol(hfig,'style','text','string','','units','normalized','tag','performance',...
        'position',[xnow,ynow,2*wid,ht]);
    
    
    %results popup
    pos=get(hax2,'position');
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
    xnowresults=xnow;
    widresults=.9*wid;
    ynowresults=ynow;
    uicontrol(hfig,'style','popupmenu','string','Diddley','units','normalized','tag','results',...
        'position',[xnowresults,ynowresults,widresults,ht],'callback','seisplothilb(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm);
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(hfig,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid .3*ht],'tag','1like2','callback','seisplothilb(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid .3*ht],'tag','2like1','callback','seisplothilb(''equalzoom'');');
    
    %right-click message
    wmsg=.2;
    xmsg=xnot+xwid+.5*xsep-.5*wmsg;
    annotation(hfig,'textbox','string','Right-click on any image for analysis tools',...
        'position',[xmsg,.955,wmsg,.05],'linestyle','none','fontsize',7,'color','r','fontweight','bold');
    
    %delete button
    wid=.06;
    ht=ht/3;
    %userdata of the delete button is the number of the current selection
    uicontrol(hfig,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnowresults+widresults+sep,ynowresults+1.75*ht,wid,ht],'callback','seisplothilb(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    %fire up clip tool
    cliptool(hclip2,data,callback);
    %compute the fdom
    seisplothilb('apply');
    hcpan=enhancecolormaptool(hfig,poscolor,hax1,hax2,cb1,cb2,cm1,cm2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    set(hcpan,'userdata',cmapdefaults);

    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.4,1); %enlarge the fonts in the figure
%     whitefig;
    
   
    set(hfig,'name',['Hilbert attributes for ' dname],'closerequestfcn','seisplothilb(''close'');');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
%     colormap(cmap)
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    msg0={'Dominant Frequency',{['Most geophysicists are well acquainted with the concept of the ',...
        'frequency spectrum but, when asked to define "dominant frequency" most will say it''s the ',...
        'frequency of the maximum peak in the spectrum. That certainly is an important element of the spectrum but the ',...
        'dominant frequency actually has a more specific mathematical definition. Let "f" denote ',...
        'frequency and "A(f)" or just "A" denote the amplitude spectrum. Then the dominant frequency is defined as ',...
        'fdom=sum(f*A^2)/sum(A^2). Let''s dissect that cryptic formula. The word "sum" simply means add up ',...
        'possible values. Since we are speaking of the spectrum of sampled data, then this is a sum ',...
        'from 0 Hz to the Nyquist frequency. The denominator of the formula, sum(A^2) means sum up the ',...
        'squared values of the amplitude spectrum (you might know that A^2 is also called the power ',...
        'spectrum). Then the numerator, sum(f*A^2), means sum up the product of f times A^2. This can ',...
        'be viewed as forming a weighted average of "f" where the weights are A^2. The denominator of ',...
        'the formula is just what is needed to ensure we get a weighted average in Hertz. '],' ',...
        ['There is some arbitrariness in the formula. Why use A^2? Why not A" or A^3?. Numerical experiments ',...
        'performed on synthetic data have led to a preference for A^2 because it most often agrees with ',...
        'intuition. Imagine a synthetic trace with a Ricker wavelet and additive noise. The Ricker means ',...
        'that the spectrum (when smoothed) will have a single peak and we would like that fdom comes close to choosing ',...
        'this peak. Any of the 3 mentioned weights (A,A^2,and A^3) work well without noise but with ',...
        'reasonable noise levels, A^2 seems to work better. This is still a subjective choice ',...
        'but it is what this software does. '],' ',...
        ['To compute an entire section of dominant frequency values, a Gabor transform can be used. This ',...
        'is just a Fourier transform computed repeatedly in a moving temporal window. This window is ',... 
        'a Gaussian whose half-width is the parameter "Twin" seen at the far right. For definiteness, '...
        'suppose Twin is 10ms and the window is initially centered at t=0. The product of window and trace ',...
        'selects the samples at the beginning of the trace and the corresponding spectrum is "local" to ',...
        'to that time. Now increment the window by say 2 samples (4ms for most data) compute the spectrum ',...
        'again. Repeat this process until a local spectrum has been defined for every 4ms along the entire ',...
        'trace. Then use these local spectra to compute the dominate frequency and, repeating this for every trace, we have an fdom section. '],...
        ' ',['The samples of an fdom section are values in Hertz and give the local dominant frequency at ',...
        'each position. An fdom section is not very sensitive to the amplitude balancing of the dataset ',...
        'because the definition of fdom has A^2 contributing equally in numerator and denominator. When ',...
        'Twin is chosen quite small, perhaps 3 to 5 samples, then the fdom section shows a great deal ',...
        'of stratigraphic influence. This can be thought of as a generalized way to examine tuning. ',...
        'When the window is 10 to 20 times longer, then the stratigraphic information begins to be ',...
        'suppressed and the influences of attenuation, focussing, defocussing, and other wave propagation ',...
        'effects are seen. '],' ',['Two other related sections can be exmined here. The first is bandwidth ',...
        'and the second is amplitude. Bandwidth is defined as BW=sum(|f-fdom|*A^2)/sum(A^2) and is a measure ',...
        'of spectral width about fdom. (Here the vertical bars, |x|, mean the absolute value of x.) ',...
        'Amplitude, really dominant amplitude, is the actual spectral amplitude at the dominant frequency. ',...
        'Bandwidth sections tend to look a lot like fdom sections. Dominant amplitude sections tend to look like a ',...
        'frequency slice from a spectral decomposition, but rather than being a slice at a constant frequency, ',...
        'it is evaluated at the dominant frequency at each point.']}};
    msg1={'Tool window',{['The axes at left (the seismic axes) shows the ordinary sesimic, the axes at right ',...
        '(fdom axes) shows one of the three dominant frequency sections. At far left above the seismic axes is a ',...
        'button labelled "Hide seismic". Clicking this removes the seismic axes from the display ',...
        'allows the fdom axes to fill the window. This action also displays a new button labelled ',...
        '"Toggle" which allows the display to be switched back and forth between seismic and fdom. '],' ',...
        ['When both seismic and fdom are shown, there are two clipping controls, the left one being for the ',...
        'seismic and the right one being for the fdom. Feel free to adjust these. Smaller clip ',...
        'numbers mean greater clipping. Selecting "graphical" causes a small window to appear above .',...
        'the clipping control showing an amplitude histogram and two red vertical lines. (If you don''t ',...
        'see red lines, then right-click in the white space twice and select a position for the max amplitude ',...
        'line and the min amplitude line.) These lines define the extent of the colorbar. Click and drag either ',...
        'line and watch the amplitudes change. '],' ',...
        ['The parameters of the ',...
        'computation are shown at right. Hover the pointer over each one for instructions. After changing ',...
        'the parameters push the "Compute Fdom" button for a new calculation. There are three different dominant ',...
        'frequency sections, one called Frequency where the amplitudes are the value in Hz of the dominant ',...
        'frequency, another called Bandwidth where the amplitudes are the estimated spectral width in Hz ',...
        'centered on the dominant frequency, and the third called Amplitude where the amplitudes are the ',...
        'spectral amplitude at the dominant frequency. The radio buttons labelled "Display choice" ',...
        'allow you to choose between these. Of these three sections, the Amplitude section is most similar ',...
        'to normal seismic and is the same as evaluating a spectral decomp volume at the dominant frequency ',...
        '(as opposed to displaying a particular frequency in Hz).  However, unlike normal seismic, ',...
        'Amplitude refers to spectral amplitude and hence is never negative. Note that the colorbar ',...
        'always refers to the fdom axes and not the seismic.']}};
    hinfo=showinfo({msg0 msg1},'Instructions for Dominant Frequency tool',nan,[600,400]);
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        if(isgraphics(udat{1}))
            delete(udat{1});
        end
        udat{1}=hinfo;
    else
        if(isgraphics(udat))
            delete(udat);
        end
        udat=hinfo;
    end
    set(hthisfig,'userdata',udat);

elseif(strcmp(action,'setcolormap'))
    % call seisplothilb('setcolormap',axetag)
    %this is called when a section choice is made
    %the assigned colormap is determined by userdata of hcpan
    %If the axis is 'seis' then the section colormap is default. If the axis is 'seishilb', then
    %the colormap depends on the selected button in hchoices
    hfig=gcf;
    hcpan=findobj(hfig,'tag','colorpanel');
    if(isempty(hcpan))%happens only on startup
        return;
    end
%     cmaps=hcpan.String;
    cmapchoices=hcpan.UserData;
    hchoices=findobj(gcf,'tag','choices');
    axetag=t;%second argument
    hax=findobj(hfig,'tag',axetag);
    if(strcmp(axetag,'seis'))
        cmapname=cmapchoices{1}{1};
        iflip=cmapchoices{1}{2};
    elseif(strcmp(hchoices.SelectedObject.String,'Amplitude'))
        cmapname=cmapchoices{3}{1};
        iflip=cmapchoices{3}{2};
    else
        cmapname=cmapchoices{2}{1};
        iflip=cmapchoices{2}{2};
    end
    enhancecolormaptool('setcmap',hax,cmapname,iflip);

elseif(strcmp(action,'clip2'))
    %if 'clip2' then we have changed clipping but not the image data
    hmasterfig=gcf;
    
    hclip=findobj(hmasterfig,'tag','clip2');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    udat{1}=clim;

    hresults=findobj(hmasterfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults','value');
    choice=nowshowing;
    if(~isempty(results))
        switch choice
            case 'freq'
                results.climfreq{iresult}=clim;
            case 'bw'
                results.climbw{iresult}=clim;
            case 'amp'
                results.climamp{iresult}=clim;
            case 'phs'
                results.climphs{iresult}=clim;
            case 'Q'
                results.climQ{iresult}=clim;
        end
        set(hresults,'userdata',results);
    end

    hclip.UserData=udat;
elseif(strcmp(action,'choice'))
    hmasterfig=gcf;
    hchoice=findobj(hmasterfig,'tag','choices');
    hresults=findobj(hmasterfig,'tag','results');
%     hcpan=findobj(hmasterfig,'tag','colorpanel');
%     h21=findobj(hmasterfig,'tag','2like1');
    choice=nowshowing;
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hseis2=findobj(hmasterfig,'tag','seishilb');
    hi=findobj(hseis2,'type','image');
    hclip2=findobj(hmasterfig,'tag','clip2');
    ud=get(hclip2,'userdata');
    switch choice
        case 'amp'
            set(hi,'cdata',results.amp{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','aspec')]);
            clim=results.climamp{iresult};
            climdata={clim,hseis2,[],0,1,1};
            set(hchoice,'userdata',1)
        case 'phs'
            set(hi,'cdata',results.phs{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
            clim=results.climphs{iresult};
            climdata={clim,hseis2,1,1,1,1};
            set(hchoice,'userdata',2)
        case 'freq'
            set(hi,'cdata',results.freq{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
            clim=results.climfreq{iresult};
            climdata={clim,hseis2,1,0,1,1};
            set(hchoice,'userdata',3)
        case 'bw'
            set(hi,'cdata',results.bw{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
            clim=results.climbw{iresult};
            climdata={clim,hseis2,1,0,1,1};
            set(hchoice,'userdata',4)
        case 'q'
            set(hi,'cdata',results.Q{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
            clim=results.climQ{iresult};
            climdata={clim,hseis2,1,0,1,1};
            set(hchoice,'userdata',5)
    end
    ud{1}=clim;
    cliptool('refresh',hclip2,climdata);
    hclip2.UserData=ud;
    set(hresults,'userdata',results);
    seisplothilb('setcolormap','seishilb');
%     seisplothilb('clip2fromchoice');

elseif(strcmp(action,'equalzoom'))
    hbut=gcbo;
    hseis=findobj(gcf,'tag','seis');
    hseissd=findobj(gcf,'tag','seishilb');
    tag=get(hbut,'tag');
    switch tag
        case '1like2'
            xl=get(hseissd,'xlim');
            yl=get(hseissd,'ylim');
            set(hseis,'xlim',xl,'ylim',yl);
            
        case '2like1'
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            set(hseissd,'xlim',xl,'ylim',yl);
    end
    
elseif(strcmp(action,'close'))
    hfig=gcf;
    haveamp=findobj(hfig,'tag','aveamp');
    hspec=get(haveamp,'userdata');
    if(isgraphics(hspec))
        delete(hspec);
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
elseif(strcmp(action,'hideshow'))
    enhancecolormaptool('colorbarsoff');
    hbut=gcbo;
    option=get(hbut,'userdata');
    hclip1=findobj(gcf,'tag','clip1');
%     udat1=get(hclip1,'userdata');
    hax1=findobj(gcf,'tag','seis');
    hclip2=findobj(gcf,'tag','clip2');
    %udat2=get(hclip2,'userdata');
    hax2=findobj(gcf,'tag','seishilb');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    htoggle=findobj(gcf,'tag','toggle');
    
    switch option
        case 'hide'
            enhancecolormaptool('colorbarsoff');drawnow
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
            set(hbut,'string','Show seismic','userdata','show')
            set(htoggle,'visible','on');
        case 'show'
            udat=get(htoggle,'userdata');
            pos1=udat{1};
            pos2=udat{2};
            set(hax1,'visible','on','position',pos1);
            set([hi1 hclip1],'visible','on');
            set(hax2,'visible','on','position',pos2);
            set(htoggle','visible','off')
            set(hbut,'string','Hide seismic','userdata','hide');
            set([hi2 hclip2],'visible','on');
    end
elseif(strcmp(action,'toggle'))
    hfig=gcf;
    hclip1=findobj(hfig,'tag','clip1');
%     udat1=get(hclip1,'userdata');
    hax1=findobj(hfig,'tag','seis');
%     hclip2=findobj(hfig,'tag','clip2');
%     udat2=get(hclip2,'userdata');
    hax2=findobj(hfig,'tag','seishilb');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    set(hclip1,'visible','off');
    option=get(hax1,'visible');
    switch option
        case 'off'
            %ok, turning on seismic
            xl=hax2.XLim;
            yl=hax2.YLim;
            hax1.XLim=xl;
            hax1.YLim=yl;
           
            set([hax1 hi1],'visible','on');
            set([hax2 hi2],'visible','off');
            hfig.CurrentAxes=hax1;
        case 'on'
            %ok, turning off seismic
            xl=hax1.XLim;
            yl=hax1.YLim;
            hax2.XLim=xl;
            hax2.YLim=yl;
            set([hax1 hi1],'visible','off');
            set([hax2 hi2],'visible','on');
            hfig.CurrentAxes=hax2;
    end
elseif(strcmp(action,'apply'))
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis');
    hseis2=findobj(hfig,'tag','seishilb');
    hclip2=findobj(hfig,'tag','clip2');
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    hi1=findobj(hseis,'type','image');
    
    seis=get(hi1,'cdata');
    t=get(hi1,'ydata');
    x=get(hi1,'xdata');
    xname=get(get(hseis,'xlabel'),'string');
    yname=get(get(hseis,'ylabel'),'string');
    %smoother length
    htsmo=findobj(hfig,'tag','tsmo');
    val=get(htsmo,'string');
    tsmo=str2double(val);
    if(isnan(tsmo))
        msgbox('Tsmo is not recognized as a number','Oh oh ...');
        return;
    end
    if(tsmo>=1)
        tsmo=tsmo/1000;
        htsmo.String=num2str(tsmo);
    end
    if(tsmo<0 || tsmo>1)
        msgbox('Tsmo must be greater than 0 and less than 1','Oh oh ...');
        return;
    end
    
    %smoother type
    hsmo=findobj(hfig,'tag','smoother');
    smoother=hsmo.Value;%1 boxcar, 2 triangle
    
    t1=clock;
    attrs=hilbertattrs(seis,t);
    amp=attrs{1};
    phs=attrs{2};
    freq=attrs{3};
    bw=attrs{4};
    if(tsmo>0)
        freq=smooth(freq,t,tsmo,smoother);
        bw=smooth(bw,t,tsmo,smoother);
%         Q=smooth(Q,t,tsmo,smoother);
    end
    Q=2*pi*freq./bw;
    t2=clock;
    timepertrace=round(100000*etime(t2,t1)/size(seis,2))/1000;
    hperf=findobj(hfig,'tag','performance');
    set(hperf,'string',[num2str(timepertrace) ' ms/trace'])
    %create clip info
    %iclip=get(hclip2,'value');
    udat=get(hclip2,'userdata');
    climamp=udat{3};
    climphs=udat{4};
    climfreq=udat{5};
    climbw=udat{6};
    climQ=udat{7};

    %update display
    choice=nowshowing;%the attribute currently displayed
    hi=findobj(hseis2,'type','image');
    if(isempty(hi))
        fnyq=.5/(t(2)-t(1));
        %then we are doing it the first time
        climamp=[0 4];
        climphs=[-pi pi];
        climfreq=[0 .6*fnyq];
        climbw=[0 .6*fnyq];
        climQ=[0 200];
        udat{3}=climamp;
        udat{4}=climphs;
        udat{5}=climfreq;
        udat{6}=climbw;
        udat{7}=climQ;
%         axes(hseis2);
        set(hfig,'currentaxes',hseis2);
        switch choice
            case 'amp'
                hi=imagesc(hseis2,x,t,amp);
                udat{1}=climamp;
                clipdata={climamp,hseis2,[],0,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'phs'
                hi=imagesc(hseis2,x,t,phs);
                udat{1}=climphs;
                clipdata={climphs,hseis2,1,1,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'freq'
                hi=imagesc(hseis2,x,t,freq);
                udat{1}=climfreq;
                clipdata={climfreq,hseis2,1,0,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'bw'
                hi=imagesc(hseis2,x,t,bw);
                udat{1}=climbw;
                clipdata={climbw,hseis2,1,0,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'q'
                hi=imagesc(hseis2,x,t,Q);
                udat{1}=climQ;
                clipdata={climQ,hseis2,1,0,1,1};
                cliptool('refresh',hclip2,clipdata);
        end
%         hfig.CurrentAxes=hseis2;
        xlabel(xname);ylabel(yname);
        set(hseis2,'tag','seishilb');
        hcm=uicontextmenu(hfig);
        hti=uimenu(hcm,'label','Trace Inspector');
        uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
        uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
        uimenu(hcm,'label','Compare tool','callback',@comparetool);
        set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap);
    else
        
        switch choice
            case 'amp'
                set(hi,'cdata',amp,'userdata',[Spaceflag('get','x,t') Dataflag('get','aspec')]);
                udat{1}=climamp;
                clipdata={climamp,hseis2,[],0,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'phs'
                set(hi,'cdata',phs,'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
                udat{1}=climphs;
                clipdata={climphs,hseis2,1,1,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'freq'
                set(hi,'cdata',freq,'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
                udat{1}=climfreq;
                clipdata={climfreq,hseis2,1,0,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'bw'
                set(hi,'cdata',bw,'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
                udat{1}=climbw;
                clipdata={climbw,hseis2,1,0,1,1};
                cliptool('refresh',hclip2,clipdata);
            case 'q'
                set(hi,'cdata',Q,'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
                udat{1}=climQ;
                clipdata={climQ,hseis2,1,0,1,1};
                cliptool('refresh',hclip2,clipdata);
        end
    end
    hclip2.UserData=udat;
    set(hfig,'currentaxes',hseis2);
    happagc=findobj(hfig,'tag','appagc');
    agcop=get(happagc,'userdata');
    smtype='boxcar';
    if(smoother==2)
        smtype='triangle';
    end
    if(tsmo>0)
        if(agcop>0)
            name=['Hilbert attributes ' smtype ' smoother, Tsmo= ' num2str(tsmo) ',  AGC ' num2str(agcop) ' s'];
        else
            name=['Hilbert attributes ' smtype ' smoother, Tsmo= ' num2str(tsmo) ',  NO AGC '];
        end
    else
        if(agcop>0)
            name=['Hilbert attributes, No Smoothing,  AGC ' num2str(agcop) ' s'];
        else
            name='Hilbert attributes, No Smoothing,  NO AGC ';
        end
    end
    
    %save the results and update hresults
    
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.amp={amp};
        results.phs={phs};
        results.freq={freq};
        results.bw={bw};
        results.Q={Q};
        results.tsmo={tsmo};
        results.smoother={smoother};
        results.climamp={climamp};
        results.climphs={climphs};
        results.climfreq={climfreq};
        results.climbw={climbw};
        results.climQ={climQ};
        results.agc={agcop};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.amp{nresults}=amp;
        results.phs{nresults}=phs;
        results.freq{nresults}=freq;
        results.bw{nresults}=bw;
        results.Q{nresults}=Q;
        results.tsmo{nresults}=tsmo;
        results.smoother{nresults}=smoother;
        results.climamp{nresults}=climamp;
        results.climphs{nresults}=climphs;
        results.climfreq{nresults}=climfreq;
        results.climbw{nresults}=climbw;
        results.climQ{nresults}=climQ;
        results.agc{nresults}=agcop;
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    seisplothilb('setcolormap','seishilb');
elseif(strcmp(action,'select'))
    hfig=gcf;
    hdelete=findobj(hfig,'tag','delete');
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    hseis2=findobj(hfig,'tag','seishilb');
    hi=findobj(hseis2,'type','image');
    hclip2=findobj(hfig,'tag','clip2');
    choice=nowshowing;
    ud=get(hclip2,'userdata');
    switch choice
        case 'amp'
            set(hi,'cdata',results.afd{iresult},'ydata',results.tfd{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','aspec')]);
            clim=results.climafd{iresult};
            climdata={clim,hseis2,[],0,1,1};
            
        case 'freq'
            set(hi,'cdata',results.fd{iresult},'ydata',results.tfd{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
            clim=results.climfd{iresult};
            climdata={clim,hseis2,1,0,1,1};    
        case 'bw'
            set(hi,'cdata',results.bwfd{iresult},'ydata',results.tfd{iresult},...
                'userdata',[Spaceflag('get','x,t') Dataflag('get','freq')]);
            clim=results.climbw{iresult};
            climdata={clim,hseis2,1,0,1,1};  
    end
    ud{1}=clim;
    hclip2.UserData=ud;
    cliptool('refresh',hclip2,climdata);
    htwin=findobj(hfig,'tag','twin');
    set(htwin,'string',num2str(results.twins{iresult}));
    htinc=findobj(hfig,'tag','tinc');
    set(htinc,'string',num2str(results.tincs{iresult}));
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(results.fmaxs{iresult}));
    htfmax=findobj(hfig,'tag','tfmax');
    set(htfmax,'string',num2str(results.tfmaxs{iresult})); 
    set(hresults,'userdata',results);
    %update hdelete userdata
    set(hdelete,'userdata',iresult);
elseif(strcmp(action,'delete'))
    hfig=gcf;
    hresults=findobj(hfig,'tag','results');
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
    seisplothilb('select');
elseif(strcmp(action,'agc'))
    hagc=findobj(gcf,'tag','agc');
    hseis=findobj(gcf,'tag','seis');
    udat=get(hagc,'userdata');
    seis=udat{1};
    t=udat{2};
    tmp=get(hagc,'string');
    oplen=str2double(tmp);
    if(isnan(oplen)||oplen<0||oplen>t(end))
        set(hagc,'string','0');
        msgbox(['Bad value for operator length. enter a value between 0 and ' num2str(t(end))]);
        return;
    end
    hi=findobj(hseis,'type','image');
    happagc=findobj(gcf,'tag','appagc');
    if(oplen==0)
        seis2=seis;
    else
        seis2=aec(seis,t(2)-t(1),oplen);
    end
    set(hi,'cdata',seis2);
    set(happagc,'userdata',oplen);
    hclip1=findobj(gcf,'tag','clip1');
    udat=get(hclip1,'userdata');
    clim=udat{1};
    clipdata={clim,hseis};
    cliptool('refresh',hclip1,clipdata);
end
end

%% functions

function showcolormap(~,~,hax)
if(nargin<3)
    hax=gca;
end
hfig=gcf;
if(ischar(hax))
    hax=findobj(hfig,'tag',hax);
end

enhancecolormaptool('showcolormap',hax);

end


function showtraces(~,~,flag)
hthisfig=gcf;
% fromenhance=false;
% if(strcmp(get(gcf,'tag'),'fromenhance'))
%     fromenhance=true;
% end
hseis1=findobj(hthisfig,'tag','seis');
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
hchoices=findobj(hthisfig,'tag','choices');
name2=hchoices.SelectedObject.String;
% switch choice
%     case 
%         name2=' Fdom Freq';
%     case 2
%         name2=' Fdom BW';
%     case 3
%         name2=' Fdom Amp';
% end
if(hseis1==gca)
    nametrace=[dname2 ' seismic'];
else
    nametrace=[dname2 '_FDOM_' name2]; 
end

seisplottraces(double(seis(:,iuse)),t,x(iuse),nametrace,pixpersec);
hfig=gcf;
customizetoolbar(hfig);
if(fromenhance(hthisfig))
    seisplottraces('addpptbutton');
    set(gcf,'tag','fromenhance');
    pos2=get(hfig,'position');
    pos2(1)=xc-.5*pos2(3);
    pos2(2)=yc-.5*pos2(4);
    set(hfig,'position',pos2,'visible','on');
end

%register the figure
seisplottraces('register',hthisfig,hfig);

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.8,.930,.05,.025]);
    enhance('newview',hfig,hthisfig);
end
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

function checktsmo(htsmo,~)
val=htsmo.String;
tsmo=str2double(val);
if(isnan(tsmo))
    msgbox('Tsmo is not recognized as a number','Oh oh ...');
    return;
end
if(tsmo>=1)
    tsmo=tsmo/1000;
    htsmo.String=num2str(tsmo);
end
if(tsmo<0 || tsmo>1)
    msgbox('Tsmo must be greater than 0 and less than 1','Oh oh ...');
    return;
end


end

function choice=nowshowing
hbg=findobj(gcf,'tag','choices');
choice=hbg.SelectedObject.Tag;
end

function sattr=smooth(sattr,t,tsmo,smo)
%build the smoother
dt=t(2)-t(1);
nsmo=2*floor(.5*tsmo/dt)+1;%force an odd number
if(smo==1)
    smo_op=ones(nsmo,1);
else
    n2=floor(nsmo/2)+1;
    smo_op=interp1([1 n2 nsmo],[0 1 0],1:nsmo);
end
ntr=size(sattr,2);
weight=sum(smo_op);
for k=1:ntr
   s=sattr(:,k);
   sattr(:,k)=convz(s,smo_op)/weight;
end
end
function datar=seisplotfkfilt(seis,t,x,dname,fmax,gridy,gridx,spaceflag)
% seisplotfkfilt: plots a seismic gather and its fk spectrum side-by-side
%
% datar=seisplotfkfilt(seis,t,x,dname,fmax,gridy,gridx,spaceflag)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The seismic
% gather is plotted as an image in the left-hand-side and its f-k transform (amplitude spectrum)
% is plotted as an image in the right-hand-side. Controls are provided to adjust the clipping
% and to brighten or darken the image plots. The data should be regularly sampled in both t and
% x. This can also be used to create the 2D spatial transform of a time slice, in which case, t
% becomes y the row coordinate (usually inline) of the slice.
%
% seis ... input seismic matrix
% t ... time coordinate vector for seis. This is the row coordinate of seis. 
% x ... space coordinate vector for seis
% dname ... text string giving a name for the dataset that will annotate
%       the plots.
% ************ default dname =[] ************
% fmax ... maximum frequency for initial display. (nan gets the default)
% ************ default = .5/(t(2)-t(1)) which is Nyquist ***********
% gridy ... grid spacing in the row direction in physical units.
% ************ default abs(t(2)-t(1)) ***********
% gridx ... grid spacing in the column direction in physical units.
% ************ default abs(x(2)-x(1)) ***********
% NOTE: gridy and gridx are useful when analyzing a time slice and the x and y coordinates are line
%       numbers. In this case the defaults for gridy and gridx will give unphysical values for
%       wavenumbers. This can be especially misleading if the x and y grid spacings are not equal
%       in physical units.
% spaceflag ... 0 means input is in (x,t) space, 1 means (x,z) space, 2 means (x,y) space, 3 means
%       (y,t) space
% ************ default 0 ***********
% 
%
% datar ... Return data which is a length 4 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the f-k axes
%           data{3} ... f coordinate vector for the spectrum
%           data{4} ... k coordinate vector for the spectrum
% These return data are provided to simplify plotting additional lines and
% text in either axes.
%
% 
% G.F. Margrave, Margrave-Geo, 2017-2019
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

% global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED
global NEWFIGVIS

if(~ischar(seis))
    action='init';
else
    action=seis;
end

if(isdeployed)
    action2='normal';
else
    action2='normal';
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match seismic');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match seismic');
    end
    fmaxfactors=[1,.5,.333,.25];%possible fmax limits as fractions of Fnyq
    if(nargin<4)
        dname=[];
    end
    if(nargin<5)
        fmax=nan;
    end
    if(nargin<6)
        gridy=abs(t(2)-t(1));
    end
    if(nargin<7)
        gridx=abs(x(2)-x(1));
    end
    if(nargin<8)
        spaceflag=0;
    end
    if(isnan(fmax))
        fmax=fmaxfactors(1)*.5/(t(2)-t(1));
    end
    fnyq=.5/gridy;
    iffactor=near(fmaxfactors*fnyq,fmax);
    fmax=fmaxfactors(iffactor)*fnyq;
    
    xwid=.35;
    yht=.75;
    xsep=.05;
    ysep=.01;
    xnot=.125;
    ynot=.1;
    
    %test to see if we are from enhance. This enables the fromenhance.m function to work
    ff=figs;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           %so the current figure is from enhance and we assume it hase called this one
           enhancetag='fromenhance';
           udat={[],gcf};
       else
           enhancetag='';
           udat=[];
       end
    end
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat);
    
    hax1=subplot('position',[xnot ynot xwid yht]);
    
    if(fromenhance)
       cmapdefaults1=enhance('getdefaultcolormap','sections');
       cmapdefaults2=enhance('getdefaultcolormap','ampspectra');
       cmapname1=cmapdefaults1{1};
       iflip1=cmapdefaults1{2};
       cmapname2=cmapdefaults2{1};
       iflip2=cmapdefaults2{2};
    else
       cmapname1='graygold';
       cmapname2='blueblack'; 
       iflip1=0;
       iflip2=1;
    end
        
    hi=imagesc(x,t,seis);
    grid
    
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    switch spaceflag
        case 0
            htitl=enTitle({dname ,['Input x-t space dx=' num2str(gridx) ', dt=' num2str(gridy)]},'interpreter','none');
            uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
            uimenu(hcm,'label','f-x phase','callback',@showfxphase);
            uimenu(hcm,'label','f-x amp','callback',@showfxamp);
        case 1
            htitl=enTitle({dname ,['Input x-z space dx=' num2str(gridx) ', dz=' num2str(gridy)]},'interpreter','none');
            uimenu(hcm,'label','Depth-variant spectra','callback',@showtvspectrum);
            uimenu(hcm,'label','f-x phase','callback',@showfxphase);
            uimenu(hcm,'label','f-x amp','callback',@showfxamp);
        case 2
            htitl=enTitle({dname ,['Input x-y space dx=' num2str(gridx) ', dy=' num2str(gridy)]},'interpreter','none');
        case 3
            htitl=enTitle({dname ,['Input y-t space dy=' num2str(gridx) ', dt=' num2str(gridy)]},'interpreter','none');
            uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
            uimenu(hcm,'label','f-x phase','callback',@showfxphase);
            uimenu(hcm,'label','f-x amp','callback',@showfxamp);
    end
    set(hi,'uicontextmenu',hcm);
    
    if(length(dname)>80)
        fs=12;
    else
        fs=12;
    end
    htitl.Interpreter='none';
    htitl.FontSize=fs;
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
    
    %right-click message
    annotation(hfig,'textbox','string','Right-click on either image for analysis tools.',...
        'position',[.41,.92,.2,.02],'linestyle','none','fontsize',8,'color','r','fontweight','bold');
    
    %make a clip control
    pctfk=5;
    wid=.04;ht=.05;sep=.005;
%     nudge=.1*wid;
    htclip=2*ht;
    xnow=xnot-3*wid;
    ynow=ynot+yht-htclip;
    %make a clip control
    climxt=[-3 3];
    hclip1=uipanel(hfig,'position',[xnow,ynow,2.5*wid,htclip],'tag','climxt',...
        'userdata',{climxt,hax1,pctfk,fmax,gridx,gridy,spaceflag},'title','Clipping');
    data={climxt,hax1};
    callback='seisplotfkfilt(''climxt'');';
    cliptool(hclip1,data,callback);
    hfig.CurrentAxes=hax1;
    %colormap control
    ynow=ynow-4.5*ht;
    poscolormap=[xnow+.5*wid,ynow,1.5*wid,4*ht];
    inonzero=seis~=0;
    am=mean(seis(inonzero));
    sigma=std(seis(inonzero));
    amax=max(seis(inonzero));
    amin=min(seis(inonzero));
    sampinfo={am,sigma,amax,amin};% $$$ check this
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,.95,.5*wid,.5*ht],'callback','seisplotfkfilt(''info'');',...
        'backgroundcolor','y');
    ht=.5*ht;
    %pick velocities button
    if(spaceflag==0 || spaceflag==3)
        buttitle='Pick velocities';
    else
        buttitle='Pick slopes';
    end
    uicontrol(hfig,'style','pushbutton','string',buttitle,'tag','pick','units','normalized',...
        'position',[xnow+3*wid,.95,2*wid,ht],'callback','seisplotfkfilt(''pick'');','userdata',buttitle);
    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);
    if(t(2)>t(1))
        tt=gridy*(0:length(t)-1)';
    else
        tt=gridy*(length(t)-1:-1:0)';
    end
    if(x(2)>x(1))
        xx=gridx*(0:length(x)-1);
    else
        xx=gridx*(length(x)-1:-1:0);
    end
    xmin=min(x);
    xmax=max(x);
    tmin=min(t);
    tmax=max(t);
    indx=near(x,xmin,xmax);
    indt=near(t,tmin,tmax);
    
    [seisfk,f,kx]=fktran(seis(indt,indx),tt(indt),xx(indx),nan,nan,pctfk);
    %     ind=near(f,0,fmax);
    Afk=abs(seisfk);

    am=mean(Afk(:));
    sigma=std(Afk(:));
    amax=max(Afk(:));
    amin=min(Afk(:));
    aampinfo={am,sigma,amax,amin};  
    
    hifk=imagesc(kx,f,Afk);
%     brighten(.5);
    
    grid
    knyq=max(abs(kx));
    fnyq=max(f);
    switch spaceflag
        case 0
            titstr=['Input kx-f space, kxnyq=' num2str(knyq) ', fnyq=' num2str(fnyq)];
            xlabel('kx wavenumber (m^{-1})');
            ylabel('frequency (Hz)');
        case 1
            titstr=['Input kx-kz space, kxnyq=' num2str(knyq) ', kznyq=' num2str(fnyq)];
            xlabel('kx wavenumber (m^{-1})');
            ylabel('kz wavenumber (m^{-1})');
        case 2
            titstr=['Input kx-ky space, kxnyq=' num2str(knyq) ', kynyq=' num2str(fnyq)];
            xlabel('kx wavenumber (m^{-1})');
            ylabel('ky wavenumber (m^{-1})');
        case 3
            titstr=['Input ky-f space, kynyq=' num2str(knyq) ', fnyq=' num2str(fnyq)];
            xlabel('ky wavenumber (m^{-1})');
            ylabel('frequency (Hz)');
    end
    
    %colormap control
    cb1='';cb2='';
    cbflag=[0,1];
    cbcb='';
    cbaxe=[hax1,hax2];
    enhancecolormaptool(hfig,poscolormap,hax1,hax2,cb1,cb2,cmapname1,cmapname2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    
    %results popup
    xnow=xnot+xwid+xsep;
    ynow=ynot+yht+ysep;
    fs=11;
    fontops={'x2','x1.5','x1.25','x1.11','x1','x0.9','x0.8','x0.67','x0.5'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange,'userdata',hax2);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
    hresults=uicontrol(hfig,'style','popupmenu','string',titstr,'units','normalized','tag','results',...
        'position',[xnow,ynow,xwid,2*ht],'callback','seisplotfkfilt(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm);
    %make the results structure
    climfk=[-2 18];%in sigma
    climdb=[-80 5];%in db
    results.seis{1}=seis;
    results.sampinfo{1}=sampinfo;
    results.Afk{1}=Afk;%not strictly necessary to store but makes toggleing quicker
    results.aampinfo{1}=aampinfo;
    results.mask{1}=ones(size(Afk(:)));
    results.name{1}=htitl.String;
    results.namefk{1}=titstr;
    results.t=t;
    results.x=x;
    results.f=f;
    results.k=kx;
    results.gridx=gridx;
    results.gridy=gridy;
    results.xx=xx;
    results.tt=tt;
    results.climxt{1}=climxt;
    results.climfk{1}=climfk;
    results.climdb{1}=climdb;

    %on with the GUI     
    
    %make a delete button
    xnow=xnow+xwid-2*wid;
    ynow=ynow+2*ht;
    uicontrol(hfig,'style','pushbutton','string','delete this result','tag','delete','units',...
        'normalized','position',[xnow,ynow,2*wid,ht],'callback','seisplotfkfilt(''delete'');');
    
    
    %make a clip control
    ht=.025;
    nudge=.1*wid;
    xnow=xnot+2*xwid+xsep+nudge;
    ynow=ynot+yht-htclip;
    
    pwid=2.8*wid;
    hclip=uipanel(hfig,'position',[xnow,ynow,pwid,htclip],'tag','climfk',...
        'userdata',{hax2,climfk,climdb},'title','Clipping');%the second and third entries in userdata
    %are clim settings for normal spectra and db spectra.
    data={climfk,hax2,[],0,0};
%     callback='seisplotdecon(''clip2'');';
    callback='seisplotfkfilt(''climfk'');';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax2;
%     uicontrol(hfig,'style','popupmenu','string',clipstr,'tag','climfk','units','normalized',...
%         'position',[xnow,ynow,1.5*wid,ht],'callback','seisplotfkfilt(''climfk'');','value',iclip,...
%         'userdata',{clips,am,sigma,amax,amin,hax2},'tooltipstring',...
%         'clip level is the number of standard deviations from the mean at which amplitudes are clipped');
    
    %make a uipanel for background color
    
    uipanel(hfig,'units','normalized','position',[xnow,ynow-5*ht,pwid,4.75*ht]);
    
    
    ynow=ynow-1.25*ht;
%     fs=10;
    ynudge=0;
    %decibels
    uicontrol(hfig,'style','radiobutton','string','Decibels','tag','decibels','value',0,...
        'units','normalized','position',[xnow ynow+ynudge pwid ht],...
        'callback','seisplotfkfilt(''recompute'');','backgroundcolor',.94*ones(1,3));
    ynow=ynow-ht;
    %Assign spaceflag dependent things
    switch spaceflag
        case 0
            xname='kx axis lims:';
            yname='f axis lims:';
            ifan=1;
            fanstr='Draw velocity fan';
        case 1
            xname='kx axis lims:';
            yname='kz axis lims:';
            ifan=0;
            fanstr='Draw slope fan';
        case 2
            xname='kx axis lims:';
            yname='ky axis lims:';
            ifan=0;
            fanstr='Draw slope fan';
        case 3
            xname='ky axis lims:';
            yname='f axis lims:';
            ifan=1;
            fanstr='Draw velocity fan';
    end
    %draw the fan
    hdraw=uicontrol(hfig,'style','radiobutton','string',fanstr,'tag','drawvfan','units','normalized',...
        'position',[xnow,ynow,pwid,ht],'callback','seisplotfkfilt(''drawvfan'');','value',ifan,...
        'userdata',{[],[],7,3,11,'none',.25,'r','r'},...%ud{1:2} are handles, ud{3}=nffan,ud{4}=nkfan,ud{5}=fs,ud{6}=bgkol,ud{7}=lw,ud{8}=kol,ud{9}=fontkol
        'tooltipstring','Draw lines of constant apparent velocity on the f-k transform');
    hcm=uicontextmenu;
    hf=uimenu(hcm,'label','Text label font size');
    uimenu(hf,'label','9','callback',@vfanfont);
    uimenu(hf,'label','10','callback',@vfanfont);
    uimenu(hf,'label','11','callback',@vfanfont);
    uimenu(hf,'label','12','callback',@vfanfont);
    uimenu(hf,'label','14','callback',@vfanfont);
    hbg=uimenu(hcm,'label','Text label background color');
    uimenu(hbg,'label','None','callback',@vfanbgc);
    uimenu(hbg,'label','White','callback',@vfanbgc);
    lims={'Nyq','Nyq/2','Nyq/3','Nyq/4'};
    set(hdraw,'uicontextmenu',hcm)
    xlimfactors=[1,.5,.333,.25]/(2*gridx);
    ylimfactors=fmaxfactors/(2*gridy);
    
    ynow=ynow-ht;
    %axis limits
    uicontrol(hfig,'style','text','string',xname,'units','normalized','position',...
        [xnow,ynow-.25*ht,1.25*wid,ht]);
    uicontrol(hfig,'style','popupmenu','string',lims,'units','normalized','position',...
        [xnow+1.25*wid,ynow,wid,ht],'callback','seisplotfkfilt(''lims'');','tag','xlim',...
        'userdata',xlimfactors,'tooltipstring','Limit the displayed wavenumber axis range');
    ynow=ynow-ht;
    uicontrol(hfig,'style','text','string',yname,'units','normalized','position',...
        [xnow,ynow-.25*ht,1.25*wid,ht]);
    uicontrol(hfig,'style','popupmenu','string',lims,'units','normalized','position',...
        [xnow+1.25*wid,ynow,wid,ht],'callback','seisplotfkfilt(''lims'');','tag','ylim',...
        'userdata',ylimfactors,'value',iffactor,'tooltipstring','Limit the displayed frequency axis range');
    %
    % tab group for filter panels
    %
    tabwid=pwid;
    tabht=.2;
    ynow=ynow-tabht-ysep;
    htg=uitabgroup(hfig,'position',[xnow,ynow,tabwid,tabht],'selectionchangedfcn','seisplotfkfilt(''filterchange'');');
    hfantab=uitab(htg,'title','Fan Filter','tag','fan');
    hgausstab=uitab(htg,'title','Gaussian Filter','tag','gaus');
    if(~ifan)
        htg.SelectedTab=hgausstab;
    end
    
    %fan filter params
    h=1/8;
    sy=h/7;
    sx=.05;
    xn=0;
    yn=1-h;
    w=.33;
    ny=.25*h;
    switch spaceflag
        case 0
            vmaxname='Vmax:';
            vmaxtts1='Maximum apparent velocity (absolute value) to reject,cannot be less than vmin.';
            vmaxtts2='Enter a nonnegative number in physical velocity units';
            vminname='Vmin:';
            vmintts1='Minimum apparent velocity to reject, 0 means no minimum.';
            vmintts2='Enter a nonnegative number in physical velocity units';
            dvname='dV:';
            dvtts1='Width of filter edge in velocity units.';
            dvtts2='Enter a nonnegative number in physical velocity units. 0 gets the default which is 20% of Vmax.';
            regionstring={'- velocity','+/- velocity','+ velocity'};
            xpadname='Xpad(%):';
            xpadtts1='Width of spatial zero pad as a percent of x axis size.';
            xpadtts2='Enter a nonnegative number in percent.';
            tpadname='Tpad(%):';
            tpadtts1='Width of temporal zero pad as a percent of t axis size.';
            tpadtts2='Enter a nonnegative number in percent.';
            sigmaxname='W_kx:';
            sigxtts1='Width of Gaussian in wavenumber, as a fraction of Nyquist';
            sigmayname='W_f:';
            sigytts1='Width of Gaussian in frequency, as a fraction of Nyquist';
            delkxname='Del_kx:';
            delkyname='Del_f:';
            delkxtts1='Size of smoothing boxcar in kx expressed as a fraction of Nyquist';
            delkytts1='Size of smoothing boxcar in f expressed as a fraction of Nyquist';
            cmenuvmax='Set maximum velocity';
            cmenuvmin='Set minimum velocity';
            cmenugaussx='Set Gaussian width in kx';
            cmenugaussy='Set Gaussian width in f';
        case 1
            vmaxname='Smax:';
            vmaxtts1='Maximum slope (dx/dz, absolute value) to reject,cannot be less than Smin.';
            vmaxtts2='Enter a nonnegative slope number';
            vminname='Smin:';
            vmintts1='Minimum slope (dx/dz, absolute value) to reject, 0 means no minimum.';
            vmintts2='Enter a nonnegative slope number';
            dvname='dS:';
            dvtts1='Width of filter edge in slope';
            dvtts2='Enter a nonnegative slope number. 0 gets the default which is 20% of Smax.';
            regionstring={'- slope','+/- slope','+ slope'};
            xpadname='Xpad(%):';
            xpadtts1='Width of spatial zero pad as a percent of x axis size.';
            xpadtts2='Enter a nonnegative number in percent.';
            tpadname='Zpad(%):';
            tpadtts1='Width of spatial zero pad as a percent of z axis size.';
            tpadtts2='Enter a nonnegative number in percent.';
            sigmaxname='W_kx:';
            sigxtts1='Width of Gaussian in kx wavenumber, as a fraction of Nyquist';
            sigmayname='W_kz:';
            sigytts1='Width of Gaussian in kz wavenumber, as a fraction of Nyquist';
            delkxname='Del_kx:';
            delkyname='Del_kz:';
            delkxtts1='Size of smoothing boxcar in kx expressed as a fraction of Nyquist';
            delkytts1='Size of smoothing boxcar in kz expressed as a fraction of Nyquist';
            cmenuvmax='Set maximum slope';
            cmenuvmin='Set minimum slope';
            cmenugaussx='Set Gaussian width in kx';
            cmenugaussy='Set Gaussian width in kz';
        case 2
            vmaxname='Smax:';
            vmaxtts1='Maximum slope (dx/dy, absolute value) to reject,cannot be less than Smin.';
            vmaxtts2='Enter a nonnegative slope number';
            vminname='Smin:';
            vmintts1='Minimum slope (dx/dy, absolute value) to reject, 0 means no minimum.';
            vmintts2='Enter a nonnegative slope number';
            dvname='dS:';
            dvtts1='Width of filter edge in slope';
            dvtts2='Enter a nonnegative slope number. 0 gets the default which is 20% of Smax.';
            regionstring={'- slope','+/- slope','+ slope'};
            xpadname='Xpad(%):';
            xpadtts1='Width of spatial zero pad as a percent of x axis size.';
            xpadtts2='Enter a nonnegative number in percent.';
            tpadname='Ypad(%):';
            tpadtts1='Width of spatial zero pad as a percent of y axis size.';
            tpadtts2='Enter a nonnegative number in percent.';
            sigmaxname='W_kx:';
            sigxtts1='Width of Gaussian in kx wavenumber, as a fraction of Nyquist';
            sigmayname='W_ky:';
            sigytts1='Width of Gaussian in ky wavenumber, as a fraction of Nyquist';
            delkxname='Del_kx:';
            delkyname='Del_ky:';
            delkxtts1='Size of smoothing boxcar in kx expressed as a fraction of Nyquist';
            delkytts1='Size of smoothing boxcar in ky expressed as a fraction of Nyquist';
            cmenuvmax='Set maximum slope';
            cmenuvmin='Set minimum slope';
            cmenugaussx='Set Gaussian width in kx';
            cmenugaussy='Set Gaussian width in ky';
        case 3
            vmaxname='Vmax:';
            vmaxtts1='Maximum apparent velocity (absolute value) to reject,cannot be less than vmin.';
            vmaxtts2='Enter a nonnegative number in physical velocity units';
            vminname='Vmin:';
            vmintts1='Minimum apparent velocity to reject, 0 means no minimum.';
            vmintts2='Enter a nonnegative number in physical velocity units';
            dvname='dV:';
            dvtts1='Width of filter edge in velocity units.';
            dvtts2='Enter a nonnegative number in physical velocity units. 0 gets the default which is 20% of Vmax.';
            regionstring={'- velocity','+/- velocity','+ velocity'};
            xpadname='Xpad(%):';
            xpadtts1='Width of spatial zero pad as a percent of y (horizontal) axis size.';
            xpadtts2='Enter a nonnegative number in percent.';
            tpadname='Tpad(%):';
            tpadtts1='Width of temporal zero pad as a percent of t axis size.';
            tpadtts2='Enter a nonnegative number in percent.';
            sigmaxname='W_ky:';
            sigxtts1='Width of Gaussian in wavenumber, as a fraction of Nyquist';
            sigmayname='W_f:';
            sigytts1='Width of Gaussian in frequency, as a fraction of Nyquist';
            delkxname='Del_ky:';
            delkyname='Del_f:';
            delkxtts1='Size of smoothing boxcar in ky expressed as a fraction of Nyquist';
            delkytts1='Size of smoothing boxcar in f expressed as a fraction of Nyquist';
            cmenuvmax='Set maximum velocity';
            cmenuvmin='Set minimum velocity';
            cmenugaussx='Set Gaussian width in ky';
            cmenugaussy='Set Gaussian width in f';
    end
    %set context menu on the fk image
    hcmfk=uicontextmenu;
    if(ifan)
        uimenu(hcmfk,'label',cmenuvmax,'callback',@setvmax);
        uimenu(hcmfk,'label',cmenuvmin,'callback',@setvmin);
    else
        uimenu(hcmfk,'label',cmenugaussx,'callback',@setsigmax);
        uimenu(hcmfk,'label',cmenugaussy,'callback',@setsigmay);
    end
    set(hifk,'uicontextmenu',hcmfk)
    
    %controls
    uicontrol(hfantab,'style','text','string',vmaxname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',vmaxtts1,'horizontalalignment','right','tag','vmax0');
    uicontrol(hfantab,'style','edit','string','0','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring',vmaxtts2,'tag','vmax','callback','seisplotfkfilt(''setvmax'');',...
        'userdata',{[],1,'r'});
    yn=yn-h-sy;
    uicontrol(hfantab,'style','text','string',vminname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',vmintts1,'horizontalalignment','right','tag','vmin0');
    uicontrol(hfantab,'style','edit','string','0','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring',vmintts2,'tag','vmin','callback','seisplotfkfilt(''setvmin'');',...
        'userdata',{[],1,'r'});
    yn=yn-h-sy;
    uicontrol(hfantab,'style','text','string',dvname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',dvtts1,'horizontalalignment','right','tag','dv0');
    uicontrol(hfantab,'style','edit','string','0','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring',dvtts2,'tag','dv');
    yn=yn-h-sy;
    uicontrol(hfantab,'style','text','string','Reject region:','units','normalized','position',[xn,yn-ny,1.4*w,h],...
        'tooltipstring','Filter can be applies to both sides (default) or either side.',...
        'horizontalalignment','right');
    uicontrol(hfantab,'style','popupmenu','string',regionstring,'units','normalized','position',...
        [xn+1.4*w+sx,yn,1.5*w,h],'tooltipstring','Choose a region.','tag','vflag','value',2);
    yn=yn-h-2*sy;
    uicontrol(hfantab,'style','text','string',xpadname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',xpadtts1,'horizontalalignment','right','tag','xpct0');
    uicontrol(hfantab,'style','edit','string','10','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring',xpadtts2,'tag','xpct');
    yn=yn-h-sy;
    uicontrol(hfantab,'style','text','string',tpadname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',tpadtts1,'horizontalalignment','right','tag','tpct0');
    uicontrol(hfantab,'style','edit','string','10','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring',tpadtts2,'tag','tpct');
    yn=yn-h-sy;
    uicontrol(hfantab,'style','pushbutton','string','Apply Fan Filter','units','normalized',...
        'position',[xn,yn,2*w,h],'tooltipstring','Apply the currently specified fan filter',...
        'tag','applyfan','callback','seisplotfkfilt(''applyfan'');');
    %gauss filter params
    yn=1-h;
    uicontrol(hgausstab,'style','text','string',sigmaxname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',sigxtts1,'horizontalalignment','right','tag','sigmax0');
    uicontrol(hgausstab,'style','edit','string','0.5','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring','Enter a number greater than zero','tag','sigmax',...
        'callback','seisplotfkfilt(''setsigmax'');','userdata',{[],1,'r'});
    yn=yn-h-sy;
    uicontrol(hgausstab,'style','text','string',sigmayname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',sigytts1,'horizontalalignment','right','tag','sigmay0');
    uicontrol(hgausstab,'style','edit','string','0.5','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring','Enter a number greater than zero','tag','sigmay',...
        'callback','seisplotfkfilt(''setsigmay'');','userdata',{[],1,'r'});
    yn=yn-h-sy;
    uicontrol(hgausstab,'style','radiobutton','string','Spatial whitening','tag','whiten',...
        'units','normalized','position',[xn,yn,2*w,h],'callback','seisplotfkfilt(''whiten'');',...
        'tooltipstring','Divide spectrum by its smoothed zero-phase self before the Gaussian filter');
    yn=yn-h-sy;
    uicontrol(hgausstab,'style','text','string',delkxname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',delkxtts1,'horizontalalignment','right','tag','delkx0','visible','off');
    uicontrol(hgausstab,'style','edit','string','0.05','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring','Enter a number greater than zero and less than 1','tag','delkx',...
        'callback','seisplotfkfilt(''setdelkx'');','visible','off');
    yn=yn-h-sy;
    uicontrol(hgausstab,'style','text','string',delkyname,'units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring',delkytts1,'horizontalalignment','right','tag','delky0','visible','off');
    uicontrol(hgausstab,'style','edit','string','0.05','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring','Enter a number greater than zero and less than 1','tag','delky',...
        'callback','seisplotfkfilt(''setdelky'');','visible','off');
    yn=yn-h-sy;
    uicontrol(hgausstab,'style','text','string','Stab:','units','normalized','position',[xn,yn-ny,w,h],...
        'tooltipstring','white noise constant to stabilize spectral division',...
        'horizontalalignment','right','tag','stab0','visible','off');
    uicontrol(hgausstab,'style','edit','string','0.1','units','normalized','position',[xn+w+sx,yn,w,h],...
        'tooltipstring','Enter a number greater than zero and less than 1','tag','stab',...
        'callback','seisplotfkfilt(''setstab'');','visible','off');
%     yn=yn-h-sy;
    uicontrol(hgausstab,'style','text','string','Growth or decay:','units','normalized','position',[xn,yn-ny,1.6*w,h],...
        'tooltipstring','Decay reduces noise and resolution, growth is the opposite',...
        'horizontalalignment','right','visible','off');
    uicontrol(hgausstab,'style','popupmenu','string',{'growth','decay'},...
        'units','normalized','position',[xn+1.6*w+sx,yn,1.2*w,h],...
        'tooltipstring','Choose one','tag','gflag','value',2,'visible','off');
    yn=yn-h-2*sy;
    uicontrol(hgausstab,'style','pushbutton','string','Apply Gaussian Filter','units','normalized',...
        'position',[xn,yn,2*w,h],'tooltipstring','Apply the currently specified Gaussian filter',...
        'tag','applygauss','callback','seisplotfkfilt(''applygauss'');');
    %toggle button
    ynow=ynow-ht-ysep;
    uicontrol(hfig,'style','pushbutton','string','Toggle Result <--> Input','tag','toggle','units',...
        'normalized','position',[xnow,ynow,pwid,ht],'callback','seisplotfkfilt(''toggle'');',...
        'tooltipstring','Toggle between the displayed result and the input');
    %toggle2 button
    ynow=ynow-ht-.5*ysep;
    uicontrol(hfig,'style','pushbutton','string','Toggle Result1 <--> Result2','tag','toggle2','units',...
        'normalized','position',[xnow,ynow,pwid,ht],'callback','seisplotfkfilt(''toggle2'');',...
        'tooltipstring','Select any result, then select any other result and press this button');
    ynow=ynow-ht-.5*sep;
    uicontrol(hfig,'style','pushbutton','string','Show Mask','tag','mask','units',...
        'normalized','position',[xnow,ynow,pwid,ht],'callback','seisplotfkfilt(''mask'');',...
        'tooltipstring','Select any result and press this button to see the filter mask');
    

    
    set(hax2,'tag','fk');
    seisplotfkfilt('drawvfan');
    results=saveparameters(results);
    set(hresults,'userdata',results);
    figure(hfig);
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
    boldlines(hax2,4,2); %make lines and symbols "fatter"
    whitefig;
    seisplotfkfilt('lims');
    
    if(ifan)
        xl=xlim;
        yl=ylim;
        pt=[xl(2),yl(2),1;xl(2),yl(2),-1];
        setvmax(1,1,pt);
    else
%         xl=xlim;
%         yl=ylim;
        pt=[knyq*.5,0,1;knyq*.5,0,-1];
        setsigmax(1,1,pt);
        pt=[0,fnyq*.5,1;0,fnyq*.5,-1];
        setsigmay(1,1,pt);
    end
    
    switch spaceflag
        case 0
            titstr=['f-kx filter analysis for ' dname];
        case 1
            titstr=['kx-kz filter analysis for ' dname];
        case 2
            titstr=['kx-ky filter analysis for ' dname];
        case 3
            titstr=['f-ky filter analysis for ' dname];
    end
    
    set(hfig,'name',titstr,'closerequestfcn','seisplotfkfilt(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,4);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=f;
        datar{4}=k;
    end

elseif(strcmp(action,'lims'))
    hfig=gcf;
    hax=findobj(hfig,'tag','fk');
%     axis(hax);
    hxlim=findobj(hfig,'tag','xlim');
    hylim=findobj(hfig,'tag','ylim');
    xval=get(hxlim,'value');
    yval=get(hylim,'value');
    xlimfactors=get(hxlim,'userdata');
    ylimfactors=get(hylim,'userdata');
    hax.XLim=[-xlimfactors(xval) xlimfactors(xval)];
    hax.YLim=[0 ylimfactors(yval)];
    seisplotfkfilt('drawvfan');
elseif(strcmp(action,'filterchange'))
    hfig=gcf;
    htg=findobj(hfig,'type','uitabgroup');
    htab=htg.SelectedTab;
    name=htab.Title;
    hdraw=findobj(hfig,'tag','drawvfan');
    hclip1=findobj(hfig,'tag','climxt');
    udat=hclip1.UserData;
    spaceflag=udat{7};
    hclip2=findobj(hfig,'tag','climfk');
    udat=hclip2.UserData;
    haxfk=udat{1};
    hifk=findobj(haxfk,'type','image');
    if(strcmp(name,'Fan Filter'))
        %switching to fan filter
        hdraw.Value=1;
        switch spaceflag
            case 0
                cmenuvmax='Set maximum velocity';
                cmenuvmin='Set minimum velocity';
            case 1
                cmenuvmax='Set maximum slope';
                cmenuvmin='Set minimum slope';
            case 2
                cmenuvmax='Set maximum slope';
                cmenuvmin='Set minimum slope';
            case 3
                cmenuvmax='Set maximum velocity';
                cmenuvmin='Set minimum velocity';
        end
        hcmfk=uicontextmenu;
        uimenu(hcmfk,'label',cmenuvmax,'callback',@setvmax);
        uimenu(hcmfk,'label',cmenuvmin,'callback',@setvmin);
        set(hifk,'uicontextmenu',hcmfk)
        
        setvmax;%plots the current line
        setvmin;%plots the current line
        
        %turn off Gauss filter lines
        hsigmax=findobj(hfig,'tag','sigmax');
        ud=get(hsigmax,'userdata');
        if(~isempty(ud))
            hh=ud{1};%is an array of graphics handles associated with sigmax
            if(~isempty(hh))
                if(isgraphics(hh))
                    delete(hh);
                end
            end
        end
        hsigmay=findobj(hfig,'tag','sigmay');
        ud=get(hsigmay,'userdata');
        if(~isempty(ud))
            hh=ud{1};%is an array of graphics handles associated with sigmay
            if(~isempty(hh))
                if(isgraphics(hh))
                    delete(hh);
                end
            end
        end
    else
        %switching to Gauss filter
        hdraw.Value=0;
        switch spaceflag
            case 0
                cmenugaussx='Set Gaussian width in kx';
                cmenugaussy='Set Gaussian width in f';
            case 1
                cmenugaussx='Set Gaussian width in kx';
                cmenugaussy='Set Gaussian width in kz';
            case 2
                cmenugaussx='Set Gaussian width in kx';
                cmenugaussy='Set Gaussian width in ky';
            case 3
                cmenugaussx='Set Gaussian width in ky';
                cmenugaussy='Set Gaussian width in f';
        end
        hcmfk=uicontextmenu;
        uimenu(hcmfk,'label',cmenugaussx,'callback',@setsigmax);
        uimenu(hcmfk,'label',cmenugaussy,'callback',@setsigmay);
        set(hifk,'uicontextmenu',hcmfk)
        
        setsigmax;
        setsigmay;
        
        %turn off any vmax,vmin lines
        hvmax=findobj(hfig,'tag','vmax');
        ud=get(hvmax,'userdata');
        if(~isempty(ud))
            hhv=ud{1};%is an array of graphics handles associated with vmax
            if(~isempty(hhv))
                if(isgraphics(hhv))
                    delete(hhv);
                end
            end
        end
        hvmin=findobj(hfig,'tag','vmin');
        ud=get(hvmin,'userdata');
        if(~isempty(ud))
            hhv=ud{1};%is an array of graphics handles associated with vmin
            if(~isempty(hhv))
                if(isgraphics(hhv))
                    delete(hhv);
                end
            end
        end
        
    end
    seisplotfkfilt('drawvfan');
elseif(strcmp(action,'drawvfan'))
    hfig=gcf;
    hdraw=findobj(hfig,'tag','drawvfan');
    hcm=hdraw.UIContextMenu;
    idraw=hdraw.Value;
    ud=hdraw.UserData;%{hv,ht,nffan,nkfan,fs,bgkol,lw,kolfontkol}
    if(~isempty(ud))
        if(~isempty(ud{1}))
            if(isgraphics(ud{1}(1)))
                delete(ud{1});
            end
        end
        if(~isempty(ud{2}))
            if(isgraphics(ud{2}(1)))
                delete(ud{2});
            end
        end
        nffan=ud{3};
        nkfan=ud{4};
        fs=ud{5};
        bgkol=ud{6};
        lw=ud{7};
        kol=ud{8};
        fontkol=ud{9};
%     else
%         nffan=7;%number of velocities intercepting f axis
%         nkfan=3;%number of velocities intercepting k axis
%         fs=11;
%         bgkol='none';
%         lw=.25;
%         kol='r';
%         fontkol='r';
    end
    if(idraw==0)
        ud{1}=[];
        set(hdraw,'userdata',ud);
        return;
    end
    hfkax=findobj(hfig,'tag','fk');
    hi=findobj(hfkax,'type','image');
    kx=hi.XData;
    f=hi.YData;
    knyq=max(kx);
    fnyq=max(f);
    %check for fnyq actually being a wavenumber. In this case it will be usually less than 1
    %So we determine a temporary scalar to boost it up to over 100
    if(log10(fnyq)<0)
       fscale=10^(round(log10(fnyq))+4);
       fnyq=fscale*fnyq;
    else
        fscale=1;
    end
    nv=nffan+nkfan;
    v=zeros(1,nv);
    hv=zeros(nv,2);
    ht=zeros(nv,2);
    delf=fnyq/(nffan+1);
    fc=zeros(1,nffan);
    ls=':';
    pos=get(hfkax,'position');
    yax=pos(4);
    xax=pos(3);
    axes(hfkax);
    xl=get(hfkax,'xlim');
    kmax=max(abs(xl));
    yl=get(hfkax,'ylim');
    fmax=max(yl);
    kv=0;
    for k=1:nffan
        kv=kv+1;
        fc(k)=k*delf;
        v(kv)=roundv(fc(k)/knyq)/fscale;
        fc(k)=v(kv)*knyq;
        hv(kv,1)=line([0 -knyq],[0 fc(k)],'linestyle',ls,'linewidth',lw,'color',kol);
        hv(kv,2)=line([0 knyq],[0 fc(k)],'linestyle',ls,'linewidth',lw,'color',kol);
        %annotate
        %get center of displayed line
        xm=kmax/2;
        ym=v(kv)*xm;
        if(ym>fmax/2)
            ym=fmax/2;
            xm=ym/v(kv);
        end
        %get angle
        dy=yax*ym/fmax;
        dx=xax*xm/kmax;
        theta=atand(dy/dx);
        
        ht(kv,1)=text(-xm,ym,num2str(-v(kv)),'rotation',theta,'color',fontkol,'fontsize',fs...
            ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
        ht(kv,2)=text(xm,ym,num2str(v(kv)),'rotation',-theta,'horizontalalignment','right',...
            'color',fontkol,'fontsize',fs,'backgroundcolor',bgkol,'uicontextmenu',hcm);
    end
    delk=knyq/(nkfan+1);
    kc=zeros(1,nkfan);
    for k=1:nkfan
        kv=kv+1;
        kc(k)=k*delk;
        v(kv)=roundv(fnyq/kc(k))/fscale;
        kc(k)=fnyq/v(kv);
        hv(kv,1)=line([0 -kc(k)],[0 fnyq],'linestyle',ls,'linewidth',lw,'color',kol);
        hv(kv,2)=line([0 kc(k)],[0 fnyq],'linestyle',ls,'linewidth',lw,'color',kol);
        %annotate
        %get center of displayed line
        ym=fmax/2;
        xm=ym/v(kv);
        %get angle
        dy=yax*ym/fmax;
        dx=xax*xm/kmax;
        theta=atand(dy/dx);
        
        ht(kv,1)=text(-xm,ym,num2str(-v(kv)),'rotation',theta,'color',fontkol,'fontsize',fs...
            ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
        ht(kv,2)=text(xm,ym,num2str(v(kv)),'rotation',-theta,'horizontalalignment','right',...
            'color',fontkol,'fontsize',fs,'backgroundcolor',bgkol,'uicontextmenu',hcm);
    end

    set(hdraw,'userdata',{hv,ht,nffan,nkfan,fs,bgkol,lw,kol,fontkol});
elseif(strcmp(action,'setvmax'))
    hfig=gcf;
    hvmax=findobj(hfig,'tag','vmax');
    hvmax0=findobj(hfig,'tag','vmax0');
    vmaxname=get(hvmax0,'string');
    hvmin=findobj(hfig,'tag','vmin');
    hvmin0=findobj(hfig,'tag','vmin0');
    vminname=get(hvmin0,'string');
    tmp=get(hvmax,'string');
    vmax=str2double(tmp);
    tmp=get(hvmin,'string');
    vmin=str2double(tmp);
    if(isnan(vmax))
        hm=msgbox([vmaxname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return
    end
    if(isnan(vmin))
        hm=msgbox([vminname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return
    end
    if(vmax<vmin)
        hm=msgbox([vmaxname(1:end-1) ' cannot be less than ' vminname(1:end-1)]);
        WinOnTop(hm,true);
%         hvmax.String=num2str(2*vmin);
%         drawnow;
%         seisplotfkfilt('setvmax');
        return
    end
    if(vmax<0)
        hm=msgbox([vmaxname(1:end-1) ' cannot be less than 0']);
        WinOnTop(hm,true);
        return
    end
    %make sure input data is displayed
    hresults=findobj(hfig,'tag','results');
    iresult=get(hresults,'value');
    if(iresult~=1)
        set(hresults,'value',1);
        seisplotfkfilt('selectNU');
    end
    %delete any existing vmax line
    ud=get(hvmax,'userdata');
    if(~isempty(ud))
        hhv=ud{1};%is an array of graphics handles associated with vmax
        if(~isempty(hhv))
            if(isgraphics(hhv))
                delete(hhv);
            end
        end
        lw=ud{2};
        kol=ud{3};
    end
    hdraw=findobj(hfig,'tag','drawvfan');
    hcm=hdraw.UIContextMenu;
    udd=get(hdraw,'userdata');
    bgkol='w';
    fontkol='k';
    fs=udd{5};
    hfkax=findobj(hfig,'tag','fk');
    axes(hfkax);
    pos=get(hfkax,'position');
    yax=pos(4);
    xax=pos(3);
    hi=findobj(hfkax,'type','image');
    k=hi.XData;
    f=hi.YData;
    knyq=max(k);
    fnyq=max(f);
    xl=get(hfkax,'xlim');
    kmax=max(abs(xl));
    yl=get(hfkax,'ylim');
    fmax=max(yl);
    hhv=nan*zeros(2,2);%velocity in row 1, text in row 2
    fc=vmax*knyq;
    hvflag=findobj(gcf,'tag','vflag');
    vflag=get(hvflag,'value');
    if(fc<fnyq)
        switch vflag
            case 1
                hhv(1,1)=line([0,-knyq],[0,fc],'color',kol,'linewidth',lw);
            case 2
                hhv(1,1)=line([0,-knyq],[0,fc],'color',kol,'linewidth',lw);
                hhv(1,2)=line([0,knyq],[0,fc],'color',kol,'linewidth',lw);
            case 3
                hhv(1,1)=line([0,knyq],[0,fc],'color',kol,'linewidth',lw);
        end
                
        %get line end
        xm=kmax;
        ym=vmax*xm;
%         if(ym>fmax/2)
%             ym=fmax/2;
%             xm=ym/vmax;
%         end
        %get angle
        dy=yax*ym/fmax;
        dx=xax*xm/kmax;
        theta=atand(dy/dx);
        switch vflag
            case 1
                hhv(2,1)=text(-xm,ym,1,['-vmax= ' num2str(-vmax)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
            case 2
                hhv(2,1)=text(-xm,ym,1,['-vmax= ' num2str(-vmax)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
                hhv(2,2)=text(xm,ym,1,['vmax= ' num2str(vmax)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
            case 3
                hhv(2,2)=text(xm,ym,1,['vmax= ' num2str(vmax)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
        end
    else
        kc=fnyq/vmax;
        switch vflag
            case 1
                hhv(1,1)=line([0,-kc],[0,fnyq],'color',kol,'linewidth',lw);
            case 2
                hhv(1,1)=line([0,-kc],[0,fnyq],'color',kol,'linewidth',lw);
                hhv(1,2)=line([0,kc],[0,fnyq],'color',kol,'linewidth',lw);
            case 3
                hhv(1,2)=line([0,kc],[0,fnyq],'color',kol,'linewidth',lw);
        end
        
        %get line end
        ym=fmax;
        xm=ym/vmax;
%         if(xm>fmax/2)
%             ym=fmax/2;
%             xm=ym/vmax;
%         end
        %get angle
        dy=yax*ym/fmax;
        dx=xax*xm/kmax;
        theta=atand(dy/dx);
        switch vflag
            case 1
                hhv(2,1)=text(-xm,ym,1,['-vmax= ' num2str(-vmax)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
            case 2
                hhv(2,1)=text(-xm,ym,1,['-vmax= ' num2str(-vmax)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
                hhv(2,2)=text(xm,ym,1,['vmax= ' num2str(vmax)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
            case 3
                hhv(2,2)=text(xm,ym,1,['vmax= ' num2str(vmax)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
        end
    end
    set(hvmax,'userdata',{hhv,lw,kol});
elseif(strcmp(action,'setvmin'))
    hfig=gcf;
    hvmax=findobj(hfig,'tag','vmax');
    hvmax0=findobj(hfig,'tag','vmax0');
    vmaxname=get(hvmax0,'string');
    hvmin=findobj(hfig,'tag','vmin');
    hvmin0=findobj(hfig,'tag','vmin0');
    vminname=get(hvmin0,'string');
    tmp=get(hvmax,'string');
    vmax=str2double(tmp);
    tmp=get(hvmin,'string');
    vmin=str2double(tmp);
    if(isnan(vmin))
        hm=msgbox([vminname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return
    end
    if(isnan(vmax))
        hm=msgbox([vmaxname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return
    end
    if(vmax<vmin)
        hm=msgbox([vmaxname(1:end-1) ' cannot be less than ' vminname(1:end-1)]);
        WinOnTop(hm,true);
        return
    end
    if(vmin<0)
        hm=msgbox([vminname(1:end-1) ' cannot be less than 0']);
        WinOnTop(hm,true);
        return
    end
    %make sure input data is displayed
    hresults=findobj(hfig,'tag','results');
    iresult=get(hresults,'value');
    if(iresult~=1)
        set(hresults,'value',1);
        seisplotfkfilt('selectNU');
    end
    %delete any existing vmin line
    ud=get(hvmin,'userdata');
    if(~isempty(ud))
        hhv=ud{1};%is an array of graphics handles associated with vmin
        if(~isempty(hhv))
            if(isgraphics(hhv))
                delete(hhv);
            end
        end
        lw=ud{2};
        kol=ud{3};
    end
    hdraw=findobj(hfig,'tag','drawvfan');
    hcm=hdraw.UIContextMenu;
    udd=get(hdraw,'userdata');
    bgkol='w';
    fontkol='k';
    fs=udd{5};
    hfkax=findobj(hfig,'tag','fk');
    axes(hfkax);
    pos=get(hfkax,'position');
    yax=pos(4);
    xax=pos(3);
    hi=findobj(hfkax,'type','image');
    k=hi.XData;
    f=hi.YData;
    knyq=max(k);
    fnyq=max(f);
    xl=get(hfkax,'xlim');
    kmax=max(abs(xl));
    yl=get(hfkax,'ylim');
    fmax=max(yl);
    hhv=nan*zeros(2,2);%velocity in row 1, text in row 2
    fc=vmin*knyq;
    hvflag=findobj(hfig,'tag','vflag');
    vflag=get(hvflag,'value');
    if(fc<fnyq)
        switch vflag
            case 1
                hhv(1,1)=line([0,-knyq],[0,fc],'color',kol,'linewidth',lw);
            case 2
                hhv(1,1)=line([0,-knyq],[0,fc],'color',kol,'linewidth',lw);
                hhv(1,2)=line([0,knyq],[0,fc],'color',kol,'linewidth',lw);
            case 3
                hhv(1,1)=line([0,knyq],[0,fc],'color',kol,'linewidth',lw);
        end
                
        %get line end
        xm=kmax;
        ym=vmin*xm;
%         if(ym>fmax/2)
%             ym=fmax/2;
%             xm=ym/vmin;
%         end
        %get angle
        dy=yax*ym/fmax;
        dx=xax*xm/kmax;
        theta=atand(dy/dx);
        switch vflag
            case 1
                hhv(2,1)=text(-xm,ym,1,['-vmin= ' num2str(-vmin)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
            case 2
                hhv(2,1)=text(-xm,ym,1,['-vmin= ' num2str(-vmin)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
                hhv(2,2)=text(xm,ym,1,['vmin= ' num2str(vmin)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
            case 3
                hhv(2,2)=text(xm,ym,1,['vmin= ' num2str(vmin)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
        end
    else
        kc=fnyq/vmin;
        switch vflag
            case 1
                hhv(1,1)=line([0,-kc],[0,fnyq],'color',kol,'linewidth',lw);
            case 2
                hhv(1,1)=line([0,-kc],[0,fnyq],'color',kol,'linewidth',lw);
                hhv(1,2)=line([0,kc],[0,fnyq],'color',kol,'linewidth',lw);
            case 3
                hhv(1,2)=line([0,kc],[0,fnyq],'color',kol,'linewidth',lw);
        end
        
        %get line end
        ym=fmax;
        xm=ym/vmin;
%         if(xm>fmax/2)
%             ym=fmax/2;
%             xm=ym/vmin;
%         end
        %get angle
        dy=yax*ym/fmax;
        dx=xax*xm/kmax;
        theta=atand(dy/dx);
        switch vflag
            case 1
                hhv(2,1)=text(-xm,ym,1,['-vmin= ' num2str(-vmin)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
            case 2
                hhv(2,1)=text(-xm,ym,1,['-vmin= ' num2str(-vmin)],'rotation',theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'uicontextmenu',hcm);
                hhv(2,2)=text(xm,ym,1,['vmin= ' num2str(vmin)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
            case 3
                hhv(2,2)=text(xm,ym,1,['vmin= ' num2str(vmin)],'rotation',-theta,'color',fontkol,'fontsize',fs...
                    ,'backgroundcolor',bgkol,'horizontalalignment','right','uicontextmenu',hcm);
        end
    end
    set(hvmin,'userdata',{hhv,lw,kol});
elseif(strcmp(action,'applyfan'))
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis');
    hfk=findobj(hfig,'tag','fk');
    hvmax=findobj(hfig,'tag','vmax');
    hvmax0=findobj(hfig,'tag','vmax0');
    vmaxname=get(hvmax0,'string');
    hvmin=findobj(hfig,'tag','vmin');
    hvmin0=findobj(hfig,'tag','vmin0');
    vminname=get(hvmin0,'string');
    
    tmp=get(hvmax,'string');
    vmax=str2double(tmp);
    if(isnan(vmax))
        hm=msgbox([vmaxname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return;
    end

    tmp=get(hvmin,'string');
    vmin=str2double(tmp);
    if(isnan(vmin))
        hm=msgbox([vminname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return;
    end
    if(vmax<0 || vmin < 0)
        hm=msgbox(['Neither ' vminname(1:end-1) ' nor ' vmaxname(1:end-1) ' can be negative']);
        WinOnTop(hm,true);
        return;
    end
    if(vmax<vmin)
        hm=msgbox([vmaxname(1:end-1) ' cannot be less than ' vminname(1:end-1)]);
        WinOnTop(hm,true);
        return;
    end
    hdv=findobj(hfig,'tag','dv');
    hdv0=findobj(hfig,'tag','dv0');
    dvname=get(hdv0,'string');
    tmp=get(hdv,'string');
    dv=str2double(tmp);
    if(isnan(dv))
        hm=msgbox([dvname(1:end-1) ' is not a number']);
        WinOnTop(hm,true);
        return;
    end
    if(dv==0)
        dv=.2*vmax;
    end
    if(dv<0)
        hm=msgbox([dvname(1:end-1) ' cannot be negative']);
        WinOnTop(hm,true);
        return;
    end
    hvflag=findobj(hfig,'tag','vflag');
    vflag=get(hvflag,'value')-2;
    hxpad=findobj(hfig,'tag','xpct');
    hxpad0=findobj(hfig,'tag','xpct0');
    xpadname=get(hxpad0,'string');
    tmp=get(hxpad,'string');
    xpadpct=str2double(tmp);
    if(isnan(xpadpct))
        hm=msgbox([xpadname(1:end-1) ' is not a number']);
        WinOnTop(hm,true);
        return;
    end
    if((xpadpct<0)||(xpadpct>100))
        hm=msgbox([xpadname(1:end-1) ' must be between 0 and 100']);
        WinOnTop(hm,true);
        return;
    end
    htpad=findobj(hfig,'tag','tpct');
    htpad0=findobj(hfig,'tag','tpct0');
    tpadname=get(htpad0,'string');
    tmp=get(htpad,'string');
    tpadpct=str2double(tmp);
    if(isnan(tpadpct))
        hm=msgbox([tpadname(1:end-1) ' is not a number']);
        WinOnTop(hm,true);
        return;
    end
    if((tpadpct<0)||(tpadpct>100))
        hm=msgbox([tpadname(1:end-1) ' must be between 0 and 100']);
        WinOnTop(hm,true);
        return;
    end
    %get the data
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    seis=results.seis{1};
    tt=results.tt;
    xx=results.xx;
    xpad=xpadpct*abs(xx(1)-xx(end))/100;
    tpad=tpadpct*abs(tt(1)-tt(end))/100;
    
    %apply the fanfilter
    [seisf,mask,f,kx]=fkfanfilter(seis,tt,xx,vmin,vmax,dv,vflag,xpad,tpad);
    
    %make the name
    hclimxt=findobj(hfig,'tag','climxt');
    udatxt=get(hclimxt,'userdata');
    spaceflag=udatxt{7};
    
    switch spaceflag
        case 0
            thisname={[results.name{1}{1} ' after f-kx fan filter '],...
                ['Vmax,Vmin,dV,vflag,xpad,tpad=' num2str(vmax) ,',', num2str(vmin) ,',', num2str(dv) ,',',...
                num2str(vflag) ,',', num2str(xpadpct) ,',', num2str(tpadpct)]};
            fkname=['kx-f space, fan filter ' thisname{2}];
        case 1
            thisname={[results.name{1}{1} ' after kx-kz fan filter '],...
                ['Smax,Smin,dS,sflag,xpad,zpad=' num2str(vmax) ,',', num2str(vmin) ,',', num2str(dv) ,',',...
                num2str(vflag) ,',', num2str(xpadpct) ,',', num2str(tpadpct)]};
            fkname=['kx-kz space, fan filter ' thisname{2}];
        case 2
            thisname={[results.name{1}{1} ' after kx-ky fan filter '],...
                ['Smax,Smin,dS,sflag,xpad,ypad=' num2str(vmax) ,',', num2str(vmin) ,',', num2str(dv) ,',',...
                num2str(vflag) ,',', num2str(xpadpct) ,',', num2str(tpadpct)]};
            fkname=['kx-ky space, fan filter ' thisname{2}];
        case 3
            thisname={[results.name{1}{1} ' after f-ky fan filter '],...
                ['Vmax,Vmin,dV,vflag,ypad,tpad=' num2str(vmax) ,',', num2str(vmin) ,',', num2str(dv) ,',',...
                num2str(vflag) ,',', num2str(xpadpct) ,',', num2str(tpadpct)]};
            fkname=['ky-f space, fan filter ' thisname{2}];
    end
    %show the results
    hiseis=findobj(hseis,'type','image');
    hiseis.CData=seisf;

    
    %the clip tools are refreshed in 'select', just assign the clims
    climxt=udatxt{1};
    hclip2=findobj(hfig,'tag','climfk');
    udatfk=get(hclip2,'userdata');
    climfk=udatfk{2};
    climdb=udatfk{3};
   
    ht=get(hseis,'title');
    ht.String=thisname;
    
    inonzero=seisf~=0;
    am=mean(seisf(inonzero));
    sigma=std(seisf(inonzero));
    amax=max(seisf(inonzero));
    amin=min(seisf(inonzero));
    sampinfo={am,sigma,amax,amin};
    
    %save results
    n=length(results.seis)+1;
    results.seis{n}=seisf;
    results.sampinfo{n}=sampinfo;
    
    results.aampinfo{n}=[];
    results.mask{n}={mask,kx,f};
    results.climxt{n}=climxt;
    results.climfk{n}=climfk;
    results.climdb{n}=climdb;
    results=saveparameters(results);%must not be called before the seismic is installed.
    results.name{n}=thisname;
    results.namefk{n}=fkname;
    results.dbflag{n}=0;
    
    %turn hdb off so that we harvest linear amplitude info
    hdb=findobj(hfig,'tag','decibels');
    hdb.Value=0;
    seisplotfkfilt('recompute');%does the fk transform of what is in hseis
    hifk=findobj(hfk,'type','image');
    Afk=hifk.CData;
    results.Afk{n}=Afk;
    
    set(hresults,'string',results.namefk,'value',n,'userdata',results);
    
    seisplotfkfilt('select');

    
elseif(strcmp(action,'setsigmax'))
    hfig=gcf;
    hsigmax=findobj(hfig,'tag','sigmax');
    hsigmax0=findobj(hfig,'tag','sigmax0');
    sigmaxname=get(hsigmax0,'string');
    tmp=get(hsigmax,'string');
    sigmax=str2double(tmp);
    if(isnan(sigmax))
        hm=msgbox([sigmaxname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return
    end
    if(sigmax<=0)
        hm=msgbox([sigmaxname(1:end-1) ' must be greater than zero']);
        WinOnTop(hm,true);
        return
    end
    if(sigmax>2)
        hm=msgbox([sigmaxname(1:end-1) ' must be less than 2']);
        WinOnTop(hm,true);
        return
    end
    %make sure input data is displayed
    hresults=findobj(hfig,'tag','results');
    iresult=get(hresults,'value');
    if(iresult~=1)
        set(hresults,'value',1);
        seisplotfkfilt('selectNU');
    end
    %delete any existing sigmax line
    ud=get(hsigmax,'userdata');
    if(~isempty(ud))
        hh=ud{1};%is an array of graphics handles associated with sigmax
        if(~isempty(hh))
            if(isgraphics(hh))
                delete(hh);
            end
        end
        lw=ud{2};
        kol=ud{3};
    end
    hdraw=findobj(hfig,'tag','drawvfan');
    hcm=hdraw.UIContextMenu;
    udd=get(hdraw,'userdata');
    bgkol='w';
    fontkol='k';
    fs=udd{5};
    hfkax=findobj(hfig,'tag','fk');
    axes(hfkax);
    hi=findobj(hfkax,'type','image');
    k=hi.XData;
    f=hi.YData;
    knyq=max(k);
    fnyq=max(f);
%     xl=get(hfkax,'xlim');
%     kmax=max(abs(xl));
    yl=get(hfkax,'ylim');
    ym=max(yl);
    hh=nan*zeros(1,4);
    hh(1)=line(sigmax*knyq*[1 1],[0 fnyq],'color',kol,'linewidth',lw,'linestyle','--');
    hh(2)=line(-sigmax*knyq*[1 1],[0 fnyq],'color',kol,'linewidth',lw,'linestyle','--');
    
    %text
    hh(3)=text(sigmax*knyq,ym*.5,1,['W_x= ' num2str(sigmax)],'rotation',-90,'color',fontkol,'fontsize',fs...
        ,'backgroundcolor',bgkol,'uicontextmenu',hcm,'horizontalalignment','center');
    hh(4)=text(-sigmax*knyq,ym*.5,1,['-W_x= ' num2str(-sigmax)],'rotation',-90,'color',fontkol,'fontsize',fs...
        ,'backgroundcolor',bgkol,'uicontextmenu',hcm,'horizontalalignment','center');
            
    set(hsigmax,'userdata',{hh,lw,kol});
elseif(strcmp(action,'setsigmay'))
    hfig=gcf;
    hsigmay=findobj(hfig,'tag','sigmay');
    hsigmay0=findobj(hfig,'tag','sigmay0');
    sigmayname=get(hsigmay0,'string');
    tmp=get(hsigmay,'string');
    sigmay=str2double(tmp);
    if(isnan(sigmay))
        hm=msgbox([sigmayname(1:end-1) ' not recognized as a number']);
        WinOnTop(hm,true);
        return
    end
    if(sigmay<=0)
        hm=msgbox([sigmayname(1:end-1) ' must be greater than zero']);
        WinOnTop(hm,true);
        return
    end
    if(sigmay>2)
        hm=msgbox([sigmayname(1:end-1) ' must be less than 2']);
        WinOnTop(hm,true);
        return
    end
    %make sure input data is displayed
    hresults=findobj(hfig,'tag','results');
    iresult=get(hresults,'value');
    if(iresult~=1)
        set(hresults,'value',1);
        seisplotfkfilt('selectNU');
    end
    %delete any existing sigmay line
    ud=get(hsigmay,'userdata');
    if(~isempty(ud))
        hh=ud{1};%is an array of graphics handles associated with sigmax
        if(~isempty(hh))
            if(isgraphics(hh))
                delete(hh);
            end
        end
        lw=ud{2};
        kol=ud{3};
    end
    hdraw=findobj(hfig,'tag','drawvfan');
    hcm=hdraw.UIContextMenu;
    udd=get(hdraw,'userdata');
    bgkol='w';
    fontkol='k';
    fs=udd{5};
    hfkax=findobj(hfig,'tag','fk');
    axes(hfkax);
    hi=findobj(hfkax,'type','image');
    k=hi.XData;
    f=hi.YData;
    knyq=max(k);
    fnyq=max(f);
%     xl=get(hfkax,'xlim');
%     kmax=max(abs(xl));
%     yl=get(hfkax,'ylim');
%     ym=max(yl);
    hh=nan*zeros(1,2);
    hh(1)=line([-knyq knyq],sigmay*fnyq*[1 1],'color',kol,'linewidth',lw,'linestyle','--');
    
    %text
    hh(2)=text(0,sigmay*fnyq,1,['W_y= ' num2str(sigmay)],'rotation',0,'color',fontkol,'fontsize',fs...
        ,'backgroundcolor',bgkol,'uicontextmenu',hcm,'horizontalalignment','center');
            
    set(hsigmay,'userdata',{hh,lw,kol});
elseif(strcmp(action,'whiten'))
    hfig=gcf;
    hwhite=findobj(hfig,'tag','whiten');
    iwhite=hwhite.Value;
    hdkx0=findobj(hfig,'tag','delkx0');
    hdkx=findobj(hfig,'tag','delkx');
    hdky0=findobj(hfig,'tag','delky0');
    hdky=findobj(hfig,'tag','delky');
    hstab0=findobj(hfig,'tag','stab0');
    hstab=findobj(hfig,'tag','stab');
    if(iwhite==0)
        set([hdkx0 hdkx hdky0 hdky hstab0 hstab],'visible','off');
    else
        set([hdkx0 hdkx hdky0 hdky hstab0 hstab],'visible','on');
    end
elseif(strcmp(action,'setdelkx')||strcmp(action,'setdelky')||strcmp(action,'setstab'))
    hfig=gcf;
    hdelkx0=findobj(hfig,'tag','delkx0');
    name=hdelkx0.String;
    hdelkx=findobj(hfig,'tag','delkx');
    tmp=hdelkx.String;
    val=str2double(tmp);
    if(isempty(val))
        hm=msgbox([name(1:end-1) ' is not specified']);
        WinOnTop(hm,true);
        return;
    end
    if(isnan(val))
        hm=msgbox([name(1:end-1) ' is not a number']);
        WinOnTop(hm,true);
        return;
    end
    if(val<0 || val>1)
        hm=msgbox([name(1:end-1) ' must be between 0 and 1']);
        WinOnTop(hm,true);
        return;
    end
elseif(strcmp(action,'applygauss'))
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis');
    hfk=findobj(hfig,'tag','fk');
    hsigmax=findobj(hfig,'tag','sigmax');
    tmp=get(hsigmax,'string');
    sigmax=str2double(tmp);
    hsigmay=findobj(hfig,'tag','sigmay');
    tmp=get(hsigmay,'string');
    sigmay=str2double(tmp);
    hwhiten=findobj(hfig,'tag','whiten');
    iwhite=get(hwhiten,'value');
    if(iwhite)
        hdelkx=findobj(hfig,'tag','delkx');
        delkx=str2double(hdelkx.String);
        hdelky=findobj(hfig,'tag','delky');
        delky=str2double(hdelky.String);
        hstab=findobj(hfig,'tag','stab');
        stab=str2double(hstab.String);
    else
        delkx=nan;
        delky=nan;
        stab=nan;
    end
%     if(gflag==1)
%         sigmax=-sigmax;
%         sigmay=-sigmay;
%     end
    %get the data
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    seis=results.seis{1};
    
    %apply the gauss filter
    [seisf,mask,kx,f]=wavenumber_gaussmask2(seis,sigmax,sigmay,iwhite,delkx,delky,stab);
    
    %make the name
    hclimxt=findobj(hfig,'tag','climxt');
    udatxt=get(hclimxt,'userdata');
    spaceflag=udatxt{7};
    if(iwhite)
        switch spaceflag
            case 0
                thisname={[results.name{1}{1} ' Whitening+Gauss filter '],...
                    ['W_kx,W_f,Del_kx,Del_f,stab=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay)),...
                    ',', num2str(abs(delkx)) ,',', num2str(abs(delky)) ,',', num2str(abs(stab))]};
                fkname=['kx-f space, ' thisname{2}];
            case 1
                thisname={[results.name{1}{1} ' Whitening+Gauss filter '],...
                    ['W_kx,W_kz,Del_kx,Del_kz,stab=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay)),...
                    ',', num2str(abs(delkx)) ,',', num2str(abs(delky)) ,',', num2str(abs(stab))]};
                fkname=['kx-kz space, ' thisname{2}];
            case 2
                thisname={[results.name{1}{1} ' Whitening+Gauss filter '],...
                    ['W_kx,W_ky,Del_kx,Del_ky,stab=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay)),...
                    ',', num2str(abs(delkx)) ,',', num2str(abs(delky)) ,',', num2str(abs(stab))]};
                fkname=['kx-ky space, ' thisname{2}];
            case 3
                thisname={[results.name{1}{1} ' Whitening+Gauss filter '],...
                    ['W_ky,W_f,Del_ky,Del_f,stab=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay)),...
                    ',', num2str(abs(delkx)) ,',', num2str(abs(delky)) ,',', num2str(abs(stab))]};
                fkname=['ky-f space, ' thisname{2}];
        end
    else
        switch spaceflag
            case 0
                thisname={[results.name{1}{1} ' Gauss filter '],...
                    ['W_kx,W_f=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay))]};
                fkname=['kx-f space, ' thisname{2}];
            case 1
                thisname={[results.name{1}{1} ' Gauss filter '],...
                    ['W_kx,W_kz=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay))]};
                fkname=['kx-kz space, ' thisname{2}];
            case 2
                thisname={[results.name{1}{1} ' Gauss filter '],...
                    ['W_kx,W_ky=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay))]};
                fkname=['kx-ky space, ' thisname{2}];
            case 3
                thisname={[results.name{1}{1} ' Gauss filter '],...
                    ['W_ky,W_f=' num2str(abs(sigmax)) ,',', num2str(abs(sigmay))]};
                fkname=['ky-f space, ' thisname{2}];
        end
    end
    %show the results
    hiseis=findobj(hseis,'type','image');
    hiseis.CData=seisf;

    %the clip tools are refreshed in 'select', just assign the clims
    climxt=udatxt{1};
    hclip2=findobj(hfig,'tag','climfk');
    udatfk=get(hclip2,'userdata');
    climfk=udatfk{2};
    climdb=udatfk{3};
    
    ht=get(hseis,'title');
    ht.String=thisname;
    
    %compute amplitude info
    inonzero=seisf~=0;
    am=mean(seisf(inonzero));
    sigma=std(seisf(inonzero));
    amax=max(seisf(inonzero));
    amin=min(seisf(inonzero));
    sampinfo={am,sigma,amax,amin};
    
    %save results
    n=length(results.seis)+1;
    results.seis{n}=seisf;
    results.sampinfo{n}=sampinfo;
    
    results.aampinfo{n}=[];
    results.mask{n}={mask,kx,f};
    results.climxt{n}=climxt;
    results.climfk{n}=climfk;
    results.climdb{n}=climdb;
    results=saveparameters(results);%must not be called before the seismic is installed.
    results.name{n}=thisname;
    results.namefk{n}=fkname;
    
    %turn hdb off so that we harvest linear amplitude info
    hdb=findobj(hfig,'tag','decibels');
    hdb.Value=0;
    seisplotfkfilt('recompute');%does the fk transform of what is in hseis
    hifk=findobj(hfk,'type','image');
    Afk=hifk.CData;
    results.Afk{n}=Afk;
    


    set(hresults,'string',results.namefk,'value',n,'userdata',results);
    seisplotfkfilt('select');
elseif(strcmp(action,'delete'))
    hfig=gcf;
    hr=findobj(gcf,'tag','results');
    results=get(hr,'userdata');
    iresult=get(hr,'value');
    if(iresult==1)
        hm=msgbox('You cannot delete the original data');
        WinOnTop(hm,true);
        return;
    end
    fn={'seis','sampinfo','Afk','aampinfo','mask','name','namefk','vmax','vmin','dv','vflag','xpct','tpct',...
        'sigmax','sigmay','whiten','delkx','delky','stab','filtertype'};
    for k=1:length(fn)
        results.(fn{k})(iresult)=[];
    end
    iresult=iresult-1;
    set(hr,'value',iresult,'userdata',results,'string',results.namefk);
    seisplotfkfilt('select');
     
    %reset toggle2
    htoggle2=findobj(hfig,'tag','toggle2');
    set(htoggle2,'userdata',[]);
elseif(strcmp(action,'pick'))
    hfig=gcf;
    hpickb=gcbo;
    pos=get(hpickb,'position');
    instructions=['With the left mouse button, click in the Seismic image and drag the mouse along ',...
        'a trajectory following a dipping event, then release the mouse button. Repeat as desired.'];
    uicontrol(hfig,'style','text','string',instructions,'units','normalized','tag','instr',...
        'position',[pos(1)+1.2*pos(3),pos(2)-pos(4),3*pos(3),2*pos(4)],'foregroundcolor','r','backgroundcolor','w');
    hfig.WindowButtonDownFcn=@startpick;
    set(hpickb,'string','Stop picking','callback','seisplotfkfilt(''notpick'');');
    hclear=findobj(gcf,'tag','clear');
    if(~isempty(hclear))
        set(hclear,'visible','on');
    end
elseif(strcmp(action,'notpick'))
    hfig=gcf;
    hfig.WindowButtonDownFcn='';
    hpickb=gcbo;
    hpickb.Callback='seisplotfkfilt(''pick'');';
    hinstr=findobj(hfig,'tag','instr');
    delete(hinstr);
    hpickb.String=hpickb.UserData;
    hclear=findobj(hfig,'tag','clear');
    if(~isempty(hclear))
        ud=get(hclear,'userdata');
        if(isempty(ud))
            delete(hclear);
        else
            set(hclear,'visible','off');
        end
    end
elseif(strcmp(action,'finishpick'))
    hfig=gcf;
    a=drawlinefini;
    if(isempty(a))
        return;
    end
    if(length(a)<2)
        return;
    end
    pick=a{1};
    hpick=a{2};
    if(strcmp(get(gca,'tag'),'fk'))
        delete(hpick);
        return;
    end
    if(length(pick)~=4)
        delete(hpick);
        return;
    end
    x=pick([1 3]);
    y=pick([2 4]);
    if(diff(y)~=0)
        v=diff(x)/diff(y);
        txt=int2str(v);
    else
        v=0;
        txt='inf';
    end
    delete(hpick);
    %get font info
    hdraw=findobj(hfig,'tag','drawvfan');
    hcm=hdraw.UIContextMenu;
    ud=get(hdraw,'userdata');
    fs=ud{5};
    bgkol=ud{6};
    fontkol=ud{9};
    if(y(2)>y(1) && v<0)
        hh=line2pt_text(x,y,txt,'end');
    else
        hh=line2pt_text(x,y,txt,'beginning');
    end
    set(hh(2),'horizontalalignment','right','fontsize',fs,'backgroundcolor',bgkol,'color',fontkol,'uicontextmenu',hcm);
    set(hh,'color','r');
    hclear=findobj(hfig,'tag','clear');
    if(isempty(hclear))
        hpbutt=findobj(hfig,'tag','pick');
        pos=get(hpbutt,'position');
        hclear=uicontrol(hfig,'style','pushbutton','string','Clear picks','units','normalized','tag','clear',...
            'position',[pos(1),pos(2)-1.2*pos(4),pos(3),pos(4)],'callback','seisplotfkfilt(''clearpicks'');');
    end
    ud=hclear.UserData;
    hclear.UserData=[ud;hh];
elseif(strcmp(action,'clearpicks'))
    hfig=gcf;
    hclear=findobj(hfig,'tag','clear');
    if(isempty(hclear))
        return;
    end
    ud=hclear.UserData;
    if(~isempty(ud))
        delete(ud);
        hclear.UserData=[];
    end
elseif(strcmp(action,'redrawpicks'))
    hfig=gcf;
    hclear=findobj(hfig,'tag','clear');
    if(isempty(hclear))
        return;
    end
    hh=hclear.UserData;
    %get font info
    hdraw=findobj(hfig,'tag','drawvfan');
    hcm=hdraw.UIContextMenu;
    ud=get(hdraw,'userdata');
    fs=ud{5};
    bgkol=ud{6};
    fontkol=ud{9};
    for k=1:size(hh,1)
        set(hh(k,2),'fontsize',fs,'color',fontkol,'backgroundcolor',bgkol,'uicontextmenu',hcm);
    end
    
elseif(strcmp(action,'climxt'))
    hfig=gcf;
    hclip=findobj(hfig,'tag','climxt');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    %save clim in results
    hresults=findobj(hfig,'tag','results');
    iresult=hresults.Value;
    results=hresults.UserData;
    results.climxt{iresult}=clim;
    hresults.UserData=results;
    %if clim was changed on iresult=1 (the input) then we adjust the saved default clim in userdata
    if(iresult==1)
        udat{1}=clim;
        set(hclip,'userdata',udat);
    end
    
elseif(strcmp(action,'climfk'))
    hfig=gcf;
    hdb=findobj(hfig,'tag','decibels');
    db=get(hdb,'value');
    hclip=findobj(gcf,'tag','climfk');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    %save clim in results
    hresults=findobj(hfig,'tag','results');
    iresult=hresults.Value;
    results=hresults.UserData;
    if(db)
        results.climdb{iresult}=clim;
    else
        results.climfk{iresult}=clim;
    end
    hresults.UserData=results;
    %if clim was changed on iresult=1 (the input) then we adjust the saved default clims in userdata
    if(iresult==1)
        if(db)
            udat{3}=clim;
        else
            udat{2}=clim;
        end
        set(hclip,'userdata',udat);
    end
    
elseif(strcmp(action,'recompute'))
    %recompute is called when (1) the db button is pushed, and (2) after applying a filter and we
    %need a spectrum, and (3) after 'select' if db is on
    hfig=gcf;
    hclimxt=findobj(hfig,'tag','climxt');
    udat=get(hclimxt,'userdata');
    haxe=udat{2};
    pctfk=udat{3};
%     fmax=udat{4};
    gridx=udat{5};
    gridy=udat{6};
%     spaceflag=udat{7};
    
    hdb=findobj(hfig,'tag','decibels');
    db=get(hdb,'value');
    if(isempty(db))
        db=0;
    end
    
    hi=findobj(haxe,'type','image');%the image to be transformed
    seis=get(hi,'cdata');
    x=get(hi,'xdata');
    t=get(hi,'ydata');
    
    if(t(2)>t(1))
        tt=gridy*(0:length(t)-1)';
    else
        tt=gridy*(length(t)-1:-1:0)';
    end
    if(x(2)>x(1))
        xx=gridx*(0:length(x)-1);
    else
        xx=gridx*(length(x)-1:-1:0);
    end
    tmin=min(t);tmax=max(t);
    xmin=min(xx);xmax=max(xx);
    it=near(t,tmin,tmax);
    ix=near(xx,xmin,xmax);
    [seisfk,f,k]=fktran(seis(it,ix),tt(it),xx(ix),nan,nan,pctfk);
%     ind=near(f,0,fmax);
    Afk=abs(seisfk);
    am=mean(Afk(:));
    sigma=std(Afk(:));
    amax=max(Afk(:));
    amin=min(Afk(:));
    aampinfo={am,sigma,amax,amin};
    %plan: aampinfo will always be for amplitude. If db, then 'select' will convert
    sigma=std(Afk(:));
    if(db==1)
        Afk=20*log10(Afk/amax);
    end
    hclip=findobj(hfig,'tag','climfk');
    udat=get(hclip,'userdata');
    haxefk=udat{1};
    
    %get results
    hresults=findobj(hfig,'tag','results');
    results=hresults.UserData;
    iresult=hresults.Value;
    results.aampinfo{iresult}=aampinfo;
    results.dbflag{iresult}=db;
    
    %update the fk cliptool
    hclimfk=findobj(hfig,'tag','climfk');
    udatfk=hclimfk.UserData;
    
    if(db)
        sigma=1;
        if(isempty(results.climdb{iresult}))
            clim=udatfk{3};
            results.climdb{iresult}=clim;
        else
            clim=results.climdb{iresult};
        end
        clipdat={clim,haxefk,sigma,0};
    else
        if(isempty(results.climfk{iresult}))
            clim=udatfk{2};
            results.climfk{iresult}=clim;
        else
            clim=results.climfk{iresult};
        end
        clipdat={clim,haxefk,[],0,0};
    end
    
%     cliptool('refresh',hclimfk,clipdat);
    %update the image
    hfig.CurrentAxes=haxefk;
%     set(haxefk,'visible','off');
    hi=findobj(haxefk,'type','image');
    hcm=hi.UIContextMenu;
%     ht=get(gca,'title');
%     titstr=get(ht,'string');
    fw=get(haxefk,'fontweight');
    fs=get(haxefk,'fontsize');
    xlbl=get(get(haxefk,'xlabel'),'string');
    ylbl=get(get(haxefk,'ylabel'),'string');
    tag=get(gca,'tag');
    cm=get(gca,'colormap');
    hi=imagesc(k,f,Afk,clim*sigma);
    cliptool('refresh',hclimfk,clipdat);
%     hi.CData=Afk;
    set(haxefk,'colormap',cm);
%     set(haxefk,'visible','on');
    hi.UIContextMenu=hcm;
    set(haxefk,'fontweight',fw,'fontsize',fs,'tag',tag);
    xlabel(xlbl);
    ylabel(ylbl);
    grid
%     enTitle(titstr,'interpreter','none');
    if(db==1)
       hc=colorbar;
       hc.Position=[.88 .1 .0133 .25];
       hc.Label.String='decibels';
    end
    seisplotfkfilt('lims');
    hrecompute=findobj(hfig,'tag','recompute');
    set(hrecompute,'backgroundcolor',.94*ones(1,3));
    hdraw=findobj(hfig,'tag','drawvfan');
    idraw=get(hdraw,'value');
    if(idraw==1)
        seisplotfkfilt('drawvfan');
    end
    
    
%     %get results
%     hresults=findobj(hfig,'tag','results');
%     results=hresults.UserData;
%     iresult=hresults.Value;
%     results.aampinfo{iresult}=aampinfo;
%     results.dbflag{iresult}=db;
    
%     %update the fk cliptool
%     hclimfk=findobj(hfig,'tag','climfk');
%     udatfk=hclimfk.UserData;
%     
%     if(db)
%         sigma=1;
%         if(isempty(results.climdb{iresult}))
%             clim=udatfk{3};
%             results.climdb{iresult}=clim;
%         else
%             clim=results.climdb{iresult};
%         end
%         clipdat={clim,haxefk,sigma,0};
%     else
%         if(isempty(results.climfk{iresult}))
%             clim=udatfk{2};
%             results.climfk{iresult}=clim;
%         else
%             clim=results.climfk{iresult};
%         end
%         clipdat={clim,haxefk,[],0,0};
%     end
%     
%     cliptool('refresh',hclimfk,clipdat);
    hresults.UserData=results;
    
elseif(strcmp(action,'select')||strcmp(action,'selectNU'))
    %selectNU means select but dont update the filter parameters
    hfig=gcf;
    hdecibels=findobj(hfig,'tag','decibels');
    idb=hdecibels.Value;
    hresults=findobj(hfig,'tag','results');
    iresult=hresults.Value;
    results=hresults.UserData;
    hseis=findobj(hfig,'tag','seis');
    hfk=findobj(hfig,'tag','fk');
    hiseis=findobj(hseis,'type','image');
%     hfk.Visible='off';
    hifk=findobj(hfk,'type','image');
    hcmfk=hifk.UIContextMenu;
    hiseis.CData=results.seis{iresult};
    hifk.CData=results.Afk{iresult};
    hifk.UIContextMenu=hcmfk;
    hseis.Title.String=results.name{iresult};
    
    %update clips
    hclip=findobj(hfig,'tag','climxt');
    climxt=results.climxt{iresult};
    clipdata={climxt,hseis};
    cliptool('refresh',hclip,clipdata);
    hclip=findobj(hfig,'tag','climfk');
    clim=results.climfk{iresult};
    clipdata={clim,hfk,[],0,0};
    if(idb)
        clim=results.climdb{iresult};
        seisplotfkfilt('recompute');
        clipdata={clim,hfk,1,0,1};
    end
    
    cliptool('refresh',hclip,clipdata);
%     hfk.Visible='on';
    
    if(strcmp(action,'select'))
        hfan=findobj(hfig,'tag','fan');
        h=findobj(hfan,'tag','vmax');
        h.String=num2str(results.vmax(iresult));
        h=findobj(hfan,'tag','vmin');
        h.String=num2str(results.vmin(iresult));
        h=findobj(hfan,'tag','dv');
        h.String=num2str(results.dv(iresult));
        h=findobj(hfan,'tag','vflag');
        h.Value=results.vflag(iresult)+2;
        h=findobj(hfan,'tag','xpct');
        h.String=num2str(results.xpct(iresult));
        h=findobj(hfan,'tag','tpct');
        h.String=num2str(results.tpct(iresult));
        hgaus=findobj(hfig,'tag','gaus');
        hp=get(hgaus,'parent');
        
        if(results.filtertype(iresult)==1)
            hp.SelectedTab=hfan;
        else
            hp.SelectedTab=hgaus;
        end
        
        h=findobj(hgaus,'tag','whiten');
        h.Value=results.whiten(iresult);
        if(results.whiten(iresult)==1)
            vis='on';
        else
            vis='off';
        end
        h=findobj(hgaus,'tag','delkx');
        h0=findobj(hgaus,'tag','delkx0');
        set(h,'string',num2str(results.delkx(iresult)),'visible',vis);
        h0.Visible=vis;
        h=findobj(hgaus,'tag','delky');
        h0=findobj(hgaus,'tag','delky0');
        set(h,'string',num2str(results.delky(iresult)),'visible',vis);
        h0.Visible=vis;
        h=findobj(hgaus,'tag','stab');
        h0=findobj(hgaus,'tag','stab0');
        set(h,'string',num2str(results.stab(iresult)),'visible',vis);
        h0.Visible=vis;
    end
    if(iresult~=1)
        htoggle=findobj(hfig,'tag','toggle');
        htoggle.UserData=iresult;
    end
    htoggle2=findobj(hfig,'tag','toggle2');
    ud=get(htoggle2,'userdata');
    if(isempty(ud))
        ud=iresult;
    elseif(length(ud)==1)
        ud=[iresult ud];
    else
        ud=[iresult ud(1)]; 
    end
    set(htoggle2,'userdata',ud);
%     seisplotfkfilt('climxt');
%     seisplotfkfilt('climfk');
    %check mask
    hmask=findobj(hfig,'tag','mask');
    hmaskwin=hmask.UserData;
    if(isgraphics(hmaskwin))
        if(iresult>1)
            seisplotfkfilt('masknew');
        end
    end
    
elseif(strcmp(action,'toggle'))
    hfig=gcf;
    htoggle=gcbo;
    hresults=findobj(hfig,'tag','results');
    iresult=hresults.Value;
    jresult=htoggle.UserData;
    if(iresult==jresult)
        %jump to #1
        hresults.Value=1;
    else
        %jump to #jresult
        hresults.Value=jresult;
    end
    seisplotfkfilt('select'); 
elseif(strcmp(action,'toggle2'))
    hfig=gcf;
    htoggle2=gcbo;
    hresults=findobj(hfig,'tag','results');
    ud=htoggle2.UserData;
    if(length(ud)<2)
        return;
    end
    iresult=hresults.Value;
    if(iresult==ud(1))
        %jump to #2
        hresults.Value=ud(2);
    else
        %jump to #1
        hresults.Value=ud(1);
    end
    seisplotfkfilt('select');
elseif(strcmp(action,'mask')||strcmp(action,'masknew'))
    hfig=gcf;
    hmask=findobj(gcf,'tag','mask');
    hmaskwin=get(hmask,'userdata');
    if(isgraphics(hmaskwin))
        if(strcmp(action,'mask'))
            figure(hmaskwin);
            return;
        end
    else
        hmaskwin=[];
    end
    hresults=findobj(hfig,'tag','results');
    iresult=hresults.Value;
    if(iresult==1)
        hm=msgbox('First select a filter result and then press this button');
        WinOnTop(hm,true);
        return;
    end
    results=hresults.UserData;
    %make a figure window
    if(isempty(hmaskwin))
        pos=get(hfig,'position');
        figwid=pos(3)*.4;
        fight=pos(4)*.5;
        xc=pos(1)+.9*pos(3);
        yc=pos(2)+.4*pos(4);
        hmaskwin=figure('position',[xc-.5*figwid,yc-.5*fight,figwid,fight],'numbertitle','off',...
            'menubar','none','toolbar','figure','name','fk filter Mask Display');
        hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
            'position',[.95,.95,.05,.05],'backgroundcolor','y','callback','enhance(''makepptslide'');');
        hmask.UserData=hmaskwin;
        customizetoolbar(hmaskwin,1);
        colormap(jet)
        viewang=[-180 90];
    else
        figure(hmaskwin);
        viewang=get(gca,'view');
        hppt=findobj(hmaskwin,'tag','ppt');
    end
    
    if(iscell(results.mask{iresult}))
        ff=results.mask{iresult}{3};
        ind=ff>=0;
        f=ff(ind);
        mask=results.mask{iresult}{1}(ind,:);
        kx=results.mask{iresult}{2};
        
    else
        mask=results.mask{iresult};
        f=results.f;
        kx=results.k;
    end
    hclimxt=findobj(hfig,'tag','climxt');
    udatxt=get(hclimxt,'userdata');
    spaceflag=udatxt{7};
    surf(kx/max(kx),f/max(f),mask);shading flat
    xlim([-1 1]);
    ylim([0 1]);
    view(viewang)
    name=results.namefk{iresult};
    switch spaceflag
        case 0
            xlabel('fractional kx wavenumber');
            ylabel('fractional frequency');
        case 1
            xlabel('fractional kx wavenumber');
            ylabel('kz wavenumber');
        case 2
            xlabel('fractional kx wavenumber');
            ylabel('fractional ky wavenumber');
        case 3
            xlabel('fractional ky wavenumber');
            ylabel('fractional frequency');
    end
    enTitle(name,'interpreter','none')
    colorbar
    %register the new figure with parent
    updatefigureuserdata(hfig,hmaskwin)
    set(hppt,'userdata',name);
elseif(strcmp(action,'close'))
    hfig=gcf;
    tmp=get(hfig,'userdata');
    if(iscell(tmp))
        hfigs=tmp{1};
    else
        hfigs=tmp;
    end
    for k=1:length(hfigs)
        if(isgraphics(hfigs(k)))
            delete(hfigs(k))
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
    for k=1:length(udat{1})
       if(isgraphics(udat{1}(k)))
          if(strcmp(get(udat{1}(k),'tag'),'info'))
              figure(udat{1}(k))
              return;
          end
       end
    end

msg1={'Synopsis',{['The f-k filter tool enables interactive 2D filtering on vertical seismic sections or ',...
        'horizontal time or depth slices. A vertical section naturally has one spatial coordinate and one ',...
        'time coordinate (or depth derived from time). A horizontal section has two spatial coordinates ',...
        'corresponding to the areal footprint of a 3D survey. These sections are distinctly different in character ',...
        'and respond best to distinctly different types of filters. ',...
        'In this tool, there are two major filter types: (1) The FAN FILTER ',...
        'which is most appropriate for vertical (time) sections and (2) The GAUSSIAN FILTER which is ',...
        'most appropriate for horizontal (spatial) sections.'], ' ', ['TOOL LAYOUT: Immediately upon ',...
        'launch, the left side of the tool window shows the seismic section to be filtered (aka the input). ',...
        'To the left of the seismic section are controls to alter its display. As wish all ENHANCE tools, ',...
        'holding the mouse pointer ofver the control without pressing a button will cause a "tooltip" to appear ',...
        'explaining the essential function  control. The most important control to the left of the seismic image ',...
        'is the "clip" control which determines how faithfully large and small amplitudes are displayed. ',...
        'The "clip" value is the number of standard deviations over which the colorbar extends. For example, ',...
        'clip=3 means that the colorbar extends + and - 3 standard deviations from the mean. Amplitudes ',...
        'falling outside this range are "clipped" meaning that they are rendered with the end values of ',...
        'the colorbar and are not otherwise distinguished. This means that smaller clip values show greater ',...
        'clipping.'],' ',...
        ['On the right side of the tool window is the 2D Fourier transform of the input. (Only the amplitude spectrum is shown). ',...
        'The term "f-k transform" will be used as a generic reference to this transform even when both data axes are spatial. ',...
        'The labelling of the axes and other details of the presentation are dependent upon the input. ',...
        'For vertical sections, a radial net of red lines is superimposed on the f-k transform and, ',...
        'for time sections, it is called a "velocity fan" while for spatial sections it is called a ',...
        '"slope fan". This fan will not initially appear for horizontal sections. Above the f-k transform ',...
        'is a popup menu that initially has only one entry which refers to the input data. As f-k filters ',...
        'are designed and applied, each one will generate a new entry in this menu. To the right of the ',...
        'f-k transform are controls to alter the transform display, controls to design the f-k filters ',...
        'and controls to compare results. A new user should take a moment to hover the mouse over each control ',...
        'without pressing a button to read the "tooltips". Further information is found in the tabs for each ',...
        'specific filter.']}};
    msg2={'Apparent Velocity',{['A fan filter is designed to reject a fan-shaped ',...
        'region of the tranform and this eliminates a corrsponding class of dipping events in the seismic ',...
        'section. To understand this, the important fact is that there is a many-to-one correspondence ',...
        'between families of dipping events in the seismic data and radial lines in the transform. The ',...
        'velocity (or slope) fan helps to visualize this. Considering the seismic section, each position on ',...
        'any event has a measurable apparent velocity and all points with a given apparent velocity are ',...
        'gathered into a particular radial line ("many-to-one") in the f-k transform. The velocity fan shows a set of radial ',...
        'lines each labelled with its apparent velocity. The velocity fan shows that the highest apparent ',...
        'velocities lie vertically down the center of the transform while the slowest are to the upper right ',...
        'and left. The right side of the transform gathers positive apparent velocities while the left side has ',...
        'the negative velocities.'],' ',[' Now, to visualize apparent velocity on the seismic section, mentally pick a ',...
        'point on some event and imagine drawing a tangent line to that event at the point you chose. ',...
        'This tangent line will have a slope characterized by some dx ("delta x") and some dt. The ratio ',...
        'dx/dt is the apparent velocity at that point. Now, click the button above the seismic section ',...
        'labelled "Pick velocities" (it might also say "Pick Slopes" if your section is not a time section) ',...
        'and, with the left mouse button, click and drag to draw a tangent to some event in the seismic section. ',...
        'Then the pick line will be drawn on the seismic data and labelled with the apparent velocity (or slope) ',...
        'of the pick that you made. (If the text is hard to read against the background of the seismic, then ',...
        'right-click on the "Draw velocity fan" control and a context menu will appear. Select "Text label ',...
        'background color/white" and it should be more legible.) In this way the apparent velocity of any point ',...
        'on any event can be measured and then its radial line in the transform domain can be visualized. '],'',...
        ['It rapidly becomes obvious that horizontal events in time, which are usually the majority of events ',...
        'have very high, possibly infinite, apparent velocity. Negative apparent velocity means that the ',...
        'event is down in the direction of decreasing coordinate while positive is the other way. ',...
        'This simple concept of apparent velocity applies directly to events that are largely continuous; ',...
        'however, its mathematical generalization reveals that small features on events or event truncations ',...
        'require all possible apparent velocities for their description. It follows therefore, that the '...
        'rejection of any range of apparent velocity will necessarily decrease overall resolution. ',...
        'Often a range of slower velocities can be suppressed with very little observable loss in resolution. ',...
        'Still, the success of an f-k filter must be judged not only from the viewpoint of eliminating ',...
        'a certain class of events, but also from that of minimizing detrimental effects on resolution. ',...
        'Physically speaking, on a time section there is always a maximum possible "time dip" or, in terms ',...
        'velocity, a minimum possible apparent velocity. It the simplest case this minimum velocity is ',...
        'related to the slowest velocity, usually in the shallowest layer, at a given x location. ',...
        'For a stacked section the minimum apparent velocity will be 1/2 of the slowest physical velocity. ',...
        'Although many effects such as topography can distort the actual values, there is still always ',...
        'a slowest physical velocity. This is a fundamental difference between time sections and spatial ',...
        'sections like time-slices for which there is no such limit.']}};
    msg3={'Fan Filters',{['Fan filters are most appropriate on time sections because, by their very nature, ',...
        'time sections have a minimum physical apparent velocity and very little resolution will be lost ',...
        'by a filter that excludes all velocities slower than this minimum. Such a filter will have a ',...
        'fan-shaped reject region in f-k space and is therefore called a Fan Filter. More general fan filters ',...
        'don''t just reject all velocities below some minimum but instead reject the velocities between ',...
        'some maximum and some minimum values. As with 1-D temporal filters the transition from pass to ',...
        'reject should not be sharp but rather should have some sort of gradual roll-off. There are many ',...
        'possible shapes for such a roll-off and the approach taken here is to define a roll-off region ',...
        'width in terms of velocity. For example, if Vmax=2000 is the fastest velocity to reject, then ',...
        'setting the transition region to a width of dV=600 means that the filter will start to roll-off ',...
        'at V=2600 reaching full rejection at Vmax=2000. Therefore the transition region is also ',...
        'fan-shaped. The actual form of the roll-off ',...
        'used here is that of a so-called "raised cosine" which has the value 1 (full pass) at Vmax+dV and the value ',...
        '0 (full reject) at Vmax. Intermediate velocities correspond to values from the first half period of ',...
        'a raised cosine. (A raised cosine is defined by rcos(x)=0.5+0.5*cos(x) where x is some angle. For ',...
        'a filter edge transition, x takes angles between 0 and pi.)'],' ',...
        ['To specify a Fan Filter, first choose some Vmax and some Vmin that are the ',...
        'numerical values of the fastest velocity to reject and the slowest. For example, there may be some ',...
        'steeply dipping events on a stacked section possibly associated with unattenuated surface waves. If these ',...
        'events have a measured apparent velocity of 2000 m/s (see the "Apparent Velocity" tab for instructions on ',...
        'using this tool for such measurements), then a reasonable choice for Vmax would be something like 2200 ',...
        'while Vmin can usually be set to 0 (but could also be, say, 500 with little difference) and dV can be defaulted. ',...
        'Now, make sure the "Fan Filter" tab is selected to the right of the F-K spectrum, ',...
        'and type your chosen values for Vmax and Vmin into the appropriate boxes. Initially upon launch of ',...
        'the f-k filter tool, both the Vmax and the Vmin boxes will be set to 0 and trying to set Vmin while Vmax is 0 ',...
        'causes the error message that "Vmax must be greater than Vmin". So a good practice is to ',...
        'always set Vmax first and then Vmin. These values should always be entered as postive numbers ',...
        'regardless of whether the measured noise events show positive or negative apparent velocity. Just below the dV ',...
        'box is a control labelled "Rejection region" which can be used to direct the filtering action to ',...
        'positive, or negative, or both apperent velocity. Most filtering tasks will use the "both" setting. There '...
        'is an alternate, and often easier, way to set Vmin and Vmax. Instead of typing values into their boxes, ',...
        'use a right mouse-click in the f-k image and select either Vmax or Vmin. The point of the mouse click will lie ',...
        'on some radial line from the f-k origin and therefore defines some apparent velocity. This value will become ',...
        'either Vmax or Vmin as you choose. It does not matter whether you click on the positive or negative velocity ',...
        'side of the f-k transform but it is always a good idea to set Vmax before Vmin. '],...
        ' ',['It is a good practice to try a variety of different filter settings to study their effect and ',...
        'gain understanding. Each time the "Apply Fan Filter" button is pressed a new "result" is obtained and all ',...
        'results are retained in memory until either deleted or the f-k filter tool is closed. Any result can ',...
        'recalled by selecting it by name from the popup menu above the f-k transform axes. The name of a ',...
        'result is a simple encoding of the Fan Filter parameters where the parameter "vflag" refers to ',...
        'the choice of rejection region. New filter specifications are always applied to the input data and ',...
        'not to the result of a previous filter regardless of what is displayed at the time the "Apply Fan Filter" ',...
        'button is pressed. As a result is selected for display, the filter parameters for that result are ',...
        'loaded into the appropriate controls. So the simplest way to modify a previous result is to first ',...
        'display it and then change the parameters after they are displayed. ',...
        'A "Toggle" button is provided to easily toggle back and forth between any result and the ',...
        'input. A second "Toggle" button is provided to toggle between any two results. To use it, first ',...
        'select and display one result and then select and display the other. Now pressing the toggle button ',...
        'will alternate back and forth between these results. '],' ',['The application of any f-k filter ',...
        'is accomplished by this tool through the construction of a filter "mask". A mask is a numerical ',...
        'array identical in size to the f-k transform but whose values all lie between 0 and 1 (inclusive). ',...
        'Of course, 1 means pass and 0 means reject and intermediate values occur at the filter transition edges. ',...
        'The mask for any result can be examined by pressing the "Show Mask" button. This causes a new ',...
        'window to appear with a 3D perspective display of the filter mask. The view angle of this display ',...
        'can be changed interactively by choosing the "Rotate 3D" control from the upper left and then ',...
        'clicking on the image. If this window is left open as you move between results, if will be ',...
        'refreshed with the mask of each result. ']}};
    msg4={'Gaussian Filters',{['Using 3D data, it is easy to verify that a Fan Filter is not the appropriate ',...
        'tool for 2D filtering of a time or depth slice. Fundamentally this is because, unlike vertical time ',...
        'sections, all possible slopes are equally probable. So eliminating a certain class of slopes is ',...
        'rarely desirable. However, 2D Gaussian filters are generally quite useful on time slices and ',...
        'can even be beneficial on vertical time sections. ',...
        'The name arises because the filter mask (see the discussion of masks at the end of the Fan Filter ',...
        'tab) is a form of 2D Gaussian, centered at the wavenumber origin and having a certain width ',...
        'along each wavenumber axis. Since both dimensions of a time slice are spatial, it ',...
        'follows that both dimensions of its 2D spectrum are wavenumbers, typically called kx and ky. ',...
        'For example, imagine a 2D Gaussian, symmetric in kx and ky, with "width" equal to 1/2 ',...
        'the Nyquist wavenumber (the largest possible). Multiplying the 2D spectrum by this mask will have ',...
        'the action of suppressing the larger wavenumbers in a smoothly varying fashion. Theoretically, this ',...
        'is appropriate because, as predicted from imaging (migration) theory, the larger lateral wavenumbers ',...
        'come exclusively from the higher temporal frequencies. Since seismic sources are generally ',...
        'bandlimited and of finite strength, it follows that the higher frequencies, and therfore the ',...
        'higher wavenumbers, will be increasingly noisy. For the same reason that it is usually desirable ',...
        'to apply a temporal bandpass filter to seismic data it may also be worthwhile to apply a wavenumber ',...
        'lowpass filter. It is also possible to apply Gaussian Filters to time sections with pleasing results ',...
        'but often Fan Filters are more effective. '],...
        ' ',['Examination of the Gaussian Filter tab to the right of the f-k spectrum ',...
        'shows that the filter is available with or without spatial whitening. The latter is discussed here ',...
        'first. The basic Gaussian filter has only two parameters and these specify the filter width ',...
        'along each of the two spectral axes. These widths, called W_kx and W_ky are always specified ',...
        'as a fraction of the Nyquist wavenumber. The actual Gaussian form used here is g(k)=exp(-k^2/W^2) ',...
        'where k is either kx or ky and W is the corresponding width. Given this definition, when W=.5*knyq, then ',...
        'g(k=.5*knyq)=exp(-1) which is an attenuation of about 9dB. At k=knyq, the attenuation is exp(-4) or ',...
        'about 35dB. Having independent width parameters for the two coordinate wavnumber ',...
        'directions allows for a greater variety of shapes and may be most useful if the two spatial directions ',...
        'do not have the same sample interval.'],' ',['The temporal spectrum of seismic data is shaped mainly ',...
        'by deconvolution and bandpass filtering (although stacking and other noise reduction techniques ',...
        'also have an effect). Since reflectivity as computed from well logs has a nearly white spectrum, ',...
        'deconvolution methods have been designed to do spectral whitening. If these methods were entirely ',...
        'successful then the higher wavenumbers created from the higher frequencies during imaging would also ',...
        'be whitened. (Here "whitened" means that all wavenumbers would have approximatly similar strength.) ',...
        'However, it is nearly always the case that "final" seismic sections or volumes seem to benefit ',...
        'from further temporal spectral whitening. This is probably because the data spectrum is always the combined ',...
        'effect of signal and noise and noise is continually suppressed in the data processing flow. So if ', ...
        'prestack deconvolution whitens the temporal spectrum it is the spectrum of signal+noise. Stacking attenuates ',...
        'the noise and de-whitens the spectrum. Similarly if a deconvolution run before migration (pre or post stack) ',...
        'whitens the spectrum then migration will de-whiten it as it suppresses noise. Thus migrated seismic ',...
        'images are often found to have a temporal spectrum that is not optimally shaped. For the very same ',...\
        'reasons, we should expect the wavenumber spectrum to also not have an optimal shape. '],' ',...
        ['Spatial whitening can be incorporated into the Gaussian filter concept in a way that is analagous to ',...
        'deconvolution. The essence of a deconvolution method in the frequency domain is to divide the temporal ',...
        'spectrum by its smoothed self. The choice of smoothing and the decision about how to handle phase ',...
        'distinguish one deconvolution from another. The deconvolution is then followed by a process to ',...
        'attenuate noise of which the simplest is a bandpass filter. The result is data with a flat spectrum ',...
        'over some passband. Something very similar is available here as a 2D zero-phase process. First ',...
        'the 2D wavenumber amplitude spectrum is smoothed in some way and then the original spectrum is divided ',...
        'by this smoothed version of itself. In a second step the spectrum is bandlimited by a specified ',...
        'Gaussian mask. Given effective parameter choices, the result is a wavenumber spectrum with a relatively ',...
        'flat passband and, in the space domain, improved resolution. There are three parameters that ',...
        'control the whitening process: Del_kx, Del_ky, and stab. The defaults for the parameters are ',...
        '0.05, 0.05, and 0.1 and are good starting points. The first two are expressed as fractions of ',...
        'Nyquist and, in percent, are 5%. These determine the dimensions of a 2D boxcar convolutional ',...
        'smoother that is applied to the wavenumber amplitude spectrum. Reasoning intuitively, Del_kx is ',...
        'inversely proportional to a characteristic spatial size Del_x~1/Del_kx~1/(.05*knyq)=100*2*dx/5 = 40*dx ',...
        'where dx is the spatial sample size. The inference to be drawn, is that spatial variations ',...
        'on a scale shorter than this will be retained and emphasized in the result whiel variations on ',...
        'a scale greatly exceeding this will be suppressed (equalized). So, smaller smoother sizes ',...
        'mean more agressive whitening and, if too small, result in fine detail but little discernable ',...
        'structure. Extremely large smoothers essentially turns off the whitening.']}};
    msg={msg1,msg2,msg3,msg4};
    hinfo=showinfo(msg,'Instructions for f-k filter tool',nan,nan,6);
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

if(strcmp(action2,'debug'))
    hfig=gcf;
    name=get(hfig,'name');
    if(length(name)<11)
        return;%too soon
    end
    if(~strcmp(name(1:11),'f-k filter'))
        return;%its not an f-k window because its already closed
    end
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        return;
    end
    fn={'seis','sampinfo','Afk','aampinfo','mask','name','namefk','vmax','vmin','vflag','xpct','tpct','sigmax',...
        'sigmay','whiten','delkx','delky','stab','filtertype'};
    nd=length(results.seis);
    errors=0;
    for k=2:length(fn)
        if(length(results.(fn{k}))~=nd)
            errors=errors+1;
            disp(['field ' fn{k} ' has the wrong size']);
        end
    end
    if(length(results.t)~=size(results.seis{1},1))
        errors=errors+1;
        disp('results.t has the wrong size');
    end
    if(length(results.tt)~=size(results.seis{1},1))
        errors=errors+1;
        disp('results.tt has the wrong size');
    end
    if(length(results.x)~=size(results.seis{1},2))
        errors=errors+1;
        disp('results.x has the wrong size');
    end
    if(length(results.xx)~=size(results.seis{1},2))
        errors=errors+1;
        disp('results.xx has the wrong size');
    end
    if(length(results.f)~=size(results.Afk{1},1))
        errors=errors+1;
        disp('results.f has the wrong size');
    end
    if(errors)
        if(~strcmp(action,'init'))
            msgbox('Errors found in seisplotfkfilt');
        end
    end
end
end

%% start of functions


function val=fromenhance
hfig=gcf;
val=false;
if(strcmp(get(hfig,'tag'),'fromenhance'))
    val=true;
end
end

function showtvspectrum(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hi=gco;
%hi=findobj(hseis2,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');

dname=haxe.Title.String;

NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplottvs(seis,t,x,dname{2},nan,nan);
NEWFIGVIS='on';
hfig=gcf;
colormap(datar{1},cmap);
customizetoolbar(hfig);
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

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function showfxamp(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');


dname=haxe.Title.String;
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfx(seis,t,x,dname{2});
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);

%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    hsane=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',hsane);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname{2});
end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)
if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function showfxphase(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
dname=haxe.Title.String;

NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfx(seis,t,x,dname{2},nan,nan,nan,nan,1);
NEWFIGVIS='on';
colormap(datar{1},cmap);
hfig=gcf;
customizetoolbar(hfig);

%determine if this is from sane
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    hsane=get(hs,'userdata');
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',hsane);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dname{2});
end
set(hfig,'visible','on');
%register the new figure with parent
updatefigureuserdata(hmasterfig,hfig)

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function showtraces(~,~,flag)
hthisfig=gcf;
hseis=gca;
%get the data
hi=findobj(gca,'type','image');
x=get(hi,'xdata');
t=get(hi,'ydata');
seis=get(hi,'cdata');

% dname=get(hthisfig,'name');
% 
% ind=strfind(dname,' for ');
% dname2=dname(ind(1)+5:end);

%get current point
pt=seisplottraces('getlocation',flag);
ixnow=near(x,pt(1,1));

%determine pixels per second
un=get(hseis,'units');
set(hseis,'units','pixels');
pos=get(hseis,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(hseis,'units',un);

iuse=ixnow(1)-0:ixnow(1)+0;
% iuse=ixnow;
pos=get(hthisfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);

name=hseis.Title.String;
if(iscell(name))
    nametrace=name{1};
else
    nametrace=name; 
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

function vout=roundv(vin)

if(vin>10)
    %its a velocity
    if(vin<1000)
        vout=10*round(vin/10);
    elseif(1000<=vin)&&(vin<=10000)
        vout=100*round(vin/100);
    else
        vout=1000*round(vin/1000);
    end
else
    %its a slope
    if(vin<.01)
        vout=round(10000*vin)/10000;
    elseif(vin<.1)
        vout=round(1000*vin)/1000;
    elseif(vin<1)
        vout=round(100*vin)/100;
    else
        vout=round(10*vin)/10;
    end
        
end

end

function vfanfont(~,~)
hfig=gcf;
hmenu=gcbo;
hdraw=findobj(hfig,'tag','drawvfan');
ud=get(hdraw,'userdata');
ud{5}=str2double(get(hmenu,'label'));
set(hdraw,'userdata',ud);
seisplotfkfilt('drawvfan');
seisplotfkfilt('redrawpicks');
end

function vfanbgc(~,~)
hfig=gcf;
hmenu=gcbo;
hdraw=findobj(hfig,'tag','drawvfan');
ud=get(hdraw,'userdata');
ud{6}=get(hmenu,'label');
set(hdraw,'userdata',ud);
seisplotfkfilt('drawvfan');
seisplotfkfilt('redrawpicks');
end

function setvmax(~,~,pt)
hfig=gcf;
hvmax=findobj(hfig,'tag','vmax');
hvmax0=findobj(hfig,'tag','vmax0');
vname=hvmax0.String;
if(nargin==0)
    v=str2double(hvmax.String);
else
    if(nargin<3)
        pt=get(gca,'currentpoint');
    end
    v=abs(pt(1,2)/pt(1,1));
end
hvmin=findobj(hfig,'tag','vmin');
hvmin0=findobj(hfig,'tag','vmin0');
vminname=hvmin0.String;
vmin=str2double(hvmin.String');
if(isinf(v))
    msgbox(['Infinite apparent velocity not allowed for ' vname(1:end-1)]);
    return
end
if(v<=vmin)
    msgbox([vname(1:end-1) ' must be greater than ' vminname(1:end-1)]);
    return
end
hvmax.String=num2str(roundv(v));

seisplotfkfilt('setvmax');
    

end

function setvmin(~,~,pt)
hfig=gcf;
hvmin=findobj(hfig,'tag','vmin');
hvmin0=findobj(hfig,'tag','vmin0');
vname=hvmin0.String;
if(nargin==0)
    v=str2double(hvmin.String);
else
    if(nargin<3)
        pt=get(gca,'currentpoint');
    end
    v=abs(pt(1,2)/pt(1,1));
end

hvmax=findobj(hfig,'tag','vmax');
hvmax0=findobj(hfig,'tag','vmax0');
vmaxname=hvmax0.String;
vmax=str2double(hvmax.String');

if(isinf(v))
    msgbox(['Infinite apparent velocity not allowed for ' vname(1:end-1)]);
    return
end
if(v>=vmax)
    msgbox([vname(1:end-1) ' must be less than ' vmaxname(1:end-1)]);
    return
end
hvmin.String=num2str(roundv(v));

seisplotfkfilt('setvmin');
    

end

function setsigmax(~,~,pt)
hfig=gcf;
haxfk=gca;
hsigmax=findobj(hfig,'tag','sigmax');
hxlim=findobj(hfig,'tag','xlim');
udat=hxlim.UserData;
xnyq=udat(1);
% hsigmax0=findobj(hfig,'tag','sigmax0');
% sigmaname=hsigmax0.String;
if(nargin==0)
    sigmax=str2double(hsigmax.String)*xnyq;
else
    if(nargin<3)
        pt=get(haxfk,'currentpoint');
    end
    sigmax=abs(pt(1,1));
end


% hline=findobj(haxfk,'tag',sigmaname);
% if(isgraphics(hline))
%     delete(hline);
% end

% hylim=findobj(hfig,'tag','ylim');
% udat=hylim.UserData;
% ynyq=udat(1);
% yl=[0 ynyq];
% hfig.CurrentAxes=haxfk;
% line(sigmax*[1 1],yl,'color','r','linestyle','--','linewidth',1,'tag',sigmaname);
% line(-sigmax*[1 1],yl,'color','r','linestyle','--','linewidth',1,'tag',sigmaname);

hsigmax.String=num2str(sigmax/xnyq);

seisplotfkfilt('setsigmax');

end

function setsigmay(~,~,pt)
hfig=gcf;
haxfk=gca;
hsigmay=findobj(hfig,'tag','sigmay');
hylim=findobj(hfig,'tag','ylim');
udat=hylim.UserData;
ynyq=udat(1);
% hsigmay0=findobj(hfig,'tag','sigmay0');
% sigmaname=hsigmay0.String;
if(nargin==0)
    sigmay=str2double(hsigmay.String)*ynyq;
else
    if(nargin<3)
        pt=get(haxfk,'currentpoint');
    end
    sigmay=abs(pt(1,2));
end


% hline=findobj(haxfk,'tag',sigmaname);
% if(isgraphics(hline))
%     delete(hline);
% end
% hxlim=findobj(hfig,'tag','xlim');
% udat=hxlim.UserData;
% xnyq=udat(1);
% xl=[-xnyq xnyq];

% hfig.CurrentAxes=haxfk;
% line(xl,sigmay*[1 1],'color','r','linestyle','--','linewidth',1,'tag',sigmaname);

hsigmay.String=num2str(sigmay/ynyq);

seisplotfkfilt('setsigmay');

end

function results=saveparameters(results)
hfig=gcf;
% hresults=findobj(hfig,'tag','results');
% results=hresults.UserData;
n=length(results.seis);
%harvest parameters
fn={'vmax','vmin','dv','vflag','xpct','tpct','sigmax','sigmay','whiten','delkx','delky','stab','filtertype'};
for k=1:length(fn)
    if(strcmp(fn{k},'filtertype'))
        hfan=findobj(hfig,'tag','fan');
        hp=hfan.Parent;
        if(hp.SelectedTab==hfan)
            results.filtertype(n)=1;
        else
            results.filtertype(n)=2;
        end
    else
        h=findobj(hfig,'tag',fn{k});
        switch h.Style
            case 'edit'
                tmp=h.String;
                results.(fn{k})(n)=str2double(tmp);
            case 'popupmenu'
                tmp=h.Value;
                if(strcmp(fn{k},'vflag'))
                    results.(fn{k})(n)=tmp-2;
                else
                    results.(fn{k})(n)=tmp;
                end
            case 'radiobutton'
                results.(fn{k})(n)=h.Value;
        end
    end
end
% hresults.UserData=results;
end

function startpick(~,~)
hax=gca;
if(strcmp(get(hax,'tag'),'fk'))
    msgbox('This only works in the Seismic axes not the FK axes');
    return;
end
drawlineinit('seisplotfkfilt(''finishpick'');');
drawline('init');
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
        results.namefk{1}=names;
    else
        names{iresult}=a{1};
        hresults.String=names;
        results.namefk{iresult}=names{iresult};
    end
    hresults.UserData=results;
end
    
end
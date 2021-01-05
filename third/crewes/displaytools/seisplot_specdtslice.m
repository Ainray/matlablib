function datar=seisplot_specdtslice(slices,t,x,y,dname)
% seisplot_specdtslice: Interactive spectral decomp on time slices
%
% datar=seisplot_specdtslice(slices,t,x,y,dname)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The input seismic
% volume is displayed in the left-hand-side and the corresponding spectral decomp volume is shown
% the the right-hand side. Initial SpecD parameters come either from internal defaults or global
% variables. Controls are provided to explore both volumes and to compute new SpecD volumes with
% different parameters.
%
% slices ... 3D seismic matrix of time slices, should be short in the first dimension (time)
% t ... first dimension (time) coordinate vector for slices
% x ... second dimension (xline) coordinate vector for slices
% y ... third dimension (inline) coordinate vector for slices
% dname ... text string nameing the slices matrix.
%   *********** default = 'Input data' **************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the input seismic axes
%           data{2} ... handle of the specd axes
% These return data are provided to simplify plotting additional lines and text in either axes.
% 
% NOTE: The key parameters for the spectral decomp computation are twin, tinc, fmin, fmax, and delf
% and the starting values for these can be controlled by defining the global variables below. These
% globals have names that are all caps. The default value applies when the corresponding global is
% either undefined or empty.
% SPECD_TWIN ... half-width of the Gaussian windows (standard deviation) in seconds
%  ************ default = 0.01 seconds ************
% SPECD_TINC ... increment between adjacent Gaussians
%  ************ default = 2*dt seconds (dt is the time sample size of the data) ***********
% SPECD_FMIN ... minimum frequency in the SpecD volume.  (in Hertz)
%  ************ default 5 Hz *************
% SPECD_FMAX ... maximum signal frequency in the dataset. (in Hertz)
%  ************ default 0.25/dt Hz which is 1/2 of Nyquist *************
% SPECD_DELF ... increment between frequencies in Hertz
% ************* default 5 Hz ***************
%
% G.F. Margrave, Margrave-Geo, 2018
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

% global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED %#ok<NUSED>
global SPECD_TWIN SPECD_TINC SPECD_FMIN SPECD_FMAX SPECD_DELF
global NEWFIGVIS WaitBarContinue XCFIG YCFIG BIGFIG_WIDTH BIGFIG_HEIGHT  %#ok<NUSED>
if(~ischar(slices))
    action='init';
else
    action=slices;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(nargin<4)
        error('at least 4 inputs are required');
    end
    if(nargin<5)
        dname='Input data';
    end
    
%     x2=x1;
%     t2=t1;
    dt=t(2)-t(1);
    fnyq=.5/dt;
    if(isempty(SPECD_FMAX))
        fmax=round(.25*fnyq);
    else
        fmax=SPECD_FMAX;
    end
    if(isempty(SPECD_FMIN))
        fmin=5;
    else
        fmin=SPECD_FMIN;
    end
    if(isempty(SPECD_DELF))
        delf=5;
    else
        delf=SPECD_DELF;
    end
    if(isempty(SPECD_TWIN))
        twin=0.01;
    else
        twin=SPECD_TWIN;
    end
    if(isempty(SPECD_TINC))
        tinc=2*dt;
    else
        tinc=SPECD_TINC;
    end

    
    if(length(t)~=size(slices,1))
        error('time coordinate vector does not match time slices matrix');
    end
    if(length(x)~=size(slices,2))
        error('xline coordinate vector does not match time slices matrix');
    end
    if(length(y)~=size(slices,3))
        error('inline coordinate vector does not match time slices matrix');
    end
    [nt,nx,ny]=size(slices); %#ok<ASGLU>
    
    if(iscell(dname))
        dname=dname{1};
    end

    xwid=.35;
    yht=.8;
    xsep=.05;
    xnot=.11;
    ynot=.1;
    
    
    %test to see if we are from enhance. This enables the fromenhance local logical function to work
    ff=figs;
    if(~isempty(ff))
       tag=get(gcf,'tag');%presumably the current figure launched this
       if(strcmp(tag,'fromenhance'))
           %so the current figure is from enhance and we assume it has called this one
           enhancetag='fromenhance';
           udat={-999.25,gcf};
       else
           enhancetag='';
           udat=[];
       end
    end

    vis='on';
    if(~isempty(XCFIG))
        if(isempty(BIGFIG_WIDTH))
            figwid=1900;
            fight=900;
        else
            figwid=BIGFIG_WIDTH;
            fight=BIGFIG_HEIGHT;
        end
        figx=XCFIG-.5*figwid;
        figy=YCFIG-.5*fight;
        figure('position',[figx,figy,figwid,fight],'visible',vis);
    else
        figure;
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat);
    
    hax1=subplot('position',[xnot ynot xwid yht]);

    inot=near(t,t(round(nt/2)));
    inot=inot(1);
    seis1=squeeze(slices(inot,:,:))';
        
    hi=imagesc(x,y,seis1);
    hcm=uicontextmenu;
    uimenu(hcm,'label','2D Spectrum','callback',@spec2d); 
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap);
%     brighten(.5);
    grid
    ht=enTitle(dname);
    ht.Interpreter='none';
    xlabel('crossline')
    ylabel('inline')
    
    
    wid=.055;ht=.05;sep=.005;  
    %make a clip control
    xnow=xnot-1.85*wid;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    climxt=[-3 3];
    hclip1=uipanel(hfig,'position',[xnow,ynow,1.45*wid,htclip],'tag','clip1',...
        'userdata',{climxt,hax1},'title','Clipping');
    data={climxt,hax1};
    callback='';
    cliptool(hclip1,data,callback);
    hfig.CurrentAxes=hax1;
     
    ht=.5*ht;
%     ynow=ynow-sep;
%     ilive=seis1~=0;
%     uicontrol(hfig,'style','radiobutton','string','Auto adjust clip','tag','autoclip1','units','normalized',...
%         'position',[xnow,ynow,1.5*wid,ht],'value',0,'userdata',ilive,...
%         'tooltipstring','clip level auto adjusted with each time slice')
      
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+5.5*ht,.5*wid,ht],'callback','seisplot_specdtslice(''info'');',...
        'backgroundcolor','y');
    
    ynow=ynow-ht-sep;
    
    set(hax1,'tag','seis1');
    
    %time location thermometer
    xnow=xnow+.25*wid-sep;
    widtherm=.9*wid;
    httherm=16*ht;
    ytherm=ynow-httherm;
    htherm=uithermometer(hfig,[xnow,ytherm,widtherm,httherm],'Time',t,30,'seisplot_specdtslice(''jump'');');
    set(htherm,'tag','thermt');
    
    %prev and next buttons
    wid=.055;ht=.05;sep=.005;
%     xnow=xnot+xwid+.1*wid;
    ynow=ytherm-5*sep;
    uicontrol(hfig,'style','pushbutton','string','Next time','tag','next','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_specdtslice(''step'');',...
        'tooltipstring','Step to greater time','userdata',{slices,t,x,y,dname,inot});
    ynow=ynow-.5*ht;
    uicontrol(hfig,'style','pushbutton','string','Previous time','tag','prev','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_specdtslice(''step'');',...
        'tooltipstring','Step to lesser time');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);

    xlabel('line coordinate')
    
    
    %make a clip control

    xnow=xnot+2*xwid+xsep+sep;
    wid=.055;ht=.05;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    climsd=[-.5 7];%default for new results
    hclip2=uipanel(hfig,'position',[xnow,ynow,2*wid,htclip],'tag','clip2',...
        'userdata',{climsd,hax2},'title','Clipping');
    data={climsd,hax2,[],0,1,1};
    callback='seisplot_specdtslice(''clip2'');';
    cliptool(hclip2,data,callback);
    hfig.CurrentAxes=hax2;
    %wid=.045;sep=.005;
    %     uicontrol(hfig,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
    %         'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''clip2'');','value',iclip,...
    %         'userdata',{clips,am,sigma,amax,amin,hax2,[]},'tooltipstring',...%the values here in userdata are placeholders. See 'computespecd' for the real thing
    %         'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
     
    ht=.5*ht;
    ynow=ynow-sep;
    %ynow=ynow-ht;
    %     uicontrol(hfig,'style','radiobutton','string','Auto adjust clip','tag','autoclip2','units','normalized',...
    %         'position',[xnow,ynow,1.5*wid,ht],'value',0,'userdata',ilive,...
    %         'tooltipstring','clip level auto adjusted with each time slice')
    %specd parameters
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','SpecD parameters:','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'tooltipstring',...
        'Change these values and then click "Compute SpecD"','horizontalalignment','left');
    ynow=ynow-ht-sep;
    wid=wid*.5;
    uicontrol(hfig,'style','text','string','Twin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Gaussian window half-width in seconds');
    uicontrol(hfig,'style','edit','string',num2str(twin),'units','normalized','tag','twin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds corresponding to a few samples');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Tinc:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Increment between consequtive windows in seconds');
    uicontrol(hfig,'style','edit','string',num2str(tinc),'units','normalized','tag','tinc',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds smaller than Twin');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fmin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Minimum frequency of interest');
    uicontrol(hfig,'style','edit','string',num2str(fmin),'units','normalized','tag','fmin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Maximum frequency of interest');
    uicontrol(hfig,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','delF:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Frequency increment');
    uicontrol(hfig,'style','edit','string',num2str(delf),'units','normalized','tag','delf',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Compute SpecD','units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'callback','seisplot_specdtslice(''computespecd'');',...
        'tooltipstring','Compute SpecD with current parameters','tag','specdbutton',...
        'backgroundcolor','y');
    
    %colormap controls
    cmapchoices=ones(2,1)*[1 0];
    if(fromenhance)
        colormaps=enhance('getcolormaplist');
        cmapdefaults=cell(1,3);
        cmapdefaults{1}=enhance('getdefaultcolormap','timeslices');
        cmapdefaults{2}=enhance('getdefaultcolormap','ampspectra');
        for k=1:length(colormaps)
            if(strcmp(colormaps{k},cmapdefaults{1}{1}))
                cmapchoices(1,1)=k;
                cmapchoices(1,2)=cmapdefaults{1}{2};%flipped flag
            end
            if(strcmp(colormaps{k},cmapdefaults{2}{1}))
                cmapchoices(2)=k;
                cmapchoices(2,2)=cmapdefaults{2}{2};%flipped flag
            end
        end
    else
        cmapdefaults=cell(1,2);
        cmapdefaults{1}={'bluebrown',0};
        cmapdefaults{2}={'blueblack',1};
    end
    
    %colormaps
    ynow=.35;
    pos=[xnow,ynow,2.5*wid,8*ht];
    cb1='';cb2='';
    cm1=cmapdefaults{1}{1};
    iflip1=cmapdefaults{1}{2};
    cm2=cmapdefaults{2}{1};
    iflip2=cmapdefaults{2}{2};
    cbflag=[0,1];
    cbcb='';
    cbaxe=[hax1,hax2];
    enhancecolormaptool(hfig,pos,hax1,hax2,cb1,cb2,cm1,cm2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    
    %spectra
    ynow=ynow-2*ht-sep;
    wid=2.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Browse spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''browse'');',...
        'tooltipstring','Start browsing spectra at specific points','tag','browse',...
        'userdata',{[],[],'Point Set New'});
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','pushbutton','string','Save spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''savespec'');',...
        'tooltipstring','Save the current set of points for recall later','tag','savespec',...
        'visible','off');
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','popupmenu','string','Point Set New','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''choosespec'');',...
        'tooltipstring','Choose the set of points to work with','tag','choosespec',...
        'userdata',{[]},'visible','off');
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(hfig,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplot_specdtslice(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplot_specdtslice(''equalzoom'');');
    
    %results popup
    wida=.065;
    xnow=pos(1);
    ynow=pos(2)+pos(4)-.5*ht;
    wid2=pos(3);
%     wid2=pos(3)-wida-.25*xsep;
    ht=3*ht;
    fs=10;
    fontops={'x2','x1.5','x1.25','x1.11','x1','x0.9','x0.8','x0.67','x0.5'};
    hcm=uicontextmenu(hfig);
    for k=1:length(fontops)
        uimenu(hcm,'label',fontops{k},'callback',@fontchange,'userdata',hax2);
    end
    uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on')
    uicontrol(hfig,'style','popupmenu','string','...','units','normalized','tag','results',...
        'position',[xnow,ynow,wid2,ht],'callback','seisplot_specdtslice(''select'');','fontsize',fs,...
        'fontweight','bold','uicontextmenu',hcm);
    %delete button
    wid=.075;
    xnow=pos(1)+pos(3);
    ht=ht/3;
%     ynow=ynow+4*ht;
    ynow=ynot+yht+2.15*ht;
    %userdata of the delete button is the number of the current selection
    uicontrol(hfig,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnow,ynow-.75*ht,wid,ht],'callback','seisplot_specdtslice(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    %make frequency stepping controls
    ht=.025;wid=.055;
    xnow=xnot+2*xwid+1.4*wid+xsep;
    %ynow=ynot+yht+ht;
    ynow=ytherm-5*sep;
    uicontrol(hfig,'style','pushbutton','string','Next frequency','tag','nextf','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''stepf'');',...
        'tooltipstring','step the the next higher frequency');
    ynow=ynow-ht;
    uicontrol(hfig,'style','pushbutton','string','Prev frequency','tag','prevf','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''stepf'');',...
        'tooltipstring','step the the next lower frequency');
    
%     xnow=pos(1)+wid2+.25*xsep;
    xnow=pos(1)+.5*pos(3)-.5*wida;
    ff=fmin:delf:fmax;
    nf=length(ff);
    fnow=ff(round(nf/2));
    ynow=ynot+yht-.35*ht;
    uicontrol(hfig,'style','text','string',['Fnow= ' num2str(fnow) 'Hz'],'tag','fnow','units','normalized',...
        'position',[xnow,ynow+.5*ht,2*wida,ht],'tooltipstring','This is the displayed frequency',...
        'userdata',round(nf/2),'fontsize',12,'fontweight','bold');
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
%     boldlines(hfig,4,2); %make lines and symbols "fatter"
%     whitefig;
    
    set(hax2,'tag','seis2');
    seisplot_specdtslice('computespecd');

    set(hfig,'name',['Spectral decomp for ' dname],...
        'closerequestfcn','seisplot_specdtslice(''close'');','menubar','none','toolbar',...
        'figure','numbertitle','off');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
% elseif(strcmp(action,'clip1'))
%     hmasterfig=gcf;

% elseif(strcmp(action,'autoclip1'))
%     hfig=gcf;
    
elseif(strcmp(action,'clip2'))
    hmasterfig=gcf;
    
    hclip=findobj(hmasterfig,'tag','clip2');
    udat=get(hclip,'userdata');
    clim=cliptool('getlims',hclip);
    udat{1}=clim;
    hclip.UserData=udat;


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

elseif(strcmp(action,'step'))
    %this is a time step activated by the 'Next time' and 'Previous time' buttons
    hmasterfig=gcf;
    hbut=gcbo;
    step='d';
    if(strcmp(get(hbut,'tag'),'prev'))
        step='u';
    end
    %step the seismic
    hseis1=findobj(hmasterfig,'tag','seis1');
    hnext=findobj(hmasterfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    inot=udat{6};
    if(step=='u')
        inot=max([1,inot-1]);
    else
        inot=min([length(t),inot+1]);
    end
    udat{6}=inot;
    set(hnext,'userdata',udat);
    tnot=t(inot);
    ht=hseis1.Title.String;
    if(iscell(ht))
        ht=ht{1};
    end
    ind=strfind(ht,'tslice');
    ht=[ht(1:ind(1)+6) time2str(tnot)];
%     ht{2}=['time= ' time2str(tnot)];
    hseis1.Title.String=ht;
    seis1=squeeze(slices(inot,:,:))';
    hi=findobj(hseis1,'type','image');
    hi.CData=seis1;
    %update cliptool
    hclip1=findobj(hmasterfig,'tag','clip1');
    uc=get(hclip1,'userdata');
    clim=uc{1};
    clipdata={clim,hseis1};
    cliptool('refresh',hclip1,clipdata);
%     seisplot_specdtslice('autoclip1');
    %step the specd
    hresults=findobj(hmasterfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hfnow=findobj(hmasterfig,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    hseis2=findobj(hmasterfig,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update cliptool
    hclip2=findobj(hmasterfig,'tag','clip2');
    uc=get(hclip2,'userdata');
    clim=uc{1};
    clipdata={clim,hseis2,[],0,1,1};
    cliptool('refresh',hclip2,clipdata);
    hthermt=findobj(hmasterfig,'tag','thermt');
    uithermometer('set',hthermt,tnot);
%     seisplot_specdtslice('autoclip2');
    seisplot_specdtslice('updatespectra');
elseif(strcmp(action,'jump'))
    %this is a time step activated by the '^' and 'v' buttons
    hmasterfig=gcf;
    hbut=gcbo;
    tnot=get(hbut,'userdata');
    %step the seismic
    hseis1=findobj(hmasterfig,'tag','seis1');
    hnext=findobj(hmasterfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    dt=abs(t(2)-t(1));
    inot=round((tnot-t(1))/dt)+1;
    udat{6}=inot;
    set(hnext,'userdata',udat);
    ht=hseis1.Title.String;
    if(iscell(ht))
        ht=ht{1};
    end
    ind=strfind(ht,'tslice');
    ht=[ht(1:ind(1)+6) time2str(tnot)];
    hseis1.Title.String=ht;
    seis1=squeeze(slices(inot,:,:))';
    hi=findobj(hseis1,'type','image');
    hi.CData=seis1;
    %update cliptool
    hclip1=findobj(hmasterfig,'tag','clip1');
    uc=get(hclip1,'userdata');
    clim=uc{1};
    clipdata={clim,hseis1};
    cliptool('refresh',hclip1,clipdata);
    seisplot_specdtslice('autoclip1');
    %step the specd
    hresults=findobj(hmasterfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hfnow=findobj(hmasterfig,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    hseis2=findobj(hmasterfig,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update cliptool
    hclip2=findobj(hmasterfig,'tag','clip2');
    uc=get(hclip2,'userdata');
    clim=uc{1};
    clipdata={clim,hseis2,[],0,1,1};
    cliptool('refresh',hclip2,clipdata);
    seisplot_specdtslice('autoclip2');
    seisplot_specdtslice('updatespectra');
elseif(strcmp(action,'stepf'))
    %a frequency step activated by the 'Next frequency' and 'Previous frequency'
    hmasterfig=gcf;
    hbut=gcbo;
    if(strcmp(get(hbut,'tag'),'nextf'))
        step='u';
    else
        step='d';
    end
    %get current time
    hnext=findobj(hmasterfig,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %get results
    hresults=findobj(hmasterfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    %determine current and new frequency
    fout=results.fouts{iresult};
    hfnow=findobj(hmasterfig,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    if(step=='u')
        ifnow=min([length(fout),ifnow+1]);
    else
        ifnow=max([1,ifnow-1]);
    end
    %update display
    set(hfnow,'string',['Fnow= ' num2str(fout(ifnow)) 'Hz'],'userdata',ifnow);
    hseis2=findobj(hmasterfig,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot(1),:,:,ifnow(1)))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update cliptool
    hclip2=findobj(hmasterfig,'tag','clip2');
    uc=get(hclip2,'userdata');
    clim=uc{1};
    clipdata={clim,hseis2,[],0,1,1};
    cliptool('refresh',hclip2,clipdata);
    seisplot_specdtslice('autoclip2');
    hthermf=results.thermfs{iresult};
    uithermometer('set',hthermf,fout(ifnow));
elseif(strcmp(action,'jumpf'))
    %a frequency step activated by the '^' and 'v' buttons
    hmasterfig=gcf;
    hbut=gcbo;
    fnow=get(hbut,'userdata');%frequency we are jumping to
    %get current time
    hnext=findobj(hmasterfig,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %get results
    hresults=findobj(hmasterfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    %determine current frequency
    fout=results.fouts{iresult};
    hfnow=findobj(hmasterfig,'tag','fnow');
    ifnow=near(fout,fnow);
    %update display
    set(hfnow,'string',['Fnow= ' num2str(fout(ifnow(1))) 'Hz'],'userdata',ifnow(1));
    hseis2=findobj(hmasterfig,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot(1),:,:,ifnow(1)))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update cliptool
    hclip2=findobj(hmasterfig,'tag','clip2');
    uc=get(hclip2,'userdata');
    clim=uc{1};
    clipdata={clim,hseis2,[],0,1,1};
    cliptool('refresh',hclip2,clipdata);
    seisplot_specdtslice('autoclip2');
elseif(strcmp(action,'computespecd'))
    %plan: apply the specd parameters and display the results for the mean frequency
    hfig=gcf;
    if(strcmp(get(hfig,'tag'),'climchooser'))
        ud=get(hfig,'userdata');
        for k=1:length(ud)
            if(isgraphics(ud(k)))
                if(~strcmp(get(ud(k),'tag'),'info'))
                    hfig=ud(k);
                    break
                end
            end
        end
    end
    hseis2=findobj(hfig,'tag','seis2');
    hseis1=findobj(hfig,'tag','seis1');
    hnext=findobj(hfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    x=udat{3};
    y=udat{4};
    %dname=udat{5};
    inot=udat{6};
    tmax=max(t);
    tmin=min(t);
    tlen=tmax-tmin;
    dt=t(2)-t(1);
    fnyq=.5/dt;
    
    %get the window size
    hw=findobj(hfig,'tag','twin');
    val=get(hw,'string');
    twin=str2double(val);
    if(isnan(twin))
        msgbox('Twin is not recognized as a number','Oh oh ...');
        return;
    end
    if(twin<0 || twin>.25*tlen)
        msgbox({'Twin is unreasonable, must be positive and less than (Tmax-Tmin)/4',['Here Tmax= ' ...
            num2str(tmax) ', and Tmin= ' num2str(tmin) '.'],'You chose these values when you launched this tool.'});
        return;
    end
    %get the window increment
    hw=findobj(hfig,'tag','tinc');
    val=get(hw,'string');
    tinc=str2double(val);
    if(isnan(tinc))
        msgbox('Tinc is not recognized as a number','Oh oh ...');
        return;
    end
    if(tinc<0 || tinc>twin)
        msgbox('tinc is unreasonable, must be positive and less than Twin');
        return;
    end
    %get fmin
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
    %get fmax
    hobj=findobj(hfig,'tag','fmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        msgbox('Fmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmax<0 || fmax>fnyq)
        if((fmax-fnyq)>10000*eps)
            msgbox(['Fmax must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
            return;
        else
            fmax=fnyq;
        end
    end
    if(fmax<=fmin)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    %get delf
    hobj=findobj(hfig,'tag','delf');
    val=get(hobj,'string');
    delf=str2double(val);
    if(isnan(delf))
        msgbox('delF is not recognized as a number','Oh oh ...');
        return;
    end
    if(delf<0 )%|| length(fmin:delf:fmax)==0)
        msgbox('dFmin must be greater than 0','Oh oh ...');
        return;
    end
    fout=fmin:delf:fmax;
    if( isempty(fout))
        msgbox('Fmin:delF:Fmax is empty','Oh oh ...');
        return;
    end

    
    %compute specd
    t0=clock;
    ievery=1;
    nt=length(t);
    ny=length(y);
    nx=length(x);
    nf=length(fout);
    phaseflag=3;
    specd=zeros(nt,nx,ny,nf,'single');
    if(isempty(XCFIG))
       posw=[400 100];
    else
       posw=[XCFIG-200,YCFIG-50,400,100];
    end
    hbar=WaitBar(0,ny,'SpecD computation','Computing spectral decomp',posw);
    for k=1:ny %loop over inlines
        s2d=squeeze(slices(:,:,k));
        if(sum(abs(s2d(:)))>0) %avoid all zero s2d
            [amp,phs,tsd,f2d]=specdecomp(s2d,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,-1); %#ok<ASGLU>
            %Accumulate results
            for j=1:nf
                specd(:,:,k,j)=single(amp(:,:,j));
            end
            if(rem(k,ievery)==0)
                time_used=etime(clock,t0);
                time_per_line=time_used/k;
                timeleft=(ny-k-1)*time_per_line/60;
                timeleft=round(100*timeleft)/100;
                WaitBar(k,hbar,['Estimated time remaining ' num2str(timeleft) ' minutes']);
            end
            if(~WaitBarContinue)
                break;
            end
        end
    end
    delete(hbar);
    set(hfig,'currentaxes',hseis2)
    
    fnot=fout(round(nf/2));
    ifnot=near(fout,fnot);
    hfnow=findobj(hfig,'tag','fnow');
    set(hfnow,'string',['Fnow= ' num2str(fnot) 'Hz'],'userdata',ifnot)
    
    seis2=squeeze(specd(inot,:,:,ifnot))';
    
    hclip2=findobj(hfig,'tag','clip2');
    udat=get(hclip2,'userdata');
    clim=udat{1};
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    fs=get(hseis1,'fontsize');
    hi=imagesc(x,y,seis2);
    hcm=uicontextmenu;
    uimenu(hcm,'label','RGB Blends','callback',@RGB);
    uimenu(hcm,'label','2D Spectrum','callback',@spec2d);
    uimenu(hcm,'label','Compare tool','callback',@comparetool);
    set(hi,'uicontextmenu',hcm,'buttondownfcn',@showcolormap);
    xlabel('crossline');ylabel('inline');
    name=['Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ',Fmin= ', num2str(fmin) ...
        ', Fmax= ', num2str(fmax) ', delF= ', num2str(delf)];
    set(hseis2,'tag','seis2','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc,'fontsize',fs);
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    %build frequency thermometer
    hthermt=findobj(hfig,'tag','thermt');
    posth=get(hthermt,'position');
    posth(1)=.937;
    posth(3)=1*posth(3);
    htherm=uithermometer(hfig,posth,'Frequency',fout,30,'seisplot_specdtslice(''jumpf'');');
    set(htherm,'tag','thermf');
    

    %refresh the cliptool
    clipdata={clim,hseis2,[],0,1,1};
    cliptool('refresh',hclip2,clipdata);
    
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.data={specd};
        results.twins={twin};
        results.tincs={tinc};
        results.fmins={fmin};
        results.fmaxs={fmax};
        results.delfs={delf};
        results.fouts={fout};
        results.clims={clim};
        results.thermfs={htherm};
    else
        iresult=get(hresults,'value');
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.data{nresults}=specd;
        results.twins{nresults}=twin;
        results.tincs{nresults}=tinc;
        results.fmins{nresults}=fmin;
        results.fmaxs{nresults}=fmax;
        results.fouts{nresults}=fout;
        results.delfs{nresults}=delf;
        results.clims{nresults}=clim;
        results.thermfs{nresults}=htherm;
        set(results.thermfs{iresult},'visible','off');
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hcompute=findobj(hfig,'tag','specdbutton');
    set(hcompute,'userdata',nresults);%the current result number stored here
    enhancecolormaptool('setcmap',hseis2);
%     seisplot_specdtslice('setcolormap','seis2');%set the specd colormap
%     hcolorbars=findobj(hfig,'tag','colorbars');
%     if(hcolorbars.Value)
%         seisplot_specdtslice('colorbars');
%     end
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
    seisplot_specdtslice('select');
elseif(strcmp(action,'select'))
    hfig=gcf;
    hdelete=findobj(hfig,'tag','delete');
    if(strcmp(get(hfig,'tag'),'climchooser'))
        ud=get(hfig,'userdata');
        for k=1:length(ud)
            if(isgraphics(ud(k)))
                if(~strcmp(get(ud(k),'tag'),'info'))
                    hfig=ud(k);
                    break
                end
            end
        end
    end
    
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    hcompute=findobj(hfig,'tag','specdbutton');
    iresultold=get(hcompute,'userdata');
    set(hcompute,'userdata',iresult);
    hseis2=findobj(hfig,'tag','seis2');
    %     hi=findobj(hseis2,'type','image');
    %     seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
    %     set(hi,'cdata',seis2);
    hop=findobj(hfig,'tag','twin');
    set(hop,'string',num2str(results.twins{iresult}));
    hstab=findobj(hfig,'tag','tinc');
    set(hstab,'string',num2str(results.tincs{iresult}));
    hfmin=findobj(hfig,'tag','fmin');
    set(hfmin,'string',num2str(results.fmins{iresult}));
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(results.fmaxs{iresult}));
    hdfmax=findobj(hfig,'tag','delf');
    set(hdfmax,'string',num2str(results.delfs{iresult}));
    %get the proper time/frequency slice
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %     fout=results.fouts{iresult};
    hfnow=findobj(gcf,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
    %update clipping
    clipdat=results.clipdats{iresult};
    clips=clipdat{1};
    clipstr=clipdat{2};
    clip=clipdat{3};
    iclip=clipdat{4};
    sigma=clipdat{5};
    am=clipdat{6};
    amax=clipdat{7};
    amin=clipdat{8};
    clim=[am-clip*sigma am+clip*sigma];
    
    hi=findobj(hseis2,'type','image');
    hi.CData=seis2;
    
    %show the proper thermometer
    set(results.thermfs{iresultold},'visible','off');
    set(results.thermfs{iresult},'visible','on');
    %set themometer to current frequency
    uithermometer('set',results.thermfs{iresult},results.fouts{iresult}(ifnow));
    
    hclip2=findobj(gcf,'tag','clip2');
    %update graphical clip window
    hgfig=[];
    uc=get(hclip2,'userdata');
    if(length(uc)>6)
        if(isgraphics(uc{7}))
            hfig=gcf;
            hgfig=uc{7};
            figure(hgfig);
            idat=seis2~=0;
            [N,xn]=hist(seis2(idat),100); %#ok<*HIST>
            climslider('refresh',uc{7},N,xn);
            figure(hfig);
        end
    end
    iclipnow=get(hclip2,'value');
    if(iclipnow==1)
        iclip=iclipnow;
    else
        set(hseis2,'clim',clim);
    end
    set(hclip2,'string',clipstr','value',iclip,'userdata',{clips,am,sigma,amax,amin,hseis2,hgfig});
    set(hseis2,'clim',clim);
    seisplot_specdtslice('clip2');
    seisplot_specdtslice('updatespectra');
    %     %see if spectra window is open
    %     hspec=findobj(hfig,'tag','spectra');
    %     hspecwin=get(hspec,'userdata');
    %     if(isgraphics(hspecwin))
    %         seisplot_specdtslice('spectra');
    %     end
    %update hdelete userdata
    set(hdelete,'userdata',iresult);
elseif(strcmp(action,'browse'))
    hbrowse=gcbo;
    mode=get(hbrowse,'string');
    hclip2=findobj(gcf,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax1=findobj(gcf,'tag','seis1');
    hax2=udat2{6}(1);
    hsavespec=findobj(gcf,'tag','savespec');
    hchoose=findobj(gcf,'tag','choosespec');
    switch mode
        case 'Browse spectra'
            set(hbrowse,'string','Stop browse','tooltipstring','Click to close spectral window and stop browsing');
            set([hsavespec hchoose],'visible','on');
            %determine if specD is full or half
            pos=get(hax2,'position');
            if(pos(3)>.4)
            else
                %half
                pos1=get(hax1,'position');
                bdy=.05;
                fact=.75;
                hback=axes('position',[pos1(1)+.6*pos1(3)-fact*bdy,pos1(2)+.25*pos1(4)-bdy, .4*pos1(3)+fact*bdy,...
                    .35*pos1(4)+bdy],'tag','back');
                haxspec=axes('position',[pos1(1)+.6*pos1(3),pos1(2)+.25*pos1(4), .4*pos1(3),...
                    .35*pos1(4)],'tag','spectra');
                disableDefaultInteractivity(haxspec)
                set(hax1,'visible','off')
%                 haxspec=axes('position',pos1,'tag','spectra');
            end
            set(hback,'xtick',[],'ytick',[],'xcolor',[1 1 1],'ycolor',[1 1 1]);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','seisplot_specdtslice(''specpt'');');
            %display current set
            iset=get(hchoose,'value');
            setnames=get(hchoose,'string');
            if(iscell(setnames))
                thisname=setnames{iset};
            else
                thisname=setnames;
            end
            pointsets=get(hchoose,'userdata');
            seti=pointsets{iset};
            if(isempty(seti))
               return;
            end
            hm=zeros(size(seti));
            hs=hm;
            haxspecd=findobj(gcf,'tag','seis2');
            axes(haxspecd);
            for k=1:length(seti)
                hm(k)=line(seti{k}.x,seti{k}.y,'linestyle','none','marker',seti{k}.marker,...
                    'color',seti{k}.color,'markersize',seti{k}.msize,'linewidth',2);
            end
            axes(haxspec);
            hnext=findobj(gcf,'tag','next');
            udat=get(hnext,'userdata');
            x=udat{3};
            y=udat{4};
            inot=udat{6};%current time
            hresult=findobj(gcf,'tag','results');
            results=get(hresult,'userdata');
            iresult=get(hresult,'value');
            for k=1:length(hs)
                iy=near(y,seti{k}.y);
                ix=near(x,seti{k}.x);
                spec=squeeze(results.data{iresult}(inot,ix,iy,:));
                hs(k)=line(results.fouts{iresult},spec,'linestyle','-','marker',seti{k}.marker,...
                    'color',seti{k}.color,'buttondownfcn','seisplot_specdtslice(''idspect'');');
            end
            
            set(hbrowse,'userdata',{hm hs thisname});
        case 'Stop browse'
            set(hbrowse,'string','Browse spectra','tooltipstring','Start browsing spectra at specific points');
            set([hsavespec hchoose],'visible','off');
            hback=findobj(gcf,'tag','back');
            delete(hback);
            haxspec=findobj(gcf,'tag','spectra');
            delete(haxspec);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','');
            set(hax1,'visible','on')
            udat=get(hbrowse,'userdata');
            if(~isempty(udat))
                delete(udat{1});
            end
            udat{1}=[];
            udat{2}=[];
            set(hbrowse,'userdata',udat);
    end
elseif(strcmp(action,'specpt'))
    kols=get(gca,'colororder');
    mkrs={'.','o','x','+','*','s','d','v','^','<','>','p','h'};
    nk=size(kols,1);
    nm=length(mkrs);
    hbrowse=findobj(gcf,'tag','browse');
    udatb=get(hbrowse,'userdata');
    if(isempty(udatb{1}))
       nlines=1;
    else
       nlines=length(udatb{1})+1; 
    end
    ik=nlines;
    if(ik>nk)
        ik=nlines-nk;
        if(ik>nk)
            ik=nlines-2*nk;
        end
    end
    im=nlines;
    if(im>nm)
        im=nlines-nm;
        if(im>nm)
            im=nlines-2*nm;
        end
    end
    hseissd=gca;
    pt=get(hseissd,'currentpoint');
    hm=line(pt(1,1),pt(1,2),'linestyle','none','marker',mkrs{im},'color',kols(ik,:),'markersize',10,'linewidth',2);
    
    %get the x and y coordinates
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    x=udat{3};
    y=udat{4};
    inot=udat{6};%current time
    hresult=findobj(gcf,'tag','results');
    results=get(hresult,'userdata');
    iresult=get(hresult,'value');
    iy=near(y,pt(1,2));
    ix=near(x,pt(1,1));
    spec=squeeze(results.data{iresult}(inot,ix,iy,:));
    haxspec=findobj(gcf,'tag','spectra');
    axes(haxspec)
    hs=line(results.fouts{iresult},spec,'linestyle','-','marker',mkrs{im},'color',kols(ik,:));
    set(hs,'buttondownfcn','seisplot_specdtslice(''idspect'');');
    if(isempty(udatb))
        udatb{1}=hm;
        udatb{2}=hs;
        xlabel('Frequency');ylabel('Amplitude')
    else
        udatb{1}=[udatb{1} hm];
        udatb{2}=[udatb{2} hs];
        xlabel('Frequency');ylabel('Amplitude')
    end
    set(hbrowse,'userdata',udatb);    
elseif(strcmp(action,'updatespectra'))
    haxspec=findobj(gcf,'tag','spectra');
    if(isempty(haxspec))
        return;
    end
    hnext=findobj(gcf,'tag','next');
    ud=get(hnext,'userdata');
    inot=ud{6};%index of current time 
    x=ud{3};
    y=ud{4};
    hbrowse=findobj(gcf,'tag','browse');
    hresult=findobj(gcf,'tag','results');
    iresult=get(hresult,'value');
    results=get(hresult,'userdata');
    udat=get(hbrowse,'userdata');
    hm=udat{1};%handles of the markers in the specd axes
    hs=udat{2};%handles of the spectral curves in the spectra axes
    for k=1:length(hm)
        xp=get(hm(k),'xdata');
        yp=get(hm(k),'ydata');
        ix=near(x,xp);
        iy=near(y,yp);
        set(hs(k),'ydata',squeeze(results.data{iresult}(inot,ix,iy,:)));
    end
elseif(strcmp(action,'idspect'))
    hthisspec=gco;
    hbrowse=findobj(gcf,'tag','browse');
    udat=get(hbrowse,'userdata');
    hm=udat{1};%handles of the markers in the specd axes
    hs=udat{2};%handles of the spectral curves in the spectra axes
    im=find(hthisspec==hs);
    if(isempty(im))
        return;
    end
    msize=get(hm(im),'markersize');
    set(hm(im),'markersize',2*msize);
    uiwait(gcf,1);
    set(hm(im),'markersize',msize);
elseif(strcmp(action,'savespec'))
    haxspec=findobj(gcf,'tag','spectra');
    if(isempty(haxspec))
        return;
    end
    hchoose=findobj(gcf,'tag','choosespec');
    setnames=get(hchoose,'string');
    if(~iscell(setnames))
        setnames={setnames};
    end
    iset=get(hchoose,'value');
    a=askthingsle('questions',{'Name the point set'},'answers',{setnames{iset}});
    if(isempty(a))
        return;
    end
    %check for no name change
    newname=a{1};
    iset=length(setnames)+1;
    for k=1:length(setnames)
       if(strcmp(a{1},setnames{k}))
          iset=k;
          newname=setnames{k};
       end
    end
    setnames{iset}=newname;
    hbrowse=findobj(gcf,'tag','browse');
    udat=get(hbrowse,'userdata');
    hm=udat{1};%handles of the markers in the specd axes
    udat{3}=newname;
    set(hbrowse,'userdata',udat);
    thisset=cell(size(hm));
    for k=1:length(hm)
       pset.x=get(hm(k),'xdata');
       pset.y=get(hm(k),'ydata');
       pset.color=get(hm(k),'color');
       pset.msize=get(hm(k),'markersize');
       pset.marker=get(hm(k),'marker');
       thisset{k}=pset;
    end
    pointsets=get(hchoose,'userdata');
    pointsets{iset}=thisset;
    set(hchoose,'string',setnames,'value',iset,'userdata',pointsets);
elseif(strcmp(action,'choosespec'))
    haxspec=findobj(gcf,'tag','spectra');
    if(isempty(haxspec))
        return;
    end
    hchoose=findobj(gcf,'tag','choosespec');
    setnames=get(hchoose,'string');
    if(~iscell(setnames))
        setnames={setnames};
    end
    iset=get(hchoose,'value');
    pointsets=get(hchoose,'userdata');
    hbrowse=findobj(gcf,'tag','browse');
    udatb=get(hbrowse,'userdata');
    %if current setname is same as choose spec then the set has simply been updated and we return
    thisname=udatb{3};
    if(strcmp(setnames{iset},thisname))
        return;
    end
    %determine which set is presently open
    for k=1:length(setnames)
       if(strcmp(thisname,setnames{k}))
           kset=k;
       end
    end
    %see if current set has changed and save if so
    hm=udatb{1};
    hs=udatb{2};
    if(~strcmp(thisname,'Point Set New'))
        setk=pointsets{kset};
        if(length(hm)>length(setk))%
            setknew=cell(size(hm));
            setknew(1:length(setk))=setk;
            for k=length(setk)+1:length(hm)
                pset.x=get(hm(k),'xdata');
                pset.y=get(hm(k),'ydata');
                pset.color=get(hm(k),'color');
                pset.msize=get(hm(k),'markersize');
                pset.marker=get(hm(k),'marker');
                setknew{k}=pset;
            end
            pointsets{kset}=setknew;
            set(hchoose,'userdata',pointsets);
        end
    end
    %delete current set
    delete(hm);
    delete(hs);
    %display new set
    seti=pointsets{iset};
    hm=zeros(size(seti));
    hs=hm;
    haxspecd=findobj(gcf,'tag','seis2');
    axes(haxspecd);
    for k=1:length(seti)
        hm(k)=line(seti{k}.x,seti{k}.y,'linestyle','none','marker',seti{k}.marker,...
            'color',seti{k}.color,'markersize',seti{k}.msize,'linewidth',2);
    end
    axes(haxspec);
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    x=udat{3};
    y=udat{4};
    inot=udat{6};%current time
    hresult=findobj(gcf,'tag','results');
    results=get(hresult,'userdata');
    iresult=get(hresult,'value');
    for k=1:length(hs)
        iy=near(y,seti{k}.y);
        ix=near(x,seti{k}.x);
        spec=squeeze(results.data{iresult}(inot,ix,iy,:));
        hs(k)=line(results.fouts{iresult},spec,'linestyle','-','marker',seti{k}.marker,...
            'color',seti{k}.color,'buttondownfcn','seisplot_specdtslice(''idspect'');');
    end
    udatb={hm hs setnames{iset}};
    set(hbrowse,'userdata',udatb)

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
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    delete(hspecwin);
    hi=findobj(hfig,'tag','info');
    hinfo=get(hi,'userdata');
    if(isgraphics(hinfo))
        delete(hinfo);
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
    for k=1:length(udat{1})
       if(isgraphics(udat{1}(k)))
          if(strcmp(get(udat{1}(k),'tag'),'info'))
              figure(udat{1}(k))
              return;
          end
       end
    end
    hi=gcbo;
    msg0={'Spectral Decomp',{['Spectral decomposition is a mapping of a seismic dataset into the ',...
        'time-frequency domain. This means that a 2D seismic section or gather, which is a function of ',...
        'say (x,t), becomes a 3D display as a function of (x,t,f)  (f is frequency). Similarly, a 3D ',...
        'dataset becomes 4D after spectral decomposition. In the present case, your 2D seismic view ',...
        'has become 3D and it helps to think of the frequency axis as being perpendicular to the computer ',...
        'monitor screen. '],' ',['There are different ways of doing the spectral decomposition and here ',...
        'it has been accomplished by a Gabor transform (aka the short-time Fourier transform). ',...
        'This transform works by defining a narrow time window that moves progressivly down a trace. ',...
        'At each window position, a short segment of the trace is Fourier transformed to produce a ',...
        'local frequency spectrum. Nominally there are both amplitude and phase in this spectrum but here ',...
        'only the amplitude is shown. The idea is to produce a decomposition that has a useful resolution ',...
        'in both time and frequency.'],' ',['The key parameters of the decomposition are the window width ',...
        'and the time increment between successive window positions. Called Twin and Tinc respectively, ',...
        'the current values are displayed in the control panel at the far right. Twin is the more important and ',...
        'Tinc can be reliably set to two or three samples. Windowing a trace is a multiplication operation ',...
        'and the corresponding operation in the Frequency domain is a convolution with the Fourier transform ',...
        'of the time window. The time window used is a Gaussian and its Fourier transform is also a Gaussian. ',...
        'Convolution with a Gaussian is a smoothing process so temporal windowing causes spectral smoothing. ',...
        'The important point is that the width of the time-Gaussian is inversely proportional to the width ',...
        'of the frequency-Gaussian. This means that the smaller the time window, which gives better ',...
        'time resolution, the larger the frequency-Gaussian which gives a smoother, less resolved, spectrum. '],...
        ' ',['So it is not possible to get maximal resolution in both time and frequency simlutaneously. It''s ',...
        'always a tradeoff (this is the famous Heisenberg uncertainty principle) and Twin is the main control. ',...
        'Make it small for the best time resolution and there will be very little distinction between ',...
        'frequencies. Make it large and you will get good frequency resolution but the time view will blur. ',...
        'A reasonable choice seems to be a Twin of 5-10 samples. Twin is the half-width of the Gaussian so ',...
        'you will really have twice this many samples determining the spectrum. Also, it''s a Gaussian ',...
        'and that means there is no sharp window edge. ']}};
    msg1={'Tool layout',{['The axes at left (the seismic axes) shows the input sesimic and the axes at right ',...
        '(specd axes) shows the spectral decomp for a single frequency. Both axes are showing the ',...
        'same time and controls to change the time are just to the right of the seismic axes. ',...
        'There are two buttons labelled "Next time" and "Previous time" that step one time sample ',...
        'in either direction. Below these buttons is a tall rectangle labeled "Time slice" that ',...
        'enables a quick jump to any of 30 positions within the set of time slices. Hover the mouse over ',...
        'one of the tiny buttons and you will see the time for that button. Pressing the button ',...
        'gets you there. '],[],...
        ['Similarly controls to change the frequency are to the right of the specd axes. There are ',...
        'both large buttons to step a single sample and a "Frequency" rectangle with 30 jump points. ',...
        'Below the clip popup are the parameters of the Spectral decomposition. You can change any of ',...
        'these parameters and then create a new decomposition by pushing the "Compute SpecD" button. ',...
        'Any number of deconpositions can be computed and they are alll retained in memory ',...
        'until you close the window. The popup menu above the specd axes is used to choose the ',...
        'specd result that is displayed. '],[],['The colormap tool is easy to figure out and can assign one ',...
        'of a list of pre-built colormaps to either axis.'],[],...
        ['The "Browse spectra" button enables you to view the frequency spectrum of any point. ',...
        'Clicking this button causes a new axes to appear on top of the seismic axes. You then ',...
        'click on any point in the SpecD image to see the spectrum associated with tha point. ',...
        'Any number of points can be clicked and their spectra are all drawn in the spectral axes. ',...
        'Clicking on a spectral curve allows easy identification of its corresponding point. '],[],...
        ['The clipping controls have a strong effect on what you see. If you choose a numeric ',...
        'clipping level then the colorbar stretches from -x*sigma to +x*sigma centered at the data ',...
        'mean value. Here x is the clip number and sigma is the standard deviation of the data. ',...
        'For more control, choose "graphical" instead of a numerical value and a small window will ',...
        'appear showing an amplitude histogram and two red lines. The colorbar stretchs between ',...
        'these lines. You can click and drag these lines as desired. ']}};
    hinfo=showinfo({msg0 msg1},'Spectral Decomp on time slices');
    ud=get(hi,'userdata');
    if(isgraphics(ud))
        delete(ud);
    end
    set(hi,'userdata',hinfo);
%     set(hi,'userdata',{msg,hinfo});
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

%% functions

function val=fromenhance
hfig=gcf;
val=false;
if(strcmp(get(hfig,'tag'),'fromenhance'))
    val=true;
end
end

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

function spec2d(~,~)
global NEWFIGVIS
hmasterfig=gcf;
cmap=get(hmasterfig.CurrentAxes,'colormap');
pos=get(hmasterfig,'position');
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
y=get(hi,'ydata');
dx=abs(x(2)-x(1));
dy=abs(y(2)-y(1));
kymax=.5/dy;
haxe=get(hi,'parent');
ydir=haxe.YDir;
hresults=findobj(gcf,'tag','results');
idata=get(hresults,'value');
dnames=get(hresults,'string');
if(haxe==hseis2)
    dname=dnames{idata};
else
    dname=haxe.Title.String;
    if(iscell(dname))
        dname=dname{1};
    end
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfk(seis,y,x,dname,kymax,dx,dy,2);
datar{1}.XLabel.String=hseis2.XLabel.String;
datar{1}.YLabel.String=hseis2.YLabel.String;
datar{1}.YDir=ydir;
colormap(datar{1},cmap);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on')
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance','userdata',henhance);
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dnames{idata});
end
%register the new figure with parent
udat=get(hmasterfig,'userdata');
if(udat{1}==-999.25)
    udat{1}=hfig;
else
    udat{1}=[udat{1} hfig];
end
set(hmasterfig,'userdata',udat);
if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.95,.920,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function RGB(~,~)
global NEWFIGVIS
hmasterfig=gcf;
hseis1=findobj(hmasterfig,'tag','seis1');
cmap=get(hseis1,'colormap');
pos=get(hmasterfig,'position');
% hseis2=findobj(gcf,'tag','seis2');
hi=findobj(hseis1,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
y=get(hi,'ydata');
dname=hseis1.Title.String;
%get the time
hnext=findobj(gcf,'tag','next');
udat=get(hnext,'userdata');
inot=udat{6};%time index
%get the specd
hresults=findobj(gcf,'tag','results');
iresult=get(hresults,'value');
results=hresults.UserData;
tmp=squeeze(results.data{iresult}(inot,:,:,:));
specd=permute(tmp,[2 1 3]);
f=results.fouts{iresult};
specname=['SpecD: ' results.names{iresult}];
frgb=[10 20 30];
units='Hz';
xdir=hseis1.XDir;
ydir=hseis1.YDir;
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplot_RGB(seis,y,x,specd,f,dname,specname,frgb,units,xdir,ydir);
xlbl=hseis1.XLabel.String;
ylbl=hseis1.YLabel.String;
for k=1:5
    datar{k}.XLabel.String=xlbl;
    datar{k}.YLabel.String=ylbl;
end
colormap(datar{1},cmap);
NEWFIGVIS='on';
hfig=gcf;
pos2=hfig.Position;
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);
pos2(1:2)=[xc-.5*pos2(3) yc-.5*pos2(4)];
% customizetoolbar(hfig);
set(hfig,'position',pos2,'visible','on')
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance','userdata',henhance);
    hppt=addpptbutton([.92,.95,.05,.025]);
    set(hppt,'userdata',get(hfig,'name'));
end
%register the new figure with parent
udat=get(hmasterfig,'userdata');
if(udat{1}==-999.25)
    udat{1}=hfig;
else
    udat{1}=[udat{1} hfig];
end
set(hmasterfig,'userdata',udat);
if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.92,.924,.05,.025]);
    enhance('newview',hfig,hmasterfig);
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


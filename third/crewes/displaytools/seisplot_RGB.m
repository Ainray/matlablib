function datar=seisplot_RGB(seis,y,x,specd,f,dname,specname,frgb,units,xdir,ydir)
% SEISPLOT_RBG ... create RGB blend display
%
% datar=seisplot_RGB(seis,y,x,specd,f,dname,specname,frgb,units,xdir,ydir)
%
% seis ... normal 2D seismic matrix
% y ... row coordinate of seis
% x ... column coordinate of seis
% specd ... 3D matrix of seismic attributes to be used to form the RGB blends. The first two
%       dimensions must be the same as seis. The third dimension must be the sam as f. The RGB blend
%       will come from three elements of specd along the f axis. So the third dimension must have at
%       least 3 elements.
% f ... coordinate for the third dimension of specd
% dname ... name of seis
% specdname ... name of specd
% frgb ... vector of length 3 with f values for R, G, and B
% ********** default [f(1) f(floor(nf/2)) f(nf)] where nf=length(f)
% units ... units name for frgb and f
% ********** default = 'Hz' ***********
% xdir ... x axis direction
% ********** default = 'normal' ***********
% ydir ... y axis direction
% ********** default = 'normal' ***********
% datar ... handles of the 5 axes
% datar{1} ... normal seismic
% datar{2} ... specd for red
% datar{3} ... specd for greem
% datar{4} ... specd for blue
% datar{5} ... RGB
%
%
% by G.F. Margrave, Margrave-Geo, 2019
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
if(ischar(seis))
    action=seis;
else
    action='init';
end

if(strcmp(action,'init'))
   [ny,nx]=size(seis);
   if(length(y)~=ny)
       error('y is the wrong size');
   end
   if(length(x)~=nx)
       error('x is the wrong size');
   end
   if(size(specd,1)~=ny)
       error('specd is the wrong size in dimension 1');
   end
   if(size(specd,2)~=nx)
       error('specd is the wrong size in dimension 2');
   end
   nf=size(specd,3);
   if(length(f)~=nf)
       error('f is the wrong size');
   end
   if(nargin<8)
       frgb=[f(1) f(floor(nf/2)) f(nf)];
   end
   if(nargin<9)
       units='Hz';
   end
   if(nargin<10)
       xdir='normal';
   end
   if(nargin<11)
       ydir='normal';
   end
   
%    if(max(y)<10)
%        yy=y;
%        y=1000*y;
%    end
   
%    irgb=zeros(1,3);
%    ind=near(f,frgb(1));
%    irgb(1)=ind(1);
%    ind=near(f,frgb(2));
%    irgb(2)=ind(1);
%    ind=near(f,frgb(3));
%    irgb(3)=ind(1);
   
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
    end
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat,...
        'name',['RGB blend for ' dname],'closerequestfcn','seisplot_RGB(''close'');');
    customizetoolbar(hfig);
    if(fromenhance)
       cmapdefaults=enhance('getdefaultcolormap','sections');
       if(exist(cmapdefaults{1},'file'))
           cmap=eval([cmapdefaults{1}, '(128);']);
           if(cmapdefaults{2})
               cmap=flipud(cmap);
           end
       else
           cmap=enhance('getcolormap',cmapdefaults{1}); 
       end
       if(cmapdefaults{2})
           cmap=flipud(cmap);
       end
       fs=8;
       fw='normal';
    else
       cmap=graygold(128);
       p=bigfig('query');
       if(p(3)>1500)
           fs=8;
           fw='normal';
       elseif(p(3)>1200)
           fs=7;
           fw='bold';
       else
           fs=6;
           fw='bold';
       end
    end
    
    xnot=.05;
    ynot=0;
    wid=.9;
    ht=.9;
    
    htg=uitabgroup(hfig,'position',[xnot,ynot,wid,ht]);
    htabS=uitab(htg,'title',dname,'tag','S','userdata',{seis,specd,x,y,dname,specname,f,frgb,xdir,ydir,units});
    htabR=uitab(htg,'title',['R: ' num2str(frgb(1)) units],'tag','R');
%     hcm=uicontextmenu(hfig);
%     uimenu(hcm,'label','Set Frequency','callback',@setfreq,'userdata',htabR);
%     htabR.UIContextMenu=hcm;
    htabG=uitab(htg,'title',['G: ' num2str(frgb(2)) units],'tag','G');
    htabB=uitab(htg,'title',['B: ' num2str(frgb(3)) units],'tag','B');
    htabRGB=uitab(htg,'title','RGB Blend','tag','RGB');
    xtab0=.05;
    ytab0=.1;
    widtab=.9;
    httab=.8;
    
    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis); %#ok<ASGLU>
    iclip=near(clips,3);
    if(iclip==1)
        clim=[amin amax];
    else
        clim=[am-clip*sigma am+clip*sigma];
    end
    
    hseis=axes(htabS,'position',[xtab0,ytab0,widtab,httab],'tag','seis','fontsize',fs,'fontweight',fw);
    hfig.CurrentAxes=hseis;
    imshow(seis,clim,'xdata',x,'ydata',y);colormap(hseis,cmap);
    if(max(y)<10)
        axis normal
    end
    set(hseis,'visible','on','xdir',xdir,'ydir',ydir)
    enTitle(dname)
    x0=.05;
    xn=x0;
    yn=.925;
    wid=.05;
    ht=.03;
    %controls on tabs (mostly toggles)
    %seismic tab
    uicontrol(htabS,'style','pushbutton','string','R','units','normalized','tag','S2R',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Red');
    xn=xn+wid;
    uicontrol(htabS,'style','pushbutton','string','G','units','normalized','tag','S2G',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Green');
    xn=xn+wid;
    uicontrol(htabS,'style','pushbutton','string','B','units','normalized','tag','S2B',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Blue');
    xn=xn+wid;
    uicontrol(htabS,'style','pushbutton','string','RGB','units','normalized','tag','S2RGB',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to RGB');
    xn=1-6*wid;
    uicontrol(htabS,'style','text','String','Clip level:','units','normalized',...
        'position',[xn,yn,3*wid,ht],'horizontalalignment','right');
    xn=1-3*wid;
    uicontrol(htabS,'style','popupmenu','string',clipstr,'tag','clipS','units','normalized',...
        'position',[xn,yn+.25*ht,3*wid,ht],'callback','seisplot_RGB(''clipS'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hseis},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    %red tab 
    hred=axes(htabR,'position',[xtab0,ytab0,widtab,httab],'tag','red','fontsize',fs,'fontweight',fw);
    xn=x0;
    uicontrol(htabR,'style','pushbutton','string','S','units','normalized','tag','R2S',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Seismic');
    xn=xn+4*wid;
    uicontrol(htabR,'style','pushbutton','string','RGB','units','normalized','tag','RGB2R',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to RGB');
    %green tab
    hgreen=axes(htabG,'position',[xtab0,ytab0,widtab,httab],'tag','green','fontsize',fs,'fontweight',fw);
    xn=x0+wid;
    uicontrol(htabG,'style','pushbutton','string','S','units','normalized','tag','G2S',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Seismic');
    xn=x0+5*wid;
    uicontrol(htabG,'style','pushbutton','string','RGB','units','normalized','tag','G2S',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to RGB');
    %blue tab
    hblue=axes(htabB,'position',[xtab0,ytab0,widtab,httab],'tag','blue','fontsize',fs,'fontweight',fw);
    xn=x0+2*wid;
    uicontrol(htabB,'style','pushbutton','string','S','units','normalized','tag','B2S',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Seismic');
    xn=x0+6*wid;
    uicontrol(htabB,'style','pushbutton','string','RGB','units','normalized','tag','B2RGB',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to RGB');
    %RGB tab
    hrgb=axes(htabRGB,'position',[xtab0,ytab0,widtab,httab],'tag','rgb','fontsize',fs,'fontweight',fw);
    xn=x0+3*wid;
    uicontrol(htabRGB,'style','pushbutton','string','S','units','normalized','tag','RGB2S',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Seismic');
    xn=xn+wid;
    uicontrol(htabRGB,'style','pushbutton','string','R','units','normalized','tag','RGB2R',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Red');
    xn=xn+wid;
    uicontrol(htabRGB,'style','pushbutton','string','G','units','normalized','tag','RGB2G',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Green');
    xn=xn+wid;
    uicontrol(htabRGB,'style','pushbutton','string','B','units','normalized','tag','RGB2B',...
        'position',[xn,yn,wid,ht],'callback',@toggle,...
        'tooltipstring','toggle to Blue');
    xn=1-3*wid;
    uicontrol(htabRGB,'style','radiobutton','string','Mark result','units','normalized','tag','mark',...
        'position',[xn,yn,3*wid,ht],'callback',@mark,'tooltipstring','Mark this blend for later recall');
    yn=yn+ht;
    xn=x0;
    uicontrol(htabRGB,'style','text','string',['Results for ' specname],'units','normalized',...
        'position',[xn,yn,1-xn,ht],'horizontalalignment','left');
        

    xnot=.1;
    ynot=.95;
    wid=.05;
    ht=.025;
    sep=.02;
    xnow=xnot-wid;
    wpan=.2;
    htpan=.1;
    
%     htpan=
%     ynow=ynow-ht-sep;
%     uicontrol(hfig,'style','text','string','RGB Clip:','units','normalized',...
%         'position',[xnow,ynow,1.2*wid,ht],'horizontalalignment','right','tooltipstring',...
%         'Noisy data will likely require clipping');
%     clipstr={'none','10','7','5','4','3','2','1'};
%     uicontrol(hfig,'style','popupmenu','string',clipstr,'units','normalized','tag','clip',...
%         'position',[xnow+1.2*wid,ynow+.25*ht,1.5*wid,ht],'callback','seisplot_RGB(''newblend'');',...
%         'value',4,'tooltipstring',...
%         'Spectral amplitudes larger than clip*stdev are clipped and appear white in the RGB blend');
    
    hpan=uipanel(hfig,'units','normalized','position',[x0,1-htpan,wpan,htpan],'title','RGB clipping');
    ind= specd~=0;
    data=cell(1,4);
    [N,xn]=hist(specd(ind),500); %#ok<HIST>
    sigma=std(specd(ind));
    data{1}=[0,0,N];
    data{2}=[-1,-.001,xn/sigma];
    data{3}=[-.5 3];
    climgraphical(hpan,data,'seisplot_RGB(''newblend'');');
    hax=findobj(hpan,'type','axes');
    set(hax,'fontsize',fs,'fontweight',fw)
    Dmax=max(specd(ind))/sigma;
    Dmin=min(specd(ind))/sigma;
    if(abs(Dmin)<1000000*eps)
        Dmin=0.0;
    end
    yfact=.6;
    annotation('textbox','position',[x0+wpan,ynot,2*wid,ht],'horizontalalignment','left',...
        'fontsize',fs,'fontweight',fw,'String',['Data max: ' num2str(Dmax,3) ' \times \sigma'],...
        'linestyle','none');
    annotation('textbox','position',[x0+wpan,ynot-yfact*ht,2*wid,ht],'horizontalalignment','left',...
        'fontsize',fs,'fontweight',fw,'String',['Data min: ' num2str(Dmin,3) ' \times \sigma'],...
        'linestyle','none');
    annotation('textbox','position',[x0+wpan,ynot-2*yfact*ht,2*wid,ht],'horizontalalignment','left',...
        'fontsize',fs,'fontweight',fw,'String','Data stdev: \sigma','linestyle','none');
    
    %balance
    ynow=ynot-.5*ht;
    xnow=xnow+wpan+5*sep;
    wfact=.9;
    uicontrol(hfig,'style','radiobutton','string','Balance','units','normalized','tag','bal',...
        'position',[xnow,ynow,wfact*wid,ht],'value',0,'tooltipstring',...
        'Click to rescale the 3 colors to equal maxima','callback','seisplot_RGB(''newblend'');',...
        'fontsize',fs,'fontweight',fw,'userdata',sigma);
    %stepping controls
    df=abs(f(2)-f(1));
    nmax=min([nf ceil(.5*(f(end)-f(1))/df)]);
    nstep=max([floor(nmax/10) 1]);
%     nsep=max([floor(nstep/2) 1]);
    nsep=floor((frgb(2)-frgb(1))/df);
    fchoices=cell(1,nmax);
    for k=1:nmax
        fchoices{k}=num2str(k*df);
    end
    xnow=xnow+wfact*wid;
    ynow=ynot;
    uicontrol(hfig,'style','text','string','F step=','units','normalized',...
        'position',[xnow,ynow,1.1*wid,ht],'tooltipstring','Frequency increment for stepping (Hz)',...
        'horizontalalignment','right','fontsize',fs,'fontweight',fw);
    uicontrol(hfig,'style','popupmenu','string',fchoices,'units','normalized','tag','finc',...
        'position',[xnow+wid+sep,ynow+.25*ht,wid,ht],'value',nstep,...
        'tooltipstring','Frequency increment for stepping (Hz)','fontsize',fs,'fontweight',fw);
%     xnow=xnow+2*wid;
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','F sep=','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Frequency separation of RGB triple (Hz)',...
        'horizontalalignment','right','fontsize',fs,'fontweight',fw);
    uicontrol(hfig,'style','popupmenu','string',fchoices,'units','normalized','tag','fsep',...
        'position',[xnow+wid+sep,ynow+.25*ht,wid,ht],'value',nsep,...
        'tooltipstring','Frequency separation of RGB triple (Hz)','fontsize',fs,'fontweight',fw,...
        'callback','seisplot_RGB(''fsep'');');
    ynow=ynow+2*ht;
    xnow=xnow+2*wid+2*sep;
    uicontrol(hfig,'style','pushbutton','string','Step up','units','normalized','tag','stepup',...
        'position',[xnow,ynow,1.25*wid,ht],'callback','seisplot_RGB(''stepup'');',...
        'tooltipstring','Step the three f''s to a higher frequency','fontsize',fs,'fontweight',fw)
    ynow=ynow-2*ht;
%     xnow=xnow+2*wid+sep;
    uicontrol(hfig,'style','pushbutton','string','Step down','units','normalized','tag','stepdown',...
        'position',[xnow,ynow,1.25*wid,ht],'callback','seisplot_RGB(''stepdown'');',...
        'tooltipstring','Step the three f''s to a lower frequency','fontsize',fs,'fontweight',fw)
    
    %controls to directly set frequency for each tab
%     wid=2.5*wid;
    ynow=ynot;
    xnow=xnow+1.5*wid;
    sep=.008;
    ynow=ynow+.5*ht;
    wfact=1.25;
    uicontrol(hfig,'style','text','string','Red frequency:','units','normalized','position',[xnow,ynow,wfact*wid,ht],...
        'horizontalalignment','right','tooltipstring','Directly set the Red frequency','fontsize',fs,'fontweight',fw);
    fcell=num2strcell(f);
    ifreq=near(f,frgb(1));
    uicontrol(hfig,'style','popupmenu','string',fcell,'units','normalized','tag','redf',...
        'position',[xnow+wfact*wid,ynow+.25*ht,wid,ht],'callback',@setfreq,'value',ifreq,...
        'tooltipstring','Directly set the Red frequency','fontsize',fs,'fontweight',fw);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Green frequency:','units','normalized','position',[xnow,ynow,wfact*wid,ht],...
        'horizontalalignment','right','tooltipstring','Directly set the Green frequency','fontsize',fs,'fontweight',fw);
    ifreq=near(f,frgb(2));
    uicontrol(hfig,'style','popupmenu','string',fcell,'units','normalized','tag','greenf',...
        'position',[xnow+wfact*wid,ynow+.25*ht,wid,ht],'callback',@setfreq,'value',ifreq,...
        'tooltipstring','Directly set the Green frequency','fontsize',fs,'fontweight',fw);
    ynow=ynow-ht-sep;
    uicontrol(hfig,'style','text','string','Blue frequency:','units','normalized','position',[xnow,ynow,wfact*wid,ht],...
        'horizontalalignment','right','tooltipstring','Directly set the Blue frequency','fontsize',fs,'fontweight',fw);
    ifreq=near(f,frgb(3));
    uicontrol(hfig,'style','popupmenu','string',fcell,'units','normalized','tag','bluef',...
        'position',[xnow+wfact*wid,ynow+.25*ht,wid,ht],'callback',@setfreq,'value',ifreq,...
        'tooltipstring','Directly set the Blue frequency','fontsize',fs,'fontweight',fw);
    
    %marked results
    xnow=.8;
    ynow=.975;
    uicontrol(hfig,'style','text','String','Marked results','units','normalized','tag','marked',...
        'position',[xnow,ynow,wid,ht],'userdata',{},'horizontalalignment','center',...
        'tooltipstring','Marked results are collected here for comparison','fontsize',fs,'fontweight',fw);
    ynow=ynow-ht;
    xnow=.75;
    wfact=1.5;
    uicontrol(hfig,'style','popupmenu','string',{'none'},'units','normalized','tag','mark1',...
        'position',[xnow,ynow,wfact*wid,ht],'callback','seisplot_RGB(''choosemark'');',...
        'tooltipstring','Toggle between this selection and the one on the right','fontsize',fs,'fontweight',fw);
    xnow=xnow+wfact*wid+sep;
    uicontrol(hfig,'style','popupmenu','string',{'none'},'units','normalized','tag','mark2',...
        'position',[xnow,ynow,wfact*wid,ht],'callback','seisplot_RGB(''choosemark'');',...
        'tooltipstring','Toggle between this selection and the one on the left','fontsize',fs,'fontweight',fw);
    ynow=ynow-1.25*ht;
    xnow=.8;
    uicontrol(hfig,'style','pushbutton','String','Toggle','units','normalized','tag','toggle',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Toggle between the above selections',...
        'callback',@togglemarked,'fontsize',fs,'fontweight',fw);
    
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow+2.25*wid,ynow-1.5*ht,.75*wid,ht],'callback','seisplot_RGB(''info'');',...
        'backgroundcolor','y');
    
    seisplot_RGB('newblend');
    
    htg.SelectedTab=htabRGB;
%     if(max(y)>10)
%         aspect=length(y)/length(x);
%     else
%         aspect=1;
%     end
    bigfig
%     pos=hfig.Position;
%     pos(3)=pos(4)/aspect;
%     hfig.Position=pos;
    datar={hseis,hred,hgreen,hblue,hrgb};

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
elseif(strcmp(action,'stepup'))
    hfig=gcf;
    
    hinc=findobj(hfig,'tag','finc');
    istep=hinc.Value;
    fchoices=hinc.String;
    finc=str2double(fchoices{istep});
    
%     hsep=findobj(hfig,'tag','fsep');
%     isep=hsep.Value;
%     fchoices=hsep.String;
%     fsep=str2double(fchoices{isep});
    
    htabS=findobj(hfig,'tag','S');
    ud=htabS.UserData;
    f=ud{7};
    frgb=ud{8}+finc;
    ind=frgb>f(end);
    frgb(ind)=f(end);
%     f1=frgb(1)+finc;
%     frgb=[f1 f1+fsep f1+2*fsep];
    ud{8}=frgb;
    htabS.UserData=ud;
    
    hredf=findobj(hfig,'tag','redf');
    ired=near(f,frgb(1));
    hredf.Value=ired(1);
    hgreenf=findobj(hfig,'tag','greenf');
    igrn=near(f,frgb(2));
    hgreenf.Value=igrn(1);
    hbluef=findobj(hfig,'tag','bluef');
    iblu=near(f,frgb(3));
    hbluef.Value=iblu(1);
    
    seisplot_RGB('newblend');
elseif(strcmp(action,'stepdown'))
    hfig=gcf;
        
    hinc=findobj(hfig,'tag','finc');
    istep=hinc.Value;
    fchoices=hinc.String;
    finc=str2double(fchoices{istep});
    
%     hsep=findobj(hfig,'tag','fsep');
%     isep=hsep.Value;
%     fchoices=hsep.String;
%     fsep=str2double(fchoices{isep});
    
    htabS=findobj(hfig,'tag','S');
    ud=htabS.UserData;
    f=ud{7};
    frgb=ud{8};
%     f3=frgb(3)-finc;
%     frgb=[f3-2*fsep f3-fsep f3];
    frgb=frgb-finc;
    ind=frgb<f(1);
    frgb(ind)=f(1);
    ud{8}=frgb;
    htabS.UserData=ud;
    
    hredf=findobj(hfig,'tag','redf');
    ired=near(f,frgb(1));
    hredf.Value=ired(1);
    hgreenf=findobj(hfig,'tag','greenf');
    igrn=near(f,frgb(2));
    hgreenf.Value=igrn(1);
    hbluef=findobj(hfig,'tag','bluef');
    iblu=near(f,frgb(3));
    hbluef.Value=iblu(1);
    
    seisplot_RGB('newblend');
elseif(strcmp(action,'fsep'))
    hfig=gcf;
%     hinc=findobj(hfig,'tag','finc');
%     istep=hinc.Value;
%     fchoices=hinc.String;
%     finc=str2double(fchoices{istep});
    
    hsep=findobj(hfig,'tag','fsep');
    isep=hsep.Value;
    fchoices=hsep.String;
    fsep=str2double(fchoices{isep});
    
    htabS=findobj(hfig,'tag','S');
    ud=htabS.UserData;
    f=ud{7};
    frgb=ud{8};
    f1=frgb(1);
%     f3=frgb(3)-finc;
    frgb=[f1 f1+fsep f1+2*fsep];
    ind=frgb>f(end);
    frgb(ind)=f(end);
    ud{8}=frgb;
    htabS.UserData=ud;
    
    hredf=findobj(hfig,'tag','redf');
    ired=near(f,frgb(1));
    hredf.Value=ired(1);
    hgreenf=findobj(hfig,'tag','greenf');
    igrn=near(f,frgb(2));
    hgreenf.Value=igrn(1);
    hbluef=findobj(hfig,'tag','bluef');
    iblu=near(f,frgb(3));
    hbluef.Value=iblu(1);
    
    seisplot_RGB('newblend');
elseif(strcmp(action,'newblend'))
    hfig=gcf;
    htabS=findobj(hfig,'tag','S');
    htabR=findobj(hfig,'tag','R');
    htabG=findobj(hfig,'tag','G');
    htabB=findobj(hfig,'tag','B');
    htabRGB=findobj(hfig,'tag','RGB');
    ud=htabS.UserData;
    specd=ud{2};
    x=ud{3};
    y=ud{4};
%     dname=ud{5};
    specname=ud{6};
    f=ud{7};
    frgb=ud{8};
    xdir=ud{9};
    ydir=ud{10};
    units=ud{11};
    iR=near(f,frgb(1));
    iG=near(f,frgb(2));
    iB=near(f,frgb(3));
    irgb=[iR(1) iG(1) iB(1)];
    tci=makeTCI(specd,irgb);
    climtci=[0 1];
    frgb=[f(iR(1)) f(iG(1)) f(iB(1))];
    ud{8}=frgb;
    htabS.UserData=ud;
    
    hRed=findobj(htabR,'type','axes');
    hfig.CurrentAxes=hRed;
    xlbl=hRed.XLabel.String;
    ylbl=hRed.YLabel.String;
    imshow(tci(:,:,1),climtci,'xdata',x,'ydata',y);colormap(hRed,redblack);
    if(max(y)<10)
        axis normal
    end
    set(hRed,'visible','on','xdir',xdir,'ydir',ydir);
    xlabel(xlbl);ylabel(ylbl);
    enTitle([specname ' Frequency ' num2str(f(iR(1))) ' ' units])
    htabR.Title=['R: ' num2str(f(iR(1))) units];
    
    hGreen=findobj(htabG,'type','axes');
    hfig.CurrentAxes=hGreen;
    imshow(tci(:,:,2),climtci,'xdata',x,'ydata',y);colormap(hGreen,greenblack);
    if(max(y)<10)
        axis normal
    end
    set(hGreen,'visible','on','xdir',xdir,'ydir',ydir)
    xlabel(xlbl);ylabel(ylbl);
    enTitle([specname ' Frequency ' num2str(f(iG(1))) ' ' units])
    htabG.Title=['G: ' num2str(f(iG(1))) units];
    
    hBlue=findobj(htabB,'type','axes');
    hfig.CurrentAxes=hBlue;
    imshow(tci(:,:,3),climtci,'xdata',x,'ydata',y);colormap(hBlue,blueblack);
    if(max(y)<10)
        axis normal
    end
    set(hBlue,'visible','on','xdir',xdir,'ydir',ydir)
    xlabel(xlbl);ylabel(ylbl);
    enTitle([specname ' Frequency ' num2str(f(iB(1))) ' ' units])
    htabB.Title=['B: ' num2str(f(iB(1))) units];
    
    hRGB=findobj(htabRGB,'type','axes');
    hfig.CurrentAxes=hRGB;
    imshow(tci,'xdata',x,'ydata',y);%colormap(hRGB,redblack);
    if(max(y)<10)
        axis normal
    end
    set(hRGB,'visible','on','xdir',xdir,'ydir',ydir)
    xlabel(xlbl);ylabel(ylbl);
    enTitle(['RGB Blend for ' num2str(f(iR(1))) ', ' num2str(f(iG(1))) ' & ' num2str(f(iB(1))) ' ' units])
    
    %check for marked
    hmark=findobj(htabRGB,'tag','mark');
    if(checkmarked(frgb))
        hmark.Value=1;
    else
        hmark.Value=0;
    end
elseif(strcmp(action,'clipS'))
    hfig=gcf;
    hclip=findobj(hfig,'tag','clipS');
    ud=hclip.UserData;
    hax=ud{6};
    iclip=hclip.Value;
    clips=ud{1};
    clip=clips(iclip);
    am=ud{2};
    amin=ud{5};
    amax=ud{4};
    sigma=ud{3};
    if(iclip==1)
        clim=[amin amax];
    else
        if(amin==0)
            clim=[.5*sigma clip*sigma];
        else
            clim=[am-clip*sigma am+clip*sigma];
        end
    end
    hax.CLim=clim;
elseif(strcmp(action,'choosemark'))
    hfig=gcf;
    hmarkn=gcbo;
    if(strcmp(hmarkn.String,'none'))
        return;
    end
    imark=hmarkn.Value;
    hmarked=findobj(hfig,'tag','marked');
    marked=hmarked.UserData;
    frgb=marked{imark};
    
    htabS=findobj(hfig,'tag','S');
    ud=htabS.UserData;
    ud{8}=frgb;
    htabS.UserData=ud;
    
    f=ud{7};
    hredf=findobj(hfig,'tag','redf');
    ired=near(f,frgb(1));
    hredf.Value=ired(1);
    hgreenf=findobj(hfig,'tag','greenf');
    igrn=near(f,frgb(2));
    hgreenf.Value=igrn(1);
    hbluef=findobj(hfig,'tag','bluef');
    iblu=near(f,frgb(3));
    hbluef.Value=iblu(1);
        
    
    seisplot_RGB('newblend');
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
    msg1={'RGB Blends',{['An RGB blend is a type of image display in which the image itself defines ',...
        'its color scheme. This is in contrast to a conventional seismic image display where a ',...
        'colormap is required to define the relationship between amplitude and color. The RGB blend ',...
        'does this by actually requiring 3 separate images, one each for red, green, and blue. To be ',...
        'meaningful, the three images should all be somehow derivable from an original seismic images ',...
        'perhaps as attributes and must all be the same size. A natural fit is spectral decomposition where a seismic image is ',...
        'decomposed into a broad range of frequencies. Generally there will be many more than 3 frequencies ',...
        'in a spectral decomposition and a unique RGB blend can be formed from a choice of any three, ',...
        'say f1,f2,f3. Since any color can be considered as a combination of red, green and blue, then ',...
        'Assigning f1 to red, f2 to green and f3 to blue defines the natural color scheme.'],' ',['So, if a spectral ',...
        'amplitude is to define the amount of red in an image then perhaps we should take the ',...
        'largest amplitude to be full red and the smallest to be no red (which is the same as black). ',...
        'This simple approach often does not work well because the dynamic range of a seismic image ',...
        'can be very large but with most amplitudes falling in a narrow "normal" range. This means ',...
        'that some form of amplitude clipping is generally required to create a useful RGB blend. ',...
        'In this tool, the clipping is controlled using the amplitude histogram shown to the upper ',...
        'left of the image. The histogram displays the amplitude distribution of the three frequencies ',...
        'involved in the blend considered together. When these are part of a spectral decomposition ',...
        'there are no negative amplitudes. The two red lines displayed on the histogram mark the ',...
        'the locations where clipping occurs. Amplitudes higher than the right-most line are set equal ',...
        'to the value marked by the line, while for the left-hand line the clipped amplitudes are those that are less ',...
        'than the value at the line. The lines can be adjusted by clicking and dragging. Moving the ',...
        'right-hand line has the greatest effect. Moving it to the left causes the image to whiten ',...
        'while moving it to the right causes darkening. The whitening happens because wherever the ',...
        'the R,G,&B values are all equal to the maximum (as defined by the red line) then the color ',...
        'is white. Alternatively, the farther the three R,G,&B values are from the data maximum then ',...
        'the darker the color. Please see the "Tool layout" tab for more discussion.']}};
    msg2={'Tool layout',{['At the top of the Figure is the control ribbon where all relevant image ',...
        'controls are located. Beneath this ribbon the RGB blend image is initially shown but tabs ',...
        '(look just above the image on the left) are available to show four other images. These are ',...
        '"S" for the seismic image, "R" for the red image, "G" for the green image, and "B" for the ',...
        'blue image. You can switch to the other images by clicking on the relevant tabs but it is ',...
        'usually more convenient to click on one of the buttons provided just above each image. ',...
        'For example, clicking on the "S" button when the RGB blend is shown toggles to the seismic ',...
        'image. Without moving the mouse, a second click on the seismic image will return to the blend. ',...
        'This allows you to toggle rapidly between the images for comparison. In similar fashion ',...
        'you can toggle between the blend and any of the three component colors. '], ' ',...
        ['At the left end of the control ribbon is the amplitude histogram that facilitates amplitude ',...
        'clipping as applied to the RGB blend. The x axis of the histogram is amplitude and the y',...
        'axis is the number of samples. This is described in more detail in the "RGB blends" ',...
        'tab. In brief, clicking and dragging either red line (the right-hand line has the most effect) ',...
        'changes the clipping. The amplitude distribution is given using the standard deviation, ',...
        'denoted by the greek sigma, as the fundamental measure. The labels on the x-axis ',...
        'are multiples of the standard deviation. Just to the right of the histogram panel, the ',...
        'data maximum and minimum are given as multiples of sigma. '],' ',['Next to the right is ',...
        'the "balance button. Thas little effect if the data are already spectrally balanced as ',...
        'most modern finished datasets are. Choosing this option causes the maximum amplitudes of ',...
        'three blend frequencies to be equalized. '],' ',['Next are a series of controls designed to ',...
        'facilitate rapid exploration of the variety of RGB blends in a given dataset. The tool ',...
        'allows the choice of a step frequency, fstep, and a frequency separation, fsep, so that ',...
        'given a "red" frequency, f1, then f2(green)=f1+fsep and f3(blue)=f2+fsep. Then pressing the "Step up" ',...
        'once will increment these by fstep and pressing "Step down" will decrement by fstep. ',...
        'The starting frequency, f1, is set using the "red frequency" popup. If evenly separated ',...
        'frequencies are not desired then all three frequencies can be set directly using the popups ',...
        'for the three colors.'],' ',['As the RGB blends are explored, interesting blends can be ',...
        'marked by clicking the "mark result" button just above the right edge of the image. This ',...
        'causes the frequencies of the blend to be added to both of the popups just beneath the ',...
        '"Marked results" label at the right edge of the control ribbon. When there are at least ',...
        'two marked results, select one in the right-had popup and another in the left-hand popup ',...
        'and then press the "Toggle" button to compare them. ']}};
%     msg3={'Tool usage',{[' ']}};
    msg={msg1 msg2};
    hinfo=showinfo(msg,'Instructions for RGB Blend analysis',nan,[600 400],[3 3]);
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        ikill=zeros(1,length(udat{1}));
        for k=1:length(udat{1})
           if(~isgraphics(udat{1}))
               ikill(k)=1;
           end
        end
        udat{1}(ikill)=[];
        udat{1}=[udat{1}(~ikill) hinfo];
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

function tci=makeTCI(specd,irgb)
hfig=gcf;
hbal=findobj(hfig,'tag','bal');
balflag=hbal.Value;
sigma=hbal.UserData;
hclim=findobj(hfig,'tag','clim');
ud=hclim.UserData;
clim=ud{2}*sigma;
%make the true-color image
[ny,nx,~]=size(specd);

im=single(specd(:,:,irgb));

%im is all positive.
ind=im(:)>clim(2);
im(ind)=clim(2);
ind=im(:)<clim(1);
im(ind)=clim(1);

if(balflag==0)
   Amax=max(im(:));
   Amin=min(im(:));
   tci=(im-Amin)/(Amax-Amin);
else
   tci=zeros(ny,nx,3,'single');
   for k=1:3
       Amax=max(max(im(:,:,k)));
       Amin=min(min(im(:,:,k)));
       tci(:,:,k)=(im(:,:,k)-Amin)/(Amax-Amin);
   end
end
end

function toggle(~,~)
hfig=gcf;
hbut=gcbo;
hthistab=hbut.Parent;
hnexttab=findobj(hfig,'tag',hbut.String);
htabg=hthistab.Parent;
% hnextbut=findobj(hnexttab,'tag',tag);
htabg.SelectedTab=hnexttab;
end

function setfreq(hm,~)
hfig=gcf;
htabS=findobj(hfig,'tag','S');
ud=htabS.UserData;
f=ud{7};
frgb=ud{8};
tag=hm.Tag;
ival=hm.Value;
switch tag
    case 'redf'
        frgb(1)=f(ival);
    case 'greenf'
        frgb(2)=f(ival);
    case 'bluef'
        frgb(3)=f(ival);
end
ud{8}=frgb;
htabS.UserData=ud;
seisplot_RGB('newblend');
end

function mark(~,~)
hfig=gcf;
htabS=findobj(hfig,'tag','S');
ud=htabS.UserData;
frgb=ud{8};
if(checkmarked(frgb))
    return;%means already marked
end
%record the info
hmarked=findobj(hfig,'tag','marked');
marked=hmarked.UserData;
marked(end+1)={frgb};
hmarked.UserData=marked;
%set popups
thisname=[num2str(frgb(1)) ',' num2str(frgb(2)) ',' num2str(frgb(3))];
hmark1=findobj(hfig,'tag','mark1');
mnames=hmark1.String;
if(strcmp(mnames{1},'none'))
    mnames={thisname};
else
    mnames(end+1)={thisname};
end
set(hmark1,'string',mnames,'value',length(mnames));
hmark2=findobj(hfig,'tag','mark2');
set(hmark2,'string',mnames,'value',length(mnames)); 
end

function argout=checkmarked(thisfrgb)
% returns true if thisfrgb is already marked
hfig=gcf;
hmarked=findobj(hfig,'tag','marked');
marked=hmarked.UserData;
argout=false;
for k=1:length(marked)
    test=sum(thisfrgb-marked{k});
    if(test==0)
        argout=true;
    end
end

end

function togglemarked(~,~)
hfig=gcf;
hmark1=findobj(hfig,'tag','mark1');
imark1=hmark1.Value;
hmark2=findobj(hfig,'tag','mark2');
imark2=hmark2.Value;

hmarked=findobj(hfig,'tag','marked');
marked=hmarked.UserData;
if(isempty(marked))
    return;
end
frgb1=marked{imark1};
frgb2=marked{imark2};

htabS=findobj(hfig,'tag','S');
ud=htabS.UserData;
frgb=ud{8};
chk1=logical(sum(frgb-frgb1));
chk2=logical(sum(frgb-frgb2));
if(~chk1 && ~chk2)
    frgb=frgb1;
elseif(~chk1)
    frgb=frgb2;
else
    frgb=frgb1;
end
ud{8}=frgb;
htabS.UserData=ud;
seisplot_RGB('newblend');
end

function [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(data)
% data ... input data
%
% 
% clips ... determined clip levels
% clipstr ... cell array of strings for each clip level for use in popup menu
% clip ... starting clip level
% iclip ... index into clips where clip is found
% sigma ... standard deviation of data
% am ... mean of data
% amax ... max of data
% amin ... min of data

sigma=std(data(:));
am=mean(data(:));
amin=min(data(:));
amax=max(data(:));
% nsigma=ceil((amax-amin)/sigma);%number of sigmas that span the data
nsigma=max([(amax-am)/sigma (am-amin)/sigma]);

% clips=[20 15 10 8 6 4 3 2 1 .1 .01 .001 .0001]';
% c1=linspace(.5*nsigma,1,10);
if(nsigma>10)
    tmp=round(linspace(nsigma,5,10));
    c1=[tmp 4 3 2 1];
elseif(nsigma<=10 && nsigma >5)
    c1=round(linspace(10*nsigma,50,5))/10;
else
    c1=round(linspace(10*nsigma,10,5))/10;
end
c2=logspace(0,-2,5);
clips=[c1,c2(2:end)];
% if(nsigma<clips(1))
%     ind= clips<nsigma;
%     clips=[nsigma;clips(ind)];
%     if(length(clips)<20)
%         ind=find(clips>1);
%         tmp=zeros(1,length(clips)+length(ind));
%         for k=1:length(ind)
%             tmp(2*k-1)=clips(k);
%             tmp(2*k)=.5*(clips(k)+clips(k+1));
%         end
%         tmp(2*length(ind)+1:end)=clips(length(ind)+1:end);
%         clips=tmp;
%     end
%         
% else
%     n=floor(log10(nsigma/clips(1))/log10(2));
%     newclips=zeros(n,1);
%     newclips(1)=nsigma;
%     for k=n:-1:2
%         newclips(k)=2^(n+1-k)*clips(1);
%     end
%     clips=[newclips;clips];
% end

clipstr=cell(size(clips));
nclips=length(clips);
clipstr{1}='none';
for k=2:nclips
    clipstr{k}=['clip= ' num2str(sigfig(clips(k),3))];
end
iclip=near(clips,3);
iclip=iclip(1);
clip=clips(iclip);

end






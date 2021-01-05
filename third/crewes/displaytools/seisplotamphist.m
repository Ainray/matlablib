function datar=seisplotamphist(seis,t,x,dname)
% SEISPLOTAMPHIST: plots a seismic gather and its amplotide histogram side-by-side
%
% datar=seisplotamphist(seis,t,x,dname)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The seismic
% gather is plotted as an image in the left-hand-side and its amplitude histogram
% is plotted in the right-hand-side. Interactive ability to define the region of analysis is
% provided.
%
% seis ... input seismic matrix
% t ... time coordinate vector for seis. This is the row coordinate of seis. 
% x ... space coordinate vector for seis
% dname ... text string giving a name for the dataset that will annotate
%       the plots.
% 
%
% datar ... Return data which is a length 4 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the amplirude histogram axes
% These return data are provided to simplify plotting additional lines and
% text in either axes.
%
% 
% G.F. Margrave, Margrave-Geo, 2019
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

global DRAGBOX_CALLBACK DRAGBOX_MOTIONCALLBACK DRAGBOX_XLIMS DRAGBOX_YLIMS
global DRAGBOX_MAXWID DRAGBOX_MINWID DRAGBOX_MAXHT DRAGBOX_MINHT
global NEWFIGVIS

if(~ischar(seis))
    action='init';
else
    action=seis;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match seismic');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match seismic');
    end
    
    xwid1=.4;
    xwid2=.25;
    yht=.75;
    xsep=.1;
    xnot=.125;
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
    end
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    set(hfig,'menubar','none','toolbar','figure','numbertitle','off','tag',enhancetag,'userdata',udat);
    
    hax1=subplot('position',[xnot ynot xwid1 yht]);
    
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
    else
        cmap=seisclrs(128);
    end
    
    imagesc(x,t,seis);colormap(hax1,cmap)
    
    
%     brighten(.5);
    grid
%     dx=abs(x(2)-x(1));
%     dt=abs(t(2)-t(1));
    
    
    %draw amp box
    pct=20;
    tinc=pct*(t(end)-t(1))/100;
    xinc=pct*abs(x(end)-x(1))/100;
    tmin=t(1)+tinc;
    tmax=t(end)-tinc;
    xmin=min(x)+xinc;
    xmax=max(x)-xinc;
    dragbox('draw',[xmin xmin xmax xmax tmin tmax tmax tmin],'seisplotamphist(''box'')','r',.5);
%     dragbox('labels',{'Max X','Min X','Max T','Min T'})
    annotation(hfig,'textbox','string','Click and drag the red box to define the analysis region.',...
        'linestyle','none','fontsize',10,'color','r','fontweight','bold','units','normalized',...
        'position',[xnot, .95, xwid1, .02],'tag','instruct','horizontalalignment','center');
    annotation(hfig,'textbox','string','Use the corners to resize and the edges to move.',...
        'linestyle','none','fontsize',10,'color','r','fontweight','bold','units','normalized',...
        'position',[xnot, .925, xwid1, .02],'tag','instruct2','horizontalalignment','center');

    if(iscell(dname))
        dname=dname{1};
    end
    if(length(dname)>80)
        fs=15;
    else
        fs=17;
    end
    ht=enTitle(dname,'interpreter','none');
    ht.FontSize=fs;
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
    inz=seis~=0;
    am=mean(seis(inz));
    sigma=std(seis(inz));
    amax=max(seis(inz));
    amin=min(seis(inz));
    wid=.055;ht=.05;
%     nudge=.1*wid;
    xnow=xnot-2*wid;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clipxt',...
        'title','Clipping','userdata',{am,sigma,amax,amin,hax1,pct});
    data={[-3 3],hax1};
    callback='';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;
%     uicontrol(hfig,'style','popupmenu','string',clipstr,'tag','clipxt','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplotamphist(''clipxt'');','value',iclip,...
%         'userdata',{clips,am,sigma,amax,amin,hax1,pct},'tooltipstring',...
%         'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    %make a help button
    uicontrol(hfig,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,.95,.5*wid,.5*ht],'callback','seisplotamphist(''info'');',...
        'backgroundcolor','y');
    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid1+xsep ynot xwid2 yht]);
    set(hax2,'tag','amp');
    
    wid=.05;
    ht=.025;
    ys=ht/5;
    xs=wid/10;
    xnow=xnot+xwid1+xwid2+xsep+xs;
    ynow=ynot+yht;
    uicontrol(hfig,'style','text','string','Max amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','max');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Min amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','min');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Mean amp','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','mean');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','text','string','Std dev','units','normalized','position',[xnow,ynow,wid,ht]);
    uicontrol(hfig,'style','text','string','','units','normalized','position',[xnow+wid+xs,ynow,wid,ht],...
        'tag','std');
    ynow=ynow-ht-ys;
    uicontrol(hfig,'style','radiobutton','string','Exclude hard zeros','units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'value',1,'tag','exclude','callback','seisplotamphist(''amp'');',...
        'tooltipstring','Hard zeros are samples with amplitude exactly equal to zero.');
    
        
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.2,1); %enlarge the fonts in the figure
    boldlines(hax1,4,2); %make lines and symbols "fatter"
    whitefig;
    
    seisplotamphist('amp');
    set(hax2,'tag','amp');
    DRAGBOX_CALLBACK='seisplotamphist(''amp'');';
    DRAGBOX_MOTIONCALLBACK='';
%     DRAGBOX_MOTIONCALLBACK='seisplotamphist(''amp'');';
    
    set(hfig,'name',['Amplitude analysis for ' dname],'closerequestfcn','seisplotamphist(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
elseif(strcmp(action,'box'))
    hax=gca;
    DRAGBOX_CALLBACK='seisplotamphist(''amp'');';
    DRAGBOX_MOTIONCALLBACK='';
    DRAGBOX_MINWID=[];
    DRAGBOX_MAXWID=[];
    DRAGBOX_MAXHT=[];
    DRAGBOX_MINHT=[];
    xl=hax.XLim;
    pct=.01;
    dx=pct*diff(xl);
    DRAGBOX_XLIMS=[xl(1)+dx xl(2)-dx];
    yl=hax.YLim;
    dy=pct*diff(yl);
    DRAGBOX_YLIMS=[yl(1)+dy yl(2)-dy];
% elseif(strcmp(action,'lims'))
%     hax=findobj(gcf,'tag','fk');
% %     axis(hax);
%     hxlim=findobj(gcf,'tag','xlim');
%     hylim=findobj(gcf,'tag','ylim');
%     xval=get(hxlim,'value');
%     yval=get(hylim,'value');
%     xlimfactors=get(hxlim,'userdata');
%     ylimfactors=get(hylim,'userdata');
%     hax.XLim=[-xlimfactors(xval) xlimfactors(xval)];
%     hax.YLim=[0 ylimfactors(yval)];

elseif(strcmp(action,'amp'))
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis');
    hbox=findobj(hseis,'tag','box');
    xbox=hbox.XData;
    tbox=hbox.YData;
    xmax=max(xbox);
    xmin=min(xbox);
    tmax=max(tbox);
    tmin=min(tbox);
    hi=findobj(hseis,'type','image');
    x=hi.XData;
    t=hi.YData;
    seis=hi.CData;
    ix=near(x,xmin,xmax);
    it=near(t,tmin,tmax);
    hex=findobj(hfig,'tag','exclude');
    iex=hex.Value;
    A=seis(it,ix);
    hamp=findobj(hfig,'tag','amp');
    hfig.CurrentAxes=hamp;
    if(iex==1)
        iuse=A~=0;
        [Ah,xn]=hist(A(iuse),400); %#ok<*HIST>
    else
        [Ah,xn]=hist(A(:),400);
    end
    bar(xn,Ah,'barwidth',1)
    enTitle('Amplitude Histogram')
    xlabel('Amplitude');
    ylabel('Number of samples');
    grid
    Amax=max(A(:));
    Amin=min(A(:));
    Amean=mean(A(:));
    sd=std(A(:));
    h=findobj(hfig,'tag','max');
    set(h,'string',num2str(Amax));
    h=findobj(hfig,'tag','min');
    set(h,'string',num2str(Amin));
    h=findobj(hfig,'tag','mean');
    set(h,'string',num2str(Amean));
    h=findobj(hfig,'tag','std');
    set(h,'string',num2str(sd));
    set(hamp,'tag','amp');
    
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
    msg={['The amplitude histogram tool allows exploration of the amplitude distribution and ',...
        'statistics. The red box defines the region being analyzed. The box can be moved to another ',...
        'location by clicking and dragging an edge. It can be resized by clicking and dragging a ',...
        'corner. Ideally the amplitude distribution should be fairly stable as the box is moved ',...
        'around. However, vertical sections and time slices tend to have very different distributions.']};
    hinfo=showinfo(msg,'Instructions for amplitude analysis');
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


function datar=seisplotcompare(seis1,t1,x1,dname1,flags1,seis2,t2,x2,dname2,flags2)
% SEISPLOTTWO: plots two seismic gathers side-by-side in separate axes
%
% datar=seisplotcompare(seis1,t1,x1,dname1,flags1,seis2,t2,x2,dname2,flags2)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The first
% seismic gather is platted as an image in the left-hand-side and the second seismic gather is
% plotted as an image in the right-hand-side. Controls are provided to adjust the clipping and
% to brighten or darken the image plots. The data should be regularly sampled in both t and x.
%
% seis1 ... first seismic matrix
% t1 ... time coordinate vector for seis1
% x1 ... space coordinate vector for seis1
% dname1 ... text string nameing the first seismic matrix. Enter [] or '' for no name.
% flags1 ... length 2 vector giving [spaceflag, dataflag] for the first input data
%       spaceflag meanings:
%       0 -> x,t space
%       1 -> x,z space
%       2 -> x,y space
%       3 -> y,t space
%       4 -> y,z space
%       dataflag meanings
%       0 -> normal seismic
%       1 -> spectra (like f-k or SpecD)
%       2 -> frequencies (like fdom)
% seis2 ... second seismic matrix
% t2 ... time coordinate vector for seis2
% x2 ... space coordinate vector for seis2
% dname2 ... text string nameing the first seismic matrix. Enter [] or '' for no name.
% flags2 ... similar to flags1 but for the second dataset
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the first seismic axes
%           data{2} ... handle of the second seismic axes
% These return data are provided to simplify plotting additional lines and
% text in either axes.
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

global NEWFIGVIS

if(~ischar(seis1))
    action='init';
else
    action=seis1;
end

if(nargout>0)
    datar=[];%initialize return data to null
end

if(strcmp(action,'init'))
    
    if(nargin==2)
        seis2=t1;
        t1=(0:size(seis1,1)-1)';
        x1=(0:size(seis1,2)-1);
        t2=(0:size(seis2,1)-1)';
        x2=(0:size(seis2,2)-1);
        dname1=[];
        dname2=[];
    end
    
    
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
    
    spaceflag1=flags1(1);
    dataflag1=flags1(2);
    spaceflag2=flags2(1);
    dataflag2=flags2(2);
    
    if(nargin<7)
        dname1=[];
    end
    if(nargin<8)
        dname2=[];
    end

    xwid=.35;
    yht=.75;
    xsep=.05;
    xnot=.125;
    ynot=.125;
    
    
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
           switch dataflag1
               case 0
                   if(spaceflag1~=2)
                       [~,cmapname1,iflip1]=enhancecolormap('sections');
                   else
                       [~,cmapname1,iflip1]=enhancecolormap('timeslices');
                   end
               case 1
                   [~,cmapname1,iflip1]=enhancecolormap('ampspectra');
               case 2
                   [~,cmapname1,iflip1]=enhancecolormap('frequencies');
           end
           switch dataflag2
               case 0
                   if(spaceflag2~=2)
                       [~,cmapname2,iflip2]=enhancecolormap('sections');
                   else
                       [~,cmapname2,iflip2]=enhancecolormap('timeslices');
                   end
               case 1
                   [~,cmapname2,iflip2]=enhancecolormap('ampspectra');
               case 2
                   [~,cmapname2,iflip2]=enhancecolormap('frequencies');
           end
           [cmap3,cmapname3,iflip3]=enhancecolormap('ampspectra'); %#ok<ASGLU>
%            [cmap4,cmapname4,iflip4]=enhancecolormap('frequencies');
       end

    end
    if(notfromenhance)
       enhancetag='';
       udat=[];
       switch dataflag1
           case 0
               if(spaceflag1~=2)
                   cmapname1='graygold';
                   iflip1=0;
               else
                   cmapname1='bluebrown';
                   iflip1=0;
               end
           case 1
               cmapname1='blueblack';
               iflip1=1;
           case 2
               cmapname1='jet';
               iflip1=0;
       end
       switch dataflag2
           case 0
               if(spaceflag2~=2)
                   cmapname2='graygold';
                   iflip2=0;
               else
                   cmapname2='bluebrown';
                   iflip2=0;
               end
           case 1
               cmapname2='blueblack';
               iflip2=2;
           case 2
               cmapname2='jet';
               iflip2=0;
       end
       cmap3=flipud(blueblack);
    end

    tvsbutton='on';
    if(spaceflag1==2 || spaceflag2==2)
        tvsbutton='off';
    end
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hfig=gcf;
    set(hfig,'numbertitle','off','menubar','none','toolbar','figure','userdata',udat,'tag',enhancetag);
    hax1=subplot('position',[xnot ynot xwid yht]);
    
    hi=imagesc(x1,t1,seis1);%colormap(hax1,cm1)
    hi.UserData=[spaceflag1 dataflag1];
    hcm=uicontextmenu;
    hti=uimenu(hcm,'label','Trace Inspector');
    uimenu(hti,'label','At clicked point','callback',{@showtraces,'pt'});
    uimenu(hti,'label','At location','callback',{@showtraces,'loc'});
    set(hi,'uicontextmenu',hcm );
    grid
    [dname1,fs]=processname(dname1);
    ht=enTitle(dname1,'interprete','none');
    ht.FontSize=fs;
    switch spaceflag1
        case 0
            ylbl='time (s)';
            xlbl='x coordinate';
        case 1
            ylbl='depth coordinate';
            xlbl='x coordinate';
        case 2
            ylbl='y coordinate';
            xlbl='x coordinate';
        case 3
            ylbl='depth coordinate)';
            xlbl='y coordinate';
    end
    xlabel(xlbl);
    ylabel(ylbl);
    
    %make first clip control
    wid=.055;ht=.05;sep=.005;
    %establish initial coordinate relation
    xx1=[x1(1) x1(end)];
    xx2=[x2(1) x2(end)];
    m=diff(xx2)/diff(xx1);
    b=xx2(2)-m*xx1(2);%initial 
    xnow=xnot-2*wid;
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    inz=seis1~=0;
    ampinfo1={min(seis1(inz)),max(seis1(inz)),std(seis1(inz))};
    inz=seis2~=0;
    ampinfo2={min(seis2(inz)),max(seis2(inz)),std(seis2(inz))};
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip1','title','Clipping');
    switch dataflag1
        case 0
            data={[-3 3],hax1};
        case 1
            data={[-.5 7],hax1,[],0,1,1};
        case 2
            data={[-3 3],hax1};
        case 3
            data={[0 round(.8*max(seis2(:)))],hax1,1,0,1,1};
    end
    callback='';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax1;
%     uicontrol(hfig,'style','popupmenu','string',clipstr1,'tag','clip1','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplotcompare(''clip1'');','value',iclip1,...
%         'userdata',{ampinfo1,ampinfo2,seis1,seis2,x1,x2,t1,t2,dname1,dname2,m,b,spaceflag1,...
%         spaceflag2,dataflag1,dataflag2},'tooltipstring',...
%         'clip level is the number of standard deviations from the mean at which amplitudes are clipped');
    
%     ht=.5*ht;
%     ampchoices={'Independent','#1 master','#2 master'};
%     ynow=ynow-2*(ht+sep);
%     uicontrol(hfig,'style','popupmenu','string',ampchoices,'tag','ampcontrol','units','normalized',...
%         'position',[xnow,ynow,1.2*wid,ht],'callback','seisplotcompare(''ampcontrol'');','value',1,...
%         'tooltipstring','Choosing #1 to be master means that the amplitude statistics of #1 control both displays.');
%     uicontrol(hfig,'style','text','string','Amp. Control:','units','normalized','position',...
%         [xnow,ynow+ht,wid,.75*ht],'fontweight','bold','horizontalalignment','left',...
%         'tooltipstring','This determines if the seismic displays are scaled independently or jointly.');
    
    
    set(hax1,'tag','seis1');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);
        
    hi=imagesc(x2,t2,seis2);
    hi.UserData=spaceflag2;
    set(hi,'uicontextmenu',hcm );
%     brighten(.5);
    grid
    [dname2,fs]=processname(dname2);
    ht=enTitle(dname2,'interprete','none');
    ht.FontSize=fs;
    switch spaceflag1
        case 0
            ylbl='time (s)';
            xlbl='x coordinate';
        case 1
            ylbl='depth coordinate';
            xlbl='x coordinate';
        case 2
            ylbl='y coordinate';
            xlbl='x coordinate';
        case 3
            ylbl='depth coordinate)';
            xlbl='y coordinate';
    end
    xlabel(xlbl);
    ylabel(ylbl);
    hclip.UserData={hax1,ampinfo1,ampinfo2,seis1,seis2,x1,x2,t1,t2,dname1,dname2,m,b,...
        spaceflag1,spaceflag2,dataflag1,dataflag2};
    %make second clip control
    xnow=xnot+2*xwid+xsep+sep;
    ht=.05;
    ysep=.01;
%         wid=.055;ht=.05;sep=.005; 
    htclip=2*ht;
    ynow=ynot+yht-htclip;
    hclip=uipanel(hfig,'position',[xnow,ynow,1.5*wid,htclip],'tag','clip2',...
        'userdata',hax2,'title','Clipping');
    switch dataflag2
        case 0
            data={[-3 3],hax2};
        case 1
            data={[-.5 7],hax2,[],0,1,1};
        case 2
            data={[-3 3],hax2};
        case 3
            data={[0 round(.8*max(seis2(:)))],hax2,1,0,1,1};
    end
    callback='';
    cliptool(hclip,data,callback);
    hfig.CurrentAxes=hax2;
%     uicontrol(hfig,'style','popupmenu','string',clipstr2,'tag','clip2','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplotcompare(''clip2'');','value',ampinfo2{4},...
%         'userdata',ampinfo2,'tooltipstring',...
%         'clip level is the number of standard deviations from the mean at which amplitudes are clipped');
        
    %amplitudes button
    ynow=ynow-.5*ht-ysep;
    w=1.2;
    uicontrol(hfig,'style','pushbutton','string','Amplitudes','tag','aveamp','units','normalized',...
        'position',[xnow,ynow,w*wid,.5*ht],'callback','seisplotcompare(''amplitudes'');','tooltipstring',...
        'Compare ampltitude histograms');
    
    %spectra button
    ynow=ynow-.5*ht-ysep;
    uicontrol(hfig,'style','pushbutton','string','TV Spectra','tag','aveamp','units','normalized',...
        'position',[xnow,ynow,w*wid,.5*ht],'callback','seisplotcompare(''aveamp'');','tooltipstring',...
        'Compare time-variant amplitude spectra','enable',tvsbutton);
    
    %F-K spectra button
    ynow=ynow-.5*ht-ysep;
    uicontrol(hfig,'style','pushbutton','string','2D (F-K) Spectra','tag','fk','units','normalized',...
        'position',[xnow,ynow,w*wid,.5*ht],'callback','seisplotcompare(''fk'');','tooltipstring',...
        'Compare 2D spectra','userdata',cmap3);
    
    
    ynow=ynow-5*ht;
    pos=[xnow,ynow,w*wid,4*ht];
    cb1='';cb2='';
    cbflag=[0,1];
    cbcb='';
    cbaxe=[hax1,hax2];
    enhancecolormaptool(hfig,pos,hax1,hax2,cb1,cb2,cmapname1,cmapname2,iflip1,iflip2,cbflag,cbcb,cbaxe);
    
    %section labels
    ht=.03;
    ynow=1-2*ht;
    xnow=xnot;
    uicontrol(hfig,'style','text','string','#1','units','normalized','fontsize',16,'tag','#1',...
        'position',[xnow,ynow,wid,ht],'horizontalalignment','left');
    xnow=xnot+xwid+xsep;
    uicontrol(hfig,'style','text','string','#2','units','normalized','fontsize',16,'tag','#2',...
        'position',[xnow,ynow,wid,ht],'horizontalalignment','left');
    
    %zoom and plotover buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    hcm1=uicontextmenu(hfig,'userdata','2over1');
    uimenu(hcm1,'label','Show coordinates','callback',@showcoords,'tag','showcoords1','checked','on');
    uimenu(hcm1,'label','More traces','callback',@traces,'tag','more');
    uimenu(hcm1,'label','Less traces','callback',@traces,'tag','less');
    uimenu(hcm1,'label','Larger wiggle','callback',@traces,'tag','larger');
    uimenu(hcm1,'label','Smaller wiggle','callback',@traces,'tag','smaller');
    uimenu(hcm1,'label','Thinner line','callback',@traces,'tag','thinner');
    uimenu(hcm1,'label','Thicker line','callback',@traces,'tag','fatter');
    
    uicontrol(hfig,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplotcompare(''equalzoom'');',...
        'tooltipstring','First use the zoom tool to zoom section 2, then click this button.');
    uicontrol(hfig,'style','radiobutton','string','Overplot #2','units','normalized','tag','2over1',...
        'position',[xnow+.25*wid,ynow-ht,wid,.5*ht],'callback',@plotover,...
        'value',0,'horizontalalignment','center',...
        'uicontextmenu',hcm1,'userdata',{20,3,'r',[],.75});
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplotcompare(''equalzoom'');',...
        'tooltipstring','First use the zoom tool to zoom section 1, then click this button.');
    hcm2=uicontextmenu(hfig,'userdata','1over2');
    uimenu(hcm2,'label','Show coordinates','callback',@showcoords,'tag','showcoords2','checked','on');
    uimenu(hcm2,'label','More traces','callback',@traces,'tag','more');
    uimenu(hcm2,'label','Less traces','callback',@traces,'tag','less');
    uimenu(hcm2,'label','Larger wiggle','callback',@traces,'tag','larger');
    uimenu(hcm2,'label','Smaller wiggle','callback',@traces,'tag','smaller');
    uimenu(hcm2,'label','Thinner line','callback',@traces,'tag','thinner');
    uimenu(hcm2,'label','Thicker line','callback',@traces,'tag','fatter');
    uicontrol(hfig,'style','radiobutton','string','Overplot #1','units','normalized','tag','1over2',...
        'position',[xnow+.25*wid,ynow-ht,wid,.5*ht],'callback',@plotover,...
        'value',0,'horizontalalignment','center',...
        'uicontextmenu',hcm2,'userdata',{20,3,'r',[],.75});
    
    %link coordinates button
    xnow=pos(1)-.5*xsep-.5*wid;
    uicontrol(hfig,'style','pushbutton','string','Relate coordinates','units','normalized',...
        'position',[xnow ynow wid ht],'tag','coords','callback','seisplotcompare(''coords'');',...
        'userdata',[xx1 xx2],'visible','on',...
        'tooltipstring','If the two sections have different x coordinates, you need to define their relation here.');
    
    %flipx buttons
    xnow=xnot;
    ynow=.4*ynot;
    ht=.5*ht;
    wid=.4*wid;
    uicontrol(hfig,'style','radiobutton','string','flip X','tag','flipx1','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotcompare(''flipx'');');
    xnow=xnot+2*xwid+xsep-wid;
    uicontrol(hfig,'style','radiobutton','string','flip X','tag','flipx2','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotcompare(''flipx'');');
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(hfig,1.6,1); %enlarge the fonts in the figure
    
    set(hax2,'tag','seis2');
    if(iscell(dname1))
        dn1=dname1{1};
    else
        dn1=dname1;
    end
    if(iscell(dname2))
        dn2=dname2{1};
    else
        dn2=dname2;
    end
    set(hfig,'name',['Compare ' dn1 ' & ' dn2],'closerequestfcn','seisplotcompare(''close'');');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
    
    seisplotcompare('ampcontrol');
    
elseif(strcmp(action,'coords'))
    hfig=gcf;
    hdial=[];
    if(strcmp(hfig.Tag,'coorddialog'))
        hdial=hfig;
        hfig=hdial.UserData;
    end
    hcoords=findobj(hfig,'tag','coords');
    ud=hcoords.UserData;
    hclip=findobj(hfig,'tag','clip1');
    udat=hclip.UserData;
    x1=udat{5};
%     x2=udat{6};
    xx1=ud(1:2);
    xx2=ud(3:4);
    m=diff(xx2)/diff(xx1);
    b=xx2(1)-m*xx1(1);
    x2alt=m*x1+b;
    %see if the dialog exists
%     ud=hfig.UserData;
%     if(iscell(ud))
%         hfigs=ud{1};
%         for k=1:length(hfigs)
%             if(isgraphics(hfigs(k)))
%                 if(strcmp(get(hfigs(k),'tag'),'coorddialog'))
%                     hdial=hfigs(k);
%                 end
%             end
%         end
%     end
    if(isempty(hdial))
        pos=get(gcf,'position');
        xc=pos(1)+.5*pos(3);
        yc=pos(2)+.5*pos(4);
        fwid=600;
        fht=400;
        hdial=figure('position',[xc-.5*fwid,yc-.5*fht,fwid,fht],'numbertitle','off',...
            'menubar','none','toolbar','figure','tag','coorddialog',...
            'name','Coordinate relations dialog');
        customizetoolbar(hdial);
        axes(hdial,'position',[.5 .2 .4 .7]);
        plot(x1,x2alt,'.');
        grid
        title('Current coordinate relation');
        xlabel('Section #1 X coordinate');ylabel('Section #2 X coordinate');
        uicontrol(hdial,'style','pushbutton','string','New coordinate relation','units','normalized',...
            'position',[.05,.5,.25,.05],'callback','seisplotcompare(''setcoords'');');
        uicontrol(hdial,'style','pushbutton','string','Dismiss','units','normalized',...
            'position',[.05,.1,.15,.05],'callback','seisplotcompare(''dismisscoords'');');
    else
        figure(hdial)
        hax=findobj(hdial,'type','axes');
        hdial.CurrentAxes=hax;
        plot(x1,x2alt,'.');
        grid
        title('Current coordinate relation');
        xlabel('Section #1 X coordinate');ylabel('Section #2 X coordinate');
    end
    ud=hfig.UserData;
    if(~iscell(ud))
        if(isgraphics(ud))
            ud={hdial ud};
        else
            ud={hdial []};
        end
    else
        if(~isgraphics(ud{1}))
            ud{1}=hdial;
        else
            ud{1}=[hdial,ud{1}];
        end
    end
    hfig.UserData=ud;
    hdial.UserData=hfig;
            
elseif(strcmp(action,'setcoords'))
    hdial=gcf;
    hfig=hdial.UserData;
    hcoords=findobj(hfig,'tag','coords');
    ud=hcoords.UserData;
    hclip=findobj(hfig,'tag','clip1');
    udat=hclip.UserData;
    x1=udat{5};
    x2=udat{6};
    q={'Enter two coordinates from section #1, x1:','Enter the two corresponding coordinates from section #2, x2:'};
    if(isempty(ud))
        a={[num2str(x1(1)) '   ' num2str(x1(end))],[num2str(x2(1)) '   ' num2str(x2(end))]};
    else
        a={[num2str(ud(1)) '   ' num2str(ud(2))],[num2str(ud(3)) '   ' num2str(ud(4))]};
    end
    fail=true;
    iter=1;
    while fail
        if(iter==1)
                tit=['Specifying two points in both coordinates allows a linear relationship to be ',...
                    'created. Be sure to sparate the numbers with a space.'];
                name='Coordinate relation dialog';
        else
            tit=msg;
            name='Ooops, Try again or Cancel';
        end
        a=askthingsle('questions',q,'answers',a,'title',tit,'name',name,'windowstyle','modal');
        if(isempty(a))
            return;
        end
        xx1=sscanf(a{1},'%f');
        xx2=sscanf(a{2},'%f');
        fail=false;
        msg=[];
        if(length(xx1)~=2)
            msg=[msg 'You must provide two coordinates for x1, separated by a space. ']; %#ok<*AGROW>
            fail=true;
        end
        if(length(xx2)~=2)
            msg=[msg 'You must provide two coordinates for x1, separated by a space. '];
            fail=true;
        end
        if(any(isnan(xx1)))
            msg=[msg 'One or both x1 coordinates were not recognizable as numbers. '];
            fail=true;
        end
        if(any(isnan(xx2)))
            msg=[msg 'One or both x2 coordinates were not recognizable as numbers. '];
            fail=true;
        end
        if(~between(x1(1),x1(end),xx1(1),2) ||  ~between(x1(1),x1(end),xx1(2),2))
            msg=[msg ['One or both x1 coordinates were not between ' num2str(x1(1)) ' and ' num2str(x1(end)) '. ']];
            fail=true;
        end
        if(~between(x2(1),x2(end),xx2(1),2) ||  ~between(x2(1),x2(end),xx2(2),2))
            msg=[msg ['one or both x2 coordinates were not between ' num2str(x2(1)) ' and ' num2str(x2(end)) '. ']];
            fail=true;
        end
        if(diff(xx1)==0)
             msg=[msg 'Your two x1 coordinates are the same but they must be unique.'];
            fail=true;
        end
        if(diff(xx2)==0)
             msg=[msg 'Your two x2 coordinates are the same but they must be unique.'];
            fail=true;
        end
        iter=iter+1;
    end
    m=diff(xx2)/diff(xx1);
    b=xx2(2)-m*xx1(2);
    udat{11}=m;
    udat{12}=b;
    hclip.UserData=udat;
    %check to see if we need to re-do any trace overlays
    h=findobj(hfig,'tag','2over1');
    if(h.Value==1)
        udat=h.UserData;
        htraces=udat{4};
        for k=1:length(htraces)
            if(isgraphics(htraces(k)))
                delete(htraces(k))
            end
        end
        h.Value=0;
    end
    h=findobj(hfig,'tag','1over2');
    if(h.Value==1)
        udat=h.UserData;
        htraces=udat{4};
        for k=1:length(htraces)
            if(isgraphics(htraces(k)))
                delete(htraces(k))
            end
        end
        h.Value=0;
    end
    hcoords.UserData=[xx1' xx2'];
    seisplotcompare('coords');
elseif(strcmp(action,'dismisscoords'))
    hdial=gcf;
    delete(hdial);
elseif(strcmp(action,'flipx'))
    hfig=gcf;
    hflip=gcbo;
    tag=hflip.Tag;
    if(strcmp(tag,'flipx1'))
        hseis=findobj(hfig,'tag','seis1');
    else
        hseis=findobj(hfig,'tag','seis2');
    end
    hfig.CurrentAxes=hseis;
    flipx;
% elseif(strcmp(action,'ampcontrol'))
%     seisplotcompare('clip1');
%     seisplotcompare('clip2');
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
    
elseif(strcmp(action,'aveamp')||strcmp(action,'spectra'))
    hfig=gcf;
    ud=hfig.UserData;
    if(iscell(ud))
        hfigs=ud{1};
    else
        hfigs=ud;
    end
    hspecfig=[];
    for k=1:length(ud)
       if(isgraphics(ud(k)))
          name=get(ud(k),'name');
          if(strcmp(name(1:3),'TVS'))
              hspecfig=hfigs(k);
          end
       end
    end
    if(isempty(hspecfig))
        hclip1=findobj(hfig,'tag','clip1');
        ud=hclip1.UserData;
        seis1=ud{4};
        seis2=ud{5};
        x1=ud{6};
        %     x2=ud{6};
        t1=ud{8};
        t2=ud{9};
        dname1=ud{10};
        dname2=ud{11};
        x2a=xtwo2xone;
        NEWFIGVIS='off'; %#ok<NASGU>
        hax1=findobj(hfig,'tag','seis1');
        cmap1=get(hax1,'colormap');
        hax2=findobj(hfig,'tag','seis2');
        cmap2=get(hax2,'colormap');
        datar=seisplottvs_two({seis1,cmap1},{seis2,cmap2},t1,t2,x1,x2a,dname1,dname2);
        colormap(datar{1},cmap1);
        NEWFIGVIS='on';
        hspecfig=gcf;
        customizetoolbar(hspecfig);
        set(hspecfig,'position',hfig.Position,'visible','on')
        %determine if this is from enhance
        hs=findobj(hfig,'tag','fromenhance');
        if(~isempty(hs))
            henhance=get(hs,'userdata');
            %the only purpose of this is to store the enhance figure handle
            uicontrol(hspecfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
                'tag','fromenhance','userdata',henhance);
            set(hspecfig,'tag','fromenhance');
            hppt=addpptbutton([.95,.95,.025,.025]);
            set(hppt,'userdata',['Spectra of ' dname1 ' and ' dname2]);
        end
        %register the new figure with parent
        updatefigureuserdata(hfig,hspecfig)
    else
        figure(hspecfig);
    end
    if(strcmp(get(hspecfig,'tag'),'fromenhance'))
        enhancebutton(hspecfig,[.95,.920,.05,.025]);
        enhance('newview',hspecfig,hfig);
    end
elseif(strcmp(action,'amplitudes'))
    hfig=gcf;
    ud=hfig.UserData;
    if(iscell(ud))
        hfigs=ud{1};
    else
        hfigs=ud;
    end
    hampfig=[];
    for k=1:length(ud)
       if(isgraphics(ud(k)))
          name=get(ud(k),'name');
          if(strcmp(name(1:3),'Amp'))
              hampfig=hfigs(k);
          end
       end
    end
    if(isempty(hampfig))
        hclip1=findobj(hfig,'tag','clip1');
        ud=hclip1.UserData;
        seis1=ud{4};
        seis2=ud{5};
        x1=ud{6};
        x2=ud{7};
        t1=ud{8};
        t2=ud{9};
        dname1=ud{10};
        dname2=ud{11};
%         x2a=xtwo2xone;
        NEWFIGVIS='off'; %#ok<NASGU>
        spaceflag1=ud{14};
        spaceflag2=ud{15};
        hax1=findobj(hfig,'tag','seis1');
        cmap1=get(hax1,'colormap');
        xname1=hax1.XLabel.String;
        yname1=hax1.YLabel.String;
        xdir1=hax1.XDir;
        ydir1=hax1.YDir;
        hax2=findobj(hfig,'tag','seis2');
        cmap2=get(hax2,'colormap');
        xname2=hax2.XLabel.String;
        yname2=hax2.YLabel.String;
        xdir2=hax2.XDir;
        ydir2=hax2.YDir;
        datar=seisplotamphist_two(seis1,t1,x1,dname1,xname1,yname1,xdir1,ydir1,spaceflag1,...
            seis2,t2,x2,dname2,xname2,yname2,xdir2,ydir2,spaceflag2);
        colormap(datar{1},cmap1);
        colormap(datar{2},cmap2);
        NEWFIGVIS='on';
        hampfig=gcf;
        customizetoolbar(hampfig);
        set(hampfig,'position',hfig.Position,'visible','on')
        %determine if this is from enhance
        hs=findobj(hfig,'tag','fromenhance');
        if(~isempty(hs))
            henhance=get(hs,'userdata');
            %the only purpose of this is to store the enhance figure handle
            uicontrol(hampfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
                'tag','fromenhance','userdata',henhance);
            set(hampfig,'tag','fromenhance');
            hppt=addpptbutton([.95,.95,.025,.025]);
            set(hppt,'userdata',['Amplitudes of ' dname1 ' and ' dname2]);
        end
        %register the new figure with parent
        updatefigureuserdata(hfig,hampfig)
    else
        figure(hampfig);
    end
    if(strcmp(get(hampfig,'tag'),'fromenhance'))
        enhancebutton(hampfig,[.95,.920,.05,.025]);
        enhance('newview',hampfig,hfig);
    end
elseif(strcmp(action,'fk'))
    hbut=gcbo;
    cmap3=hbut.UserData;
    hfig=gcf;
    ud=hfig.UserData;
    if(iscell(ud))
        hfigs=ud{1};
    else
        hfigs=ud;
    end
    hampfig=[];
    for k=1:length(ud)
       if(isgraphics(ud(k)))
          name=get(ud(k),'name');
          if(strcmp(name(1:3),'Amp'))
              hampfig=hfigs(k);
          end
       end
    end
    if(isempty(hampfig))
        hclip1=findobj(hfig,'tag','clip1');
        ud=hclip1.UserData;
        seis1=ud{4};
        seis2=ud{5};
        x1=ud{6};
        x2=ud{7};
        t1=ud{8};
        t2=ud{9};
        dname1=ud{10};
        dname2=ud{11};
%         x2a=xtwo2xone;
        spaceflag1=ud{14};
        spaceflag2=ud{15};
        hax1=findobj(hfig,'tag','seis1');
        cmap1=get(hax1,'colormap');
        xname1=hax1.XLabel.String;
        yname1=hax1.YLabel.String;
        xdir1=hax1.XDir;
        ydir1=hax1.YDir;
        hax2=findobj(hfig,'tag','seis2');
        cmap2=get(hax2,'colormap');
        xname2=hax2.XLabel.String;
        yname2=hax2.YLabel.String;
        xdir2=hax2.XDir;
        ydir2=hax2.YDir;
%         hcolormap=findobj(hfig,'tag','colormap');
%         colormapstuff=hcolormap.UserData;
%         cmap3=colormapstuff{3};
%         if(colormapstuff{11})
%             cmap3=flipud(cmap3);
%         end
        NEWFIGVIS='off'; %#ok<NASGU>
        datar=seisplotfk_two(seis1,t1,x1,dname1,xname1,yname1,xdir1,ydir1,spaceflag1,...
            seis2,t2,x2,dname2,xname2,yname2,xdir2,ydir2,spaceflag2);
        colormap(datar{1},cmap1);
        colormap(datar{2},cmap2);
        colormap(datar{3},cmap3);
        colormap(datar{4},cmap3);
        NEWFIGVIS='on';
        hampfig=gcf;
        customizetoolbar(hampfig);
        set(hampfig,'position',hfig.Position,'visible','on');
        %determine if this is from enhance
        hs=findobj(hfig,'tag','fromenhance');
        if(~isempty(hs))
            henhance=get(hs,'userdata');
            %the only purpose of this is to store the enhance figure handle
            uicontrol(hampfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
                'tag','fromenhance','userdata',henhance);
            set(hampfig,'tag','fromenhance');
            hppt=addpptbutton([.95,.95,.025,.025]);
            set(hppt,'userdata',['Amplitudes of ' dname1 ' and ' dname2]);
        end
        %register the new figure with parent
        updatefigureuserdata(hfig,hampfig)
%         %register the new figure with parent
%         udat=get(hfig,'userdata');
%         if(iscell(udat))
%             if(udat{1}==-999.25)
%                 udat{1}=hampfig;
%             else
%                 udat{1}=[udat{1} hampfig];
%             end
%         else
%             udat={[udat hampfig],hfig};
%         end
%         set(hfig,'userdata',udat);
%         set(hampfig,'userdata',{-999.25, hfig});
    else
        figure(hampfig);
    end
    if(strcmp(get(hampfig,'tag'),'fromenhance'))
        enhancebutton(hampfig,[.95,.920,.05,.025]);
        enhance('newview',hampfig,hfig);
    end
% elseif(strcmp(action,'aveamp')||strcmp(action,'spectra'))
%     hfig=gcf;
%     name=get(hfig,'name');
%     ind=strfind(name,'Spectral display');
%     if(isempty(ind)) %#ok<STREMP>
%         hmaster=hfig;
%     else
%         hmaster=get(hfig,'userdata');
%     end
%     hseis1=findobj(hmaster,'tag','seis1');
%     hseis2=findobj(hmaster,'tag','seis2');
%     hi=findobj(hseis1,'type','image');
%     seis1=get(hi,'cdata');
%     hi=findobj(hseis2,'type','image');
%     seis2=get(hi,'cdata');
%     t=get(hi,'ydata');
%     hspec=findobj(hmaster,'tag','aveamp');
%     hspecwin=get(hspec,'userdata');
%     if(isempty(hspecwin))
%         datar=seisplottvs_two(seis1,seis2,t1,t2,x1,x2,dname1,dname2,t1s,twins,fmax);
%         %make the spectral window if it does not already exist
%         pos=get(hmaster,'position');
%         wid=pos(3)*.5;ht=pos(4)*.5;
%         x0=pos(1)+pos(3)-wid;y0=pos(2);
%         hspecwin=figure('position',[x0,y0,wid,ht],'closerequestfcn','seisplotcompare(''closespec'');','userdata',hmaster);
%         set(hspecwin,'name','Spectral display window')
%         
%         whitefig;
%         x0=.1;y0=.1;awid=.7;aht=.8;
%         subplot('position',[x0,y0,awid,aht]);
%         sep=.01;
%         ht=.05;wid=.075;
%         ynow=y0+aht-ht;
%         xnow=x0+awid+sep;
%         uicontrol(gcf,'style','text','string','tmin:','units','normalized',...
%             'position',[xnow,ynow,wid,ht])
%         ntimes=10;
%         tinc=round(10*(t(end)-t(1))/ntimes)/10;
%         %times=[fliplr(0:-tinc:t(1)) tinc:tinc:t(end)-tinc];
%         times=t(1):tinc:t(end)-tinc;
%         %times=t(1):tinc:t(end)-tinc;
%         stimes=num2strcell(times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','popupmenu','string',stimes,'units','normalized','tag','tmin',...
%             'position',[xnow,ynow,wid,ht],'callback','seisplotcompare(''spectra'');','userdata',times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','text','string','tmax:','units','normalized',...
%             'position',[xnow,ynow,wid,ht])
%         times=t(end):-tinc:tinc;
%         stimes=num2strcell(times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','popupmenu','string',stimes,'units','normalized','tag','tmax',...
%             'position',[xnow,ynow,wid,ht],'callback','seisplotcompare(''spectra'');','userdata',times);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','text','string','db range:','units','normalized',...
%             'position',[xnow,ynow,wid,ht])
%         db=-20:-20:-160;
%         idb=near(db,-100);
%         dbs=num2strcell(db);
%         ynow=ynow-ht-sep;
%         uicontrol(gcf,'style','popupmenu','string',dbs,'units','normalized','tag','db','value',idb,...
%             'position',[xnow,ynow,wid,ht],'callback','seisplotcompare(''spectra'');','userdata',db);
%         set(hspec,'userdata',hspecwin);
%     else
%         figure(hspecwin);
%     end
%     htmin=findobj(gcf,'tag','tmin');
%     times=get(htmin,'userdata');
%     it=get(htmin,'value');
%     tmin=times(it);
%     htmax=findobj(gcf,'tag','tmax');
%     times=get(htmax,'userdata');
%     it=get(htmax,'value');
%     tmax=times(it);
%     if(tmin>=tmax)
%         return;
%     end
%     ind=near(t,tmin,tmax);
%     hdb=findobj(gcf,'tag','db');
%     db=get(hdb,'userdata');
%     dbmin=db(get(hdb,'value'));
%     pct=10;
%     [S1,f]=fftrl(seis1(ind,:),t(ind),pct);
%     S2=fftrl(seis2(ind,:),t(ind),pct);
%     A1=mean(abs(S1),2);
%     A2=mean(abs(S2),2);
%     hh=plot(f,todb(A1),f,todb(A2));
%     set(hh,'linewidth',2)
%     xlabel('Frequency (Hz)')
%     ylabel('decibels');
%     ylim([dbmin 0])
%     grid on
%     legend('Seis1 (left)','Seis2 (right)'); 
%     enTitle(['Average ampltude spectra, tmin=' time2str(tmin) ', tmax=' time2str(tmax)]); 
elseif(strcmp(action,'closespec'))
    hfig=gcf;
    hdaddy=get(hfig,'userdata');
    hspec=findobj(hdaddy,'tag','aveamp');
    set(hspec,'userdata',[]);
    delete(hfig);
    if(isgraphics(hdaddy))
        figure(hdaddy);
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
end
end

%% functions start here

function plotover(~,~)
hfig=gcf;
hobj=gcbo;%usually is the radio button but might be the context menu
if(isa(hobj,'matlab.ui.container.Menu'))
    %means it was called by the context menu attached to the radio button
    htmp=hobj.Parent;%the context menu
    tag=htmp.UserData;
    hobj=findobj(hfig,'tag',tag);
end
value=hobj.Value;%will be 1 or 0 for on or off
tag=hobj.Tag;
% tag is either '1over2' or '2over1' indicating which dataset is the image and which is the overlay.
if(value==1)
    hclip=findobj(gcf,'tag','clip1');
    ud=hclip.UserData;
    switch tag
        case '2over1'
            ampinfo=ud{2};
            seisb=ud{5};
            xa=ud{6};
            xb=xtwo2xone;
            xb2=ud{7};
            tb=ud{9};
            dnamea=ud{10};
            dnameb=ud{11};
            hax=findobj(hfig,'tag','seis1');
            hshow=findobj(hfig,'tag','showcoords1');
        case '1over2'
            ampinfo=ud{3};
            seisb=ud{4};
            xa=ud{7};
            xb=xone2xtwo;
            xb2=ud{6};
            tb=ud{8};
            dnamea=ud{11};
            dnameb=ud{10};
            hax=findobj(hfig,'tag','seis2');
            hshow=findobj(hfig,'tag','showcoords2');
    end
    
    ishow=1;
    if(strcmp(hshow.Checked,'off'))
        ishow=0;
    end
    % seisa is the image, seisb will be the overlay
    hfig.CurrentAxes=hax;
    dname=[dnamea ' with ' dnameb ' overlay '];
    
    %now plot the overlay traces
    ud=hobj.UserData;
    ntraces=ud{1};%number of wiggles to plot
    wigmax=ud{2};%amplitude of the wiggle
    kolor=ud{3};
    lw=ud{5};
    trspace=(max(xb)-min(xb))/(ntraces+1);
    xtent=.5*trspace;
    xnow=trspace;
    istart=near(xb,xnow);%first trace
    iplot=istart;
    amax=ampinfo{2};
    sigma=ampinfo{3};
    htraces=nan*zeros(1,ntraces);
    htext=htraces;
    aref=min(wigmax*sigma,amax);
    for k=1:ntraces
        if(between(xa(1),xa(end),xnow))
            htraces(k)=line(xnow+seisb(:,iplot(1))*xtent/aref,tb,'color',kolor,'linewidth',lw);
            if(ishow)
                htext(k)=text(xnow,tb(end),num2str(xb2(iplot(1))),'rotation',-90);
            end
        end
        xnow=xnow+trspace;
        iplot=near(xb,xnow);
    end
    ud{4}=[htraces,htext];
    hobj.UserData=ud;
    enTitle(dname,'interprete','none')
else
    ud=hobj.UserData;
    if(length(ud)<4)
        return;
    end
    hclip=findobj(gcf,'tag','clip1');
    ud2=hclip.UserData;
    switch tag
        case '2over1'
            dnamea=ud2{10};
            hax=findobj(hfig,'tag','seis1');
        case '1over2'
            dnamea=ud2{11};
            hax=findobj(hfig,'tag','seis2');
    end
    % seisa is the image, seisb will be the overlay
    hfig.CurrentAxes=hax;
    htraces=ud{4};
    for k=1:length(htraces)
        if(isgraphics(htraces(k)))
            delete(htraces(k));
        end
    end
    ud{4}=[];
    hobj.UserData=ud;
    enTitle(dnamea,'interprete','none')
end

end


function traces(~,~)
hfig=gcf;
hobj=gcbo;%the cb menu

htmp=hobj.Parent;%the context menu
tag2=htmp.UserData;
hoverlay=findobj(hfig,'tag',tag2);
ud=hoverlay.UserData;
tag=hobj.Tag;%identifies the specific cb menu
switch tag
    case 'more'
        ntraces=round(1.5*ud{1});
        ud{1}=ntraces;
    case 'less'
        ntraces=max([1 round(.75*ud{1})]);
        ud{1}=ntraces;
    case 'larger'
        wigmax=.75*ud{2};
        ud{2}=wigmax;
    case 'smaller'
        wigmax=1.5*ud{2};
        ud{2}=wigmax;
    case 'thinner'
        lw=.75*ud{5};
        ud{5}=lw;
    case 'fatter'
        lw=1.5*ud{5};
        ud{5}=lw;
end
if(length(ud)>3)
    htraces=ud{4};
    for k=1:length(htraces)
        if(isgraphics(htraces(k)))
            delete(htraces(k));
        end
    end
    ud{4}=[];
    hoverlay.UserData=ud;
    plotover;
else
    hoverlay.UserData=ud;
end


end


function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','enhance(''makepptslide'');');
%the title string will be stored as userdata
end


function x1=xtwo2xone
hfig=gcf;
hclip=findobj(hfig,'tag','clip1');
ud=get(hclip,'userdata');
x2=ud{7};
m=ud{12};
b=ud{13};
x1=(x2-b)/m;
end

function x2=xone2xtwo
hfig=gcf;
hclip=findobj(hfig,'tag','clip1');
ud=get(hclip,'userdata');
x1=ud{6};
m=ud{12};
b=ud{13};
x2=m*x1+b;
end

function showcoords(~,~)
hmenu=gcbo;
chk=hmenu.Checked;
if(strcmp(chk,'on'))
    hmenu.Checked='off';
else
    hmenu.Checked='on';
end
end

function showtraces(~,~,flag)
hmasterfig=gcf;
hseis=findobj(gcf,'tag','seis1');
hseis2=findobj(gcf,'tag','seis2');
name1=hseis.Title.String;
name2=hseis2.Title.String;

hi=gco;
seis=get(hi,'cdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');

if(haxe==hseis)
    dname=name1;
else
    dname=name2;
end
x=get(hi,'xdata');
pt=seisplottraces('getlocation',flag);
ixnow=near(x,pt(1,1));
xnow=x(ixnow(1));
dname2=dname;
%determine pixels per second
un=get(haxe,'units');
set(gca,'units','pixels');
pos=get(haxe,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(haxe,'units',un);


pos=get(hmasterfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);
seisplottraces(double(seis(:,ixnow(1))),t,xnow,dname2,pixpersec);
hfig=gcf;
customizetoolbar(hfig);
if(fromenhance(hmasterfig))
    seisplottraces('addpptbutton');
    set(gcf,'tag','fromenhance');
    pos2=get(hfig,'position');
    pos2(1)=xc-.5*pos2(3);
    pos2(2)=yc-.5*pos2(4);
    set(hfig,'position',pos2,'visible','on');
end

% hbrighten=findobj(hmasterfig,'tag','brighten');
% hfigs=get(hbrighten,'userdata');
% set(hbrighten,'userdata',[hfigs hfig]);

%register the figure
seisplottraces('register',hmasterfig,hfig);

if(strcmp(get(hfig,'tag'),'fromenhance'))
    enhancebutton(hfig,[.8,.930,.05,.025]);
    enhance('newview',hfig,hmasterfig);
end
end

function [dname,fs]=processname(name)
if(iscell(name))
    dname=[name{1} ' ' name{2}];
else
    dname=name;
end
Nd=length(dname);
fs=16;
if(Nd>50 && Nd<60)
    fs=12;
elseif(Nd>50 && Nd<70)
    fs=9;
    ind=strfind(dname,',');
    if(~isempty(ind))
        ii=near(ind,round(Nd/2));
        str1=dname(1:ind(ii(1)));
        str2=dname(ind(ii(1))+1:end);
    else
        str1=dname(1:round(Nd/2));
        str2=dname(round(Nd/2)+1:end);
    end
    dname={str1,str2};
elseif(Nd>50)
    fs=7;
    ind=strfind(dname,',');
    if(~isempty(ind))
        ii=near(ind,round(Nd/2));
        str1=dname(1:ind(ii(1)));
        str2=dname(ind(ii(1))+1:end);
    else
        str1=dname(1:round(Nd/2));
        str2=dname(round(Nd/2)+1:end);
    end
    dname={str1,str2};
end
end
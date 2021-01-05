function argout=picktool_getcolor(hornames,oldcolor,horcolors,posxy,transfer)
%picktool_getcolor ... interactive GUI tool for color choice
% 
% selectedcolor=picktool_getcolor(hfig,oldcolor,horcolors,transfer)
% 
% hornames = list of horizon hornames
% oldcolor ... rgb triplet specifying the current color that is to be changed.
% horcolors ... cell array of colors that are currently in use. Each entry must be an rgb triple.
%       May also be provided as an Nx3 matrix of rbg triples where N is the number of colors in use.
% There must be one color for each horname
% transfer ... string containing an executable Matlab command that will be evaluated when the user
%       presses 'Done' or 'Cancel'. Typically this transfers control back to the function that needs
%       the color information.
%
% When the 'Done' or 'Cancel' button is pressed, you must do the following. 
%    1) Check the 'tag' of gcbo to determine if 'Done' or 'Cancel' was pressed. That is, if
%    strcmp(get(gcbo,'tag'),'done') evaluates to 1, then 'Done' was pressed and similarly for
%    cancel. Note that the 'tag' strings are lower case.
%    2) If done was pressed, then retrieve the selected color by
%       selectedcolor=picktool_getcolor('getresult')
%       The returned value is an rgb trple.
%    3) Delete the picktool_getcolor figure (be sure to get the selected color before deleting the figure)
%
% Example: picktool_getcolor(gcf,[1 0 0],{},'disp(''Color selected'')')
%       After selecting a color, press 'Done' and then type the command:
%       newcolor=picktool_getcolor('getresult')
%
% Example2: picktool_getcolor(gcf,[1 0 0],{[0 1 0],[0 0 1],[.3 .7 .8]},'disp(''Color selected'')')
%       After selecting a color, press 'Done' and then type the command:
%       newcolor=picktool_getcolor('getresult')
%
% Example3: picktool_getcolor(gcf,[1 0 0],rand(20,3),'disp(''Color selected'')')
%       After selecting a color, press 'Done' and then type the command:
%       newcolor=picktool_getcolor('getresult')
%
% G.F. Margrave, CREWES, 2018
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

if(ischar(hornames))
    action=hornames;
else
    action='init';
end
if(nargout>0)
    argout=[];
end
if(strcmp(action,'init'))
   if(~iscell(horcolors))
      tmp=horcolors;
      horcolors=cell(1,size(tmp,1));
      for k=1:size(tmp,1)
          horcolors{k}=tmp(k,:);
      end
   end
   thishor=1;
   if(isempty(hornames{end}))
       %     newhor=1;
       newname=inputdlg('Specify a name for the new horizon:','Name needed');
       if(isempty(newname))
           return;
       end
       hornames(end)=newname;
       horcolors{end}=[1 1 1];
       thishor=length(horcolors);
   end
   figwid=800;fight=500;
   pos=[posxy(1)-.5*figwid,posxy(2)-.5*fight,figwid,fight];
   hdial=figure('position',pos,'Name','Color Chooser','numbertitle','off',...
       'menubar','none','toolbar','none');
   
   if(isnan(oldcolor))
       if(iscell(horcolors))
           oldcolor=horcolors{end};
       else
           oldcolor=horcolors(end,:);
       end
       thishor=length(hornames);
   end
   
%    newcolors=horcolors;
%    newhornames=hornames;
   xnot=.05;
   sep=.02;
   xnow=xnot;
   ynow=.6;
   width=.2;height=.3;
   hlist=uicontrol(hdial,'style','listbox','string',hornames,'value',thishor,...
       'units','normalized','position',[xnow,ynow,width,height],'callback',...
       @choose_horizon,'tag','horizonlist');
   ynow=ynow+height;
   height2=.08;
   uicontrol(hdial,'style','text','String','Horizon names','units','normalized',...
       'position',[xnow,ynow,width,.5*height2],'fontweight','bold');
   xnow=xnot;ynow=.45;wid=.1;ht=.1;
   ht2=.025;

   uicontrol(hdial,'style','text','string','Old color','units','normalized',...
       'position',[xnow,ynow,wid,ht],'fontweight','bold');
   ynow=ynow-ht2;
   uicontrol(hdial,'style','text','string','','tag','oldcolor','units','normalized',...
       'position',[xnow,ynow,wid,ht],'backgroundcolor',oldcolor);
   ynow=ynow-ht-sep;
   uicontrol(hdial,'style','text','string','New color','units','normalized',...
       'position',[xnow,ynow,wid,ht],'fontweight','bold');
   ynow=ynow-ht2;
   uicontrol(hdial,'style','text','string','','tag','newcolor','units','normalized',...
       'position',[xnow,ynow,wid,ht],'backgroundcolor',oldcolor);
   uicontrol(hdial,'style','pushbutton','string','New Name','units','normalized','tag','newname',...
       'position',[xnow+wid+sep,ynow+ht,wid,ht/2],'callback',@rename);
   ynow=ynow-ht;
   ht2=.05;
   uicontrol(hdial,'style','pushbutton','string','Done','tag','done','units','normalized',...
       'position',[xnow,ynow,wid,ht2],'callback',@done,'userdata',{hornames,horcolors});
   ynow=ynow-ht2-sep;
   uicontrol(hdial,'style','pushbutton','string','Cancel','tag','cancel','units','normalized',...
       'position',[xnow,ynow,wid,ht2],'callback',@cancel,'userdata',transfer);
   xnow=xnow+2*wid+10*sep;
   wid=1-xnow-xnot;
   ht=wid;
   ynow=1-ht-.1;
   coloraxes(hdial,[xnow,ynow,wid,ht],10,'picktool_getcolor(''clickcolor'');',oldcolor);
   
   xspace=wid/3;
   wid=wid/12;
   ht=ynow-.15+sep;
   ynow=ynow-ht-sep;
   xnow=xnow+xspace/2-wid/2;
   ht2=.05;
   uicontrol(gcf,'style','text','string','You can also choose a color by adjusting the sliders',...
       'units','normalized','position',[xnow,ynow-2*ht2,2.2*xspace,ht2],'fontweight','bold')
   kinc=.01;
   colorscale=linspace(0,1,round(1/kinc)+1);
   ival=near(colorscale,oldcolor(1));
   val=colorscale(ival(1));
   uicontrol(hdial,'style','slider','string','Red','units','normalized','tag','red',...
       'position',[xnow,ynow,wid,ht],'max',1,'min',0,'sliderstep',[kinc 10*kinc],'callback',...
       'picktool_getcolor(''slidecolor'');','value',val,'backgroundcolor','r');
   
   uicontrol(hdial,'style','text','string','Red','units','normalized','position',[xnow,ynow-ht2,wid,ht2]);
   xnow=xnow+xspace;
   ival=near(colorscale,oldcolor(2));
   val=colorscale(ival(1));
   uicontrol(hdial,'style','slider','string','Green','units','normalized','tag','green',...
       'position',[xnow,ynow,wid,ht],'max',1,'min',0,'sliderstep',[kinc 10*kinc],'callback',...
       'picktool_getcolor(''slidecolor'');','value',val,'backgroundcolor','g');
   uicontrol(hdial,'style','text','string','Green','units','normalized','position',[xnow,ynow-ht2,wid,ht2]);
   xnow=xnow+xspace;
   ival=near(colorscale,oldcolor(3));
   val=colorscale(ival(1));
   uicontrol(hdial,'style','slider','string','Blue','units','normalized','tag','blue',...
       'position',[xnow,ynow,wid,ht],'max',1,'min',0,'sliderstep',[kinc 10*kinc],'callback',...
       'picktool_getcolor(''slidecolor'');','value',val,'backgroundcolor','b');
   uicontrol(hdial,'style','text','string','Blue','units','normalized','position',[xnow,ynow-ht2,wid,ht2]);
   
   %do the horcolors
   xnow=xnot+.24;
   wid=.1;ht=.05;
   ynow=.9;
   hhc=uicontrol(hdial,'style','text','string',{'Horizon','colors'} ,'units','normalized',...
       'position',[xnow,ynow-.5*ht,wid,1.5*ht],'fontweight','bold','tag','horcolors');
%    xc=xnow+.5*wid;%center
   ht2=.05;wid=ht;
   ynow=.875;
   nkols=floor((ynow-ht-ht2)/ht2);%number that will fit in a column
%    ynot=ynow-ht2;
   if(iscell(horcolors))
       ncin=length(horcolors);
   else
       ncin=size(horcolors,1);
   end
   hp=zeros(1,ncin);
   htax=nkols*ht2;
   hax=axes('position',[xnow,ynow-htax,2*wid,htax],'visible','off');
   set(hax,'xlim',[0 1],'ylim',[0 1])
   wid=.25;ht2=.975/nkols;
   if(nkols>ncin)
%        xnow=xc-.5*wid;%one column centered
       xnow=.5;%one column centered
       ynow=.975-ht2;
       ipatch=0;
       for k=1:nkols
           ipatch=ipatch+1;
           if(iscell(horcolors))
               cin=horcolors{k};
           else
               cin=horcolors(k,:);
           end
%            hp(ipatch)=uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid,ht2],...
%                'backgroundcolor',cin,'userdata',ipatch);
           hp(ipatch)=patch([xnow,xnow+wid,xnow+wid,xnow],[ynow,ynow,ynow+ht2,ynow+ht2],cin,...
               'buttondownfcn',@choose_horizon);
           ynow=ynow-ht2;
           if(k==ncin)
               break;
           end
       end
   else
%        xnow=xc-wid;%two columns
       xnow=0;%two columns
       ynow=.975-ht2;
       ipatch=0;
       for k=1:nkols
           ipatch=ipatch+1;
           if(iscell(horcolors))
               cin=horcolors{k};
           else
               cin=horcolors(k,:);
           end
%            hp(ipatch)=uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid,ht2],...
%                'backgroundcolor',cin,'userdata',ipatch);
           hp(ipatch)=patch([xnow,xnow+wid,xnow+wid,xnow],[ynow,ynow,ynow+ht2,ynow+ht2],cin);
           ynow=ynow-ht2;
       end
%        xnow=xnow+wid;
%        ynow=ynot;
       xnow=.5;%two columns
       ynow=.975-ht2;
       for k=nkols+1:2*nkols
           ipatch=ipatch+1;
           if(iscell(horcolors))
               cin=horcolors{k};
           else
               cin=horcolors(k,:);
           end
%            hp(ipatch)=uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid,ht2],...
%                'backgroundcolor',cin,'userdata',ipatch);
           hp(ipatch)=patch([xnow,xnow+wid,xnow+wid,xnow],[ynow,ynow,ynow+ht2,ynow+ht2],cin);
           ynow=ynow-ht2;
           if(k==ncin)
               break;
           end
       end
   end
   hhc.UserData={hp,[]};
   choose_horizon(hlist);   
elseif(strcmp(action,'clickcolor'))
    hpatch=gcbo;
    hcax=findobj(gcf,'tag','colors');
    udat=get(hcax,'userdata');
    iselected=udat{3};%previous selection
    hp=udat{4};
    hpold=hp(iselected);
    ud=get(hpold,'UserData');
    set(hpold,'linewidth',.5,'xdata',ud(:,1),'ydata',ud(:,2),'zdata',zeros(4,1),'userdata',[]);%restore previous
    iselected=find(hp==hpatch);%new selection
    hpnew=hp(iselected);
    x=get(hpnew,'XData');
    y=get(hpnew,'Ydata');
    dx=x(2)-x(1);
    dy=y(3)-y(2);
    x2=x+[-1;1;1;-1]*dx/4;
    y2=y+[-1;-1;1;1]*dy/4;
    set(hpnew,'linewidth',2,'xdata',x2,'ydata',y2,'zdata',ones(4,1),'userdata',[x y])
    selectedcolor=get(hpatch,'facecolor');
    hnew=findobj(gcf,'tag','newcolor');
    set(hnew,'backgroundcolor',selectedcolor);
    hred=findobj(gcf,'tag','red');
    set(hred,'value',selectedcolor(1));
    hgreen=findobj(gcf,'tag','green');
    set(hgreen,'value',selectedcolor(2));
    hblue=findobj(gcf,'tag','blue');
    set(hblue,'value',selectedcolor(3));
    
    udat{3}=iselected;
    udat{2}=selectedcolor;
    set(hcax,'userdata',udat);
    picktool_getcolor('sethorcolor',selectedcolor)
elseif(strcmp(action,'slidecolor'))
    hred=findobj(gcf,'tag','red');
    hgreen=findobj(gcf,'tag','green');
    hblue=findobj(gcf,'tag','blue');
    selectedcolor=[hred.Value hgreen.Value hblue.Value];
    hnew=findobj(gcf,'tag','newcolor');
    set(hnew,'backgroundcolor',selectedcolor);
    hcax=findobj(gcf,'tag','colors');
    udat=get(hcax,'userdata');
    hp=udat{4};%patch vector
    hpold=hp(udat{3});%previous selection
    ud=get(hpold,'userdata');
    set(hpold,'linewidth',.5,'xdata',ud(:,1),'ydata',ud(:,2),'zdata',zeros(4,1),'userdata',[]);%restore previous
    kols=udat{1};
    nkols=size(kols,1);
    colordist=sum(abs(kols-selectedcolor(ones(nkols,1),:)),2);
    [~,iselected]=min(colordist);
    selectedcolor=kols(iselected,:);
    udat{2}=selectedcolor;
    udat{3}=iselected;
    hpnew=hp(iselected);
    x=get(hpnew,'XData');
    y=get(hpnew,'Ydata');
    dx=x(2)-x(1);
    dy=y(3)-y(2);
    x2=x+[-1;1;1;-1]*dx/4;
    y2=y+[-1;-1;1;1]*dy/4;
    set(hpnew,'linewidth',2,'xdata',x2,'ydata',y2,'zdata',ones(4,1),'userdata',[x y])
    set(hcax,'userdata',udat);
    picktool_getcolor('sethorcolor',selectedcolor)
elseif(strcmp(action,'setcolor'))
    %called when a horizon name is clicked
    selectedcolor=oldcolor;%second arg
    hnew=findobj(gcf,'tag','newcolor');
    set(hnew,'backgroundcolor',selectedcolor);
    hcax=findobj(gcf,'tag','colors');
    udat=get(hcax,'userdata');
    hp=udat{4};%patch vector
    hpold=hp(udat{3});%previous selection
    ud=get(hpold,'userdata');
    set(hpold,'linewidth',.5,'xdata',ud(:,1),'ydata',ud(:,2),'zdata',zeros(4,1),'userdata',[]);%restore previous
    kols=udat{1};
    nkols=size(kols,1);
    colordist=sum(abs(kols-selectedcolor(ones(nkols,1),:)),2);
    [~,iselected]=min(colordist);
    selectedcolor=kols(iselected,:);
    udat{2}=selectedcolor;
    udat{3}=iselected;
    hpnew=hp(iselected);
    x=get(hpnew,'XData');
    y=get(hpnew,'Ydata');
    dx=x(2)-x(1);
    dy=y(3)-y(2);
    x2=x+[-1;1;1;-1]*dx/4;
    y2=y+[-1;-1;1;1]*dy/4;
    set(hpnew,'linewidth',2,'xdata',x2,'ydata',y2,'zdata',ones(4,1),'userdata',[x y])
    set(hcax,'userdata',udat);
    picktool_getcolor('sethorcolor',selectedcolor)
elseif(strcmp(action,'sethorcolor'))
    hfig=gcf;
    kol=oldcolor;%second arg
    hlist=findobj(hfig,'tag','horizonlist');
    ihor=hlist.Value;%horizon number
    %set horizon color patch
    hhors=findobj(hfig,'tag','horcolors');
    ud=hhors.UserData;
    hhp=ud{1};
    set(hhp(ihor),'facecolor',kol);
    %update user data in hdone
    hdone=findobj(hfig,'tag','done');
    ud=hdone.UserData;
    horcolors=ud{2};
    horcolors{ihor}=kol;
    ud{2}=horcolors;
    hdone.UserData=ud;
    
elseif(strcmp(action,'getresult'))
    hdone=findobj(gcf,'tag','done');
    argout=hdone.UserData;
    return;
end

end

function hcax=coloraxes(hfig,pos,nbins,callback,selectedcolor)


hcax=axes(hfig,'position',pos);

npatches=nbins^3;
r=linspace(0,1,nbins);
g=r;
b=r;

n2=ceil(sqrt(npatches));
xlim([0,1]);
ylim([0 1]);

%s=1/n2;%size of patch
x=linspace(0,1,n2+1);
y=x;
kols=zeros(npatches,3);
ipatch=0;
for k1=1:nbins
    for k2=1:nbins
        for k3=1:nbins
            ipatch=ipatch+1;
            kols(ipatch,:)=[r(k1),g(k2),b(k3)];
        end
    end
end

%locate closest kols to selected color
colordist=sum(abs(kols-selectedcolor(ones(npatches,1),:)),2);
[selectedcolor,iselected]=min(colordist);

ipatch=0;
hp=zeros(1,npatches);
for k=1:n2
    for j=1:n2
        ipatch=ipatch+1;
        hp(ipatch)=patch([x(k) x(k+1) x(k+1) x(k)],[y(j) y(j) y(j+1) y(j+1)],kols(ipatch,:),...
            'buttondownfcn',callback,'userdata',ipatch);
        if(ipatch==iselected)
            xx=[x(k) x(k+1) x(k+1) x(k)];
            yy=[y(j) y(j) y(j+1) y(j+1)];
%             dx=xx(2)-xx(1);
%             dy=yy(2)-yy(1);
%             x2=xx+[-1;1;1;-1]/dx/4;
%             y2=yy+[-1;-1;1;1;]*dy/4;
%             set(hp(ipatch),'linewidth',.5,'xdata',x2,'ydata',y2,'zdata',ones(4,1),'userdata',[xx yy]);
        end
        if(ipatch==npatches)
            break;
        end
    end
    if(ipatch==npatches)
        break;
    end
end
dx=xx(2)-xx(1);
dy=yy(3)-yy(2);
x2=xx+[-1,1,1,-1]*dx/4;
y2=yy+[-1,-1,1,1]*dy/4;
set(hp(iselected),'linewidth',2,'xdata',x2,'ydata',y2,'zdata',ones(4,1),'userdata',[xx(:) yy(:)]);
set(hcax,'xtick',[],'ytick',[],'userdata',{kols,selectedcolor,iselected,hp},'tag','colors',...
    'color',.94*ones(1,3))
title('Click a color to select it')
end

function done(~,~)
hcancel=findobj(gcf,'tag','cancel');
transfer=hcancel.UserData;
eval(transfer);
end

function cancel(~,~)
hcancel=findobj(gcf,'tag','cancel');
transfer=hcancel.UserData;
hdone=findobj(gcf,'tag','done');
hdone.UserData={};
eval(transfer);
end

function choose_horizon(hlist,~)
hfig=gcf;
hold=findobj(hfig,'tag','oldcolor');
hhorcolors=findobj(hfig,'tag','horcolors');
ud=hhorcolors.UserData;
ihor_old=ud{2};
hhp=ud{1};
if(strcmp(get(hlist,'type'),'patch'))
    hp=hlist;
    hlist=findobj(hfig,'tag','horizonlist');
    ihor=find(hhp==hp);
    hlist.Value=ihor;
else
    ihor=hlist.Value;
end
%restore old
if(~isempty(ihor_old))
    ud2=get(hhp(ihor_old),'userdata');
    set(hhp(ihor_old),'linewidth',.5,'xdata',ud2(:,1),'ydata',ud2(:,2),'zdata',zeros(4,1),'userdata',[]);%restore previous
end
%expand new
hhp_new=hhp(ihor);
x=get(hhp_new,'XData');
y=get(hhp_new,'Ydata');
dx=x(2)-x(1);
dy=y(3)-y(2);
x2=x+[-1;1;1;-1]*dx/6;
y2=y+[-1;-1;1;1]*dy/6;
set(hhp_new,'linewidth',2,'xdata',x2,'ydata',y2,'zdata',ones(4,1),'userdata',[x y])
%
ud{2}=ihor;
hhorcolors.UserData=ud;
kol=get(hhp(ihor),'FaceColor');
hold.BackgroundColor=kol;
picktool_getcolor('setcolor',kol);
end

function rename(~,~)
hfig=gcf;
hlist=findobj(hfig,'tag','horizonlist');
ihor=hlist.Value;
hornames=hlist.String;
thisname=hornames{ihor};
q={'Enter new horizon name'};
a={thisname};
newname=askthingsle('questions',q,'answers',a,'title',['Rename horizon ' thisname]);
if(~isempty(newname))
    hdone=findobj(hfig,'tag','done');
    ud=hdone.UserData;
    hornames=ud{1};
    hornames{ihor}=newname{1};
    ud{1}=hornames;
    hdone.UserData=ud;
    hlist.String=hornames;
end
end
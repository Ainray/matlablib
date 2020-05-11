function htsv=viewdata(hmf,buf,xytitle,isdual,isxlabel)
% global vars
%  pagesize,   number of samples per page
%  
 htsv=figure('Name','Time series viewer','Resize','off','DockControls','off',...
 'units','normalized','Position',[0.1,0.1,0.8,0.7],'ToolBar','figure','MenuBar','none',...
 'NumberTitle','off', 'CloseRequestFcn',@(src,evt)closetsv(src,evt,hmf));  


%initialization
initialization(hmf,buf,xytitle,isdual,isxlabel,htsv);

% menu
htsvfile=uimenu(htsv,'Label','&File','HandleVisibility','off');
uimenu(htsvfile,'Label','&Open','Callback',@(src,evt)opents(src,evt,hmf,htsv),'HandleVisibility','off','Enable','off');
htsvview=uimenu(htsv,'Label','&Edit','HandleVisibility','off');
uimenu(htsvview,'Label','&Vetical Scale','CallBack',@(src,evt)verticalscale(src,evt,hmf,htsv),'HandleVisibility','off');
uimenu(htsvview,'Label','&Refresh','CallBack',@(src,evt)refresh(src,evt,hmf,htsv),'HandleVisibility','off');
htsvplot=uimenu(htsv,'Label','&Plot','HandleVisibility','off');
uimenu(htsvplot,'Label','&Replot','CallBack',@(src,evt)replotts(src,evt,hmf,htsv),'HandleVisibility','off');
uimenu(htsvplot,'Label','&Spectra','CallBack',@(src,evt)plotspectra(src,evt,hmf,htsv),'HandleVisibility','off');
uimenu(htsvplot,'Label','&Cross Spectra','CallBack',@(src,evt)plotcrossspectra(src,evt,hmf,htsv),'HandleVisibility','off');
uimenu(htsvplot,'Label','&Impulse','CallBack',@(src,evt)plotimp(src,evt,hmf,htsv),'HandleVisibility','off');
htsvspectra=uimenu(htsv,'Label','&Sepctra','HandleVisibility','off');
uimenu(htsvspectra,'Label','&Computute Sepctra','Callback',@(src,evt)calcspectra(src,evt,hmf,htsv),'HandleVisibility','off');
uimenu(htsvspectra,'Label','&Cross spectra','Callback',@(src,evt)calcrossspectra(src,evt,hmf,htsv),'HandleVisibility','off');
htsvdec=uimenu(htsv,'Label','&Deconvolution','HandleVisibility','off');
uimenu(htsvdec,'Label','&Cross Estimation','Callback',@(src,evt)crossestimation(src,evt,hmf,htsv),'HandleVisibility','off');

% layout
tsvlayout(hmf,htsv);
fplotts(htsv);

function initialization(hmf,buf,xytitle,isdual,isxlabel,htsv)
data=equalen({buf.x, buf.y});
setappdata(htsv,'data',data);
setappdata(htsv,'ph',[buf.xph buf.yph]);
setappdata(htsv,'isspectra',getappdata(hmf,'isspectra'));
setappdata(htsv,'iscrossspectra',getappdata(hmf,'iscrossspectra'));
setappdata(htsv,'isimp',getappdata(hmf,'isimp'));
setappdata(htsv,'spectra',buf.spectra);
setappdata(htsv,'crossspectra',buf.crossspectra);
spp=8000; %samples per page
N=size(data,1);
setappdata(htsv,'pagesize',spp);
setappdata(htsv,'numofpage',ceil(N/spp));
setappdata(htsv,'curpage',1);
setappdata(htsv,'fs',1);
setappdata(htsv,'isrmdc',false);
setappdata(htsv,'xytitle',xytitle);
setappdata(htsv,'isdual',isdual);
setappdata(htsv,'isxlabel',isxlabel);
setappdata(htsv,'enableslide',false);
setappdata(htsv,'isprint',false);
setappdata(htsv,'axyy',0);

function tsvlayout(hmf,htsv)
uicontrol(htsv,'Style','check',...
    'Units','normalized','Position',[0.9,0.85,0.08,0.05],...
    'String','Remove DC','Value',getappdata(htsv,'isrmdc'),'BackgroundColor',get(htsv,'Color'),...
    'callback',@(src,evt)rmdc(src,evt,htsv));       % removedc

uicontrol(htsv,'Style','check',...
    'Units','normalized','Position',[0.9,0.9,0.08,0.05],...
    'String','Samples','Value',1,'BackgroundColor',get(htsv,'Color'),...
    'callback',@(src,evt)sample(src,evt,htsv));% Time abscessa

uicontrol(htsv,'Style','check',...
    'Units','normalized','Position',[0.9,0.8,0.08,0.05],...
    'String','Reverse Src','Value',false,'BackgroundColor',get(htsv,'Color'),...
    'callback',@(src,evt)reversesrc(src,evt,hmf,htsv));  % reverse src

uicontrol(htsv,'Style','check',...
    'Units','normalized','Position',[0.9,0.75,0.08,0.05],...
    'String','Reverse Rcv','Value',false,'BackgroundColor',get(htsv,'Color'),...
    'callback',@(src,evt)reversercv(src,evt,hmf,htsv));  % reverse rcv

uicontrol(htsv,'Style','Frame',...
        'Units','normalized','Position',[0.05,0.045,0.9,0.08],...
        'BackgroundColor',get(htsv,'Color'));  % Frame

htsvplot=uicontrol(htsv,'Style','push','Unit','Normalized',...
        'Position',[0.06,0.06,0.05,0.05],'String','Plot','Tag','decplot1',...
        'CallBack',@(src,evt)ffplotts(src,evt,htsv));       % plot button
    
htsvcurpage=uicontrol(htsv,'Style','edit',...
    'Units','normalized','Position',[0.27,0.06,0.04,0.048],'String',...
    sprintf('%d',getappdata(htsv,'curpage')),'CallBack',...
    @(src,evt)fcurpage(src,evt,htsv)); % cur page  edit

htsvnumofpage=uicontrol(htsv,'Style','text','Tag','decplotpagenum1',...
    'Units','normalized','Position',[0.312,0.055,0.03,0.04],'String',...
    sprintf('%d',getappdata(htsv,'numofpage')),'BackgroundColor',get(htsv,'Color')); % page num text

htsvpagesize=uicontrol(htsv,'Style','edit',...
    'Units','normalized','Position',[0.12,0.06,0.05,0.048],'String',sprintf('%d',getappdata(htsv,'pagesize')),...
    'CallBack',@(src,evt)fpagesize(src,evt,htsvcurpage,htsvnumofpage,htsv)); % page szie edit

 uicontrol(htsv,'Style','text',...
    'Units','normalized','Position',[0.172,0.055,0.05,0.04],'String',...
    'Samples','BackgroundColor',get(htsv,'Color')); % page size text 

htsvpagehome=uicontrol(htsv,'Style','push','Tag','decplotpagehome1',...
    'Units','normalized','Position',[0.22,0.06,0.02,0.05],'String','<<',...
    'CallBack',@(src,evt)fpagehome(src,evt,htsvcurpage,htsv));  % page home button

htsvpagedown=uicontrol(htsv,'Style','push','Tag','decplotpagedown1',...
        'Units','normalized','Position',[0.24,0.06,0.02,0.05],'String','<',...
        'CallBack',@(src,evt)fpagedown(src,evt,htsvcurpage,htsv));  % page down button


htsvpageup=uicontrol(htsv,'Style','push','Tag','decplotpageup1',...
    'Units','normalized','Position',[0.34,0.06,0.02,0.05],'String','>',...
    'CallBack',@(src,evt)fpageup(src,evt,htsvcurpage,htsv)); % page up button

htsvpageend=uicontrol(htsv,'Style','push','Tag','decplotpageend1',...
    'Units','normalized','Position',[0.36,0.06,0.02,0.05],'String','>>',...
    'CallBack',@(src,evt)fpageend(src,evt,htsvcurpage,htsv));  % page end button

htsvslidev=uicontrol(htsv,'Style','slider','Tag','decsliderv1',...
    'Units','normalized','Position',[0.52,0.06,0.16,0.045],'Min',0.001,...
    'Max',2,'Value',1,'CallBack',@fslidevel); % velocity slide
set(htsvslidev,'ToolTipString','Moderate');



uicontrol(htsv,'Style','text','Tag','decslidervmin1',...
    'Units','normalized','Position',[0.69,0.055,0.03,0.04],'String','Slow'...
    ,'BackgroundColor',get(htsv,'Color'));% velocity slide min

uicontrol(htsv,'Style','text','Tag','decslidervmin1',...
    'Units','normalized','Position',[0.48,0.055,0.02,0.04],'String','Fast'...
    ,'BackgroundColor',get(htsv,'Color'));%  velocity slide max


hexport=uicontrol(htsv,'Style','push','Tag','decexport1',...
    'Units','normalized','Position',[0.72,0.06,0.06,0.05],...       
    'CallBack',@(src,evt)fexport(src,evt,htsv),'String','Export');%export fig

hnext=uicontrol(htsv,'Style','push',...
    'Units','normalized','Position',[0.79,0.06,0.06,0.05],...       
    'CallBack',@(src,evt)fnext(src,evt,hmf,htsv),'String','Next');%next pair

hprevious=uicontrol(htsv,'Style','push',...
    'Units','normalized','Position',[0.86,0.06,0.06,0.05],...       
    'CallBack',@(src,evt)fprevious(src,evt,hmf,htsv),'String','Previous');%next pair

uicontrol(htsv,'Style','togglebutton','Tag','decslide1',...
    'Units','normalized','Position',[0.42,0.06,0.05,0.05],'String','Slide',...
    'Value',0,'CallBack',@(src,evt)fslide(src,evt,htsvslidev,htsvplot,htsvpagehome,...
    htsvpagedown,htsvpageend,htsvpageup,htsvpagesize,hexport,...
    hnext,hprevious,htsvcurpage,htsv),'Interruptible','on'); % slide toggle button

function fpagesize(src,~,x1,x2,htsv)
ps=getappdata(htsv,'pagesize');     %old page size;
pnc=getappdata(htsv,'curpage');  %old page number
data=getappdata(htsv,'data');
N=size(data,1);
% update related parameters
pagesize=min(str2double(get(src,'string')),N); 	%page size
numofpage=ceil(N/pagesize);                     %number of pages
curpage=min(numofpage,max(1,ceil(((pnc-1)*ps+1)/pagesize)));          %current page number

setappdata(htsv,'pagesize',pagesize);   % store
setappdata(htsv,'numofpage',numofpage); 
setappdata(htsv,'curpage',curpage);

set(x1,'String',num2str(curpage));      % display
set(x2,'string',num2str(numofpage));

fplotts(htsv);

function fcurpage(src,~,htsv)
curpage=min(max(1,str2double(get(src,'string'))),getappdata(htsv,'numofpage'));
set(src,'string',num2str(curpage));
setappdata(htsv,'curpage',curpage);
fplotts(htsv);

function fpagehome(~,~,x1,htsv)
setappdata(htsv,'curpage',1);
set(x1,'string','1');      
fplotts(htsv);

function fpagedown(~,~,x1,htsv)
curpage=getappdata(htsv,'curpage');
curpage=max(1,curpage-1);
setappdata(htsv,'curpage',curpage);
set(x1,'string',num2str(curpage));
fplotts(htsv);

function fpageup(~,~,x1,htsv)
curpage=getappdata(htsv,'curpage');
curpage=min(getappdata(htsv,'numofpage'),curpage+1);
setappdata(htsv,'curpage',curpage);
set(x1,'string',num2str(curpage)); 
fplotts(htsv);

function fpageend(~,~,x1,htsv)
curpage=getappdata(htsv,'numofpage');
setappdata(htsv,'curpage',curpage);
set(x1,'string',num2str(curpage));   
fplotts(htsv);

function ffplotts(~,~,htsv)
fplotts(htsv);
    
function fplotts(htsv)
data=getappdata(htsv,'data');
ph=getappdata(htsv,'ph');
phase=ones(size(data,1),1)*v2row(ph);
fs=getappdata(htsv,'fs');
if ~isequal(getappdata(htsv,'axyy'),0)
    delete(getappdata(htsv,'axyy'));
end
haxes=axes('Parent',htsv,'Position',[0.08,0.25,0.75,0.7]); % axis
setappdata(htsv,'isprint',true);  % print on
start=min((getappdata(htsv,'curpage')-1)*getappdata(htsv,'pagesize')+1,size(data,1)-1);
length=min(getappdata(htsv,'pagesize'),size(data,1)-start+1);
[ax]=plotstart(data.*phase,'Start',start, 'SamplingRate',fs,'Length',length,...
    'Removedc',getappdata(htsv,'isrmdc'),'NormalXscale',true,'Dual',getappdata(htsv,'isdual'));

if isempty(ax)   % update the axes
   ax=haxes;
end
setappdata(htsv,'axyy',ax);
set(ax,'xLim',[1,length]/fs);
xytitle=getappdata(htsv,'xytitle');
title(xytitle{1},'Interpreter', 'none');
set(get(ax(1),'ylabel'),'string',xytitle{3});
if  ~getappdata(htsv,'isxlabel')
    if fs==1
        xlabel('Time (Sample)');
    else
        xlabel('Time (s)');
    end
else
    xlabel(xytitle{2});  
end
if getappdata(htsv,'isdual')
    set(get(ax(2),'ylabel'),'string',xytitle{4});
%     set(ax(2),'yLim',[-1.1*max(abs(data(:,2))),1.1*max(abs(data(:,2)))+eps]);
end

function rmdc(src,~,htsv) 
if get(src,'value')
    setappdata(htsv,'isrmdc',true);
else
    setappdata(htsv,'isrmdc',false);
end
fplotts(htsv);

function sample(src,~,htsv)
if get(src,'value')
    setappdata(htsv,'fs',1);
else
    setappdata(htsv,'fs',16000);
end

function fslide(src,~,x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,htsvcurpage,htsv)
istoggle=get(src,'Value');
switch istoggle
    case 1        
        for i=1:9 % diable other buttons
           eval(['set(x',num2str(i),',''enable'',''off'')']); 
        end
        isstop=false;
        setappdata(htsv,'enableslide',false);  % enable slide     
        set(src,'String','Stop');   % change toggle string
        i=getappdata(htsv,'curpage');
        N=getappdata(htsv,'numofpage');
        while i<=N && ~isstop
             fplotts(htsv);
             sv=get(x0,'Value');% get current velocity of slideing
             pause(sv/5); % interruptted here
             i=i+1;  % next page
             isstop=getappdata(htsv,'enableslide'); 
             if isstop %interrupted
                 i=i-1;
             end
             setappdata(htsv,'curpage',i);
             set(htsvcurpage,'string',i);
        end
       
    case 0  % stop
      set(src,'String','Slide');         
      fplotts(htsv);
      setappdata(htsv,'enableslide',true);
      for i=1:9 % enable other buttons
           eval(['set(x',num2str(i),',''enable'',''on'')']); 
      end
end

function fslidevel(src,~)
set(src,'ToolTipString',num2str(get(src,'Value')));

function fexport(~,~,htsv)
clr=get(htsv,'color');
if ~getappdata(htsv,'isprint') % no picutre
    return;
end
% axis
[fnamelist] = uiputfile({'*.bmp','Bitmap(*.bmp)';'*.jpg','JPEG(*.jpg)';...
       '*.pdf','PDF(*.pdf)';'*.png','PNG(*.png)';...
       '*.tiff','TIFF(*.tiff)';'*.*','all files (*.*)'},'Export Picture');
if isequal(fnamelist,0)
    return;
end
[path,fname,ext]=fileparts(fnamelist);
warning('off','all');
print_fig(fname,['-',ext(2:end)],'-m2',getappdata(htsv,'axyy'),'n',true);
% htsv=findobj('Tag','htsviewer1');   % export_fig create a copy
% delete(htsv(1));
% htsv=findobj('Tag','htsviewer1'); 
set(htsv,'color',clr);
warning('on','all')
msgbox(sprintf('%s has been exported',fnamelist));

function replotts(~,~,hmf,htsv)
clf(htsv);
buf=getappdata(hmf,'buf');
setappdata(htsv,'data',[buf.x buf.y]);
setappdata(htsv,'isdual',true);
tsvlayout(hmf,htsv);
fplotts(htsv);

function plotspectra(src,evt,hmf,htsv)
if getappdata(htsv,'isspectra')
   fplotspectra(htsv);
end

function plotcrossspectra(src,evt,hmf,htsv)
if getappdata(htsv,'iscrossspectra')
    fplotcross(htsv);
end

function plotimp(src,evt,hmf,htsv)
if getappdata(htsv,'isimp')  % no cross
    setappdata(hmf,'viewimpmode','cur'); % current imp
    setappdata(hmf,'viewimpcurindx',1); 
    buf=getappdata(hmf,'buf');
    viewimp(hmf,buf.imp); 
end
    

function refresh(src,evt,hmf,htsv)
setappdata(htsv,'isspectra',false);
setappdata(htsv,'iscrossspectra',false);
setappdata(htsv,'isimp',false);

function reversesrc(src,evt,hmf,htsv)

ph=getappdata(htsv,'ph');
if get(src,'value')
    ph(1)=-1;
else
    ph(1)=1;
end
setappdata(htsv,'ph',ph);

setappdata(htsv,'isdual',true);
fplotts(htsv);
crossspectra=getappdata(htsv,'crossspectra'); %update crosspectra
if ~isempty(crossspectra)
    crossspectra.b=ph(1)*ph(2)*crossspectra.b;
end
setappdata(htsv,'crossspectra',crossspectra);
buf=getappdata(hmf,'buf');
buf.xph=ph(1);
buf.yph=ph(2);
buf.crossspectra=crossspectra;
if getappdata(htsv,'isimp')
    buf.imp.g=ph(1)*ph(2)*buf.imp.g;
end
setappdata(hmf,'buf',buf);

function reversercv(src,evt,hmf,htsv)
ph=getappdata(htsv,'ph');
if get(src,'value')
    ph(2)=-1;
else
    ph(2)=1;
end
setappdata(htsv,'ph',ph);
setappdata(htsv,'isdual',true);
fplotts(htsv);
crossspectra=getappdata(htsv,'crossspectra'); %update crosspectra
if getappdata(htsv,'iscrossspectra')
    crossspectra.b=ph(1)*ph(2)*crossspectra.b;
end
setappdata(htsv,'crossspectra',crossspectra);
buf=getappdata(hmf,'buf');
buf.xph=ph(1);
buf.yph=ph(2);
buf.crossspectra=crossspectra;
if getappdata(htsv,'isimp')
    buf.imp.g=ph(1)*ph(2)*buf.imp.g;
end
setappdata(hmf,'buf',buf);

function opents(~,~,hmf,htsv)
cwd=cd; % buffer current path
cd(getappdata(hmf,'oldsrcpath'));
[file,path]=uigetfile({'*.dat','Time series (*.dat)';'*,*','all files (*.*)'},'Open Time Series');
if isequal(file,0)
    warndlg('User cancel');
    return;
end
fnamelist=fullfile(path,file);
if ~iscell(fnamelist)  % one file
    ffnamelist={fnamelist};
else
    ffnamelist=fnamelist;
end
src=readdata(ffnamelist);
setappdata(htsv,'data',src);
setappdata(htsv,'xytitle',{[],[],[],[]});
setappdata(htsv,'isdual',false);
setappdata(htsv,'isxlabel','false');
fplotts(htsv);
cd(cwd); % restor path

function verticalscale(src,evt,hmf,htsv)
% 

function calcspectra(src,evt,hmf,htsv)

    data=getappdata(htsv,'data');
    m=esd(data,16000,'Figure','none');
    buf=getappdata(hmf,'buf');
    buf.spectra=m;
    setappdata(hmf,'buf',buf);
    setappdata(hmf,'isspectra',true);
    setappdata(htsv,'isspectra',true);
    setappdata(htsv,'spectra',m);
    fplotspectra(htsv);

function fplotspectra(htsv)
    m=getappdata(htsv,'spectra');
    hd=figure('Name','Spectra','Resize','off','DockControls','off',...
    'units','normalized','Position',[0.1,0.1,0.7,0.7],'NumberTitle','off',....
    'Toolbar','figure','MenuBar','none');
    setappdata(hd,'issrc',true);
    setappdata(hd,'isrcv',true);
    setappdata(hd,'data',m);
    axes('Parent',hd,'Position',[0.08,0.08,0.75,0.88]); % axis
%     uicontrol(hd,'Style','Frame',...
%         'Units','normalized','Position',[0.05,0.045,0.81,0.08],...
%         'BackgroundColor',get(hd,'Color'));  % Frame
    uicontrol(hd,'Style','check',...
    'Units','normalized','Position',[0.9,0.9,0.08,0.05],...
    'String','S','Value',1,'BackgroundColor',get(htsv,'Color'),...
    'callback',@(src,evt)spectrasrcset(src,evt,hd));% S
    uicontrol(hd,'Style','check',...
    'Units','normalized','Position',[0.9,0.85,0.08,0.05],...
    'String','R','Value',1,'BackgroundColor',get(htsv,'Color'),...
    'callback',@(src,evt)spectrarcvset(src,evt,hd));% R
     plotstart(abs(m),'length',size(m,1),'SamplingRate',size(m,1)/8000,'xscale','log','yscale','log');
     
function spectrasrcset(src,~,hd)
    isrcv=getappdata(hd,'isrcv');
    issrc=get(src,'value'); 
    setappdata(hd,'issrc',issrc);  
    if issrc && isrcv
        indx=[1,2];
    else if ~issrc && isrcv
            indx=2;
        else if issrc && ~isrcv
                indx=1;
            else
               cla; 
               return;
            end
        end
    end
    m=getappdata(hd,'data');    
    plotstart(abs(m(:,indx)),'length',size(m,1),'SamplingRate',size(m,1)/8000,'xscale','log','yscale','log');

function spectrarcvset(src,~,hd)
issrc=getappdata(hd,'issrc');
isrcv=get(src,'value'); 
setappdata(hd,'isrcv',isrcv);  
if issrc && isrcv
    indx=[1,2];
else if ~issrc && isrcv
        indx=2;
    else if issrc && ~isrcv
            indx=1;
        else
           cla;
           return;
        end
    end
end
m=getappdata(hd,'data');
plotstart(abs(m(:,indx)),'length',size(m,1),'SamplingRate',size(m,1)/8000,'xscale','log','yscale','log');


function calcrossspectra(src,evt,hmf,htsv)
buf=getappdata(hmf,'buf');
answer=inputdlg({'Number of crosspower','Skip','Length'},'Cross spectra parameter',[1,50],...
     {num2str(min(20,floor(buf.meta.code(3)/3))),'1',num2str(floor(buf.meta.npp*0.6/320)*320)});

if isempty(answer)
     return;
end
number=str2double(answer{1});
skip=str2double(answer{2});
len=str2double(answer{3});
crossspectras(hmf,htsv,number,skip,len);
fplotcross(htsv);

function crossspectras(hmf,htsv,number,skip,len,eirlen)
buf=getappdata(hmf,'buf');

start=floor(skip*buf.meta.ncpp*buf.meta.fs/buf.meta.code(2))+1; % skip number of sample
% if step>buf.meta.code(3)
%     number=1;   
step=ceil((buf.meta.code(3)-skip)/number);
if step*number+skip<buf.meta.code(3)
    number=number+1;
end
ends(1:number+1)=start+floor(( (0:step:step*number)*...
    buf.meta.ncpp*buf.meta.fs/buf.meta.code(2)));% calaculating the bound of per segment
 nps=floor(step*buf.meta.ncpp*buf.meta.fs/buf.meta.code(2));% number of samples per segment
 rtmp=zeros(len,number);
 btmp=zeros(len,number);
 src=zeros(nps,number);
 rcv=zeros(nps,number);
 x=removedc(buf.x(start:end));y=removedc(buf.y(start:end));
 m=equalen({x,y},ends(end));
 x=m(:,1);y=m(:,2);
 N=min(numel(x),numel(y));
%  rxxtmp=zeros(2*nps-1,number);
 for i=1:number % number is the  segments of calculating impules     
         re=ends(i+1);  % the rigth bound
         if i==1 && re>N  % only one segment
             re=N;
         end
         if re<=N       % check data size limit
            src(:,i)=removedc(x( max(re-nps+1,1):re)*buf.xph); % cut the data
            rcv(:,i)=removedc(y(max(re-nps+1,1):re)*buf.yph);  
            %[rtmp(:,i),btmp(:,i)]=accorr(src(:,i),rcv(:,i),1,len);
            [rtmp(:,i),btmp(:,i)]=accorr(src(:,i),rcv(:,i),0);
         end
 end
r=mean(rtmp,2);
b=mean(btmp,2);
% rxx=mean(rxxtmp,2);
crossspectra.r=r;
crossspectra.b=b;
% crossspectra.rxx=rxx;
%      crossspectra.rtmp=rtmp;
%      crossspectra.btmp=btmp;
 crossspectra.skip=skip;
 crossspectra.number=number;
 crossspectra.nps= nps;
 setappdata(htsv,'crossspectra',crossspectra);
 buf=getappdata(hmf,'buf');
 buf.crossspectra=crossspectra;
 setappdata(hmf,'buf',buf);
 setappdata(hmf,'iscrossspectra',true);
 setappdata(htsv,'iscrossspectra',true);
 
function fplotcross(htsv)
crossspectra=getappdata(htsv,'crossspectra');
hd=figure('Name','Cross spectra','NumberTitle','off','MenuBar','none','ToolBar','figure',...
     'units','normalized','Position',[0.1,0.1,0.7,0.7]);
axes('Parent',hd,'Position',[0.08,0.6,0.75,0.35]); % axis
plot(time_vector(crossspectra.r,1),crossspectra.r,'r');
set(gca,'Xlim',[-0.01,1]*length(crossspectra.r));
xlabel('Time (Samples)');ylabel('Amplitude');
title('a.) Auto correlation of PRBS current and reponse');
axes('Parent',hd,'Position',[0.08,0.08,0.75,0.35]); % axis
plot(time_vector(crossspectra.b,1),crossspectra.b,'r');
set(gca,'Xlim',[-0.01,1]*length(crossspectra.r));
xlabel('Time (Samples)');ylabel('Amplitude');box on;
title('b.) Cross correlation of PRBS current and reponse');

function crossestimation(src,evt,hmf,htsv)
if ~getappdata(htsv,'iscrossspectra')  % no cross
    warndlg('Please first calculate the cross spectra');
    return; % user cancel
end

answer=inputdlg({'Prewhiten Noise','Length'},'EIR parameter',[1,50],...
     {'0.02',num2str(3200)});
 if isempty(answer)
     return;
 end
prenoise=str2double(answer{1}); 
len=str2double(answer{2});
crossdeconv(hmf,htsv,prenoise,len);
setappdata(hmf,'viewimpmode','cur'); % current imp
setappdata(hmf,'viewimpcurindx',1); 
buf=getappdata(hmf,'buf');
viewimp(hmf,buf.imp); 

 
function crossdeconv(hmf,htsv,prenoise,len)
buf=getappdata(hmf,'buf');
imp=initialimp;
imp.meta=buf.meta;
% len=length(buf.crossspectra.r);
% nps=buf.crossspectra.nps;
% x=buf.crossspectra.rxx(nps-len-1:end)/buf.crossspectra.r(1);
imp.g=levidurb(buf.crossspectra.r(1:len),buf.crossspectra.b(1:len),prenoise);
imp.mask=1;     % assuming effective data
imp.bg=imp.g;       % EIR backup
imp.ng=imp.g;
imp.r=buf.crossspectra.r;
imp.b=buf.crossspectra.b;
imp.ts=time_vector(imp.g,imp.meta.fs); % time abscissa
imp=peakimp(imp);
buf.imp=imp;
setappdata(hmf,'buf',buf);
setappdata(hmf,'isimp',true);
setappdata(htsv,'isimp',true);

function fnext(~,~,hmf,htsv)
curindxofsrt=getappdata(hmf,'curindxofsrt');
curindxofbuf=getappdata(hmf,'curindxofbuf');
ssrt=getappdata(hmf,'ssrt');
numofssrt=getappdata(hmf,'numofssrt');
if curindxofsrt<numofssrt  % next one
    curindxofsrt=curindxofsrt+1;
    setappdata(hmf,'curindxofsrt',curindxofsrt);
end
if curindxofbuf~=curindxofsrt  % new buf 
     updatebuf(curindxofsrt,hmf);
end
% replot
curindxofbuf=getappdata(hmf,'curindxofbuf');
buf=getappdata(hmf,'buf');
nextpair(hmf,buf,{sprintf('S: %s.dat/%dm, R: %s.dat/%dm, F: %dHz, N: %d',...
    ssrt{curindxofbuf,2},buf.meta.srcpos,ssrt{curindxofbuf,3},...
    buf.meta.rcvpos, buf.meta.code(2),buf.meta.code(1)),[],'Current (A)','Voltage (V)'},...
    htsv);
fplotts(htsv);

function fprevious(src,evt,hmf,htsv)
curindxofsrt=getappdata(hmf,'curindxofsrt');
curindxofbuf=getappdata(hmf,'curindxofbuf');
ssrt=getappdata(hmf,'ssrt');
if curindxofsrt>1  %previous one
    curindxofsrt=curindxofsrt-1;
    setappdata(hmf,'curindxofsrt',curindxofsrt);
end
if curindxofbuf~=curindxofsrt  % new buf 
     updatebuf(curindxofsrt,hmf);
end
% replot
curindxofbuf=getappdata(hmf,'curindxofbuf');
buf=getappdata(hmf,'buf');
nextpair(hmf,buf,{sprintf('S: %s.dat/%dm, R: %s.dat/%dm, F: %dHz, N: %d',...
    ssrt{curindxofbuf,2},buf.meta.srcpos,ssrt{curindxofbuf,3},...
    buf.meta.rcvpos, buf.meta.code(2),buf.meta.code(1)),[],'Current (A)','Voltage (V)'},...
    htsv);
fplotts(htsv);

function updatebuf(curindxofsrt,hmf)
ssrt=getappdata(hmf,'ssrt');
if ~isempty(ssrt)
    setappdata(hmf,'curindxofbuf',curindxofsrt); % buf the first one
    [buf.x,buf.y,buf.meta]=readdata(ssrt(curindxofsrt,:),getappdata(hmf,'scn'));
    buf.xph=1;
    buf.yph=1;
    setappdata(hmf,'isspectra',false);  % sepctra
    setappdata(hmf,'iscrossspectra',false); % iscrossspectra
    setappdata(hmf,'isimp',false);
    buf.spectra=[];
    buf.crossspectra=[];
    buf.imp=[];
    setappdata(hmf,'buf',buf);
else
    warndlg('Please first set the path');
end

function nextpair(hmf,buf,xytitle,htsv)
data=equalen({buf.x, buf.y});
setappdata(htsv,'data',data);
setappdata(htsv,'ph',[buf.xph buf.yph]);
setappdata(htsv,'isspectra',getappdata(hmf,'isspectra'));
setappdata(htsv,'iscrossspectra',getappdata(hmf,'iscrossspectra'));
setappdata(htsv,'isimp',getappdata(hmf,'isimp'));
setappdata(htsv,'spectra',buf.spectra);
setappdata(htsv,'crossspectra',buf.crossspectra);
spp=8000; %samples per page
N=size(data,1);
setappdata(htsv,'pagesize',spp);
setappdata(htsv,'numofpage',ceil(N/spp));
setappdata(htsv,'curpage',1);
setappdata(htsv,'xytitle',xytitle);

function closetsv(htsv,evt,hmf)
ssrt=getappdata(hmf,'ssrt');
curindxofsrt=getappdata(hmf,'curindxofsrt');
ssrt(:,5)={false};
ssrt(curindxofsrt,5)={true};
setappdata(hmf,'ssrt',ssrt);
delete(htsv);

function hp2tgt1=viewdata(hmf,buf,xytitle,isdual,isxlabel)
% global vars
%  pagesize,   number of samples per page
%  
 hp2tgt1=figure('Name','Time series viewer','Resize','off','DockControls','off',...
 'units','normalized','Position',[0.1,0.1,0.8,0.7],'ToolBar','figure','MenuBar','none',...
 'NumberTitle','off', 'CloseRequestFcn',@(src,evt)closetsv(src,evt,hmf));  


%initialization
initialization(hmf,buf,xytitle,isdual,isxlabel,hp2tgt1);

% menu
hp2tgt1file=uimenu(hp2tgt1,'Label','&File','HandleVisibility','off');
uimenu(hp2tgt1file,'Label','&Open','Callback',@(src,evt)opents(src,evt,hmf,hp2tgt1),'HandleVisibility','off','Enable','off');
hp2tgt1view=uimenu(hp2tgt1,'Label','&Edit','HandleVisibility','off');
uimenu(hp2tgt1view,'Label','&Vetical Scale','CallBack',@(src,evt)verticalscale(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
uimenu(hp2tgt1view,'Label','&Refresh','CallBack',@(src,evt)refresh(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
hp2tgt1plot=uimenu(hp2tgt1,'Label','&Plot','HandleVisibility','off');
uimenu(hp2tgt1plot,'Label','&Replot','CallBack',@(src,evt)replotts(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
uimenu(hp2tgt1plot,'Label','&Spectra','CallBack',@(src,evt)plotspectra(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
uimenu(hp2tgt1plot,'Label','&Cross Spectra','CallBack',@(src,evt)plotcrossspectra(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
uimenu(hp2tgt1plot,'Label','&Impulse','CallBack',@(src,evt)plotimp(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
hp2tgt1spectra=uimenu(hp2tgt1,'Label','&Sepctra','HandleVisibility','off');
uimenu(hp2tgt1spectra,'Label','&Computute Sepctra','Callback',@(src,evt)calcspectra(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
uimenu(hp2tgt1spectra,'Label','&Cross spectra','Callback',@(src,evt)calcrossspectra(src,evt,hmf,hp2tgt1),'HandleVisibility','off');
hp2tgt1dec=uimenu(hp2tgt1,'Label','&Deconvolution','HandleVisibility','off');
uimenu(hp2tgt1dec,'Label','&Cross Estimation','Callback',@(src,evt)crossestimation(src,evt,hmf,hp2tgt1),'HandleVisibility','off');

% layout
tsvlayout(hmf,hp2tgt1);
fplotts(hp2tgt1);

function initialization(hmf,buf,xytitle,isdual,isxlabel,hp2tgt1)
data=equalen({buf.x, buf.y});
setappdata(hp2tgt1,'data',data);
setappdata(hp2tgt1,'ph',[buf.xph buf.yph]);
setappdata(hp2tgt1,'isspectra',getappdata(hmf,'isspectra'));
setappdata(hp2tgt1,'iscrossspectra',getappdata(hmf,'iscrossspectra'));
setappdata(hp2tgt1,'isimp',getappdata(hmf,'isimp'));
setappdata(hp2tgt1,'spectra',buf.spectra);
setappdata(hp2tgt1,'crossspectra',buf.crossspectra);
spp=8000; %samples per page
N=size(data,1);
setappdata(hp2tgt1,'pagesize',spp);
setappdata(hp2tgt1,'numofpage',ceil(N/spp));
setappdata(hp2tgt1,'curpage',1);
setappdata(hp2tgt1,'fs',1);
setappdata(hp2tgt1,'isrmdc',false);
setappdata(hp2tgt1,'xytitle',xytitle);
setappdata(hp2tgt1,'isdual',isdual);
setappdata(hp2tgt1,'isxlabel',isxlabel);
setappdata(hp2tgt1,'enableslide',false);
setappdata(hp2tgt1,'isprint',false);
setappdata(hp2tgt1,'axyy',0);

function tsvlayout(hmf,hp2tgt1)
uicontrol(hp2tgt1,'Style','check',...
    'Units','normalized','Position',[0.9,0.85,0.08,0.05],...
    'String','Remove DC','Value',getappdata(hp2tgt1,'isrmdc'),'BackgroundColor',get(hp2tgt1,'Color'),...
    'callback',@(src,evt)rmdc(src,evt,hp2tgt1));       % removedc

uicontrol(hp2tgt1,'Style','check',...
    'Units','normalized','Position',[0.9,0.9,0.08,0.05],...
    'String','Samples','Value',1,'BackgroundColor',get(hp2tgt1,'Color'),...
    'callback',@(src,evt)sample(src,evt,hp2tgt1));% Time abscessa

uicontrol(hp2tgt1,'Style','check',...
    'Units','normalized','Position',[0.9,0.8,0.08,0.05],...
    'String','Reverse Src','Value',false,'BackgroundColor',get(hp2tgt1,'Color'),...
    'callback',@(src,evt)reversesrc(src,evt,hmf,hp2tgt1));  % reverse src

uicontrol(hp2tgt1,'Style','check',...
    'Units','normalized','Position',[0.9,0.75,0.08,0.05],...
    'String','Reverse Rcv','Value',false,'BackgroundColor',get(hp2tgt1,'Color'),...
    'callback',@(src,evt)reversercv(src,evt,hmf,hp2tgt1));  % reverse rcv

uicontrol(hp2tgt1,'Style','Frame',...
        'Units','normalized','Position',[0.05,0.045,0.9,0.08],...
        'BackgroundColor',get(hp2tgt1,'Color'));  % Frame

hp2tgt1plot=uicontrol(hp2tgt1,'Style','push','Unit','Normalized',...
        'Position',[0.06,0.06,0.05,0.05],'String','Plot','Tag','decplot1',...
        'CallBack',@(src,evt)ffplotts(src,evt,hp2tgt1));       % plot button
    
hp2tgt1curpage=uicontrol(hp2tgt1,'Style','edit',...
    'Units','normalized','Position',[0.27,0.06,0.04,0.048],'String',...
    sprintf('%d',getappdata(hp2tgt1,'curpage')),'CallBack',...
    @(src,evt)fcurpage(src,evt,hp2tgt1)); % cur page  edit

hp2tgt1numofpage=uicontrol(hp2tgt1,'Style','text','Tag','decplotpagenum1',...
    'Units','normalized','Position',[0.312,0.055,0.03,0.04],'String',...
    sprintf('%d',getappdata(hp2tgt1,'numofpage')),'BackgroundColor',get(hp2tgt1,'Color')); % page num text

hp2tgt1pagesize=uicontrol(hp2tgt1,'Style','edit',...
    'Units','normalized','Position',[0.12,0.06,0.05,0.048],'String',sprintf('%d',getappdata(hp2tgt1,'pagesize')),...
    'CallBack',@(src,evt)fpagesize(src,evt,hp2tgt1curpage,hp2tgt1numofpage,hp2tgt1)); % page szie edit

 uicontrol(hp2tgt1,'Style','text',...
    'Units','normalized','Position',[0.172,0.055,0.05,0.04],'String',...
    'Samples','BackgroundColor',get(hp2tgt1,'Color')); % page size text 

hp2tgt1pagehome=uicontrol(hp2tgt1,'Style','push','Tag','decplotpagehome1',...
    'Units','normalized','Position',[0.22,0.06,0.02,0.05],'String','<<',...
    'CallBack',@(src,evt)fpagehome(src,evt,hp2tgt1curpage,hp2tgt1));  % page home button

hp2tgt1pagedown=uicontrol(hp2tgt1,'Style','push','Tag','decplotpagedown1',...
        'Units','normalized','Position',[0.24,0.06,0.02,0.05],'String','<',...
        'CallBack',@(src,evt)fpagedown(src,evt,hp2tgt1curpage,hp2tgt1));  % page down button


hp2tgt1pageup=uicontrol(hp2tgt1,'Style','push','Tag','decplotpageup1',...
    'Units','normalized','Position',[0.34,0.06,0.02,0.05],'String','>',...
    'CallBack',@(src,evt)fpageup(src,evt,hp2tgt1curpage,hp2tgt1)); % page up button

hp2tgt1pageend=uicontrol(hp2tgt1,'Style','push','Tag','decplotpageend1',...
    'Units','normalized','Position',[0.36,0.06,0.02,0.05],'String','>>',...
    'CallBack',@(src,evt)fpageend(src,evt,hp2tgt1curpage,hp2tgt1));  % page end button

hp2tgt1slidev=uicontrol(hp2tgt1,'Style','slider','Tag','decsliderv1',...
    'Units','normalized','Position',[0.52,0.06,0.16,0.045],'Min',0.001,...
    'Max',2,'Value',1,'CallBack',@fslidevel); % velocity slide
set(hp2tgt1slidev,'ToolTipString','Moderate');



uicontrol(hp2tgt1,'Style','text','Tag','decslidervmin1',...
    'Units','normalized','Position',[0.69,0.055,0.03,0.04],'String','Slow'...
    ,'BackgroundColor',get(hp2tgt1,'Color'));% velocity slide min

uicontrol(hp2tgt1,'Style','text','Tag','decslidervmin1',...
    'Units','normalized','Position',[0.48,0.055,0.02,0.04],'String','Fast'...
    ,'BackgroundColor',get(hp2tgt1,'Color'));%  velocity slide max


hexport=uicontrol(hp2tgt1,'Style','push','Tag','decexport1',...
    'Units','normalized','Position',[0.72,0.06,0.06,0.05],...       
    'CallBack',@(src,evt)fexport(src,evt,hp2tgt1),'String','Export');%export fig

hnext=uicontrol(hp2tgt1,'Style','push',...
    'Units','normalized','Position',[0.79,0.06,0.06,0.05],...       
    'CallBack',@(src,evt)fnext(src,evt,hmf,hp2tgt1),'String','Next');%next pair

hprevious=uicontrol(hp2tgt1,'Style','push',...
    'Units','normalized','Position',[0.86,0.06,0.06,0.05],...       
    'CallBack',@(src,evt)fprevious(src,evt,hmf,hp2tgt1),'String','Previous');%next pair

uicontrol(hp2tgt1,'Style','togglebutton','Tag','decslide1',...
    'Units','normalized','Position',[0.42,0.06,0.05,0.05],'String','Slide',...
    'Value',0,'CallBack',@(src,evt)fslide(src,evt,hp2tgt1slidev,hp2tgt1plot,hp2tgt1pagehome,...
    hp2tgt1pagedown,hp2tgt1pageend,hp2tgt1pageup,hp2tgt1pagesize,hexport,...
    hnext,hprevious,hp2tgt1curpage,hp2tgt1),'Interruptible','on'); % slide toggle button

function fpagesize(src,~,x1,x2,hp2tgt1)
ps=getappdata(hp2tgt1,'pagesize');     %old page size;
pnc=getappdata(hp2tgt1,'curpage');  %old page number
data=getappdata(hp2tgt1,'data');
N=size(data,1);
% update related parameters
pagesize=min(str2double(get(src,'string')),N); 	%page size
numofpage=ceil(N/pagesize);                     %number of pages
curpage=min(numofpage,max(1,ceil(((pnc-1)*ps+1)/pagesize)));          %current page number

setappdata(hp2tgt1,'pagesize',pagesize);   % store
setappdata(hp2tgt1,'numofpage',numofpage); 
setappdata(hp2tgt1,'curpage',curpage);

set(x1,'String',num2str(curpage));      % display
set(x2,'string',num2str(numofpage));

fplotts(hp2tgt1);

function fcurpage(src,~,hp2tgt1)
curpage=min(max(1,str2double(get(src,'string'))),getappdata(hp2tgt1,'numofpage'));
set(src,'string',num2str(curpage));
setappdata(hp2tgt1,'curpage',curpage);
fplotts(hp2tgt1);

function fpagehome(~,~,x1,hp2tgt1)
setappdata(hp2tgt1,'curpage',1);
set(x1,'string','1');      
fplotts(hp2tgt1);

function fpagedown(~,~,x1,hp2tgt1)
curpage=getappdata(hp2tgt1,'curpage');
curpage=max(1,curpage-1);
setappdata(hp2tgt1,'curpage',curpage);
set(x1,'string',num2str(curpage));
fplotts(hp2tgt1);

function fpageup(~,~,x1,hp2tgt1)
curpage=getappdata(hp2tgt1,'curpage');
curpage=min(getappdata(hp2tgt1,'numofpage'),curpage+1);
setappdata(hp2tgt1,'curpage',curpage);
set(x1,'string',num2str(curpage)); 
fplotts(hp2tgt1);

function fpageend(~,~,x1,hp2tgt1)
curpage=getappdata(hp2tgt1,'numofpage');
setappdata(hp2tgt1,'curpage',curpage);
set(x1,'string',num2str(curpage));   
fplotts(hp2tgt1);

function ffplotts(~,~,hp2tgt1)
fplotts(hp2tgt1);
    
function fplotts(hp2tgt1)
data=getappdata(hp2tgt1,'data');
ph=getappdata(hp2tgt1,'ph');
phase=ones(size(data,1),1)*v2row(ph);
fs=getappdata(hp2tgt1,'fs');
if ~isequal(getappdata(hp2tgt1,'axyy'),0)
    delete(getappdata(hp2tgt1,'axyy'));
end
haxes=axes('Parent',hp2tgt1,'Position',[0.08,0.25,0.75,0.7]); % axis
setappdata(hp2tgt1,'isprint',true);  % print on
start=min((getappdata(hp2tgt1,'curpage')-1)*getappdata(hp2tgt1,'pagesize')+1,size(data,1)-1);
length=min(getappdata(hp2tgt1,'pagesize'),size(data,1)-start+1);
[ax]=plotstart(data.*phase,'Start',start, 'SamplingRate',fs,'Length',length,...
    'Removedc',getappdata(hp2tgt1,'isrmdc'),'NormalXscale',true,'Dual',getappdata(hp2tgt1,'isdual'));

if isempty(ax)   % update the axes
   ax=haxes;
end
setappdata(hp2tgt1,'axyy',ax);
set(ax,'xLim',[1,length]/fs);
xytitle=getappdata(hp2tgt1,'xytitle');
title(xytitle{1},'Interpreter', 'none');
set(get(ax(1),'ylabel'),'string',xytitle{3});
if  ~getappdata(hp2tgt1,'isxlabel')
    if fs==1
        xlabel('Time (Sample)');
    else
        xlabel('Time (s)');
    end
else
    xlabel(xytitle{2});  
end
if getappdata(hp2tgt1,'isdual')
    set(get(ax(2),'ylabel'),'string',xytitle{4});
%     set(ax(2),'yLim',[-1.1*max(abs(data(:,2))),1.1*max(abs(data(:,2)))+eps]);
end

function rmdc(src,~,hp2tgt1) 
if get(src,'value')
    setappdata(hp2tgt1,'isrmdc',true);
else
    setappdata(hp2tgt1,'isrmdc',false);
end
fplotts(hp2tgt1);

function sample(src,~,hp2tgt1)
if get(src,'value')
    setappdata(hp2tgt1,'fs',1);
else
    setappdata(hp2tgt1,'fs',16000);
end

function fslide(src,~,x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,hp2tgt1curpage,hp2tgt1)
istoggle=get(src,'Value');
switch istoggle
    case 1        
        for i=1:9 % diable other buttons
           eval(['set(x',num2str(i),',''enable'',''off'')']); 
        end
        isstop=false;
        setappdata(hp2tgt1,'enableslide',false);  % enable slide     
        set(src,'String','Stop');   % change toggle string
        i=getappdata(hp2tgt1,'curpage');
        N=getappdata(hp2tgt1,'numofpage');
        while i<=N && ~isstop
             fplotts(hp2tgt1);
             sv=get(x0,'Value');% get current velocity of slideing
             pause(sv/5); % interruptted here
             i=i+1;  % next page
             isstop=getappdata(hp2tgt1,'enableslide'); 
             if isstop %interrupted
                 i=i-1;
             end
             setappdata(hp2tgt1,'curpage',i);
             set(hp2tgt1curpage,'string',i);
        end
       
    case 0  % stop
      set(src,'String','Slide');         
      fplotts(hp2tgt1);
      setappdata(hp2tgt1,'enableslide',true);
      for i=1:9 % enable other buttons
           eval(['set(x',num2str(i),',''enable'',''on'')']); 
      end
end

function fslidevel(src,~)
set(src,'ToolTipString',num2str(get(src,'Value')));

function fexport(~,~,hp2tgt1)
clr=get(hp2tgt1,'color');
if ~getappdata(hp2tgt1,'isprint') % no picutre
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
print_fig(fname,['-',ext(2:end)],'-m2',getappdata(hp2tgt1,'axyy'),'n',true);
% hp2tgt1=findobj('Tag','hp2tgt1iewer1');   % export_fig create a copy
% delete(hp2tgt1(1));
% hp2tgt1=findobj('Tag','hp2tgt1iewer1'); 
set(hp2tgt1,'color',clr);
warning('on','all')
msgbox(sprintf('%s has been exported',fnamelist));

function replotts(~,~,hmf,hp2tgt1)
clf(hp2tgt1);
buf=getappdata(hmf,'buf');
setappdata(hp2tgt1,'data',[buf.x buf.y]);
setappdata(hp2tgt1,'isdual',true);
tsvlayout(hmf,hp2tgt1);
fplotts(hp2tgt1);

function plotspectra(src,evt,hmf,hp2tgt1)
if getappdata(hp2tgt1,'isspectra')
   fplotspectra(hp2tgt1);
end

function plotcrossspectra(src,evt,hmf,hp2tgt1)
if getappdata(hp2tgt1,'iscrossspectra')
    fplotcross(hp2tgt1);
end

function plotimp(src,evt,hmf,hp2tgt1)
if getappdata(hp2tgt1,'isimp')  % no cross
    setappdata(hmf,'viewimpmode','cur'); % current imp
    setappdata(hmf,'viewimpcurindx',1); 
    buf=getappdata(hmf,'buf');
    viewimp(hmf,buf.imp); 
end
    

function refresh(src,evt,hmf,hp2tgt1)
setappdata(hp2tgt1,'isspectra',false);
setappdata(hp2tgt1,'iscrossspectra',false);
setappdata(hp2tgt1,'isimp',false);

function reversesrc(src,evt,hmf,hp2tgt1)

ph=getappdata(hp2tgt1,'ph');
if get(src,'value')
    ph(1)=-1;
else
    ph(1)=1;
end
setappdata(hp2tgt1,'ph',ph);

setappdata(hp2tgt1,'isdual',true);
fplotts(hp2tgt1);
crossspectra=getappdata(hp2tgt1,'crossspectra'); %update crosspectra
if ~isempty(crossspectra)
    crossspectra.b=ph(1)*ph(2)*crossspectra.b;
end
setappdata(hp2tgt1,'crossspectra',crossspectra);
buf=getappdata(hmf,'buf');
buf.xph=ph(1);
buf.yph=ph(2);
buf.crossspectra=crossspectra;
if getappdata(hp2tgt1,'isimp')
    buf.imp.g=ph(1)*ph(2)*buf.imp.g;
end
setappdata(hmf,'buf',buf);

function reversercv(src,evt,hmf,hp2tgt1)
ph=getappdata(hp2tgt1,'ph');
if get(src,'value')
    ph(2)=-1;
else
    ph(2)=1;
end
setappdata(hp2tgt1,'ph',ph);
setappdata(hp2tgt1,'isdual',true);
fplotts(hp2tgt1);
crossspectra=getappdata(hp2tgt1,'crossspectra'); %update crosspectra
if getappdata(hp2tgt1,'iscrossspectra')
    crossspectra.b=ph(1)*ph(2)*crossspectra.b;
end
setappdata(hp2tgt1,'crossspectra',crossspectra);
buf=getappdata(hmf,'buf');
buf.xph=ph(1);
buf.yph=ph(2);
buf.crossspectra=crossspectra;
if getappdata(hp2tgt1,'isimp')
    buf.imp.g=ph(1)*ph(2)*buf.imp.g;
end
setappdata(hmf,'buf',buf);

function opents(~,~,hmf,hp2tgt1)
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
setappdata(hp2tgt1,'data',src);
setappdata(hp2tgt1,'xytitle',{[],[],[],[]});
setappdata(hp2tgt1,'isdual',false);
setappdata(hp2tgt1,'isxlabel','false');
fplotts(hp2tgt1);
cd(cwd); % restor path

function verticalscale(src,evt,hmf,hp2tgt1)
% 

function calcspectra(src,evt,hmf,hp2tgt1)

    data=getappdata(hp2tgt1,'data');
    m=esd(data,16000,'Figure','none');
    buf=getappdata(hmf,'buf');
    buf.spectra=m;
    setappdata(hmf,'buf',buf);
    setappdata(hmf,'isspectra',true);
    setappdata(hp2tgt1,'isspectra',true);
    setappdata(hp2tgt1,'spectra',m);
    fplotspectra(hp2tgt1);

function fplotspectra(hp2tgt1)
    m=getappdata(hp2tgt1,'spectra');
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
    'String','S','Value',1,'BackgroundColor',get(hp2tgt1,'Color'),...
    'callback',@(src,evt)spectrasrcset(src,evt,hd));% S
    uicontrol(hd,'Style','check',...
    'Units','normalized','Position',[0.9,0.85,0.08,0.05],...
    'String','R','Value',1,'BackgroundColor',get(hp2tgt1,'Color'),...
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


function calcrossspectra(src,evt,hmf,hp2tgt1)
buf=getappdata(hmf,'buf');
answer=inputdlg({'Number of crosspower','Skip','Length'},'Cross spectra parameter',[1,50],...
     {num2str(min(20,floor(buf.meta.code(3)/3))),'1',num2str(floor(buf.meta.npp*0.6/320)*320)});

if isempty(answer)
     return;
end
number=str2double(answer{1});
skip=str2double(answer{2});
len=str2double(answer{3});
crossspectras(hmf,hp2tgt1,number,skip,len);
fplotcross(hp2tgt1);

function crossspectras(hmf,hp2tgt1,number,skip,len,eirlen)
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
            [rtmp(:,i),btmp(:,i)]=accorr(src(:,i),rcv(:,i),len);                   
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
 setappdata(hp2tgt1,'crossspectra',crossspectra);
 buf=getappdata(hmf,'buf');
 buf.crossspectra=crossspectra;
 setappdata(hmf,'buf',buf);
 setappdata(hmf,'iscrossspectra',true);
 setappdata(hp2tgt1,'iscrossspectra',true);
 
function fplotcross(hp2tgt1)
crossspectra=getappdata(hp2tgt1,'crossspectra');
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

function crossestimation(src,evt,hmf,hp2tgt1)
if ~getappdata(hp2tgt1,'iscrossspectra')  % no cross
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
crossdeconv(hmf,hp2tgt1,prenoise,len);
setappdata(hmf,'viewimpmode','cur'); % current imp
setappdata(hmf,'viewimpcurindx',1); 
buf=getappdata(hmf,'buf');
viewimp(hmf,buf.imp); 

 
function crossdeconv(hmf,hp2tgt1,prenoise,len)
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
setappdata(hp2tgt1,'isimp',true);

function fnext(~,~,hmf,hp2tgt1)
curindxofsrp=getappdata(hmf,'curindxofsrp');
curindxofbuf=getappdata(hmf,'curindxofbuf');
srptbl=getappdata(hmf,'srptbl');
numofsrp=getappdata(hmf,'numofsrp');
if curindxofsrp<numofsrp  % next one
    curindxofsrp=curindxofsrp+1;
    setappdata(hmf,'curindxofsrp',curindxofsrp);
end
if curindxofbuf~=curindxofsrp  % new buf 
     updatebuf(curindxofsrp,hmf);
end
% replot
curindxofbuf=getappdata(hmf,'curindxofbuf');
buf=getappdata(hmf,'buf');
nextpair(hmf,buf,{sprintf('S: %s.dat/%dm, R: %s.dat/%dm, F: %dHz, N: %d',...
    srptbl{curindxofbuf,2},buf.meta.srcpos,srptbl{curindxofbuf,3},...
    buf.meta.rcvpos, buf.meta.code(2),buf.meta.code(1)),[],'Current (A)','Voltage (V)'},...
    hp2tgt1);
fplotts(hp2tgt1);

function fprevious(src,evt,hmf,hp2tgt1)
curindxofsrp=getappdata(hmf,'curindxofsrp');
curindxofbuf=getappdata(hmf,'curindxofbuf');
srptbl=getappdata(hmf,'srptbl');
if curindxofsrp>1  %previous one
    curindxofsrp=curindxofsrp-1;
    setappdata(hmf,'curindxofsrp',curindxofsrp);
end
if curindxofbuf~=curindxofsrp  % new buf 
     updatebuf(curindxofsrp,hmf);
end
% replot
curindxofbuf=getappdata(hmf,'curindxofbuf');
buf=getappdata(hmf,'buf');
nextpair(hmf,buf,{sprintf('S: %s.dat/%dm, R: %s.dat/%dm, F: %dHz, N: %d',...
    srptbl{curindxofbuf,2},buf.meta.srcpos,srptbl{curindxofbuf,3},...
    buf.meta.rcvpos, buf.meta.code(2),buf.meta.code(1)),[],'Current (A)','Voltage (V)'},...
    hp2tgt1);
fplotts(hp2tgt1);

function updatebuf(curindxofsrp,hmf)
srptbl=getappdata(hmf,'srptbl');
if ~isempty(srptbl)
    setappdata(hmf,'curindxofbuf',curindxofsrp); % buf the first one
    [buf.x,buf.y,buf.meta]=readdata(srptbl(curindxofsrp,:),getappdata(hmf,'srcch'));
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

function nextpair(hmf,buf,xytitle,hp2tgt1)
data=equalen({buf.x, buf.y});
setappdata(hp2tgt1,'data',data);
setappdata(hp2tgt1,'ph',[buf.xph buf.yph]);
setappdata(hp2tgt1,'isspectra',getappdata(hmf,'isspectra'));
setappdata(hp2tgt1,'iscrossspectra',getappdata(hmf,'iscrossspectra'));
setappdata(hp2tgt1,'isimp',getappdata(hmf,'isimp'));
setappdata(hp2tgt1,'spectra',buf.spectra);
setappdata(hp2tgt1,'crossspectra',buf.crossspectra);
spp=8000; %samples per page
N=size(data,1);
setappdata(hp2tgt1,'pagesize',spp);
setappdata(hp2tgt1,'numofpage',ceil(N/spp));
setappdata(hp2tgt1,'curpage',1);
setappdata(hp2tgt1,'xytitle',xytitle);

function closetsv(hp2tgt1,evt,hmf)
srptbl=getappdata(hmf,'srptbl');
curindxofsrp=getappdata(hmf,'curindxofsrp');
srptbl(:,5)={false};
srptbl(curindxofsrp,5)={true};
setappdata(hmf,'srptbl',srptbl);
delete(hp2tgt1);

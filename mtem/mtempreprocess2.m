function mtempreprocess(imps)
% version 1.2.2
% date: 20160519
% author: Ainray
% bug-report: wwzhang0421@163.com
% Introduction: MTEM preprossor, now mainly for deconvolution
% Syntax:   mtempreprocess;             % Frem scratch
%           mtempreprocess(imps);       % have 
            
% current version not support multiple freqenies
% EIR :earth impulse response

% global variables:
%-------------------------------------------------------------------------------------------
%       oldsrcpath, save last source path
%       oldrcvpath, save last receive path
%          srcpath, buffer last ten path for source data
%          rcvpath, buffer last ten path for receiver data
%           srptbl, src-rcv pair tables
%  issrptblupdated, src-rcv pair table updated or not
%            srcsn, source receiver number
%            srcch, source channels or source position
%         numofsrp, number of s-r pairs
%     curindxofsrp, current s-r pair index
%   indxofselected, indices of selected s-r pairs
%     curindxofbuf, current index of buf
%              buf, buffer of time series
%            buf.x, buffer for x
%            buf.y, buffer for y
% buf.crossspectra, buffer for cross spectra
%      buf.spectra, buffer for spectra
%          buf.xph, buffer for x phase
%          buf.yph, buffer for y phase
%   iscrossspectra, is crossspectra updated
%        isspectra, is spectra updated
% function list
% ------------------------------------------------------------------------------------------
%   [flag,handle]=existtag(tag);    check whether 'tag' exist or not
%                 mkfs;             make local file system
%       initialization;             initialization of global variables and status
%
%====================================create main figure=====================================
 
if  ~existtag('impmf1')  %check whether it exists or not     
    % main figure
    hmf=figure('Name','MTEM Preprocessor','NumberTitle','off','Tag','impmf1','position',[100,100,800,600],...
        'windowstyle','normal','ToolBar','none','MenuBar','none','CloseRequestFcn',@closehmf);
    set(hmf,'Unit','normalized','Position',[0.1,0.1,0.8,0.7]);    
    
    % global status & vars   
    initialization(hmf);
    
    % file system
    if ~mkfs(hmf)
        return;
    end
  
    % menulayout
    impmenu(hmf); 

else
    msgbox(sprintf('There already exist an instance.')); 
end

% ===================================menu layout==========================
%menus
function impmenu(hmf)
    %File/1  Eidt/2   Setup/3  deconvolution/4  impulse/5  EIR analysis/6 PLot/7
    menuno=[1:2,5,4,6,7,3];  
    hmffile=uimenu(hmf,'Label','&File','HandleVisibility','off');
    hmfmenu( menuno(1),1)=hmffile;
    
    %Edit/2
    hmfedit=uimenu(hmf,'Label','&Edit','HandleVisibility','off');
    hmfmenu(menuno(2),1)=hmfedit;
    hmfmenu(menuno(2),2)=uimenu(hmfedit,'Label','&Site Paras','HandleVisibility','off',...
        'CallBack',@(src,evt)siteset(src,evt,hmf));
    hmfmenu(menuno(2),3)=uimenu(hmfedit,'Label','&List src-rcv pair','HandleVisibility','off',...
        'CallBack',@(src,evt)listsrp(src,evt,hmf));
    hmfmenu(menuno(2),4)=uimenu(hmfedit,'Label','&Refresh ','HandleVisibility','off',...
        'CallBack',@(src,evt)refresh(src,evt,hmf));
   
    %Plot/7
    hmfplot=uimenu(hmf,'Label','&Plot','HandleVisibility','off');
    hmfmenu(menuno(7),1)=hmfplot;
    hmfmenu(menuno(7),2)=uimenu(hmfplot,'Label','&Time series','HandleVisibility','off',...
        'CallBack',@(src,evt)tsviewer(src,evt,hmf));
    hmfmenu(menuno(7),32)=uimenu(hmfplot,'Label','&Layout','HandleVisibility','off',...
        'CallBack',@(src,evt)geolayout(src,evt,hmf));
    
    % deconv/4
    hmfdec=uimenu(hmf,'Label','&Deconvolution','HandleVisibility','off','Enable','on');
    hmfmenu(menuno(4),1)=hmfdec;
%     hmfmenu( menuno(4),2)=uimenu(hmfdec,'Label','&Parameter','HandleVisibility','off',...
%         'CallBack',@(src,evt)decsetpara(src,evt,hmf));  %set para
%     hmfmenu( menuno(4),3)=uimenu(hmfdec,'Label','&Load Data','HandleVisibility','off',...
%         'CallBack',@decloaddata);   
%     hmfmenu( menuno(4),4)=uimenu(hmfdec,'Label','Plot Curve','HandleVisibility','off'...
%        );
%    hmfmenu( menuno(4),5)=uimenu(hmfdec,'Label','Cross-corr estimation','HandleVisibility','off',...
%         'CallBack',@deccorr); 
%     hmfmenu( menuno(4),6)=uimenu(hmfdec,'Label','Deconv','HandleVisibility','off',...
%         'CallBack',@decdec);  
    hmfmenu( menuno(4),2)=uimenu(hmfdec,'Label','Deconv in batch','HandleVisibility','off',...
        'CallBack',@(src,evt)deconvbat(src,evt,hmf));
    
    %impulse/5
     hmfimp=uimenu(hmf,'Label','&Impulse','HandleVisibility','off');
     hmfmenu(menuno(5),1)=hmfimp;
     hmfmenu(menuno(5),2)=uimenu(hmfimp,'Label','Load EIRs','HandleVisibility','off',...
        'CallBack',@(src,evt)imploadeir(src,evt,hmf)); 
     hmfmenu(menuno(5),3)=uimenu(hmfimp,'Label','&Peak Up','HandleVisibility','off',...
        'CallBack',@(src,evt)imppeakeir(src,evt,hmf));  %EIR menu  
     
    hmfset=uimenu(hmf,'Label','&Option','HandleVisibility','off');    
     hmfmenu(menuno(3),1)=hmfset;
    hmfmenu(menuno(3),2)=uimenu(hmfset,'Label','&Deconvolution','HandleVisibility','off',...
        'CallBack',@setdecmode,'Tag','hmfsetdec1');
    hmfmenu(menuno(3),3)=uimenu(hmfset,'Label','&Peak up EIR','HandleVisibility','off',...
        'CallBack',@setimpmode,'Tag','hmfsetimp1'); 
     
      
    hmfana=uimenu(hmf,'Label','&Analysis','HandleVisibility','off','Enable','off'); % analysis
    hmfmenu(menuno(6),1)=hmfana;
    hmfmenu(menuno(6),2)=uimenu(hmfana,'Label','&Removedc','HandleVisibility','off','CallBack',@rmdc);
    hmfmenu(menuno(6),3)=uimenu(hmfana,'Label','&Spectrum','HandleVisibility','off','CallBack',@spectrumeir); %spectrum
    hmfmenu(menuno(6),4)=uimenu(hmfana,'Label','&Reverse Phase','HandleVisibility','off','CallBack',@flipudeir); % reverse phase
    hmfmenu(menuno(6),5)=uimenu(hmfana,'Label','&Notcher','HandleVisibility','off','CallBack',@notcherset); %notcher   
    hmfmenu(menuno(6),6)=uimenu(hmfana,'Label','&Fiters','HandleVisibility','off',...
        'CallBack',@mtemfilter);
    hmfmenu(menuno(6),7)=uimenu(hmfana,'Label','&Cross correlation','HandleVisibility','off',...
        'CallBack',@crossspec);
    hmfmenu(menuno(6),8)=uimenu(hmfana,'Label','Plot Correlations','HandleVisibility','off',...
        'CallBack',@decplotcorr);
    hmfmenu(menuno(6),9)=uimenu(hmfana,'Label','50Hz','HandleVisibility','off',...
        'CallBack',@de50Hz);
    

     
    % store handles of menus
    setappdata(hmf,'hmfmenus',hmfmenu);
    setappdata(hmf,'menuno',menuno);
   
% ==================================public functions=====================
function initialization(hmf)
    setappdata(hmf,'srcpath','');
    setappdata(hmf,'rcvpath','');
    setappdata(hmf,'oldsrcpath','');
    setappdata(hmf,'oldrcvpath','');
    setappdata(hmf,'srptbl',cell(0));
    setappdata(hmf,'issrptblupdated',false);
    setappdata(hmf,'srcsn',1351);
    setappdata(hmf,'srcch',0);
    setappdata(hmf,'spacing',40);
    setappdata(hmf,'numofsrp',0); % indicate on s-r pair
    setappdata(hmf,'curindxofsrp',0); 
    setappdata(hmf,'indxofselected',0);
    setappdata(hmf,'curindxofbuf',0);  % indicate no buf
    setappdata(hmf,'isspectra',false);  % sepctra
    setappdata(hmf,'iscrossspectra',false); % iscrossspectra
    setappdata(hmf,'isimp',false); % EIR
    setappdata(hmf,'imptblstr',cell(0)); % a list for view imp
    setappdata(hmf,'imptable',[]); 
    setappdata(hmf,'viewimpmode','cur'); % view imp mode
    setappdata(hmf,'viewimpcurindx',0); % view imp index
    setappdata(hmf,'isimpload',false);
    setappdata(hmf,'hsrptbl',0);    % table of s-r pair
    setappdata(hmf,'impdata',[]);
    setappdata(hmf,'isbat',false);
    buf.x=0;
    buf.y=0;
    buf.xph=1;
    buf.yph=1;
    buf.meta=[];
    buf.spectra=[];
    buf.crossspectra=[];
    buf.imp=[];
    setappdata(hmf,'buf',buf);
    
function status=mkfs(hmf)
status=true;
if ~exist(fullfile(pwd(),'par'),'dir')
    [suc,msg]=mkdir('par');
    if ~suc          
        status=false;
        hw=warndlg(sprintf('%s: %s\nPlease change the current path of Matlab first!',msg(1:end-3),pwd()),'Acess denied','modal');
        uiwait(hw);
        delete(hmf);
        return;
    end
end
% path file :src
pathfname=fullfile(pwd(),'par','mtemsrc.path');
if exist(pathfname,'file')
    srcpath=textread(fullfile(pwd(),'par','mtemsrc.path'),'%s','delimiter','\n','whitespace','');
    if isempty(srcpath)
        srcpath={pwd()};
    else
        srcpathtmp=srcpath; % check effective or not
        cc=0;
        srcpath=cell(0);
        for i=1:numel(srcpathtmp)
            if exist(srcpathtmp{i},'dir')
                cc=cc+1;
                srcpath(cc)=srcpathtmp(i);
            end
        end
        if isempty(srcpath)
            srcpath={pwd()};
        end
    end
else
        srcpath={pwd()};
end
setappdata(hmf,'srcpath',srcpath);
setappdata(hmf,'oldsrcpath','');

% path file :rcv
pathfname=fullfile(pwd(),'par','mtemrcv.path');
if exist(pathfname,'file')
     rcvpath=textread(fullfile(pwd(),'par','mtemrcv.path'),'%s','delimiter','\n','whitespace','');
     if isempty(rcvpath)
            rcvpath={pwd()};
     else
      rcvpathtmp=rcvpath; % check effective or not
        cc=0;
        rcvpath=cell(0);
        for i=1:numel(rcvpathtmp)
            if exist(rcvpathtmp{i},'dir')
                cc=cc+1;
                rcvpath(cc)=rcvpathtmp(i);
            end
        end
        if isempty(rcvpath)
            rcvpath={pwd()};
        end
     end
else
     rcvpath={pwd()};
end
setappdata(hmf,'rcvpath',rcvpath);  
setappdata(hmf,'oldrcvpath','');


function [flag,handle]=existtag(tag)
   handle=findobj('Tag',tag);
   if isempty(handle)  
       flag=false;
   else
       flag=true;
   end
   
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

% ==================================callbacks============================
% edit menu
function siteset(~,~,hmf)
hd=dialog('Name','Setting source & receiver parameters','Resize','off','DockControls','on',...
    'CloseRequestFcn',@(src,evt)closesitesetdlg(src,evt,hmf),'units','normalized','Position',[0.2,0.1,0.5,0.5]);   
srcpath=getappdata(hmf,'srcpath');
rcvpath=getappdata(hmf,'rcvpath');
% list last dirs
hrcvdir=uicontrol(hd,'Style','popup','Tag',' hrcvdir1','string',strjoin(rcvpath,'|'),...
        'Units','normalized','Position',[0.15,0.4,0.6,0.12],'callback',@(src,evt)listrcvdir(src,evt,hmf));

hrcvcheck=uicontrol(hd,'Style','checkbox','Tag','hrcvcheck1',...
     'units','normalized','position',[0.77,0.445,0.15,0.1],'string','Same with source',...
     'callback',@(src,evt)rcvcheckset(src,evt,hrcvdir,hmf));
 
hsrcdir=uicontrol(hd,'Style','popup','Tag',' hsrcdir1','string',strjoin(srcpath,'|'),...
        'Units','normalized','Position',[0.15,0.6,0.6,0.12],'callback',...
        @(src,evt)listsrcdir(src,evt,hrcvcheck,hrcvdir,hmf));
%         {@listsrcdir,hrcvcheck,hrcvdir});

% src dir brower
x=imread('browersrc.png');
I2=imresize(x,[42,113]);
uicontrol(hd,'Style','push','Tag','hsrcdirtext1',...
    'units','normalized','position',[0.05,0.65,0.08,0.1],'cdata',I2,...
    'tooltipstring','Source data directory','callback',@(src,evt)setsrcdir(src,evt,hsrcdir,hmf)); 
x=imread('browerrcv.png');
I2=imresize(x,[42,113]);
uicontrol(hd,'Style','push','Tag','hrcvdirtext1',...
    'units','normalized','position',[0.05,0.45,0.08,0.1],'cdata',I2,...
    'tooltipstring','Receive data directory','callback',@(src,evt)setrcvdir(src,evt,hrcvdir,hmf));



uicontrol(hd,'style','text','Tag','hsrcsntext1',...
    'units','normalized','position',[0.1,0.22,0.25,0.1],'BackgroundColor',get(hd,'Color'),...
    'string','Source Serial Number');
uicontrol(hd,'style','edit','Tag','hsrcsn1','units','normalized','position',...
[0.38,0.28,0.1,0.05],'string','1351','callback',@(src,evt)srcsnset(src,evt,hmf));

uicontrol(hd,'style','text','Tag','hsrcchtext1',...
    'units','normalized','position',[0.5,0.22,0.25,0.1],'BackgroundColor',get(hd,'Color'),...
    'string','Source channel Number');
uicontrol(hd,'style','edit','Tag','hsrcch1','units','normalized','position',...
[0.78,0.28,0.1,0.05],'string','0','callback',@(src,evt)srcchset(src,evt,hmf));

uicontrol(hd,'style','text',...
    'units','normalized','position',[0.1,0.12,0.25,0.1],'BackgroundColor',get(hd,'Color'),...
    'string','Spacing');
uicontrol(hd,'style','edit','units','normalized','position',...
[0.38,0.18,0.1,0.05],'string','40','callback',@(src,evt)spacingset(src,evt,hmf));


function setsrcdir(~,~,x,hmf)
srcpath=getappdata(hmf,'srcpath');
dirname=uigetdir();
if ~isequal(dirname,0)
    srcpath=updatesrdir(srcpath,dirname);
    set(x,'string',strjoin(srcpath,'|'),'value',1);
    setappdata(hmf,'srcpath',srcpath);
end

function setrcvdir(~,~,x,hmf)
rcvpath=getappdata(hmf,'rcvpath');
dirname=uigetdir();
if ~isequal(dirname,0)
    rcvpath=updatesrdir(rcvpath,dirname);
    set(x,'string',strjoin(rcvpath,'|'),'value',1);
    setappdata(hmf,'rcvpath',rcvpath);
end

 function listsrcdir(src,~,x1,x2,hmf)
% update dirs
srcpath=getappdata(hmf,'srcpath');
dirval=get(src,'Value');
srcpath([1,dirval])=srcpath([dirval,1]);
set(src,'string',strjoin(srcpath,'|'),'value',1);
setappdata(hmf,'srcpath',srcpath);   
rcvpath=getappdata(hmf,'rcvpath');
if get(x1,'value') && ~strcmpi(rcvpath{1},srcpath{1})
    rcvpath=updatesrdir(rcvpath,srcpath{1});
    setappdata(hmf,'rcvpath',rcvpath);
    set(x2,'string',strjoin(rcvpath,'|'),'value',1);
end

function listrcvdir(src,~,hmf)
% update dirs
rcvpath=getappdata(hmf,'rcvpath');
dirval=get(src,'Value');
rcvpath([1,dirval])=rcvpath([dirval,1]);
set(src,'string',strjoin(rcvpath,'|'),'value',1);
setappdata(hmf,'rcvpath',rcvpath);

function srcsnset(src,~,hmf)
srcsn=str2double(get(src,'string'));
if isempty(srcsn)
    warndlg('Input must be a digit');
else
    setappdata(hmf,'srcsn',srcsn)
end

function srcchset(src,~,hmf)
srcch=str2double(get(src,'string'));
if isempty(srcch)
    warndlg('Input must be a digit');
else
    setappdata(hmf,'srcch',srcch)
end

function spacingset(src,~, hmf)
srcch=str2double(get(src,'string'));
if isempty(srcch)
    warndlg('Input must be a digit');
else
    setappdata(hmf,'spacing',srcch)
end

function rcvcheckset(src,~,x,hmf)
rcvpath=getappdata(hmf,'rcvpath');
srcpath=getappdata(hmf,'srcpath');
if get(src,'value') && ~strcmpi(rcvpath{1},srcpath{1})
    rcvpath=updatesrdir(rcvpath,srcpath{1});
    setappdata(hmf,'rcvpath',rcvpath);
    set(x,'string',strjoin(rcvpath,'|'),'value',1);
end

function srpath=updatesrdir(srpath,dirname)
N=numel(srpath);
id=strfindindx(srpath,dirname,1);
if isempty(id)% add new items
    srpath(2:min(N+1,10))=srpath(1:min(N,9));
    srpath(1)={dirname};
else
     srpath([1,id])=srpath([id,1]);
end

function closesitesetdlg(src,~,hmf)
delete(src); 
srcpath=getappdata(hmf,'srcpath');
rcvpath=getappdata(hmf,'rcvpath');
oldsrcpath=getappdata(hmf,'oldsrcpath');
oldrcvpath=getappdata(hmf,'oldrcvpath');
if ~strcmpi(oldsrcpath,srcpath{1}) || ~strcmpi(oldrcvpath,rcvpath{1}) % changed
    setappdata(hmf,'oldsrcpath',srcpath{1});   % update
    setappdata(hmf,'oldrcvpath',rcvpath{1});
   if strcmpi(srcpath{1},rcvpath{1})
        D=dir(srcpath{1});
        fnamelist=v2col({D.name});
        i=strfindindx(fnamelist,'.dat');
        ffnamelist=fnamelist(i);
        dirlist=repmat(srcpath(1),numel(ffnamelist),1);
   else
        DS=dir(srcpath{1});
        fnamelist=v2col({DS.name});
        i=strfindindx(fnamelist,'.dat');
        ffnamelist=fnamelist(i);
        dirlist=repmat(srcpath(1),numel(ffnamelist),1);
        N=numel(ffnamelist);
        DR=dir(rcvpath{1});
        fnamelist=v2col({DR.name});
        i=strfindindx(fnamelist,'.dat');
        ffnamelist(N+1:N+numel(i))=fnamelist(i);
        dirlist(N+1:N+numel(i))=repmat(rcvpath(1),numel(i),1);
   end
   ffnamelist=fullfile(dirlist,ffnamelist);
   srptbl=srmatch(ffnamelist,getappdata(hmf,'srcsn'),getappdata(hmf,'srcch'));
   if isempty(srptbl)
        msgbox(sprintf('No valid data directories.'));
        return;
   end
   N=size(srptbl,1);
   setappdata(hmf,'srptbl',srptbl);
   setappdata(hmf,'issrptblupdated',true);
   setappdata(hmf,'numofsrp',N);
   if getappdata(hmf,'curindxofsrp')>N
       setappdata(hmf,'curindxofsrp',N);
   end
end
if getappdata(hmf,'issrptblupdated')
    flistsrp(hmf);
    setappdata(hmf,'issrptblupdated',false);
end
% have s-r pair, no buf
if getappdata(hmf,'numofsrp')>0  && getappdata(hmf,'curindxofbuf')==0
    setappdata(hmf,'curindxofbuf',1);
    updatebuf(1,hmf);
end

function listsrp(~,~,hmf)
flistsrp(hmf);

function flistsrp(hmf)
srptbl=getappdata(hmf,'srptbl');
hsrptbl=getappdata(hmf,'hsrptbl');
if exist('hsrptbl','var') && ~isequal(hsrptbl,0)
    delete(hsrptbl);   
end
% set menu
% if getappdata(hmf,'issrptablupdated',false);
if ~isempty(srptbl)
    c=uicontextmenu(hmf);
    hsrptbl=uitable(hmf,'data',srptbl(:,[5,1:3]),'units','normalized',...
               'position',[0.02,0.1,0.38,0.85],'Tag','hsrptbl1',...
               'columnwidth',{55,65,150,150},'Selected','off','SelectionHighlight','off',...
           'columnname',{'Select','Record No','Source','Receiver'},...
            'columneditable',[true,false,false,false],...
            'uicontextmenu',c,'CellEditCallback',@(src,evt)selectrow(src,evt,hmf));
            m1=uimenu(c,'Label','Select &All','CallBack',@(src,evt)selectsr(src,evt,hsrptbl,hmf));
            m2=uimenu(c,'Label','Select &None','CallBack',@(src,evt)selectsr(src,evt,hsrptbl,hmf));
            m3=uimenu(c,'Label','&Reverse Selection','CallBack',@(src,evt)selectsr(src,evt,hsrptbl,hmf));
    %       ,'RowStriping','on','backgroundcolor',[0.8,0.9,0.2;0.2,0.9,0.8]...
    setappdata(hmf,'hsrptbl',hsrptbl);
else
    warndlg('Please first set the path');
end

function selectrow(src,evt,hmf)
% src.Data(evt.Indices(1),1)={~src.Data{evt.Indices(1),1}};
nx=find(cellfun(@(y) y,src.Data(:,1)));
if ~isempty(nx)
    setappdata(hmf,'curindxofsrp',nx(1)); 
    setappdata(hmf,'indxofselected',nx);
else
    setappdata(hmf,'curindxofsrp',0);      
end

function selectsr(src,~,x,hmf)
switch src.Label
    case 'Select &All'
        x.Data(:,1)={true};
        nx=find(cellfun(@(y) y,x.Data(:,1)));
        if ~isempty(nx)
            setappdata(hmf,'curindxofsrp',nx(1));
            setappdata(hmf,'indxofselected',nx);
        else
            setappdata(hmf,'curindxofsrp',0);
        end
    case 'Select &None'
        x.Data(:,1)={false};
        nx=find(cellfun(@(y) y,x.Data(:,1)));
        if ~isempty(nx)
            setappdata(hmf,'curindxofsrp',nx(1));
            setappdata(hmf,'indxofselected',nx);
        else
            setappdata(hmf,'curindxofsrp',0);
        end
    case '&Reverse Selection'
        x.Data(:,1)=cellfun(@(y) {~y},x.Data(:,1));
         nx=find(cellfun(@(y) y,x.Data(:,1)));
        if ~isempty(nx)
            setappdata(hmf,'curindxofsrp',nx(1));
            setappdata(hmf,'indxofselected',nx);
        else
            setappdata(hmf,'curindxofsrp',0);
        end
end

function refresh(~,~,hmf)
clf(hmf);
setappdata(hmf,'curindxofsrp',0);

function tsviewer(~,~,hmf)       
curindxofsrp=getappdata(hmf,'curindxofsrp');
curindxofbuf=getappdata(hmf,'curindxofbuf');
if getappdata(hmf,'numofsrp')==0
    warndlg('No data. Please first set the data path');
    return;
end
if curindxofsrp==0 || numel(getappdata(hmf,'indxofselected'))>1
   warndlg('Please select only one s-r pair');
   return;
end
srptbl=getappdata(hmf,'srptbl');
if curindxofbuf~=curindxofsrp  % new buf 
     updatebuf(curindxofsrp,hmf);
end
buf=getappdata(hmf,'buf');
htsv=viewdata(hmf,buf,{sprintf('S: %s.dat/%dm, R: %s.dat/%dm, F: %dHz, N: %d',...
    srptbl{curindxofbuf,2},buf.meta.srcpos,srptbl{curindxofbuf,3},...
    buf.meta.rcvpos, buf.meta.code(2),buf.meta.code(1)),[],'Current (A)','Voltage (V)'},...
    true,false);% time series viewer
uiwait(htsv);
flistsrp(hmf);

% dec menu --------------------------------

function deconvbat(src,evt,hmf)
if getappdata(hmf,'isbat')
    ync=questdlg('The EIR resuls will be overwrided, are you sure to Continue?','Warning: Exit',...
    'Yes','No','No');
    switch ync
        case 'Yes'
            setappdata(hmf,'impdata',[]);
        case 'No'
            return;
    end
end
 indxofselected=getappdata(hmf,'indxofselected');
 N=numel(indxofselected);
 if isequal(indxofselected,0)
     warndlg('No data selected');
     return;
 end
 buf=getappdata(hmf,'buf');
 answer=inputdlg({'Number of crosspower','Skip','Length of Cross','Prewhiten Noise'...
     ,'Length of EIR'}, 'Cross spectra parameter',[1,50],...  
     {num2str(min(20,floor(buf.meta.code(3)/3))),'1',num2str(floor(buf.meta.npp*0.6/320)*320),'0.01','3200'});

if isempty(answer)
     return;
end
   
number=str2double(answer{1});
skip=str2double(answer{2});
len=str2double(answer{3});
prenoise=str2double(answer{4}); 
eirlen=str2double(answer{5});
 
% write log file    
fid_log=fopen('mtemdeconv.log','a');
time.day=date;time.h=hour(now);time.m=minute(now);time.s=second(now);
fprintf(fid_log,'%s %d:%d:%2.0f\n',time.day,time.h,time.m,time.s);
% calculating looply
hw = waitbar(0,'Please wait...');
tic;    
for i=1:N
    cc=indxofselected(i);
    updatebuf(cc,hmf);
    setappdata(hmf,'curindxofsrp',cc);
    crossdeconv(hmf,number,skip,len,eirlen,prenoise);
    buf=getappdata(hmf,'buf');
    impout=buf.imp;
    waitbar(i/N,hw,...
    sprintf('processing (%d/%d,%d,%d,%d,%d,%d,%d,%d,%d)\n',i,N,impout.meta.recnum,...
    impout.meta.srcpos,impout.meta.rcvpos,impout.meta.code(1),impout.meta.code(2),...
              impout.meta.code(3),impout.meta.rcvsn,impout.meta.rcvch));    
    fprintf(fid_log,'processing (%d/%d,%d,%d,%d,%d,%d,%d,%d,%d)\n',i,N,impout.meta.recnum,...
    impout.meta.srcpos,impout.meta.rcvpos,impout.meta.code(1),impout.meta.code(2),...
              impout.meta.code(3),impout.meta.rcvsn,impout.meta.rcvch);
end

delete(hw);
imps=getappdata(hmf,'impdata');
imps=sortimp(imps);   % sort 
fname=saveimp(imps);       % save EIR
msgbox(sprintf('Save mat file: %s. Cost time (sec): %f',fname,toc));

%write log file
time.day=date;time.h=hour(now);time.m=minute(now);time.s=second(now);
fprintf(fid_log,'\n%s %d:%d:%2.0f calculating points:%d\n',time.day,time.h,time.m,time.s,i);
fprintf(fid_log,'Dada are saveed in %s.mat\n', fname);
fprintf(fid_log,'Parameter:\n');
fprintf(fid_log,sprintf(['Number of crosspower: %d ','Skip: %d ','Length of Cross: %d ',...
    'Length of EIR: %d ','Prewhiten Noise: %f\n'],number,skip,len,eirlen,prenoise));
fprintf(fid_log,'--------------------------------------------------------\n');
fclose(fid_log);

setappdata(hmf,'isbat',true);
  
    
function crossdeconv(hmf,number,skip,len,eirlen,prenoise)
buf=getappdata(hmf,'buf');
% N=max(numel(buf.x),numel(buf.y));
start=floor(skip*buf.meta.ncpp*buf.meta.fs/buf.meta.code(2))+1; % skip number of sample
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

crossspectra.r=r;
crossspectra.b=b;

crossspectra.skip=skip;
crossspectra.number=number;
crossspectra.nps= nps;
buf.crossspectra=crossspectra;

imp=initialimp;
imp.meta=buf.meta;
imp.para.length=eirlen;

% imp.g=levidurb(buf.crossspectra.r(1:eirlen),buf.crossspectra.b(1:eirlen),prenoise);
tmp=sub50hz(b,(3201:length(b)));
imp.g=inversephase(tmp(1:eirlen));
imp.mask=1;     % assuming effective data
imp.bg=imp.g;       % EIR backup
imp.ng=imp.g;
imp.r=buf.crossspectra.r;
imp.b=buf.crossspectra.b;
imp.ts=time_vector(imp.g,imp.meta.fs); % time abscissa
imp=peakimp(imp);
buf.imp=imp;

setappdata(hmf,'buf',buf); % cache the last one
setappdata(hmf,'iscrossspectra',true);
setappdata(hmf,'isimp',true);
imps=getappdata(hmf,'impdata');
imps=[imps;imp];

setappdata(hmf,'impdata',imps);
setappdata(hmf,'isimpload',true);
 
 
% impulse menu-----------------------------  
function imploadeir(src,evt,hmf) % loadeir
    [fnamelist,path] = uigetfile({'*.mat','Matlab data(*.mat)';'*.*','all files (*.*)'},...
        'Load EIR data');
    if fnamelist==0
        return;
    end
    fname=fullfile(path,fnamelist);
    eval(['load ',fname,' -regexp  ''^(impmeta)\w*'''])
    %match the variable
    ismatched=false;
    vars=who; 
    impvars=regexp(vars,'^(impmeta)\w*');
    for i=1:numel(impvars)
        if ~isempty(impvars{i}); % find valide variable
            eval(['imp=',vars{i},';']);
                if ~isempty(getappdata(hmf,'impdata'))
                ycn=questdlg(sprintf(['The EIR data exists in application, which will be overrided.\n'...
               'Are you sure to continue?']),...
                   'Warning: Override variable','Yes','No','Cancel','No');
               switch ycn
                   case 'Yes'
                   	    % load data
                        imps=imp.data;                      
                        setappdata(hmf,'impdata',imps);
                        setappdata(hmf,'isimpload',true);
                    msgbox(sprintf('%s have been loaded',imp.fname));
               end
            else
                        % load data
                imps=imp.data;
                setappdata(hmf,'impdata',imps);   
                setappdata(hmf,'isimpload',true);
                msgbox(sprintf('%s have been loaded',imp.fname));
            end
            ismatched=true;
            break;
        end
        if i==numel(impvars) && ~ismatched  % no matched
            msgbox(sprintf('Invalid data.'));
        end
    end
    
function imppeakeir(src,evt,hmf)  %imppeak
 if getappdata(hmf,'isimpload')
    setappdata(hmf,'viewimpmode','mul');
    imps=getappdata(hmf,'impdata');
    [imptbl,impitems]=listimp(imps);
    setappdata(hmf,'imptable',imptbl); % EIRs list table
    setappdata(hmf,'imptblstr',impitems);
    setappdata(hmf,'viewimpcurindx',1);
    viewimp(hmf,imps); 
 else
     warndlg('No valid data.');
 end
 
% close function
function closehmf(src,evt)
ync=questdlg('Are you sure to exit?','Warning: Exit',...
    'Yes','No','No');
switch ync
    case 'Yes'
        % update the path dir
        if ~exist(fullfile(pwd(),'par'),'dir')
            mkdir('par');
        end
        srcpath=getappdata(src,'srcpath');
        fid=fopen(fullfile(pwd(),'par','mtemsrc.path'),'w');
        fprintf(fid,'%s',strjoin(srcpath,'\n'));

        rcvpath=getappdata(src,'rcvpath');
        fid=fopen(fullfile(pwd(),'par','mtemrcv.path'),'w');
        fprintf(fid,'%s',strjoin(rcvpath,'\n'));
        delete(src);
end

function geolayout(src,evt,hmf)
srptbl=getappdata(hmf,'srptbl');
if ~isempty(srptbl)
    src=cell2mat(srptbl(:,8));
    rcv=cell2mat(srptbl(:,9));
    spacing=getappdata(hmf,'spacing');
    [~,~,mask,mask_offset]=...   
    xy2co(src,rcv,spacing,'custom');
    hf=figure('Name','Data Coverage in CMP-offset coordinate','Resize','on','DockControls','off',...
'units','normalized','ToolBar','figure','MenuBar','none',...
'NumberTitle','off'); 
    geo_plot(mask,mask_offset,[src rcv],spacing);
else
    warndlg('Please first set the path');
end
% notcher menu
function notcherset(src,evt)

    hmf=findobj('Tag','impmf1');  
    switch getappdata(hmf,'mode')
        case 'imp'
            imp=getappdata(hmf,'impdata');
            i=getappdata(hmf,'impcurindex');
            answer=inputdlg({'Sampling Freqency(Hz)','Notch Frequency(Hz)','Notch Numerical Band Width'},...
                'Notch Setting',1,{num2str(imp(i).meta.fs),  ['[',regexprep(num2str(imp(i).para.nfres),'\s*',','),']']...
                ,num2str(imp(i).para.notcherwidth)});
            if ~isempty(answer)
                fs=str2num(answer{1});
                beta=str2num(answer{2});
                yita=str2num(answer{3});
                imp(i).para.nfres=beta;
                imp(i).para.notcherwidth=yita;
                imp(i).ng=drf_notcher(imp(i).g,beta/fs,yita);
                setappdata(hmf,'impdata',imp);
                msgbox('Notch filtering finished');
            end
        case 'dec'
                decbuf=getappdata(hmf,'decdata');
                 hmf=findobj('Tag','impmf1');
                srccheck=findobj('Tag','decplotsrc1');  %src
                issrc=get(srccheck,'Value');
                rcvcheck=findobj('Tag','decplotrcv1'); %rcv
                isrcv=get(rcvcheck,'Value');
                autocheck=findobj('Tag','decplotautocorr1'); %auto
                isauto=get(autocheck,'Value');
                crosscheck=findobj('Tag','decplotcrosscorr1'); %cross
                iscross=get(crosscheck,'Value');
                notchchecksrc=findobj('Tag','decplotnotchersrc1');% notcher src
                isnotchersrc=get(notchchecksrc,'Value');
                notchcheckrcv=findobj('Tag','decplotnotcherrcv1');% notcher rcv
                isnotcherrcv=get(notchcheckrcv,'Value');
         
            answer=inputdlg({'Sampling Freqency(Hz)','Notch Frequency(Hz)','Notch Numerical Band Width'},...
                'Notch Setting',1,{num2str(decbuf(1).imp.meta.fs),  ['[',regexprep(num2str(decbuf(1).imp.para.nfres),'\s*',','),']']...
                ,num2str(decbuf(1).imp.para.notcherwidth)});
            if ~isempty(answer)
                fs=str2num(answer{1});
                beta=str2num(answer{2});
                yita=str2num(answer{3});
                decbuf(1).imp.meta.fs=fs;
                decbuf(1).imp.para.nfres=beta;
                decbuf(1).imp.para.notcherwidth=yita;
                if issrc
                    decbuf(1).nx=drf_notcher(decbuf(1).x,beta/fs,yita);
                end
                if isrcv
                    decbuf(1).ny=drf_notcher(decbuf(1).y,beta/fs,yita);
                end
                if isauto
                  decbuf(1).nr=drf_notcher(decbuf(1).r,beta/fs,yita);
                end
                if iscross
                  decbuf(1).nb=drf_notcher(decbuf(1).b,beta/fs,yita);
                end
                if isnotchersrc
                   decbuf(1).nx=drf_notcher(decbuf(1).nx,beta/fs,yita);
                end
                if isnotcherrcv
                    decbuf(1).ny=drf_notcher(decbuf(1).ny,beta/fs,yita);
                end                 
                setappdata(hmf,'decdata',decbuf);
                msgbox('Notch filtering finished');           
            end
            
    end
            

% notcher button
function notchereir(src,evt)
hmf=findobj('Tag','impmf1');
  switch getappdata(hmf,'mode')
        case 'imp'
            imp=getappdata(hmf,'impdata');
            i=getappdata(hmf,'impcurindex');
            switch get(src,'Value')
                case 1
                  ync=questdlg('Are you sure to swap data.?','Warning:Swap',...
                    'Yes','No','Cancel','No');
                switch ync
                    case 'Yes'
                        tmp=imp(i).g;  % backup
                        imp(i).g=imp(i).ng;
                        imp(i).ng=tmp; 
                        set(src,'String','ReSwap'); 
                        setappdata(hmf,'impdata',imp);  
                end 
                case 0  % reback
                    ync=questdlg('Are you sure to reswap data.?','Warning:Swap',...
                    'Yes','No','Cancel','No');
                switch ync
                    case 'Yes'
                        tmp=imp(i).g;  % backup
                        imp(i).g=imp(i).ng;
                        imp(i).ng=tmp; 
                        set(src,'String','Swap'); 
                        setappdata(hmf,'impdata',imp);    
                end      
            end
      case 'dec'
            decbuf=getappdata(hmf,'decdata');
            srccheck=findobj('Tag','decplotsrc1');  %src
            issrc=get(srccheck,'Value');
            rcvcheck=findobj('Tag','decplotrcv1'); %rcv
            isrcv=get(rcvcheck,'Value');
            switch get(src,'Value')
                case 1
                  ync=questdlg('Are you sure to swap data.?','Warning:Swap',...
                    'Yes','No','Cancel','No');
                switch ync
                    case 'Yes'
                         if issrc
                            tmp=decbuf(1).x;  % backup
                            decbuf(1).x=decbuf(1).nx;
                            decbuf(1).nx=tmp; 
                         end
                         if isrcv
                            tmp=decbuf(1).y;  % backup
                            decbuf(1).y=decbuf(1).ny;
                            decbuf(1).ny=tmp;  
                         end
                        set(src,'String','ReSwap'); 
                        setappdata(hmf,'decdata',decbuf);  
                end 
                case 0  % reback
                   ync=questdlg('Are you sure to reswap data.?','Warning:Swap',...
                    'Yes','No','Cancel','No');
                switch ync
                    case 'Yes'
                        if issrc
                            tmp=decbuf(1).nx;  % backup
                            decbuf(1).nx=decbuf(1).x;
                            decbuf(1).x=tmp; 
                         end
                         if isrcv
                            tmp=decbuf(1).ny;  % backup
                            decbuf(1).ny=decbuf(1).y;
                            decbuf(1).y=tmp;  
                         end
                        set(src,'String','Swap'); 
                        setappdata(hmf,'decdata',decbuf);  
                end      
            end
  end


function mtemfilter(src,evt)
    hmf=findobj('Tag','impmf1');
    
    switch getappdata(hmf,'mode')
        case 'imp'
            imp=getappdata(hmf,'impdata');
            i=getappdata(hmf,'impcurindex');
            button=questdlg('Choose filter type','Filter','lowpass','highpass','bandpass','lowpass');
            switch button
                case 'lowpass'
                    mode='gs';
                    answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
                    'Filter',1,{num2str(imp(i).meta.fs),num2str(imp(i).meta.code(2)*0.7)});
                    if isempty(answer)
                        return;
                    else
                        fs=str2num(answer{1});
                        cf=str2num(answer{2});
                        imp(i).meta.fs=fs;
                        imp(i).ng=winsincfilter(imp(i).g,cf/fs,mode);
                        setappdata(hmf,'impdata',imp);
                     msgbox(sprintf('Filter finished.'));
                    end
                 case 'highpass'
                        mode='bp';
                        answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
                        'Filter',1,{num2str(imp(i).meta.fs),num2str(imp(i).meta.code(2)*0.5)});
                        if isempty(answer)
                            return;
                        else
                            fs=str2num(answer{1});
                            cf=str2num(answer{2});
                            imp(i).meta.fs=fs;
                            imp(i).ng=winsincfilter(imp(i).g,cf/fs,mode);
                        end
                      setappdata(hmf,'impdata',imp);
                     msgbox(sprintf('Filter finished.'));
                case 'bandpass'
                    mode='bp';
                    answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
                    'Filter',1,{num2str(imp(i).meta.fs),['[',regexprep(num2str([imp(i).meta.code(2)/imp(i).meta.ncpp,...
                      imp(i).meta.code(2)*0.5]),'\s*',','),']']});
                    if isempty(answer)
                        return;
                    else
                        fs=str2num(answer{1});
                        cf=str2num(answer{2});
                        imp(i).meta.fs=fs;
                        imp(i).ng=winsincfilter(imp(i).g,cf/fs,mode);
                    end
                     setappdata(hmf,'impdata',imp);
                     msgbox(sprintf('Filter finished.'));
                otherwise
            end
            
        case 'dec'
            srccheck=findobj('Tag','decplotsrc1');  %src
            hd(1)=srccheck;
            issrc=get(srccheck,'Value');
            rcvcheck=findobj('Tag','decplotrcv1'); %rcv
            hd(2)=rcvcheck;
            isrcv=get(rcvcheck,'Value');
            autocheck=findobj('Tag','decplotautocorr1'); %auto
            hd(6)=autocheck;
            isauto=get(autocheck,'Value');
            crosscheck=findobj('Tag','decplotcrosscorr1'); %cross
            hd(7)=crosscheck;
            iscross=get(crosscheck,'Value');
            notchchecksrc=findobj('Tag','decplotnotchersrc1');% notcher src
            hd(3)=notchchecksrc;
            isnotchersrc=get(notchchecksrc,'Value');
            notchcheckrcv=findobj('Tag','decplotnotcherrcv1');% notcher rcv
            hd(4)=notchcheckrcv;
            isnotcherrcv=get(notchcheckrcv,'Value');
            decbuf=getappdata(hmf,'decdata');
            button=questdlg('Choose filter type','Filter','lowpass','highpass','bandpass','lowpass');
            switch button
                case 'lowpass'
                    mode='gs';
                    answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
                    'Filter',1,{num2str(decbuf(1).imp.meta.fs),num2str(decbuf(1).imp.meta.code(2)*0.7)});
                    if isempty(answer)
                        return;
                    else
                        fs=str2num(answer{1});
                        cf=str2num(answer{2});
                        decbuf(1).imp.meta.fs=fs;
                        if issrc
                            decbuf(1).nx=winsincfilter(decbuf(1).x,cf/fs,mode);
                        end
                        if isrcv
                            decbuf(1).ny=winsincfilter(decbuf(1).y,cf/fs,mode);
                        end
                        if isnotchersrc
                            decbuf(1).nx=winsincfilter(decful(1).nx,cf/fs,mode);
                        end
                        if isnotcherrcv
                            decbuf(1).ny=winsincfilter(decful(1).ny,cf/fs,mode);
                        end
                        if isauto
                            decbuf(1).nr=winsincfilter(decbuf(1).r,cf/fs,mode);
                        end
                        if iscross
                            decbuf(1).nb=winsincfilter(decbuf(1).b,cf/fs,mode);
                        end
                    end
                case 'highpass'
                    mode='hp';
                    answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
                        'Filter',1,{num2str(decbuf(1).imp.meta.fs),num2str(decbuf(1).imp.meta.code(2)*0.5)});
                    if isempty(answer)
                        return;
                    else
                        fs=str2num(answer{1});
                        cf=str2num(answer{2});
                        decbuf(1).imp.meta.fs=fs;
                        if issrc
                            decbuf(1).nx=winsincfilter(decbuf(1).x,cf/fs,mode);
                        end
                        if isrcv
                            decbuf(1).ny=winsincfilter(decbuf(1).y,cf/fs,mode);
                        end
                         if isnotchersrc
                            decbuf(1).nx=winsincfilter(decful(1).nx,cf/fs,mode);
                        end
                        if isnotcherrcv
                            decbuf(1).ny=winsincfilter(decful(1).ny,cf/fs,mode);
                        end
                        if isauto
                            decbuf(1).nr=winsincfilter(decbuf(1).r,cf/fs,mode);
                        end
                        if iscross
                            decbuf(1).nb=winsincfilter(decbuf(1).b,cf/fs,mode);
                        end
                    end                           
            case 'bandpass'
                    mode='bp';
                    answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},'Filter',1,...
                    {num2str(decbuf(1).imp.meta.fs),...
                      ['[',regexprep(num2str([decbuf(1).imp.meta.code(2)/decbuf(1).imp.meta.ncpp,...
                      decbuf(1).imp.meta.code(2)*0.5]),'\s*',','),']']});
                    if isempty(answer)
                        return;
                    else
                        fs=str2num(answer{1});
                        cf=str2num(answer{2});
                        decbuf(1).imp.meta.fs=fs;
                        if issrc
                            decbuf(1).nx=winsincfilter(decbuf(1).x,cf/fs,mode);
                        end
                        if isrcv
                            decbuf(1).ny=winsincfilter(decbuf(1).y,cf/fs,mode);
                        end
                        if isnotchersrc
                            decbuf(1).nx=winsincfilter(decful(1).nx,cf/fs,mode);
                        end
                        if isnotcherrcv
                            decbuf(1).ny=winsincfilter(decful(1).ny,cf/fs,mode);
                        end
                        if isauto
                            decbuf(1).nr=winsincfilter(decbuf(1).r,cf/fs,mode);
                        end
                        if iscross
                            decbuf(1).nb=winsincfilter(decbuf(1).b,cf/fs,mode);
                        end
                    end           
            end
            setappdata(hmf,'decdata',decbuf);
            msgbox(sprintf('Filter finished.'));
    end
function de50Hz(src,evt)
hmf=findobj('Tag','impmf1');   
if strcmpi(getappdata(hmf,'mode'), 'imp')
        imp=getappdata(hmf,'impdata');
        i=getappdata(hmf,'impcurindex');
        srt=listimp(imp);
        indx=[];
        indx=find(srt(1:i,2)==srt(i,2));
%         for jj=1:length(indx)
%             j=i+1-jj;
%             imp(j).g=imp(j).bg;
%             imp(j).g=sub50hz(imp(j).g,[6401:16000]);
%             imp(j).g=drf_notcher(imp(j).g,50/imp(j).meta.fs,1.01);
%             imp(j).g=winsincfilter(imp(j).g,imp(j).meta.code(2)*0.7/imp(j).meta.fs,'Mode','gs');
%             
%             
%             imp(j).g=inversephase(imp(j).g);
%             imp(j)=peakimp(imp(j));
%         end
%          setappdata(hmf,'impdata',imp);
%          msgbox(sprintf('50 Hz is removed'));
        answer=inputdlg({'Range'},'Remove 50 Hz',[1,100],...
             {['[',regexprep(num2str([6401,16000]),'\s*',':'),']']});
        if isempty(answer{1})
             return;
        else
            imp(i).ng=sub50hz(imp(i).g,str2num(answer{1})); 
            setappdata(hmf,'impdata',imp);
            msgbox(sprintf('50 Hz is removed'))
        end
       
end  
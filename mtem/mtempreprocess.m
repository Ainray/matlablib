
function mtempreprocess(imps)
% version 1.3
% date: 20160519, 20170614, 20180327
% author: Ainray
% bug-report: wwzhang0421@163.com
% Introduction: MTEM preprossor, now mainly for deconvolution
%
% Syntax:   mtempreprocess;             % from scratch
%           mtempreprocess(imps);       % have EIR data
%            
% current version not support multiple freqenies
% EIR :earth impulse response

% global variables:
%-------------------------------------------------------------------------------------------
%           oldsdc,     save last source path
%           oldrdc,     save last receive path
%              sdc,     buffer last ten path for source data
%              rdc,     buffer last ten path for receiver data
%              srt,     src-rcv pair tables
%                       the source-receiver pair table N*8 cell
%     -----------------------------------------------------------------------------
%            col.1           col.2               col.3               col. 4                
%        record number   source file name    receiver file name     short source name     
%    -----------------------------------------------------------------------------
%    -----------------------------------------------------------------------------
%           col.5           col.6               col.7               col. 8                
%       short rcv fname   logical flags    receiver serial number   frequencies     
%    -----------------------------------------------------------------------------
%     isrtupdated,     src-rcv pair table updated or not
%              ssn,     source serial number
%              scn,     source channels or source position
%            rcvsn,     receiver serial no. list
%              rec,     record number
%        numofssrt,     number of s-r pairs
%    curindxofsrt,     current s-r pair index
%   indxofselected,     indices of selected s-r pairs
%     curindxofbuf,     current index of buf
%              buf,     buffer of time series
%            buf.x,     buffer for x
%            buf.y,     buffer for y
% buf.crossspectra,     buffer for cross spectra
%      buf.spectra,     buffer for spectra
%          buf.xph,     buffer for x phase
%          buf.yph,     buffer for y phase
%   iscrossspectra,     is crossspectra updated
%        isspectra,     is spectra updated
%     p2tgt1p1sp1isrmdc,     is dc removed or not
% function list
% ------------------------------------------------------------------------------------------
%   [flag,handle]=existtag(tag);    check whether 'tag' exist or not
%                 mkfs;             make local file system
%       initialization;             initialization of global variables and status
%
%====================================create main figure=====================================
 
if  ~existtag('impmf1')  %check whether it exists or not
    if verLessThan('matlab','9.2.0')
        msgbox(sprintf('Version 9.2.0 and later are recommend')); 
    end
    % main figure
    set(0,'units','pixels');
    srcsz=get(0,'ScreenSize');
    hmf=figure('Name','MTEM Preprocessor','NumberTitle','off','Tag','impmf1',...
        'windowstyle','normal','ToolBar','none','MenuBar','none',...
        'OuterPosition',[srcsz(3)*0.1,srcsz(4)*0.01,srcsz(3)*0.9,srcsz(4)*0.9],...
        'SizeChangedFcn',@matchpanel,'CloseRequestFcn',@hmf_close);
      %  'Unit','normalized','Position',[0.1,0.05,0.8,0.8],...    
     % file system
     if ~mkfs(hmf)
        return;
     end
     % global status & vars
     initialization(hmf);   
     inithmflayout(hmf);
  
else
    msgbox(sprintf('There already exist an instance.')); 
end

function initialization(hmf)
    % global vars
    ssn=1351;    % source meter
    scn=0;       % source channel number
    spc=0;       % spacing between adjoint sounding points
    ssrtnpp=100; % number of s-r-pair per table page 
    ssrtnp=1;    % number of pages
    ssrtcp=1;    % current page
    
    setappdata(hmf,'ssn',ssn);
    setappdata(hmf,'scn',scn);
    setappdata(hmf,'spc',spc);
    
    % gobal indicators 
    setappdata(hmf,'rcvsnindex',1);             % meter serial number index
    setappdata(hmf,'recindex',1);               % record index
    setappdata(hmf,'freindex',1);                % frequency index
    
    % set the path 
    [sdc,rdc]=dirread();
    setappdata(hmf,'sdc',sdc);
    setappdata(hmf,'rdc',rdc);
    if isempty(sdc)
        sdc=cd;
    end
    if isempty(rdc)
        rdc=sdc;
    end
    fname=listdata(sdc{1},rdc{1});
    setappdata(hmf,'fname',fname);  
    dataupdate(hmf,fname);
    
    setappdata(hmf,'curindxofbuf',0);  % indicate no buf
    setappdata(hmf,'isspectra',false);  % sepctra
    setappdata(hmf,'iscrossspectra',false); % iscrossspectra
    setappdata(hmf,'isimp',false); % EIR
    setappdata(hmf,'imptblstr',cell(0)); % a list for view imp
    setappdata(hmf,'imptable',[]); 
    setappdata(hmf,'viewimpmode','cur'); % view imp mode
    setappdata(hmf,'viewimpcurindx',0); % view imp index
    setappdata(hmf,'isimpload',false);
    
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

    % tsview
    setappdata(hmf,'p2tgt1p1sp1crossspectra',buf.crossspectra)
    setappdata(hmf,'p2tgt1p1sp1iscrossspectra',true)
    setappdata(hmf,'p2tgt1p1sp1ph',[buf.xph buf.yph])
    setappdata(hmf,'p2tgt1p1sp1isrmdc',false);
    setappdata(hmf,'p2tgt1p1sp1xtickfs',16000)
    setappdata(hmf,'p2tgt1p1sp1isdual',true)

function inithmflayout(hmf)
    % panel 1, data navigation, 3 subpannels:
    % hp1, handle of pannel 1
    hp1=uipanel('Parent',hmf,'HandleVisibility','off');
    setappdata(hmf,'hp1',hp1);  
    
    % sub panel 3, data list 
    hp1sp3=uipanel('Parent',hp1,'Title','Data List','HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp1sp3',hp1sp3);
     
    numofssrt=getappdata(hmf,'numofssrt');
     hp1sp3srtedit=uicontrol(hp1sp3,'style','push','String',string(numofssrt),'fontsize',10);
       %@(src,evt)p1sp3srtedit_set(src,evt,hmf));
    setappdata(hmf,'hp1sp3srtedit',hp1sp3srtedit);
    % context menu and table to manipulate data list
    hp1sp3cm=uicontextmenu(hmf);
    srt=getappdata(hmf,'srt');
    hp1sp3srt=uitable(hmf,'Tag','hp1sp3srt1',...
              'Selected','off','SelectionHighlight','off',...
              'fontsize',10,'HandleVisibility','off',...
           'columnname',{'Select','Record','Source','Receiver'},...
           'columneditable',[true,false,false,false],...
           'uicontextmenu',hp1sp3cm,'CellEditCallback',@(src,evt)p1sp3srt_selectrow(src,evt,hmf));
    uimenu(hp1sp3cm,'Label','Select &All','CallBack',@(src,evt)hp1sp3cm_selectsr(src,evt,hp1sp3srt,hmf));
    uimenu(hp1sp3cm,'Label','Select &None','CallBack',@(src,evt)hp1sp3cm_selectsr(src,evt,hp1sp3srt,hmf));
    uimenu(hp1sp3cm,'Label','&Reverse Selection','CallBack',@(src,evt)hp1sp3cm_selectsr(src,evt,hp1sp3srt,hmf));

    if ~isempty(srt)
       set(hp1sp3srt,'data',srt(:,[6,1,4,5]));
    end
    setappdata(hmf,'hp1sp3srt',hp1sp3srt);

    %subpannel 2, screen data by f/r/s/spacing and other parameters
    hp1sp2=uipanel('Parent',hp1,'Title','Screen data','HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp1sp2',hp1sp2);
   
    % spacing subpanel 2: 6
    spc=getappdata(hmf,'spc');  
    hp1sp2spc=uicontrol(hp1sp2,'Style','edit','Tag','hp1sp2spc1','string',num2str(spc),...
    'callback',@(src,evt)p1sp2spc_set(src,evt,hmf),'fontsize',8,'fontweight','bold');
    setappdata(hmf,'hp1sp2spc',hp1sp2spc);      
    hp1sp2spct=uicontrol(hp1sp2,'style','text',...
    'string','SPC','fontsize',8,'fontweight','bold');
    setappdata(hmf,'hp1sp2spct',hp1sp2spct);  

    % frequency, subpanel 2: 1
    hp1sp2fret=uicontrol(hp1sp2,'style','text',...%'BackgroundColor',get(hp1sp2,'Color'),
        'string','FRE','fontsize',8,'fontweight','bold');
    setappdata(hmf,'hp1sp2fret',hp1sp2fret);
    fre=getappdata(hmf,'fre');
    hp1sp2fre=uicontrol(hp1sp2,'Style','popup','Tag',' hp1sp2fre1','string',' ',...
       'callback',@(src,evt)p1sp2fre_listdata(src,evt,hp1sp3srtedit,hp1sp3srt,hmf)...
       ,'fontsize',8,'fontweight','bold');

    N=numel(fre);
    if N==1
       set(hp1sp2fre,'string',fre,'fontsize',8,'fontweight','bold');
    elseif N>1
        set(hp1sp2fre,'string',[{'all'};fre],'fontsize',8,'fontweight','bold');
    end
    setappdata(hmf,'hp1sp2fre',hp1sp2fre); 
   
     %receiver, subpanel 2: 2
    hp1sp2rcvt=uicontrol(hp1sp2,'style','text',...
       'string','RCV','fontsize',8,'fontweight','bold');
    setappdata(hmf,'hp1sp2rcvt',hp1sp2rcvt);

    rcv=getappdata(hmf,'rcv');
    hp1sp2rcv=uicontrol(hp1sp2,'Style','popup','Tag',' hp1sp2rcv1','string',' ',...
        'callback',@(src,evt)hp1sp2rcv_listdata(src,evt,hp1sp3srtedit,hp1sp3srt,hmf),'fontsize',8,'fontweight','bold');
    N=numel(rcv);
    if N==1
        set(hp1sp2rcv,'string',rcv,'fontsize',8,'fontweight','bold');
    elseif numel(rcv)>1
       set(hp1sp2rcv,'string',[{'all'};rcv],'fontsize',8,'fontweight','bold');
    end
    setappdata(hmf,'hp1sp2rcv',hp1sp2rcv);


     %record, subpanel 2: 3
     hp1sp2rect=uicontrol(hp1sp2,'style','text',...
        'string','REC','fontsize',8,'fontweight','bold');
     setappdata(hmf,'hp1sp2rect',hp1sp2rect);

     rec=getappdata(hmf,'rec');
     hp1sp2rec=uicontrol(hp1sp2,'Style','popup','Tag',' hp1sp2rec1','string',' ',...
        'callback',@(src,evt)p1sp2rec_listdata(src,evt,hp1sp3srtedit,hp1sp3srt,hmf),'fontsize',8,'fontweight','bold');

     N=numel(rec);
     if N==1
         set(hp1sp2rec,'string',rec,'fontsize',8,'fontweight','bold');
     elseif N>1
        set(hp1sp2rec,'string',[{'all'};rec],'fontsize',8,'fontweight','bold');
     end
     setappdata(hmf,'hp1sp2rec',hp1sp2rec);
         
     % source, subpanel 2: 4
     hp1sp2srct=uicontrol(hp1sp2,'style','text',...
        'string','SRC','fontsize',8,'fontweight','bold');
     setappdata(hmf,'hp1sp2srct',hp1sp2srct);  
     ssn=getappdata(hmf,'ssn');
     hp1sp2src=uicontrol(hp1sp2,'Style','edit','Tag',' hp1sp2src1','string',num2str(ssn),...
        'callback',@(src,evt)p1sp2src_set(src,evt,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,...
        hmf),'fontsize',8,'fontweight','bold');
     setappdata(hmf,'hp1sp2src',hp1sp2src);    
     
    
     % source channel number, subpanel 2: 5
     scn=getappdata(hmf,'scn');
     hp1sp2sc=uicontrol(hp1sp2,'Style','edit','Tag','hp1sp2sc1','string',num2str(scn),...
        'callback',@(src,evt)p1sp2sc_set(src,evt,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,...
        hmf),'fontsize',8,'fontweight','bold');
     setappdata(hmf,'hp1sp2sc',hp1sp2sc);     
     hp1sp2sct=uicontrol(hp1sp2,'style','text',...
        'string','SCN','fontsize',8,'fontweight','bold');
     setappdata(hmf,'hp1sp2sct',hp1sp2sct);  
     
     
    %subpanel 1 -------------- directory------------------
    hp1sp1=uipanel('Parent',hp1,'Title','Directory','HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp1sp1',hp1sp1);
    
    % rcv directory popup menu
    sdc=getappdata(hmf,'sdc');
    rdc=getappdata(hmf,'rdc'); 
    hp1sp1rcvd=uicontrol(hp1sp1,'Style','popup','Tag',' hp1sp1rcvd1','string',strjoin(rdc,'\n'),...
        'callback',@(src,evt)p1sp1rcvd_listdata(src,evt,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf),...
        'fontsize',10);
    setappdata(hmf,'hp1sp1rcvd',hp1sp1rcvd); 

    x=imread('browerrcv.png');
    I2=imresize(x,[42,113]);
    hp1sp1rcvdi=uicontrol(hp1sp1,'Style','push','Tag','hp1sp1rcvdi1','cdata',I2,...
        'tooltipstring','Receive data path','callback',@(src,evt)p1sp1rcvdi_setpath(src,evt,hp1sp1rcvd,...
        hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf),'fontsize',10);
    setappdata(hmf,'hp1sp1rcvdi',hp1sp1rcvdi);
     
    % check box for source and receivers are in the same directory
    hp1sp1check=uicontrol(hp1sp1,'Style','checkbox','Tag','hp1sp1check1', 'string','Same with source',...
        'value',1,'callback',@(src,evt)p1sp1check_set(src,evt,hp1sp1rcvd,hp1sp1rcvdi,...
        hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf),'fontsize',10);
    set(hp1sp1rcvd,'enable','off');
    set(hp1sp1rcvdi,'enable','off');
    setappdata(hmf,'hp1sp1check',hp1sp1check); 
    
    % src directory
    hp1sp1srcd=uicontrol(hp1sp1,'Style','popup','Tag',' hp1sp1srcd1','string',strjoin(sdc,'\n'),...
        'callback',@(src,evt)p1sp1srcd_listdata(src,evt,hp1sp1check,hp1sp1rcvd,...
        hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf),'fontsize',10);       
    setappdata(hmf,'hp1sp1srcd',hp1sp1srcd);
    % src directory icon
    x=imread('browersrc.png');
    I2=imresize(x,[42,113]);
    hp1sp1srcdi=uicontrol(hp1sp1,'Style','push','Tag','hp1sp1srcdi1','cdata',I2,...
    'tooltipstring','Source data path','callback',@(src,evt)p1sp1srcdi_setpath(src,evt,hp1sp1srcd,hp1sp1check,hp1sp1rcvd,...
    hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)); 
    setappdata(hmf,'hp1sp1srcdi',hp1sp1srcdi);     
    
    % pannel 2 :contian a tabgroup
    hp2=uipanel('Parent',hmf,'HandleVisibility','off');
    setappdata(hmf,'hp2',hp2); 
    hp2tg=uitabgroup('Parent',hp2);      
    hp2tgt1=uitab('Parent',hp2tg,'Title','Time series');
    hp2tgt2=uitab('Parent',hp2tg,'Title','EIR analysis');
    hp2tgt3=uitab('Parent',hp2tg,'Title','Geometry');
    setappdata(hmf,'hp2tg',hp2tg);
    setappdata(hmf,'hp2tgt1',hp2tgt1);
    setappdata(hmf,'hp2tgt2',hp2tgt2);
    setappdata(hmf,'hp2tgt3',hp2tgt3);
     
    % hp2tgt1p1, handle of pannel 1 within p2tgt1p1sp1
    hp2tgt1p1=uipanel('Parent',hp2tgt1,'HandleVisibility','off');
    setappdata(hmf,'hp2tgt1p1',hp2tgt1p1);  
    hp2tgt2p1=uipanel('Parent',hp2tgt2,'HandleVisibility','off');
    setappdata(hmf,'hp2tgt2p1',hp2tgt2p1);  
    hp2tgt3p1=uipanel('Parent',hp2tgt3,'HandleVisibility','off');
    setappdata(hmf,'hp2tgt3p1',hp2tgt3p1);  
    
    % sub panel 1-4 in hp2tgt1p1,1 for control, 2 for plot 3 for status 4
    % for reserved
    hp2tgt1p1sp1=uipanel('Parent',hp2tgt1p1,'HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp2tgt1p1sp1',hp2tgt1p1sp1);
    hp2tgt1p1sp2=uipanel('Parent',hp2tgt1p1,'HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp2tgt1p1sp2',hp2tgt1p1sp2);
    hp2tgt1p1sp3=uipanel('Parent',hp2tgt1p1,'HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp2tgt1p1sp3',hp2tgt1p1sp3);
    hp2tgt1p1sp4=uipanel('Parent',hp2tgt1p1,'HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp2tgt1p1sp4',hp2tgt1p1sp4);

    hp2tgt2p1sp1=uipanel('Parent',hp2tgt2p1,'HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp2tgt2p1sp1',hp2tgt2p1sp1);
    hp2tgt3p1sp1=uipanel('Parent',hp2tgt3p1,'HandleVisibility','off','fontsize',10);
    setappdata(hmf,'hp2tgt3p1sp1',hp2tgt3p1sp1);

    hp2tgt1p1sp1rmdc=uicontrol(hp2tgt1p1sp1,'Style','push',...
        'String','tsview','Value',getappdata(hmf,'p2tgt1p1sp1isrmdc'),...
        'callback',@(src,evt)tsviewer(src,evt,hmf));       % removedc
%     hp2tgt1p1sp1xtickfs=uicontrol(hp2tgt1p1sp1,'Style','check',...
%         'String','Samples','Value',1,...
%         'callback',@(src,evt)p2tgt1p1sp1xtickfs_set(src,evt,hmf));% Time abscessa
%     hp2tgt1p1sp1rcreverse=uicontrol(hp2tgt1p1sp1,'Style','check',...
%         'String','Reverse Src','Value',false,...
%         'callback',@(src,evt)p2tgt1p1sp1srcreverse_set(src,evt,hmf,hmf));  % reverse src
%     hp2tgt1p1sp1rcvreverse=uicontrol(hp2tgt1p1sp1,'Style','check',...
%         'String','Reverse Rcv','Value',false,...
%         'callback',@(src,evt)p2tgt1p1sp1rcvreverse_set(src,evt,hmf));  % reverse rcv

     % change screen size 
     srcsz=get(0,'screensize');
     set(hmf,  'OuterPosition',[srcsz(3)*0.1,srcsz(4)*0.2,srcsz(3)*0.85,srcsz(4)*0.78])
%      hp1sp3ssrtnpp=uicontrol(hp1sp3,'style','push','String','0','fontsize',10,'callback',...
%          @(src,evt)ssrtnpp(src,evt,hp1sp3srtedit,hmf));
%      setappdata(hmf,'hp1sp3ssrtnpp',hp1sp3ssrtnpp);
%      
%      hp1sp3srthome=uicontrol(hp1sp3,'style','push','String','<<','fontsize',10,'callback',...
%          @(src,evt)srthome(src,evt,hp1sp3srtedit,hmf));
%      setappdata(hmf,'hp1sp3srthome',hp1sp3srthome); 
%      
%      hp1sp3srtend=uicontrol(hp1sp3,'style','push','String','>>','fontsize',10,'callback',...
%          @(src,evt)srtend(src,evt,hp1sp3srtedit,hmf));
%      setappdata(hmf,'hp1sp3srtend',hp1sp3srtend);
%      
%      hp1sp3srtpre=uicontrol(hp1sp3,'style','push','String','<','fontsize',10,'callback',...
%          @(src,evt)srtpre(src,evt,hp1sp3srtedit,hmf));
%      setappdata(hmf,'hp1sp3srtpre',hp1sp3srtpre);
%      
%      hp1sp3srtnext=uicontrol(hp1sp3,'style','push','String','>','fontsize',10,'callback',...
%          @(src,evt)srtnext(src,evt,hp1sp3srtedit,hmf));
%      setappdata(hmf,'hp1sp3srtnext',hp1sp3srtnext);

   
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
        'CallBack',@(src,evt)listsrt(src,evt,hmf));
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

function matchpanel(src,~)
    % match the width and height of "hp1" panel into the "hmf" figure
    hp1=getappdata(src,'hp1');
    
      % sub panel 1
    hp1sp1=getappdata(src,'hp1sp1');
    hp1sp1rcvd=getappdata(src,'hp1sp1rcvd');
    hp1sp1srcd=getappdata(src,'hp1sp1srcd');
    hp1sp1check=getappdata(src,'hp1sp1check');
    hp1sp1srcdi=getappdata(src,'hp1sp1srcdi');
    hp1sp1rcvdi=getappdata(src,'hp1sp1rcvdi');
    
     %sub pannel 2
    hp1sp2=getappdata(src,'hp1sp2');
    hp1sp2fre=getappdata(src,'hp1sp2fre');
    hp1sp2rec=getappdata(src,'hp1sp2rec');
    hp1sp2rcv=getappdata(src,'hp1sp2rcv');
    hp1sp2src=getappdata(src,'hp1sp2src');
    hp1sp2sc=getappdata(src,'hp1sp2sc');
    hp1sp2spc=getappdata(src,'hp1sp2spc');
        
    hp1sp2fret=getappdata(src,'hp1sp2fret');
    hp1sp2rect=getappdata(src,'hp1sp2rect');
    hp1sp2rcvt=getappdata(src,'hp1sp2rcvt');
    hp1sp2srct=getappdata(src,'hp1sp2srct');
    hp1sp2sct=getappdata(src,'hp1sp2sct');
    hp1sp2spct=getappdata(src,'hp1sp2spct');

    % sub panel 3
    hp1sp3=getappdata(src,'hp1sp3');
    hp1sp3srt=getappdata(src,'hp1sp3srt');
    hp1sp3srtedit=getappdata(src,'hp1sp3srtedit');
    
    % panel 2
    hp2=getappdata(src,'hp2');
    hp2tg=getappdata(src,'hp2tg');
    hp2tgt1=getappdata(src,'hp2tgt1');
    hp2tgt1p1=getappdata(src,'hp2tgt1p1');
    hp2tgt1p1sp1=getappdata(src,'hp2tgt1p1sp1');
    hp2tgt1p1sp2=getappdata(src,'hp2tgt1p1sp2');
    hp2tgt1p1sp3=getappdata(src,'hp2tgt1p1sp3');
    hp2tgt1p1sp4=getappdata(src,'hp2tgt1p1sp4');
    
    pos=get(src,'Position');
    
    % change panel units to pixels and adjust position
    hp1u = get(hp1,'Units');
    hp1sp1u=get(hp1sp1,'Units');
    hp1sp1rcvdu=get(hp1sp1rcvd,'Units');
    hp1sp1srcdu=get(hp1sp1srcd,'Units');
    hp1sp1checku=get(hp1sp1check,'Units');
    hp1sp1rcvdiu=get(hp1sp1rcvdi,'Units');
    hp1sp1srcdiu=get(hp1sp1srcdi,'Units');
   
    % sub panel 2
    hp1sp2u=get(hp1sp2,'Units');

    hp1sp2freu=get(hp1sp2fre,'Units');
    hp1sp2recu=get(hp1sp2rec,'Units');
    hp1sp2rcvu=get(hp1sp2rcv,'Units');
    hp1sp2srcu=get(hp1sp2src,'Units');
    hp1sp2scu=get(hp1sp2sc,'Units');
    hp1sp2spcu=get(hp1sp2spc,'Units');

    hp1sp2fretu=get(hp1sp2fret,'Units');
    hp1sp2rectu=get(hp1sp2rcvt,'Units');
    hp1sp2rcvtu=get(hp1sp2rcvt,'Units');
    hp1sp2srctu=get(hp1sp2src,'Units');
    hp1sp2sctu=get(hp1sp2sc,'Units');
    hp1sp2spctu=get(hp1sp2spc,'Units');
    
    % sub panel 3
    hp1sp3u=get(hp1sp3,'Units');
    hp1sp3srtu=get(hp1sp3srt,'Units');
    hp1sp3srteditu=get(hp1sp3srtedit,'Units');

    % panel 2
    hp2u=get(hp2,'Units');
    hp2tgu=get(hp2tg,'Units');
    hp2tgt1u=get(src,'Units');
    hp2tgt1p1u=get(hp2tgt1p1,'Units');
    hp2tgt1p1sp1u=get(hp2tgt1p1sp1,'Units');
    hp2tgt1p1sp2u=get(hp2tgt1p1sp2,'Units');
    hp2tgt1p1sp3u=get(hp2tgt1p1sp3,'Units');
    hp2tgt1p1sp4u=get(hp2tgt1p1sp4,'Units');
    
    set(hp1sp1,'Units', 'pixels');
    set(hp1,'Units', 'pixels');
    set(hp1sp1rcvd,'Units', 'pixels');
    set(hp1sp1srcd,'Units', 'pixels');
    set(hp1sp1check,'Units', 'pixels');
    set(hp1sp1srcdi,'Units', 'pixels');
    set(hp1sp1rcvdi,'Units', 'pixels');
    
    set(hp1sp2,'Units', 'pixels');
    set(hp1sp2fre,'Units', 'pixels');
    set(hp1sp2rec,'Units', 'pixels');
    set(hp1sp2rcv,'Units', 'pixels');
    set(hp1sp2fret,'Units', 'pixels');
    set(hp1sp2rcvt,'Units', 'pixels');
    set(hp1sp2rcvt,'Units', 'pixels');
    set(hp1sp2src,'Units', 'pixels');
    set(hp1sp2sc,'Units', 'pixels');
    set(hp1sp2spc,'Units', 'pixels');
    set(hp1sp2srct,'Units', 'pixels');
    set(hp1sp2sct,'Units', 'pixels');
    set(hp1sp2spct,'Units', 'pixels');
    
    set(hp1sp3,'Units','pixels');
    set(hp1sp3srt,'Units','pixels');
    set(hp1sp3srtedit,'Units','pixels');
    
    set(hp2,'Units','pixels');
    set(hp2tg,'Units','pixels');
    set(hp2tgt1,'Units','pixels');
    set(hp2tgt1p1,'Units','pixels');
    set(hp2tgt1p1sp1,'Units','pixels');
    set(hp2tgt1p1sp2,'Units','pixels');
    set(hp2tgt1p1sp3,'Units','pixels');
    set(hp2tgt1p1sp4,'Units','pixels');
    
    hp1pos=[1,1,min(468,pos(3)*.32),pos(4)];
    hp1sp1height=125;
    hp1sp1pos=[hp1pos(1)+1,hp1pos(4)-125,hp1pos(3)-5,hp1sp1height];
    hp1sp1srcdpos=[50,hp1sp1pos(4)-60,hp1sp1pos(3)-55,35];
    hp1sp1rcvdpos=[50,hp1sp1pos(4)-100,hp1sp1pos(3)-55,35];
    hp1sp1checkpos=[50,hp1sp1pos(4)-120,hp1sp1pos(3)-5,20];
    hp1sp1srcdipos=[5,hp1sp1pos(4)-55,42,30];
    hp1sp1rcvdipos=[5,hp1sp1pos(4)-95,42,30];
    
    hp1sp2height=75;hp1sp2width=hp1pos(3)-5;
    hp1sp2x=hp1pos(1); hp1sp2y=hp1sp1pos(2)-hp1sp2height;
    hp1sp1pos2=[hp1sp2x,hp1sp2y,hp1sp2width,hp1sp2height];
    
    % regulator:
    srcsz=get(0,'screensize');
    regwd=62/srcsz(3)*1.25/0.35*hp1sp1pos2(3);
    
    hp1sp2srctpos=[hp1sp2x+4,40,30,15];
    hp1sp2sctpos =[hp1sp2x+regwd-10,40,30,15];
    hp1sp2spctpos=[hp1sp2x+2*regwd-35,40,30,15];
    hp1sp2rcvtpos=[hp1sp2x+2*regwd+10,40,30,15];
    hp1sp2fretpos=[hp1sp2x+3*regwd+10,40,30,15]; 
    hp1sp2rectpos=[hp1sp2x+4*regwd+10,40,30,15];  
    
    hp1sp2srcpos=[hp1sp2x,11,40,24];
    hp1sp2scpos =[hp1sp2x+regwd-10,11,30,24];
    hp1sp2spcpos=[hp1sp2x+2*regwd-35,11,30,24];  
    hp1sp2rcvpos=[hp1sp2x+2*regwd,32,50,1.4];
    hp1sp2frepos=[hp1sp2x+3*regwd,32,50,1.4]; 
    hp1sp2recpos=[hp1sp2x+4*regwd,32,50,1.4];    
  

    hp1sp3height=pos(4)-hp1sp1height-hp1sp2height;
    hp1sp1pos3=[1,1,hp1pos(3),hp1sp3height];
    hp1sp3srtpos=[1,1,hp1sp1pos3(3),hp1sp1pos3(4)-50];
    hp1sp3srteditpos=[1,hp1sp1pos3(4)-45,hp1sp1pos3(3),25];
    
    % restore original panel units
    set(hp1,'Position',hp1pos,'units',hp1u); 
    set(hp1sp1,'Position',hp1sp1pos,'units',hp1sp1u);
    set(hp1sp1rcvd,'Position',hp1sp1rcvdpos,'units',hp1sp1rcvdu);
    set(hp1sp1srcd,'Position',hp1sp1srcdpos,'units',hp1sp1srcdu);
    set(hp1sp1check,'Position',hp1sp1checkpos,'units',hp1sp1checku);
    set(hp1sp1rcvdi,'Position',hp1sp1rcvdipos,'units',hp1sp1rcvdiu);
    set(hp1sp1srcdi,'Position',hp1sp1srcdipos,'units',hp1sp1srcdiu);
    
    set(hp1sp2,'Position',hp1sp1pos2,'units',hp1sp2u);
    set(hp1sp2fre,'Position',hp1sp2frepos,'units',hp1sp2freu);
    set(hp1sp2rcv,'Position',hp1sp2rcvpos,'units',hp1sp2rcvu);
    set(hp1sp2rec,'Position',hp1sp2recpos,'units',hp1sp2recu);
    set(hp1sp2src,'Position',hp1sp2srcpos,'units',hp1sp2srcu);
    set(hp1sp2sc,'Position',hp1sp2scpos,'units',hp1sp2scu);
    set(hp1sp2spc,'Position',hp1sp2spcpos,'units',hp1sp2spcu);
    set(hp1sp2fret,'Position',hp1sp2fretpos,'units',hp1sp2fretu);
    set(hp1sp2srct,'Position',hp1sp2srctpos,'units',hp1sp2srctu);
    set(hp1sp2rect,'Position',hp1sp2rectpos,'units',hp1sp2rectu);
    set(hp1sp2rcvt,'Position',hp1sp2rcvtpos,'units',hp1sp2rcvtu);
    set(hp1sp2srct,'Position',hp1sp2srctpos,'units',hp1sp2srctu);
    set(hp1sp2sct,'Position',hp1sp2sctpos,'units',hp1sp2sctu);
    set(hp1sp2spct,'Position',hp1sp2spctpos,'units',hp1sp2spctu);
    
    set(hp1sp3,'Position',hp1sp1pos3,'units',hp1sp3u);
    set(hp1sp3srt,'OuterPosition',hp1sp3srtpos,'units',hp1sp3srtu);
    hp1sp1pos3=get(hp1sp3srt,'Position');
    if ~isempty(hp1sp1pos3)
       set(hp1sp3srt,'columnwidth',num2cell([0.1 0.1 0.35 0.45]*hp1sp1pos3(3)));
    end
    set(hp1sp3srtedit,'Outerposition',hp1sp3srteditpos,'units',hp1sp3srteditu);

    hp2pos=[hp1pos(3)+5,1,pos(3)-hp1pos(3)-hp1pos(1)-7,pos(4)];
    hp2tgpos=[1,1,hp2pos(3),hp2pos(4)];
    hp2tgt1p1pos=[1,1,hp2tgpos(3),hp2tgpos(4)-36];
    
    hp2tgt1p1sp3pos=[1,1,hp2pos(3),24]; % status
    hp2tgt1p1sp1pos=[1,hp2tgt1p1sp3pos(2)+hp2tgt1p1sp3pos(4)+1,hp2tgt1p1pos(3),45];
    hp2tgt1p1sp2pos=[1,hp2tgt1p1sp1pos(2)+hp2tgt1p1sp1pos(4)+1,hp2tgt1p1pos(3)*0.8, ...
    hp2tgt1p1pos(4)-hp2tgt1p1sp1pos(4)-hp2tgt1p1sp3pos(4)];
    hp2tgt1p1sp4pos=[hp2tgt1p1sp2pos(1)+hp2tgt1p1sp2pos(3)+1,hp2tgt1p1sp2pos(2),...
        hp2tgt1p1pos(3)-hp2tgt1p1sp2pos(3)-2,hp2tgt1p1sp2pos(4)];

    set(hp2,'Position',hp2pos,'units',hp2u);
    set(hp2tg,'position',hp2tgpos,'units',hp2tgu);
    set(hp2tgt1p1,'position',hp2tgt1p1pos,'Units',hp2tgt1p1u);
    set(hp2tgt1p1sp1,'position',hp2tgt1p1sp1pos,'Units',hp2tgt1p1sp1u);
    set(hp2tgt1p1sp2,'position',hp2tgt1p1sp2pos,'Units',hp2tgt1p1sp2u);
    set(hp2tgt1p1sp3,'position',hp2tgt1p1sp3pos,'Units',hp2tgt1p1sp3u);
    set(hp2tgt1p1sp4,'position',hp2tgt1p1sp4pos,'Units',hp2tgt1p1sp4u);
    
function [flag,handle]=existtag(tag)
   handle=findobj('Tag',tag);
   if isempty(handle)  
       flag=false;
   else
       flag=true;
   end
   
function [srt,rcv,rec,fre,spc]=dataupdate(hmf,fname)
% introduction: match src-rcv-pair-table
%
% output:   srt,    s-r pair table
%         rcv,    receiver serial number 
%           rec,    record number
%           fre,    frequencies
%           spc,    spacing
    if nargin<2
        fname=getappdata(hmf,'fname');
    end
    if isempty(fname)
        srt=cell(0);
        rcv={' '};
        rec={' '};
        fre={' '};
        spc=0;
    else  % match
        ssn=getappdata(hmf,'ssn');
        scn=getappdata(hmf,'scn');
        srt=srmatch(fname,ssn,scn);           
        if isempty(srt)
            rcv={' '};
            rec={' '};
            fre={' '};
            spc=0;
        else
            rcv=sort_nat(unique(srt(:,7)));
            rec=sort_nat(unique(srt(:,1)));
            fre=sort_nat(unique(srt(:,8)));
            spc=presetspc(srt(:,3));
        end

        % set global variables
        setappdata(hmf,'srt',srt);
        setappdata(hmf,'ssrt',srt);
        numofssrt=size(srt,1);
        %ssrtnpp=getappdata(hmf,'ssrtnpp');
        %ssrtnp=ceil(numofssrt/ssrtnpp);
        setappdata(hmf,'numofssrt',numofssrt); % indicate on s-r pair
        %setappdata(hmf,'ssrtnp',ssrtnp);
        setappdata(hmf,'curindxofsrt',0); 
        setappdata(hmf,'indxofselected',0);
   
        setappdata(hmf,'rcv',rcv);
        setappdata(hmf,'rec',rec);
        setappdata(hmf,'fre',fre);
        setappdata(hmf,'spc',spc);    
    end

function [ssrt,numofssrt]=dataupdatescreen(hmf,type,val)
        srt=getappdata(hmf,'srt');
        ssrt=datascreen(srt,type,val); %screen data
        
        setappdata(hmf,'ssrt',ssrt);
        numofssrt=size(ssrt,1);
%         sssrtnpp=getappdata(hmf,'sssrtnpp');
%         ssrtnp=ceil(numofssrt/sssrtnpp);
        setappdata(hmf,'numofssrt',numofssrt); % indicate on s-r pair
%         setappdata(hmf,'ssrtnp',ssrtnp);
        setappdata(hmf,'curindxofsrt',0); 
        setappdata(hmf,'indxofselected',0);

function[srt,rcv,rec,fre,spc]=dataupdaterematch(hmf,ssn,scn)
    fname=getappdata(hmf,'fname');
    if isempty(fname)
        srt=cell(0);
        rcv={' '};
        rec={' '};
        fre={' '};
        spc=0;
    else      % match   
        srt=srmatch(fname,ssn,scn);           
        if isempty(srt)
            rcv={' '};
            rec={' '};
            fre={' '};
            spc=0;
        else
            rcv=sort_nat(unique(srt(:,7)));
            rec=sort_nat(unique(srt(:,1)));
            fre=sort_nat(unique(srt(:,8)));
            spc=presetspc(srt(:,3));
        end
        setappdata(hmf,'srt',srt);
        setappdata(hmf,'ssrt',srt);
        numofssrt=size(srt,1);
%         ssrtnpp=getappdata(hmf,'ssrtnpp');
%         ssrtnp=ceil(numofssrt/ssrtnpp);
        setappdata(hmf,'numofssrt',numofssrt); % indicate on s-r pair
%         setappdata(hmf,'ssrtnp',ssrtnp);
        setappdata(hmf,'curindxofsrt',0); 
        setappdata(hmf,'indxofselected',0);
   
        setappdata(hmf,'rcv',rcv);
        setappdata(hmf,'rec',rec);
        setappdata(hmf,'fre',fre);
        setappdata(hmf,'spc',spc);    
    end
    
function updatebuf(curindxofsrt,hmf)
srt=getappdata(hmf,'srt');
if ~isempty(srt)
    setappdata(hmf,'curindxofbuf',curindxofsrt); % buf the first one
    [buf.x,buf.y,buf.meta]=readdata(srt(curindxofsrt,:),getappdata(hmf,'scn'));
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

function updatep1sp2(hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,...
    hmf,srt,rcv,rec,fre,spc)
% udpate sub panel 2
    set(hp1sp2rcv,'String',rcv,'Value',1);
    if numel(rcv)>1
        set(hp1sp2rcv,'string',[{'all'};rcv],'Value',1);
    end
    set(hp1sp2rec,'String',rec,'Value',1);
    if numel(rec)>1
        set(hp1sp2rec,'string',[{'all'};rec],'Value',1);
    end
    set(hp1sp2fre,'String',fre);
    if numel(fre)>1
        set(hp1sp2fre,'string',[{'all'};fre],'Value',1);
    end
    set(hp1sp2spc,'String',spc);
    set(hp1sp3srtedit,'string',size(srt,1));
    if ~isempty(srt)
        set(hp1sp3srt,'Data',srt(:,[6,1,4,5]));
    else
        set(hp1sp3srt,'Data',srt);
    end
   setappdata(hmf,'rcvindex',1);
   setappdata(hmf,'recindex',1);
   setappdata(hmf,'freindex',1);
% ==================================callbacks============================

function p1sp1srcdi_setpath(~,~,hp1sp1srcd,hp1sp1check,hp1sp1rcvd,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)
sdc=getappdata(hmf,'sdc');
csd=uigetdir(sdc{1}); % current data directory
% if ~isequal(csd,0) && ~strcmpi(csd,sdc{1})
    sdc=dirupdate(sdc,csd);
    set(hp1sp1srcd,'string',strjoin(sdc,'|'),'value',1);
    setappdata(hmf,'sdc',sdc);
    
     rdc=getappdata(hmf,'rdc');
    if get(hp1sp1check,'value') && (isempty(rdc) ||~strcmpi(rdc{1},sdc{1}))
            rdc=dirupdate(rdc,sdc{1});
            setappdata(hmf,'rdc',rdc);
            set(hp1sp1rcvd,'string',strjoin(rdc,'|'),'value',1); 
    end
    fname=listdata(sdc{1},rdc{1});
    setappdata(hmf,'fname',fname);
    %update data
    [srt,rcv,rec,fre,spc]=dataupdate(hmf,fname);
    updatep1sp2(hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf,srt,rcv,rec,fre,spc); 
%end

function p1sp1rcvdi_setpath(~,~,x,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)
rdc=getappdata(hmf,'rdc');
crd=uigetdir();
if ~isequal(crd,0) && (isempty(rdc)|| ~strcmpi(crd,rdc{1}) )
    rdc=dirupdate(rdc,crd);
    set(x,'string',strjoin(rdc,'|'),'value',1);
    sdc=getappdata(hmf,'sdc');
    setappdata(hmf,'rdc',rdc);  
    fname=listdata(sdc{1},rdc{1});
    setappdata(hmf,'fname',fname);
    [srt,rcv,rec,fre,spc]=dataupdate(hmf,fname);    
    updatep1sp2(hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf,srt,rcv,rec,fre,spc); 
end

function p1sp1srcd_listdata(src,~,hp1sp1check,hp1sp1rcv,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)
% update dirs
dirval=get(src,'Value');
if dirval>1
    sdc=getappdata(hmf,'sdc');
    if ~isempty(sdc)
        oldsd=sdc{1};
        sdc([1,dirval])=sdc([dirval,1]);% update src dir
        set(src,'string',strjoin(sdc,'|'),'value',1);
        setappdata(hmf,'sdc',sdc);    
        rdc=getappdata(hmf,'rdc');
        if get(hp1sp1check,'value') && (isempty(rdc) || ~strcmpi(rdc{1},sdc{1}) ) %update rcv dir
            rdc=dirupdate(rdc,sdc{1});
            setappdata(hmf,'rdc',rdc);
            set(hp1sp1rcv,'string',strjoin(rdc,'|'),'value',1);
        end
        if ~strcmpi(oldsd,sdc{1})  %update data only from src dir
            fname=listdata(sdc{1},rdc{1});
            setappdata(hmf,'fname',fname);
            %update data
            [srt,rcv,rec,fre,spc]=dataupdate(hmf,fname);
             updatep1sp2(hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf,srt,rcv,rec,fre,spc); 
        end
    end
end

function p1sp1rcvd_listdata(src,~,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)
% set(src,'Value',get(src,'Value'));
% update dirs  
dirval=get(src,'Value');
if dirval>1
    rdc=getappdata(hmf,'rdc');
    if ~isempty(rdc)
        oldrdc=rdc{1};
        rdc([1,dirval])=rdc([dirval,1]);
        set(src,'string',strjoin(rdc,'|'),'value',1);
        setappdata(hmf,'rdc',rdc);
        if ~strcmpi(rdc{1},oldrdc) %different
            sdc=getappdata(hmf,'sdc');
            fname=listdata(sdc{1},rdc{1});
            setappdata(hmf,'fname',fname);
            [srt,rcv,rec,fre,spc]=dataupdate(hmf,fname);
            % update subpanel 2
            updatep1sp2(hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf,srt,rcv,rec,fre,spc); 
        end
    end
end

function p1sp1check_set(src,~,hp1sp1rcvd,hp1sp1rcvdi,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)
rdc=getappdata(hmf,'rdc');
sdc=getappdata(hmf,'sdc');
ischck=get(src,'value');
if ischck && ~strcmpi(rdc{1},sdc{1})
    rdc=dirupdate(rdc,sdc{1});
    setappdata(hmf,'rdc',rdc);
    set(hp1sp1rcvd,'string',strjoin(rdc,'|'),'value',1);
end
fname=listdata(sdc{1},rdc{1});
setappdata(hmf,'fname',fname);
[srt,rcv,rec,fre,spc]=dataupdate(hmf,fname);
updatep1sp2(hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf,srt,rcv,rec,fre,spc); 

if ischck 
    set(hp1sp1rcvd,'enable','off');
    set(hp1sp1rcvdi,'enable','off');
else
    set(hp1sp1rcvdi,'enable','on');
    set(hp1sp1rcvd,'enable','on');
end

function p1sp2fre_listdata(src,~,hp1sp3srtedit,hp1sp3srt,hmf)
% update fres
cfreindex=get(src,'Value');
oldfreindex=getappdata(hmf,'freindex');
oldrcvsnindex=getappdata(hmf,'rcvsnindex');
oldrecindex=getappdata(hmf,'recindex');
if oldfreindex~=cfreindex  % updated
    setappdata(hmf,'freindex',cfreindex);
    set(src,'Value',cfreindex);
    rcv=getappdata(hmf,'rcv');
    rec=getappdata(hmf,'rec');
    fre=getappdata(hmf,'fre');
    if cfreindex==1 % all
        val{3}=fre;    
    else
        val{3}=fre(cfreindex-1);
    end
    if oldrcvsnindex==1
        val{1}=rcv;
    else
        val{1}=rcv(oldrcvsnindex-1);
    end
    if oldrecindex==1
        val{2}=rec;
    else
        val{2}=rec(oldrecindex-1);
    end
    [ssrt,numofssrt]=dataupdatescreen(hmf,0,val);
    
    set(hp1sp3srtedit,'string',numofssrt);
    if ~isempty(ssrt)
        set(hp1sp3srt,'Data',ssrt(:,[6,1,4,5]));
    else
        set(hp1sp3srt,'Data',ssrt);
    end
end

function hp1sp2rcv_listdata(src,~,x30,x31,hmf)
% update rcv
crcvsnindex=get(src,'Value');
oldrcvsnindex=getappdata(hmf,'rcvsnindex');
oldfreindex=getappdata(hmf,'freindex');
oldrecindex=getappdata(hmf,'recindex');
if oldrcvsnindex~=crcvsnindex  % updated
    setappdata(hmf,'rcvsnindex',crcvsnindex);
    set(src,'Value',crcvsnindex);
    rcv=getappdata(hmf,'rcv');
    rec=getappdata(hmf,'rec');
    fre=getappdata(hmf,'fre');
    if oldfreindex==1 % all
        val{3}=fre;    
    else
        val{3}=fre(oldfreindex-1);
    end
    if crcvsnindex==1
        val{1}=rcv;
    else
        val{1}=rcv(crcvsnindex-1);
    end
    if oldrecindex==1
        val{2}=rec;
    else
        val{2}=rec(oldrecindex-1);
    end
    [ssrt,numofssrt]=dataupdatescreen(hmf,0,val);
    set(x30,'string',numofssrt);
    if ~isempty(ssrt)
        set(x31,'Data',ssrt(:,[6,1,4,5]));
    else
        set(x31,'Data',ssrt);
    end
end

function p1sp2rec_listdata(src,~,hp1sp3srtedit,hp1sp3srt,hmf)
% update rcv
crecindex=get(src,'Value');
oldrecindex=getappdata(hmf,'recindex');
oldfreindex=getappdata(hmf,'freindex');
oldrcvsnindex=getappdata(hmf,'rcvsnindex');
if oldrecindex~=crecindex  % updated
    setappdata(hmf,'recindex',crecindex);
    set(src,'Value',crecindex);
    rcv=getappdata(hmf,'rcv');
    rec=getappdata(hmf,'rec');
    fre=getappdata(hmf,'fre');
    if oldfreindex==1 % all
        val{3}=fre;    
    else
        val{3}=fre(oldfreindex-1);
    end
    if oldrcvsnindex==1
        val{1}=rcv;
    else
        val{1}=rcv(oldrcvsnindex-1);
    end
    if crecindex==1
        val{2}=rec;
    else
        val{2}=rec(crecindex-1);
    end
    
    [ssrt,numofssrt]=dataupdatescreen(hmf,0,val);
    set(hp1sp3srtedit,'string',numofssrt);
    if ~isempty(ssrt)
        set(hp1sp3srt,'Data',ssrt(:,[6,1,4,5]));
    else
        set(hp1sp3srt,'Data',ssrt);
    end
end

function p1sp2sc_set(src,~,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)
scn=str2double(get(src,'string'));
if isnan(scn)
    warndlg('Input must be a digit');
else
    setappdata(hmf,'scn',scn);
    ssn=getappdata(hmf,'ssn');
    [srt,rcv,rec,fre,spc]=dataupdaterematch(hmf,ssn,scn);
    set(hp1sp2rcv,'String',rcv,'Value',1);
    if numel(rcv)>1
        set(hp1sp2rcv,'string',[{'all'};rcv],'Value',1);
    end
    set(hp1sp2rec,'String',rec,'Value',1);
    if numel(rec)>1
        set(hp1sp2rec,'string',[{'all'};rec],'Value',1);
    end
    set(hp1sp2fre,'String',fre,'Value',1);
    if numel(fre)>1
        set(hp1sp2fre,'string',[{'all'};fre],'Value',1);
    end
    set(hp1sp2spc,'String',spc);
    set(hp1sp3srtedit,'string',size(srt,1));
    if ~isempty(srt)
        set(hp1sp3srt,'Data',srt(:,[6,1,4,5]));
    else
        set(hp1sp3srt,'Data',srt);
    end
end

function p1sp2src_set(src,~,hp1sp2rcv,hp1sp2rec,hp1sp2fre,hp1sp2spc,hp1sp3srtedit,hp1sp3srt,hmf)
ssn=str2double(get(src,'string'));
if isempty(ssn)
    warndlg('Input must be a digit');
else
    setappdata(hmf,'ssn',ssn);
    scn=getappdata(hmf,'scn');
    [srt,rcv,rec,fre,spc]=dataupdaterematch(hmf,ssn,scn);
    set(hp1sp2rcv,'String',rcv,'Value',1);
    if numel(rcv)>1
        set(hp1sp2rcv,'string',[{'all'};rcv],'Value',1);
    end
    set(hp1sp2rec,'String',rec,'Value',1);
    if numel(rec)>1
        set(hp1sp2rec,'string',[{'all'};rec],'Value',1);
    end
    set(hp1sp2fre,'String',fre,'Value',1);
    if numel(fre)>1
        set(hp1sp2fre,'string',[{'all'};fre],'Value',1);
    end
    set(hp1sp2spc,'String',spc);
    set(hp1sp3srtedit,'string',size(srt,1));
    if ~isempty(srt)
        set(hp1sp3srt,'Data',srt(:,[6,1,4,5]));
    else
        set(hp1sp3srt,'Data',srt);
    end
end

function p1sp2spc_set(src,~, hmf)
spc=str2double(get(src,'string'));
if isempty(spc)
    warndlg('Input must be a digit');
else
    setappdata(hmf,'spc',spc)
end

function p1sp3srt_selectrow(src,~,hmf)
% src.Data(evt.Indices(1),1)={~src.Data{evt.Indices(1),1}};
nx=find(cellfun(@(y) y,src.Data(:,1)));
if ~isempty(nx)
    setappdata(hmf,'curindxofsrt',nx(1)); 
    setappdata(hmf,'indxofselected',nx);
else
    setappdata(hmf,'curindxofsrt',0);      
end

function hp1sp3cm_selectsr(src,~,hp1sp3srt,hmf)
switch src.Label
    case 'Select &All'
        hp1sp3srt.Data(:,1)={true};
        nx=find(cellfun(@(y) y,hp1sp3srt.Data(:,1)));
        if ~isempty(nx)
            setappdata(hmf,'curindhp1sp3srtofsrt',nx(1));
            setappdata(hmf,'indhp1sp3srtofselected',nx);
        else
            setappdata(hmf,'curindhp1sp3srtofsrt',0);
        end
    case 'Select &None'
        hp1sp3srt.Data(:,1)={false};
        nhp1sp3srt=find(cellfun(@(y) y,hp1sp3srt.Data(:,1)));
        if ~isempty(nhp1sp3srt)
            setappdata(hmf,'curindhp1sp3srtofsrt',nhp1sp3srt(1));
            setappdata(hmf,'indhp1sp3srtofselected',nhp1sp3srt);
        else
            setappdata(hmf,'curindhp1sp3srtofsrt',0);
        end
    case '&Reverse Selection'
        hp1sp3srt.Data(:,1)=cellfun(@(y) {~y},hp1sp3srt.Data(:,1));
         nhp1sp3srt=find(cellfun(@(y) y,hp1sp3srt.Data(:,1)));
        if ~isempty(nhp1sp3srt)
            setappdata(hmf,'curindhp1sp3srtofsrt',nhp1sp3srt(1));
            setappdata(hmf,'indhp1sp3srtofselected',nhp1sp3srt);
        else
            setappdata(hmf,'curindhp1sp3srtofsrt',0);
        end
end
% close function
function hmf_close(src,~)
ync=questdlg('Are you sure to exit?','Warning: Exit',...
    'Yes','No','No');
switch ync
    case 'Yes'
        % update the path dir
        sdc=getappdata(src,'sdc');
        rdc=getappdata(src,'rdc');
        %dirwrite(sdc,rdc);
        delete(src);
end

function p2tgt1p1sp1rmdc_set(src,~,hmf) 
if get(src,'value')
    setappdata(hmf,'p2tgt1p1sp1isrmdc',true);
else
    setappdata(hmf,'p2tgt1p1sp1isrmdc',false);
end
fplotts(hp2tgt1p1sp1);

function p2tgt1p1sp1xtickfs_set(src,~,hmf)
if get(src,'value')
    setappdata(hmf,'p2tgt1p1sp1xtickfs',1);
else
    setappdata(hmf,'p2tgt1p1sp1xtickfs',16000);
end

function p2tgt1p1sp1srcreverse_set(src,evt,hmf)
ph=getappdata(hmf,'p2tgt1p1sp1ph');
if get(src,'value')
    ph(1)=-1;
else
    ph(1)=1;
end
setappdata(hmf,'p2tgt1p1sp1ph',ph);

setappdata(hmf,'p2tgt1p1sp1isdual',true);

fplotts(hp2tgt1p1sp1);
crossspectra=getappdata(hmf,'p2tgt1p1sp1crossspectra'); %update crosspectra
if ~isempty(crossspectra)
    crossspectra.b=ph(1)*ph(2)*crossspectra.b;
end
setappdata(hmf,'p2tgt1p1sp1crossspectra',crossspectra);
buf=getappdata(hmf,'buf');
buf.xph=ph(1);
buf.yph=ph(2);
buf.crossspectra=crossspectra;
if getappdata(hmf,'p2tgt1p1sp1isimp')
    buf.imp.g=ph(1)*ph(2)*buf.imp.g;
end
setappdata(hmf,'buf',buf);

function p2tgt1p1sp1rcvreverse_set(src,evt,hmf)
ph=getappdata(hmf,'p2tgt1p1sp1ph');
if get(src,'value')
    ph(2)=-1;
else
    ph(2)=1;
end
setappdata(hmf,'p2tgt1p1sp1ph',ph);
setappdata(hmf,'p2tgt1p1sp1isdual',true);
fplotts(hp2tgt1p1sp1);
crossspectra=getappdata(hmf,'p2tgt1p1sp1crossspectra'); %update crosspectra
if getappdata(hmf,'p2tgt1p1sp1iscrossspectra')
    crossspectra.b=ph(1)*ph(2)*crossspectra.b;
end
setappdata(hmf,'p2tgt1p1sp1crossspectra',crossspectra);
buf=getappdata(hmf,'buf');
buf.xph=ph(1);
buf.yph=ph(2);
buf.crossspectra=crossspectra;
if getappdata(hmf,'p2tgt1p1sp1isimp')
    buf.imp.g=ph(1)*ph(2)*buf.imp.g;
end
setappdata(hmf,'buf',buf);

function tsviewer(~,~,hmf)       
curindxofsrt=getappdata(hmf,'curindxofsrt');
curindxofbuf=getappdata(hmf,'curindxofbuf');
if getappdata(hmf,'numofssrt')==0
    warndlg('No data. Please first set the data path');
    return;
end
if curindxofsrt==0 || numel(getappdata(hmf,'indxofselected'))>1
   warndlg('Please select only one s-r pair');
   return;
end
ssrt=getappdata(hmf,'ssrt');
if curindxofbuf~=curindxofsrt  % new buf 
     updatebuf(curindxofsrt,hmf);
end
buf=getappdata(hmf,'buf');
viewdata(hmf,buf,{sprintf('S: %s.dat/%dm, R: %s.dat/%dm, F: %dHz, N: %d',...
    ssrt{curindxofbuf,2},buf.meta.srcpos,ssrt{curindxofbuf,3},...
    buf.meta.rcvpos, buf.meta.code(2),buf.meta.code(1)),[],'Current (A)','Voltage (V)'},...
    true,false);% time series viewer

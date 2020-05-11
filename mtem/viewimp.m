function himp=viewimp(hmf,imps)
himp=figure('Name','The Earth Impulse','Resize','off','DockControls','off',...
'units','normalized','Position',[0.1,0.1,0.8,0.7],'ToolBar','figure','MenuBar','none',...
'NumberTitle','off','CloseRequestFcn',@(src,evt)closeimp(src,evt,hmf)); 

%initialiation
initialization(hmf,himp,imps);
%menu
hfile=uimenu(himp,'Label','&File','HandleVisibility','off');

uimenu(hfile,'Label','&Export App Res','HandleVisibility','off','CallBack',...
    @(src,evt)exportappres(src,evt,himp));

hanalysis=uimenu(himp,'Label','&Analysis','HandleVisibility','off');
uimenu(hanalysis,'Label','&Filter','HandleVisibility','off','CallBack',...
    @(src,evt)ffilter(src,evt,himp));
uimenu(hanalysis,'Label','&Sub50Hz','HandleVisibility','off','CallBack',...
    @(src,evt)fsub50Hz(src,evt,himp));
himpplot=uimenu(himp,'Label','&Plot','HandleVisibility','off');
uimenu(himpplot,'Label','&Replot','HandleVisibility','off',...
        'CallBack',@(src,evt)freplotimps(src,evt,hmf,himp));
uimenu(himpplot,'Label','&Export in batch','HandleVisibility','off',...
        'CallBack',@(src,evt)fplotimps(src,evt,hmf,himp));

function initialization(hmf,himp,imps)
setappdata(himp,'imps',imps);  % current EIR
setappdata(himp,'mode',getappdata(hmf,'viewimpmode'));
setappdata(himp,'curindxofimp',getappdata(hmf,'viewimpcurindx'));
setappdata(himp,'imptblstr',getappdata(hmf,'imptblstr'));
setappdata(himp,'iseir',true);
setappdata(himp,'ispeak',false);
setappdata(himp,'isaeir',false);
setappdata(himp,'fs',1);
setappdata(himp,'haxes',0);
setappdata(himp,'xlog','linear');
setappdata(himp,'ylog','linear');
setappdata(himp,'impnum',numel(imps));
setappdata(himp,'isstop',false);
setappdata(himp,'ismark',false);
implayout(hmf,himp);
fploteir(himp);

function implayout(hmf,himp)   
    
    uicontrol(himp,'Style','Frame','Tag','impplotframe1',...
        'Units','normalized','Position',[0.79,0.25,0.2,0.31],...
        'BackgroundColor',get(himp,'Color'));  % Frame
    
    markstr={'UnMark','Mark'};
    imps=getappdata(himp,'imps');
    i=getappdata(himp,'curindxofimp');
    himpmark=uicontrol(himp,'Style','push','Tag','impmark1',...
        'Units','normalized','Position',[0.8,0.35,0.08,0.05],...
        'CallBack',@(src,evt)markeir(src,evt,himp),'String',markstr{imps(i).mask+1});      % mark uneffective
    
    %  update EIRs peaks himpreversephase=
    uicontrol(himp,'Style','push','Unit','Normalized',...
        'Position', [0.8,0.49,0.08,0.05],'String','Reverse','Tag','impplot1',...
        'CallBack',@(src,evt)reverseeir(src,evt,himp));       % reversephase button 
    
     himpreversephase=uicontrol(himp,'Style','push','Unit','Normalized',...
        'Position', [0.9,0.49,0.08,0.05],'String','MarkNear','Tag','impplot1',...
        'CallBack',@(src,evt)removenear(src,evt,himp));       % remvoe near button 
    
    himpplot=uicontrol(himp,'Style','push','Unit','Normalized',...
        'Position', [0.8,0.42,0.08,0.05],'String','Plot','Tag','impplot1',...
        'CallBack',@(src,evt)ploteir(src,evt,himpmark,himp));       % plot button 
                               
    himpupdate=uicontrol(himp,'Style','push','Unit','Normalized',...
        'Position',[0.9,0.42,0.08,0.05],'String','Update','Tag','impupdate1',...
        'CallBack',@(src,evt)updatepeak(src,evt,himpmark,hmf,himp));       % update peak
    
   
   
	himpreset=uicontrol(himp,'Style','push','Tag','impreset1',...
        'Units','normalized','Position',[0.9,0.35,0.08,0.05],...
        'CallBack',@(src,evt)reseteir(src,evt,himpmark,himp),'String','Reset');      % reset

    himpsave=uicontrol(himp,'Style','push','Tag','impsave1',...
        'Units','normalized','Position',[0.8,0.28,0.08,0.05],...
        'CallBack',@(src,evt)fsaveeir(src,evt,himp),'String','Save');   % save impulse

    himpexport=uicontrol(himp,'Style','push','Tag','impexport1',...
        'Units','normalized','Position',[0.9,0.28,0.08,0.05],...
        'CallBack',@(src,evt)exporteir(src,evt,himp),'String','Export');%export fig
    
    uicontrol(himp,'Style','Frame','Tag','impplotframe1',...
        'Units','normalized','Position',[0.79,0.78,0.2,0.17],...
        'BackgroundColor',get(himp,'Color'));  % Frame
    
    impplotg=uicontrol(himp,'Style','check','Tag','impplotg1',...
        'Units','normalized','Position',[0.8,0.89,0.08,0.05],...
        'String','EIR','Value',1,'BackgroundColor',get(himp,'Color'),...
        'CallBack',@(src,evt)checkeir(src,evt,himp));       % EIRself
    
    impplotag=uicontrol(himp,'Style','check','Tag','impplotag1',...
        'Units','normalized','Position',[0.9,0.89,0.08,0.05],...
        'String','Analytic','Value',0,'BackgroundColor',get(himp,'Color'),...
        'CallBack',@(src,evt)checkaeir(src,evt,himp));% analytic
    
    impplotpv=uicontrol(himp,'Style','check','Tag','impplotpv1',...
        'Units','normalized','Position',[0.8,0.84,0.08,0.05],...
        'String','Peak','Value',0,'BackgroundColor',get(himp,'Color'),...
        'CallBack',@(src,evt)checkpeak(src,evt,himp));     %peak

    impplotsample=uicontrol(himp,'Style','check','Tag','impplotsample1',...
        'Units','normalized','Position',[0.9,0.84,0.08,0.05],...
        'String','Sample','Value',1,'BackgroundColor',get(himp,'Color'),...
       'CallBack',@(src,evt)checksample(src,evt,himp) );  % time
  
    impplotxlog=uicontrol(himp,'Style','check','Tag','impplotsample1',...
        'Units','normalized','Position',[0.8,0.79,0.08,0.05],...
        'String','Xlog','Value',0,'BackgroundColor',get(himp,'Color'),...
       'CallBack',@(src,evt)checkxlog(src,evt,himp) );  % x log
  
    impplotmark=uicontrol(himp,'Style','check','Tag','impplotsample1',...
        'Units','normalized','Position',[0.9,0.79,0.08,0.05],...
        'String','Mask','Value',0,'BackgroundColor',get(himp,'Color'),...
       'CallBack',@(src,evt)checkmark(src,evt,himp) );  % mark
   
%    impplotylog=uicontrol(himp,'Style','check','Tag','impplotsample1',...
%         'Units','normalized','Position',[0.9,0.8,0.08,0.05],...
%         'String','YLog','Value',0,'BackgroundColor',get(himp,'Color'),...
%        'CallBack',@(src,evt)checkylog(src,evt,himp) );  % y log
   
   
    
    % for multiple
    if strcmpi(getappdata(himp,'mode'),'mul')% multiple
        impitems=getappdata(himp,'imptblstr');   
        heirlist=uicontrol(himp,'Style','popup','string',strjoin(impitems,'|'),...
            'Unit','Normalized','position',[0.79,0.9,0.2,0.1],'Tag','implist1',...
            'CallBack',@(src,evt)listeir(src,evt,himpmark,himp));  
        set(heirlist,'Value',getappdata(himp,'curindxofimp')); 
        
        uicontrol(himp,'Style','Frame','Tag','impplotframe1',...
        'Units','normalized','Position',[0.79,0.6,0.2,0.14],...
        'BackgroundColor',get(himp,'Color'));  % Frame 
    
        hpagedown=uicontrol(himp,'Style','push','Tag','impplotpagedown1',...
            'Units','normalized','Position',[0.8,0.68,0.055,0.05],'String','Previous',...
            'CallBack',@(src,evt)fpagedown(src,evt,heirlist,himpmark,himp));  % page down button
        
        hpageup=uicontrol(himp,'Style','push','Tag','impplotpageup1',...
        'Units','normalized','Position',[0.865,0.68,0.055,0.05],'String','Next',...
        'CallBack',@(src,evt)fpageup(src,evt,heirlist,himpmark,himp)); % page up button

        
 
        hslidev=uicontrol(himp,'Style','slider','Tag','impsliderv1',...
        'Units','normalized','Position',[0.83,0.61,0.11,0.055],'Min',0.001,...
        'Max',2,'Value',1,'CallBack',@feirslidev); % velocity slide 
        set(hslidev,'ToolTipString','Moderate');
        
        uicontrol(himp,'Style','togglebutton','Tag','impslide1',...
        'Units','normalized','Position',[0.93,0.68,0.055,0.05],'String','Slide',...
        'Value',0,'CallBack',@(src,evt)fslideeir(src,evt,hpagedown,himpmark,hpageup,...
        himpreversephase, himpplot,himpupdate,himpreset,himpsave,himpexport,heirlist,hslidev,himp),...
        'Interruptible','on'); % slide toggle button
    
        impslidervmin=uicontrol(himp,'Style','text','Tag','impslidervmin1',...
        'Units','normalized','Position',[0.8,0.604,0.02,0.05],'String','Fast'...
        ,'BackgroundColor',get(himp,'Color'));% velocity slide min

        impslidervmax=uicontrol(himp,'Style','text','Tag','impslidervmin1',...
        'Units','normalized','Position',[0.945,0.604,0.04,0.05],'String','Slow'...
        ,'BackgroundColor',get(himp,'Color'));%  velocity slide max
    end
    
function freplotimps(~,~,hmf,himp)
clf(himp);
implayout(hmf,himp);
fploteir(himp);

function fploteir(himp)
imps=getappdata(himp,'imps');
i=getappdata(himp,'curindxofimp');
if getappdata(himp,'ismark')
    while imps(i).mask==0
        if i<numel(imps)
            i=i+1;
        else
            i=1;
        end
    end
    setappdata(himp,'curindxofimp',i);
end
fs=getappdata(himp,'fs');
iseir=getappdata(himp,'iseir');
ispeak=getappdata(himp,'ispeak');
isaeir=getappdata(himp,'isaeir');
haxes=getappdata(himp,'haxes');
if ~isequal(haxes,0)
    delete(haxes);
end
haxes=axes('Parent',himp,'Position',[0.08,0.25,0.7,0.7]); % axis
set(haxes,'xscale',getappdata(himp,'xlog'));
set(haxes,'yscale',getappdata(himp,'ylog'));

setappdata(himp,'haxes',haxes);

hold on;
if iseir
    warning('off','all');
    plot(time_vector(imps(i).g,fs,1/fs),imps(i).g,'r','LineWidth',2);
    warning('on','all');
end

if ispeak       
        plot((imps(i).cpn)/fs,imps(i).apv,'or','MarkerFace','k');
        pt=(imps(i).cpn)/fs*1.3;
%         if strcmpi(getappdata(himp,'xlog'),'log')
%             pt=log10(pt);
%         end
text( pt,imps(i).g(imps(i).cpn),...
        ['\leftarrow',sprintf('(%d,%.2e,%.2e,%.2e)',imps(i).cpn,(imps(i).cpn-1)/imps(i).meta.fs,imps(i).apv,imps(i).rho)]);
end
if isaeir
    plot(time_vector(imps(i).ag,fs,1/fs),imps(i).ag,'b');
end       
title(sprintf('R: %d, S: %dm(%d,%d), R: %dm(%d,%d), F: %dHz, N: %d M: %d',imps(i).meta.recnum,imps(i).meta.srcpos,...
        imps(i).para.srcsn,imps(i).para.srcch,imps(i).meta.rcvpos,imps(i).meta.rcvsn,imps(i).meta.rcvch,...
        imps(i).meta.code(2),imps(i).meta.code(1),imps(i).mask),'Interpreter', 'none');
    
set(get(haxes,'ylabel'),'string','Amplitude (\Omega/m^2/s)');
if fs==1
    xlabel('Time (Sample)');
else
    xlabel('Time (s)');
end


function checkeir(src,~,himp) 
if get(src,'value')
    setappdata(himp,'iseir',true);
else
    setappdata(himp,'iseir',false);
end
fploteir(himp);

function checkpeak(src,~,himp) 
if get(src,'value')
    setappdata(himp,'ispeak',true);
else
    setappdata(himp,'ispeak',false);
end
fploteir(himp);   

function checkaeir(src,~,himp)
if get(src,'value')
    setappdata(himp,'isaeir',true);
else
    setappdata(himp,'isaeir',false);
end
fploteir(himp);

function checksample(src,~,himp)
if get(src,'value')
    setappdata(himp,'fs',1);
else
    setappdata(himp,'fs',16000);
end
fploteir(himp);

function checkxlog(src,~,himp)
if get(src,'value')
    setappdata(himp,'xlog','log');
else
    setappdata(himp,'xlog','linear');
end
fploteir(himp);

function checkmark(src,~,himp)
if get(src,'value')
    setappdata(himp,'ismark',true)
else
    setappdata(himp,'ismark',false);
end

function checkylog(src,~,himp)
if get(src,'value')
    setappdata(himp,'ylog','log');
else
    setappdata(himp,'ylog','linear');
end
fploteir(himp);

function reverseeir(src,evt,himp)
imps=getappdata(himp,'imps');
i=getappdata(himp,'curindxofimp');
imps(i).g=-imps(i).g;
setappdata(himp,'imps',imps);
fploteir(himp);

function removenear(src,evt,himp)
answer=inputdlg({'Offset(m)'}, 'Remove Near source',[1,80],...
       {'300'});
if isempty(answer)
    return;
end
% para=getappdata(himp,'para');
% para.nearoffset=str2double(answer{1});
% setappdata(himp,'para',para);
imps=getappdata(himp,'imps');
for i=1:numel(imps)
    if abs(imps(i).meta.offset)<str2double(answer{1})
        imps(i).mask=0;
    end
end
setappdata(himp,'imps',imps);
fploteir(himp);
msgbox('Near EIRs have been marked');

function ploteir(src,evt,x2,himp)
imps=getappdata(himp,'imps');
markstr={'UnMark','Mark'};
i=getappdata(himp,'curindxofimp');
set(x2,'string',markstr{imps(i).mask+1});
fploteir(himp);

function updatepeak(src,evt,x2,hmf,himp)
imps=getappdata(himp,'imps');
i=getappdata(himp,'curindxofimp');
% fs=getappdata(himp,'fs');
g=imps(i).g;
N=length(g);

dcm=datacursormode(himp);    % get cursor index
info= getCursorInfo(dcm);
if isempty(info)
   tpn0=imps(i).cpn; 
else
   tpn0=info.DataIndex;
end

n1=30;
n2=30;
x=(max(1,tpn0-n1):min(tpn0+n2,N))';
y0=g(x);
p=polyfit(x,y0,2);
y=polyval(p,x);
hold on;
lgf=plot(x,y,'g','linewidth',1.2);
% lim=get(gca,'xlim');
fs=getappdata(himp,'fs');
% lim=lim*fs;
set(gca,'xlim',[0,200]/fs);
answer=inputdlg({'Left range of fitting','Right range of fitting'},'Fitting',[1,50],...
    {num2str(n1),num2str(n2)});
if isempty(answer)
    return;
else
    n10=n1;n20=n2;
    n1=str2double(answer{1});
    n2=str2double(answer{2});
    if n1~=n10 ||n2~=n20
        x=(max(1,tpn0-n1):min(tpn0+n2,N))';
        y0=g(x);
        p=polyfit(x,y0,2);
        y=polyval(p,x);
    end
    [pv,tpn]=max(y);
    tpn=tpn+x(1);
    delete(lgf);
%     plot(x,y,'g','linewidth',1.2);
    %debug 
    imps(i).mask=1; 
    markstr={'UnMark','Mark'};
    set(x2,'string',markstr{imps(i).mask+1});

    % update the peak values
    imps(i).cpn=tpn;           % peak time (samples)
    imps(i).cpv=pv; % current peak value of calculated EIR
    imps(i)=mapimp(imps(i));

    % 
    % txt = {['Time: ',num2str(pos(1))],...
    % 	      ['Amplitude: ',num2str(pos(2))],['Res: ',num2str(imps(i).rho)]};
    % save app data
    buf=getappdata(hmf,'buf');
    buf.imp=imps(i);
    setappdata(hmf,'buf',buf);
    setappdata(himp,'imps',imps);
    fploteir(himp);
end
% fs=getappdata(himp,'fs');
% set(gca,'xlim',lim/fs);
hold off;
% msgbox('EIR has been updated');

function markeir(src,evt,himp)
imps=getappdata(himp,'imps');
i=getappdata(himp,'curindxofimp');
if imps(i).mask  % 1
%     ync=questdlg('Are you sure to mark this EIR?','Warning: Make EIR uneffective','No');
%     switch ync
%         case 'Yes'
        imps(i).mask=0;
        setappdata(himp,'imps',imps);
        set(src,'String','UnMark');
%     end
else
%      ync=questdlg('Are you sure to unmark this EIR?','Warning: Make EIR effective','No');
%      switch ync
%         case 'Yes'
        imps(i).mask=1;
        setappdata(himp,'imps',imps);
        set(src,'String','Mark');
%      end
end
fploteir(himp);

function reseteir(src,evt,x1,himp)
imps=getappdata(himp,'imps');
i=getappdata(himp,'curindxofimp');

imps(i).mask=1;          % assuming effective data
imps(i).g=imps(i).bg;     % recovery

imps(i).cpv=imps(i).pv; 
imps(i).cpn=imps(i).pn;
imps(i)=mapimp(imps(i));
imps(i).ng=imps(i).g; 
% save app data
setappdata(himp,'imps',imps);
set(x1,'String','Mark');
fploteir(himp);
msgbox('EIR has been reset');

function exporteir(src,evt,himp)
clr=get(himp,'color');
% axis
[fnamelist] = uiputfile({'*.bmp','Bitmap(*.bmp)';'*.jpg','JPEG(*.jpg)';...
       '*.pdf','PDF(*.pdf)';'*.png','PNG(*.png)';...
       '*.tiff','TIFF(*.tiff)';'*.*','all files (*.*)'},'Export Picture');
if isequal(fnamelist,0)
    return;
end
[path,fname,ext]=fileparts(fnamelist);
warning('off','all');
print_fig(fname,['-',ext(2:end)],'-m2',getappdata(himp,'haxes'),'n',true);
set(himp,'color',clr);
warning('on','all')
msgbox(sprintf('%s has been exported',fnamelist));

function fsaveeir(src,evt,himp)
imps=getappdata(himp,'imps');
[fnamelist,path] = uiputfile({'*.mat','Matlab data(*.mat)';'*.*','all files (*.*)'},'Save data');
if isequal(fnamelist,0)
    return;
end
fname=fullfile(path,fnamelist);
saveimp(imps,fname);
msgbox(sprintf('EIRs have been saved in %s',fname));

function closeimp(himp,evt,hmf)
if strcmpi(getappdata(himp,'mode'),'cur')
    buf=getappdata(hmf,'buf');
    imps=getappdata(himp,'imps');
    i=getappdata(himp,'curindxofimp');
    buf.imp=imps(i);
    setappdata(hmf,'buf',buf);  % update current eir
    delete(himp);
else  %if strcmpi(getappdata(himp,'mode'),'mul')
    setappdata(hmf,'impdata',getappdata(himp,'imps'));
    ync=questdlg('Do you want save data defore closing the figure?','Warning: Exit',...
        'Save','Cancel','Exit','Save');
    switch ync
        case 'Save'
                imps=getappdata(himp,'imps');
                fname=saveimp(imps);
                uiwait(msgbox(sprintf('EIRs have been saved in %s',fname),'Save file','modal'));       
                delete(himp);
        case 'Exit'
            button=questdlg('Are you sure to close the figure with data not saved',...
                'Warn: Exit','Yes','No','No');
            switch button
                case 'Yes'
                   delete(himp);
            end
    end
end

function fpagedown(src,evt,x1,x2,himp)
i=getappdata(himp,'curindxofimp');
if i>1
    i=i-1;
    setappdata(himp,'curindxofimp',i);
    set(x1,'Value',i);
end
imps=getappdata(himp,'imps');
 markstr={'UnMark','Mark'};
 set(x2,'string',markstr{imps(i).mask+1});
fploteir(himp);

function fpageup(src,evt,x1,x2,himp)   
i=getappdata(himp,'curindxofimp');
N=getappdata(himp,'impnum');
if i<N
    i=i+1;
    setappdata(himp,'curindxofimp',i);
    set(x1,'Value',i);
end
imps=getappdata(himp,'imps');
markstr={'UnMark','Mark'};
set(x2,'string',markstr{imps(i).mask+1});
fploteir(himp);

function fslideeir(src,evt,x1,x2,x3,x4,x5,x6,x7,x8,x9,heirlist,hslidev,himp)
istoggle=get(src,'Value');
% other  buttons
switch istoggle
    case 1
        % diable other buttons
        for i=1:9 % diable other buttons 
           eval(['set(x',num2str(i),',''enable'',''on'')']); 
        end
        isstop=false; 
        setappdata(himp,'isstop',isstop);  % enable slide
        ci=getappdata(himp,'curindxofimp'); % current index
        set(src,'String','Stop');   % change toggle string
        i=ci;
        N=getappdata(himp,'impnum');
        while i<=N && ~isstop
             imps=getappdata(himp,'imps');
             markstr={'UnMark','Mark'};
             set(x2,'string',markstr{imps(i).mask+1});
           	 fploteir(himp);
             sv=get(hslidev,'Value');% get current velocity of slideing
             pause(sv/5); % interruptted here
             i=i+1;  % next EIR
             isstop=getappdata(himp,'isstop'); 
             if isstop %interrupted
                 i=i-1;
             end
             setappdata(himp,'curindxofimp',min(i,N));
             ci=getappdata(himp,'curindxofimp');
             set(heirlist,'Value',ci);
        end
        set(src,'String','Slide'); 
        % finish slide
        for i=1:9 % diable other buttons
           eval(['set(x',num2str(i),',''enable'',''on'')']); 
        end
    case 0  % stop
      set(src,'String','Slide');
      imps=getappdata(himp,'imps');
      markstr={'UnMark','Mark'};
      set(x2,'string',markstr{imps(i).mask+1});
      fploteir(himp);
      setappdata(himp,'isstop',true);
      for i=1:9 % diable other buttons
           eval(['set(x',num2str(i),',''enable'',''on'')']); 
      end
end

function feirslidev(src,evt)
set(src,'ToolTipString',num2str(get(src,'Value')));

function listeir(src,evt,x2,himp)
i=get(src,'Value');
setappdata(himp,'curindxofimp',i);
fploteir(himp);
imps=getappdata(himp,'imps');
markstr={'UnMark','Mark'};
set(x2,'string',markstr{imps(i).mask+1});

function ffilter(src,evt,himp)
imps=getappdata(himp,'imps');
i=getappdata(himp,'curindxofimp');
impnum=getappdata(himp,'impnum');
if strcmpi(getappdata(himp,'mode'),'cur')
    indx=i;
else
    indx=1:impnum;
end
button=questdlg('Choose filter type','Filter','lowpass','highpass','bandpass','lowpass');
switch button 
    case 'lowpass'
        mode='lp';
        answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
        'Filter',1,{num2str(imps(i).meta.fs),num2str(imps(i).meta.code(2)*0.7)});
        if isempty(answer)
            return;
        else
            for i=indx
                fs=str2double(answer{1});
                cf=str2double(answer{2});
                imps(i).meta.fs=fs;
                imps(i).g=winsincfilter(imps(i).g,cf/fs,mode);
            end
                setappdata(himp,'imps',imps);
                msgbox(sprintf('Filter finished, %d EIRs.',impnum));
        end
     case 'highpass'
            mode='bp';
            answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
            'Filter',1,{num2str(imps(i).meta.fs),num2str(imps(i).meta.code(2)*0.5)});
            if isempty(answer)
                return;
            else
                fs=str2double(answer{1});
                cf=str2double(answer{2});
                for i=indx
                    imps(i).meta.fs=fs;
                    imps(i).g=winsincfilter(imps(i).g,cf/fs,mode);
                end
                setappdata(himp,'imps',imps);
                 msgbox(sprintf('Filter finished, %d EIRs.',impnum));
            end
         
    case 'bandpass'
        mode='bp';
        answer=inputdlg({'Sampling Freqency(Hz)','cut off frequency(Hz)'},...
        'Filter',1,{num2str(imps(i).meta.fs),['[',regexprep(num2str([imps(i).meta.code(2)/imps(i).meta.ncpp,...
          imps(i).meta.code(2)*0.5]),'\s*',','),']']});
            if isempty(answer)
                return;
            else
                fs=str2double(answer{1});
                cf=str2double(answer{2});
                for i=indx
                    imps(i).meta.fs=fs;
                    imps(i).g=winsincfilter(imps(i).g,cf/fs,mode);
                end
            end
            setappdata(himp,'imps',imps);
              msgbox(sprintf('Filter finished, %d EIRs.',impnum));
end

function fplotimps(src,evt,hmf,himp)
    answer=inputdlg({'Number of subplots Per Page','Length','Sampling Frequency','Quality(1/2/3)'}...
    , 'Plot parameter',[1,50],...  
    {'10','500','16000','3'});
    if isempty(answer)
        return;
    end
    imps=getappdata(himp,'imps');
    imps=v2row(indximp(imps,0,'Mode','Mark'));
    imps=sortimp(imps);
    plotimp(imps,'SamplingRate',str2double(answer{3}),'Length',...
        str2double(answer{2}),'nplotperpage',str2double(answer{1}),'Print',true,...
        'Quality',sprintf('-m%d',str2double(answer{4})),'Visibility','off');
    uiwait(msgbox(sprintf('%d pictures have been printed.',ceil(numel(imps)/str2double(answer{1})))));
    clf;
    implayout(hmf,himp);
    fploteir(himp);

function  fsub50Hz(src,evt,himp)
imps=getappdata(himp,'imps');
i=getappdata(himp,'curindxofimp');
imps(i).g=sub50hz(imps(i).g,320,2);
setappdata(himp,'imps',imps);
fploteir(himp);

function exportappres(src,evt,himp)
fnamelist= uiputfile({'*.dat','Apparent Resistivity(*.dat)';'*.*','all files (*.*)'},'Apparent Resistivity');
if isequal(fnamelist,0)
    return;
end
fid=fopen(fnamelist,'w');
imps=getappdata(himp,'imps');
imps=v2row(indximp(imps,0,'Mode','Mark'));
imps=sortimp(imps);
for i=1:numel(imps)
    fprintf(fid,'%.2f   %.2f    %.2e    %.3e	%d      %.2f    %.2f    %.3e\n',...
        imps(i).meta.srcpos,imps(i).meta.rcvpos,imps(i).cpv,imps(i).cpn/imps(i).meta.fs,...
        imps(i).cpn,imps(i).meta.cmp,-abs(imps(i).meta.offset)/2,imps(i).rho);
end
fclose(fid);
msgbox(sprintf('%d apparent resistivity data have been exported',numel(imps)))
% 
% function exportcoimp(src,evt,himp)
% answer=inputdlg({'Offset (m)'}...
%     , 'Common offset section',[1,50],...  
%     '500');
% if isempty(answer)
%     
% fnamelist= uiputfile({'*.dat',sprintf('Apparent Resistivity(*.dat)';'*.*','all files (*.*)'},'Apparent Resistivity');
% if isequal(fnamelist,0)
%     return;
% end
% fid=fopen(fnamelist,'w');
% imps=getappdata(himp,'imps');
% imps=v2row(indximp(imps,0,'Mode','Mark'));
% imps=sortimp(imps);

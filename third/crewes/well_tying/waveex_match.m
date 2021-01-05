function waveex_match(s,t,r,tr,name,w,tw,pname,I,z,tz)
% waveex_match: wavelet explorer for match filter method
%
% waveex_match(s,t,r,tr,name,w,tw)
% % This calls waveex for the majority of the interface. Specific things that must be done here
%   1) initialize input either by args or from file
%   2) call waveex('build',vars);
%   3) fill in the control panel with controls specific to method
%   4) control panel must include an apply button with tag 'apply'. Userdata of the apply button must
%       be the callback string invoked when the reflectivity is changed
%
% extraction method found in: extract_wavelets_match
% 
% s ... seismic trace
% t ... time coordinate for s
% r ... reflectivity
% tr ... time coordinate for r
% name ... title string
% ******** default '' *********
% w ... wavelet known to be embedded (if s is a synthetic with known
%           wavelet)
% ******** default nan (i.e. no known wavelet) *******
% tw ... time coordinate for s
% Must be provided if w is provided
% pname ... string giving the path to the input dataset
% I ... impedance in depth
% z ... depth coordinate for I
% tz ... time coordinate for I
% NOTE: I, z, tz must all be the same size vectors
%

global MATCHALG
global TGATE1 TGATE2

if(nargin<1)
    [fname,pathname]=uigetfile('*.mat','Select input file');
    if(fname==0)
        return;
    end
    load([pathname fname ],'s','t','r','tr','name','w','tw','I','z','tz');
    if(~exist('s','var')||~exist('t','var')||~exist('r','var')||~exist('tr','var')||~exist('name','var'))
        msgbox('Invalid input file');
        return;
    end
    if(isempty(s))
        msgbox('Invalid input file');
        return;
    end
end

if(~ischar(s))
    action='init';
else
    action=s;
end

if(strcmp(action,'init'))
    if(length(s)~=length(t))
        error('s and t must have the same length');
    end
    if(length(r)~=length(tr))
        error('r and tr must have the same length');
    end
    ind=near(t,tr(1),tr(end));
    if(length(ind)~=length(r))
        error('tr must lie within bounds of t')
    end
    if(nargin<5)
        if(~exist('name','var'))
            name=[];
        end
    end
    if(nargin<6)
        if(~exist('w','var'))
            w=nan;
            tw=nan;
        end
    end
    if(nargin<8)
        pname=nan;
    end
    if(~isnan(pname))
        pathname=pname;
    end
    if(~exist('pathname','var'))
        pathname='';
    end
    if(~exist('jcausal','var'))
        jcausal=nan;
    end
    if(nargin<9)
        eye=nan;
        zee=nan;
        teezee=nan;
    end
    
    if(~exist('I','var'))
       if(isnan(eye))
           error('Impedance must be input')
       else
           I=eye;
       end
    end
    if(~exist('z','var'))
       if(isnan(zee))
           error('z must be input')
       else
           z=zee;
       end
    end
    if(~exist('tz','var'))
       if(isnan(teezee))
           error('tz must be input')
       else
           tz=teezee;
       end
    end
    
    if(length(I)~=length(z))
        error('I and z must be the same length');
    end
    
    if(length(tz)~=length(z))
        error('tz and z must be the same length');
    end
    
    %I believe that this stuff considering tr and t to be different is now irrelevant (Jan 2020). But I leave
    %it in just in case.
    
    
    dt=t(2)-t(1);
    dtr=tr(2)-tr(1);
    small=10^(-9);
    if(abs(dt-dtr)>small)
        error('Trace and reflectivity must have the same sample rate');
    end
    if(round(tr(1)/dt)*dt ~= tr(1))
       tr=round(tr/dt)*dt; 
    end
    
    
    %if r is not the same length as s, make them the same by zero padding
    nzeros_beg=round((tr(1)-t(1))/dt);
    nzeros_end=round((t(end)-tr(end))/dt);
    if(nzeros_beg>0)
        r=[zeros(nzeros_beg,1);r];
    end
    if(nzeros_end>0)
        r=[r;zeros(nzeros_end,1)];
    elseif(nzeros_end<0)
        %truncate r to length of s
        r=r(1:length(s));
    end
    tr=t;
    
    er=env(r);
    rdb=todb(er+.001*max(er));
    ind=find(rdb>-25);
    tw1=t(ind(1));
    tw2=t(ind(end));
    
    trange=t(end)-t(1);
    tol=.02;
    if(tw1<t(1)+tol*trange)
        tw1=t(1)+trange*tol;
    end
    if(tw2>t(end)-tol*trange)
        tw2=t(end)-trange*tol;
    end
    
    TGATE1=tw1;
    TGATE2=tw2;
    
    %if r is not the same length as s, make them the same by zero padding
    nzeros_beg=round(tr(1)/dt);
    nzeros_end=round((t(end)-tr(end))/dt);
    if(nzeros_beg>0)
        r=[zeros(nzeros_beg,1);r];
    end
    if(nzeros_end>0)
        r=[r;zeros(nzeros_end,1)];
    elseif(nzeros_end<0)
        %truncate r to length of s
        r=r(1:length(s));
    end
    tr=t;
    
    if(tw1==t(1))
        tw1=t(1)+(t(end)-t(1))*.1;
    end
    if(tw2==t(end))
        tw2=t(end)-(t(end)-t(1))*.1;
    end
    
    %build the figure
    vars.s=s;
    vars.r=r;
    vars.str=zeros(size(r));
    vars.t=t;
    vars.tr=tr;
    vars.name=name;
    vars.w=w;
    vars.tw=tw;
    vars.I=I;
    vars.z=z;
    vars.tz=tz;
    
    waveex('build',vars);
    hfig=gcf;
    
    set(hfig,'name',['Wavelet Explorer: Match Filter, ' name],'numbertitle','off','menubar','none','toolbar','figure')
    
    %set title
    xnow=.02;ynow=.93;
    width=.2;ht=.05;
    fs=12;
    uicontrol(gcf,'style','text','string','Wavelet Explorer: Match Filter','tag','title',...
        'units','normalized','position',[xnow,ynow,width,ht],'fontsize',fs,'fontweight','bold',...
        'horizontalalignment','left','backgroundcolor',[1 1 1]);
    
    
    %set default parameters
    hcntl=findobj(hfig,'tag','control');
    wavestruc=get(hcntl,'userdata');
    parms={'pctnoncausal',50,'wlen',.2,'mu',[1 10],'stab',.01};
    wavestruc.defparms=parms;
    wavestruc.fmin=5;
    wavestruc.fmax=.25/(t(2)-t(1));
    set(hcntl,'userdata',wavestruc);
    
    hfile=uimenu(hfig,'label','File','userdata',pathname);
    hmatch=uimenu(hfile,'label','Match method');
    uimenu(hmatch,'label','Read other dataset','callback','waveex_match(''open'');')
    hsimple=uimenu(hfile,'label','Simple method');
    uimenu(hsimple,'label','Read other dataset','callback','waveex_simple(''open'');')
    hrw=uimenu(hfile,'label','RW method');
    uimenu(hrw,'label','Read other dataset','callback','waveex_rw(''open'');')
    
    
    %install controls
    ht=1/16;
    sep=.5*ht;
    wlbl=.5;
    wtxt=.3;
    wsep=.05;
    xnow=wsep;
    ynow=1-ht-sep;
    fs=11;
    uicontrol(hcntl,'style','text','string','Top gate:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','Top of wavelet extraction gate (sec)',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    %ynow=ynow+.25*ht;
    tdel=.1*(tr(end)-tr(1));
    uicontrol(hcntl,'style','edit','string',num2str(tw1,4),'tag','tw1',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'callback','waveex(''waveletgatechangetext'')',...
        'tooltipstring','You can choose this by dragging the dotted green lines',...
        'fontsize',fs);
    %
    xnow=wsep;
    ynow=ynow-ht-sep;
    uicontrol(hcntl,'style','text','string','Bottom gate:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','Bottom of wavelet extraction gate (sec)',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    uicontrol(hcntl,'style','edit','string',num2str(tw2,4),'tag','tw2',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'callback','waveex(''waveletgatechangetext'')',...
        'tooltipstring','You can choose this by dragging the dotted green lines',...
        'fontsize',fs);
    %
    xnow=wsep;
    ynow=ynow-ht-sep;
    tzpct=findparm(parms,'pctnoncausal');
    uicontrol(hcntl,'style','text','string','Pct non causal:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','Percent of wavelet before t=0.',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    %ynow=ynow+.25*ht;
    uicontrol(hcntl,'style','edit','string',num2str(tzpct),'tag','pctnoncausal',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'tooltipstring','A number between 0 and 100.',...
        'fontsize',fs);
    %

    xnow=wsep;
    ynow=ynow-ht-sep;
    val=findparm(parms,'wlen');
    uicontrol(hcntl,'style','text','string','Length:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','Wavelet length as a fraction of gate size',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    uicontrol(hcntl,'style','edit','string',num2str(val),'tag','wlen',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'tooltipstring','Enter a value between 0 and 1',...
        'fontsize',fs);
    %
    xnow=wsep;
    ynow=ynow-ht-sep;
    val=findparm(parms,'mu');
    uicontrol(hcntl,'style','text','string','Constraints:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','Contraint weights: two non-negative numbers separated by a space or comma ',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    uicontrol(hcntl,'style','edit','string',num2str(val),'tag','mu',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'tooltipstring','first value is SMOOTHNESS second is TIME constraint (0,0 means no constraints)',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    %
    xnow=wsep;
    ynow=ynow-ht-sep;
    val=findparm(parms,'stab');
    uicontrol(hcntl,'style','text','string','Stability:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','Stability constant (used in wavelet inversion)',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    uicontrol(hcntl,'style','edit','string',num2str(val),'tag','stab',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'tooltipstring','Enter a number between 0 and 1',...
        'fontsize',fs);
    %
    xnow=wsep;
    ynow=ynow-ht-sep;
    val=wavestruc.fmin;
    uicontrol(hcntl,'style','text','string','Min freq:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','This is for a post-decon bandpass filter',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    uicontrol(hcntl,'style','edit','string',num2str(val),'tag','fmin',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'tooltipstring','Enter a non negative number in HZ',...
        'fontsize',fs);
    %
    xnow=wsep;
    ynow=ynow-ht-sep;
    val=wavestruc.fmax;
    uicontrol(hcntl,'style','text','string','Max freq:','units','normalized',...
        'position',[xnow,ynow,wlbl,ht],...
        'tooltipstring','This is for a post-decon bandpass filter',...
        'backgroundcolor',[1 1 1],...
        'fontsize',fs);
    xnow=xnow+wlbl+wsep;
    uicontrol(hcntl,'style','edit','string',num2str(val),'tag','fmax',...
        'units','normalized','position',[xnow,ynow,wtxt,ht],...
        'tooltipstring','Enter a non negative number in HZ',...
        'fontsize',fs);
    %
    xnow=wsep;
    ynow=ynow-ht-sep;
    uicontrol(hcntl,'style','pushbutton','string','Apply','units','normalized',...
        'position',[xnow,ynow,1.2*wlbl,1.2*ht],'callback','waveex_match(''apply'')',...
        'tooltipstring','Push to extract a wavelet with the above parameters',...
        'backgroundcolor',.95*[1 1 0],...
        'fontsize',fs,'tag','apply','userdata','waveex_match(''update'');');
    
    %load up true wavelet if provided
    if(~isnan(w))
        %expand tw to negative samples if it is causal
        if(tw(1)==0)
           twmax=tw(end);
           dt=tw(2);
           tmp=tw;
           tw=-twmax:dt:twmax;
           nzeros=length(tw)-length(tmp);
           w=[zeros(nzeros,1);w];
        end
        htv=findobj(gcf,'tag','tvcontrol');
        htwin=findobj(htv,'tag','twin');
        result.twin=str2double(get(htwin,'string'));
        htinc=findobj(htv,'tag','tinc');
        result.tinc=str2double(get(htinc,'string'));
        result.w=w;
        result.tw=tw;
        result.tw1=min(t);
        result.tw2=max(t);
        parms=getparms;
        result.tw1=findparm(parms,'tw1');
        result.tw2=findparm(parms,'tw2');
        fmin=findparm(parms,'fmin');
        result.fmin=fmin;
        fmax=findparm(parms,'fmax');
        result.fmax=fmax;
        result.ccs=[1 0];
        result.pep=1;
        result.crr=[1 0];
        result.prr=1;
        result.tvphaseSR=[];
        result.tvdelaySR=[];
        result.tvphaseSS=[];
        result.tvdelaySS=[];
        result.tvphaseRR=[];
        result.tvdelayRR=[];
        result.tvccSS=ones(size(s));
        result.tvccRR=ones(size(r));
        result.tvpep=ones(size(s));
        result.tvprr=ones(size(r));  
        result.name='"True" wavelet';
        result.icausal=jcausal;
        result.r=r;
        result.rf=butterband(r,tr,fmin,fmax,4,0);
        result.rp=result.rf;
        result.sp=convz(r,w,tw);
        result.params=parms;
        result.phase=waveletphase(w,tw);
        result.wavelabel=['phase=' num2str(result.phase,3) ', ccs=1, pep=1, ccr=1, prr=1'];
        wavestruc.results{1}=result;
        wavestruc.iresult=1;
        set(hcntl,'userdata',wavestruc);
    end

    
    
    waveex('waveletplot')
    waveex('traceplot')
    waveex('tvphsdelay')
    disableDA(gcf);
elseif(strcmp(action,'open'))
    hfile=findobj(gcf,'label','File');
    pname=hfile.UserData;
    [fname,pathname]=uigetfile([pname '*.mat'],'Select input file for WaveEx Match');
    hfile.UserData=pathname;
    if(fname==0)
        return;
    end
    load([pathname fname ],'s','t','r','tr','name','w','tw','I','z','tz');
    if(~exist('s','var')||~exist('t','var')||~exist('r','var')||~exist('tr','var')||~exist('name','var'))
        msgbox('Invalid input file');
        return;
    end
    if(isempty(s))
        msgbox('Invalid input file');
        return;
    end
    if(exist('w','var'))
        waveex_match(s,t,r,tr,name,w,tw,pathname,I,z,tz);
    else
        waveex_match(s,t,r,tr,name,nan,nan,pathname,I,z,tz);
    end    
elseif(strcmp(action,'apply')||strcmp(action,'update'))
    parms=getparms;
    pctnoncausal=findparm(parms,'pctnoncausal');
    if(isnan(pctnoncausal) || pctnoncausal<0 || pctnoncausal>100)
        msgbox('bad value for Pct non causal');
        return;
    end
    
    tw1=findparm(parms,'tw1');
    tw2=findparm(parms,'tw2');
    wlen=findparm(parms,'wlen');
    stab=findparm(parms,'stab');
    mu=findparm(parms,'mu');
    fmin=findparm(parms,'fmin');
    fmax=findparm(parms,'fmax');

    hcntl=findobj(gcf,'tag','control');
    wavestruc=get(hcntl,'userdata');
    s=wavestruc.s;
    r=wavestruc.r(:,wavestruc.ireflec);
    t=wavestruc.t;
    tr=wavestruc.tr;
    ind=near(t,tr(1),tr(end));
    wlen2=wlen*(tw2-tw1);
    nwlen=round(wlen2/(t(2)-t(1)));
    if(pctnoncausal==50)
        icausal=0;
    else
        icausal=round(pctnoncausal*nwlen/100)+1;%we want pctnoncausal=0 to correspond to minimum phase which is icausal=1
    end
    if(strcmp(MATCHALG,'matchs'))
        [ww,tww]=extract_wavelets_match(s(ind),t(ind),r,.5*(tw1+tw2),tw2-tw1,wlen,mu(1),pctnoncausal);
    elseif(isempty(MATCHALG) || strcmp(MATCHALG,'matchT'))
        [ww,tww]=extract_wavelets_matchT(s(ind),t(ind),r,.5*(tw1+tw2),tw2-tw1,wlen,mu,pctnoncausal);
    else
        error('unable to find match algorithm')
    end
    w=ww{1};
    tw=tww{1};
    
    %w=butterband(w,tw,fmin,fmax,4,0);%applying filter to wavelet makes it less jittery
    rf=butterband(r,tr,fmin,fmax,4,0);%filtered reflectivity needed for diagnostics
    
%     if(icausal==0)
%         mname='noncausal';
%     else
%         mname='causal';
%     end
    
    name=[time2str(tw1) '-' time2str(tw2) '_' num2str(pctnoncausal) '_' num2str(wlen) '_' ...
        num2str(mu(1)) '-' num2str(mu(2)) '_'  num2str(fmin) '-' num2str(fmax)];
    %compute the trace model and the reflectivity estimate
    izero=near(tw,0);
    sp=convz(r,w,izero);
    [d,twd]=toinv(w,stab,round(length(w)/2),icausal);
    rp=convz(s,d,twd);
%     if(icausal==0)
%         rp=convz(s,d);
%     else
%         rp=convm(s,d);
%     end
    rpf=butterband(rp,t,fmin,fmax,4,0);%always apply filter after inverse
    phs=waveletphase(w,tw);
    wavestruc.sp=sp;
    wavestruc.rp=rpf;

    %compute performance diagnostics
    %ind=near(t,tw1,tw2);%extraction window
    %ind points to entire range of r, not just extraction window
    if(strcmp(action,'update'))
        result=wavestruc.results{wavestruc.iresult};
    end
    %measure stats over extraction window
    ind2=near(t,tw1,tw2);
    result.ccs=maxcorr(s(ind2),sp(ind2));
    result.pep=penpred(s(ind2),sp(ind2));
    result.ccr=maxcorr(rf(ind2),rpf(ind2));
    result.prr=penpred(rf(ind2),rpf(ind2));
    result.wavelabel=['phase=' num2str(phs,3) ', ccs=' num2str(sigfig(result.ccs(1),2)) ', pep=' ...
        num2str(sigfig(result.pep,2)) ', ccr=' num2str(sigfig(result.ccr(1),2))...
        ', prr=' num2str(sigfig(result.prr,2))];
    
    %get windowing parameters
    htv=findobj(gcf,'tag','tvcontrol');
    htwin=findobj(htv,'tag','twin');
    val=get(htwin,'string');
    twin=str2double(val);
    if(isnan(twin)||twin>t(end)||twin<0)
        msgbox('bad value for time window size');
        return;
    end
    htinc=findobj(htv,'tag','tinc');
    val=get(htinc,'string');
    tinc=str2double(val);
    if(isnan(tinc)||tinc>t(end)||tinc<0)
        msgbox('bad value for window increment');
        return;
    end
    
    %populate results structure
    result.r=r;
    result.rf=rf;
    result.w=w;
    result.tw=tw;
    result.tw1=tw1;
    result.tw2=tw2;
    result.twin=twin;
    result.tinc=tinc;
    result.params=parms;
    result.fmin=fmin;
    result.fmax=fmax;
    result.name=name;
    result.icausal=icausal;
    result.phase=phs;
    result.tw1=tw1;
    result.tw2=tw2;
    result.tvphaseSR=[];
    result.tvdelaySR=[];
    result.tvphaseSS=[];
    result.tvdelaySS=[];
    result.tvphaseRR=[];
    result.tvdelayRR=[];
    result.tvpep=[];
    result.tvprr=[];
    result.tvccSS=[];
    result.tvccRR=[];
%     result.twin=wavestruc.twin;
%     result.tinc=wavestruc.tinc;
    result.sp=sp;
    result.rp=rpf;
    nresults=length(wavestruc.results);
    if(strcmp(action,'apply'))
        iresult=nresults+1;
        wavestruc.results{iresult}=result;
        wavestruc.iresult=iresult;
    else
        wavestruc.results{wavestruc.iresult}=result;
    end

    set(hcntl,'userdata',wavestruc);
    
    %waveex('plotresult');
    waveex('traceplot');
    waveex('tvphsdelay');
    waveex('waveletplot');
    disableDA(gcf);
end
end


function parms=getparms
parms=cell(16,1);
hcntl=findobj(gcf,'tag','control');

hobj=findobj(hcntl,'tag','pctnoncausal');
parms{1}='pctnoncausal';
val=get(hobj,'string');
pctnoncausal=round(str2double(val));
parms{2}=pctnoncausal;

hobj=findobj(hcntl,'tag','tw1');
tw1=str2double(get(hobj,'string'));
parms{3}='tw1';
parms{4}=tw1;

hobj=findobj(hcntl,'tag','tw2');
tw2=str2double(get(hobj,'string'));
parms{5}='tw2';
parms{6}=tw2;

hobj=findobj(hcntl,'tag','wlen');
wlen=str2double(get(hobj,'string'));
parms{7}='wlen';
parms{8}=wlen;

hobj=findobj(hcntl,'tag','mu');
mu=str2num(get(hobj,'string')); %#ok<ST2NM>
parms{9}='mu';
parms{10}=mu;


hobj=findobj(hcntl,'tag','stab');
stab=str2double(get(hobj,'string'));
parms{11}='stab';
parms{12}=stab;

hobj=findobj(hcntl,'tag','fmin');
fmin=str2double(get(hobj,'string'));
parms{13}='fmin';
parms{14}=fmin;

hobj=findobj(hcntl,'tag','fmax');
fmax=str2double(get(hobj,'string'));
parms{15}='fmax';
parms{16}=fmax;
end
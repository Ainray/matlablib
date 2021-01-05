 function align_ref(r,tr,s,t,I,z,tz,cb,wfact,htfact)
%
% r ... reflectivity
% tr ... time coordinate for r
% s ... trace
% ts ... time coordinate for s
% cb ... string giving callback to be executed when "return shifted reflectivity" button is pushed.
%   The adjusted reflectivity is placed in the global ALIGN_REF_RNEW and the corresponding time
%   coordinate is in the global ALIGN_REF_TRNEW .
% wfact ... width of figure as a fraction of calling figure
% htfact ... height of figure as a fraction of calling figure
%
% 
global DRAGLINE_MOTION DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_PAIRED DRAGLINE_MOTIONCALLBACK DRAGLINE_CC
global TGATE1 TGATE2

% main data structure is the data obj or dobj with the fields:
% dobj.s ... the seismic trace as supplied at calling
% dobj.scurr ... currently displayed version of s, with or without filter (always a trace even if envelope is displayed)
% dobj.t ... time coordinate for dobj.s
% dobj.r ... the reflectivity. This is always the unchanged original r
% dobj.I ... impedance in depth
% dobj.z ... depth coordinate for I
% dobj.tz ... time coordinate for I
% dobj.tr ... time coordinate for dobj.r
% dobj.rnew ... the current altered reflectivity. This has been padded with zeros to the same
%        length as s to allow easy shifting. It therefore uses dobj.t as its time
%        coordinate.
% dobj.rcurr ... currently displayed version of rnew, with or without filter (always a trace even if envelope is displayed)
% dobj.cc ... cross correlation max and lag from maxcorr
% dobj.tr1 ... estimated start time of the altered reflectivity. There may be some sinc
%        function side lobes earlier than this but they are not returned. This determines the
%        start of the samples that are returned to the calling program. It gets adjusted
%        with each shift or stretch.
% dobj.tr2 ... estimated end time of the altered reflectivity. There may be some sinc
%        function side lobes later than this but they are not returned. This determines the
%        end of the samples that are returned to the calling program. It gets adjusted
%        with each shift or stretch.
% dobj.str ... total cumulative stretch function required to computed dobj.rnew from dobj.I.
%        This gets updated after every shift or stretch. It is a two column matrix with the same
%        number of rows as t. The first column is always t and the second column gives the times
%        that the input reflectivity samples map to. See the internal function "combine_stretches"
%        for more discussion.
% dobj.tg1 ... start time of correlation gate
% dobj.tg2 ... end time of correlation gate
%
% The data object is retrieved or set with the internal functions getdataobject and setdataobject
%

if(~ischar(r))
    action='init';
else
    action=r;
end


if(strcmp(action,'init'))
   dt=t(2)-t(1);
   dtr=tr(2)-tr(1);
   small=.0000001;
   if((abs(dt-dtr)>small))
       error('log and seismic sample rates are different');
   end
   pos=get(gcf,'position');%calling figure
   hcallingfig=gcf;
   hfig=figure;
   h=pos(4)*htfact;
   w=pos(3)*wfact;
   set(hfig,'position',[pos(1)+.5*w,pos(2),w,h]);
   set(hfig,'name','Alignment tool','menubar','none','toolbar','figure','numbertitle','off');
   xnot=.1;ynot=.1;
   waxe=.45;%traces axes
   waxets=.1;%time-shift axes (sum of waxe and waxets should be .55)
   htaxe=.8;
   htraxe=axes('position',[xnot ynot waxe htaxe],'tag','traces');
   
   h0=.05*htaxe;
   w0=.15*waxe;
   uicontrol(gcf,'style','popupmenu','string',{'traces','envelopes'},...
       'units','normalized','position',[xnot+.45*(waxe-w0),ynot-h0,w0,h0],...
       'value',1,'tooltipstring','Choose trace or envelope display',...
       'callback',@envtrace,'tag','envtrace');
   
   tl=num2cell([.01 .02 .05 .1 .15 .2 .25 .3 .4 .5 .75]);
   uicontrol(gcf,'style','text','string','timing lines:',...
       'units','normalized','position',[xnot+.01*waxe,ynot-2*h0,.8*w0,2*h0],...
       'tooltipstring','Timing line interval');
   uicontrol(gcf,'style','popupmenu','string',tl,...
       'units','normalized','position',[xnot+.01*waxe+.8*w0,ynot-h0,w0,h0],...
       'value',7,'tooltipstring','Choose timing line interval',...
       'callback',@timinglines,'tag','timinglines');
   
   uicontrol(gcf,'style','popupmenu','string',{'Adjusted ref','Adjusted and original ref',...
       'View original ref only','Revert to original ref'},...
       'units','normalized','position',[xnot+.7*(waxe-w0),ynot-h0,2*w0,h0],...
       'value',1,'tooltipstring','Choose what to display',...
       'callback',@dispchoice,'tag','dispchoice');
   
   %time_shift axes
   htsaxe=axes('position',[xnot+waxe ynot waxets htaxe],'tag','timeshiftaxes');
   
   %correlation axes
   sep=.1;
   sep2=.05;
   xnow=xnot+waxe+waxets+sep;
   waxe2=.2;
   htaxe2=.4;
   %first entry of user data of ccaxes is size of crosscorrelation scan in seconds. In this case +/- .4
   hccaxe=axes('position',[xnow,ynot+2.5*sep2,waxe2,htaxe2],'userdata',{.4,t,s,r});
   
   htpan=.2;
   wpan=.15;
   fs=10;
   xnow=xnot+waxe+waxets+.2*sep;
   %ynow=ynot+htaxe-htpan;
   sep3=.05;
   ynow=ynot+htaxe2+3.5*sep2;
   hpan1=uipanel(gcf,'title','Interactive shifting','fontsize',fs,...
       'position',[xnow,ynow,wpan,htpan]);
   xnow=xnow+wpan;
   hpan2=uipanel(gcf,'title','Automatic shifting','fontsize',fs,...
       'position',[xnow,ynow,wpan,htpan]);
   xnow=xnow-wpan;
   hpan3=uipanel(gcf,'title','filter','fontsize',fs,...
       'position',[xnow,ynow+htpan,wpan,.6*htpan]);
   
   uicontrol(gcf,'style','pushbutton','string','undo/redo','units','normalized',...
       'position',[xnow+wpan+sep3,ynow+1.1*htpan,.4*wpan,.3*htpan],'callback',@undoredo,...
       'tooltipstring','toggle between new and previous result','tag','undoredo');
   w=.45;
   h=.25;
   
   xn=sep3;
   yn=1-h-sep3;
   uicontrol(hpan1,'style','text','string','Time shift (ms)','units','normalized',...
       'position',[xn,yn,w,h],'tag','timeshiftlabel',...
       'tooltipstring','A value in MILLISECONDS');
    xn=xn+w+sep3;
    shifts=dt*[.25 .5 1:10 15 20]*1000;
    sshifts=cell(size(shifts));
    for k=1:length(shifts)
        sshifts{k}=num2str(shifts(k));
    end
    ival=near(shifts,dt*1000);
    uicontrol(hpan1,'style','popupmenu','string',sshifts,'units','normalized',...
       'position',[xn,yn,w,h],'tag','timeshift','value',ival,...
       'tooltipstring','A value in MILLISECONDS');
   xn=sep3;
   yn=yn-h-sep3;
   w=.8;
   uicontrol(hpan1,'style','pushbutton','string','Shift DOWN','units','normalized',...
       'position',[xn,yn,w,h],'tag','shiftdown',...
       'tooltipstring','Shift reflectivity DOWN by the amount above',...
       'callback',@applyshift);
   xn=sep3;
   yn=yn-h-sep3;
   uicontrol(hpan1,'style','pushbutton','string','Shift UP','units','normalized',...
       'position',[xn,yn,w,h],'tag','shiftup',...
       'tooltipstring','Shift reflectivity UP by the amount above',...
       'callback',@applyshift,'userdata',[htraxe hccaxe htsaxe]);
   
   xn=sep3;
   w=.8;
   h=.25;
   yn=1-h-sep3;
   %    uicontrol(hpan2,'style','popupmenu','string',{'Bulk shift','TV ccorr','DTW'},'units','normalized',...
   uicontrol(hpan2,'style','popupmenu','string',{'Bulk shift','TV ccorr','DTW'},'units','normalized',...
       'position',[xn,yn,w,h],'tag','automethod','value',1,...
       'tooltipstring','Choose the automatic method');
   xn=sep3;
   yn=yn-h-sep3;
   uicontrol(hpan2,'style','pushbutton','string','Apply','units','normalized',...
       'position',[xn,yn,w,h],'tag','autoapply',...
       'tooltipstring','Apply the above method',...
       'callback',@applyauto);
   xn=.5*sep3;
   yn=yn-h-sep3;
   uicontrol(hpan2,'style','pushbutton','string','Undo','units','normalized',...
       'position',[xn,yn,.4*w,h],'tag','autoundo',...
       'tooltipstring','Undo the last auto application',...
       'callback',@undoauto,'enable','off');
   xn=xn+.4*w+.5*sep3;
   uicontrol(hpan2,'style','pushbutton','string','Show shifts','units','normalized',...
       'position',[xn,yn,.7*w,h],'tag','showshifts',...
       'tooltipstring','show the estimated time shifts',...
       'callback',@showshifts);
   
   xn=sep3;
   h=.25;
   w1=.4;w2=.4;
   yn=1-h;
   uicontrol(hpan3,'style','text','string','fmin','units','normalized',...
       'position',[xn,yn-.2*h,w1,h],'tag','fminlabel',...
       'tooltipstring','lowest frequency in passband');
   uicontrol(hpan3,'style','edit','string','10','units','normalized',...
       'position',[xn+w1,yn,w2,h],'tag','fmin','tooltipstring','A value in Hz');
      yn=yn-h-sep3;
   uicontrol(hpan3,'style','text','string','fmax','units','normalized',...
       'position',[xn,yn-.2*h,w1,h],'tag','fmaxlabel',...
       'tooltipstring','lowest frequency in passband');
   uicontrol(hpan3,'style','edit','string','80','units','normalized',...
       'position',[xn+w1,yn,w2,h],'tag','fmax','tooltipstring','A value in Hz');
   %xn=xn+w1+w2+sep3;
   %yn=yn+.5*h;
   yn=yn-h-sep3;
   uicontrol(hpan3,'style','text','string','Apply to','units','normalized',...
       'position',[xn,yn-.2*h,w2,h],'tag','applylabel',...
       'tooltipstring','choose what to filter');
   uicontrol(hpan3,'style','popupmenu','string',{'none','both','rcs','seismic'},...
       'units','normalized','position',[xn+w2,yn,w2,h],'tag','applyto',...
       'tooltipstring','Apply bandpass filter','value',2,...
       'callback','align_ref(''filter'')');
   
   xnow=xnot+waxe+waxets+sep;
   
   w=.1;
   h=.035;
   ynow=ynot+.5*h;
   uicontrol(gcf,'style','pushbutton','string','Return shifted reflectivity','units','normalized',...
       'position',[xnow,ynow,2*w,h],'tag','returnref',...
       'tooltipstring','Return modified reflectivity to original program',...
       'callback',@returnref,'userdata',{cb, [], hcallingfig}); %middle value of user data is unused
   ynow=ynow-h;
   uicontrol(gcf,'style','pushbutton','string','Save to SEGY','units','normalized',...
       'position',[xnow,ynow,w,h],'tag','savesegy',...
       'tooltipstring','Save modified reflectivity and shift information to SEGY',...
       'callback',@savesegy);
   uicontrol(gcf,'style','pushbutton','string','Save to Excel','units','normalized',...
       'position',[xnow+w,ynow,w,h],'tag','saveexcel',...
       'tooltipstring','Save modified reflectivity and shift information to Excel spreadsheet',...
       'callback',@saveexcel);
   
   
    %info button
    xnow=.05;
    ynow=.95;
    width=.1;fs=12;ht=.03;
    hinfo=uicontrol(gcf,'style','pushbutton','string','Info?','tag','info','units','normalized',...
        'position',[xnow,ynow,width,ht],'callback','align_ref(''help'')',...
        'backgroundcolor',.95*[1 1 0],'fontsize',fs);
   %determine path to help file
    helpfile='Alignment_tool_Help.pdf';
    if(isdeployed)
        [status,result]=system('path'); %#ok<ASGLU>
        ss = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));%truncate
        %check "for_testing"
        ichk=strfind(ss,'for_testing');
        ind=strfind(ss,'\');
        if(~isempty(ichk)) %#ok<STREMP>
            helppath=[ss(1:ind(end)) 'for_redistribution_files_only\'];
        else
            helppath=[ss '\'];
        end
    else
        thispath=which('waveex');
        ind=strfind(thispath,'\');
        helppath=thispath(1:ind(end));
    end
    hinfo.UserData=[helppath helpfile];
   %expand r to size of z
   ind=near(t,tr(1),tr(end));
   rnew=zeros(size(s));
   rnew(ind)=r;

   cc=maxcorr(rnew,s,100);
   
   %define correlation gate
   tg1=nan;
   tg2=nan;
   trange=t(end)-t(1);
   tol=.02;
   if(~isempty(TGATE1))
       if(TGATE1>=t(1)+trange*tol)
           tg1=TGATE1;
       end
   end
   if(~isempty(TGATE2))
       if(TGATE2<=t(end)-trange*tol)
           tg2=TGATE2;
       end
   end
   if(isnan(tg1))
       tg1=t(1)+tol*trange;
   end
   if(isnan(tg2))
       tg2=t(end)-tol*trange;
   end

   %Initialize the data object
   dobj.s=s;
   dobj.r=r;
   dobj.tr=tr;
   dobj.t=t;
   dobj.I=I;
   dobj.z=z;
   dobj.tz=tz;
   dobj.rnew=rnew;%padded version of r to the same length as s
   dobj.cc=cc;
   dobj.tg1=tg1;
   dobj.tg2=tg2;
   dobj.tr1=tr(1);
   dobj.tr2=tr(end);
   dobj.str=[t t];
   
   setdataobject(dobj);
   align_ref('filter');
   plottraces(t,s,rnew);
   plottimeshifts;
      
elseif(strcmp(action,'dragline'))
    hline=gco;
    dobj=getdataobject;
    %tr=dobj.tr;
    t=dobj.t;
    lineid=get(hline,'tag');
    [tg1,tg2]=getcorrelationgate;
    factor=.1;
    if(strcmp(lineid,'tg1'))
        del=(tg2-tg1)*factor;
        ylims=[t(1) tg2-del];
        hlineother=findobj(gca,'tag','tg2');
        pair=[hline hlineother];
    elseif(strcmp(lineid,'tg2'))
        del=(tg2-tg1)*factor;
        ylims=[tg1+del t(end)];
        hlineother=findobj(gca,'tag','tg1');
        pair=[hlineother hline];
    else
        return;
    end
    DRAGLINE_MOTION='yonly';
    DRAGLINE_YLIMS=ylims;
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='align_ref(''corrgatechange'');';
    DRAGLINE_PAIRED=pair;
    DRAGLINE_MOTIONCALLBACK='align_ref(''corrupdate'');';
%     DRAGLINE_MOTIONCALLBACK='';
    hcc=findobj(gcf,'tag','ccf');
    hcce=findobj(gcf,'tag','ccfe');
    DRAGLINE_CC=[hcc hcce];%this is not part of the dragline function but is unique to align_ref
    dragline('click');
elseif(strcmp(action,'corrgatechange'))
    dobj=getdataobject;
    h1=findobj(gca,'tag','tg1');
    h2=findobj(gca,'tag','tg2');
    y1=get(h1,'ydata');
    y2=get(h2,'ydata');
    dobj.tg1=y1(1);
    dobj.tg2=y2(1);
    setdataobject(dobj);
    plotccorr(dobj.t,dobj.scurr,dobj.rcurr);
elseif(strcmp(action,'corrupdate'))
    hfig=gcf;
    hup=findobj(hfig,'tag','shiftup');
    haxes=get(hup,'userdata');
    yl=get(haxes(2),'ylim');
    dobj=getdataobject;
    s=dobj.scurr;
    rnew=dobj.rcurr;
    t=dobj.t;
    dt=t(2)-t(1);
%     h1=findobj(gca,'tag','tg1');
%     h2=findobj(gca,'tag','tg2');
    hpair=DRAGLINE_PAIRED;
    hcc=DRAGLINE_CC;
    tg1=get(hpair(1),'ydata');
    tg2=get(hpair(2),'ydata'); 
%     [tg1,tg2]=getcorrelationgate;
    icc=near(t,tg1(1),tg2(1));
    nlags=round(yl(2)/dt);
    mw=mwindow(length(icc));
    %mw=gwindow(length(icc));
    %ccf=ccorr(rnew(icc).*mw,s(icc).*mw,nlags);
    ccf=ccorr(s(icc).*mw,rnew(icc).*mw,nlags);
    tlag=dt*(-nlags:nlags);
    ccfe=env(ccf);
    set(hcc(1),'xdata',ccf,'ydata',tlag);
    set(hcc(2),'xdata',ccfe,'ydata',tlag);
    
elseif(strcmp(action,'filter'))
    dobj=getdataobject;
%     h1=findobj(gca,'tag','tg1');
%     h2=findobj(gca,'tag','tg2');
%     y1=get(h1,'ydata');
%     y2=get(h2,'ydata');
%     dobj.tg1=y1(1);
%     dobj.tg2=y2(1);
%     setdataobject(dobj);
    plottraces(dobj.t,dobj.s,dobj.rnew);
    
elseif(strcmp(action,'help'))
    hinfo=findobj(gcf,'tag','info');
    ud=hinfo.UserData;
    winopen(ud);
elseif(strcmp(action,'revertrcs'))
    decision=yesnofini;
    if(decision==1)
        hfig=gcf;
        %we revert
        hup=findobj(hfig,'tag','shiftup');
        haxes=get(hup,'userdata');
        axes(haxes(1));
        
        dobj=getdataobject;
        t=dobj.t;
        tr=dobj.tr;
        r=dobj.r;
        s=dobj.s;
        rnew=zeros(size(s));
        %grab existing correlation gate
        ind=find(abs(r)>0);
        rnew(ind)=r(ind);
        tg1=t(ind(1));
        tg2=t(ind(end));
        cc=maxcorr(rnew(ind),s,100);%should this be s(ind)
        dobj.rnew=rnew;
        dobj.str=[t t];
        dobj.cc=cc;
        dobj.tg1=tg1;
        dobj.tg2=tg2;
        dobj.tr1=tr(1);
        dobj.tr2=tr(end);
        setdataobject(dobj);
    end
    hchoice=findobj(gcf,'tag','dispchoice');
    set(hchoice,'value',1)
    dispchoice;
    plottimeshifts;
    
end

end
%end of main function. Internal functions start here
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function applyshift(source,~)
%
% Here we apply a bulk time shift either to the entire reflectivity or to a portion of it. In the
% latter case, the user must have defined anchors at the two ends of the zone to shift and an
% application point where the full shift applies. The shift is linearly tapered to zero at the
% anchors. The number of anchors can be anything from none to many, and the application point need
% not be between anchors. Anchors simply define immovable points and the application point defines 
% where the full shift occurs.
%

% userdata of the reflectivity
% udat{1} ... cell array of graphics handles for the anchors
% udat{2} ... cell array of times for the anchors
% udat{3} ... a single graphics handle denoting the application point
% udat{4} ... the time of the application point
%
enableundoredo;
sgn=+1;
if(strcmp(get(source,'tag'),'shiftup'))
    sgn=-1;
end
dobj=getdataobject; %fields defined at the start of this file
tr_lims=[dobj.tr1 dobj.tr2];
s=dobj.s;
t=dobj.t;
tr=dobj.tr;
I=dobj.I;
z=dobj.z;
tz=dobj.tz;
ind=near(t,tr(1),tr(end));
r=zeros(size(t));
r(ind)=dobj.r;
%get the handle of reflectivity
hup=findobj(gcf,'tag','shiftup');
haxes=get(hup,'userdata');
axes(haxes(1));
href=findobj(gca,'tag','ref');
% interrogate href user data for anchor info
uu=get(href,'userdata');
shifttype='bulk';
if(~isempty(uu))
    ha=uu{1};
    if(~isempty(ha))
        %ok we have anchors
        hpoint=uu{3};
        if(isempty(hpoint))
            msgbox('You must click on the reflectivity to define the application point')
            return;
        else
            shifttype='stretch';
            tpoint=uu{4};%time of the application point
            tanch=uu{2};%anchor times
        end
    end
end
htshift=findobj(gcf,'tag','timeshift');
% val=get(htshift,'string');
% tshift=str2double(val)/1000;
sshifts=get(htshift,'string');
ival=get(htshift,'value');
tshift=str2double(sshifts{ival})/1000;
if(isnan(tshift) || abs(tshift)>.5*(t(end)-t(1)) || abs(tshift)<.0001)
    msgbox('Bad time shift value');
    return;
end
if(strcmp(shifttype,'bulk'))
    %this means we are shifting the entire trace
    dt=t(2)-t(1);
    delt=sgn*abs(tshift);%the total shift
    str2=[t t+delt];
    str1=dobj.str;%the previous stretch
    str3=combine_stretches(str1,str2,dt);%compute the updated stretch
    delt_total=str3(:,2)-str3(:,1);%total stretch from original.
    rnew=make_new_rcs(t,delt_total,I,tz);
%     deltz=interp1(t,delt_total,tz);%interpolate to log samples
% %     rnew=stretcht(r,t,str3(:,2)-str3(:,1));
%     rnew=zeros(size(r));
%     [tmpr,tr]=imp2rcs_t(I,tz+deltz,dt);
%     %tmpr will usually be smaller than rnew. tr tells us the times to map tmpr to
%     t1=max([t(1) tr(1)]);%in case the shift moves samples before t(1)
%     tN=min([tr(end) t(end)]);%in case the shift moves samples after t(end)
%     indr=near(tr,t1,tN);
%     ind=near(t,t1,tN);
%     rnew(ind)=tmpr(indr);
    tr_lims=tr_lims+delt;
    clearallanchors;%seems best to clear the anchor info if a bulk shift has been made
else
    %here we are applying a shift to just a portion of the trace. So there must be anchors and an
    %application point defined.
    dt=t(2)-t(1);
    deltmp=zeros(1,length(tanch)+3);%this will have a shift for each anchor, plus endpoints, plus application point
    ttmp=sort([t(1) tanch tpoint t(end)]);%desired shifts
    ind=find(ttmp==tpoint);
    if(ind<=2)
        %tpoint is less than any anchor
        deltmp(1)=sgn*abs(tshift);%shift t(1)
        deltmp(ind)=sgn*abs(tshift);%shift application point
    elseif(ind>=length(ttmp)-1)
        %tpoint is greater than any anchor
        deltmp(ind)=sgn*abs(tshift);%shift application point
        deltmp(end)=sgn*abs(tshift);%shift end point
    else
        deltmp(ind)=sgn*abs(tshift);%shift application point
    end
    delt=interp1(ttmp,deltmp,t);
    str2=[t t+delt(:)];
    str1=dobj.str;
    str3=combine_stretches(str1,str2,dt);%compute the updated stretch
    delt_total=str3(:,2)-str3(:,1);%total stretch from original.
    rnew=make_new_rcs(t,delt_total,I,tz);
%     deltz=interp1(t,delt_total,tz);%interpolate to log samples
% %     rnew=stretcht(r,t,str3(:,2)-str3(:,1));
%     rnew=zeros(size(r));
%     [tmpr,tr]=imp2rcs_t(I,z,tz+deltz,dt);
%     %tmpr will usually be smaller than rnew. tr tells us the times to map tmpr to
%     t1=max([t(1) tr(1)]);%in case the shift moves samples before t(1)
%     tN=min([tr(end) t(end)]);%in case the shift moves samples after t(end)
%     indr=near(tr,t1,tN);
%     ind=near(t,t1,tN);
%     rnew(ind)=tmpr(indr);
    
    ind=near(t,tr_lims(1));
    tr_lims(1)=tr_lims(1)+delt(ind(1));
    ind=near(t,tr_lims(2));
    tr_lims(2)=tr_lims(2)+delt(ind(1));
    
    %shift the application point
    tpoint=tpoint+sgn*abs(tshift);
    set(uu{3},'ydata',tpoint);
    uu{4}=tpoint;
    set(href,'userdata',uu);%update anchors
end
%update the stretch information
dobj.str=str3;
dobj.tr1=tr_lims(1);
dobj.tr2=tr_lims(2);
dobj.rnew=rnew;
setdataobject(dobj);


plottraces(t,s,rnew)
plottimeshifts

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function applyauto(~,~)
% Here we apply an automatically defined shift. There are 3 possibilities
%   1) Bult shift: The trace and reflectivity are cross correlatied and the maximum of the envelope
%       of the ccorr defines the magnitude of the bulk shift. User can choose the ccorr window and
%       whther traces or envelopes are used. 
%   2) Time-variant ccorr: Function tvmaxcorr is invoked to accomplish a time-variant
%       crosscorrelation between trace and reflectivity. Envelopes are typically used in the
%       process. This usually gives better results than the next option.
%   3) Dynamic time warping - or DTW - is invoked. This is Dave Hale's theory and does not seem to
%       be as immune to phase rotations as option 2.
%
% userdata of the reflectivity
% udat{1} ... cell array of graphics handles for the anchors
% udat{2} ... cell array of times for the anchors
% udat{3} ... a single graphics handle denoting the application point
% udat{4} ... the time of the application point
%
hfig=gcf;
enableundoredo;
hautometh=findobj(gcf,'tag','automethod');
methods=get(hautometh,'string');
imeth=get(hautometh,'value');
method=methods{imeth};
[tr1,tr2]=getcorrelationgate;
dobj=getdataobject;
s=dobj.s;
t=dobj.t;
tr=dobj.tr;
I=dobj.I;
z=dobj.z;
tz=dobj.tz;
ind=near(t,tr(1),tr(end));
r=zeros(size(t));
r(ind)=dobj.r;
rnew=dobj.rnew;
dt=t(2)-t(1);
hundo=findobj(gcf,'tag','autoundo');
hundoredo=findobj(gcf,'tag','undoredo');
hshowshifts=findobj(gcf,'tag','showshifts');
clearallanchors;%seems best to clear the anchors
switch method
    case 'Bulk shift'
        hup=findobj(hfig,'tag','shiftup');
        haxes=get(hup,'userdata');
        ud=haxes(2).UserData;
        tshift=ud{1};
        [tg1,tg2]=getcorrelationgate;
        %         answers=inputdlg({'start correlation gate (sec)','end correlation gate (sec)',...
        %             'max lag to search (sec)','Enter 1 for traces 2 for envelopes'},'Bulk shift',1,...
        %             {time2str(tg1), time2str(tg2), time2str(tshift),int2str(2)});
        answers=askthingsle('questions',{'start correlation gate (sec)','end correlation gate (sec)',...
            'max lag to search (sec)','Enter 1 for traces 2 for envelopes','Order of maximum'},...
            'name','Bulk shift',...
            'answers',{time2str(tg1), time2str(tg2), time2str(tshift),int2str(1),'1|2|3|4'});
        if(isempty(answers))
            return
        end
        tg1=str2double(answers{1});
        if(isnan(tg1) || tg1<t(1) || tg1>t(end))
            msgbox('bad value for correlation gate start');
            return;
        end
        tg2=str2double(answers{2});
        if(isnan(tg2) || tg2<tg1 || tg2>t(end))
            msgbox('bad value for correlation gate end');
            return;
        end
        tshift=str2double(answers{3});
        if(isnan(tshift) || tshift<0 || tshift>.5*(t(end)-t(1)))
            msgbox('bad value for correlation max lag');
            return;
        end
        envchoice=str2double(answers{4});
        if(isnan(envchoice) || (envchoice~=1 && envchoice~=2))
           msgbox('bad value for trace/envelope choice');
           return
        end
        m=str2double(answers{5});
        %run maxcorr
        ind=near(t,tg1,tg2);
        n=round(tshift/dt);
        mw=mwindow(length(ind));
        if(envchoice==1)
            cc=maxcorrex(s(ind).*mw,rnew(ind).*mw,n,m,2);%the final "2" means use env(cc)
        else
            cc=maxcorrex(env(s(ind).*mw),env(rnew(ind).*mw),n,m);
        end
        tstat=cc(2)*dt;
        str2=[t t+tstat];
        str1=dobj.str;
        str3=combine_stretches(str1,str2,dt);
        delt_total=str3(:,2)-str3(:,1);%total stretch from original.
        rnew2=make_new_rcs(t,delt_total,I,tz);
        dobj.rnew=rnew2;
        set(hundo,'userdata',{rnew, [tr1 tr2], str1},'enable','on');
        set(hundoredo,'userdata',{rnew, [tr1 tr2], str1, []},'enable','on');
        set(hshowshifts,'userdata',{tstat*ones(size(t)),rnew,rnew2,t,method})
        setcorrelationgate(max([tr1+tstat t(1)]),min([tr2+tstat,t(end)]));
    case 'TV ccorr'
        tr=dobj.tr;
        twin=.3;
        tinc=.05;
        tshift=.2*twin;
        answers=inputdlg({'Gaussian window half-width (sec)','Window increment (sec)',...
            'max lag to search (sec)','Enter 1 for traces 2 for envelopes'},'TV cc',1,...
            {time2str(twin), time2str(tinc), time2str(tshift), int2str(2)});
        if(isempty(answers))
            return
        end
        twin=str2double(answers{1});
        if(isnan(twin) || twin<0 || twin>(t(end)-t(1))*0.5)
            msgbox('bad value for Gaussian window half-width');
            return;
        end
        tinc=str2double(answers{2});
        if(isnan(tinc) || tinc<0 || tinc>twin)
            msgbox('bad value for window increment');
            return;
        end
        tshift=str2double(answers{3});
        if(isnan(tshift) || tshift<0 || tshift>.5*twin)
            msgbox('bad value for correlation max lag');
            return;
        end
        envchoice=str2double(answers{4});
        if(isnan(envchoice) || (envchoice~=1 && envchoice~=2))
           msgbox('bad value for trace/envelope choice');
           return
        end
        ind=near(t,tr(1),tr(end));
        ii=find(abs(rnew)>0);
        t1=t(ii(1));
        t2=t(ii(end));
        if(envchoice==1)
          [cc,tcc]=tvmaxcorr(s(ind),rnew(ind),t(ind),twin,tinc,tshift,t1,t2,2);
        else
          [cc,tcc]=tvmaxcorr(env(s(ind)),env(rnew(ind)),t(ind),twin,tinc,tshift,t1,t2,0); 
        end
        delt=cc(:,2)*dt;
        %toss values from areas with zero r
        ii=find(abs(rnew)>0);
        t1=t(ii(1));
        t2=t(ii(end));
        ii=between(t1,t2,tcc,2);
        delt=delt(ii);
        tcc=tcc(ii);
        if(tcc(1)>t(1))
            tcc2=[t(1);tcc];
            delt2=[delt(1);delt];
        else
            tcc2=tcc;
            delt2=delt;
        end       
        if(tcc2(end)<t(end))
            tcc2=[tcc2;t(end)];
            delt2=[delt2;delt(end)];
        end
        tstretch=interp1(tcc2,delt2,t);
        str2=[t t+tstretch(:)];
        str1=dobj.str;%previous stretch
        str3=combine_stretches(str1,str2,dt);
        delt_total=str3(:,2)-str3(:,1);%total stretch from original.
        rnew2=make_new_rcs(t,delt_total,I,tz);
%         deltz=interp1(t,delt_total,tz);%interpolate to log samples
%         rnew2=zeros(size(r));
%         [tmpr,tr]=imp2rcs_t(I,z,tz+deltz,dt);
%         %tmpr will usually be smaller than rnew. tr tells us the times to map tmpr to
%         t1=max([t(1) tr(1)]);%in case the shift moves samples before t(1)
%         tN=min([tr(end) t(end)]);%in case the shift moves samples after t(end)
%         indr=near(tr,t1,tN);
%         ind=near(t,t1,tN);
%         rnew2(ind)=tmpr(indr);
%         rnew2=stretcht(r,t,str3(:,2)-str3(:,1));
        i1=near(t,tr(1));
        i2=near(t,tr(end));
        setcorrelationgate(max([tr1+tstretch(i1) t(1)]),min([tr2+tstretch(i2),t(end)]));
%         tr_lims=tr_lims+[tstretch(i1) tstretch(i2)];
        dobj.rnew=rnew2;
        set(hundo,'userdata',{rnew, [tstretch(i1) tstretch(i2)], str1},'enable','on');
        set(hundoredo,'userdata',{rnew, [tr1 tr2], str1, []},'enable','on');
        set(hshowshifts,'userdata',{tstretch,rnew,rnew2,t,method})
    case 'DTW'
        tr=dobj.tr;
        tshift=.02;
        blocksize=10;%(samples)
        answers=inputdlg({'max lag to search (sec)','lag constraint delta(samples)/sample'},...
            'DTW',1,{time2str(tshift),num2str(1/blocksize)});
        if(isempty(answers))
            return
        end
        tshift=str2double(answers{1});
        if(isnan(tshift) || tshift<0 || tshift>.4*(tr(end)-tr(1)))
            msgbox('bad value for correlation max lag');
            return;
        end
        invb=str2double(answers{2});
        if(isnan(invb) || invb<0 || invb>1)
            msgbox('bad value for lag constraint');
            return;
        end
        ind=near(t,tr(1),tr(end));
        b=round(1/invb);
        L=round(tshift/dt);
        %impose the seismic band
        w=waveseis(s,t);
        rsband=convz(rnew,w);
%         [e,d,u]=DTW(env(s(ind)),env(rsband(ind)),L,b); %#ok<ASGLU>
        [e,d,u]=DTW(s(ind),rsband(ind),L,b); %#ok<ASGLU>
%         delt=u*dt;
%         delt2=[delt(1);delt;delt(end)];
%         tdtw=[t(1);tr;t(end)];
%         tstretch=interp1(tdtw,delt2,t);
        tstretch=u*dt;
        str2=[t t+tstretch(:)];
        str1=dobj.str;
        str3=combine_stretches(str1,str2,t(2)-t(1));
        delt_total=str3(:,2)-str3(:,1);%total stretch from original.
        rnew2=make_new_rcs(t,delt_total,I,tz);
%         rnew2=stretcht(r,t,str3(:,2)-str3(:,1));
        i1=near(t,tr(1));
        i2=near(t,tr(end));
        setcorrelationgate(max([tr1+tstretch(i1) t(1)]),min([tr2+tstretch(i2),t(end)]));
        dobj.rnew=rnew2;
        set(hundo,'userdata',{rnew, [tstretch(i1) tstretch(i2)], str1},'enable','on');
        set(hshowshifts,'userdata',{tstretch,rnew,rnew2,t,method})

end
%update the stretch information
dobj.str=str3;
dobj.tr1=tr1;
dobj.tr2=tr2;
setdataobject(dobj);

clearallanchors;%seems best to clear the anchor info if autoshift has been made
%

plottraces(t,s,dobj.rnew)
plottimeshifts

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function undoauto(source,~)
hundo=source;
udat=get(hundo,'userdata');
if(isempty(udat))
    return;
end
rnew=udat{1};
tr_adj=udat{2};
str=udat{3};
dobj=getdataobject;

tr_lims=[dobj.tr1 dobj.tr2];%these are the limit times of r. We may need to adjust them here
tr_lims=tr_lims-tr_adj;
dobj.rnew=rnew;
dobj.tr1=tr_lims(1);
dobj.tr2=tr_lims(2);
dobj.str=str;
% set(hrr,'userdata',urr);
set(hundo,'userdata',[],'enable','off')
setdataobject(dobj);
plottraces(dobj.t,dobj.s,dobj.rnew)
plottimeshifts


end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showshifts(source,~)
hshowshifts=source;
udat=get(hshowshifts,'userdata');
if(isempty(udat))
    return;
end
tshifts=udat{1};
rnew=udat{2};
rnew_shifted=udat{3};
t=udat{4};
method=udat{5};
figure
subplot(1,2,1)
plot(rnew,t,rnew_shifted,t);
gridy;flipy
ylabel('time (sec)');
legend('original','shifted')
title('reflectivity before and after')
subplot(1,2,2)
plot(tshifts,t);
xlabel('seconds')
set(gca,'yticklabel',[])
grid;flipy
tm=max(abs(tshifts));
tm=.01*ceil(tm/.01);
xlim([-tm tm])
title(['applied shifts by ' method])
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plottraces(t,s,rnew)
%this function updates both the traces axes and the ccorr axes
%determine what reflectivity we are plotting
hfig=gcf;
hchoice=findobj(hfig,'tag','dispchoice');
choiceflag=get(hchoice,'value');
dobj=getdataobject;
if(choiceflag==2)
    %we are diplaying both original and adjusted reflectivity
    rr=dobj.r;
    tr=dobj.tr;
    ind=near(t,tr(1),tr(end));
    r=zeros(size(t));
    r(ind)=rr/max(abs(rr));
elseif(choiceflag==1) %show only adjusted
    %we are displaying only adjusted reflectivity
    r=nan*t;%so we set original to nan so it won't display
else %show only original
    %so we discard the input rnew and set rnew equal to the original r
    rr=dobj.r;
    tr=dobj.tr;
    ind=near(t,tr(1),tr(end));
    r=zeros(size(t));
    r(ind)=rr/max(abs(rr));
    rnew=r;
    r=nan*r;
end

%determine if filtering
hfmin=findobj(hfig,'tag','fmin');
hfmax=findobj(hfig,'tag','fmax');
happlyto=findobj(hfig,'tag','applyto');
ifilt=get(happlyto,'value');
targets=get(happlyto,'string');%this says what is being filtered
thistarget=targets{ifilt};
fnyq=.5/(t(2)-t(1));
tmp=get(hfmin,'string');
fmin=str2double(tmp);
if(isnan(fmin) || fmin<0 || fmin>.5*fnyq)
    fmin=10;
    msgbox(['bad value for fmin, reset to ' num2str(fmin)])
    set(hfmin,'string',num2str(fmin))
end
tmp=get(hfmax,'string');
fmax=str2double(tmp);
if(isnan(fmax) || fmax<0 || fmax<fmin || fmax>fnyq)
    fmax=fmin+70;
    msgbox(['bad value for fmax, reset to ' num2str(fmax)])
    set(hfmin,'string',num2str(fmax))
end
switch thistarget 
    case 'rcs'
        rnew=butterband(rnew,t,fmin,fmax,4,0);
    case 'seismic'
        s=butterband(s,t,fmin,fmax,4,0);
    case 'both'
        rnew=butterband(rnew,t,fmin,fmax,4,0);
        s=butterband(s,t,fmin,fmax,4,0);
end
dobj.scurr=s;
dobj.rcurr=rnew;
setdataobject(dobj);%these settings are needed for on-the-fly cc updates

hup=findobj(hfig,'tag','shiftup');
haxes=get(hup,'userdata');
axes(haxes(1));
%get current zoom state
hkids=get(haxes(1),'children');
% if(~isempty(hkids))
%     xlnow=get(haxes(1),'xlim');
%     ylnow=get(haxes(1),'ylim');
% else
%     xlnow=[];
%     ylnow=[];
% end

[tg1,tg2]=getcorrelationgate;
rnew=rnew/max(abs(rnew));
s=s/max(abs(s));

%determine if plotting traces or envelopes
henvtrace=findobj(hfig,'tag','envtrace');
flag=get(henvtrace,'value');

figure(hfig);
if(isempty(hkids))
    if(flag==1)
        hh=plot([s rnew+1 r+1],t);flipy
        set(hh(3),'zdata',zeros(size(t))-1,'color',.5*ones(1,3));
    else
        hh=plot(env(s)-.25,t,-env(rnew)+1.25,t,-env(r)+1.25,t);flipy
        set(hh(3),'zdata',zeros(size(t))-1,'color',.5*ones(1,3));
    end
    savetracehandles(hh);
else
    hh=gettracehandles;
    if(flag==1)
        set(hh(1),'xdata',s,'ydata',t);
        set(hh(2),'xdata',rnew+1,'ydata',t);
        set(hh(3),'xdata',r+1,'ydata',t);
    else
        set(hh(1),'xdata',env(s)-.25,'ydata',t);
        set(hh(2),'xdata',-env(rnew)+1.25,'ydata',t);
        set(hh(3),'xdata',-env(r)+1.25,'ydata',t);
    end
end
xlim([-1 2])
ylabel('time(s)')
grid
set(gca,'xtick',[]);
% if(~isempty(xlnow))
%     xlim(xlnow);
%     ylim(ylnow);
% end
icc=near(t,tg1,tg2);
cc=sum(rnew(icc).*s(icc))/sqrt(sum(rnew(icc).^2)*sum(s(icc).^2));
title(['Zero lag cc =' num2str(cc)])

%restore anchors
% href=findobj(gca,'tag','ref');
% uu=get(href,'userdata');
% if(~isempty(uu) && isempty(hkids))
%     tanch=uu{2};
%     tmotion=uu{4};
%     [ha,hm]=plotanchors(t,tanch,tmotion);
%     uu{1}=ha;
%     uu{3}=hm;
% elseif(isempty(uu))
%     uu=cell(1,4);
% end
% set(hh(2),'userdata',uu);

%set context menus
hup=findobj(hfig,'tag','shiftup');
hdown=findobj(hfig,'tag','shiftdown');
happly=findobj(hfig,'tag','autoapply');
if(choiceflag==3)
    enable='off';
    %disable the shift buttons
    set([hup hdown happly],'enable','off');
else
    enable='on';
    %enable the shift buttons
    set([hup hdown happly],'enable','on');
end
hcntx=uicontextmenu;
uimenu(hcntx,'label','Drop anchor','callback',@setanchor,'enable',enable);
uimenu(hcntx,'label','Clear anchor','callback',@clearanchor,'enable',enable);
uimenu(hcntx,'label','Clear all anchors','callback',@clearallanchors,'enable',enable);
set(hh(2),'buttondownfcn',@refclick);
set(hh(2),'uicontextmenu',hcntx,'tag','ref');

%draw correlation gate
xl=xlim;
if(isempty(hkids))
    hl1=line(xl,[tg1 tg1],[1 1],'linestyle',':','color','g','buttondownfcn',...
        'align_ref(''dragline'')','tag','tg1','linewidth',2);
    set(hl1,'zdata',[10 10]);
    hl2=line(xl,[tg2 tg2],[1 1],'linestyle',':','color','g','buttondownfcn',...
        'align_ref(''dragline'')','tag','tg2','linewidth',2);
    set(hl2,'zdata',[10 10]);
else
    hl=findobj(gca,'tag','tg1');
    set(hl,'ydata',[tg1 tg1]);
    hl=findobj(gca,'tag','tg2');
    set(hl,'ydata',[tg2 tg2]);
end

timinglines;

plotccorr(t,s,rnew)
disableDA(hfig);

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotccorr(t,s,rnew)
hfig=gcf;
hup=findobj(hfig,'tag','shiftup');
haxes=get(hup,'userdata');
axes(haxes(2));
ud=haxes(2).UserData;
if(nargin==0)
    dobj=getdataobject;
    s=dobj.scurr;
    rnew=dobj.rcurr;
    t=dobj.t;
%     t=ud{2};
%     s=ud{3};
%     rnew=ud{4};
end
taumax=ud{1};
dt=t(2)-t(1);
nlags=round(taumax/dt);
[tg1,tg2]=getcorrelationgate;
% tg1=get(hpair(1),'ydata');
% tg2=get(hpair(2),'ydata');
icc=near(t,tg1(1),tg2(1));
mw=mwindow(length(icc));
ccf=ccorr(s(icc).*mw,rnew(icc).*mw,nlags);%computes r x s NOT s x r
ccfe=env(ccf);
% cce=ccorr(env(rnew),env(s),nlags);
tau=(t(2)-t(1))*(-nlags:nlags)';
axes(haxes(2))
hh=plot(ccf,tau,ccfe,tau);
set(hh(1),'tag','ccf');
set(hh(2),'tag','ccfe');
xmax=1;
xlim([-xmax xmax])
xtick(-1:.25:1)
set(haxes(2),'xticklabel',{'-1','','-.5','','0','','.5','','1'},'userdata',{taumax,t,s,rnew},...
    'ylim',[-taumax taumax])
xlabel('cc value');
ylabel('lag time (s)');
title('ccorr (blue) and env (red)')
hcntx=uicontextmenu;
uimenu(hcntx,'label','Expand correlation range','callback',@expandccrange);
uimenu(hcntx,'label','Reduce correlation range','callback',@reduceccrange);
haxes(2).UIContextMenu=hcntx;
grid
disableDA(hfig);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function expandccrange(~,~)
hax=gca;
ud=hax.UserData;
ud{1}=1.5*ud{1};
hax.UserData=ud;
plotccorr;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reduceccrange(~,~)
hax=gca;
ud=hax.UserData;
ud{1}=ud{1}/1.5;
hax.UserData=ud;
plotccorr;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tg1,tg2]=getcorrelationgate
hfig=gcf;
%check the green lines
hup=findobj(hfig,'tag','shiftup');
haxes=get(hup,'userdata');

h1=findobj(haxes(1),'tag','tg1');
h2=findobj(haxes(1),'tag','tg2');
%update the data objject
dobj=getdataobject;
if(isgraphics(h1))
    dobj.tg1=h1.YData(1);
    dobj.tg2=h2.YData(1);
    setdataobject(dobj);
end
tg1=dobj.tg1;
tg2=dobj.tg2;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setcorrelationgate(tg1,tg2)
hfig=gcf;
%find the green lines
hup=findobj(hfig,'tag','shiftup');
haxes=get(hup,'userdata');

h1=findobj(haxes(1),'tag','tg1');
h2=findobj(haxes(1),'tag','tg2');

set(h1,'ydata',[tg1 tg1]);
set(h2,'ydata',[tg2 tg2]);
%update the data objject
dobj=getdataobject;
if(isgraphics(h1))
    dobj.tg1=tg1;
    dobj.tg2=tg2;
    setdataobject(dobj);
end
plotccorr(dobj.t,dobj.scurr,dobj.rcurr);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dobj=getdataobject
hbut=findobj(gcf,'tag','shiftdown');
dobj=get(hbut,'userdata');
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setdataobject(dobj)
hbut=findobj(gcf,'tag','shiftdown');
set(hbut,'userdata',dobj);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setanchor(~,~)
href=findobj(gcf,'tag','ref');
pt=get(gca,'currentpoint');

tclick=pt(1,2);
t=get(href,'ydata');
%rs=get(href,'xdata');
% iclick=near(t,tclick);
% hh=line(1,t(iclick(1)),'linestyle','none','marker','o','color','k','markersize',10);
ha=plotanchors(t,tclick);
uu=get(href,'userdata');
if(isempty(uu))
    uu{1}=ha;
    uu{2}=tclick;
    uu{3}=[];
    uu{4}=[];
else
    uu{1}=[uu{1} ha];
    uu{2}=[uu{2} tclick];
end
set(href,'userdata',uu)
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clearanchor(~,~)
href=findobj(gcf,'tag','ref');
pt=get(gca,'currentpoint');
tclick=pt(1,2);
uu=get(href,'userdata');
if(isempty(uu))
    return
end
tanch=uu{2};
hh=uu{1};
ind=near(tanch,tclick);
delete(hh(ind));
hh(ind)=[];
tanch(ind)=[];
uu={hh tanch uu{3} uu{4}};
set(href,'userdata',uu)
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clearallanchors(~,~)
href=findobj(gcf,'tag','ref');
uu=get(href,'userdata');
if(isempty(uu))
    return;
end
if(isgraphics(uu{1}))
    delete(uu{1});
end
if(isgraphics(uu{3}))
    delete(uu{3})
end
set(href,'userdata',cell(1,4))
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refclick(~,~)
button=get(gcf,'selectiontype');
if(~strcmp(button,'normal'))
    return;
end
%set the motion point
href=findobj(gcf,'tag','ref');
%rs=get(href,'xdata');
t=get(href,'ydata');
pt=get(gca,'currentpoint');
tclick=pt(1,2);
uu=get(href,'userdata');
if(length(uu)>2)
    if(iscell(uu))
        if(~isgraphics(uu{3}))
            delete(uu{3});
        end
    end
end
[ha,hm]=plotanchors(t,[],tclick); %#ok<ASGLU>
uu{3}=hm;
uu{4}=tclick;
set(href,'userdata',uu);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ha,hm]=plotanchors(t,tanch,tmotion)
ha=zeros(1,length(tanch));
for k=1:length(ha)
    ianch=near(t,tanch(k));
    ha(k)=line(1,t(ianch),'linestyle','none','marker','o','color','k','markersize',10);
end
if(nargin>2 && ~isempty(tmotion))
    im=near(t,tmotion);
    hm=line(1,t(im),'linestyle','none','marker','s','color','k','markersize',18);
else
    hm=[];
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plottimeshifts
hfig=gcf;
hup=findobj(hfig,'tag','shiftup');
haxes=get(hup,'userdata');
haxe=haxes(3);
axes(haxe)
dobj=getdataobject;
str=dobj.str;
t=dobj.t;
dt=(str(:,2)-str(:,1))*1000;
plot(dt,str(:,1));
set(gca,'ydir','reverse')
small=.000001;
if(sum(abs(dt))<small)
    xlim([-10 10]);
end
if(sum(abs(diff(dt)))<small)
   dtm=mean(dt);
   xlim([dtm-10 dtm+10]);
end
ylim([t(1) t(end)])
set(gca,'yticklabel',[])
xlabel('milliseconds');
title('total shifts')
set(haxe,'tag','timeshiftaxes');
timinglines;
%check xticks and make sure there are at least 3
xtic=get(gca,'xtick');
if((xtic(end)-xtic(1))<10)
    x1=floor(xtic(1)/10)*10;
    x2=ceil(xtic(end)/10)*10;
    xtic=[x1 x2];
end
if(length(xtic)<3)
    xl=xlim;
    dxl=diff(xlim);
    xlim([xl(1)-.1*dxl xl(2)+.1*dxl]);
    set(gca,'xtick',[xtic(1) .5*sum(xtic) xtic(2)]);
end
set(gca,'xgrid','on')
disableDA(gcf);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function returnref(source,~)
global ALIGN_REF_RNEW ALIGN_REF_STR
uu=get(source,'userdata');
cb=uu{1};
hcallingfig=uu{3};

dobj=getdataobject;
ALIGN_REF_RNEW=dobj.rnew;
ALIGN_REF_STR=dobj.str;%column 1 is original time and column 2 is new times after shift
figure(hcallingfig)
eval(cb);
return;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function envtrace(~,~)
dobj=getdataobject;
s=dobj.s;
rnew=dobj.rnew;
t=dobj.t;
plottraces(t,s,rnew)
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dispchoice(~,~)
hchoice=findobj(gcf,'tag','dispchoice');
choiceflag=get(hchoice,'value');
if(choiceflag==4)
    yesnoinit('align_ref(''revertrcs'')',...
        'Are you sure you wish to revert to the original reflectivty? All changes will be lost.');
    return
end
dobj=getdataobject;
s=dobj.s;
rnew=dobj.rnew;
t=dobj.t;
plottraces(t,s,rnew)
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timinglines(~,~)
hup=findobj(gcf,'tag','shiftup');
haxes=get(hup,'userdata');
htl=findobj(gcf,'tag','timinglines');
tls=get(htl,'string');
itl=get(htl,'value');
tlinc=str2double(tls{itl});
dobj=getdataobject;
t=dobj.t;
y0=ceil(t(1)/tlinc)*tlinc;
y1=floor(t(end)/tlinc)*tlinc;
%seismic axes
axes(haxes(1));
ytick(y0:tlinc:y1)
set(haxes(1),'ygrid','on');
%timeshift axes
axes(haxes(3));
ytick(y0:tlinc:y1)
set(haxes(3),'ygrid','on');
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function undoredo(source,~)
hundoredo=source;
udat=get(hundoredo,'userdata');%should be rnew, tr_lims, str, anchorinfo of previous or next state
if(isempty(udat))
    return;
end
rnew=udat{1};
tr_lims=udat{2};%the previous correlation gate to be installed
str=udat{3};
anchorinfo=udat{4};
dobj=getdataobject;
%get present anchor info
href=findobj(gcf,'tag','ref');
anchnow=get(href,'userdata');
%save current state
[tr1,tr2]=getcorrelationgate;
udat{1}=dobj.rnew;
udat{2}=[tr1 tr2];
udat{3}=dobj.str;
udat{4}=anchnow;
set(hundoredo,'userdata',udat);
%install new state
setcorrelationgate(tr_lims(1),tr_lims(2));
dobj.rnew=rnew;
% dobj.tr1=tr_lims(1);
% dobj.tr2=tr_lims(2);
dobj.str=str;
set(href,'userdata',anchorinfo);
setdataobject(dobj);
%shift application point
if(~isempty(anchorinfo))
    if(isgraphics(anchorinfo{3}))
        set(anchorinfo{3},'ydata',anchorinfo{4});
    end
end
%replot
plottraces(dobj.t,dobj.s,dobj.rnew)
plottimeshifts

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enableundoredo
dobj=getdataobject;
href=findobj(gcf,'tag','ref');
anchnow=get(href,'userdata');
rnew=dobj.rnew;
tr_lims=[dobj.tr1 dobj.tr2];
str=dobj.str;
udat={rnew tr_lims str anchnow};
hundoredo=findobj(gcf,'tag','undoredo');
set(hundoredo,'userdata',udat);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savetracehandles(hh)
henvtrace=findobj(gcf,'tag','envtrace');
set(henvtrace,'userdata',hh);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hh=gettracehandles
henvtrace=findobj(gcf,'tag','envtrace');
hh=get(henvtrace,'userdata');
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savesegy(~,~)
[filename,pathname]=uiputfile('*.segy','Choose the outpput file','aligned_ref.segy');
if(filename==0)
    return;
end
dobj=getdataobject;
rnew=dobj.rnew;
rold=dobj.r;
t=dobj.t;
tr=dobj.tr;
ind=near(t,tr(1),tr(end));
r=zeros(size(t));
r(ind)=rold;
str=dobj.str;
tshifts=str(:,2)-str(:,1);
dt=t(2)-t(1);
dataout=[rnew,r,tshifts];
altwritesegy([pathname filename],dataout,dt);
msgbox(['Three traces written to "' [pathname filename] '". Trace 1 is the adjusted reflectivity,'...
    ' trace 2 is the original reflectivity, and trace 3 contains the time shifts required '...
    'to compute the adjusted from the original.'],'SEGY output');

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveexcel(~,~)
[filename,pathname]=uiputfile('*.xls','Choose the outpput file','aligned_ref.xls');
if(filename==0)
    return;
end
dobj=getdataobject;
rnew=dobj.rnew;
rold=dobj.r;
t=dobj.t;
tr=dobj.tr;
ind=near(t,tr(1),tr(end));
r=zeros(size(t));
r(ind)=rold;
str=dobj.str;
tshifts=str(:,2)-str(:,1);
dataout=[rnew,r,t,tshifts];
xlswrite([pathname filename],dataout);
msgbox(['Four traces written to "' [pathname filename] '". Trace 1 is the adjusted reflectivity,'...
    ' trace 2 is the original reflectivity, trace 3 is the time vector for the reflectivities, '...
    'and trace 4 contains the time shifts required '...
    'to compute the adjusted from the original.'],'SEGY output');

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str3=combine_stretches(str1,str2,tinc)
%
% str3=combine_stretches(str1,str2)
%
% str1 and str2 are two stretch functions where is is assumed that str2 happened after str1. A
% stretch function is a two-column matrix where the first column is start time and the second
% column is the end time. This defines the movement of samples in the stretch. It is important
% to make sure these functions are invertible (single-valued). The result from this function,
% str3, is a single stretch function that will accomplish the same effect as the combined
% str1->str2.
%
% str1 ... a two column matrix defining the first strtetch. Column 1 is the start times and
%       column 2 is the corresponding end times. Points between specified times are assumed to
%       have been mapped accoding to a linear interpolation.
% str2 ... similar to str2 except that this describes a second stretch after the first one.
%
% str3 ... a single stretch function, sampled at the increment tinc in column 1, that
%           accomplishes the same as the combined stretch.
%
% Procedure: Consider that str1 defines a mapping from t to t1 and str2 defines a mapping from
% t1 to t2. We wich to compute the corresponding mapping from t to t2. 
%       1) Column 2 of str1 defines irregular t1 times that map back to regular t times.
%           Column 1 of str2 defines regular t1 times that map to irregular t2 times. So, we
%           compute the t times that correpond to the t2 times by the interpolation
%           ta=interp1(str1(:,2),str1(:,1),str2(:,1));
%       2) The times ta from step 1 map directly to str2(:,2) which is t2 and are thus a t->t2
%           map. However, the ta are irregular so the second step is to interpolate a regular set
%           at the sample rate tinc. To ensure no loss of information, tinc should normally be the
%           sample rate of the traces.


ta=interp1(str1(:,2),str1(:,1),str2(:,1),'linear','extrap');

tmin=min(str1(:,1));
tmax=max(str1(:,1));
t=tmin:tinc:tmax;

%t2=interpextrap(ta,str2(:,2),t,1);
t2=interp1(ta,str2(:,2),t,'linear','extrap');

str3=[t(:) t2(:)];
end
%% %%%%%%%%%%%%%%%%%%%%%%
function rnew=make_new_rcs(t,delt,I,tz)
% t ... seismic time coordinate vector. The new rcs will fit inside
% delt ... desired time shifts. Same size vector as t
% I ... impedance from well at well sample rate
% tz ... original time coordinates for I as defined by original log
% 
dt=t(2)-t(1);
deltz=interp1(t,delt,tz);%interpolate shifts to well sampling
rnew=zeros(size(t));
[tmpr,tr]=imp2rcs_t(I,tz+deltz,dt);
%tmpr will usually be smaller than rnew. tr tells us the times to map tmpr to
t1=max([t(1) tr(1)]);%in case the shift moves samples before t(1)
tN=min([tr(end) t(end)]);%in case the shift moves samples after t(end)
indr=near(tr,t1,tN);
ind=near(t,t1,tN);
rnew(ind)=tmpr(indr);
end
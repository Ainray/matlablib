function ha=annotate(hobj,event,action,hpar) %#ok<INUSL>
%
% possible actions:
% 'textbox' ... uses annotation now working
% 'textaxes' ... uses "text" in axes, not needed, use textbox
% 'textarrow' ... uses annotation not implemented
% 'arrow' ... uses annotation not implemented
% 'delete'
%

hfig=gcf;
if(nargin<4)
    hpar=hfig;
end

if(~strcmp(hpar.Type,'figure')&&~strcmp(hpar.Type,'uipanel'))
    error('Parent must be a Figure or a Panel')
end

pta=currentpoint2annotationpoint(hpar);
x=pta(1);%in normalized coordinates
y=pta(2);%in normalized coordinates

% grid=20;%pixels defining invisible grid
% x=max([round(x/grid)*grid 1]);
% y=max([round(y/grid)*grid 1]);

if(strcmp(action,'textaxes'))
    %this makes everything an annotation
    action='textbox';
end

ha=[];
if(strcmp(action(1:4),'text'))
    fss=[8,10,12,16];%fontsizes
    fsstext='8|10|12|16';
    kols={'Red','Black','Blue','Green'};
    kolsa='Red|Black|Blue|Green';
    kolsrgb=[1 0 0;0 0 0;0 0 1;0 .5 0];
    fws={'Normal','Bold'};
    % put up dialog
    q={'Enter your comment:','Fontsize:','Text color:','Fontweight:','Box:'};
    a={' ',fsstext,kolsa,'Normal|Bold','Yes|No'};
    flags=[1,2,1,2,2];
    a=askthingsle('name','Provide textbox information','questions',q,'answers',a,'figurewidth',400,...
        'flags',flags);
    if(isempty(a))
        return;
    end
    str=a{1};
    fontsize=str2double(a{2});
    klr=a{3};
    fontweight=a{4};
    if(strcmp(klr,'Red'))
        kol='r';
    elseif strcmp(klr,'Black')
        kol='k';
    elseif strcmp(klr,'Blue')
        kol='b';
    elseif strcmp(klr,'Green')
        kol='g';
    end
    if(strcmp(a{5},'Yes'))
        ls='-';
    else
        ls='none';
    end
    
    hcm=uicontextmenu;
    hm=uimenu(hcm,'label','Fontsize');
    for k=1:length(fss)
       if(fss(k)==fontsize)
           chkd='on';
       else
           chkd='off';
       end
       uimenu(hm,'label',num2str(fss(k)),'checked',chkd,'callback',{@annotate,'fontsize'},...
           'userdata',fss(k));
    end
    hm=uimenu(hcm,'label','Fontweight');
    for k=1:length(fws)
       if(strcmp(fws{k},fontweight))
           chkd='on';
       else
           chkd='off';
       end
       uimenu(hm,'label',fws{k},'checked',chkd,'callback',{@annotate,'fontweight'});
    end
    hm=uimenu(hcm,'label','Color');
    for k=1:length(kols)
       if(strcmp(kols{k},klr))
           chkd='on';
       else
           chkd='off';
       end
       uimenu(hm,'label',kols{k},'checked',chkd,'callback',{@annotate,'color'},...
           'userdata',kolsrgb(k,:));
    end
    uimenu(hcm,'label','Edit','callback',{@annotate,'edit'})
    uimenu(hcm,'label','Delete','callback',{@annotate,'delete'})
end

if(strcmp(action,'textbox'))
%     str=[num2str(x,2) '-' num2str(y,2) ' ' str]; %used in debugging
    ha=annotation(hpar,'textbox',[x y .02 .02],'string',str,'FitBoxToText','on','tag','anno2',...
        'fontsize',fontsize,'fontweight',fontweight,'color',kol,'linestyle',ls,'contextmenu',hcm,...
        'verticalalignment','middle','margin',0,'buttondownfcn','draganno(''click'');');
    set(ha.Parent,'Tag','anno','handlevisibility','on');

elseif(strcmp(action,'textaxes'))
    hax=gca;
    pt=get(hax,'currentpoint');
    ha=text(pt(1,1),pt(1,2),str,'tag','anno','fontsize',fontsize,'fontweight',fontweight,...
        'color',kol,'linestyle',ls,'contextmenu',hcm,'verticalalignment','middle');...
elseif(strcmp(action,'fontsize'))
    hanno=gco;
    if(strcmp(hanno.Tag,'anno')||strcmp(hanno.Tag,'anno2'))
        hm=gcbo;
        fs=hm.UserData;
        hanno.FontSize=fs;
        hmp=hm.Parent;
        hkids=hmp.Children;
        for k=1:length(hkids)
           if(hkids(k).UserData==fs)
               hkids(k).Checked='on';
           else
               hkids(k).Checked='off';
           end 
        end
    end
elseif(strcmp(action,'fontweight'))
    hanno=gco;
    if(strcmp(hanno.Tag,'anno')||strcmp(hanno.Tag,'anno2'))
        hm=gcbo;
        fw=hm.Label;
        hanno.FontWeight=fw;
        hmp=hm.Parent;
        hkids=hmp.Children;
        for k=1:length(hkids)
           if(strcmp(hkids(k).Label,fw))
               hkids(k).Checked='on';
           else
               hkids(k).Checked='off';
           end 
        end
    end
elseif(strcmp(action,'color'))
    hanno=gco;
    if(strcmp(hanno.Tag,'anno')||strcmp(hanno.Tag,'anno2'))
        hm=gcbo;
        kol=hm.UserData;
        hanno.Color=kol;
        kol=hm.Label;
        hmp=hm.Parent;
        hkids=hmp.Children;
        for k=1:length(hkids)
           if(strcmp(hkids(k).Label,kol))
               hkids(k).Checked='on';
           else
               hkids(k).Checked='off';
           end 
        end
    end
elseif(strcmp(action,'delete'))
    hanno=gco;
    
    if(strcmp(hanno.Tag,'anno')||strcmp(hanno.Tag,'anno2'))
        delete(hanno);
    end
elseif(strcmp(action,'edit'))
    hanno=gco;
    comment=hanno.String;
    % put up dialog
    q={'Edit your comment:'};
    a={comment};
    flags=1;
    a=askthingsle('name','Edit textbox information','questions',q,'answers',a,'figurewidth',400,...
        'flags',flags);
    if(isempty(a))
        return;
    end
    comment=a{1};
    hanno.String=comment;
end
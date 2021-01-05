function ht=enTitle(titstr,varargin)
%enTitle: used by enhance. Installs a context menu on top of title to allow fontsize
% 
% ht=enTitle(titstr,varargin)
% ht= handle of title
% varargin ... passed directly to title
haxe=gca;

hfig=haxe.Parent;
type=hfig.Type;
while(~strcmp(type,'figure'))
    hfig=hfig.Parent;
    type=hfig.Type;
end

extraargs=[];
fs=[];
if(length(varargin)==1)
    fs=varargin{1};
elseif(iseven(length(varargin)))
    extraargs=varargin;
end
if(~isempty(extraargs))
    if(length(extraargs)==2)
        ht=title(titstr,extraargs{1},extraargs{2});
    elseif(length(extraargs)==4)
        ht=title(titstr,extraargs{1},extraargs{2},extraargs{3},extraargs{4});
    else
        ht=title(titstr,extraargs{1},extraargs{2},extraargs{3},extraargs{4},extraargs{5},extraargs{6});
    end
else
    if(~isempty(fs))
        ht=title(titstr,'fontsize',fs,'interpreter','none');
    else
        ht=title(titstr,'interpreter','none');
    end
end
fontops={'x4','x2','x1.5','x1.25','x1.11','x1','x0.9','x0.8','x0.67','x0.5','x0.25'};
hcm=uicontextmenu(hfig,'tag','fontsizes');
for k=1:length(fontops)
    uimenu(hcm,'label',fontops{k},'callback',@fontchange,'userdata',haxe);
end
uimenu(hcm,'label','ReTitle','callback',@retitle,'separator','on','userdata',haxe)
uimenu(hcm,'label','Two lines','callback',@twolines,'separator','on','userdata',haxe)
ht.UIContextMenu=hcm;
if(nargout<1)
    clear ht;
end
end

function fontchange(~,~)
hm=gcbo;
tag=hm.Label;
scalar=str2double(tag(2:end));
haxe=hm.UserData;
ht=haxe.Title;
fs=ht.UserData;
if(isempty(fs))
    fs=ht.FontSize;
    ht.UserData=fs;
end
ht.FontSize=scalar*fs;
end


function twolines(~,~)
hm=gcbo;
haxe=hm.UserData;
titstr=haxe.Title.String;
if(iscell(titstr))
    return;
end
ind=strfind(titstr,',');
N=length(titstr);
ii=near(ind,round(N/2));
str1=titstr(1:ind(ii(1)));
str2=titstr(ind(ii(1))+1:end);
haxe.Title.String={str1,str2};
end

function retitle(~,~)
hm=gcbo;
haxe=hm.UserData;
titstr=haxe.Title.String;
if(ischar(titstr))
    a=askthingsle('questions',{'New Title1','New Title2'},'answers',{titstr,''},'flags',[0 0]);
else
    a=askthingsle('questions',{'New Title1','New Title2'},'answers',titstr,'flags',[0 0]);
end
if(isempty(a))
    return;
else
    if(length(a)==1)
        haxe.Title.String=a{1};
    else
        if(isempty(a{2}))
            haxe.Title.String=a{1};
        else
            haxe.Title.String=a;
        end
%         hfig=haxe.Parent;
%         hfig.CurrentAxes=haxe;
%         title(a)
    end
end
    
end

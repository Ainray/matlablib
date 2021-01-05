function updatefigureuserdata(hmasterfig,hnewfig,winname)
%
% This is a generalized utility to update the userdata of two figures in a figure chain
% The setting is that master figure has just spawned a child figure. The master figure may itself be
% the spawn of a previous master. The user data of any figure should follow one of these patterns
%
% Pattern 1 (Used when the Figure is not part of a Figure chain):
%       ud = [conventional array of child figures] Normally thise will all be closed when the 
%               figure is closed.
%
% Pattern 2 (Used when the Figure is part of a Figure chain):
%       ud = {cell array of length 2} where ud{1} is a conventional array of child figures as in
%       Pattern 1, and ud{2} is the parent Figure of this Figure
%
% ENHANCE creates very large Figure chains. The chain is as described where the top of each chain is
% one of the data browsers (currently PI2D or PI3D). The data browsers have a diferent structure for
% their userdata which is ud={N henhance} where N is an integer dataset number and henhance is the
% handle of an Enhance main figure. If hmaster is determined to be a browser, then we don't update
% it.
%

if(~isgraphics(hmasterfig))
    error('Master figure handle is invalid')
end
if(~isgraphics(hnewfig))
    error('New figure handle is invalid')
end

udm=hmasterfig.UserData;
udnew=hnewfig.UserData;

%new figure
if(isempty(udnew))
    udnew={[], hmasterfig}; %this chains the new Figure to the master
elseif(length(udnew)==1)
    if(~iscell(udnew))
        if(~isgraphics(udnew))
            udnew={[] hmasterfig};%this chains the new Figure to the master
        else
            udnew={udnew hmasterfig};%this chains the new Figure to the master
        end
    else
        udnew={udnew{1}, hmasterfig}; %this chains the new Figure to the master
    end
else
    if(~iscell(udnew))
        udnew={udnew hmasterfig};
    else
        if(~isgraphics(udnew{1}))
            udnew{1}=[];
        end
    end
end

hnewfig.UserData=udnew;

%check if master is a browser
name=hmasterfig.Name;
if(contains(name,'PI'))
    hwin=findobj(hmasterfig,'tag','windows');
    currentwindows=get(hwin,'string');
    currentfigs=get(hwin,'userdata');
    if(~iscell(currentwindows))
        currentwindows={currentwindows};
    end
    nwin=length(currentwindows);
    if(nwin==1)
        if(strcmp(currentwindows{1},'None'))
            currentwindows{1}=winname;
            currentfigs(1)=hnewfig;
            nwin=0;
        else
            currentwindows{2}=winname;
            currentfigs(2)=hnewfig;
        end
    else
        currentwindows{nwin+1}=winname;
        currentfigs(nwin+1)=hnewfig;
    end
    set(hwin,'string',currentwindows,'value',nwin+1,'userdata',currentfigs)
    return;
end

%master figure
if(isempty(udm))
    udm=hnewfig; %here the master is independent
elseif(length(udm)==1)
    if(~iscell(udm))
        udm=[udm hnewfig]; %here the master is independent
    else
        %don't want a cell array of handles,just a regular array
        udm=[udm{1} hnewfig]; %here the master is independent
    end
else
    if(~iscell(udm))
        %regular array of child figures
        udm=[udm hnewfig]; %here the master is independent
    else
        %this is where the master figure is part of a Figure chain
        %here the first element of the cell array is a regular array of child figures
        %the second element should be the parent figure of hmasterfig
        if(length(udm{1})==1 && udm{1}==-999.25)
            udm{1}=hnewfig;
        else
            udm{1}=[udm{1} hnewfig]; 
        end
    end
end

hmasterfig.UserData=udm;
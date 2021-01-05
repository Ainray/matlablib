function setlims(hobj,event,action)

hfig=gcf;
hax=gca;

if(strcmp(action,'x'))
    xl=xlim;
    q={'Minimum X','Maximum X','Automatic?'};
    a={num2str(xl(1)),num2str(xl(2)),'Yes|No'};
    flags=[1,1,2];
    a=askthingsle('name','Provide X Limits','questions',q,'answers',a,...
        'flags',flags);
    if(isempty(a))
        return;
    end
    x1=str2double(a{1});
    if(isnan(x1))
        return;
    end
    x2=str2double(a{2});
    if(isnan(x2))
        return;
    end
    if(x1>=x2)
        return;
    end
    auto=a{3};
    
    if(strcmp(auto,'Yes'))
        hax.XLimMode='auto';
        return;
    end
    
    xlim([x1 x2]);
elseif(strcmp(action,'y'))
    yl=ylim;
    q={'Minimum Y','Maximum Y','Automatic?'};
    a={num2str(yl(1)),num2str(yl(2)),'Yes|No'};
    flags=[1,1,2];
    a=askthingsle('name','Provide Y Limits','questions',q,'answers',a,...
        'flags',flags);
    if(isempty(a))
        return;
    end
    y1=str2double(a{1});
    if(isnan(y1))
        return;
    end
    y2=str2double(a{2});
    if(isnan(y2))
        return;
    end
    if(y1>=y2)
        return;
    end
    auto=a{3};
    
    if(strcmp(auto,'Yes'))
        hax.YLimMode='auto';
        return;
    end
    
    ylim([y1 y2]);
end
    
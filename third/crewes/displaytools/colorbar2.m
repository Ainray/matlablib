function colorbar2(haxe,state)
%COLORBAR2 is like Matlab's colorbar except that the axes is not resized to accomodate the colorbar.
%Instead the colorbar is placed outside the axes.
% examples
% colorbar2 ... turns on a colorbar for the current axes
% colorbar2(hax) ... turns on a colorbar for the axes hax
% colorbar(hax,'off') ... turns off the colorbar for axes hax
%

if(nargin==1)
    if(ischar(haxe))
        haxe=gca;
        state=haxe;
    else
        state='on';
    end
end

posax=get(haxe,'position');



if(strcmp(state,'on'))
    hcb=colorbar(haxe);
    posax2=get(haxe,'position');
    del=posax(3)-posax2(3);
    poscb=get(hcb,'position');
    set(haxe,'position',posax);
    set(hcb,'position',[poscb(1)+del poscb(2:4)])
else
    colorbar(haxe,state);
end


function customizetoolbar(hfig,rotate)
% Used only for enhance and related tools

if(nargin<2)
    rotate=0;
end

a=findall(hfig);
for k=1:length(a)
    if(strcmp(a(k).Type,'uipushtool'))
        a(k).Visible='off';
    elseif(strcmp(a(k).Type,'uitogglesplittool'))
        a(k).Visible='off';
    elseif(strcmp(a(k).Type,'uitoggletool'))
        if(rotate==0)
            if(~strcmp(a(k).TooltipString,'Zoom In')&&~strcmp(a(k).TooltipString,'Zoom Out'))
                a(k).Visible='off';
            end
            if(strcmp(a(k).TooltipString,'Zoom In')||strcmp(a(k).TooltipString,'Zoom Out'))
                a(k).Visible='on';
            end
        else
            if(~strcmp(a(k).TooltipString,'Zoom In')&&~strcmp(a(k).TooltipString,'Zoom Out')&&~strcmp(a(k).TooltipString,'Rotate 3D'))
                a(k).Visible='off';
            end
        end
    end
end

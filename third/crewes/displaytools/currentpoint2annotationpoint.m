function pta=currentpoint2annotationpoint(hpan)
%
% We want to place annotation in the panel or figure whose handle is provided as hpan. We assume that
% the desired location of the annotation is at the figure's current point which was set by mouse
% click. This function converts the figure's current point to normalized coordinates in hpan.
%

if(~strcmp(hpan.Type,'figure')&&~strcmp(hpan.Type,'uipanel')&&~strcmp(hpan.Type,'uitab'))
   error('hpan must be either a figure, a panel, or a tab') 
end


%find the figure
hpar=hpan.Parent;
if(strcmp(hpar.Type,'root'))
    %this means hpan is actually a figure
    hfig=hpan;
    level=0;
elseif(strcmp(hpar.Type,'figure'))
    %this means hpan is a panel whose parent is the figure
    hfig=hpar;
    level=1;
    hpanels={hpar};
else
    %this means we are in a panel whose parent is also a panel. We need to continue upward to find
    %the figure
    
    level=1;
    hpanels{level}=hpan;
    while ~strcmp(hpar.Type,'figure')
        level=level+1;
        hpanels{level}=hpar;
        hpar=hpar.Parent;
        
    end
    hfig=hpar;
end

switch level
    case 0
        %trivial case where hpan is actually the figure
        U=hfig.Units;
        hfig.Units='normalized';
        pta=hfig.CurrentPoint;
        hfig.Units=U;
    case 1
        %hpan is the child of the figure
        %first get the current point of the Figure in normalized coords
        U=hfig.Units;
        hfig.Units='normalized';
        pt=hfig.CurrentPoint;
        hfig.Units=U;
        x=pt(1,1);
        y=pt(1,2);
        %Now get the position of the panel in normalized coordinates
        U=hpan.Units;
        hpan.Units='normalized';
        pos=hpan.Position;
        hpan.Units=U;
        x0=pos(1);%x coord of lower left corner of panel in normalized Figure coords 
        x1=pos(1)+pos(3);%x coord of lower right corner of panel in normalized Figure coords
        xa=(x-x0)/(x1-x0);%x coord of current point in normalized panel coordinates
        y0=pos(2);%y coord of lower left corner of panel in normalized Figure coords 
        y1=pos(2)+pos(4);%y coord of upper left corner of panel in normalized Figure coords
        ya=(y-y0)/(y1-y0);%ycoord of current point in normalized panel coordinates
        pta=[xa,ya];
    case 2
        %hpan is the child of a panel whose parent is a figure. The annotation is in a panel which
        %itself is in a panel which is in a Figure
        %first get the current point of the Figure in normalized coords
        U=hfig.Units;
        hfig.Units='normalized';
        pt=hfig.CurrentPoint;
        hfig.Units=U;
        x=pt(1,1);
        y=pt(1,2);
        %Now get the position of the outer panel in normalized coordinates
        hpan2=hpanels{2};
        U=hpan2.Units;
        hpan2.Units='normalized';
        pos=hpan2.Position;
        hpan2.Units=U;
        x0=pos(1);%x coord of lower left corner of outer panel in normalized Figure coords 
        x1=pos(1)+pos(3);%x coord of lower right corner of outer panel in normalized Figure coords
        xa2=(x-x0)/(x1-x0);%x coord of current point in normalized outer panel coordinates
        y0=pos(2);%y coord of lower left corner of outer panel in normalized Figure coords 
        y1=pos(2)+pos(4);%y coord of upper left corner of outer panel in normalized Figure coords
        ya2=(y-y0)/(y1-y0);%ycoord of current point in normalized outer panel coordinates
        %now move to inner panel
        hpan1=hpanels{1};
        U=hpan1.Units;
        hpan1.Units='normalized';
        pos=hpan1.Position;
        hpan1.Units=U;
        x0=pos(1);%x coord of lower left corner of inner panel in normalized outer panel coords 
        x1=pos(1)+pos(3);%x coord of lower right corner of inner panel in normalized outer panel coords 
        xa=(xa2-x0)/(x1-x0);%x coord of current point in normalized inner panel coordinates
        y0=pos(2);%y coord of lower left corner of inner panel in normalized outer panel coords  
        y1=pos(2)+pos(4);%y coord of upper left corner of inner panel in normalized outer panel coords 
        ya=(ya2-y0)/(y1-y0);%ycoord of current point in normalized inner panel coordinates
        pta=[xa,ya];
        
    otherwise
        error('General case not done')
end
    
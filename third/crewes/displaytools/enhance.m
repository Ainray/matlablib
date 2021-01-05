function  argout=enhance(action,arg2)
%
% dummy enhance for CREWES displaytools
%

if(strcmp(action,'getcolormap'))
    argout={'graygold',0};
elseif(strcmp(action,'getdefaultcolormap'))
    %this is called by an external tool to get the default colormap for a purpose
    % it is returned as a length 2 cell, the first entry being the name and the second a flag 
    % (0 or 1) saying if the colormap is flipped or not
    % calling syntax: argout=enhance('getdefaultcolormap',arg2)
    % where arg2 is a string, one of 'sections','timeslices','frequencies','ampspectra','phsspectra'
    request=arg2;%a string like 'sections' or 'timeslices'
    
        %happens if no enhance is running
        if(strcmp(request,'sections'))
            argout={'graygold',0};
        elseif(strcmp(request,'timeslices'))
            argout={'bluebrown',0};
        elseif(strcmp(request,'ampspectra'))
            argout={'blueblack',1};
        elseif(strcmp(request,'phsspectra'))
            argout={'seisclrs',0};
        elseif(strcmp(request,'frequencies'))
            argout={'jet',0};
        else
            argout={'seisclrs',0};
        end
        return
    
elseif(strcmp(action,'getcolormaplist'))
    %this returns the complete list of available colormaps
    argout=listcolormaps;
    return
end
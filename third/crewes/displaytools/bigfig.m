function p=bigfig(figno)
%BIGFIG enlarges a figure to an optimal size for a slide
% bigfig(figno)
%
% figno is the handle of the figure to be enlarged
% figno defaults to gcf
%
% Normally, BIGFIG enlarges the figure to half the height and half the
% width of your screen. However, you can control this behavior by defining
% some globals BIGFIG_X BIGFIG_Y BIGFIG_WIDTH and BIGFIG_HEIGHT. In order,
% these are the x and y coordiates of the lower left corner and the width
% and height of the figure after enlargement. Specify them in pixels. They
% default to 1,1,screen width and screen height. A good place to define
% them is in your startup.m file. See sample_startup.m in the
% crewes\utilities for an example of a startup file. 
%
% G.F. Margrave, CREWES
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE

%
if(nargin<1)
    figno=gcf; 
    action='normal';
elseif(ischar(figno))
    action=figno;
else
    action='normal';
end
global BIGFIG_X BIGFIG_Y BIGFIG_WIDTH BIGFIG_HEIGHT
global BROWSER_X BROWSER_Y BROWSER_W BROWSER_H
global TOOL_X TOOL_Y TOOL_W TOOL_H BTEST
if(isempty(BTEST))
    BTEST=false;
end
scr=get(0,'screensize');
if(isdeployed || BTEST)
    xmid=scr(3)*.5;ymid=scr(4)*.5;
    name=get(figno,'name');
    type='tool';
    if(length(name)>1)
        if(strcmp(name(1:2),'PI'))
            type='browser';
        end
    end
    if(strcmp(type,'browser') )
        if(~isempty(BROWSER_W))
            w=BROWSER_W;
        else
            w=.8*scr(3);
        end
        if(~isempty(BROWSER_H))
            h=BROWSER_H;
        else
            h=.8*scr(3);
        end
        if(~isempty(BROWSER_X))
            x=BROWSER_X;
        else
            x=xmid-.5*w;
        end
        if(~isempty(BROWSER_Y))
            y=BROWSER_Y;
        else
            y=ymid-.5*h;
        end
    else
        if(~isempty(TOOL_W))
            w=TOOL_W;
        else
            w=.8*scr(3);
        end
        if(~isempty(TOOL_H))
            h=TOOL_H;
        else
            h=.8*scr(3);
        end
        if(~isempty(TOOL_X))
            x=TOOL_X;
        else
            x=xmid-.5*w;
        end
        if(~isempty(TOOL_Y))
            y=TOOL_Y;
        else
            y=ymid-.5*h;
        end
    end
%     if(scr(3)>1600)
%         w=1600;
%     else
%         w=.833*scr(3);
%     end
%     if(scr(4)>900)
%         h=900;
%     else
%         h=.833*scr(4);
%     end
%     x=scr(1)+.5*scr(3)-.5*w;
%     y=scr(2)+.5*scr(4)-.5*h;
    
else
    if(isempty(BIGFIG_X))
        x=scr(1);
    else
        x=BIGFIG_X;
    end
    if(isempty(BIGFIG_Y))
        y=scr(2);
    else
        y=BIGFIG_Y;
    end
    if(isempty(BIGFIG_WIDTH))
        w=round(7*scr(3)/8);
    else
        w=BIGFIG_WIDTH;
    end
    if(isempty(BIGFIG_HEIGHT))
        h=min([round(w*5/9) round(scr(4)*.9)]);
    else
        h=BIGFIG_HEIGHT;
    end
    
    if(x+w-1>=scr(3))
        w=scr(3)-x-100;
    end
    if(y+h-1>=.9*scr(4))
        h=.9*scr(4)-y-10;
    end
end

if(strcmp(action,'normal'))
    units=get(figno,'Units');
    set(figno,'Units','Pixels','position',[x y w h]);
    set(figno,'Units',units);
elseif(strcmp(action,'query'))
    p=[x y w h];
end
function draganno(action)
% draganno ... allows constrained dragging of annotation with the mouse
%
% draganno('click')
%
% draganno is designed to allow the user to click on an annotaation object in a
% figure window and drag it around. Behaviour is controlled by globals. The
% motion is 'free' in both x and y. To use this, set the 'buttondownfcn'
% of the line to call your code. Then in your callback, define the globals
% to get the desired behaviour and then your callback should call
% draganno('click'). When the drag is finished, you can have your code
% called again by providing the callback global.
%
%
% NOTE: This function uses the userdata of the line so you should not.
%
%
% G.F. Margrave, Margrave-Geo, 2016
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


if(strcmp(action,'click'))
    hanno=gco;
    hpar=hanno.Parent.Parent;%first parent is a dummy wrapper
    if(~strcmp(hanno.Type,'textboxshape'))
       return;
    end
    hfig=gcf;
    pt=get(hfig,'currentpoint');
    %convert pt to normalized coordinates of hpar
    U=hpar.Units;
    hpar.Units='pixels';
    pospar=hpar.Position;
    hpar.Units=U;
    p1x=pospar(1);p2x=p1x+pospar(3);
    p1y=pospar(2);p2y=p1y+pospar(4);
    pxn=(p1x-pt(1))/(p1x-p2x);%normalized x
    pyn=(p1y-pt(2))/(p1y-p2y);%normalized y
    %get shift between clicked point and anno position
    panno=hanno.Position;
    set(hanno,'userdata',[pxn-panno(1) pyn-panno(2)]);

    set(gcf,'windowbuttonmotionfcn','draganno(''move'')');
    set(gcf,'windowbuttonupfcn','draganno(''fini'')');
    return;
end
if(strcmp(action,'move'))
    hanno=gco;
    hpar=hanno.Parent.Parent;%first parent is a dummy wrapper
    hfig=gcf;
    pt2=get(hfig,'currentpoint');%new location
    %convert pt2 to normalized
    U=hpar.Units;
    hpar.Units='pixels';
    pospar=hpar.Position;
    hpar.Units=U;
    p1x=pospar(1);p2x=p1x+pospar(3);
    p1y=pospar(2);p2y=p1y+pospar(4);
    px2n=(p1x-pt2(1))/(p1x-p2x);%normalized x
    py2n=(p1y-pt2(2))/(p1y-p2y);%normalized y
    %motion
    pdisp=hanno.UserData;%displacement between clicked point and origin of anno
    panno=hanno.Position;
    hanno.Position=[px2n-pdisp(1) py2n-pdisp(2) panno(3:4)];
    
    return;
end

if(strcmp(action,'fini'))
    hanno=gco;
    hanno.UserData=[];
    set(gcf,'windowbuttondownfcn','');
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','');

    return;
end	
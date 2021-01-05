function ansfini=askthingsle(varargin)
% ASKTHINGSLE  Builds a dialog which queries user for answers to questions
%
% function ansfini=askthingsle(varargin)
%
% Example:
%  q = { 'How high is the moon (km)', 'Mission status' };
%  a = { num2str(384400),'Go|No go' };
%  a = askthingsle('name', 'Mission control asks', 'questions', q, 'answers', a);
%  moonheight = str2num(a{1});
%  missionstatus = a{2};
%  disp(['You said the moon height was: ', num2str(moonheight), ' km']);
%  disp(['You said the mission status is: ' missionstatus]);
%
% Arguments to askthingsle are supplied in property/value pairs.
%
% Property: 'questions'
%  Value required: cell array of question strings
%
%  Example:
%   questions = {'Age', 'Date of birth', 'Phone number'};
%   answers = askthingsle('questions', questions)
%
% Property: 'answers', 
%  Value required: cell array of default answers
%
%  Two formats are available, an editable box which is either blank 
%  or has some predefined (editable) answer or a popup box with 
%  multiple predefined uneditable answers.  
%  To make a popup menu of answers use '|' between possible options.
%  There must be as many answers as there are questions.
%
%  Example:
%   answers = {'Example answer' 'Blue|Black|Maroon' num2str(27.5)};
%   answers = askthingsle('answers', answers,...);
% 
% Property: 'flags'
%  Value required: array of flag values
%  If supplied there has to be one flag for every answer.  
%  A flag value of flag forces the user to place an answer in 
%  the desired editable box.  A flag value of 0 makes the question optional.
%  The flags may be set up as follows. For questions which are a popup menu
%  the flag value indicates which value is shown as the default response.
%  Example:
%   questions = { 'Required','Optional','Popup'};
%   answers = { 'love' ,'money', 'sad|angry|contented|overjoyed'};
%   flags=[1 0 3];  
%   askthingsle('questions',questions,'answers',answers','flags',flags)
%
% Property: 'title'
%  Value required: string with the title
%  The title is displayed as text at the top of the question
%  diaglog.  It may run onto multiple lines.
%
% Property: 'name'
%  Value required: name of the window
%  The window name is displayed in the window border. 
%  If your question is short, place it in the the 'name' rather
%  than in the 'title'.
%
% Property: 'tooltips'
%  Value required: cell array of tool tip strings
%  Tool tips string for each question.  There has to be as many tool
%  tip strings as there are questions.
%  Example:
%   tooltips = { 'Avoid values above 2','The boss like blue' };
%   q = { 'Table length (m)', 'Paint color' };
%   a = { '1.4' , 'red|green|yellow|blue|orange|white' };
%   askthingsle('questions',q,'answers',a,'tooltips',tooltips)
%
% Property 'figurewidth'
% Overrides automatic calculation of Figure width. Specify a value in pixels
%
% Property: 'masterfig'
%  Value required: handle of the master figure
%  The question dialog is "attached" to a master figure.  Not
%  normally required.
%
% NOTE1: If windowstyle is 'normal' askthingsle calls WinOnTop to ensure that
% the dialog window remains on top.
% NOTE2: When initialized, askthingsle defines the global ASKTHINGS whose value
% is the dialog window handle. When the dialog is dismissed this global is set
% to empty. This allows the calling program to determine if an askthingsle dialog
% has not been properly responded to. If ASKTHINGS is not empty, then there is
% an open dialog. The 'title' property of the ASKTHINGS figure can then be set
% to a message demanding a proper response.
%
% Return value: ansfini 
%  The answers are returned in cell format.  There are as many
%  answers as there are question.  Unanswered optional questions are
%  returned blank.  Cancel will return a blank cell.  Use isempty(ansfini)
%  to test for Cancel.
%       {'Example output' 'Black' ''}
%
% History
%  askthingsle is a replacement for the askthingsinit, askthings and
%  askthingsfini dialogs askthingsle only needs to be called once with the
%  desired questions, answers and flags unlike the old version which took
%  two seperate programs to run.
%
% Compatibility-mode invocation
%  For a while, askthingsle used different input arguments.  For this legacy
%  code, the input arguments are interpretted as such:
%   askthingsle(masterfig,qst,a,flags,titlestr,ttstr,windowstyle,name);
% 
%
% C.B. Harrison 2002
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
global ASKTHINGS
% If we have any figures at all, use gcf, otherwise use the root window
if isempty(get(0,'children'))
    masterfig = 0;  % 0  is the root window
else
    masterfig = gcf;
end
titlestr=[];
ttstr = [];
windowstyle = 'normal';
flags = [];
name = 'Please enter';
a = [];
qst = [];
figwidth=[];
dialogcolor = [212 208 200]/255; 


    if (nargin >= 1) && ~ischar(varargin{1}) 
        % operate in compatibility mode with old argument list
        % askthingsle(masterfig,qst,a,flags,titlestr,ttstr,windowstyle,name);
        masterfig = varargin{1};
        qst = varargin{2};
        a = varargin{3};
        flags = varargin{4};
        if nargin >=5
            titlestr = varargin{5};
            if nargin >= 6
                ttstr=varargin{6};
                if nargin >= 7
                    windowstyle = varargin{7};
                end
            end
        end
    else
        propList = varargin(1:2:end);
        valueList = varargin(2:2:end);
        for ii= 1:length(propList)
            switch(lower(propList{ii})) 
                case 'masterfig'
                    masterfig = valueList{ii};
                case 'questions'
                    qst = valueList{ii};
                case 'answers'
                    a = valueList{ii};
                case 'title'
                    titlestr = valueList{ii};
                case 'name'
                    name = valueList{ii};
                case {'tooltip','tooltips'}
                    ttstr = valueList{ii};
                case 'flags'
                    flags = valueList{ii};
                case 'windowstyle'
                    windowstyle = valueList{ii};
                case 'figurewidth'
                    figwidth = valueList{ii};
                otherwise
                    error(['Unknown property name: ' propList{ii}]);
            end
        end
    end

    if ~iscellstr(qst)
        error('"Questions" must be supplied as a cell array of strings');
    end

    if isempty(a) 
        a = cell(length(qst),1);
        % force it into a cell string
        for i=1:length(a)
            a{i} = '';
        end
    end
    
    if ~iscellstr(a)
        error('"Answers" must be supplied as a cell array of strings');
    end
    
    if isempty(flags)
        flags = ones(length(qst),1);
    end
    
    if isempty(ttstr)
        ttstr = cell(length(qst),1);
        for i=1:length(qst)
            ttstr{i} = '';
        end
    end

    if (length(qst)~=length(a)) || (length(qst) ~= length(flags))
        error('You must have the same number of Questions, Answers and Flags');
    end

    if ~isempty(ttstr) && length(ttstr)~= length(qst)
        error('You must have the same number of Tooltips as Questions');
    end

    if isempty(windowstyle)
        windowstyle = 'modal';
    elseif isnumeric(windowstyle)
        if windowstyle == 1
            windowstyle = 'modal';
        else
            windowstyle = 'normal';
        end
    end
    

    % find the maximum question or answer length
    qlen=-inf;
    for ii=1:length(qst)
        checkquestion=qst{ii};
        if(~ischar(checkquestion))
            error('Questions have to be strings');
        else
            nsize=length(checkquestion);
            if(nsize>=qlen)
                qlen=nsize;
            end
        end    
    end
    alen=-inf;
    for ii=1:size(a,2)
        checkans=a{ii};
        if(iscell(checkans))
            for jj=1:size(checkans,2)
                checkans2=checkans{jj};
                nsize=length(checkans2);
                if(nsize>=alen)
                    alen=nsize;
                end
            end
        else
            % checking for | to see what is the longest answer in series
            [ansout, ansleft]=strtok(checkans,'|');
            while ~isempty(ansleft)
                nsize=length(ansout);
                if(nsize>=alen)
                    alen=nsize;
                end
                [ansout, ansleft]=strtok(ansleft,'|'); %#ok<STTOK>
            end
            nsize=length(ansout);
            if(nsize>=alen)
                alen=nsize;
            end
        end
    end
    
    %build the dialog box and the questions
    hdial=figure('visible','on','menubar','none','numbertitle','off',...
        'name',name,...
        'closerequestfcn',@askthingsleCancel,...
        'resize','off',...
        'windowstyle',windowstyle,...
        'color', dialogcolor);
    %pos=get(hdial,'position');
    sep=1;
    %
    % assume 10 chars in 50 pixels
    %
    charpixel=8;
    qwidth=50*ceil(qlen/charpixel);
    fmltq=0;
    if(qwidth>=600)
        qwidth=600;
        %fmlq=2;
    end
    awidth=max([80*ceil(alen/charpixel) 100]);
    fmlta=0;
    if (awidth>=600)
        awidth=600;
        fmlta=2;
    end
    
    width=max([qwidth awidth]);
    % compute height of title string (allow long strings to wrap)
    titlen=50*ceil(length(titlestr)/9);
    factor=ceil(titlen/(2*(width+sep)));
    height=20;
    titheight=factor*height;
    figheight=(height+sep)*(size(qst,2)+1.4+factor); % 1.4 is for buttons at the bottom
    if(isempty(figwidth))
        figwidth=2*(width+sep);
        awidthtext=awidth;
    else
        awidthtext=figwidth-qwidth-sep;
    end
    ynow=figheight-titheight-.5;
    xnow=sep;
    if titheight > 0
      uicontrol('style','text','string',titlestr,...
        'position',[xnow ynow figwidth titheight],...
        'horizontalalignment','left', ...
        'backgroundcolor', dialogcolor);
    end
    hq=zeros(1,size(qst,2));ha=zeros(1,size(qst,2));
    ynow=ynow-sep-height;
    bgkol=[1 1 1];
%    uipanel('units','pixels','position',[0 1.2*height figwidth figheight ],...
%         'bordertype','beveledout','backgroundcolor',dialogcolor);
    for ii=1:size(qst,2)
        q=qst{ii};
        hq(ii)=uicontrol(...
            'style','text',...
            'string',deblank(q),...
            'position',[xnow,ynow-5,qwidth,height+factor*fmltq],...
            'tooltipstring',ttstr{ii},...
            'userdata',q,...
            'value',1,...
            'horizontalalignment','center', ...
            'backgroundcolor', dialogcolor);

        xnow=xnow+qwidth+sep;
        ind=strfind(a{ii},'|');
        %if(strcmp(blanks,a(k,:)))
        if( isempty(ind) )
            if(flags(ii))
                bg = bgkol;
            else
                bg = bgkol;
            end
            if flags(ii) < 0
                enable = 'off';
            else
                enable = 'on';
            end
            fg = [0 0 0 ];
            ha(ii)=uicontrol(...
                'style','edit',...
                'string', a{ii},...
                'position',[xnow,ynow,awidthtext,height+factor*fmlta],...
                'horizontalalignment','left', ...
                'foregroundcolor',fg,... 
                'backgroundcolor',bg,...
                'userdata',deblank(a{ii}),...
                'tooltipstring',ttstr{ii},...
                'value',1,...
                'enable',enable);
        else
            ind=find(abs(a{ii})==1, 1);
            if( isempty(ind) ); ind=length(a{ii})+1; end
            if(flags(ii)<1); flags(ii)=1; end
            ha(ii)=uicontrol(...
                'style','popupmenu',...
                'string', a{ii},...
                'horizontalalignment','center',...
                'position',[xnow,ynow,awidth,height+factor*fmlta],...
                'value',flags(ii),...
                'userdata',a{ii},...
                'tooltipstring',ttstr{ii},...
                'backgroundcolor',[1 1 1]);
        end
        xnow=sep;
        ynow=ynow-sep-height;
    end
    
    hdial.CurrentObject=ha(1);
    
    buttonwidth = min(60,width);
    
    % Finished all the questions, now present OK an Cancel buttons
    ynow = ynow - height*.24;
    uicontrol(...
        'style','pushbutton',...
        'string','OK',...
        'position', [figwidth/2-buttonwidth-sep ynow buttonwidth height],...
        'callback',@askthingsleDone,...
        'backgroundcolor',dialogcolor);
    
    %xnow=width+sep;
    uicontrol(...
        'style','pushbutton',...
        'string','Cancel',...
        'position',[figwidth/2+sep ynow buttonwidth height],...
        'callback',@askthingsleCancel,...
        'backgroundcolor',dialogcolor);
   
    
    % get the position of the calling figure.  Need to make sure that the
    % units acquired are pixels
    gcfunits=get(masterfig,'units');
    set(masterfig,'units','pixels');
    if masterfig ~= 0
        pospar=get(masterfig,'position');
    else
        pospar = [get(masterfig,'screensize') 0 0];
    end
    set(masterfig,'units',gcfunits); 
    %unitspar=get(hparent,'units');
    
    px=pospar(1)+pospar(3)/2-figwidth/2;
    py=pospar(2)+pospar(4)/2-figheight/2;
    posdial=[px py figwidth figheight];
    
    set(hdial,'position',posdial);
    set(hdial,'visible','on');
    
    uicontrol('style','text','visible','off','userdata',a);
    
    finalanswers={};
    set(hdial,'userdata',{ha flags masterfig finalanswers});
    if(strcmp(windowstyle,'normal'))
        WinOnTop(hdial,true);
    end

    ASKTHINGS=hdial; %#ok<NASGU>
    uiwait;
    
    if(isgraphics(hdial))
        dat=get(hdial,'userdata');
        ansfini=dat{4};
        delete(hdial);
        ASKTHINGS=[];
    else
        ansfini=[];
    end
%catch
%    ansfini={};
%    delete(gcf);
%    errordlg('Invalid Input Arguments');
%end

function askthingsleCancel(~, ~, ~)
% user just wants to quit
% dat=get(gcf,'userdata');
% dat{5}=[];
uiresume;
delete(gcf);

function askthingsleDone(~, ~, ~)
% preparing data to export according to user preference
% hbutton=gco;
dat=get(gcf,'userdata');
ha=dat{1};
flags=dat{2};
% mastfig=dat{3};
finalanswer=cell(1,size(ha,2));

for ii=1:size(ha,2)
    checkflag=flags(ii);
    checkans=get(ha(ii),'string');
    if(isempty(checkans))
    else
        checkans=checkans(get(ha(ii),'value'),:);
    end
    if(checkflag==1) && (isempty(checkans))
        msgbox('Please answer all questions or press Cancel.','Incomplete information','none');
%        set(hmsg,'string',stringinfo);
        return 
    end
    finalanswer{ii}=deblank(checkans);    
end
dat{4}=finalanswer;
set(gcf,'userdata',dat);
uiresume;
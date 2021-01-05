function sane(action,arg2)
% SANE: Seismic ANalysis Environment (3D)
%
% Just type SANE and the GUI will appear
%
% SANE establishes an analysis environment for 3D seismic datasets. There is currently no facility
% for 2D. SANE is meant to be used in an energy company environment where 3D seismic volumes must be
% compared, QC'd, and perhaps enhanced. To make effective use of SANE you should run this on a
% workstation with lots of RAM. SANE was developed on a computer with 128GB of RAM. It is suggested
% that your workstation should have at least 2 times the RAM of the size of the SEGY volumes that
% you wish to analyze. So, for eaxmple, if you have a 3D dataset that is 10GB as a SEGY file on
% disk, then you should have at least 20GB of RAM available. SANE allows you to read in one or more
% 3D volumes into a project. Its a good idea if the volumes are all somehow related or similar. For
% example maybe they are different processing of the same data. You load these into SANE using the
% "Read SEGY" option and then save the project. Reading SEGY is quite slow but once you save the
% project (as a Matlab binary) further reads are much faster. SANE saves your data internally in
% single precision because that reduces memory and that is how SEGY files are anyway. If your 3D
% dataset has a very irregular patch size, then forming the data into a 3D volume will require
% padding it with lots of zero traces and this can significantly increase memory usage. SANE allows
% you to control which datasets in the project are in memory and which are displayed at any one
% time. Thus it is quite possible to have many more datasets in a project than you can possibly
% display at any one time. Data display is done by sending the data to plotimage3D and you might
% want to check the help for that function. So each dataset you display is in a separate plotimage3D
% window and the windows can be "grouped" to cause them all to show the same view. Plotimage3D can
% show 2D slices of either inline, xline (crossline), or timeslice. In each view there are a number
% of analysis tools available and these are accessed by a right-click of the mouse directly on the
% image plot. Such a right-click brings up a "context menu" of available analysis tools. These tools
% just operate directly on the 2D image that is being displayed. SANE also offers a gradually
% expanding list of "tasks" that are accesible from the "Compute" menu that operate on an entire 3D
% volume and usually produces a same-size 3D volume. Examples are filtering and deconvolution.
%
% G.F. Margrave, CREWES, 2017
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

% To Do:
%
% 
% Plotimage3D needs to be able to send signals to sane. For example when grouping changes
%   - Done: SANE sets the 'tag' of the PI3D figure to 'fromsane' and the userdata to {idata hsane}
%   where idata is the dataset number and hsane is the handle of the SANE window.
%   - PI3D then calls SANE for: group and ungroup: sane('pi3d:group',{idata hsane}). This causes
%   SANE to examine the globals and reset the group buttons as needed
%
% Need ability to edit time shifts and to apply coordinate scalars
%
% It would be nice to be able to write out a subset.
%
% Need a way to edit the project structure fields like dx, dy, tshift, filenames, 
%
% Need a way to edit the SEGY text header
% 
% 

% How to edit a SANE Project dataset. SANE project datasets are saved as .mat files with just two
% variables visible at the top level: proj and datasets. proj is a structure with lots of fields and
% datasets is a cell array with the 3D datasets stored in it. The easiest way to edit a dataset from
% the command line is to use the "matfile" facility. If you are unfamiliar with matfile then you
% should read the online help. Suppose saneproject.mat is the name of a SANE project file that needs
% to be edited. Then open it like this
% >> m=matfile('saneproject.mat','writable',true);
% This command does not read the objects in the file, it just opens them. To read the project
% structure into memory do
% >> proj=m.proj
% where I've left off the semicolon to list the structure fields. If you choose to edit this
% structure, beware that there are lots of implied logical connections between the fields and making
% a change in one field can require a corresponding change in another in order that SANE will
% understand. Also, never change the field names. Notice that the field 'filenames' is a cell array
% with a certain length, there is one filename for each 3D survey in the project. Most, but not all,
% of the fields in proj must also have this same length. So, if you make an edit that changes a
% field length, then you must change all of the other fields in the same way.  Also notice that most
% of the fields are cell arrays but some are ordinary arrays. Be sure to preserve this. There is a
% field in proj called 'datasets' that is a cell array to put the seismic datasets in. When you read
% proj from disk like is done here, this will always be empty and the seismic volumes are all in the
% datasets cell array on disk. The field 'isloaded' is an ordinary array of 1 or 0, for each
% dataset. If 1, then the dataset is read from disk into proj.datasets when the project is first
% opened. The isloaded field reflects the load status of things when the project was last saved.
% SANE reads this upon opening the project and puts up a dialog allowing you to decide what is to be
% loaded and what is to be displayed (there is also an isdisplayed field). When a dataset is
% deleted, the various fields are not shortened in length, rather, the corresponding entry in
% datasets is set to null and the fields 'isdeleted' and 'deletedondisk' are set to indicate
% deletion. To read a dataset from the datasets cell array on disk you must know the number of the
% dataset. This is just the integer number of the dataset in the cell array. In determining this, be
% sure to allow for any deleted datasets by checking the isdeleted field. To read in dataset number
% 3 the two-step syntax is
% >> cdat=m.datasets(1,3);
% >> seis=cdat{1};
% The first line here uses regular round brackets even though we are reading from a cell array. This
% is a 'feature' of the matfile behaviour. Note also that you must use two index addressing like
% (1,3) and not simply (3). This line reads the dataset into a cell array of length 1 and the second
% line is required to unpack the dataset into a conventional 3D matrix. This matrix is stored in the
% order expected by plotimage3D which is with time as dimension 1, xline as dimension 2, and inline
% as dimension3. If you wish to write a new dataset into location 3, the syntax is
% >> m.datasets(1,3)={seis};
% Where seis is a 3D volume of the proper size. If you changed the dimensions of this volume in the
% course of altering it, then you must also update the various coordinate fields that have the same
% dimensions. You may also encounter problems if you try to output a SEGY volume from SANE after
% changing the dimensions. This is because SANE remembers the SEGY headers from the original read
% and tries to reuse them. Deletion of a dataset is similar
% >> m.datasets(1,3)={[]};
% which must be followed with
% >> proj.isdeleted(3)=1;
% >> proj.deletedondisk(3)=1;
% >> m.proj=proj;
% Deletion is the one exception to changing the size of a dataset that does not require
% corresponding changes in the coordinate arrays.

% plan for tasks. There will be two types of tasks, those accesible via the context menu of the
% current view in plotimage3D and those accessible by the tasks menu in Sane. I discuss the latter
% here and the former in plotimage. Sane tasks will be applied to entire datasets with the
% subsequent option of saving the result in the project, writing to segy, or discarding. Since many
% tasks in Sane will be similar to those in plotimage3d, there needs to be a mechanism to share
% parmsets. Sane tasks will execute via a callback to an action in sane. Each callback needs to do:
% (1) identify the input dataset, (2) identify the parameters, (3) run the task, and (4) determine
% the disposition of the output.

% To implement a new SANE task, do the following
% 1) Add a new entry to the Compute menu. The tag of this menu will be the name of the task.
% 2) Create a parmset function. This is an internal-to-SANE function that does two things (i) it
% defines the parameters needed to run the task and (ii) it checks a parmset edited by the user for
% validity. See parmsetfilter and parmsetdecon (in this file) for examples.
% 3) Create a new case in the switch in the internal function getparmset (in this file). This new
% case must call the parmset function created in step 2.
% 4) Create a new case in the switch in 'starttask' action for the new task. This function calls the
% internal function sanetask (in this file) that puts up a GUI showing the current parameters in the
% parmset and their current values. The user then changes them and pushes the done button which
% calls the action 'dotask'. Internal function sanetask is meant to automatically adapt to parmsets
% of different lengths and types and (hopefully) will not require modification. 
% 5) In the 'dotask' action there are two switch's that need new cases. The first is the switch
% statment that calls the appropriate parmset function to check the current parmset for validity.
% The second is the switch that actually does the computation. This switch will generally need more
% work and thought than the others.
%
% NOTE: Initially, there are no parmsets saved in a project and so the parmset presented to the
% user is the default one. However, once a task is run, the parmset is saved in the proj structure.
% The next time that same task is run, then the starting parmset is the saved one.
%
% NOTE: At present all of the tasks have two things in common: (i) They are either trace-by-trace
% operation or slice-by-slice. As such it is easy to put them in a loop and save the results in the
% input matrix. This is a great memory savings because otherwise a 3D matrix the same size as the
% input would be needed. This means that if a computation is partially complete, then the input
% matrix is part input and part output. For this reason, if a task is interrupted when partially
% done, the input dataset is unloaded from memory. Rerunning the task will therefore require a
% reload (which is automatic). (ii) They all have the same 4 options for dealing with the output
% dataset. The options are established in the internal function sanetask and are {'Save SEGY','Save
% SEGY and display','Replace input in project','Save in project as new'} . If these two behaviors
% are not appropriate, then more work will be required to implement the new task. The four output
% options are implemented in the action 'dotask' .


% SANE project structure fields
% name ... name of the project
% projfilename ... file name of the project
% projpath ... path of the project.
% filenames ... cell array of filenames for datasets
% paths ... cell array of paths for datasets
% datanames ... cell array of dataset names
% isloaded ... array of flags for loaded or not, one per dataset
% isdisplayed ... array of flags for displayed or not, one per dataset
% xcoord ... cell array of x (xline) coordinate vectors, will be empty if dataset not loaded.
% ycoord ... cell array of y (inline) coordinate vectors, will be empty if dataset not loaded.
% tcoord ... cell array of t (time or depth) coordinate vectors, will be empth if not loaded.
% datasets ... cell array of datasets as 3D matrices, will be empty if not loaded
% xcdp ... cell array of xcdp numbers, empty if not loaded
% ycdp ... cell array of ycdp numbers, empty if not loaded
% dx ... array of physical grid in x direction, will be empty if not loaded
% dy ... array of physical grid in x direction, will be empty if not loaded
% depth ... array of flags, 1 for depth, 0 for time
% texthdr ... cell array of text headers
% texthdrfmt ... cell array of text header formats
% segfmt ... cell array of seg trace formats (IBM, IEEE, etc)
% byteorder ... cell array of byte orders
% binhdr ... cell array of binary headers
% exthdr ... cell array of extended headers
% tracehdr ... cell array of trace headers
% bindef ... cell array of bindef, nan indicates default behaviour and should be passed to readsegy and writesegy as [];
% trcdef ... cell array of trcdef, nan indicates default behaviour and should be passed to readsegy and writesegy as [];
% segyrev ... ordinary array of segyrev. nan indicates default behaviour and should be passed to readsegy and writesegy as []; 
% kxline ... cell array of kxlineall values as returned from make3Dvol
% gui ... array of handles of the data panels showing name and status
% rspath ... last used path for reading segy
% wspath ... last used path for writing segy
% rmpath ... last used path for reading matlab
% wmpath ... last used path for writing matlab
% pifigures ... Cell array of plotimage3D figure handles. One for each dataset. Will be empty if not displayed.
% isdeleted ... array of flags signalling deleted or no
% isdeletedondisk ... array of flags signalling deleted on disk or not
% saveneeded ... array of flags indicating a dataset needs to be saved
% parmsets ... cell array of parmsets which are also cell arrays. A parmset holds parameters for 
%           functions like filters, decon, etc. Each parmset is a indefinite length cell array of
%           name value triplets. However the first entry is always a string giving the name of the
%           task for which the parmset applies. Thus a parmset always has length 3*nparms+1. A name
%           value triple consists of (1) parameter name, (2) parameter value, (3) tooltip string.
%           The latter being a hint or instruction. The parameter value is either a string or a cell
%           array. If the parameter is actually a number then it is read from the string with
%           str2double. If the parameter is a choice, then it is encoded as a cell array like this:
%           param={'choice1' 'choice2' 'choice3' 1}. The last entry is numeric and in this example
%           means that the default is choice1. A thirs option exists to accomodate a parameter that
%           is a vector of values such that the list of frequencies in specdecomp. In this case the
%           vector of values is provided as a string inside a cell. The values are listed in the
%           string either comma or space separated. Internal function getparmset is used to retrieve
%           a parmset by task name from the structure. In the event that no parmset is found it
%           returns the default parmset. Internal function setparmset stores a modified parmset in
%           the project structure, replacing any already existing parmset of the same name. Once a
%           parmset is retrieved, internal function getparm is used to retrieve a given parameter by
%           name from a parmset.
% xlineloc ... for each dataset, the header location of the xline number (in bytes)
% inlineloc ... for each dataset, the header location of the inline number (in bytes)
% horizons ... structure array of horizon structures, one for each dataset. The horizon structure has the
%           fields:
%           horstruc.horizons ... a 3D array of horizon times. Each horizon is a 2D array the same
%               size as the base survey and is stored as a slice in the horizons 3D array. Horizon
%               arrays have x as coordinate 2, y as coordinate 3, while coordinate 1 is the horizon
%               index.
%           horstruc.filenames ... cell array of file names for each horizon. These may be long
%               complicated names that document the dataset that the picking was done on.
%           horstruc.names ... cell array horizon names. These are short names that will be shown on plots.
%           horstruc.showflags ... numeric array of flags. For each horizon, this is a flag (1 or 0)
%               indicating if the horizon is to be shown or not.
%           horstruc.colors ... cell array of colors for each horizon. If a color is
%               not specified, then one is obtained automatically from the axes colororder.
%           horstruc.linewidths ... numerica array containing linewidths for plotting. Set to 1 on
%               import.
%           horstruc.handles ... array of graphics handles for the displayed horizons.
% 



%userdata assignments
%hfile ... the project structure
%hmpan ... (the master panel) {hpanels geom thispanel}
%hpan ... the idata (data index) which is the number of the dataset for that data panel
%hreadsegy ... path for the most recently read segy
%hreadmat ... path for the most recently read .mat
%any plotimage figure ... {idata hsane}, idata is the number of the dataset, hsane is the sane figure
%any figure menu in "view" ... the handle of the figure the menu refers to
%hmessage ... array of figure handles that may need to be closed if sane is closed (usually info
%           windows)
% 

global PLOTIMAGE3DTHISFIG PLOTIMAGE3DFIGS HWAIT CONTINUE
%HWAIT and CONTINUE are used by the waitbar for continueing or cancelling

if(nargin<1)
    action='init';
end

if(strcmp(action,'init'))
%     test=findsanefig;
%     if(~isempty(test))
%         msgbox('You already have SANE running, only one at a time please');
%         return
%     end
    hsane=figure;
    ssize=get(0,'screensize');
    figwidth=1000;
    figheight=floor(ssize(4)*.4);
    if(figheight<600)
        if(ssize(4)>600)
            figheight=600;
        end
    end
    xnot=(ssize(3)-figwidth)*.5;
    ynot=(ssize(4)-figheight)*.5;
    set(hsane,'position',[xnot,ynot,figwidth,figheight],'tag','sane');
    set(hsane,'menubar','none','toolbar','none','numbertitle','off','name','SANE New Project',...
        'nextplot','new','closerequestfcn','sane(''close'')');
    
    hfile=uimenu(hsane,'label','File','tag','file');
    uimenu(hfile,'label','Load existing project','callback','sane(''loadproject'');','tag','loadproject');
    uimenu(hfile,'label','Save project','callback','sane(''saveproject'');');
    uimenu(hfile,'label','Save project as ...','callback','sane(''saveprojectas'');');
    uimenu(hfile,'label','New project','callback','sane(''newproject'');');
    hread=uimenu(hfile,'Label','Read datasets','tag','read');
    uimenu(hread,'label','*.sgy file','callback','sane(''readsegy'');','tag','readsegy');
    uimenu(hread,'label','Multiple sgy files','callback','sane(''readmanysegy'');','tag','readmanysegy');
    uimenu(hread,'label','*.mat file','callback','sane(''readmat'');','tag','readmat');
    hwrite=uimenu(hfile,'label','Write datasets');
    uimenu(hwrite,'label','*.sgy file','callback','sane(''writesegy'');');
    uimenu(hwrite,'label','*.mat file','callback','sane(''writemat'');');
    hreadhor=uimenu(hfile,'label','Read horizons');
    uimenu(hreadhor,'label','.xyz file','callback','sane(''readhor'');','tag','xyz','enable','on');
    uimenu(hfile,'label','Quit','callback','sane(''close'');');
    
    uimenu(hsane,'label','View','tag','view');
    
    hcompute=uimenu(hsane,'label','Compute','tag','compute');
    uimenu(hcompute,'label','Bandpass filter','callback','sane(''starttask'');','tag','filter');
    uimenu(hcompute,'label','Spiking decon','callback','sane(''starttask'');','tag','spikingdecon');
    uimenu(hcompute,'label','Wavenumber lowpass filtering','callback','sane(''starttask'');','tag','wavenumber','enable','on');
    if(exist('tvfdom','file')==2)
        uimenu(hcompute,'label','Dominant frequency volumes','callback','sane(''starttask'');','tag','fdom','enable','on');
    end
    hsd=uimenu(hcompute,'label','Spectral Decomp');
    uimenu(hsd,'label','Decision maker','callback','sane(''specdecompdecide'');');
    uimenu(hsd,'label','Compute Spec Decomp','callback','sane(''starttask'');','tag','specdecomp','enable','off');
    uimenu(hcompute,'label','Phase maps','callback','sane(''starttask'');','tag','phasemap','enable','off');
    
    proj=makeprojectstructure;
    set(hfile,'userdata',proj);
    
    x0=.05;width=.2;height=.05;
    ysep=.02;
    xsep=.02;
    xnow=x0;
    ynow=1-height-ysep;
    fs=10;
    %a message area
    uicontrol(gcf,'style','text','string','Load an existing project or read a SEGY file','units','normalized',...
        'position',[xnow,ynow,.8,height],'tag','message','fontsize',fs,'fontweight','bold');
    %project name display
    ynow=ynow-height-ysep;
    uicontrol(gcf,'style','text','string','Project Name:','tag','name_label','units','normalized',...
        'position',[xnow,ynow-.25*height,width,height],'fontsize',fs,'horizontalalignment','right');
    xnow=xnow+xsep+width;
    uicontrol(gcf,'style','edit','string',proj.name,'tag','project_name','units','normalized',...
        'position',[xnow,ynow,2*width,height],'fontsize',fs,'callback','sane(''projectnamechange'');');
    xnow=xnow+xsep+2*width;
    %ppt button
    uicontrol(gcf,'style','pushbutton','string','Start PPT','tag','pptx','units','normalized',...
        'position',[xnow,ynow,.5*width,height],'callback','sane(''pptx'');','backgroundcolor','y');
    panelwidth=1-2*x0;
    panelheight=1.2*height;
    xnow=x0;
    ynow=ynow-height-ysep;
    %the master panel
    hmpan=uipanel(gcf,'tag','master_panel','units','normalized','position',...
        [xnow ynow panelwidth panelheight]);
    xn=0;yn=0;wid=.5;ht=.8;ht2=1.1;
    ng=.94*ones(1,3);
    dg=.7*ones(1,3);
    uicontrol(hmpan,'style','text','string','Dataset','tag','dataset_label','units','normalized',...
        'position',[xn,yn,wid,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+wid+xsep;
    wid2=(1-wid-3*xsep)/4.5;
    uicontrol(hmpan,'style','text','string','Info','tag','info_label','units','normalized',...
        'position',[xn,yn,.75*wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+.75*wid2+xsep;
    uicontrol(hmpan,'style','text','string','In memory','tag','memory_label','units','normalized',...
        'position',[xn,yn,wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized',...
        'position',[xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+wid2+xsep;
    uicontrol(hmpan,'style','text','string','Displayed','tag','display_label','units','normalized',...
        'position',[xn,yn,wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized',...
        'position',[xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+wid2+xsep;
    uicontrol(hmpan,'style','text','string','Delete','tag','delete_label','units','normalized',...
        'position',[xn,yn,.5*wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized',...
        'position',[xn+.5*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+.5*wid2+xsep;
    uicontrol(hmpan,'style','text','string','Group','tag','group_label','units','normalized',...
        'position',[xn,yn,.5*wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %userdata of hmpan will be a cell array. The first entry is an array of panel handles, one for each dataset in the project
    %the second entry is geometry information: panelwidth panelheight wid ht xsep ysep
    ysep=.01;
    set(hmpan,'userdata',{[],[panelwidth panelheight xnow ynow wid ht xsep ysep ynow]});
    
    %now a the 'sane_panel' which stretches from the master_panel to the figure bottom. Inside the
    %sane_panel will be the data_panel which has the same width but 4 times the height.
    hsp=uipanel(gcf,'tag','sane_panel','units','normalized','position',[xnow,.05,panelwidth,ynow-.05;]);
    %data_panel
    hdp=uipanel(hsp,'tag','data_panel','units','normalized','position',[0 -3 1 4]);
    %scrollbar
    uicontrol(hsane,'style','slider','tag','slider','units','normalized','position',...
        [xnow+panelwidth,.05,.5*x0,ynow-.05],'value',1,'Callback',{@sane_slider,hdp})
    
elseif(strcmp(action,'readsegy'))
    %read in a segy dataset
    hsane=findsanefig;
    pos=get(hsane,'position');
    hreadsegy=findobj(hsane,'tag','readsegy');
    startpath=get(hreadsegy,'userdata');
    if(isempty(startpath))
        spath='*.sgy';
    else
        spath=[startpath '*.sgy'];
    end
    [fname,path]=uigetfile(spath,'Choose the .sgy file to import');
    if(fname==0)
        return
    end
    %test last 4 characters for .SGY or .SGY
    nsgy=3;
    if(~strcmpi(fname(end-nsgy:end),'.sgy'))
        nsgy=4;
        if(~strcmpi(fname(end-nsgy:end),'.segy'))
            msgbox('Chosen file is not a either .sgy or .segy, cannot proceed');
            return;
        end
    end
    %put up second dialog
    hdial=figure;
    fight=300;
    figwid=400;
    set(hdial,'position',[pos(1)+.5*(pos(3)-figwid),pos(2)+.5*(pos(4)-fight),figwid,fight],...
        'menubar','none','toolbar','none','numbertitle','off',...
        'name','SANE: Read Segy dialog','userdata',{[],hsane},'tag','fromsane');
    xnot=.05;ynow=.85;
    xnow=xnot;
    wid=.9;ht=.1;
    ysep=.01;xsep=.02;
    uicontrol(hdial,'style','text','string',['File: ' fname],'tag','fname','units','normalized',...
        'position',[xnow,ynow,wid,ht],'userdata',fname,'horizontalalignment','left','fontsize',10);
    ynow=ynow-ht-ysep;
    uicontrol(hdial,'style','text','string',['Path: ' path],'tag','path','units','normalized',...
        'position',[xnow,ynow,wid,ht],'userdata',path,'horizontalalignment','left','fontsize',10);
    ynow=ynow-ht-ysep;
    wid=.3;
    uicontrol(hdial,'style','pushbutton','string','Trace headers','units','normalized','tag','traceheaders',...
        'position',[xnow,ynow,wid,ht],'callback','sane(''showtraceheaders'');',...
        'tooltipstring','push to view trace headers');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','text','string','# hdrs to view:','units','normalized','position',...
        [xnow,ynow-.1*ht,wid,ht],'horizontalalignment','right');
    uicontrol(hdial,'style','edit','string','100','tag','ntraces','units','normalized',...
        'position',[xnow+wid+xsep,ynow,.3*wid,ht]);
    xnow=xnot;
    wid=.3;
    ynow=ynow-ht-ysep;
    uicontrol(hdial,'style','text','string','Inline byte loc:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'horizontalalignment','right');
    xnow=xnow+wid+xsep;
    locs=segybytelocs;
    uicontrol(hdial,'style','pushbutton','string','SEGY standard','tag','inline','units',...
        'normalized','position',[xnow,ynow,wid,ht],'callback','sane(''choosebyteloc'');',...
        'tooltipstring',['loc= ' int2str(locs(1)) ', Push to change.'],'userdata',locs(1));
    ynow=ynow-ht-ysep;
    xnow=xnot;
    uicontrol(hdial,'style','text','string','Xline byte loc:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'horizontalalignment','right');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','pushbutton','string','SEGY standard','tag','xline','units',...
        'normalized','position',[xnow,ynow,wid,ht],'callback','sane(''choosebyteloc'');',...
        'tooltipstring',['loc= ' int2str(locs(2)) ', Push to change.'],'userdata',locs(2));
    xnow=xnot;
    ynow=ynow-ht-ysep;
    wid=.5;
    uicontrol(hdial,'style','radiobutton','string','Display immediately','tag','display',...
        'units','normalized','position',[xnow,ynow,wid,ht],'value',1,'tooltipstring',...
        'Option to display the dataset immediately after import')
    ynow=ynow-ht-ysep;
    wid=.2;
    uicontrol(hdial,'style','edit','string','0.0','tag','tshift','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Enter a value in seconds or depth units');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','text','string','time shift','units','normalized','position',...
        [xnow,ynow-.1*ht,3*wid,ht],'horizontalalignment','left');
    ynow=ynow-ht-ysep;
    xnow=xnot;
    wid=.3;
    uicontrol(hdial,'style','pushbutton','string','Done','tag','done','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','sane(''readsegy2'');');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','pushbutton','string','Cancel','tag','cancel','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','sane(''readsegy2'');');
    
    
elseif(strcmp(action,'readsegy2'))
    hdial=gcf;%the dialog from readsegy
    hsane=findsanefig;
    hfile=findobj(hsane,'label','File');
    hreadsegy=findobj(hsane,'tag','readsegy');
    hmsg=findobj(hsane,'tag','message');
    hbut=gcbo;%the button clicked
    if(strcmp(get(hbut,'tag'),'cancel'))
        delete(hdial);
        set(hmsg,'string','SEGY import cancelled');
        return;
    end
    %look for a trace header window open and close it
    htrbut=findobj(hdial,'tag','traceheaders');
    ud=get(htrbut,'userdata');
    if(isgraphics(ud))
        delete(ud);
    end
    
    hfname=findobj(hdial,'tag','fname');
    fname=get(hfname,'userdata');
    hpath=findobj(hdial,'tag','path');
    path=get(hpath,'userdata');
    loc=[0,0];
    hinline=findobj(hdial,'tag','inline');
    loc(1)=get(hinline,'userdata');
    hxline=findobj(hdial,'tag','xline');
    loc(2)=get(hxline,'userdata');
    hdisp=findobj(hdial,'tag','display');
    dispopt=get(hdisp,'value');
    htshift=findobj(hdial,'tag','tshift');
    tshift=str2double(get(htshift,'string'));
    if(isnan(tshift)); tshift=0; end
    
    delete(hdial)
    
    nsgy=3;
    if(~strcmpi(fname(end-nsgy:end),'.sgy'))
        nsgy=4;
    end
    dname=fname(1:end-nsgy-1);
    waitsignalon
    segyrev=1;
    set(hmsg,'string',['Reading SEGY dataset ' path fname]);
    [seis,segyrev,dt,segfmt,texthdrfmt,byteorder,texthdr,binhdr,...
        exthdr,tracehdr,bindef,trcdef] =readsegy([path fname],[],segyrev,[],[],...
        [],[],[],[],[],hsane);
%     [],[],[],[],[],hsane);

    t=double(dt)*(0:size(seis,1)-1)';
    %determine if time or depth
    dt=abs(t(2)-t(1));
    depthflag=0;
    if(dt>.02)
        depthflag=1;
    end
    %read inline and xline numbers according to the byte locations
    fld1=tracebyte2word(loc(1),1);%segyrev 1 was forced on input
    y=double(getfield(tracehdr,fld1));
    fld2=tracebyte2word(loc(2),1);
    x=double(getfield(tracehdr,fld2));
    if(isfield(tracehdr,'CdpX'))
        cdpx=tracehdr.CdpX;
        cdpy=tracehdr.CdpY;
        if(sum(abs(cdpx))==0)
            cdpx=tracehdr.SrcX;
            cdpy=tracehdr.SrcY;
        end
        if(sum(abs(cdpx))==0)
            cdpx=tracehdr.GroupX;
            cdpy=tracehdr.GroupY;
        end
    else
        cdpx=tracehdr.SrcX;
        cdpy=tracehdr.SrcY;
        if(sum(abs(cdpx))==0)
            cdpx=tracehdr.GroupX;
            cdpy=tracehdr.GroupY;
        end
    end
    if(sum(abs(cdpx))==0)
        cdpx=x;%this happens if the above strategies have netted nothing
        cdpy=y;
    end
    %cdp coords are doubles in the headers. No need to typecast
    
    [seis3D,xline,iline,xcdp,ycdp,kxline]=make3Dvol(seis,x,y,cdpx,cdpy);
    
    dx=mean(abs(diff(xcdp)));
    dy=mean(abs(diff(ycdp)));
    dx=max([dx, 1]);
    dy=max([dy, 1]);
    
    

    if(depthflag==0 && tshift>10)
        tshift=tshift/1000;%assume they mean milliseconds
    end
    
    
    
    %update the project structure
    
    proj=get(hfile,'userdata');
    nfiles=length(proj.filenames)+1;
    proj.filenames{nfiles}=fname;
    proj.paths{nfiles}=path;
    proj.datanames{nfiles}=dname;
    if(dispopt)
        proj.isloaded(nfiles)=1;
        proj.isdisplayed(nfiles)=1;
    else
        proj.isloaded(nfiles)=0;
        proj.isdisplayed(nfiles)=0;
    end
    %make the new data panel
    hpan=newdatapanel(dname,proj.isloaded(nfiles),proj.isdisplayed(nfiles));
    %finish updating project structure
    proj.xcoord{nfiles}=xline;
    proj.ycoord{nfiles}=iline(:);
    proj.tcoord{nfiles}=t+tshift;
    proj.tshift(nfiles)=tshift;
    proj.xcdp{nfiles}=xcdp;
    proj.ycdp{nfiles}=ycdp(:);
    proj.dx(nfiles)=dx;
    proj.dy(nfiles)=dy;
    proj.depth(nfiles)=depthflag;
    proj.texthdr{nfiles}=texthdr;
    proj.texthdrfmt{nfiles}=texthdrfmt;
    proj.segfmt{nfiles}=segfmt;
    proj.byteorder{nfiles}=byteorder;
    proj.tracehdr{nfiles}=tracehdr;
    proj.binhdr{nfiles}=binhdr;
    proj.exthdr{nfiles}=exthdr;
    proj.bindef{nfiles}=bindef;
    proj.trcdef{nfiles}=trcdef;
    proj.segyrev(nfiles)=segyrev;
    proj.kxline{nfiles}=kxline;
    proj.datasets{nfiles}=seis3D;
    proj.gui{nfiles}=hpan;
    proj.isdeleted(nfiles)=0;
    proj.deletedondisk(nfiles)=0;
    proj.saveneeded(nfiles)=1;
    

    %call plotimage3D
    if(dispopt)
        plotimage3D(seis3D,t,{xline,xcdp},{iline,ycdp},dname,'seisclrs',dx,dy);
        set(gcf,'tag','fromsane','userdata',{nfiles hsane});
        set(gcf,'closeRequestFcn','sane(''closepifig'');')
        hview=findobj(hsane,'tag','view');
        uimenu(hview,'label',dname,'callback','sane(''popupfig'');','userdata',gcf);
        proj.pifigures{nfiles}=gcf;
    else
        proj.pifigures{nfiles}=[];
    end
    %save the path
    set(hreadsegy,'userdata',path);
    
    %save the project structure
    set(hfile,'userdata',proj);
    figure(hsane)
    waitsignaloff
    if(dispopt)
        set(hmsg,'string',['File "' fname '" imported and displayed. Data will be written to disk when you save the project.'])
    else
        set(hmsg,'string',['File "' fname '" imported. Data will be written to disk when you save the project.'])
    end
    
elseif(strcmp(action,'readmanysegy'))
    %Here we read in a bunch of SEGY's at once. 
    %If the existing project is not new, then we first ask if we want to add to it. Otherwise we suggest save.  
    hsane=findsanefig;
    hmsg=findobj(hsane,'tag','message');
    hfile=findobj(hsane,'tag','file');
    proj=hfile.UserData;
    newproject=true;
    if(~isempty(proj.filenames))
       Q='Merge new data into existing project?';
       Q0='What about the current project?';
       A1='Yes';
       A2='No, start new project';
       A3='Cancel, I forgot to save';
       answer=questdlg(Q,Q0,A1,A2,A3,A1);
       if(strcmp(answer,A3))
           set(hmsg,'string','Multilple SEGY load cancelled, Save your project first');
           return;
       elseif(strcmp(answer,A2))
           sane('newproject');
       else
           newproject=false;
       end
    end
    %put up dialog
    set(hmsg,'string','Beginning Multiple SEGY load');
    multiplesegyload(newproject);
    return;
elseif(strcmp(action,'readmanysegy2'))
    hdial=gcf;
    hsane=findsanefig;
    hmsg=findobj(hsane,'tag','message');
    set(hmsg,'string','Beginning multiple SEGY read');
    hfile=findobj(hsane,'tag','file');
    proj=hfile.UserData;
    %look for open trace header windows and close if necessary
    htrbut=findobj(hdial,'tag','traceheaders');
    for k=1:length(htrbut)
       if(isgraphics(htrbut(k)))
           delete(htrbut(k));
       end
    end
    hmpan=findobj(hdial,'tag','readmanymaster');
    udat=get(hmpan,'userdata');
    hpanels=udat{1};
    if(isempty(hpanels))
        msgbox('You need to choose some datasets to import','Oooops!');
        return;
    end
    hprojfile=findobj(hdial,'tag','projsavefile');
    projfile=get(hprojfile,'string');
    
    if(strcmpi('undefined',projfile))
        msgbox('You need define the project save file','Oooops!');
        return;
    end
    proj.projfilename=projfile;
    proj.projpath=get(hprojfile,'userdata');
    matobj=matfile([proj.projpath proj.projfilename],'writable',true);%open the mat file
    nd=length(proj.datanames);%number of datasets currently in project
    ndnew=length(hpanels);%number of new datasets
    proj=expandprojectstructure(proj,ndnew);
    set(hfile,'userdata',proj);
    %harvest the data info
    data=cell(ndnew,7);%entries are: filename, pathname, dataname, displayopt, tshift, inlineloc, xlineloc 
    for k=1:ndnew
        hfname=findobj(hpanels{k},'tag','filename');
        data{k,1}=get(hfname,'string');
        data{k,2}=get(hfname,'userdata');
        hdname=findobj(hpanels{k},'tag','dataname');
        data{k,3}=get(hdname,'string');
        hdisp=findobj(hpanels{k},'tag','display');
        data{k,4}=get(hdisp,'value');
        htshift=findobj(hpanels{k},'tag','tshift');
        tshift=str2double(get(htshift,'string'));
        if(isnan(tshift))
            tshift=0;
        end
        data{k,5}=tshift;
        hinline=findobj(hpanels{k},'tag','inline');
        data{k,6}=get(hinline,'userdata');
        hxline=findobj(hpanels{k},'tag','xline');
        data{k,7}=get(hxline,'userdata');
    end
    delete(hdial);
    t0=clock;
    figure(hsane);
    waitsignalon
    for k=nd+1:nd+ndnew
        filename=data{k-nd,1};
        datapath=data{k-nd,2};
        proj.datanames{k}=data{k-nd,3};
        dispopt=data{k-nd,4};
        if(dispopt)
            proj.isdisplayed(k)=1;
            proj.isloaded(k)=1;
        end
        tshift=str2double(data{k-nd,5});
        if(isnan(tshift))
            tshift=0;
        elseif(tshift>10)
            tshift=tshift/1000;
        end
        proj.tshift(k)=tshift;
        
        set(hmsg,'string',['reading file ' int2str(k-nd) ' of ' int2str(ndnew) ', ' filename ...
            ' from path ' datapath ', see main Matlab window for progress']);
        drawnow
        %note the flag forcing everything to be read in a rev1. This causes a rev0 to have its
        %unassigned trace header values renamed to the rev1 names. I think this is a benign thing.
        [seis,proj.segyrev(k),dt,proj.segfmt{k},proj.texthdrfmt{k},proj.byteorder{k},proj.texthdr{k},proj.binhdr{k},...
            proj.exthdr{k},proj.tracehdr{k},proj.bindef{k},proj.trcdef{k}] =readsegy([datapath filename],[],1,[],[],...
            [],[],[],[],[],1);
        
        t=dt*(0:size(seis,1)-1)'+tshift;
        proj.tcoord{k}=t;
        dt=abs(t(2)-t(1));
        if(dt>.02)
            proj.depth(k)=1;
        end
        %read inline and xline numbers according to the byte locations
        fld1=tracebyte2word(data{k-nd,6},1);%segyrev 1 was forced on input
        y=double(getfield(proj.tracehdr{k},fld1));
        fld2=tracebyte2word(data{k-nd,7},1);
        x=double(getfield(proj.tracehdr{k},fld2));
        if(isfield(proj.tracehdr{k},'CdpX'))
            cdpx=proj.tracehdr{k}.CdpX;
            cdpy=proj.tracehdr{k}.CdpY;
            if(sum(abs(cdpx))==0)
                cdpx=proj.tracehdr{k}.SrcX;
                cdpy=proj.tracehdr{k}.SrcY;
            end
            if(sum(abs(cdpx))==0)
                cdpx=proj.tracehdr{k}.GroupX;
                cdpy=proj.tracehdr{k}.GroupY;
            end
        else
            cdpx=proj.tracehdr{k}.SrcX;
            cdpy=proj.tracehdr{k}.SrcY;
            if(sum(abs(cdpx))==0)
                cdpx=proj.tracehdr{k}.GroupX;
                cdpy=proj.tracehdr{k}.GroupY;
            end
        end
        if(sum(abs(cdpx))==0)
            cdpx=x;%this happens if the above strategies have netted nothing
            cdpy=y;
        end
%         if(isfield(proj.tracehdr{k},'CdpX'))
%             cdpx=proj.tracehdr{k}.CdpX;
%             cdpy=proj.tracehdr{k}.CdpY;
%         else
%             cdpx=zeros(size(x));
%             cdpy=zeros(size(y));
%         end
        
        [seis3D,proj.xcoord{k},tmp,xcdp,ycdp,proj.kxline{k}]=make3Dvol(seis,x,y,cdpx,cdpy);
        proj.ycoord{k}=tmp';
        dx=mean(abs(diff(xcdp)));
        dy=mean(abs(diff(ycdp)));
        proj.dx(k)=max([dx, 1]);
        proj.dy(k)=max([dy, 1]);
        proj.xcdp{k}=xcdp;
        proj.ycdp{k}=ycdp';
        proj.gui{k}=newdatapanel(proj.datanames{k},proj.isloaded(k),proj.isdisplayed(k));%make a data panel
        matobj.datasets(1,k)={seis3D};
        
        if(proj.isloaded(k)==1)
            proj.datasets{k}=seis3D;
            plotimage3D(seis3D,t,{proj.xcoord{k},xcdp},{proj.ycoord{k},ycdp},proj.datanames{k},'seisclrs',proj.dx(k),proj.dy(k));
            set(gcf,'tag','fromsane','userdata',{k hsane});
            set(gcf,'closeRequestFcn','sane(''closepifig'');')
            hview=findobj(hsane,'tag','view');
            uimenu(hview,'label',proj.datanames{k},'callback','sane(''popupfig'');','userdata',gcf);
            proj.pifigures{k}=gcf;
            figure(hsane)
        end
        
        
        
        tnow=clock;
        timeused=etime(tnow,t0);
        
        set(hmsg,'string',['Finished reading file ' int2str(k-nd) ' of ' int2str(ndnew) ', '...
            filename ', Time used = ' num2str(timeused/60) ' minutes']);
    end
    set(hfile,'userdata',proj);
    for k=nd+1:nd+ndnew
        proj.datasets{k}=[];%don't save a dataset in the project structure
        proj.pifigures{k}={};%don't want to save a graphics handle
        proj.gui{k}={};
    end
    if(strcmp(proj.name,'New Project'))
        tmp=proj.projfilename;
        ind=strfind(tmp,'.mat');
        if(isempty(ind)); ind=length(tmp); end
        proj.name=tmp(1:ind(1)-1);
        %update the gui
        hn=findobj(hsane,'tag','project_name');
        set(hn,'string',proj.name);
        set(hsane,'name',['Sane, Project: ' proj.name])
    end
    matobj.proj=proj;%save project structure
    
    waitsignaloff
    
elseif(strcmp(action,'selectnewdataset'))
    %this is called by the multiplesegyload internal function
    %It can happen eith by pushing the 'New dataset' button of by p[ushing the 'Filename button' of
    %an already defined dataset.
    hdial=gcf;
    hbut=gcbo;
    hnew=findobj(hdial,'tag','new');
    if(hbut==hnew)
       hpan=[];
    else
       hpan=get(hbut,'parent');
    end
    startpath=get(hnew,'userdata');
    if(isempty(startpath))
        spath='*.sgy';
    else
        spath=[startpath '*.sgy'];
    end
    [fname,path]=uigetfile(spath,'Choose the .sgy file to import');
    if(fname==0)
        return
    end
    nsgy=3;
    if(~strcmpi(fname(end-nsgy:end),'.sgy'))
        nsgy=4;
        if(~strcmpi(fname(end-nsgy:end),'.segy'))
            msgbox('Chosen file is not a either .sgy or .segy, cannot proceed');
            return;
        end
    end
    dname=fname(1:end-nsgy-1);
    if(isempty(hpan))
        newfileloadpanel(fname,path,dname);
    else
       hfname=findobj(hpan,'tag','filename');
       set(hfname,'string',fname,'userdata',path,'tooltipstring',['Path: ' path]);
       hdname=findobj(hpan,'tag','dataname');
       set(hdname,'string',dname);
    end

    set(hnew,'userdata',path);%the is always the path of the last chosen dataset
elseif(strcmp(action,'defineprojectsavefile'))
%     hsane=findsanefig;
    hdial=gcf;
    %hfile=findobj(hsane,'label','File');
    %hreadsegy=findobj(hsane,'tag','readsegy');
%     hmsg=findobj(hsane,'tag','message');
    hdialmsg=findobj(hdial,'tag','dialmsg');
%     hreadmany=findobj(hsane,'tag','readmanysegy');
    hnew=findobj(hdial,'tag','new');
    ht=findobj(hdial,'tag','table');
    paths=get(ht,'userdata');
    if(isempty(paths))
        startpath=get(hnew,'userdata');
    else
        startpath=paths{1};
    end
    if(isempty(startpath))
        spath='*.mat';
    else
        spath=[startpath '*.mat'];
    end
    [fname,path]=uiputfile(spath,'Specify the Project .mat file');
    if(fname==0)
        set(hdialmsg,'string','UNDEFINED');
        return
    end
    nsgy=3;
    if(strcmpi(fname(end-nsgy:end),'.sgy'))
        msgbox('Chosen file must be a .mat file not a .sgy. Try again');
            set(hdialmsg,'String','Project save file must be a .mat file');
            return;
    end
    nsgy=4;
    if(strcmpi(fname(end-nsgy:end),'.segy'))
        msgbox('Chosen file must be a .mat file not a .segy. Try again');
            set(hdialmsg,'String','Project save file must be a .mat file');
            return;
    end
%     ind=strfind(fname,'.mat');
%     if(isempty(ind)) %#ok<STREMP>
    if(~contains(fname,'.mat'))
        fname=[fname '.mat'];
    end
    if(exist([path fname],'file'))
        response=questdlg('The specified prohect file already exists. Overwrite?','Project file question.',...
            'Yes','No','Yes');
        if(strcmp(response','No'))
           set(hdialmsg,'string','Choose a different Project file');
           return;
        end
    end
    hprojfile=findobj(hdial,'tag','projsavefile');
    set(hprojfile,'string',fname,'userdata',path);
elseif(strcmp(action,'cancelmultipleload'))
    udat=get(gcf,'userdata');
    hdial2=udat{1};
    for k=1:length(hdial2)
        if(isgraphics(hdial2(k)))
            delete(hdial2(k))
        end
    end
    hsane=udat{2};
    hmsg=findobj(hsane,'tag','message');
    delete(gcf)
    set(hmsg,'string','Multiple SEGY load cancelled');
elseif(strcmp(action,'reloaddataset'))
    hsane=findsanefig;
    hmsg=findobj(hsane,'tag','message');
    %this is called from a datapanel to load a dataset not in memory. The data panel is identified
    %by the third entry of the userdata of the master panel
    hmpan=findobj(hsane,'tag','master_panel');
    udat=hmpan.UserData;
    idata=udat{3};%this is the dataset we are loading
    %hpan=udat{1}(udat{3});
    hfile=findobj(hsane,'tag','file');
    proj=hfile.UserData;
    
    set(hmsg,'string',['Recalling dataset ' proj.datanames{idata} ' from disk'])
    waitsignalon
    matobj=matfile([proj.projpath proj.projfilename]);
    cseis3D=matobj.datasets(1,idata);%this reads from disk
    seis3D=cseis3D{1};
    t=proj.tcoord{idata};
    xline=proj.xcoord{idata};
    iline=proj.ycoord{idata};
    xcdp=proj.xcdp{idata};
    ycdp=proj.ycdp{idata};
    dname=proj.datanames{idata};
    
    %update the project structure
    proj.datasets{idata}=seis3D;
    proj.isloaded(idata)=1;
    proj.saveneeded(idata)=0;
    %call plotimage3D
    if(proj.isdisplayed(idata)==0)%don't display it a second time
        plotimage3D(seis3D,t,{xline,xcdp},{iline,ycdp},dname,'seisclrs',proj.dx(idata),proj.dy(idata));
        set(gcf,'tag','fromsane','userdata',{idata hsane});
        set(gcf,'closeRequestFcn','sane(''closepifig'');')
        hview=findobj(hsane,'tag','view');
        uimenu(hview,'label',dname,'callback','sane(''popupfig'');','userdata',gcf);
        proj.pifigures{idata}=gcf;
        proj.isdisplayed(idata)=1;
    end
    memorybuttonon(idata);
    waitsignaloff;
    
    set(hfile,'userdata',proj);
    figure(hsane);
    
    set(hmsg,'string',['Dataset ' dname ' reloaded']);
    
elseif(strcmp(action,'readmat'))
    hsane=findsanefig;
    hreadmat=gcbo;
    %basic idea is that the .mat file can contain one and only one 3D matrix. It should also contain
    %coordinate vectors for each of the 3 dimensions. So, an abort will occur if there are more than
    %1 3D matrices (or none), and also if there are no possible coordinate vectors for the 3
    %dimensions. If there are coordinate vectors but it is not clear which is which, then an
    %ambiguity dialog is put up to resolve this.
    %read in a *.mat file
    [fname,path]=uigetfile('*.mat','Choose the .mat file to import');
    if(fname==0)
        return
    end
    m=matfile([path fname]);
    varnames=fieldnames(m);
    varnames(1)=[];
    varsizes=cell(size(varnames));
    threed=zeros(size(varsizes));
    %find any 3D matrices. only one is allowed
    for k=1:length(varnames)
        varsizes{k}=size(m,varnames{k});
        if(length(varsizes{k})==3)
            threed(k)=1;%points to 3D matrices
        end
    end
    if(sum(threed)>1)
        msgbox('Dataset contains more than 1 3D matrix. Unable to proceed.','Sorry!');
        return
    end
    %look for t,iline and xline
    i3d=find(threed==1);
    sz3d=size(m,varnames{i3d});
    nt=sz3d(1);%time is always the first dimension
    nx=sz3d(2);%xline is always the second dimension
    ny=sz3d(3);%inline is always the third dimension
    it=zeros(size(threed));
    ix=it;
    iy=it;
    %find things that are the size of nt, nx, and ny
    itchoice=0;
    ixchoice=0;
    iychoice=0;
    inamechoice=0;
    for k=1:length(varnames)
        if(k~=i3d)
            szk=varsizes{k};
            if((min(szk)==1)&&(max(szk)>1))
                %ok its a vector
                n=max(szk);
                if(n==nt)
                    %mark as possible time coordinate
                    it(k)=1;
                    if(strcmp(varnames{k},'t'))
                        itchoice=k;
                    end
                end
                if(n==nx)
                    %mark as possible xline
                    ix(k)=1;
                    if(strcmp(varnames{k},'xline'))
                        ixchoice=k;
                    end
                end
                if(n==ny)
                    %mark as possible iline
                    iy(k)=1;
                    if(strcmp(varnames{k},'iline')||strcmp(varnames{k},'inline')||strcmp(varnames{k},'yline'))
                        iychoice=k;
                    end
                end
            end
            if(strfind(varnames{k},'dname'))
                inamechoice=k;
            end
        end
    end
    %ok, the best case is that it, ix, and iin all sum to 1 meaning there is only 1 possible
    %coordinate vector for each. If any one sums to zero, then we cannot continue. If any one sums
    %to greater than 1 then we have ambiguity that must be resolved.
    failmsg='';
    if(sum(it)==0)
        failmsg={failmsg 'Dataset contains no time coordinate vector. '};
    end
    if(sum(ix)==0)
        failmsg={failmsg 'Dataset contains no xline coordinate vector. '};
    end
    if(sum(iy)==0)
        failmsg={failmsg 'Dataset contains no inline coordinate vector. '};
    end
    if(~isempty(failmsg))
        msgbox(failmsg,'Sorry, dataset is not compaible with SANE.')
        return
    end
    if(itchoice==0)
        ind=find(it==1);
        itchoice=it(ind(1));
    end
    if(ixchoice==0)
        ind=find(ix==1);
        ixchoice=ix(ind(1));
    end
    if(iychoice==0)
        ind=find(iy==1);
        iychoice=iy(ind(1));
    end
    ambig=[0 0 0];
    if(sum(it)>1)
        ambig(1)=1;
    end
    if(sum(ix)>1)
        ambig(2)=1;
    end
    if(sum(iy)>1)
        ambig(3)=1;
    end
    if(sum(ambig)>1)
        % put up dialog to resolve ambiguity
        [itchoice,ixchoice,iychoice]=ambigdialog(ambig,it,ix,iy,varnames,itchoice,ixchoice,iychoice);
    end
    %ok now get stuff from the matfile
    seis=getfield(m,varnames{i3d}); %#ok<*GFLD>
    t=getfield(m,varnames{itchoice});
    xline=getfield(m,varnames{ixchoice});
    iline=getfield(m,varnames{iychoice});
    dname='';
    if(inamechoice>0)
        dname=getfield(m,varnames{inamechoice});
    end
    if(inamechoice==0 || ~ischar(dname))
        dname=fname;
    end
    
    %determine if time or depth
    dt=abs(t(2)-t(1));
    depthflag=0;
    if(dt>.02)
        depthflag=1;
    end
    
    %ask for a few things
    tshift=0;
    if(depthflag==1)
        q4='Datum shift (depth units)';
    else
        q4='Datum shift (seconds)';
    end
    dx=1;
    dy=1;
    q={'Specify dataset name:','Physical distance between crosslines:','Physical distance between inlines:',q4};
    a={dname num2str(dy) num2str(dx) num2str(tshift)};
    a=askthingsle('name','Please double check these values','questions',q,'answers',a);
    if(isempty(a))
        msgbox('SEGY input aborted');
        return;
    end
    dname=a{1};
    dy=str2double(a{2});
    dx=str2double(a{3});
    tshift=str2double(a{4});
    if(isnan(tshift));tshift=0;end
    %insist on a positive number for dx and dy
    if(isnan(dy)); dy=0; end
    if(isnan(dx)); dx=0; end
    if(dx<0); dx=0; end
    if(dy<0); dy=0; end
    while(dx*dy==0)
        q={'Specify dataset name:','Physical distance between crosslines:','Physical distance between inlines:',q4};
        a={dname num2str(dy) num2str(dx) num2str(tshift)};
        a=askthingsle('name','Inline and crossline distances must be positive numbers!!','questions',q,'answers',a);
        if(isempty(a))
            msgbox('.mat input aborted');
            return;
        end
        dname=a{1};
        dy=str2double(a{2});
        dx=str2double(a{3});
        if(isnan(dy)); dy=0; end
        if(isnan(dx)); dx=0; end
        if(dx<0); dx=0; end
        if(dy<0); dy=0; end
    end
    if(depthflag==0 && tshift>2)
        tshift=tshift/1000;%assume they mean milliseconds
    end
    
    hpan=newdatapanel(dname,1,1);
    
    %update the project structure
    hfile=findobj(hsane,'label','File');
    proj=get(hfile,'userdata');
    nfiles=length(proj.filenames)+1;
    proj.filenames{nfiles}=fname;
    proj.paths{nfiles}=path;
    proj.datanames{nfiles}=dname;
    proj.isloaded(nfiles)=1;
    proj.isdisplayed(nfiles)=1;
    proj.xcoord{nfiles}=xline;
    proj.ycoord{nfiles}=iline;
    proj.tcoord{nfiles}=t+tshift;
    proj.tshift(nfiles)=tshift;
    proj.xcdp{nfiles}=dx*(1:length(xline));
    proj.ycdp{nfiles}=dy*(1:length(iline));
    proj.dx(nfiles)=dx;
    proj.dy(nfiles)=dy;
    proj.depth(nfiles)=depthflag;
    proj.texthdr{nfiles}='Data from .mat file. No text header available';
    proj.texthdrfmt{nfiles}=nan;
    proj.segfmt{nfiles}=nan;
    proj.byteorder{nfiles}=nan;
    proj.tracehdr{nfiles}=nan;
    proj.binhdr{nfiles}=nan;
    proj.exthdr{nfiles}=nan;
    proj.kxline{nfiles}=nan;
    proj.datasets{nfiles}=seis;
    proj.gui{nfiles}=hpan;
    proj.isdeleted(nfiles)=0;
    proj.deletedondisk(nfiles)=0;
    proj.saveneeded(nfiles)=1;
    
    %save the path
    set(hreadmat,'userdata',path);
    
    plotimage3D(seis,t,{xline,proj.xcdp{nfiles}},{iline,proj.ycdp{nfiles}},dname,'seisclrs',dx,dy);
    set(gcf,'tag','fromsane','userdata',{nfiles hsane});
    set(gcf,'closeRequestFcn','sane(''closepifig'');')
    hview=findobj(hsane,'tag','view');
    uimenu(hview,'label',dname,'callback','sane(''popupfig'');','userdata',gcf);
    proj.pifigures{nfiles}=gcf;
    set(hfile,'userdata',proj);
    figure(hsane)
    
elseif(strcmp(action,'datainfo'))
    hinfo=gco;%the button clicked
    hsane=findsanefig;
    hpan=get(hinfo,'parent');%panel we are in
    idata=get(hpan,'userdata');%number of the dataset
    hfile=findobj(hsane,'label','File');
    proj=get(hfile,'userdata');%the project
    hmsg=findobj(hsane,'tag','message');
    %msgbox(hproj.texthdr{dataindex});
    pos=get(hsane,'position');
    x0=pos(1);
    y0=max([1 pos(2)-1.2*pos(4)]);
    hinfofig=figure('position',[x0 y0 .7*pos(3) 1.4*pos(4)],'name',...
        ['Info for dataset ' proj.datanames{idata}],'menubar','none','toolbar','none',...
        'numbertitle','off','tag','datainfo','userdata',hsane);
    %put up the text header
    hpan1=uipanel('title','Text Header','position',[.1 .05 .8 .67]);
    uicontrol(hpan1,'style','text','units','normalized','position',[0 0 1 1],...
        'string',proj.texthdr{idata},'HorizontalAlignment','left','tag','texthdr');
    nt=length(proj.tcoord{idata});
    nx=length(proj.xcoord{idata});
    ny=length(proj.ycoord{idata});
    dt=abs(proj.tcoord{idata}(2)-proj.tcoord{idata}(1));
    dx=proj.dx(idata);
    dy=proj.dy(idata);
    tshift=proj.tshift(idata);
    ntraces=nx*ny;
    tmax=proj.tcoord{idata}(end)-proj.tcoord{idata}(1);
    mb=round(ntraces*nt*4/10^6);
    [ylmin,ilmin]=min(proj.ycoord{idata});
    [ylmax,ilmax]=max(proj.ycoord{idata});
    [xlmin,ixlmin]=min(proj.xcoord{idata});
    [xlmax,ixlmax]=max(proj.xcoord{idata});
    datasummary=cell(1,6);
    datasummary{1,1}=['Dataset consists of ' int2str(ntraces) ' traces, ' num2str(tmax) ' seconds long, datum shift= ' num2str(tshift)];
    datasummary{1,2}=['Number of inlines= ' int2str(ny) ', number of crosslines= ' int2str(nx) ', number of time samples=' int2str(nt)];
    datasummary{1,3}=['Inline numbers run from ' int2str(ylmin) ' to ' int2str(ylmax) ', Xlines from ' int2str(xlmin) ' to ' int2str(xlmax)];
    datasummary{1,4}=['Y (inline) coordinates from ' num2str(proj.ycdp{idata}(ilmin)) ' to ' num2str(proj.ycdp{idata}(ilmax))...
        ', X coordinates from ' num2str(proj.xcdp{idata}(ixlmin)) ' to ' num2str(proj.xcdp{idata}(ixlmax))];
    datasummary{1,5}=['Time sample size= ' num2str(dt) ' seconds, inline separation= ' num2str(dy) ', crossline separation= ' num2str(dx)];
    datasummary{1,6}=['Dataset size (without headers) = ' int2str(mb) ' megabytes'];
    hpan2=uipanel('title','Data summary','position',[.1 .8 .8 .15]);
    uicontrol(hpan2,'style','text','units','normalized','position',[0 0 1 1],...
        'string',datasummary,'HorizontalAlignment','left','fontsize',10,'tag','datasummary','userdata',idata);
    
    ht=.02;
    xnow=.1;
    ynow=.8-2*ht;
    wid=.2;
    uicontrol(hinfofig,'style','pushbutton','string','Trace headers','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'callback','sane(''showtraceheaders'');');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','text','string','# of trace headers to show:','units','normalized',...
        'position',[xnow ynow wid ht],'horizontalalignment','right');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','edit','string','1000','tag','ntraces','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'tooltipstring','Enter a positive number or ''all''',...
        'userdata',idata);
    xnow=.1;
    ynow=ynow-ht;
    uicontrol(hinfofig,'style','pushbutton','string','Binary header','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'callback','sane(''showbinaryheader'');');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','text','string','Applied time shift:','units','normalized',...
        'position',[xnow ynow wid ht],'horizontalalignment','right');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','edit','string',num2str(proj.tshift(idata)),'tag','tshift','units','normalized',...
        'position',[xnow,ynow,.5*wid,ht],'tooltipstring','Enter a value in seconds or depth units',...
        'userdata',idata,'callback','sane(''changetshift'');');
    xnow=xnow+.5*wid;
    uicontrol(hinfofig,'style','text','string','<<You can change this value','units','normalized',...
        'position',[xnow ynow 1.5*wid ht],'horizontalalignment','left');
    
    hppt=addpptbutton([.95 .95 .05 .05]);
    set(hppt,'userdata',['Info for dataset ' proj.datanames{idata}]);
    
    hfigs=get(hmsg,'userdata');
    set(hmsg,'userdata',[hfigs hinfofig]);
elseif(strcmp(action,'projectnamechange'))
    hfile=findobj(gcf,'tag','file');
    proj=get(hfile,'userdata');
    hprojname=gcbo;
    proj.name=get(hprojname,'string');
    set(gcf,'name',['SANE, Project: ' proj.name])
    set(hfile,'userdata',proj);
elseif(strcmp(action,'saveproject')||strcmp(action,'saveproj'))
    % The project file is a mat file with two variables: proj and datasets. Proj is a structure and
    % datasets is a cell array. Proj has a field called datasets but this is always saved to disk as
    % null and the datasets are sames separately in the cell array. Also in the proj structure are
    % fields isloaded and isdisplayed. When a project is loaded, only proj is read at first and a
    % dialog is presented showing which datasets were previously loaded and/or displayed. The user
    % can then choose to load and display as before or make any changes desired. Datasets that are
    % currently in memory are included in project as proj.datasets. All datasets, in memory or not,
    % are found in the datasets cell array. When a dataset is moved out of memory, it is saved into
    % the datasets array where it can be retrieved when desired. Syntax for retrieving a dataset
    % matobj=matfile([path filename]);
    % cdataset=matobj.datasets(1,thisdataset);%variable thisdataset is the index of the dataset
    % dataset=cdataset{1};
    % Syntax for saveing a dataset
    % matobj=matfile([path filename],'writable',true);
    % matobj.datasets(1,thisdataset)={dataset};
    % There does not appear to be a need to formally close a mat file after writing to it.
    % There does not seem to be a way to load a portion of a dataset. I have to load it all at once.
    %
    
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    hmsg=findobj(hsane,'tag','message');
    proj=get(hfile,'userdata');
    filename=proj.projfilename;
    path=proj.projpath;
    %newprojectfile=0;
    if(isempty(filename) || isempty(path))
        [filename, path] = uiputfile('*.mat', 'Specify project filename');
        if(filename==0)
            msgbox('Project save cancelled');
            return;
        end
        %ind=strfind(filename,'.mat');
        %if(isempty(ind))
        if(~contains(filename,'.mat'))
            filename=[filename '.mat'];
        end
        proj.projfilename=filename;
        proj.projpath=path;
        set(hfile,'userdata',proj);
        %newprojectfile=1;
        if(exist([path filename],'file'))
            delete([path filename]);
        end
    end
    set(hmsg,'string','Saving project ...')
    waitsignalon
    %plan: strip out the datasets from the project. Make sure we have all of the datasets saved in
    %the datasets cell array on disk. Active datasets will be automatically moved into the proj
    %structure on loading.
    datasets=proj.datasets;
    pifigs=proj.pifigures;
    gui=proj.gui;
    proj.datasets={};%save it as an empty cell
    proj.pifigures={};%don't save graphics handles
    proj.gui={};
    disp('opening mat file')
    matobj=matfile([path filename],'Writable',true);
    
   
    isave=proj.saveneeded;
    %save any new datasets
    if(sum(isave)>0)
        disp('saving datasets')
        set(hmsg,'string','Saving new datasets');
        for k=1:length(isave)
            if(isave(k)==1)
                if(isempty(datasets(1,k)))
                    error('attempt to save empty dataset');
                end
                matobj.datasets(1,k)=datasets(1,k);%writes to disk
            end
        end
    end
    %check for newly deleted datasets
    ndatasets=length(datasets);
    for k=1:ndatasets
        if(proj.isdeleted(k)==1 && proj.deletedondisk(k)==0)
            matobj.datasets(1,k)={[]};
            proj.deletedondisk(k)=1;
        end
    end
    disp('writing project structure')
    set(hmsg,'string','Writing project structure');
    proj.saveneeded=zeros(1,ndatasets);
    matobj.proj=proj;%this writes the project structure
    proj.datasets=datasets;
    proj.pifigures=pifigs;
    proj.gui=gui;
    set(hfile,'userdata',proj)
    waitsignaloff
    set(hsane,'name',['SANE, Project file: ' filename]);
    set(hmsg,'string',['Project ' filename ' saved'])
    
elseif(strcmp(action,'saveprojectas'))
    % In this case we squeeze out any deleted datasets
    
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(hsane,'tag','message');
%     filename=proj.projfilename;
%     path=proj.projpath;
    [filename, path] = uiputfile('*.mat', 'Specify project filename');
    if(filename==0)
        msgbox('Project save cancelled');
        return;
    end
    if(exist([path filename],'file'))
        delete([path filename]);
    end
    %     ind=strfind(filename,'.mat');
    %     if(isempty(ind))
    if(~contains(filename,'.mat'))
        filename=[filename '.mat'];
    end
    if(exist([path filename],'file'))
        delete([path filename]);
    end
    set(hmsg,'string',['Saving project into ' path filename])
    %open the old file
    mOld=matfile([proj.projpath proj.projfilename]);
    
%     proj.projfilename=filename;
%     proj.projpath=path;
    set(hfile,'userdata',proj);
    waitsignalon
    nfiles=length(proj.datanames);
    for k=1:nfiles
       if(proj.isdeleted(k)~=1)
           if(isempty(proj.datasets{k}))
               proj.datasets(1,k)=mOld.datasets(1,k);
           end
       end
    end
    %ok, proj,datasets is fully loaded with those that we are keeping
    ind=proj.isdeleted~=1;
    datasets=proj.datasets(ind);%these are the keepers
    newproj=makeprojectstructure;
    newproj.projfilename=filename;
    newproj.projpath=path;
    newproj.filenames=proj.filenames(ind);
    newproj.paths=proj.paths(ind);
    newproj.datanames=proj.datanames(ind);
    newproj.isloaded=proj.isloaded(ind);
    newproj.isdisplayed=proj.isdisplayed(ind);
    newproj.xcoord=proj.xcoord(ind);
    newproj.ycoord=proj.ycoord(ind);
    newproj.tcoord=proj.tcoord(ind);
    newproj.tshift=proj.tshift(ind);
    newproj.xcdp=proj.xcdp(ind);
    newproj.ycdp=proj.ycdp(ind);
    newproj.dx=proj.dx(ind);
    newproj.dy=proj.dy(ind);
    newproj.depth=proj.depth(ind);
    newproj.texthdr=proj.texthdr(ind);
    newproj.texthdrfmt=proj.texthdrfmt(ind);
    newproj.segfmt=proj.segfmt(ind);
    newproj.byteorder=proj.byteorder(ind);
    newproj.binhdr=proj.binhdr(ind);
    newproj.exthdr=proj.exthdr(ind);
    newproj.tracehdr=proj.tracehdr(ind);
    newproj.kxline=proj.kxline(ind);
    newproj.isdeleted=proj.isdeleted(ind);
    newproj.deletedondisk=proj.deletedondisk(ind);
    newproj.saveneeded=zeros(size(ind));
    
    matobj=matfile([path filename],'Writable',true);
    matobj.proj=newproj;
    matobj.datasets=datasets(ind);
 
    newproj.pifigures=proj.pifigures(ind);
    newproj.datasets=datasets;
    
    %delete any gui panels
    for k=1:length(proj.gui)
        if(isgraphics(proj.gui{k}))
            delete(proj.gui{k});
        end
    end
    hmpan=findobj(hsane,'tag','master_panel');
    udat=get(hmpan,'userdata');
    geom=udat{2};
    geom(4)=geom(9);%resets the initial y coordinates of the panels
    udat{2}=geom;
    set(hmpan,'userdata',udat);
    set(hsane,'name',['SANE, Project file: ' filename]);
    set(hmsg,'string',['Project ' filename ' saved'])
    proj=newproj;
    %hmpan=findobj(hsane,'tag','master_panel');
    %udat=get(hmpan,'userdata');
    udat{1}=[];
    set(hmpan,'userdata',udat);
    
    ndatasets=length(proj.datanames);
    proj.gui=cell(1,ndatasets);
    
    % put up datapanels for each dataset, read and display if needed
    %hpanels=cell(1,ndatasets);
    %PIfigs=cell(1,ndatasets);
    for k=1:ndatasets
        if(proj.isdeleted(k)~=1)
            proj.gui{k}=newdatapanel(proj.datanames{k},proj.isloaded(k),proj.isdisplayed(k));
        end
    end
    waitsignaloff
    set(hfile,'userdata',proj);
    hpn=findobj(hsane,'tag','project_name');
    set(hpn,'string',proj.name)
elseif(strcmp(action,'loadproject'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    hmsg=findobj(hsane,'tag','message');
    [fname,path]=uigetfile('*.mat','Choose the SANE Project file (.mat) to load');
    if(fname==0)
        return
    end
    m=matfile([path fname],'writable',true);
    varnames=fieldnames(m);
    ivar=[];
    for k=1:length(varnames)
        ind=strcmp(varnames{k},'proj');
        if(ind~=0)
            ivar=k;
        end
    end
    if(isempty(ivar))
        msgbox('Chosen file is not a SANE Project file, Nothing has been loaded');
        return
    end
    set(hmsg,'string',['Loading project ' path fname ' ... '])
    %check for existing project and delete any data panels
    projold=get(hfile,'userdata');
    if(~isempty(projold))
       hpanels=projold.gui;
       for k=1:length(hpanels)
           if(isgraphics(hpanels{k}))
               delete(hpanels{k});
           end
       end
       for k=1:length(projold.pifigures)
           if(isgraphics(projold.pifigures{k}))
               delete(projold.pifigures{k});
           end
       end
       hview=findobj(hsane,'tag','view');
       hk=get(hview,'children');
       delete(hk);
       hmpan=findobj(gcf,'tag','master_panel');
       udat=get(hmpan,'userdata');
       udat{1}={};
       geom=udat{2};
       geom(4)=geom(9);%resets the initial y coordinates of the panels
       udat{2}=geom;
       set(hmpan,'userdata',udat);
    end
    waitsignalon 
    proj=getfield(m,varnames{ivar});
    ndatasets=length(proj.datanames);
    proj.projfilename=fname;
    proj.projpath=path;
    proj.pifigures=cell(1,ndatasets);
    proj.gui=cell(1,ndatasets);
    proj.datasets=cell(1,ndatasets);
    %check proj.segyrev and if necessary change from cell to ordinary array
    if(isfield(proj,'segyrev'))
        if(iscell(proj.segyrev))
            tmp=proj.segyrev{:};
            if(length(tmp)~=length(proj.datanames))
                tmp=zeros(1,length(proj.datanames));
            end
            %check segyrev for validity
            for k=1:length(tmp)
                if(isfield(proj.tracehdr{k},'CdpX'))
                    tmp(k)=1;
                else
                    tmp(k)=0;
                end
            end
            proj.segyrev=tmp;
            m.proj=proj;
        end
    else
        %ok we are missing a segyrev field so we insert one
        nd=length(proj.datanames);
        tmp=zeros(1,nd);
        for k=1:nd
            if(isfield(proj.tracehdr{k},'CdpX'))
                    tmp(k)=1;
                else
                    tmp(k)=0;
            end
        end
        proj.segyrev=tmp;
        m.proj=proj;
    end
    set(hfile,'userdata',proj);
    loadprojectdialog
    return;
elseif(strcmp(action,'cancelprojectload'))
    hdial=gcf;
    hsane=get(hdial,'userdata');
    delete(hdial);
    hmsg=findobj(hsane,'tag','message');
    set(hmsg,'string','Project load cancelled');
    waitsignaloff
    return
elseif(strcmp(action,'loadprojdial'))
    hdial=gcf;
    hsane=get(hdial,'userdata');
    hbutt=gcbo;
    subaction=get(hbutt,'tag');
    hh=findobj(hdial,'tag','loaded');
    hloaded=get(hh,'userdata');
    hh=findobj(hdial,'tag','display');
    hdisplayed=get(hh,'userdata');
    switch subaction
        case 'allyes'
            set([hloaded hdisplayed],'value',2);
            
        case 'allno'
            set([hloaded hdisplayed],'value',1);
            
        case 'continue'
            hfile=findobj(hsane,'tag','file');
            proj=get(hfile,'userdata');
            ndata=length(hloaded);
            for k=1:ndata
                if(proj.isdeleted(k)~=1)
                    proj.isloaded(k)=get(hloaded(k),'value')-1;
                    proj.isdisplayed(k)=get(hdisplayed(k),'value')-1;
                end
            end
            set(hfile,'userdata',proj);
            delete(hdial);
            figure(hsane);
            sane('loadproject2');  
    end
    
elseif(strcmp(action,'loadproject2'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    hmsg=findobj(hsane,'tag','message');
    t0=clock;
    proj=get(hfile,'userdata');
    ndatasets=length(proj.datanames);
    m=matfile([proj.projpath proj.projfilename]);
    % put up datapanels for each dataset, read and display if needed
    %hpanels=cell(1,ndatasets);
    %PIfigs=cell(1,ndatasets);
    for k=1:ndatasets
        if(proj.isdeleted(k)~=1)
            proj.gui{k}=newdatapanel(proj.datanames{k},proj.isloaded(k),proj.isdisplayed(k));
            if(proj.isloaded(k)==1 || proj.isdisplayed(k)==1)%see if we read the dataset from disk
                cseis=m.datasets(1,k);%this reads it
                if(proj.isloaded(k)==1)
                    proj.datasets(1,k)=cseis;
                end
            end
            if(proj.isdisplayed(k)==1)%see if we display the dataset
                plotimage3D(cseis{1},proj.tcoord{k},{proj.xcoord{k},proj.xcdp{k}},{proj.ycoord{k},proj.ycdp{k}},...
                    proj.datanames{k},'seisclrs',proj.dx(k),proj.dy(k));
                %check for horizons
                if(isfield(proj,'horizons'))
                    if(~isempty(proj.horizons{k}))
                        plotimage3D('importhorizons',proj.horizons{k});
                    end
                end
                %
                set(gcf,'tag','fromsane','userdata',{k hsane});
                set(gcf,'closeRequestFcn','sane(''closepifig'');');
                hview=findobj(hsane,'tag','view');
                uimenu(hview,'label',proj.datanames{k},'callback','sane(''popupfig'');','userdata',gcf);
                proj.pifigures{k}=gcf;
                figure(hsane)
            end
        end
    end
    %check for the existence of horizons as a field
    if(~isfield(proj,'horizons'))
        proj.horizons=cell(1,ndatasets);
    end
    waitsignaloff
    set(hfile,'userdata',proj);
    hpn=findobj(hsane,'tag','project_name');
    set(hpn,'string',proj.name)
    
    tnow=clock;
    timeused=etime(tnow,t0)/60;
    if(timeused>1)
        timeused=round(100*timeused)/100;
        set(hmsg,'string',['Project ' proj.name ' loaded in ' num2str(timeused) ' min'])
    else
        timeused=round(60*10*timeused)/10;
        set(hmsg,'string',['Project ' proj.name ' loaded in ' num2str(timeused) ' sec'])
    end
    set(hsane,'name',['SANE, Project: ' proj.name ])

elseif(strcmp(action,'newproject'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    %check for existing project and delete any data panels
    projold=get(hfile,'userdata');
    if(~isempty(projold))
        hpanels=projold.gui;
        for k=1:length(hpanels)
            if(isgraphics(hpanels{k}))
                delete(hpanels{k});
            end
        end
        for k=1:length(projold.pifigures)
            if(isgraphics(projold.pifigures{k}))
                delete(projold.pifigures{k});
            end
        end
        hview=findobj(hsane,'tag','view');
        hk=get(hview,'children');
        delete(hk);
        hmpan=findobj(gcf,'tag','master_panel');
        udat=get(hmpan,'userdata');
        geom=udat{2};
        geom(4)=geom(9);%resets the initial y coordinates of the panels
        udat{1}={};
        udat{2}=geom;
        set(hmpan,'userdata',udat);
    end
    proj=makeprojectstructure;
    set(hfile,'userdata',proj);
    hpn=findobj(hsane,'tag','project_name');
    set(hpn,'string',proj.name)
    hmsg=findobj(hsane,'tag','message');
    set(hmsg,'string','Now read some data into your project')
    set(hsane,'name',['SANE, Project: ' proj.name ])
elseif(strcmp(action,'readhor'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    %put up dialog window
    [path]=uigetdir('Select horizon (.xyz file) folder');
    if(path==0)
        return
    end
    files=dir(fullfile(path,'*.xyz'));
    if(isempty(files))
        msgbox('Chosen folder has no .xyz files');
        return;
    end
    pos=get(hsane,'position');
    xc=pos(1)+.5*pos(3);
    yc=pos(2)+.5*pos(4);
    fwd=1000;
    fht=400;
    hdial=figure('position',[xc-.5*fwd, yc-.5*fht, fwd, fht],'name','SANE: Horizon import dialog',...
        'numbertitle','off','menubar','none','toolbar','none');
    set(hdial,'userdata',hsane);
    
    %table showing datasets
    ndata=length(proj.datanames);
    d=cell(ndata,2);
    nmax=0;
    for k=1:ndata
       d(k,:)={proj.datanames{k},false};
       nm=length(proj.datanames{k});
       if(nm>nmax)
           nmax=nm;
           kmax=k;%points to longest name
       end
    end
    %determine pixel size of longest name
    ht=uicontrol(hdial,'style','text','string',proj.datanames{kmax},'units','pixels','visible','off');
    pxsize=ht.Extent;
    delete(ht);
    wid=5*pxsize(3)/fwd;
    ht=2*ndata*pxsize(4)/fht;
    xnow=.05;ynow=.8-ht;
    htab=uitable(hdial,'units','normalized','position',[xnow,ynow,wid,ht],'data',d,...
        'columneditable',[false,true],'columnname',{'data','assoc.'},'tag','datasets');
    ext=get(htab,'extent');
    pos=get(htab,'position');
    set(htab,'position',[pos(1) pos(2)+(pos(4)-ext(4)) ext(3:4)])
    pos=get(htab,'position');
    ynow=pos(2)+pos(4);
    uicontrol(hdial,'style','text','string','Choose the datasets to associate with the horizons',...
        'units','normalized','position',[xnow,ynow,.4,.05],'horizontalalignment','left','fontsize',10);
    nf=length(files);
    d2=cell(nf,3);
    for k=1:nf
        d2(k,:)={files(k).name, false, ''};
    end
    wid=.9-xnow;
    ht=.8;
    %ynow=ynow-pos(4)-.05;
    ynow=.2;
    htab2=uitable(hdial,'units','normalized','position',[xnow,ynow,wid,ht],'data',d2,...
        'columneditable',[false,true,true],'columnname',{'File','import','Horizon name'},'columnwidth',...
        {round(wid*fwd*.8),round(wid*fwd*.05),round(wid*fwd*.15)},'tag','files','userdata',path);
    ext2=get(htab2,'extent');
    pos2=get(htab2,'position');
    set(htab2,'position',[pos2(1), pos(2)-ext2(4)-.1 ext2(3:4)])
    pos2=get(htab2,'position');
    ynow=pos2(2)+pos2(4);
    uicontrol(hdial,'style','text','string','Choose the horizon files to import and a name for each horizon',...
        'units','normalized','position',[xnow,ynow,.4,.05],'horizontalalignment','left','fontsize',10);
    ynow=.1;
    wid=.1;ht=.05;
    uicontrol(hdial,'style','pushbutton','string','Done','units','normalized','tag','done',...
        'position',[xnow,ynow,wid,ht],'callback','sane(''readhor2'');');
    uicontrol(hdial,'style','pushbutton','string','Cancel','units','normalized','tag','cancel',...
        'position',[xnow+wid+.05,ynow,wid,ht],'callback','sane(''readhor2'');');
    return;
elseif(strcmp(action,'readhor2'))
    hdial=gcf;
    hsane=get(hdial,'userdata');
    hbut=gcbo;
    tag=get(hbut,'tag');
    if(strcmp(tag,'cancel'))
        hmsg=findobj(hsane,'tag','message');
        set(hmsg,'string','Horizon import cancelled')
        delete(hdial)
        return;
    end
    
    hd=findobj(hdial,'tag','datasets');
    data=hd.Data;
    hf=findobj(hdial,'tag','files');
    files=hf.Data;
    %make sure there is at least one thing checked in each
    nd=size(data,1);
    ichkd=zeros(nd,1);
    for k=1:nd
        if(data{k,2})
            ichkd(k)=1;
        end
    end
    if(sum(ichkd)==0)
        msgbox('You must check at least one dataset');
        return;
    end
    nf=size(files,1);
    ichkf=zeros(nf,1);
    for k=1:nf
        if(files{k,2})
            ichkf(k)=1;
        end
    end
    if(sum(ichkf)==0)
        msgbox('You must check at least one file');
        return;
    end
    %make sure we have a short name for each horizon
    namesok=true;
    for k=1:nf
        if(ichkf(k)==1)
           if(isempty(files{k,3}))
               namesok=false;
           end
        end
    end
    if(~namesok)
       msgbox('You must provide a Horizon Name for each imported file');
       return
    end
    %check that the associated datasets are the same size
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    nx=0;ny=0;
    for k=1:nd
        if(ichkd(k)==1)
            if(nx==0)
                x=proj.xcoord{k};
                y=proj.ycoord{k};
                nx=length(x);
                ny=length(y);
            else
                nx2=length(proj.xcoord{k});
                ny2=length(proj.ycoord{k});
                if((nx~=nx2)||(ny~=ny2))
                    msgbox('Horizon files can only be associated with multiple datasets if the datasets are the same size');
                    return;
                end
            end
        end
    end
    %ok, good to go
    path=get(hf,'userdata');
    delete(hdial);
    figure(hsane);
    hmsg=findobj(hsane,'tag','message');
    inlinemin=min(y);
    xlinemin=min(x);
    waitsignalon
    %put an ampty horizon structure in each dataset
    for k=1:nf %loop over the horizon files
        
        if(ichkf(k)==1)
            set(hmsg,'string',['Importing horizon file ' files{k,1}]);
            drawnow;
            [value,xf,yf,xlf,ilf]=readhorizonfile([path '\' files{k,1}]); %#ok<ASGLU>
            %check for milliseconds and correct
            if(max(value)>10)
                value=value/1000;
            end
            %sort into a survey-sized array
            horizon=nan*zeros(nx,ny);
            set(hmsg,'string','Sorting ...');
            drawnow;
            for jj=1:length(value)
               ii=round(ilf(jj)-inlinemin)+1;
               kk=round(xlf(jj)-xlinemin)+1;
               if(ii>=1 && ii<=ny && kk>=1 && kk<=nx)
                  horizon(kk,ii)=value(jj); 
               end
            end
            %now load this horizon into project structure and associate with the datasets
            thishor=files{k,3};%name of this horizon
            for jj=1:nd
                if(ichkd(jj)==1)
                    %make a horizon structure if needed
                    if(isempty(proj.horizons{jj}))
                        %make a horizon structure
                        horstruct.horizons=[];
                        horstruct.filenames={};
                        horstruct.names={};
                        horstruct.showflags=[];
                        horstruct.colors={};
                        horstruct.linewidths=[];
                        horstruct.handles=[];
                    else
                        horstruct=proj.horizons{jj};
                    end
                    nhors=length(horstruct.names);%number of horizons for this dataset before this one
                    %check for exisiting horizon of same name
                    jjhor=nhors+1;%anticipate this is a new horizon
                    if(nhors>0)
                        for kk=1:nhors
                           if(strcmp(thishor,horstruct.names(kk)))
                               jjhor=kk;
                               break;
                           end
                        end
                    end
                    horstruct.horizons(jjhor,:,:)=horizon;
                    horstruct.filenames{jjhor}=files{k,1};
                    horstruct.names{jjhor}=files{k,3};
                    horstruct.showflags(jjhor)=1;
                    horstruct.colors{jjhor}=[];
                    horstruct.linewidths(jjhor)=1;
                    horstruct.handles(jjhor)=-1;% a -1 always fails the isgraphics test
                    proj.horizons{jj}=horstruct;
                end
                
            end
            
        end
    end
    set(hfile,'userdata',proj)
    set(hmsg,'string','Horizon import complete');
    waitsignaloff
    
elseif(strcmp(action,'datamemory'))
    %This gets called if the "in memory" radio buttons are toggled
    %We want to be able to control whether a dataset is in memory or not. When in memory, then it is
    %present in the "datasets" field of the proj structure. If it is displayed, then it is also
    %present in the userdata of a plotimage3D window. Once a dataset is displayed, we may want to
    %clear it from memory, otherwise there are effectively two copies of it in memory. We would
    %really only want to save it in memory if we planned on applying an operation to it. If a
    %dataset has just been loaded to SEGY and not yet saved in the project, then we need to write it
    %to disk first before clearing it from memory.
    hsane=findsanefig;
    hbut=gcbo;%will be either 'Y' or 'N'
    hbg=get(hbut,'parent');
    hpan=get(hbg,'parent');
    hmsg=findobj(hsane,'tag','message');
    idata=hpan.UserData;%the dataset number
    choice=get(hbut,'string');%this will be 'Y' or 'N'
    hfile=findobj(hsane,'tag','file');
    proj=hfile.UserData;
    if(strcmp(choice','N'))
        %dataset is being cleared from memory
        %first check to ensure that the project has been save so that a project file exists on disk
        if(isempty(proj.projfilename)||isempty(proj.projpath))
            msgbox('Please save the project to disk before clearing data from memory');
            return;
        end
        %we also close any display
%         hfig=proj.pifigures(idata);
%         if(isgraphics(hfig))
%             close(hfig);
%         end
%         proj.pifigures{idata}=[];
%         proj.isdisplayed(idata)=0;
        proj.isloaded(idata)=0;
        %now we need to be sure that the data exists on disk before clearing it from memory
        if(proj.saveneeded(idata)==1)
            %open the project file
            matobj=matfile([proj.projpath proj.projfilename],'writable',true);
            [meh,ndatasetsondisk]=size(matobj,'datasets'); %#ok<ASGLU>%this is the number datasets that exist on disk
            ndatasets=length(proj.datasets);%this is how many datasets there are in total
            if(ndatasetsondisk<ndatasets)
                nnew=ndatasetsondisk+1:ndatasets;
                matobj.datasets(1,nnew)=cell(1,length(nnew));
            end
            if(isempty(proj.datasets(1,idata)))
                error('attempt to save empty dataset');
            end
            matobj.datasets(1,idata)=proj.datasets(1,idata);
            proj.saveneeded(idata)=0;
            proj.datasets{idata}=[];
            pifigs=proj.pifigures;
            proj.pifigures=[];
            matobj.proj=proj;%need to save the project for consistency on disk
            proj.pifigures=pifigs;
        end
        proj.datasets{idata}=[];
%         %set the isdisplayed button to no
%         hno=findobj(hpan,'tag','displayno');
%         set(hno,'value',0);
        set(hfile,'userdata',proj);
        set(hmsg,'string',['Datset ' proj.datanames{idata} ' cleared from memory but may still be displayed']);
    else
        %dataset is being loaded into memory and displayed
        hmpan=findobj(gcf,'tag','master_panel');
        udat=hmpan.UserData;
        udat{3}=idata;%this flags to reload which dataset we are reading
        hmpan.UserData=udat;
        sane('reloaddataset');%this updates proj and displays the dataset
        %set the isdisplayed button to yes
        hyes=findobj(hpan,'tag','displayyes');
        set(hyes,'value',1);
    end
elseif(strcmp(action,'datadisplay'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    hmsg=findobj(hsane,'tag','message');
    proj=get(hfile,'userdata');
    %determine choice
    hbut=gcbo;
    butname=get(hbut,'string');
    val=get(hbut,'value');
    if((strcmp(butname,'Y')&&val==1)||(strcmp(butname,'N')&&val==0))
        choice='display';
    else
        choice='dontdisplay';
    end
    %deternime dataset number
    hpan=get(get(hbut,'parent'),'parent');
    idata=get(hpan,'userdata');
    
    switch choice
        case 'display'
            waitsignalon
            %check if dataset is loaded
            if(~proj.isloaded(idata)||isempty(proj.datasets{idata}))
                hmpan=findobj(gcf,'tag','master_panel');
                udat=hmpan.UserData;
                udat{3}=idata;%this flags to reload which dataset we are reading
                hmpan.UserData=udat;
                sane('reloaddataset');%this loads and displays and updates proj
                %set the isdisplayed button to yes
                hyes=findobj(hpan,'tag','displayyes');
                set(hyes,'value',1);
                hyes=findobj(hpan,'tag','memoryyes');
                set(hyes,'value',1);
            else
                %now display
%                 plotimage3D(proj.datasets{idata},proj.tcoord{idata},proj.xcoord{idata},...
%                     proj.ycoord{idata},proj.datanames{idata},'seisclrs',proj.dx(idata),proj.dy(idata))
                plotimage3D(proj.datasets{idata},proj.tcoord{idata},{proj.xcoord{idata},proj.xcdp{idata}},...
                    {proj.ycoord{idata},proj.ycdp{idata}},proj.datanames{idata},'seisclrs',proj.dx(idata),proj.dy(idata))
                %check for horizons
                if(isfield(proj,'horizons'))
                    if(~isempty(proj.horizons{idata}))
                        plotimage3D('importhorizons',proj.horizons{idata});
                    end
                end
                set(gcf,'tag','fromsane','userdata',{idata hsane});
                set(gcf,'closeRequestFcn','sane(''closepifig'');')
                hview=findobj(hsane,'tag','view');
                uimenu(hview,'label',proj.datanames{idata},'callback','sane(''popupfig'');','userdata',gcf);
                proj.isdisplayed(idata)=1;
                proj.pifigures{idata}=gcf;
                set(hfile,'userdata',proj);
                set(hmsg,'string',['Dataset ' ,proj.datanames{idata} ' displayed'])
            end
            waitsignaloff
        case 'dontdisplay'
            hpifig=proj.pifigures{idata};
            if(isgraphics(hpifig))
                figure(hpifig);
                sane('closepifig');
            else
                proj.isdisplayed(idata)=0;
                proj.pifigures{idata}=[];
                set(hfile,'userdata',proj)
            end
            
    end
    figure(hsane)
elseif(strcmp(action,'closepifig'))
    hthisfig=gcbf;
    if(strcmp(get(hthisfig,'tag'),'sane'))
        %ok, the call came from SANE
        hpan=get(get(gcbo,'parent'),'parent');%should be the panel of the dataset whose figure is closing
        idat=get(hpan,'userdata');
        hfile=findobj(hthisfig,'tag','file');
        proj=get(hfile,'userdata');
        hthisfig=proj.pifigures{idat};
    end
    test=get(hthisfig,'name');
    %ind=strfind(test,'plotimage3D');
    tag=get(hthisfig,'tag');
    udat=get(hthisfig,'userdata');
    if(length(udat)>1)
        hsane=udat{2};
    else
        hsane=findsanefig;
    end
    hview=findobj(hsane,'tag','view');
    if(contains(test,'plotimage3D')&&strcmp(tag,'fromsane')&&iscell(udat)&&length(udat)==2)
        %if we get this far then we have a legitimate closure of a pifig
        %that pifig is called hthisfig
        hmenus=get(hview,'children');
        for k=1:length(hmenus)
           fig=get(hmenus(k),'userdata');
           if(fig==hthisfig)
              delete(hmenus(k));
           end
        end
%         PLOTIMAGE3DTHISFIG=proj.pifigures{idata};
%         flag=get(hg,'value');
%         if(flag==1)
%             plotimage3D('groupex');
%         else
%             plotimage3D('ungroupex')
%         end
        %check for horstruct
        hfile=findobj(hsane,'tag','file');
        proj=get(hfile,'userdata');
        hhor=findobj(hthisfig,'tag','horizons');
        idata=udat{1};
        if(~isempty(hhor))
           horstruct=get(hhor,'userdata');
           proj.horizons{idata}=horstruct;
        end
        
        plotimage3D('closesane');
        if(isgraphics(hthisfig))
            return; %this happens if they choose not to close
        end
        %delete(hthisfig);
        hmsg=findobj(hsane,'tag','message');
        
        
        proj.pifigures{idata}=[];
        hpanels=proj.gui;
        hpan=hpanels{idata};
        hno=findobj(hpan,'tag','displayno');
        set(hno,'value',1);
        proj.isdisplayed(idata)=0;
        %ungroup if needed
        hg=findobj(hpan,'tag','group');
        val=get(hg,'value');
        if(val==1)
            set(hg,'value',0);
        end
        set(hfile,'userdata',proj);
        bn=questdlg('Do you want to keep the data in memory?','Memory question','Yes','No','No');
        if(strcmp(bn,'No'))
            %remove from memory
            waitsignalon
            %need to check if it has been saved before we delete it
            if(~isempty(proj.projfilename))
                %this means the project has been save at least onece. However, the dataset might not
                %have been. So, we check for dataset saved.
                mObj=matfile([proj.projpath proj.projfilename],'writable',true);
                [meh,ndatasetsondisk]=size(mObj,'datasets'); %#ok<ASGLU>
                ndatasets=length(proj.datasets);
                if(ndatasets>ndatasetsondisk)
                    jdata=ndatasetsondisk+1:ndatasets;
                    nnew=length(jdata);
                    mObj.datasets(1,jdata)=cell(1,nnew);
                end
                %check total project datasize and compare to size of datasets on disk. If the disk
                %size is greater than the computed data size, then we can assume the dataset has
                %already been written to disk
                info=whos(mObj,'datasets');
                if(info.bytes<datasetsize)
                    set(hmsg,'string','Saving dataset to disk');
                    if(isempty(proj.datasets(1,idata)))
                        error('attempt to save empty dataset');
                    end
                    mObj.datasets(1,idata)=proj.datasets(1,idata);
                end
                waitsignaloff
            else
                sane('saveproject');
                proj=get(hfile,'userdata');
            end
            proj.datasets{idata}=[];
            hno=findobj(hpan,'tag','memoryno');
            set(hno,'value',1);
            proj.isloaded(idata)=0;
            set(hmsg,'string','Dataset removed from memory')
            set(hfile,'userdata',proj);
        else
            set(hmsg,'string','Display closed but data retained in memory');
        end
        
        figure(hsane)
    end
elseif(strcmp(action,'datanamechange'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(hsane,'tag','message');
    hnamebox=gcbo;
    idata=get(get(hnamebox,'parent'),'userdata');
    oldname=proj.datanames{idata};
    newname=get(hnamebox,'string');
    proj.datanames{idata}=newname;
    set(hfile,'userdata',proj);
    %look for open pi3d windows and change those
    hview=findobj(hsane,'tag','view');
    hkids=get(hview,'children');
    for k=1:length(hkids)
        if(strcmp(get(hkids(k),'label'),oldname))%see if the name matches
            hpifig=get(hkids(k),'userdata');
            if(isgraphics(hpifig))
                udat=get(hpifig,'userdata');
                jdata=udat{1};%there might be two datasets with the same name so jdata must match idata
                if(jdata==idata)
                    %this is it
                    plotimage3D('datanamechange',hpifig,newname);
                    set(hkids(k),'label',newname);
                end
            end
        end
    end
    set(hmsg,'string',[' dataset name changed to ' newname])
elseif(strcmp(action,'close'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    bn=questdlg('Do you want to save the project first?','Close SANE','Yes','No','Cancel','Yes');
    hmsg=findobj(hsane,'tag','message');
    hfigs=get(hmsg,'userdata');%figures needing closure other than PI3D figures
    switch bn
        case 'Cancel'
            set(hmsg,'string','Close cancelled')
            return;
        case 'Yes'
            sane('saveproject')
            %check if ppt is open and save it
            hppt=findobj(hsane,'tag','pptx');
            str=get(hppt,'string');
            if(strcmp(str,'Close PPT'))
                sane('pptx')
            end
            for k=1:length(hfigs)
                if(isgraphics(hfigs(k)))
                    delete(hfigs(k))
                end
            end
            delete(hsane)
            for k=1:length(proj.pifigures)
%                if(isgraphics(proj.pifigures{k}))
%                    delete(proj.pifigures{k});
%                end
                if(isgraphics(proj.pifigures{k}))
                    figure(proj.pifigures{k})
                    plotimage3D('close','Yes');
                end
            end
        case 'No'
            %check if ppt is open and save it
            hppt=findobj(hsane,'tag','pptx');
            str=get(hppt,'string');
            if(strcmp(str,'Close PPT'))
                sane('pptx')
            end
            for k=1:length(hfigs)
                if(isgraphics(hfigs(k)))
                    delete(hfigs(k))
                end
            end
            delete(hsane)
            for k=1:length(proj.pifigures)
%                if(isgraphics(proj.pifigures{k}))
%                    delete(proj.pifigures{k});
%                end
                if(isgraphics(proj.pifigures{k}))
                    figure(proj.pifigures{k});
                    plotimage3D('close','Yes');
                end
            end
    end
elseif(strcmp(action,'popupfig'))
    hmenu=gcbo;
    fig=get(hmenu,'userdata');
    if(isgraphics(fig))
        figure(fig);
    end
elseif(strcmp(action,'datadelete'))
    hsane=findsanefig;
    hbutt=gcbo;
    idata=get(get(hbutt,'parent'),'userdata');
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(hsane,'tag','message');
    %confirm
    choice=questdlg(['Please confirm the deletion of dataset ' proj.datanames{idata}],'Data deletion','Yes','No','Cancel','Yes');
    switch choice
        case 'No'
            set(hmsg,'string','Data deletion cancelled');
        case 'Cancel'
            set(hmsg,'string','Data deletion cancelled');
        case 'Yes'
            proj.isdeleted(idata)=1;%set deletion flag
            proj.deletedondisk(idata)=0;
            if(isgraphics(proj.pifigures{idata}))
                delete(proj.pifigures{idata});
            end
            proj.filenames{idata}=[];
            proj.paths{idata}=[];
            deadname=proj.datanames{idata};
            proj.datanames{idata}=[];
            proj.isloaded(idata)=0;
            proj.isdisplayed(idata)=0;
            proj.xcoord{idata}=[];
            proj.ycoord{idata}=[];
            proj.tcoord{idata}=[];
            proj.tshift(idata)=0;
            proj.datasets{idata}=[];
            proj.xcdp{idata}=[];
            proj.ycdp{idata}=[];
            proj.dx(idata)=0;
            proj.dy(idata)=0;
            proj.depth(idata)=0;
            proj.texthdr{idata}=[];
            proj.texthdrfmt{idata}=[];
            proj.segfmt{idata}=[];
            proj.byteorder{idata}=[];
            proj.binhdr{idata}=[];
            proj.exthdr{idata}=[];
            proj.tracehdr{idata}=[];
            proj.kxline{idata}=[];
            if(isgraphics(proj.gui{idata}))
                pos=get(proj.gui{idata},'position');
                delete(proj.gui{idata});
                uicontrol(hsane,'style','text','string',{['dataset ' deadname ' has been deleted.'],...
                    'This space will disappear when you save and reload the Project. Deletion on disk does not happen until you save the project'},...
                    'units','normalized','position',pos);
            end
            set(hmsg,'string',['dataset ' deadname ' has been deleted.'])
            set(hfile,'userdata',proj);
    end
elseif(strcmp(action,'group'))
    hsane=findsanefig;
    hg=gcbo;
    idata=get(get(hg,'parent'),'userdata');
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    if(proj.isdisplayed(idata)==0)
        msgbox({'Grouping only works if the dataset is displayed.' 'Display it first, then group.'});
        return
    end
    if(isgraphics(proj.pifigures{idata}))
        PLOTIMAGE3DTHISFIG=proj.pifigures{idata};
        flag=get(hg,'value');
        if(flag==1)
            plotimage3D('groupex');
        else
            plotimage3D('ungroupex')
        end
    else
        error('Logic error in SANE when trying to group/ungroup figures')
    end
elseif(strcmp(action,'pi3d:group'))
    %this is a message from plotimage3D saying either a group or an ungroup has happened
%     hpi3d=gcf;%if this happens then a pi3d figure is current
%     %now we verify that the pi3d figure is from sane
%     udat=get(hpi3D,'userdata');
%     tag=get(hpi3d,'tag');
%     if(strcmp(tag,'fromsane')&&length(udat)==2)
%         hsane=udat{2};
%     else
%         return; %if this happens then the logic has failed
%     end
    hsane=arg2{2};
    
    hgroup=PLOTIMAGE3DFIGS;%these are the grouped figures
    
    hmpan=findobj(hsane,'tag','master_panel');%the master panel is the key to SANE data panels
    udat2=get(hmpan,'userdata');
    hpanels=udat2{1};%the sane data panels
    idatas=zeros(size(hgroup));
    %loop over the grouped figures and find their sane data numbers
    for k=1:length(hgroup)
        udat3=get(hgroup(k),'userdata');
        if(strcmp(get(hgroup(k),'tag'),'fromsane'))
            idatas(k)=udat3{1};
        end    
    end
    %now loop over panels and compare their data numbers to those in the group
    for k=1:length(hpanels)
        hg=findobj(hpanels{k},'tag','group');
        idata=get(hpanels{k},'userdata');
        ind=find(idata==idatas, 1);
        if(~isempty(ind))
            set(hg,'value',1);
        else
            set(hg,'value',0);
        end
    end
elseif(strcmp(action,'writesegy'))
    hsane=findsanefig;
    hmsg=findobj(hsane,'tag','message');
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    iout=listdlg('Promptstring','Choose the dataset for output','liststring',proj.datanames,...
        'selectionmode','single','listsize',[500,300]);
    if(isempty(iout))
        return;
    end
    [fname,path]=uiputfile('*.sgy','Select the output file');
    if(isequal(fname,0) || isequal(path,0))
        msgbox('Output cancelled');
        return;
    end
    if(exist([path fname],'file'))
        delete([path fname]);
    end
    if(isempty(proj.datasets{iout}))
        %recall the dataset from disk
        mObj=matfile([pro.projpath proj.projfilename]);
        cseis=mObj.datasets(1,iout);
    else
        cseis=proj.datasets(1,iout);
    end
    waitsignalon
    set(hmsg,'string','Forming output array');
    seis=unmake3Dvol(cseis{1},proj.xcoord{iout},proj.ycoord{iout},proj.xcdp{iout},proj.ycdp{iout},...
        'kxlineall',proj.kxline{iout});
    dt=abs(proj.tcoord{iout}(2)-proj.tcoord{iout}(1));
    set(hmsg,'string','Beginning SEGY output');
    writesegy([path fname],seis,getsegyrev(iout),dt,proj.segfmt{iout},proj.texthdrfmt{iout},...
        proj.byteorder{iout},proj.texthdr{iout},proj.binhdr{iout},proj.exthdr{iout},...
        proj.tracehdr{iout},proj.bindef{iout},proj.trcdef{iout},hsane);
    
    waitsignaloff
    set(hmsg,'string',['Dataset ' [path fname] ' written']);
elseif(strcmp(action,'writemat'))
    msgbox('Sorry, feature not yet implemented')
    return;
elseif(strcmp(action,'starttask'))
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    proj=hfile.UserData;
    if(isempty(proj.datasets))
        msgbox('You need to load some data before you can do this!','Oh oh ...');
        return
    end
    %determine the task
    task=get(gcbo,'tag');
    parmset=getparmset(task);
    switch task
        case 'filter'
            sanetask(proj.datanames,parmset,task);
        case 'phasemap'
            return;
        case 'spikingdecon'
            sanetask(proj.datanames,parmset,task);
            return;
        case 'fdom'
            sanetask(proj.datanames,parmset,task);
            return;
        case 'wavenumber'
            sanetask(proj.datanames,parmset,task);
        case 'specdecomp'
            sanetask(proj.datanames,parmset,task,[1 1 0 1]);
    end
elseif(strcmp(action,'dotask'))
    htaskfig=gcf;
    htask=findobj(htaskfig,'tag','task');
    udat=get(htask,'userdata');
    task=udat{1};
    parmset=udat{2};%these are the parameters before user modification
    nparms=(length(parmset)-1)/3;
    %determine the dataset name, get the project
    hdat=findobj(htaskfig,'tag','datasets');
    idat=get(hdat,'value');
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    hmsg=findobj(hsane,'tag','message');
    proj=hfile.UserData;
    %pull the updated parameters out of the gui
    for k=1:nparms
       hobj=findobj(htaskfig,'tag',parmset{3*(k-1)+2});
       val=get(hobj,'string');
       parm=parmset{3*(k-1)+3};
       if(iscell(val))
           flag=get(hobj,'userdata');
           if(flag==1)
               parm{end}={val};
           else
               ival=get(hobj,'value');
               parm{end}=ival;
           end
       else
           parm=val;
       end
       parmset{3*(k-1)+3}=parm;
    end
    %check the parms for validity
    switch task
        case 'filter'
            parmset=parmsetfilter(parmset);
            %if parmset comes back as a string, then we have failure
        case 'phasemap'
            
            
        case 'spikingdecon'
            parmset=parmsetdecon(parmset,proj.tcoord{idat});
            
        case 'fdom'
            parmset=parmsetfdom(parmset,proj.tcoord{idat});
            
        case 'wavenumber'
           parmset=parmsetwavenumber(parmset); 
           
        case 'specdecomp'
           parmset=parmsetspecdecomp(parmset,proj.tcoord{idat}); 
            
    end
    if(ischar(parmset))
        msgbox(parmset,'Oh oh, there are problems...');
        return;
    end
    %save the updated parmset
    setparmset(parmset);
    %get the dataset
    if(~proj.isloaded(idat))
        %load the dataset
        figure(hsane)
        waitsignalon
        set(hmsg,'string',['Loading ' proj.datanames{idat} ' from disk']);
        hmpan=findobj(hsane,'tag','master_panel');
        udat=hmpan.UserData;
        udat{3}=idat;%this flags to reload which dataset we are reading
        hmpan.UserData=udat;
        sane('reloaddataset');%this updates proj and displays the dataset
        proj=hfile.UserData;
        waitsignaloff
    end
    %determine output dataset's fate
    hout=findobj(htaskfig,'tag','outputs');
    outopts=get(hout,'string');
    fate=outopts{get(hout,'value')};
    seis=proj.datasets{idat};
    t=proj.tcoord{idat};
    x=proj.xcoord{idat};
    y=proj.ycoord{idat};
    xcdp=proj.xcdp{idat};
    ycdp=proj.ycdp{idat};
    dx=proj.dx(idat);
    dy=proj.dy(idat);
    dname=proj.datanames{idat};
    %close the task window
    close(htaskfig);
    %start the task
    hcompute=findobj(hsane,'label','Compute');
    switch task
        case 'filter'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Bandpass filtering in progress')
            fmin=getparm(parmset,'fmin');
            dfmin=getparm(parmset,'dfmin');
            fmax=getparm(parmset,'fmax');
            dfmax=getparm(parmset,'dfmax');
            phase=getparm(parmset,'phase');
            if(strcmp(phase,'zero'))
                phase=0;
            else
                phase=1;
            end
            nx=length(x);ny=length(y);
            itrace=0;
            %The waitbar implements a cancel operation that works through the globals HWAIT and
            %CONTINUE. When the cancel button is hit (on the waitbar) the callback 'sane(''canceltaskafter'')'
            %sets the value of CONTINUE to false which causes the loop to stop. The callback also
            %removes the input dataset from memory and deletes the waitbar. Thus to restart the task
            %(it always must start from the beginning) then the dataset must be reloaded.
            HWAIT=waitbar(0,'Please wait for bandpass filtering to complete','CreateCancelBtn','sane(''canceltaskafter'')');
            ntraces=nx*ny;
            t0=clock;
            CONTINUE=true;
            for k=1:nx
                for j=1:ny
                    tmp=seis(:,k,j);
                    if(sum(abs(tmp))>0)
                        seis(:,k,j)=filtf(tmp,t,[fmin dfmin],[fmax dfmax],phase);
                    end
                    itrace=itrace+1;
                    if(~CONTINUE)
                        break;
                    end
                end
                if(~CONTINUE)
                        break;
                end
                t1=clock;
                timeused=etime(t1,t0);
                timeleft=(timeused/itrace)*(ntraces-itrace)/60;%in minutes
                timeleft=round(timeleft*100)/100;
                waitbar(itrace/ntraces,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
            end
            t1=clock;
            timeused=etime(t1,t0);
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused/60) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'spikingdecon'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Spiking decon in progress')
            oplen=getparm(parmset,'oplen');
            stab=getparm(parmset,'stab');
            topgate=getparm(parmset,'topgate');
            botgate=getparm(parmset,'botgate');
            fmin=getparm(parmset,'fmin');
            dfmin=getparm(parmset,'dfmin');
            fmax=getparm(parmset,'fmax');
            dfmax=getparm(parmset,'dfmax');
            phase=getparm(parmset,'phase');
            dt=t(2)-t(1);
            if(strcmp(phase,'zero'))
                phase=0;
            else
                phase=1;
            end
            nx=length(x);ny=length(y);
            itrace=0;
            HWAIT=waitbar(0,'Please wait for decon to complete','CreateCancelBtn','sane(''canceltaskafter'')');
            ntraces=nx*ny;
            t0=clock;
            idesign=near(t,topgate,botgate);
            nop=round(oplen/dt);
            CONTINUE=true;
            for k=1:nx
                for j=1:ny
                    tmp=seis(:,k,j);
                    tmpd=seis(idesign,k,j);
                    if(sum(abs(tmpd))>0)
                        tmpdecon=deconw(tmp,tmpd,nop,stab);
                        seis(:,k,j)=filtf(tmpdecon,t,[fmin dfmin],[fmax dfmax],phase);
                    end
                    itrace=itrace+1;
                    if(~CONTINUE)
                        break;
                    end
                end
                if(~CONTINUE)
                        break;
                end
                t1=clock;
                timeused=etime(t1,t0);
                timeleft=(timeused/itrace)*(ntraces-itrace)/60;%in minutes
                timeleft=round(timeleft*100)/100;
                waitbar(itrace/ntraces,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
            end
            t1=clock;
            timeused=etime(t1,t0);
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused/60) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'wavenumber'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Wavenumber filtering in progress')
            sigmax=getparm(parmset,'sigmax');
            sigmay=getparm(parmset,'sigmay');
            
            nt=length(t);
            HWAIT=waitbar(0,'Please wait for wavenumber filtering to complete','CreateCancelBtn','sane(''canceltaskafter'')');
            t0=clock;
            ievery=10;
            CONTINUE=true;
            for k=1:nt

                slice=squeeze(seis(k,:,:));
                slice2=wavenumber_gaussmask2(slice,sigmax,sigmay);
                slice2=slice2*norm(slice)/norm(slice2);
                seis(k,:,:)=shiftdim(slice2,-1);
                if(~CONTINUE)
                        break;
                end
                if(rem(k,ievery)==0)
                    tnow=clock;
                    timeused=etime(tnow,t0);
                    timeperslice=timeused/k;
                    timeleft=timeperslice*(nt-k)/60;
                    timeleft=round(timeleft*100)/100;
                    waitbar(k/nt,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
                end

            end
            t1=clock;
            timeused=etime(t1,t0);
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused/60) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'phasemap'
            
            
        case 'fdom'
            ny=length(y);
            twin=getparm(parmset,'twin');
            ninc=getparm(parmset,'ninc');
            fmax=getparm(parmset,'Fmax');
            tfmax=getparm(parmset,'tfmax');
            tinc=ninc*(t(2)-t(1));
            interpflag=1;
            p=2;
            fc=1;
            
            
            if(isnan(tfmax))
                fmt0=fmax;
            else
                fmt0=[fmax tfmax];
            end
            
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Dominant frequency volume computation in progress')
            
            HWAIT=waitbar(0,'Please wait for fdom computation to complete','CreateCancelBtn','sane(''canceltaskafter'')');
            t0=clock;
            CONTINUE=true;
            ievery=1;
            for k=1:ny
                %process each iline as a panel in tvfdom3
                spanel=squeeze(seis(:,:,k));
                test=sum(abs(spanel));
                ilive=find(test~=0);
                if(~isempty(ilive))
                    fd=tvfdom3(spanel(:,ilive),t,twin,tinc,fmt0,interpflag,p,fc);
                    ind=find(fd<0);
                    if(~isempty(ind))
                        fd(ind)=0;
                    end
                end
                seis(:,ilive,k)=single(fd);
                if(rem(k,ievery)==0)
                    time_used=etime(clock,t0);
                    time_per_line=time_used/k;
                    timeleft=(ny-k-1)*time_per_line/60;
                    timeleft=round(100*timeleft)/100;
                    waitbar(k/ny,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
                end
            end
            t1=clock;
            timeused=etime(t1,t0)/60;
            timeused=round(timeused*100)/100;
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'specdecomp'
            ny=length(y);
            nx=length(x);
            twin=getparm(parmset,'Twin');
            ninc=getparm(parmset,'Ninc');
            tmin=getparm(parmset,'Tmin');
            tmax=getparm(parmset,'Tmax');
            fout=getparm(parmset,'Fout');
            tinc=ninc*(t(2)-t(1));
            ind=near(t,tmin,tmax);
            nt=length(ind);
            %check that the requested frequencies will fit in memory
            [availmem,reqmem,nfreqs,resmem]=specdmemory(nx,ny,nt); %#ok<ASGLU>
            if(nfreqs<length(fout))
                msgbox('Number of frequecies exceeds the maximum allowed by your computer''s memory');
                return;
            end
            
            %loop over y=constant lines
            fmin=min(fout);fmax=max(fout);df=1;
            phaseflag=3;
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Spectral Decomp computation in progress')
            HWAIT=waitbar(0,'Please wait for SpecDecomp computation to complete','CreateCancelBtn','sane(''canceltaskafter'')');
            t0=clock;
            CONTINUE=true;
            ievery=1;
            for k=1:ny
                s2d=squeeze(seis(:,:,k));
                [amp2d,phs,tout,f2d]=specdecomp(s2d,t,twin,tinc,fmin,fmax,df,tmin,tmax,phaseflag); %#ok<ASGLU>
                if(k==1)
                    %allocate output volumes
                    amp=cell(size(fout));
                    for j=1:length(fout)
                        amp{j}=zeros(length(tout),nx,ny);
                    end
                end
                for j=1:length(fout)
                    jf=near(f2d,fout(j));
                    amp{j}(:,:,k)=amp2d(:,:,jf(1));
                end
                if(rem(k,ievery)==0)
                    time_used=etime(clock,t0);
                    time_per_line=time_used/k;
                    timeleft=(ny-k-1)*time_per_line/60;
                    timeleft=round(100*timeleft)/100;
                    waitbar(k/ny,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
                end
            end
            t1=clock;
            timeused=etime(t1,t0)/60;
            timeused=round(timeused*100)/100;
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
    end
    if(~CONTINUE)
        waitsignaloff
        set(hmsg,'string','Computation interrupted by user, input dataset unloaded');
        return
    end
    %deal with the output
    switch fate
        case 'Save SEGY'
            if(strcmp(task,'specdecomp'))
                goodname=false;
                while(~goodname)
                    [fname,path]=uiputfile('*.sgy','Select the output file (a number will be afixed for each frequency)');
                    if(isequal(fname,0) || isequal(path,0))
                        msgbox('Output cancelled');
                        return;
                    else
                        idot=strfind(fname,'.');
                        if(length(idot)~=1)
                            goodname=false;
                        else
                            goodname=true;
                        end
                    end
                end
                waitsignalon
                for k=1:length(amp)
                    fname2=[fname(1:idot-1) num2str(fout(k)) fname(idot:end)];
                    if(exist([path fname],'file'))
                        delete([path fname2]);
                    end
                    
                    set(hmsg,'string','Forming output array');
                    seis=unmake3Dvol(amp{k},proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                        'kxlineall',proj.kxline{idat});
                    dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                    set(hmsg,'string','Beginning SEGY output');
                    writesegy([path fname2],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                        proj.byteorder{idat},proj.texthdr{idat},proj.binhdr{idat},proj.exthdr{idat},...
                        proj.tracehdr{idat},proj.bindef{idat},proj.trcdef{idat},hsane);
                    set(hmsg,'string',['Dataset ' [path fname2] ' written']);
                end
                waitsignaloff
            else
                [fname,path]=uiputfile('*.sgy','Select the output file');
                if(isequal(fname,0) || isequal(path,0))
                    msgbox('Output cancelled');
                    return;
                end
                if(exist([path fname],'file'))
                    delete([path fname]);
                end
                waitsignalon
                set(hmsg,'string','Forming output array');
                seis=unmake3Dvol(seis,proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                    'kxlineall',proj.kxline{idat});
                dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                set(hmsg,'string','Beginning SEGY output');
                writesegy([path fname],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                    proj.byteorder{idat},proj.texthdr{idat},proj.binhdr{idat},proj.exthdr{idat},...
                    proj.tracehdr{idat},proj.bindef{idat},proj.trcdef{idat},hsane);
                
                waitsignaloff
                set(hmsg,'string',['Dataset ' [path fname] ' written']);
            end
        case 'Save SEGY and display'
            if(strcmp(task,'specdecomp'))
                %output
                goodname=false;
                while(~goodname)
                    [fname,path]=uiputfile('*.sgy','Select the output file (a number will be afixed for each frequency)');
                    if(isequal(fname,0) || isequal(path,0))
                        msgbox('Output cancelled');
                        return;
                    else
                        idot=strfind(fname,'.');
                        if(length(idot)~=1)
                            goodname=false;
                        else
                            goodname=true;
                        end
                    end
                end
                %display
                
                waitsignalon
                for k=1:length(amp)
                    fname2=[fname(1:idot-1) num2str(fout(k)) fname(idot:end)];
                    if(exist([path fname],'file'))
                        delete([path fname2]);
                    end
                    %display
                    plotimage3D(amp{k},t,{x,xcdp},{y,ycdp},[dname ' ' task],dx,dy)
                    %
                    set(hmsg,'string','Forming output array');
                    seis=unmake3Dvol(amp{k},proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                        'kxlineall',proj.kxline{idat});
                    dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                    set(hmsg,'string','Beginning SEGY output');
                    writesegy([path fname2],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                        proj.byteorder{idat},proj.texthdr{idat},proj.binhdr{idat},proj.exthdr{idat},...
                        proj.tracehdr{idat},proj.bindef{idat},proj.trcdef{idat},hsane);
                    set(hmsg,'string',['Dataset ' [path fname2] ' written']);
                end
                waitsignaloff
                
            else
                %display
                plotimage3D(seis,t,{x,xcdp},{y,ycdp},[dname ' ' task],dx,dy)
                %output
                [fname,path]=uiputfile('*.sgy','Select the output file');
                if(isequal(fname,0) || isequal(path,0))
                    msgbox('Output cancelled');
                    return;
                end
                if(exist([path fname],'file'))
                    delete([path fname]);
                end
                waitsignalon
                set(hmsg,'string','Forming output array');
                seis=unmake3Dvol(seis,proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                    'kxlineall',proj.kxline{idat});
                dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                set(hmsg,'string','Beginning SEGY output');
                writesegy([path fname],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                    proj.byteorder{idat},proj.texthdr{idat},proj.binhdr{idat},proj.exthdr{idat},...
                    proj.tracehdr{idat},proj.bindef{idat},proj.trcdef{idat},hsane);
                
                waitsignaloff
                set(hmsg,'string',['Dataset ' [path fname] ' written']);
            end
        case 'Replace input in project'
            proj.datasets{idat}=seis;
            %see if data is displayed
            if(proj.isdisplayed{idat}==1)
                delete(proj.pifigures{idat})
                plotimage3D(seis,t,{x,xcdp},{y,ycdp},dname,'seisclrs',proj.dx(idat),proj.dy(idat));
                set(gcf,'tag','fromsane','userdata',{idat hsane});
                set(gcf,'closeRequestFcn','sane(''closepifig'');')
                hview=findobj(hsane,'tag','view');
                uimenu(hview,'label',dname,'callback','sane(''popupfig'');','userdata',gcf);
                proj.pifigures{idat}=gcf;
                proj.isdisplayed(idat)=1;
            end
            proj.saveneeded(idat)=1;
            set(hfile,'userdata',proj)
            set(hmsg,'string',[proj.datanames{idat} ' replaced. Data will be written to disk when you save the project.'])
        case 'Save in project as new'
            waitsignalon
            %update project structure
            ndatasets=length(proj.datanames)+1;
            proj.filenames{ndatasets}=proj.filenames{idat};
            proj.paths{ndatasets}=proj.paths{idat};
            proj.datanames{ndatasets}=[proj.datanames{idat} '_' task];
            proj.isloaded(ndatasets)=1;
            proj.isdisplayed(ndatasets)=1;
            proj.xcoord{ndatasets}=proj.xcoord{idat};
            proj.ycoord{ndatasets}=proj.ycoord{idat};
            proj.tcoord{ndatasets}=proj.tcoord{idat};
            proj.datasets{ndatasets}=seis;
            proj.tshift(ndatasets)=proj.tshift(idat);
            proj.xcdp{ndatasets}=proj.xcdp{idat};
            proj.ycdp{ndatasets}=proj.ycdp{idat};
            proj.dx(ndatasets)=proj.dx(idat);
            proj.dy(ndatasets)=proj.dy(idat);
            proj.depth(ndatasets)=proj.depth(idat);
            proj.texthdr{ndatasets}=proj.texthdr{idat};
            proj.texthdrfmt{ndatasets}=proj.texthdrfmt{idat};
            proj.segfmt{ndatasets}=proj.segfmt{idat};
            proj.byteorder{ndatasets}=proj.byteorder{idat};
            proj.binhdr{ndatasets}=proj.binhdr{idat};
            proj.exthdr{ndatasets}=proj.exthdr{idat};
            proj.tracehdr{ndatasets}=proj.tracehdr{idat};
            proj.bindef{ndatasets}=proj.bindef{idat};
            proj.trcdef{ndatasets}=proj.trcdef{idat};
            proj.kxline{ndatasets}=proj.kxline{idat};
            
            proj.segyrev(ndatasets)=proj.segyrev(idat);
            proj.pifigures{ndatasets}=[];
            proj.isdeleted(ndatasets)=0;
            proj.deletedondisk(ndatasets)=0;
            proj.saveneeded(ndatasets)=1;
            
            hpan=newdatapanel(proj.datanames{ndatasets},1,1);
            proj.gui{ndatasets}=hpan;
            
            %call plotimage3D
            plotimage3D(seis,t,{x,xcdp},{y,ycdp},proj.datanames{ndatasets},'seisclrs',dx,dy);
            set(gcf,'tag','fromsane','userdata',{ndatasets hsane});
            set(gcf,'closeRequestFcn','sane(''closepifig'');')
            hview=findobj(hsane,'tag','view');
            uimenu(hview,'label',dname,'callback','sane(''popupfig'');','userdata',gcf);
            proj.pifigures{ndatasets}=gcf;
            
            %save the project
            set(hfile,'userdata',proj);
            figure(hsane)
            waitsignaloff 
            set(hmsg,'string',[proj.datanames{ndatasets} ' saved and displayed. Data will be written to disk when you save the project.'])
    end
    
    
    
elseif(strcmp(action,'canceltask'))
    %this is called if the task is cancelled before it actually begins to compute
    delete(gcf);
    hsane=findsanefig;
    figure(hsane);
    hmsg=findobj(hsane,'tag','message');
    set(hmsg,'string','Computation task cancelled');
    return
    
    
elseif(strcmp(action,'canceltaskafter'))
    %this is call if the task has already started to compute. This is a special problem because the
    %tasks are designed to replace the input data array either trace-by-trace or slice-by-slice. So
    %cancelling the task once the computation has begun means the data volume must be discarded.
    drawnow
    hsane=findsanefig;
    hmsg=findobj(hsane,'tag','message');
    set(hmsg,'string','Computation task cancelled');
    CONTINUE=false;
    delete(HWAIT);
    hcompute=findobj(hsane,'label','Compute');
    idat=get(hcompute,'userdata');
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    proj.isloaded(idat)=0;%this will cause a reload if the task is restarted
    memorybuttonoff(idat);
    proj.datasets{idat}=[];
    set(hfile,'userdata',proj);
    return
    
elseif(strcmp(action,'choosebyteloc'))
    %this pops up a dialog allowing the specification of byte locations for inline and crossline.
    %it is called by the Multiple segyload dialog.
    hdial=gcf;%the calling dialog window
    udat=get(hdial,'userdata');
    hdialarray=udat{1};%array of any existing byte location dialogs
    hbut=gcbo;%the button that was clicked
    mode=get(hbut,'string');%this will be one of 'SEGY standard','Canadian locs','Kingdom locs','Other'
    hpan=get(hbut,'parent');%The panel of the button
    locs=zeros(1,2);
    if(strcmp(get(hbut,'tag'),'inline'))
        locs(1)=get(hbut,'userdata');
        hbut2=findobj(hpan,'tag','xline');
        locs(2)=get(hbut2,'userdata');
    else
        locs(2)=get(hbut,'userdata');
        hbut2=findobj(hpan,'tag','inline');
        locs(1)=get(hbut2,'userdata');
    end
    pos=get(hdial,'position');
    hdial2=figure;
    hdialarray(end+1)=hdial2;
    udat{1}=hdialarray;
    set(hdial,'userdata',udat);
    dialht=200;%in pixels
    dialwid=400;%in pixels
    set(hdial2,'position',[pos(1)+.5*(pos(3)-dialwid) pos(2)+.5*(pos(4)-dialht) dialwid dialht],...
        'name','SANE: Define header locations','menubar','none','toolbar','none','numbertitle','off');
    xnot=.05;ynot=.8;
    xnow=xnot;ynow=ynot;ht=1/7;wid=.4;
    xsep=.05;ysep=.02;
    %get filename
    hfn=findobj(hpan,'tag','filename');
    fname=get(hfn,'string');
    uicontrol(hdial2,'style','text','string',['define byte locs for ' fname],'units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'tag','message','userdata',hpan)
    ynow=ynow-1.5*ht-ysep;
    choices={'SEGY standard','Canadian locs','Kingdom locs','Other'};
    for k=1:length(choices)
        if(strcmp(choices{k},mode))
            val=k;
        end
    end
    uicontrol(hdial2,'style','popupmenu','string',choices,'tag','options','units','normalized',...
        'position',[xnow+.5*wid,ynow,wid,ht],'callback','sane(''choosebyteloc2'');','value',val);
    xnow=xnot;
    ynow=ynow-ht-ysep;
    fsbig=10;
    uicontrol(hdial2,'style','text','string','Inline byte loc:','units','normalized','position',...
        [xnow ynow-.25*ht wid ht],'horizontalalignment','right','fontsize',fsbig);
    xnow=xnow+wid+xsep;
    if(strcmp(mode,'Other'))
        val='on';
        hint1='<<Changable';
    else
        val='inactive';
        hint1='';
    end
    uicontrol(hdial2,'style','edit','string',int2str(locs(1)),'tag','inline','enable',val,'units',...
        'normalized','position',[xnow ynow .5*wid ht],'fontsize',fsbig);
    uicontrol(hdial2,'style','text','string',hint1,'tag','hint1','units','normalized',...
        'position',[xnow+.5*wid ynow-.25*ht wid ht],'foregroundcolor','r','fontsize',fsbig',...
        'fontweight','bold','horizontalalignment','left');
    xnow=xnot;
    ynow=ynow-ht-ysep;
    uicontrol(hdial2,'style','text','string','Xline byte loc:','units','normalized','position',...
        [xnow ynow-.25*ht wid ht],'horizontalalignment','right','fontsize',fsbig);
    xnow=xnow+wid+xsep;
    uicontrol(hdial2,'style','edit','string',int2str(locs(2)),'tag','xline','enable',val,'units',...
        'normalized','position',[xnow ynow .5*wid ht],'fontsize',fsbig);
    uicontrol(hdial2,'style','text','string',hint1,'tag','hint2','units','normalized',...
        'position',[xnow+.5*wid ynow-.25*ht wid ht],'foregroundcolor','r','fontsize',fsbig',...
        'fontweight','bold','horizontalalignment','left');
    %done and cancel buttons
    xnow=xnot;
    ynow=ynow-ht-ysep;
    uicontrol(hdial2,'style','pushbutton','string','Done','tag','done','units','normalized',...
        'position',[xnow+.5*wid ynow .5*wid ht],'callback','sane(''choosebyteloc2'');','Backgroundcolor','c',...
        'fontsize',fsbig);
    xnow=xnow+wid+xsep;
    uicontrol(hdial2,'style','pushbutton','string','Cancel','tag','cancel','units','normalized',...
        'position',[xnow ynow .5*wid ht],'callback','sane(''choosebyteloc2'');');
    
elseif(strcmp(action,'choosebyteloc2'))
    %this is called by one of several controls on the byte location dialog
    %determine calling control
    hcntrl=gcbo;
    mode=get(hcntrl,'tag');
    hdial2=gcf;
    hhint1=findobj(hdial2,'tag','hint1');
    hhint2=findobj(hdial2,'tag','hint2');
    switch mode
        case 'options'
            hopt=findobj(hdial2,'tag','options');
            opts=get(hopt,'string');
            val=get(hopt,'value');
            option=opts{val};
            hinline=findobj(gcf,'tag','inline');
            hxline=findobj(gcf,'tag','xline');
            switch option
                case 'SEGY standard'
                    locs=segybytelocs;
                    set(hinline,'string',int2str(locs(1)),'enable','inactive');
                    set(hxline,'string',int2str(locs(2)),'enable','inactive');
                    set([hhint1 hhint2],'string','')
                case 'Canadian locs'
                    locs=canadabytelocs;
                    set(hinline,'string',int2str(locs(1)),'enable','inactive');
                    set(hxline,'string',int2str(locs(2)),'enable','inactive');
                    set([hhint1 hhint2],'string','')
                case 'Kingdom locs'
                    locs=kingdombytelocs;
                    set(hinline,'string',int2str(locs(1)),'enable','inactive');
                    set(hxline,'string',int2str(locs(2)),'enable','inactive');
                    set([hhint1 hhint2],'string','')
                case 'Other'
                    set(hinline,'enable','on');
                    set(hxline,'enable','on');
                    set([hhint1 hhint2],'string','<<Changable');
            end
            
        case 'done'
            %get the option
            hopt=findobj(hdial2,'tag','options');
            opts=get(hopt,'string');
            val=get(hopt,'value');
            option=opts{val};
            %get the byte locations
            hinline=findobj(gcf,'tag','inline');
            hxline=findobj(gcf,'tag','xline');
            loc1=round(str2double(get(hinline,'string')));
            loc1flag=true;
            if(isnan(loc1) || loc1<1 || loc1>237)
                loc1flag=false;
            end
            loc2=round(str2double(get(hxline,'string')));
            loc2flag=true;
            if(isnan(loc2) || loc2<1 || loc2>237)
                loc2flag=false;
            end
            
            if(loc1flag && loc2flag)
                %ok we go
                hmsg=findobj(hdial2,'tag','message');
                hpan=get(hmsg,'userdata');%the panel we are updating
                %get the buttons
                hinline=findobj(hpan,'tag','inline');
                hxline=findobj(hpan,'tag','xline');
                set(hinline','string',option,'userdata',loc1,'tooltipstring',...
                    ['loc= ' int2str(loc1) ', Push to change.']);
                set(hxline','string',option,'userdata',loc2,'tooltipstring',...
                    ['loc= ' int2str(loc2) ', Push to change.']);
                delete(hdial2)
                return;
                          
            elseif(~loc1flag)
                set(hhint1,'string','<<Bad value');
                return
                
            else
                set(hhint2,'string','<<Bad value');
                return
                
            end
            
        case 'cancel'
            delete(hdial2);
            return
            
    end
elseif(strcmp(action,'showtraceheaders'))
    %called by Multiple SEGY load dialog, or single segyload, or from Datainfo window
    hfig=gcf;%the figure that called this;
    frominfo=false;
    if(strcmp(get(hfig,'tag'),'datainfo'))
        frominfo=true;
    end
    pos=get(hfig,'position');
    
    %get number of traces
    hbut=gcbo;%the calling button
    ntr=get(hbut,'userdata');
    if(isempty(ntr))
        hntraces=findobj(hfig,'tag','ntraces');
        ntraces=str2double(get(hntraces,'string'));%number of headers to read
        if(isnan(ntraces)||ntraces<1)
            ntraces=1000;
            set(hntraces,'string',int2str(ntraces));
        end
    else
        ntraces=ntr;
    end
    if(frominfo)
        hsane=get(hfig,'userdata');
        hfile=findobj(hsane,'label','File');
        proj=get(hfile,'userdata');%project structure
        idata=get(hntraces,'userdata');%dataset number
        alltr=false;
        if(ischar(ntraces))%test for 'all'
            if(strcmpi(ntraces,'all'))
                nx=length(proj.xcoord{idata});
                ny=length(proj.ycoord{idata});
                ntraces=nx*ny;
                alltr=true;
            else
                ntraces=1000;
                set(hntraces,'string','ntraces');
            end
        elseif(isnan(ntraces))
            ntraces=1000;
            set(hntraces,'string','1000');
        end
        dname=proj.datanames{idata};
        %sgrv=getsegyrev(idata,hsane);
        if(alltr)
            msg=['For ' dname ', all traceheaders.'];
            viewtraceheaders(proj.tracehdr{idata},msg);
            htrhfig=gcf;
        else
            msg=['For ' dname ', first ' int2str(ntraces) ' traceheaders.'];
            viewtraceheaders(tracehdr_subset(proj.tracehdr{idata},1:ntraces),msg);
            htrhfig=gcf;
        end
        pos2=get(htrhfig,'position');%position of the new figure
        set(htrhfig,'position',[pos(1)+.5*(pos(3)-pos2(3)) pos(2)+.5*(pos(4)-pos2(4)) pos2(3:4)])
        
        hppt=addpptbutton([.95 .95 .05 .05]);
        set(hppt,'userdata',['Trace headers for ' dname]);
        
    else
        udat=get(hfig,'userdata');
        hsane=udat{2};
        %get filename and path
        hpan=get(hbut,'parent');
        hfname=findobj(hpan,'tag','filename');
        if(isempty(hfname))
            %happens when called from single readsegy file input
            hfname=findobj(hpan,'tag','fname');
            fname=get(hfname,'userdata');
            hpath=findobj(hpan,'tag','path');
            path=get(hpath,'userdata');
        else
            fname=get(hfname,'string');
            path=get(hfname,'userdata');
        end
        trc=SegyTrace([path fname]);
        trchdr=trc.read(1:ntraces,'headers');
        viewtraceheaders(trchdr,['First ' int2str(ntraces) ' headers of ' fname]);
        htrhfig=gcf;
        pos2=get(htrhfig,'position');%position of the new figure
        set(htrhfig,'position',[pos(1)+.5*(pos(3)-pos2(3)) pos(2)+.5*(pos(4)-pos2(4)) pos2(3:4)])
        %save the figure handle in buttons userdata
        set(hbut,'userdata',htrhfig);
    end
%     sf=SegyFile([path fname],'r');
%     trchdr = sf.Trace.read(1:ntraces,'headers');
%     viewtraceheaders(trchdr,sf.SegyRevision,['First ' int2str(ntraces) ' headers of ' fname]);
    hm=findobj(hsane,'tag','message');
    hfigs=get(hm,'userdata');
    set(hm,'userdata',[hfigs htrhfig]);
elseif(strcmp(action,'showbinaryheader'))
    hfig=gcf;%should be the datainfo figure
    pos=get(hfig,'position');
    hntraces=findobj(hfig,'tag','ntraces');
    hsane=get(hfig,'userdata');
    hfile=findobj(hsane,'label','File');
    proj=get(hfile,'userdata');%project structure
    idata=get(hntraces,'userdata');%dataset number
    dname=proj.datanames{idata};
    msg=['Binary header for ' dname ];
    viewbinheader(proj.binhdr{idata},msg);
    hbinfig=gcf;
    pos2=get(hbinfig,'position');%position of the new figure
    set(hbinfig,'position',[pos(1)+.5*(pos(3)-pos2(3)) pos(2)+.5*(pos(4)-pos2(4)) pos2(3:4)])
    
    hppt=addpptbutton([.9 .9 .1 .05]);
    set(hppt,'userdata',['Trace headers for ' dname]);
    
    hm=findobj(hsane,'tag','message');
    hfigs=get(hm,'userdata');
    set(hm,'userdata',[hfigs hbinfig]);
elseif(strcmp(action,'changetshift'))
    %this is called for the information panel
    hpan=gcf;
    htshift=findobj(hpan,'tag','tshift');
    tshift=str2double(get(htshift,'string'));
    if(isnan(tshift))
        msgbox('Unrecognizable value for time shift');
        set(htshift,'string','0.0');
    end

    
    hsane=get(hpan,'userdata');
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    hdsum=findobj(hpan,'tag','datasummary');
    idata=get(hdsum,'userdata');%the dataset number
    if(tshift>10 && proj.depth(idata)==0)
        tshift=tshift/1000; %assume milliseconds
    end
    t=proj.tcoord{idata};
    tshiftold=proj.tshift(idata);
    proj.tcoord{idata}=t-tshiftold+tshift;
    proj.tshift(idata)=tshift;
    set(hfile,'userdata',proj);
    hmsg=findobj(hsane,'tag','message');
    delete(hpan);
    sane('saveproject');
    set(hmsg,'string','Time shift updated and project saved');
    msgbox(['Time shift changed for ' proj.datanames{idata} ...
        '. You should close and re-open any displays of this dataset'],'SANE message');
elseif(strcmp(action,'pptx'))
    %here we open a new PPTX file. If one is already open, we close it and start another.
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    hppt=findobj(hsane,'tag','pptx');
    proj=get(hfile,'userdata');
    if(isempty(proj.projpath))
        msgbox('Load a project or dataset first and then press this button');
        return;
    end
    str=get(hppt,'string');
    if(strcmp(str,'Start PPT'))
        %ok we are starting a new PPTX
        isopen=exportToPPTX();
        if(~isempty(isopen))
            %get the name and path
            
            udat=get(hppt,'userdata');
            exportToPPTX('saveandclose',[udat{1} udat{2}]);
            [success,message,messageid]=movefile([udat{1} udat{2} '.pptx'],[udat{1} udat{2} '.ppt']); %#ok<ASGLU>
        end
        %get the project path
        ppath=proj.projpath;
        %look for existing saneppt.pptx files
        inum=1;
        done=false;
        saneppt='saneppt';
        while(~done)
            fileppt=[saneppt '#' int2str(inum)];
            test=exist([ppath fileppt '.ppt'],'file');
            if(test==0)
                done=true;
            end
            inum=inum+1;
        end
        %at this point fileppt with have the name 'saneppt#x.ppt' where x is an integrer that gives
        %a filename that does not already exist
        if(~isdeployed)
            pp=which('exportToPPTX');
            ii=strfind(pp,'exportToPPTX.m');
            exportToPPTX('open',[pp(1:ii(1)-1) 'DevonTemplate.pptx']);%opens the PPT
        else
            hn=char(getHostName(java.net.InetAddress.getLocalHost));
            if(strcmp(hn(1:3),'CGY'))
                %pp='\\cgynafsvs001p\MARGRG\Documents\matlab_repository\crewes\exportToPPTX-master\';
                pp='\\dvn.com\network\USA\Corporate\Apps\App-Data\Matlab\crewes\exportToPPTX-master\';
            else
                pp='\\dvn.com\network\USA\Corporate\Apps\App-Data\Matlab\crewes\exportToPPTX-master\';
            end
            exportToPPTX('open',[pp 'DevonTemplate.pptx']);%opens the PPT
        end
        
        set(hppt,'userdata',{ppath fileppt},'string','Close PPT');
        %look for open PowerPoint windows and change their copy buttons
        for k=1:length(proj.pifigures)
            hpif=proj.pifigures{k};
            if(~isempty(hpif))
               plotimage3D('buttons2ppt',hpif)
            end
        end
    else
        %ok we are closing the PPTX
        udat=get(hppt,'userdata');
        exportToPPTX('saveandclose',[udat{1} udat{2}]);
        [success,message,messageid]=movefile([udat{1} udat{2} '.pptx'],[udat{1} udat{2} '.ppt']); %#ok<ASGLU>
        set(hppt,'userdata',{},'string','Start PPT');
        %look for open PowerPoint windows and change their copy buttons
        for k=1:length(proj.pifigures)
            hpif=proj.pifigures{k};
            if(~isempty(hpif))
               plotimage3D('buttons2clipboard',hpif)
            end
        end
    end
elseif(strcmp(action,'makepptslide'))
        %this is called from any SANE application with sane('makepptslide','Title string')
        %The slide is always made from GCF
        hfig=gcf;
        %see if PPT is open
        isopen=exportToPPTX();
        if(isempty(isopen))
            sane('pptx');%opens a new powerpoint
        end
        %put up the title string for approval
        if(nargin<2)
            hppt=findobj(hfig,'tag','ppt');
            titlestring=get(hppt,'userdata');
        else
            titlestring=arg2;
        end
        tit=askthingsle('name','PPT slide title','questions',{'Title for slide'},'answers',...
            {titlestring});
        if(isempty(tit))
            return;
        end
        titlestring=tit{1};
        %make the slide
        exportToPPTX('addslide','Layout','Title and Footer');
        %slideNum = exportToPPTX('addslide','Layout','Title and Footer');
        exportToPPTX('addtext',titlestring,'Position','Title');
        %fprintf('Added slide %d\n',slideNum);
        exportToPPTX('addpicture',hfig,'position',[0 1.5 13.333 5.5]);
elseif(strcmp(action,'specdecompdecide'))
    hsane=findsanefig;
    pos=get(hsane,'position');
    figwid=600;
    fight=400;
    xc=pos(1)+.5*pos(3);
    yc=pos(2)+.5*pos(4);
    hdial=figure('position',[xc-.5*figwid,yc-.5*fight,figwid,fight],'tag','SDdecide',...
        'userdata',hsane,'numbertitle','off','name','Spectral Decomp Decision Tool');
    xnow=.1;ynow=.9;
    wid=.8;ht=.05;
    fs=12;sep=.01;
    uicontrol(hdial,'style','text','string','Spectral Decomp Decision Tool','units','normalized',...
        'position',[xnow,ynow,wid,ht],'fontsize',fs,'fontweight','bold');
    ynow=ynow-3*ht;
    msg=['Spectral decompositon creates an output volume the same size as the input volume for ',...
        'each output frequency. This can use up available memory rapidly. Therefore for large datasets ',...
        'it is recommended to reduce the input volume by limiting the time range. This tool allows ',...
        'you to estimate the maximum number of frequecies possible. Try to leave a few GB of '...
        'residual memory.'];
    uicontrol(hdial,'style','text','string',msg,'units','normalized','position',[xnow,ynow,.8,3*ht])
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    ynow=ynow-ht;
    ht=.05;
    wid=.1;
    nudge=.25*ht;
    uicontrol(hdial,'style','text','string','Dataset:','units','normalized',...
        'position',[xnow,ynow-nudge,wid,ht]);
    uicontrol(hdial,'style','popupmenu','string',proj.datanames,'tag','datanames','units','normalized',...
        'position',[xnow+wid+sep,ynow,7*wid,ht],'callback','sane(''specdecompdecide2'');');
    ynow=ynow-2*ht-sep;
    xnow=.4;
    uicontrol(hdial,'style','text','string','Start time:','units','normalized',...
        'position',[xnow,ynow-nudge,wid,ht]);
    uicontrol(hdial,'style','edit','string',proj.tcoord{1}(1),'tag','start','units','normalized',...
        'position',[xnow+wid+sep,ynow,wid,ht],'callback','sane(''specdecompdecide2'');',...
        'tooltipstring','Type a value in seconds then hit "enter"');
    ynow=ynow-2*ht-sep;
    uicontrol(hdial,'style','text','string','End time:','units','normalized',...
        'position',[xnow,ynow-nudge,wid,ht]);
    uicontrol(hdial,'style','edit','string',proj.tcoord{1}(end),'tag','end','units','normalized',...
        'position',[xnow+wid+sep,ynow,wid,ht],'callback','sane(''specdecompdecide2'');',...
        'tooltipstring','Type a value in seconds then hit "enter"');
    ynow=ynow-2*ht;
    wid=.6;
    xnow=.25;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','availmem',...
        'position',[xnow,ynow,wid,ht]);
    ynow=ynow-1.5*ht;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','reqmem',...
        'position',[xnow,ynow,wid,ht]);
    ynow=ynow-1.5*ht;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','resmem',...
        'position',[xnow,ynow,wid,ht]);
    ynow=ynow-1.5*ht;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','nfreqs',...
        'position',[xnow,ynow,wid,ht],'fontsize',10,'fontweight','bold');
    ynow=ynow-2*ht;
    wid=.1;
    xnow=.5;
    uicontrol(hdial,'style','pushbutton','string','Done','units','normalized','position',...
        [xnow,ynow,wid,ht],'callback','close(gcf)');
    sane('specdecompdecide2');
    return;
elseif(strcmp(action,'specdecompdecide2'))
    hdial=gcf;
    hsane=get(hdial,'userdata');
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    hd=findobj(hdial,'tag','datanames');
    idata=get(hd,'value');
    x=proj.xcoord{idata};
    y=proj.ycoord{idata};
    t=proj.tcoord{idata};
    hstart=findobj(hdial,'tag','start');
    tmin=str2double(hstart.String);
    if(isnan(tmin)); tmin=t(1); end
    tmin=max([t(1) tmin]);
    set(hstart,'string',num2str(tmin));
    hend=findobj(hdial,'tag','end');
    tmax=str2double(hend.String);
    if(isnan(tmax)); tmax=t(1); end
    tmax=max([t(1) tmax]);
    set(hend,'string',num2str(tmax));
    %compute
%     mm=memory;
%     availmem=mm.MaxPossibleArrayBytes;
%     ind=near(t,tmin,tmax);
%     reqmem=length(x)*length(y)*length(ind)*4;
%     nfreqs=floor(availmem/reqmem);
%     resmem=availmem-nfreqs*reqmem;
    ind=near(t,tmin,tmax);
    [availmem,reqmem,nfreqs,resmem]=specdmemory(length(x),length(y),length(ind));
    %annotate
    ha=findobj(hdial,'tag','availmem');
    GB=(1024)^3;
    set(ha,'string',['Available memory: ' num2str(availmem) ' bytes (' num2str(availmem/GB,3) 'GB)']);
    hr=findobj(hdial,'tag','reqmem');
    set(hr,'string',['Memory required per frequency: ' num2str(reqmem) ' bytes (' num2str(reqmem/GB,3) 'GB)']);
    hr=findobj(hdial,'tag','resmem');
    set(hr,'string',['Residual memory ' num2str(resmem) ' bytes (' num2str(resmem/GB,3) 'GB)']);
    hf=findobj(hdial,'tag','nfreqs');
    set(hf,'string',['Maximum number of output frequencies: ' int2str(nfreqs) ]);
    
end

end

function [availmem,reqmem,nfreqs,resmem]=specdmemory(nx,ny,nt)
    mm=memory;
    availmem=mm.MaxPossibleArrayBytes;
    reqmem=nx*ny*nt*4;
    nfreqs=floor(availmem/reqmem);
    resmem=availmem-nfreqs*reqmem;
end

function [itchoice,ixchoice,iychoice]=ambigdialog(ambig,it,ix,iin,varnames,itchoice,ixchoice,iychoice)
%this is called when importing a .mat file that may have many variables in it.
hsane=findsanefig;
pos=get(hsane,'position');
if(pos(3)<450);pos(3)=450;end
%hdial=dialog;
hdial=figure('windowstyle','modal');
set(hdial,'position',pos,'menubar','none','toolbar','none','numbertitle','off',...
    'name','SANE mat file input ambiguity dialog','nextplot','new');
indt= it==1;
indx= ix==1;
indin= iin==1;
columnformat={};
data={};
columnnames={};
if(ambig(1)==1)
   columnformat=[columnformat {varnames(indt)'}];
   data=[data varnames{itchoice}];
   columnnames=[columnnames {'time coordinate'}];
end
if(ambig(2)==1)
   columnformat=[columnformat {varnames(indx)'}];
%    if(strcmp(varnames{indt(itchoice)},varnames{indx(ixchoice)}))
%     data=[data varnames{indx(2)}];
%     ixchoice=2;
%    else
    data=[data varnames{ixchoice}];
%    end
   columnnames=[columnnames {'xline coordinate'}];
end
if(ambig(3)==1)
   columnformat=[columnformat {varnames(indin)'}];
%    if(strcmp(varnames{indin(iychoice)},varnames{indx(ixchoice)}))
%       iychoice=ixchoice+1;
%    end
   data=[data varnames{iychoice}];
   columnnames=[columnnames {'inline coordinate'}];
end

ynow=.4;ht=.3;
htab=uitable(hdial,'data',data,'columnformat',columnformat,'columnname',columnnames,...
    'rowname','choose:','columneditable',true,'units','normalized','position',[.1 ynow .8 ht],...
    'tag','table','userdata',varnames);
htab.Position(3)=htab.Extent(3);
htab.Position(4)=htab.Extent(4);
ynow=.6;
msg={'Unable to determine coordinate vectors based on size only.'...
    'Please choose a unique name for each coordinate'};
uicontrol(hdial,'style','text','units','normalized','position',[.1 ynow .8 ht],'string',msg,...
    'tag','msg');
uicontrol(hdial,'style','pushbutton','string','Done','units','normalized',...
    'position',[.1 .1 .3 .1],'callback',@checkambig,'userdata',ambig,'tag','done');

uiwait(hdial)

%function [itchoice,ixchoice,iychoice]=checkambig(~,~)
function checkambig(~,~)
htable=findobj(gcf,'tag','table');
choices=htable.Data;
if(length(choices)==3)
    if(strcmp(choices{1},choices{2})||strcmp(choices{1},choices{3})...
            ||strcmp(choices{2},choices{3}))
        hmsg=findobj(gcf,'tag','msg');
        set(hmsg,'string','You must choose unique names for each!!!','foregroundcolor',[1 0 0],...
            'fontsize',10,'fontweight','bold');
        itchoice=0;
        ixchoice=0;
        iychoice=0;
        return
    end
elseif(length(choices)==2)
    if(strcmp(choices{1},choices{2}))
        hmsg=findobj(gcf,'tag','msg');
        set(hmsg,'string','You must choose unique names for each!!!','foregroundcolor',[1 0 0],...
            'fontsize',10,'fontweight','bold');
        itchoice=0;
        ixchoice=0;
        iychoice=0;
        return
    end
end
varnames=get(htable,'userdata');
hbut=findobj(gcf,'tag','done');
ambig=get(hbut,'userdata');
colnames=htable.ColumnName;
if(sum(ambig)==3)
    for k=1:length(varnames)
        if(strcmp(varnames{k},choices{1}))
            itchoice=k;
        end
        if(strcmp(varnames{k},choices{2}))
            ixchoice=k;
        end
        if(strcmp(varnames{k},choices{3}))
            iychoice=k;
        end
    end
elseif(sum(ambig)==2)
    for k=1:length(varnames)
        if(strcmp(varnames{k},choices{1}))
            if(colnames{1}(1)=='t')
                itchoice=k;
            elseif(colnames{1}(1)=='x')
                ixchoice=k;
            end
        end
        if(strcmp(varnames{k},choices{2}))
            if(colnames{2}(1)=='x')
                ixchoice=k;
            elseif(colnames{2}(1)=='i')
                iychoice=k;
            end
        end
    end
else
    for k=1:length(varnames)
        if(strcmp(varnames{k},choices{1}))
            if(colnames{1}(1)=='t')
                itchoice=k;
            elseif(colnames{1}(1)=='x')
                ixchoice=k;
            elseif(colnames{1}(1)=='i')
                iychoice=k;
            end
        end
    end
end
close(gcf)
end

end

function proj=makeprojectstructure

proj.name='New Project';
proj.filenames={};
proj.projfilename=[];
proj.projpath=[];
proj.paths={};
proj.datanames={};
proj.isloaded=[];
proj.isdisplayed=[];
proj.xcoord={};
proj.ycoord={};
proj.tcoord={};
proj.tshift=[];
proj.datasets={};
proj.xcdp={};
proj.ycdp={};
proj.dx=[];
proj.dy=[];
proj.depth=[];
proj.texthdr={};
proj.texthdrfmt={};
proj.segfmt={};
proj.byteorder={};
proj.binhdr={};
proj.exthdr={};
proj.tracehdr={};
proj.bindef={};
proj.trcdef={};
proj.segyrev=[];
proj.kxline={};
proj.gui={};
proj.rspath=[];
proj.wspath=[];
proj.rmpath=[];
proj.wmpath=[];
proj.pifigures=[];
proj.isdeleted=[];
proj.deletedondisk=[];
proj.saveneeded=[];
proj.xlineloc=[];
proj.inlineloc=[];
proj.parmsets={};
proj.horizons={};

end

function projnew=expandprojectstructure(proj,nnew)

projnew.name=proj.name;
projnew.projfilename=proj.projfilename;
projnew.filenames=[proj.filenames cell(1,nnew)];
projnew.projpath=proj.projpath;
projnew.paths=[proj.paths cell(1,nnew)];
projnew.datanames=[proj.datanames cell(1,nnew)];
projnew.isloaded=[proj.isloaded zeros(1,nnew)];
projnew.isdisplayed=[proj.isdisplayed zeros(1,nnew)];
projnew.xcoord=[proj.xcoord cell(1,nnew)];
projnew.ycoord=[proj.ycoord cell(1,nnew)];
projnew.tcoord=[proj.tcoord cell(1,nnew)];
projnew.tshift=[proj.tshift zeros(1,nnew)];
projnew.datasets=[proj.datasets cell(1,nnew)];
projnew.xcdp=[proj.xcdp cell(1,nnew)];
projnew.ycdp=[proj.ycdp cell(1,nnew)];
projnew.dx=[proj.dx ones(1,nnew)];
projnew.dy=[proj.dy ones(1,nnew)];
projnew.depth=[proj.depth zeros(1,nnew)];
projnew.texthdr=[proj.texthdr cell(1,nnew)];
projnew.texthdrfmt=[proj.texthdrfmt cell(1,nnew)];
projnew.segfmt=[proj.segfmt cell(1,nnew)];
projnew.byteorder=[proj.byteorder cell(1,nnew)];
projnew.binhdr=[proj.binhdr cell(1,nnew)];
projnew.exthdr=[proj.exthdr cell(1,nnew)];
projnew.tracehdr=[proj.tracehdr cell(1,nnew)];
projnew.bindef=[proj.bindef cell(1,nnew)];
projnew.trcdef=[proj.trcdef cell(1,nnew)];
projnew.segyrev=[proj.segyrev zeros(1,nnew)];
projnew.kxline=[proj.kxline cell(1,nnew)];
projnew.gui=[proj.gui cell(1,nnew)];
projnew.rspath=proj.rspath;
projnew.wspath=proj.wspath;
projnew.rmpath=proj.rmpath;
projnew.wmpath=proj.wmpath;
projnew.pifigures=[proj.pifigures cell(1,nnew)];
projnew.isdeleted=[proj.isdeleted zeros(1,nnew)];
projnew.deletedondisk=[proj.deletedondisk zeros(1,nnew)];
projnew.saveneeded=[proj.saveneeded zeros(1,nnew)];
projnew.xlineloc=[proj.xlineloc zeros(1,nnew)];
projnew.inlineloc=[proj.inlineloc zeros(1,nnew)];
projnew.parmsets=proj.parmsets;
proj.horizons=[proj.horizons cell(1,nnew)];

end

function hpan=newdatapanel(dname,memflag,dispflag)
hsane=findsanefig;
hmpan=findobj(hsane,'tag','master_panel');%the master panel
hsp=findobj(hsane,'tag','sane_panel');
poss=get(hsp,'position');
hdp=findobj(hsane,'tag','data_panel');%the data panel
posd=get(hdp,'position');
udat=get(hmpan,'userdata');
geom=udat{2};
hpanels=udat{1};
npanels=length(hpanels)+1;
panelwidth=1;panelheight=geom(2)/(poss(4)*posd(4));xnow=0;
wid=geom(5);ht=geom(6);xsep=geom(7);ysep=geom(8)/(poss(4)*posd(4));
%ynow=ynow-panelheight-ysep;
ynow=1-npanels*(panelheight+ysep);
hpan=uipanel(hdp,'tag',['data_panel' int2str(npanels)],'units','normalized',...
    'position',[xnow ynow panelwidth panelheight],'userdata',npanels);
geom(4)=ynow;
hpanels{npanels}=hpan;
set(hmpan,'userdata',{hpanels geom []});
%dataset name
xn=0;yn=.1;
dg=.7*ones(1,3);
ht2=1.1;
uicontrol(hpan,'style','edit','string',dname,'tag','dataname','units','normalized',...
    'position',[xn yn wid ht],'callback','sane(''datanamechange'');','horizontalalignment','center');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%info button
xn=xn+wid+xsep;
wid2=(1-wid-3*xsep)/4.5;
uicontrol(hpan,'style','pushbutton','string','Information','tag','dataname','units','normalized',...
    'position',[xn yn .75*wid2 ht],'callback','sane(''datainfo'');');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%memory
xn=xn+.75*wid2+xsep;
hbg1=uibuttongroup(hpan,'tag','memory','units','normalized','position',[xn yn wid2 ht]);
if(memflag==1)
    val1=1;val2=0;
else
    val1=0;val2=1;
end
uicontrol(hbg1,'style','radio','string','Y','units','normalized','position',[.1 .2 .35 .8],'value',val1,...
    'callback','sane(''datamemory'');','tag','memoryyes');
uicontrol(hbg1,'style','radio','string','N','units','normalized','position',[.6 .2 .35 .8],'value',val2,...
    'callback','sane(''datamemory'');','tag','memoryno');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%display
xn=xn+wid2+xsep;
hbg2=uibuttongroup(hpan,'tag','display','units','normalized','position',[xn yn wid2 ht]);
if(dispflag==1)
    val1=1;val2=0;
else
    val1=0;val2=1;
end
uicontrol(hbg2,'style','radio','string','Y','units','normalized','position',[.1 .2 .35 .8],'value',val1,...
    'callback','sane(''datadisplay'');','tag','displayyes');
uicontrol(hbg2,'style','radio','string','N','units','normalized','position',[.6 .2 .35 .8],'value',val2,...
    'callback','sane(''datadisplay'');','tag','displayno');

%delete button
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
xn=xn+wid2+xsep;
uicontrol(hpan,'style','pushbutton','string','Delete','tag','dataname','units','normalized',...
    'position',[xn yn .5*wid2 ht],'callback','sane(''datadelete'');');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.5*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
xn=xn+.65*wid2+xsep;
uicontrol(hpan,'style','radio','string','','units','normalized','position',[xn yn .5*wid2 ht],'value',0,...
    'callback','sane(''group'');','tag','group');

end



function waitsignalon
pos=get(gcf,'position');
spinnersize=[40 40];
waitspinner('start',[pos(3)-spinnersize(1), pos(4)-spinnersize(2), spinnersize]);
drawnow
end

function waitsignaloff
waitspinner('stop');
end

function hsane=findsanefig
hfigs=figs;
if(isempty(hfigs))
    hsane=[];
    return;
end
hfig=gcf;
if(strcmp(get(hfig,'tag'),'sane'))
    hsane=hfig;
    return;
elseif(strcmp(get(hfig,'tag'),'fromsane'))
    udat=get(hfig,'userdata');
    if(~iscell(udat))
        udat=get(udat,'userdata');
    end
    %explanation for the above. When plotimage3D is called from SANE the tag is set to 'fromsane'
    %and the userdata is set to a two element cell where the second entry is the sane figure handle.
    %(The first entry is lost in time.) With some plotimage3D tools, this tag is copied to the tool
    %window but the userdata of the tool window is just the pi3D handle.
    if(isgraphics(udat{2}))
        if(strcmp(get(udat{2},'tag'),'sane'))
            hsane=udat{2};
            return;
        end
    end
else
    
    isane=zeros(size(figs));
    for k=1:length(figs)
        if(strcmp(get(hfigs(k),'tag'),'sane'))
            isane(k)=1;
        end
    end
    if(sum(isane)==1)
        ind= isane==1;
        hsane=hfigs(ind);
    elseif(sum(isane)==0)
        hsane=[];
    else
        error('unable to resolve SANE figure')
    end
end
end

function loadprojectdialog
hsane=findsanefig;
hfile=findobj(hsane,'tag','file');
proj=get(hfile,'userdata');
dnames=proj.datanames;

isloaded=proj.isloaded;
isdisplayed=proj.isdisplayed;
islive=~proj.isdeleted;
nnames=length(dnames(islive));
pos=get(hsane,'position');
hdial=figure;
htfig=1.2*pos(4);
y0=pos(2)+pos(4)-htfig;
set(hdial,'position',[pos(1) y0 pos(3)*.6 htfig],'menubar','none','toolbar','none','numbertitle','off',...
    'name','SANE: Project load dialogue','closerequestfcn','sane(''cancelprojectload'');');
wid1=.5;wid2=.1;sep=.02;ht=.05;
xnow=.1;ynow=.95;
uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,.8,ht],...
    'string','Choose which datasets to load and display. Initial settings are from last save.');
ynow=ynow-ht-sep;
uicontrol(hdial,'string','Dataset','units','normalized','position',[xnow,ynow,wid1,ht]);
hload=uicontrol(hdial,'string','Loaded','units','normalized','position',[xnow+wid1+sep, ynow,wid2, ht],...
    'tag','loaded');
hdisp=uicontrol(hdial,'string','Displayed','units','normalized',...
    'position',[xnow+wid1+2*sep+wid2, ynow,wid2, ht],'tag','display');
hpan=uipanel(hdial,'position',[xnow,.1,.8,.77]);
hpan2=uipanel(hpan,'position',[0, -3, 1 4]);
%scrollbar
uicontrol(hdial,'style','slider','tag','slider','units','normalized','position',...
    [xnow+.8,.1,.5*xnow,.77],'value',1,'Callback',{@sane_slider,hpan2})
xn=.02;yn=.96;h=1.5*ht/(4);
wd1=wid1;sp=.01;wd2=wid2;
xf=1.3;
hloaded=zeros(1,nnames);
hdisplayed=hloaded;
for k=1:length(dnames)
    if(~proj.isdeleted(k))
        mb=round(length(proj.xcoord{k})*length(proj.ycoord{k})*length(proj.tcoord{k})*4/10^6);
        uicontrol(hpan2,'style','text','string',[dnames{k} ' (' int2str(mb) 'MB)'],'units','normalized','position',[xn yn wd1 h]);
        hloaded(k)=uicontrol(hpan2,'style','popupmenu','string','No|Yes','units','normalized',...
            'position',[xn+wd1*xf yn wd2 h],'value',isloaded(k)+1);
        hdisplayed(k)=uicontrol(hpan2,'style','popupmenu','string','No|Yes','units','normalized',...
            'position',[xn+wd1*xf+wd2*xf+2*sp*xf yn wd2 h],'value',isdisplayed(k)+1);
        yn=yn-h-sp;
    end
end
ynow=.05;wid=.1;sep=.05;
uicontrol(hdial,'style','pushbutton','string','OK, continue','units','normalized',...
    'position',[xnow,ynow,2*wid,ht],'tooltipstring','Push to continue loading',...
    'callback','sane(''loadprojdial'')','tag','continue','backgroundcolor','b','foregroundcolor','w');
uicontrol(hdial,'style','pushbutton','string','All Yes','units','normalized',...
    'position',[xnow+2*wid+sep,ynow,wid,ht],'tooltipstring','set all responses to Yes',...
    'callback','sane(''loadprojdial'')','tag','allyes');
uicontrol(hdial,'style','pushbutton','string','All No','units','normalized',...
    'position',[xnow+3*wid+2*sep,ynow,wid,ht],'tooltipstring','set all responses to No',...
    'callback','sane(''loadprojdial'')','tag','allno');

set(hload,'userdata',hloaded);
set(hdisp,'userdata',hdisplayed);
set(hdial,'userdata',hsane);

end

function multiplesegyload(newproject)
hsane=findsanefig;
hfile=findobj(hsane,'tag','file');
proj=get(hfile,'userdata');
%hreadmany=findobj(hsane,'tag','readmanysegy');
pos=get(hsane,'position');
hdial=figure;
htfig=1*pos(4);
widfig=1.3*pos(3);
y0=pos(2)+pos(4)-htfig;
set(hdial,'position',[pos(1) y0 widfig htfig],'menubar','none','toolbar','none','numbertitle','off',...
    'name','SANE: Multiple SEGY load dialogue','closerequestfcn','sane(''cancelmultipleload'');');
wid1=.8;wid2=.1;sep=.02;ht=.05;
xnow=.1;ynow=.9;
if(newproject)
    msg='Select the SEGY Datasets to be read. Then define the project save file.';
else
    msg='Select the SEGY Datasets to be read. Datasets will be included in existing project.';
end
fsb=10;
uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid1,ht],...
    'string',msg,'fontsize',fsb,'fontweight','bold','tag','dialmsg');
% ynow=ynow-.5*ht-sep;
% uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid1,ht],...
%     'string','','tag','dialmsg');
ynow=ynow-ht-sep;
uicontrol(hdial,'style','pushbutton','string','New dataset','units','normalized','tag','new',...
    'position',[xnow,ynow,wid2,ht],'tooltipstring','push this to select a new dataset',...
    'callback','sane(''selectnewdataset'')','userdata',[],'fontsize',fsb);%userdata will contain the panel handles
if(newproject)
    uicontrol(hdial,'style','pushbutton','string','Project save file','units','normalized','tag','proj',...
        'position',[xnow+wid2+sep,ynow,wid2,ht],'tooltipstring','push this to define project save file',...
        'callback','sane(''defineprojectsavefile'')','fontsize',fsb);
end
ynow=ynow-ht-sep;
uicontrol(hdial,'style','text','string','Project will be saved in:','units','normalized',...
    'position',[xnow,ynow,2*wid2,ht]);
if(isempty(proj.projfilename))
    projsavefile='Undefined';
else
    projsavefile=[proj.projpath proj.projfilename];
end
uicontrol(hdial,'style','text','string',projsavefile,'units','normalized','tag','projsavefile',...
    'position',[xnow+2*wid2,ynow,wid1-2*wid2,ht],'horizontalalignment','left');
ynow=ynow-.5*ht-sep;
uicontrol(hdial,'style','pushbutton','string','Done','units','normalized','tag','done',...
    'position',[xnow,ynow,wid2,ht],'tooltipstring','Push to begin reading datasets',...
    'callback','sane(''readmanysegy2'')','fontsize',fsb);
uicontrol(hdial,'style','pushbutton','string','Cancel','units','normalized','tag','cancel',...
    'position',[xnow+wid2+sep,ynow,wid2,ht],'tooltipstring','Push to cancel reading datasets',...
    'callback','sane(''cancelmultipleload'')');

xnow=.9-.6*wid2;
htt=.8*ht;
uicontrol(hdial,'style','text','string','# hdrs to view:','units','normalized','position',...
    [xnow,ynow-.25*htt,.65*wid2,htt],'horizontalalignment','right');
xnow=xnow+.65*wid2;
uicontrol(hdial,'style','edit','string','100','units','normalized','tag','ntraces',...
    'position',[xnow ynow .35*wid2 htt]);
%make a master panel
xnow=.05;
ynow=ynow-ht-sep;
panelwidth=.9;
panelheight=ht;
hmpan=uipanel(hdial,'tag','readmanymaster','units','normalized','position',...
    [xnow,ynow,panelwidth,panelheight]);
%filename
wid=.27;ht=.8;ht2=1.1;
xn=0;yn=0;
ng=.94*ones(1,3);
dg=.7*ones(1,3);
fs=8;
xsep=.02;
ysep=.01;
%file name
uicontrol(hmpan,'style','text','string','Filename','tag','fname_label','units','normalized',...
    'position',[xn,yn,wid,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%dataset name
xn=xn+wid+xsep;
uicontrol(hmpan,'style','text','string','Dataset name','tag','dname_label','units','normalized',...
    'position',[xn,yn,wid,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%display option
xn=xn+wid+xsep;
wid2=(1-2.1*wid-6*xsep)/5;%nominal width of last five items
uicontrol(hmpan,'style','text','string','Display?','tag','dlabel','units','normalized','position',[xn,yn,.75*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Will this dataset be displayed after reading?');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%time shift
xn=xn+.75*wid2+xsep;
uicontrol(hmpan,'style','text','string','Time shift','tag','tslabel','units','normalized','position',[xn,yn,.75*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Datum shift for this dataset, seconds for time data. Feet or meters for depth data.');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%inline loc
xn=xn+.75*wid2+xsep;
uicontrol(hmpan,'style','text','string','Inline byte loc','tag','inlabel','units','normalized','position',[xn,yn,1.25*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Byte location in the SEGY trace headers for the inline number');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%xline loc
xn=xn+1.25*wid2+xsep;
uicontrol(hmpan,'style','text','string','Xline byte loc','tag','xlabel','units','normalized','position',[xn,yn,1.25*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Byte location in the SEGY trace headers for the crossline number');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%xline loc
xn=xn+1.25*wid2+xsep;
uicontrol(hmpan,'style','text','string','Trace headers','tag','trclbl','units','normalized','position',[xn,yn,1.25*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Browse the trace headers');

set(hmpan,'userdata',{[],[panelwidth,panelheight,xnow,ynow,wid,ht,xsep,ysep]})%the first slot in UserData will contain the array of panel handles

panelht=ynow-.1-ysep;
ynow=.1;
hlp=uipanel(hdial,'tag','load_panel','units','normalized','position',[xnow,ynow,panelwidth,panelht]);
hdp=uipanel(hlp,'tag','data_panel','units','normalized','position',[0, -3, 1 4]);
%scrollbar
uicontrol(hdial,'style','slider','tag','slider','units','normalized','position',...
    [xnow+panelwidth,ynow,.025,panelht],'value',1,'Callback',{@sane_slider,hdp});

set(hdial,'tag','fromsane','userdata',{[] , hsane});
end

function newfileloadpanel(fname,path,dname)
hdial=gcf;
hlp=findobj(hdial,'tag','load_panel');
posl=get(hlp,'position');
hdp=findobj(hdial,'tag','data_panel');
posd=get(hdp,'position');
hmpan=findobj(hdial,'tag','readmanymaster');
udat=get(hmpan,'userdata');
geom=udat{2};
hpanels=udat{1};%the array of existing panels
npanels=length(hpanels)+1;
panelwidth=1;panelheight=1.1*geom(2)/(posl(4)*posd(4));xnow=0;
wid=geom(5);ht=geom(6);xsep=geom(7);ysep=geom(8)/(posl(4)*posd(4));
ynow=1-npanels*(panelheight+ysep);
hpan=uipanel(hdp,'tag',['data_panel' int2str(npanels)],'units','normalized',...
    'position',[xnow ynow panelwidth panelheight],'userdata',npanels);
geom(4)=ynow;
hpanels{npanels}=hpan;
set(hmpan,'userdata',{hpanels geom []});
if(npanels==1)
    inlinedefault='SEGY standard';
    xlinedefault=inlinedefault;
    locs=segybytelocs;
else
    hinline=findobj(hpanels{npanels-1},'tag','inline');
    hxline=findobj(hpanels{npanels-1},'tag','xline');
    inlinedefault=get(hinline,'string');
    xlinedefault=get(hxline,'string');
    locs(2)=get(hxline,'userdata');
    locs(1)=get(hinline,'userdata');
end
%file name
xn=0;yn=.1;
dg=.7*ones(1,3);
ht2=1.1;
uicontrol(hpan,'style','pushbutton','string',fname,'tag','filename','units','normalized',...
    'position',[xn yn wid ht],'horizontalalignment','center','userdata',path,...
    'callback','sane(''selectnewdataset'');','Tooltipstring',['Path: ' path]);
%separator
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%dataset name
xn=xn+wid+xsep;
uicontrol(hpan,'style','edit','string',dname,'tag','dataname','units','normalized',...
    'position',[xn yn wid ht],'horizontalalignment','center');
%separator
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%display button
xn=xn+wid+xsep;
wid2=(1-2.1*wid-6*xsep)/5;%nominal width of last five items
uicontrol(hpan,'style','radiobutton','tag','display','units','normalized',...
    'position',[xn+.3*wid2 yn .75*wid2 ht],'value',0,...
    'tooltipstring','If clicked, then this dataset will be displayed after reading.');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%time shift
xn=xn+.75*wid2+xsep;
uicontrol(hpan,'style','edit','string','0.0','units','normalized','position',[xn,yn,.75*wid2,ht],...
    'tooltipstring','Dataum shift for this dataset.','tag','tshift');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%inlineloc button
xn=xn+.75*wid2+xsep;
uicontrol(hpan,'style','pushbutton','string',inlinedefault,'units','normalized','position',...
    [xn,yn,1.25*wid2,ht],'callback','sane(''choosebyteloc'');','tag','inline',...
    'tooltipstring',['loc= ' int2str(locs(1)) ', Push to change.'],'userdata',locs(1));
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%xlineloc button
xn=xn+1.25*wid2+xsep;
uicontrol(hpan,'style','pushbutton','string',xlinedefault,'units','normalized','position',...
    [xn,yn,1.25*wid2,ht],'callback','sane(''choosebyteloc'');','tag','xline',...
    'tooltipstring',['loc= ' int2str(locs(2)) ', Push to change.'],'userdata',locs(2));
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
xn=xn+1.25*wid2+xsep;
uicontrol(hpan,'style','pushbutton','string','Trace headers','units','normalized','position',...
    [xn,yn,1.25*wid2,ht],'callback','sane(''showtraceheaders'');','tag','traceheaders',...
    'tooltipstring','Show first # trace headers.','userdata',[]);
if(npanels>8)
    %scroll the window
    hslider=findobj(hdial,'tag','slider');
    sliderval=get(hslider,'value');
    sliderval=sliderval-.04;
    set(hslider,'value',sliderval);
    set(hdp,'position',[0 -3*sliderval 1 4]);
end
end

function parmset=parmsetfilter(parmset)
% With no input: returns a filter parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function sanetask (below) for more detail.

if(nargin<1)
    nparms=5;
    parmset=cell(1,3*nparms+1);
    parmset{1}='filter';
    parmset{2}='fmin';
    parmset{3}='10';
    parmset{4}='Define low-cut frequency in Hz';
    parmset{5}='dfmin';
    parmset{6}='5';
    parmset{7}='Define low-end rolloff in Hz (use .5*fmin if uncertain)';
    parmset{8}='fmax';
    parmset{9}='100';
    parmset{10}='Define high-cut frequency in Hz';
    parmset{11}='dfmax';
    parmset{12}='10';
    parmset{13}='Define high-end rolloff in Hz (use 10 or 20 if uncertain)';
    parmset{14}='phase';
    parmset{15}={'zero' 'minimum' 1};
    parmset{16}='Choose zero or minimum phase';
else
   fmin=str2double(parmset{3});
   dfmin=str2double(parmset{6});
   fmax=str2double(parmset{9});
   dfmax=str2double(parmset{12});
   msg=[];
   if(isnan(fmin) || isnan(fmax) || isnan(dfmin) || isnan(dfmax))
       msg='Parameters must be numbers';
   else
       if(fmin<0)
           msg=[msg '; fmin cannot be negative'];
       end
       if(dfmin<0)
           msg=[msg '; dfmin cannot be negative'];
       end
       if(dfmin>fmin)
           msg=[msg '; dfmin cannot be greater than fmin'];
       end
       if(fmax<0)
           msg=[msg '; fmax cannot be negative'];
       end
       if(dfmax>250-fmax)%bad practice but I've hardwired the Nyquist for 2 mils. I'm a baaaad boy
           msg=[msg '; dfmax is too large'];
       end
       if(fmax<fmin)
           if(fmax~=0)
               msg=[msg '; fmax must be greater than fmin'];
           end
       end
   end
   if(~isempty(msg))
        if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetdecon(parmset,t)
% With no input: returns a filter parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function sanetask (below) for more detail.

if(nargin<1)
    hsane=findsanefig;
    hfile=findobj(hsane,'tag','file');
    proj=get(hfile,'userdata');
    t=proj.tcoord{1};
    nparms=9;
    parmset=cell(1,3*nparms+1);
    parmset{1}='decon';
    parmset{2}='oplen';
    parmset{3}='0.1';
    parmset{4}='Decon operator length in seconds';
    parmset{5}='stab';
    parmset{6}='0.001';
    parmset{7}='Stability constant, between 0 and 1';
    parmset{8}='topgate';
    parmset{9}=time2str(t(1)+.25*(t(end)-t(1)));
    parmset{10}='top of design gate (seconds)';
    parmset{11}='botgate';
    parmset{12}=time2str(t(1)+.75*(t(end)-t(1)));
    parmset{13}='bottom of design gate (seconds)';
    parmset{14}='fmin';
    parmset{15}='5';
    parmset{16}='Post-decon filter low-cut frequency in Hz';
    parmset{17}='dfmin';
    parmset{18}='2.5';
    parmset{19}='Define low-end rolloff in Hz (use .5*fmin if uncertain)';
    parmset{20}='fmax';
    parmset{21}='100';
    parmset{22}='Post-decon filter high-cut frequency in Hz';
    parmset{23}='dfmax';
    parmset{24}='10';
    parmset{25}='Define high-end rolloff in Hz (use 10 or 20 if uncertain)';
    parmset{26}='phase';
    parmset{27}={'zero' 'minimum' 1};
    parmset{28}='Post-decon filter: Choose zero or minimum phase';
else
   oplen=str2double(parmset{3});
   stab=str2double(parmset{6});
   topgate=str2double(parmset{9});
   botgate=str2double(parmset{12});
   fmin=str2double(parmset{15});
   dfmin=str2double(parmset{18});
   fmax=str2double(parmset{21});
   dfmax=str2double(parmset{24});
   msg=[];
   if(isnan(fmin) || isnan(fmax) || isnan(dfmin) || isnan(dfmax) || isnan(oplen) ||isnan(stab)...
           || isnan(topgate) || isnan(botgate))
       msg='Parameters must be numbers';
   else
       if(oplen<0)
           msg=[msg '; oplen cannot be negative'];
       end
       if(oplen>1)
           msg=[msg '; oplen must be less than 1 (second)'];
       end
       if(stab<0)
           msg=[msg '; stab cannot be negative'];
       end
       if(stab>1)
           msg=[msg '; stab must be less than 1'];
       end
       if(topgate<t(1))
           msg=[msg ['; topgate must be greater than ' time2str(t(1)) 's']];
       end
       if(topgate>t(end))
           msg=[msg ['; topgate must be less than ' time2str(t(end)) 's']];
       end
       if(botgate<topgate)
           msg=[msg '; botgate must be greater than topgate' ];
       end
       if(botgate>t(end))
           msg=[msg ['; botgate must be less than ' time2str(t(end)) 's']];
       end
       if(fmin<0)
           msg=[msg '; fmin cannot be negative'];
       end
       if(dfmin<0)
           msg=[msg '; dfmin cannot be negative'];
       end
       if(dfmin>fmin)
           msg=[msg '; dfmin cannot be greater than fmin'];
       end
       if(fmax<0)
           msg=[msg '; fmax cannot be negative'];
       end
       if(dfmax>250-fmax)%bad practice but I've hardwired the Nyqiost for 2 mils
           msg=[msg '; dfmax is too large'];
       end
       if(fmax<fmin)
           if(fmax~=0)
               msg=[msg '; fmax must be greater than fmin'];
           end
       end
   end
   if(~isempty(msg))
       if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetwavenumber(parmset)
% With no input: returns a filter parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)

if(nargin<1)
    nparms=2;
    parmset=cell(1,3*nparms+1);
    parmset{1}='wavenumber lowpass';
    parmset{2}='sigmax';
    parmset{3}='0.125';
    parmset{4}='Define high-cut crossline wavenumber as a fraction of Nyquist';
    parmset{5}='sigmay';
    parmset{6}='0.125';
    parmset{7}='Define high-cut inline wavenumber as a fraction of Nyquist';
else
   sigmax=str2double(parmset{3});
   sigmay=str2double(parmset{6});
   msg=[];
   if(isnan(sigmax) || isnan(sigmay) )
       msg='Parameters must be numbers';
   else
       if(sigmax<0)
           msg=[msg '; sigmax cannot be negative'];
       end
       if(sigmax>1)
           msg=[msg '; sigmax cannot be greater than 1'];
       end
       if(sigmay<0)
           msg=[msg '; sigmay cannot be negative'];
       end
       if(sigmay>1)
           msg=[msg '; sigmay cannot be greater than 1'];
       end
   end
   if(~isempty(msg))
        if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetfdom(parmset,t)
% With no input: returns a fdom parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function sanetask (below) for more detail.

if(nargin<1)
    nparms=4;
    parmset=cell(1,3*nparms+1);
    parmset{1}='Dominant Frequency';
    parmset{2}='twin';
    parmset{3}='0.01';
    parmset{4}='Gaussian window half-width in seconds';
    parmset{5}='ninc';
    parmset{6}='2';
    parmset{7}='Increment between adjacent windows as an integer times the sample rate';
    parmset{8}='Fmax';
    parmset{9}='100';
    parmset{10}='Define high-cut frequency in Hz';
    parmset{11}='tfmax';
    parmset{12}='';
    parmset{13}='Time (seconds) at which Fmax occurs, leave blank if time invariant';
else
   twin=str2double(parmset{3});
   ninc=str2double(parmset{6});
   fmax=str2double(parmset{9});
   tfmax=str2double(parmset{12});
   msg=[];
   if(isnan(twin) || isnan(ninc) || isnan(fmax) )
       msg='Parameters must be numbers';
   else
       trange=t(end)-t(1);
       dt=t(2)-t(1);
       tinc=ninc*dt;
       if(twin<0)
           msg=[msg '; twin cannot be negative'];
       end
       if(twin>.1*trange)
           msg=[msg '; twin is too large'];
       end
       if(tinc<0)
           msg=[msg '; tinc=ninc*dt cannot be negative'];
       end
       if(tinc>twin)
           msg=[msg '; tinc=ninc*dt cannot be greater than twin'];
       end
       if(fmax<0)
           msg=[msg '; fmax cannot be negative'];
       end
       fnyq=.5/dt;
       if(fmax>fnyq)
           msg=[msg '; fmax is too large'];
       end
       if(isnan(tfmax))
           tfmax=[];
       end
       if(tfmax<0)
           msg=[msg '; tfmax cannot be negative'];
       end
       if(tfmax>t(end))
           msg=[msg '; tfmax too large'];
       end
   end
   if(~isempty(msg))
        if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetspecdecomp(parmset,t)
% With no input: returns a specdecomp parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function sanetask (below) for more detail.

if(nargin<1)
    %invent a fake t
    t=0:.002:3;
    nparms=5;
    parmset=cell(1,3*nparms+1);
    parmset{1}='specdecomp';
    parmset{2}='Twin';
    parmset{3}='.02';
    parmset{4}='Half-width of Gaussian window (in seconds)';
    parmset{5}='Ninc';
    parmset{6}='2';
    parmset{7}='Increment between window centers, expressed in samples';
    parmset{8}='Tmin';
    parmset{9}=num2str(t(1));
    parmset{10}='Start of time window, in seconds.';
    parmset{11}='Tmax';
    parmset{12}=num2str(t(end));
    parmset{13}='End of time window, in seconds.';
    parmset{14}='Fout';
    parmset{15}={'10 30 60'};
    parmset{16}='A list of output (integer) frequencies, separated by spaces or commas (not both).';
else
   twin=str2double(parmset{3});
   Ninc=str2double(parmset{6});
   tmin=str2double(parmset{9});
   tmax=str2double(parmset{12});
   tmp1=sscanf(parmset{15}{1},'%g');%space separated read
   tmp2=sscanf(parmset{15}{1},'%g,');%comma separated read
   if(length(tmp1)>length(tmp2))
       fout=tmp1;
   else
       fout=tmp2;
   end
   msg=[];
   if(isnan(twin) || isnan(Ninc) || isnan(tmin) || isnan(tmax) || any(isnan(fout)))
       msg='Parameters must be numbers';
   else
       if(twin<0)
           msg=[msg '; Twin cannot be negative'];
       end
       if(twin> .1*(t(end)-t(1)))
           msg=[msg '; Twin too large'];
       end
       if(Ninc<=0)
           msg=[msg '; Ninc must be positive'];
       end
       dt=t(2)-t(1);
       if(Ninc*dt>twin)
           msg=[msg '; Ninc too large (Ninc*dt must be less than Twin'];
       end
       if(tmin<0)
           msg=[msg '; Tmin cannot be negative'];
       end
       if(tmin>tmax)
           msg=[msg '; Tmin cannot be greater than Tmax'];
       end
       if(tmax<0)
           msg=[msg '; Tmax cannot be negative'];
       end
       if(tmax<tmin)
           msg=[msg '; Tmax cannot be less than Tmin'];
       end
       if(any(fout<0))
           msg=[msg '; Fout cannot have negative entries'];
       end
       fnyq=.5/dt;
       if(any(fout>fnyq))
           msg=[msg ['; Fout cannot have values greater than Nyquist=' num2str(fnyq) 'Hz']];
       end
   end
   if(~isempty(msg))
       if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end


function val=contains(str1,str2)
ind=strfind(str1,str2);
if(isempty(ind))   % EMP>
    val=false;
else
    val=true;
end

end

function sanetask(datasets,parmset,task,iout)
% 
% This function is called by SANE to initiate a data-processing task on one of its datasets. It puts
% up a dialog window in which the dataset is chosen and the parameters are specified. The first two
% inputs are the list of possible datasets and the parameter set, or parmset. The list of possible
% datasets is just a cell array of strings. The parmset is also a cell array but with a defined
% structure. It has length 3*nparms+1 where nparms is the number of parameters that must be defined
% for the task and all entries are strings. The first entry of the parmset is a string giving the
% name of the task, for example, 'spikingdecon' or 'domfreq' or 'filter'. Then for each of nparms
% parameters, there are three consequtive values: the name of the parameter (a string), the current
% parameter value (a string), and the tooltipstring. The current parameter value can either be a
% number in a string if the parameter is numeric or a string with choices such as 'yes|no'.
% 
% datasets ... cell array of dataset names
% parmset ... parameter set for the task
% task ... string giving the internal name of the task. This comes from the tag of the
%       corresponding menu
% iout ... vector of length 4, either 1 or 0, saying which output options are available. The 4
%       options are 'Save SEGY and display','Replace input in project','Save in project as new'
% *********** default = ones(1,4) ***************
% 

if(nargin<4)
    iout=ones(1,4);
end

hsane=gcf;
hmsg=findobj(hsane,'tag','message');
taskname=parmset{1};
htask=figure('toolbar','none','menubar','none');
set(hmsg,'string',['Please complete parameter specifications in dialog window for task ' taskname])
% set(htask,'name',['SANE: Computation task ' task]);
pos=get(hsane,'position');
% wid=figsize(1)*pos(3);
% ht=figsize(2)*pos(4);
nparms=(length(parmset)-1)/3;
fwid=500;%width in pixels of figure
ht=30;%height of a single item in pixels
ysep=5;%y separation in pixels
xsep=5;
fht=(nparms+5)*(ht+ysep);%fig ht in pixels
%make upper left corners same
xul=pos(1);
yul=pos(2)+pos(4);
yll=yul-fht;
set(htask,'position',[xul yll fwid fht],'name',['SANE: ' taskname ' dialog'],'closerequestfcn','sane(''canceltask'')');
xnot=.1*fwid;ynot=fht-2*ht;
xnow=xnot;ynow=ynot;
wid=fwid*.8;
uicontrol(htask,'style','text','string',['Computation task: ' taskname],'units','pixels',...
    'position',[xnow ynow wid ht],'tag','task','userdata',{task parmset},'fontsize',12);
ynow=ynow-ht-ysep;
wid=fwid*.2;
uicontrol(htask,'style','text','string','Input dataset>>','units','pixels',...
    'position',[xnow ynow wid ht]);
xnow=xnow+wid+xsep;
wid=fwid*.6;
uicontrol(htask,'style','popupmenu','string',datasets,'units','pixels','tag','datasets',...
    'position',[xnow ynow wid ht],'tooltipstring','Choose the input dataset');

ynow=ynow-ht-ysep;
wid=fwid*.2;
xnow=xnot;
uicontrol(htask,'style','text','string','Output dataset>>','units','pixels',...
    'position',[xnow ynow wid ht]);
xnow=xnow+wid+xsep;
wid=fwid*.3;
outopts={'Save SEGY','Save SEGY and display','Replace input in project','Save in project as new'};
uicontrol(htask,'style','popupmenu','string',outopts(logical(iout)),'units','pixels','tag','outputs',...
    'position',[xnow ynow wid ht],'tooltipstring','Choose the output option','value',sum(iout));

for k=1:nparms
    xnow=xnot;
    ynow=ynow-ht-ysep;
    wid=.2*fwid;
    uicontrol(htask,'style','text','string',parmset{3*(k-1)+2},'units','pixels','position',...
        [xnow,ynow,wid,ht],'fontsize',12);
    xnow=xnow+wid+xsep;
    wid=.5*fwid;
    parm=parmset{3*(k-1)+3};
    if(~iscell(parm))
        uicontrol(htask,'style','edit','string',parm,'units','pixels','position',...
            [xnow,ynow,wid,ht],'tooltipstring',parmset{3*(k-1)+4},'tag',parmset{3*(k-1)+2},'fontsize',12);
    else
        if(length(parm)==1)
            uicontrol(htask,'style','edit','string',parm{1},'units','pixels','position',...
                [xnow,ynow,wid,ht],'tooltipstring',parmset{3*(k-1)+4},'tag',parmset{3*(k-1)+2},'fontsize',12);
        else
            uicontrol(htask,'style','popupmenu','string',parm(1:end-1),'units','pixels','position',...
                [xnow,ynow,wid,ht],'tooltipstring',parmset{3*(k-1)+4},'tag',parmset{3*(k-1)+2},...
                'value',parm{end},'fontsize',12);
        end
    end
end

%done and cancel buttons

xnow=.25*fwid;
wid=.3*fwid;
ynow=ynow-ht-ysep;
uicontrol(htask,'style','pushbutton','string','Done','units','pixels','tag','done',...
    'position',[xnow,ynow,wid,ht],'tooltipstring','Click to initiate the Task',...
    'callback','sane(''dotask'')');

xnow=xnow+wid+xsep;
uicontrol(htask,'style','pushbutton','string','Cancel','units','pixels','tag','cancel',...
    'position',[xnow,ynow,wid,ht],'tooltipstring','Click to cancel the Task',...
    'callback','sane(''canceltask'')');
end

function parmset=getparmset(task)
hsane=findsanefig;
hfile=findobj(hsane,'tag','file');
proj=hfile.UserData;
if(isfield(proj,'parmsets'))
    parmsets=proj.parmsets;
else
    parmsets=[];
end
%parmset=[];
for k=1:length(parmsets)
   thisparmset=parmsets{k};
   if(strcmp(thisparmset{1},task))
       parmset=thisparmset;
       return;
   end
end
%if we reach here then there is no stored parmset so we get the default one
switch task
    case 'filter'
        parmset=parmsetfilter;
    case 'spikingdecon'
        parmset=parmsetdecon;
    case 'phasemap'
        parmset=parmsetphasemap;
    case 'fdom'
        parmset=parmsetfdom;
    case 'wavenumber'
        parmset=parmsetwavenumber;
    case 'specdecomp'
        parmset=parmsetspecdecomp;
end
return

end

function setparmset(parmset)
hsane=findsanefig;
hfile=findobj(hsane,'tag','file');
proj=hfile.UserData;
if(isfield(proj,'parmsets'))
    parmsets=proj.parmsets;
    task=parmset{1};
    done=false;
    for k=1:length(parmsets)
        thisparmset=parmsets{k};
        if(strcmp(thisparmset{1},task))
            parmsets{k}=parmset;
            done=true;
            break;
        end
    end
    if(~done)
        parmsets{length(parmsets)+1}=parmset;
    end
    proj.parmsets=parmsets;
else
    proj.parmsets={parmset};
end
set(hfile,'userdata',proj);
end

function val=getparm(parmset,parm)
    nparms=(length(parmset)-1)/3;
    for k=1:nparms
        if(strcmp(parm,parmset{3*(k-1)+2}))
            parmdat=parmset{3*(k-1)+3};
            if(~iscell(parmdat))
                val=str2double(parmdat);
            else
                if(length(parm)==1)
                    tmp1=sscanf(parmset{15}{1},'%g');%space separated read
                    tmp2=sscanf(parmset{15}{1},'%g,');%comma separated read
                    if(length(tmp1)>length(tmp2))
                        val=tmp1;
                    else
                        val=tmp2;
                    end
                else
                    val=parmdat{parmdat{end}};
                end
            end
        end
    end
end

function memorybuttonoff(idat)
%set the memory button off on the datapanel for dataset #idat
hsane=findsanefig;
hmpan=findobj(hsane,'tag','master_panel');
udat=get(hmpan,'userdata');
hdatapans=udat{1};
hpan=hdatapans{idat};
hno=findobj(hpan,'tag','memoryno');
hyes=findobj(hpan,'tag','memoryyes');
set(hno,'value',1)
set(hyes,'value',0)
end

function memorybuttonon(idat)
%set the memory button off on the datapanel for dataset #idat
hsane=findsanefig;
hmpan=findobj(hsane,'tag','master_panel');
udat=get(hmpan,'userdata');
hdatapans=udat{1};
hpan=hdatapans{idat};
hno=findobj(hpan,'tag','memoryno');
hyes=findobj(hpan,'tag','memoryyes');
set(hno,'value',0)
set(hyes,'value',1)
end

function locs=canadabytelocs
locs=[9,13];
end

function locs=kingdombytelocs
locs=[17,13];
end

function locs=segybytelocs
locs=[189,193];
end

function sgrv=getsegyrev(idata,hsane)
%this is needed because of inconsistencies in the project structure definition
if(nargin<2)
    hsane=findsanefig;
end
hfile=findobj(hsane,'label','File');
proj=get(hfile,'userdata');
sgrv=1;
if(iscell(proj.segyrev))
    tmp=proj.segyrev{:};
    if(length(tmp)<=idata)
        sgrv=tmp(idata);
    end
else
    if(length(proj.segyrev)<=idata)
        sgrv=proj.segyrev(idata);
    end
end

end

function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','sane(''makepptslide'');');
%the title string will be stored as userdata
end

function s=datasetsize(idata)
%if idata is provided then we return the size of that dataset, otherwise we return the size of all
%of the datasets in the projects.
if(nargin<1)
    idata=0;
end
hsane=findsanefig;
hfile=findobj(hsane,'tag','file');
proj=get(hfile,'userdata');
if(idata==0)
    %we determine the total size in bytes of all of the datasets in the project
    ndatasets=length(proj.datanames);
    s=0;
    for k=1:ndatasets
        s=s+length(proj.xcoord{k})*length(proj.ycoord{k})*length(proj.tcoord{k})*4;
    end
else
    ndatasets=length(proj.datanames);
    if(idata>ndatasets)
        error('SANE: attempt to access unknown dataset')
    end
    s=length(proj.xcoord{idata})*length(proj.ycoord{idata})*length(proj.tcoord{idata})*4;
end
end

function sane_slider(src,eventdata,arg1) %#ok<INUSL>
val = get(src,'Value');
set(arg1,'Position',[0 -3*val 1 4])

end
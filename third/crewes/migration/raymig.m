function [fig_seis,fig_refl,fig_vel]=raymig(seis,vel,t,x,z,titlestring,smoothers)
% RAYMIG: Interactive normal incidence raytrace migration and modelling
% 
% raymig(seis,vel,t,x,z,titlestring,smoothers)
%
% Display a set of 3 plotimage windows designed to facilitate interactive,
% normal incidence, ray trace migration and modelling. Window 1 contains the zero offset seismic data,
% Window 2 displays the velocity model, and Window 3 also contains the
% velcity model with an option to smooth.
%
% seis ... 2D matrix containing the seismic zero offset section
% vel ... 2D matrix contining the velocity model. This must be interval or
%       instantaneous velocity in depth.
% NOTE: seis and vel must have the same number of columns
% t ... row (time) cooordinate vector for seis. Must be the same length as the
%       number of rows in seis.
% x ... column (distance) coordinate vector for seis and vel. Must be the
%       same length as the number of columns in seis and vel.
% z ... row (depth) coordinate vector for vel. Must be the same length as
%       the number of rows in vel.
%NOTE: x and z must have the same sample size. That is, the velocuty matrix
%   must be on a square grid.
% titlestring ... string identfying this study. Will appear on each window.
% smoothers ... list of factors for precomputed smoothers. Each smoother
%   will have a Gaussian full width that is smoothers(k) times the dominant
%   wavelength.
%************** default [.25 .5 .75 1 1.5 2 3 4] *****************
% WARNING: the longer smoothers can take a long while to apply to vel. Try
% the default list firs.
%
% fig_seis ... handle of the seismic figure
% fig_refl ... handle of the velocity model figure
% fig_vel ... handle of the smoothed model figure
%
% G.F. Margrave, CREWES, 2014
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

if(isnumeric(seis))
    action='init';
else
    action=seis;
end
if(strcmp(action,'init'))
    if(nargin<7)
        smoothers=[.25 .5 .75 1 1.5 2 3 4];
    end
    %compute smoother size as the dominant wavelength
    ntraces=size(seis,2);
    fdom=dom_freq(seis(:,round(ntraces/2)),t);
    vmean=mean(vel(:));
    smo=.5*vmean/fdom;

    xrim=5;%percent width of rim around screem
    dx=x(2)-x(1);
    plotimage(seis,t,x);
    grid
    fig_seis=gcf;
    hm=findobj(fig_seis,'tag','zoompickoption');
    set(hm,'value',2);
    plotimage('zoompick');
    plotimage('imagecontrolsoff');
    xlabel('distance (m)');ylabel('time (s)');
    hm=findobj(fig_seis,'tag','messages');
    set(hm,'string','use MB1 to draw a time dip and then click one of the migrate buttons')
    clearpicksbutton(gcf);
    pititle(['Seismic section for ' titlestring])
    % figure;
    % imagesc(x,z,vel);colorbar
    %true velocity picture
    reflectivity=afd_reflect(vel,5);
    plotimage(reflectivity,z,x)
    grid
    
    xlabel('distance (m)');ylabel('depth (m)')
    fig_refl=gcf;
    hm=findobj(fig_refl,'tag','zoompickoption');
    set(hm,'value',2);
    plotimage('zoompick');
    plotimage('imagecontrolsoff');
    hm=findobj(fig_refl,'tag','messages');
    pititle(['Reflectivity model for ' titlestring]);
    axis equal
    ylim([z(1) z(end)]);xlim([x(1) x(end)])
    set(hm,'string','use MB1 to draw a true dip and then click one of the model buttons')
    clearraysbutton(fig_refl);
    clearpicksbutton(fig_refl);
    hmodtrue=raymodbutton(fig_refl,fig_seis,vel,dx,'true','r');
    hmigtrue=raymigbutton(fig_seis,fig_refl,vel,dx,'true','r');
    
    
    figure
    set(gcf,'toolbar','none','menubar','none');
    fig_vel=gcf;
    hsmo=uimenu(gcf,'label','Click to choose smoother');
    velsmo=cell(size(smoothers));
    hwait=waitbar(0,'Applying smoothers, please be patient ...');
    ione=near(smoothers,1);
    for k=1:length(smoothers)
        hm=uimenu(hsmo,'label',['Smoother ' num2str(smoothers(k)) ' times dominant wavelength'],...
            'callback','raymig(''smooth'')','userdata',[k smoothers(k) smo]);
        if(k==ione)
            set(hm,'checked','on');
        end
        %smoothed velocity picture
        velsmo{k}=gaussian_smoother(vel,x,z,smo*smoothers(k));
        waitbar(k/length(smoothers),hwait)
    end
    close(hwait)
    
    subplot('position',[.1 .1 .35 .8])
    imagesc(x,z,vel);
    title([titlestring ' velocity (true)']);
    xlabel('distance (m)');ylabel('depth (m)')
    set(gca,'tag','truevel');
    trueaxe=gca;
    subplot('position',[.5 .1 .46 .8] )
    clim=[min(vel(:)) max(vel(:))];
    imagesc(x,z,velsmo{ione(1)},clim);
    set(gca,'ytick',[])
    set(gca,'tag','smoothvel');
    smoothaxe=gca;
    colorbar
    title(['Velocity smoothed, smoother width= ' num2str(2*smo)])
    xlabel('distance (m)');
    set(fig_vel,'name',['Velocity displays for ' titlestring])
    hmigsmo=raymigbutton(fig_seis,fig_refl,velsmo{ione(1)},dx,'smooth',[0 0 0]);
    hmodsmo=raymodbutton(fig_refl,fig_seis,velsmo{ione(1)},dx,'smooth',[0 0 0]);

    screensize=get(0,'screensize');

    sep=40;%figure separation in pixels
    figwidth=round(screensize(3)*(1-3*xrim/100)/2);%figure width in pixels
    figheight=round(screensize(4)*(1-3*xrim/100)/2);%figure height in pixels
    xnotseis=round(screensize(3)*xrim/100)+1;
    xnotmod=xnotseis+sep+figwidth;
    ynotseis=round(screensize(4)/2);
    ynotmod=ynotseis;
    ysep=round(.1*figheight);%this is an attempt to account for the top part of the window that containes the menus
    ynotmodsmo=ynotmod-sep-figheight-ysep;
    set(fig_seis,'position',[xnotseis ynotseis figwidth figheight])
    set(fig_refl,'position',[xnotmod ynotmod figwidth figheight])
    set(fig_vel,'position',[(xnotmod+xnotseis)*.4 ynotmodsmo 1.5*figwidth figheight])
    set(fig_vel,'userdata',{velsmo hmigtrue hmodtrue hmigsmo hmodsmo trueaxe smoothaxe clim});

    %put up instructions

    titlestring='Instructions for normal-incidence raytrace migration and modelling';
    instructions=['The three active figures before you are: #1 (Top left) The seismic section '...
        'where you pick time dips to define migration rays and where time-dips calculated from '...
        'modelling are displayed. #2 (Top right) The reflectivity model where migration rays are drawn '...
        'as defined by time-dips picked in #1 and where modelling rays are defined by picking '...
        'geological dips. #3 (bottom) The true and smoothed velocity models, initially smoothed by ' ...
        'a Gaussian whose width equals the dominant wavelength. To migrate, begin in the seismic '...
        'figure using the left mouse button to click and drag on the seismic section to define a time-dip tangent '...
        'to an event that you wish to migrate. When you release the mouse button a short red line ' ...
        'will appear on the seismic section defining your pick. Note that this pick is defined entirely ' ...
        'by you and it is your task to ensure that it is accurately tangent to a seismic primary reflection. '...
        'After defining one or more time-dips then click the button at the top of the seismic figure '...
        'that says ''Migrate figA -> figB true''. (A and B will be replaced by Figure numbers that '...
        'depend on how many figures you have open.) This will cause red migration rays to be drawn in the '...
        'reflectivity model figure. The rays start at z=0 and at the x coordinate of the center of the pick. They '...
        'end when the traveltime along the ray is 1/2 of the traveltime of the pick. ',...
        ' The angle the ray makes at the surface is defined by the time-dip that you picked and the near-surface velocity. At the end of the ray ' ...
        'a short segment is drawn perpendicular to the ray indicating the estimated structure dip. Next click '...
        'the button labelled ''Migrate figA -> figB smooth'' and black rays will be drawn using the '...
        'smoothed velocity model. Buttons are provided to clear picks and clear rays and you can define '...
        'and migrate any number of picks. You can draw multiple time-dips with the mouse and then migrate them all at once. ',...
        'Modelling, the inverse process to migration, is accomplished '...
        'in a similar fashion except that picks are made in the reflectivity model in depth and one of the '...
        'modelling buttons is pushed. The resulting normal incidence raypaths are drawn and the predicted timedips are plotted on the seismic section.'];
        %msgbox(instructions,titlestring);
        fontsize=12;windowsize=[.4 .5];initialstate=1;
        helpbutton(fig_seis,instructions,titlestring,fontsize,windowsize,initialstate);
        pos=get(gcf,'position');
        set(gcf,'position',[(xnotmod+xnotseis)*.6 ynotmodsmo+.5*figheight pos(3:4)])
    %     set(h,'position',[xnotseis,ynotmodsmo,figwidth,figheight])
elseif(strcmp(action,'smooth'))
    udat=get(gcf,'userdata');
    velsmo=udat{1};
    %udath=udat{2};
    hm=gcbo;%the menu that was selected
    smodat=get(hm,'userdata');
    %compute new smoother
    smonew=prod(smodat(2:3));
    velsmonew=velsmo{smodat(1)};
    %get true model
    truedat=get(udat{2},'userdata');
    veltrue=truedat{1};
    dx=truedat{2};
    x=(0:size(veltrue,2)-1)*dx;
    z=(0:size(veltrue,1)-1)*dx;
    %apply smoother to veltrue
%     set(gcf,'pointer','watch')
%     velsmo=gaussian_smoother(veltrue,x,z,smonew);
%     set(gcf,'pointer','arrow')
    %put the new model in the appropriate buttons
    velsmodat=get(udat{4},'userdata');
    velsmodat{1}=velsmonew;
    set(udat{4},'userdata',velsmodat);
    velsmodat=get(udat{5},'userdata');
    velsmodat{1}=velsmonew;
    set(udat{5},'userdata',velsmodat);
    %refresh the plot
    set(gcf,'currentaxes',udat{7});
    clim=udat{8};
    imagesc(x,z,velsmonew,clim);
    set(gca,'ytick',[])
    colorbar
    title(['Velocity smoothed, smoother width= ' num2str(2*smonew)])
    xlabel('distance (m)');
    %update checked status of menus 
    hp=get(hm,'parent');
    hk=get(hp,'children');
    set(hk,'checked','off');
    set(hm,'checked','on');
end
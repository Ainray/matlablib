function [seis3D,xline,iline,xcdp,ycdp,kseq]=make3Dvol(seis,xlineall,ilineall,xcdpall,ycdpall,tin,t1,t2,precision)
% MAKE3DVOL: form a matrix of traces into a 3D volume
%
% [seis3D,xline,iline,xcdp,ycdp,kxline]=make3Dvol(seis,xlineall,ilineall,xcdpall,ycdpall,tin,t1,t2,precision)
%
% When a 3D SEGY dataset is read in, it is usually stored as a large 2D
% array (one trace after another) regardless of the actual geometry of the
% dataset. Provided that the surface x and y coordinates of the data are
% available, this function reshapes the traces into a 3D matrix (3D volume)
% suitable for viewing in plotimage3D. Here the x coordinates are called
% xline (which usally also means crossline) and the y coordinates are
% called iline (or inline). It is preferable if xline and iline are integer
% coordinates, with unit increments between lines. These coordinates then
% determine the forming of the 3D volume. The output volume, seis3D, will
% have time as the first dimension, xline as the second dimension, and
% iline as the third dimension. Thus seis3D(:,:,10) is inline number 10 and
% seis3D(:,10,:) is crossline number 10. Note that seis3D(:,10,:) is not a
% conventional 2D matrix but squeeze(seis3D(:,10,:)) is. xline and xcdp are
% assumed to be the same dimension and similarly with iline and ycdp.
%
% seis ... 3D seismic data as a 2D matrix
% xlineall ... vector of xline coordinates, one per trace. Length(xlineall)
%       must equal size(seis,2).
% ilineall ... vector of inline coordinates, one per trace. Length(ilineall)
%       must equal size(seis,2).
% xcdpall ... vector of xcdp coordinates, one per trace. Length(xcdpall)
%       must equal size(seis,2). If supplied as nan, then it will be
%       atomatically generated as 1:length(xlineall)
% *********** default zeros(size(xlineall))**********
% ycdpall ... vector of xcdp coordinates, one per trace. Length(ycdpall)
%       must equal size(seis,2). If supplied as nan, then it will be
%       atomatically generated as 1:length(ilineall)
% *********** default zeros(size(ilineall))**********
% tin ... time coordinate for seis. Length(tin) must equal size(seis,1).
%       A value of nan gets the default.
% ********** .001*(0:size(seis,1)-1)' *****
% t1 ... first desired outout time. A value of nan gets the default.
% ********** default tin(1) **********
% t2 ... last desired output time. A value of nan gets the default.
% ********** default tin(end) **********
% precision ...  either 'single' or 'double'. If you are simply going to
%        display and interprete then choose 'single'.
% ********** default 'single' ********
%
% seis3D ... output 3D maxtrix, time is first dimension, xline is second
%       and iline is third
% xline ... crossline coordinates for the volume. length(xline) will equal
%       size(seis3D,2)
% iline ... crossline coordinates for the volume. length(xline) will equal
%       size(seis3D,3)
% xcdp ... xcdp coordinates for the volume. length(xcdp) will equal
%       size(seis3D,2)
% ycdp ... ycdp coordinates for the volume. length(ycdp) will equal
%       size(seis3D,3)
% kseq ... maxtrix of size=length(xline)-by-length(iline) giving the
%       index into xlineall for each trace in the volume. This is needed to
%       properly unmake the 3Dvol if it is to be written to SEGY using the
%       same headers as the original dataset. See unmake3Dvol. (There is no
%       need for a similar contruct for ilineall since it is identical.)
%       Using this will ensure that the output from unmake3Dvol will have
%       the same trace order as the input to make3Dvol. However, it will
%       not account for any changes in trace length.
% NOTE: kseq is a 2D array the same size as squeeze(seis3d(1,:,:)). This means it has the same
% spatial footprint as the 3D volume but has only one value per trace. The value of kseq(i,j)
% is the sequential trace number of the the 2D array input to this function. So kseq is the
% trace mapping from the 2D array to the 3D array.
%
% See unmake3Dvol for the inverse to this process.
%
% G.F. Margrave, CREWES (U of Calgary), 2016
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

if(nargin<6)
    tin=nan;
end

if(isnan(tin))
    tin=.001*(0:size(seis,1)-1)';
end

if(nargin<7)
    t1=tin(1);
end
if(nargin<8)
    t2=tin(end);
end
if(nargin<9)
    precision='single';
end

if(nargin<4)
    xcdpall=nan;
end

if(isnan(xcdpall))
    xcdpall=zeros(size(xlineall));
end

if(nargin<5)
    ycdpall=nan;
end

if(isnan(ycdpall))
    ycdpall=zeros(size(xlineall));
end

if(~strcmp(precision,'single')&&~strcmp(precision,'double'))
    error('precision must be either ''single'' or ''double''');
end
[nt,ntraces]=size(seis);
if(length(tin)~=nt)
    error('time coordinate does not match seismic');
end
if(length(ilineall)~=ntraces)
    error('ilineall does not match seismic volume')
end
if(length(xlineall)~=ntraces)
    error('xlineall does not match seismic volume')
end

if(length(xcdpall)~=ntraces)
    error('xcdpall does not match seismic volume')
end
if(length(ycdpall)~=ntraces)
    error('ycdpall does not match seismic volume')
end

ilmin=min(ilineall);
ilmax=max(ilineall);
xlmin=min(xlineall);
xlmax=max(xlineall);

iline=ilmin:ilmax;
xline=xlmin:xlmax;

xcdp=nan(size(xline));
ycdp=nan(size(iline));

nt=size(seis,1);
if(nargin<6)
    tin=1:nt;
    t1=1;
    t2=nt;
end

it=near(tin,t1,t2);

ntout=length(it);
M=memory;
if(strcmp(precision,'single'))
    if(M.MaxPossibleArrayBytes<ntout*length(xline)*length(iline)*4)
        seis3D='Attempt to create and array larger than the available memory';
        xline=[];iline=[];xcdp=[];ycdp=[];kseq=[];
        return;
    end
    seis=single(seis);
    seis3D=zeros(ntout,length(xline),length(iline),'single');
else
    seis3D=zeros(ntout,length(xline),length(iline));
end

kseq=nan(length(xline),length(iline));

ntraces=length(ilineall);

%determine if the dataset is ordered by inlines, crosslines, or nothing
dxline=diff(xlineall);
diline=diff(ilineall);
indx=find(dxline~=0);
indy=find(diline~=0);
if(length(indx)<.5*length(dxline)&&length(indy)>.5*length(diline))
    order='xline';
    disp('dataset appears to be ordered by xline');
elseif(length(indx)>.5*length(dxline)&&length(indy)<.5*length(diline))
    order='iline';
    disp('dataset appears to be ordered by iline');
else
    order='nothing';
    disp('dataset appears to have neither xline nor iline order');
end

switch order
    case 'nothing'
        %tic
        for k=1:ntraces
            i2=near(xline,xlineall(k));
            i3=near(iline,ilineall(k));
            xcdp(i2)=xcdpall(k);
            ycdp(i3)=ycdpall(k);
            seis3D(:,i2,i3)=seis(it,k);
            kseq(i2,i3)=k;
        end
        disp('volume completed')
        %toc
    case 'xline'
        %tic
        ind=find(dxline~=0);
        kmax=length(ind)+1;
        for k=1:kmax
            if(k<kmax)
                i2=near(xline,xlineall(ind(k)));%index for this line
            else
                i2=near(xline,xlineall(end));
            end
            if(k==1)
                jbeg=1;
            else
                jbeg=ind(k-1)+1;
            end
            if(k<kmax)
                jend=ind(k);
            else
                jend=ntraces;
            end
            for j=jbeg:jend
                i3=near(iline,ilineall(j));
                seis3D(:,i2,i3)=seis(it,j);
                xcdp(i2)=xcdpall(j);
                ycdp(i3)=ycdpall(j);
                kseq(i2,i3)=j;
            end
        end
        disp('volume completed')
        %toc
    case 'iline'
        %tic
        ind=find(diline~=0);
        kmax=length(ind)+1;
        for k=1:kmax
            if(k<kmax)
                i3=near(iline,ilineall(ind(k)));%index for this line
            else
                i3=near(iline,ilineall(end));
            end
            if(k==1)
                jbeg=1;
            else
                jbeg=ind(k-1)+1;
            end
            if(k<kmax)
                jend=ind(k);
            else
                jend=ntraces;
            end
            for j=jbeg:jend
                i2=near(xline,xlineall(j));
                seis3D(:,i2,i3)=seis(it,j);
                xcdp(i2)=xcdpall(j);
                ycdp(i3)=ycdpall(j);
                kseq(i2,i3)=j;
            end
        end
        disp('volume completed')
        %toc
        
end



%fill in xcdp and ycdp with values
ilive=find(~isnan(xcdp));
dxcdp=median(diff(xcdp(ilive)));
nx=length(xcdp);
xcdp(ilive(1)-1:-1:1)=xcdp(ilive(1))+(1:ilive(1)-1)*(-dxcdp);
xcdp(ilive(1)+1:nx)=xcdp(ilive(1))+(1:nx-ilive(1))*(dxcdp);

ilive=find(~isnan(ycdp));
dycdp=median(diff(ycdp(ilive)));
ny=length(ycdp);
ycdp(ilive(1)-1:-1:1)=ycdp(ilive(1))+(1:ilive(1)-1)*(-dycdp);
ycdp(ilive(1)+1:ny)=ycdp(ilive(1))+(1:ny-ilive(1))*(dycdp);
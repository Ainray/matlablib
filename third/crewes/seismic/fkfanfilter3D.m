function [seisf,masks,kx,ky]=fkfanfilter3D(seis,t,x,y,vmin,vmax,dv,tpad,xpad,ypad,fmask,debug)
%FKFANFILTER3D ... apply an f-k fan filter to a 3D seismic dataset
%
% [seisf,masks,kx,ky]=fkfanfilter3D(seis,t,x,y,va1,va2,dv,tpad,xpad,ypad,fmask)
%
% FKFANFILTER3D designs and applies an f-k (frequency-wavenumber) fan reject filter in 3D. The
% reject region is fan-shaped (when viewed in frequency and radial wavenumber) and defined by two
% bounding apparent velocities, va1 and va2. These are expressed as positive numbers and the filter
% is rotationally invariant about the vertical (t) axis. A raised cosine taper is applied to the
% filter edge. The filter is applied to each frequency as a radially symmetric multiplier (or mask)
% whose values lie between 0 and 1. This mask can be examined by returning all four values and then
% plotting it.
%
% seis ... 3D seismic matrix to be filtered. The first dimension is time, the second x and the third
%       y. All three coordinates must be regularly sampled.
% t ... time coordinate vector for seis. The length(t) must equal size(seis,1)
% x ... first space coordinate vector for seis. The length(x) must equal size(seis,2)
% y ... second space coordinate vector for seis. The length(y) must equal size(seis,3)
% va1 ... minumum apparent velocity defining the rejection fan. 
%       Enter 0 to reject everything slower than va2.
% va2 ... maximum apparent velocity defining the rejection fan.
% Requirement: va2>va1. neither value can be negative.
% dv  ... width of the taper on the edge of the rejection fan in velocity units
% REQUIREMENT: 0<dv<va1<=va2.  Setting va1=va2 gives a very narrow reject
% region. Better rejection of a specific velocity, vn, follows from making
% va1 slightly less than vn and va2 slightly greater.
%
% tpad ... size (in t units) of temporal zero pad to be afixed to seis in the first dimension
% ********* default = 0.1*(max(t)-min(t)) **********
% xpad ... size (in x units) of spatial zero pad to be afixed to seis in the second dimension.
% ********* default = 0.1*(max(x)-min(x))***********
% ypad ... size (in y units) of spatial zero pad to be afixed to seis in the third dimension.
% ********* default = 0.1*(max(x)-min(x))***********
% fmask ... vector of frequencies at which the filter mask is to be output
% ********* default = [] (no mask output) **********
%
% NOTE: The values supplied for xpad, ypad and tpad are minimal pads because, after afixing these pads,
% the matrix is further extended to the next power of 2 in all dimensions. The purpose of this pad
% is to minimize wraparound of the filter impulse response.
%
% seisf ... the f-k filtered result with all pads removed. It will be the same size as seis.
% masks ...a cell array of length fmask of filter multipliers. Each cell contains a 2-D mask with 
%       kx as the row coordinate and ky as the column coordinate.
% kx ... x wavenumber coordinate for mask
% ky ... y wavenumber coordinate for mask
% 
% The mask can be displayed by: seisplot(mask{ifreq},kx,ky) where ifreq is an integer corresponding
% to one of the input values of fmask.
% 
% G.F. Margrave, Margrave-Geo, 2019
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

if(nargin<12)
    debug=0;
end
if(nargin<11)
    fmask=[];
end
if(nargin<8)
    tpad=0.1*(max(t)-min(t));
end
if(nargin<10)
    ypad=0.1*(max(y)-min(y));
end
if(nargin<9)
    xpad=0.1*(max(x)-min(x));
end

[nt,nx,ny]=size(seis);
if(length(t)~=nt)
    error('seis and t have incompatible sizes')
end
if(length(x)~=nx)
    error('seis and x have incompatible sizes')
end
if(length(y)~=ny)
    error('seis and y have incompatible sizes')
end
if(dv<=0 || vmin<0 || vmax<=0)
    error('dv, va1,va2 must not be negative')
end
if(vmin>vmax)
    error('va1 must be less than va2')
end
dx=abs(x(2)-x(1));
dy=abs(y(2)-y(1));
dt=t(2)-t(1);
small=.01*dx;
if(sum(abs(diff(diff(x)))/length(x))>small)
    error('x coordinates must be regularly spaced')
end
small=.01*dy;
if(sum(abs(diff(diff(y)))/length(y))>small)
    error('y coordinates must be regularly spaced')
end
small=.00001*dt;
if(sum(abs(diff(diff(t))))>small)
    error('t coordinates must be regularly spaced')
end

%attach t pad
% nt2=nt;
if(tpad>0)
    ntpad=round(tpad/dt);
    nt2=nt+ntpad;
    nt2=2^(nextpow2(nt2));
    ntpad=nt2-nt;
    t2=(0:nt2-1)*dt;
    seis=[seis;zeros(ntpad,nx,ny)];
end

%f transform
if(debug)
    t0=clock;
    disp('Beginning forward transform');
end
%t->f transform
[specfxy,f]=fftrl(seis,t2);
clear seis
if(debug)
    tnow=clock;
    timeused=etime(tnow,t0);
    disp(['forward transform complete in ' int2str(timeused) ' seconds'])
end
df=f(2);
%determine pads and wavenumber coordinates
nxpad=round(xpad/dx);
nx2=2^nextpow2(nx+nxpad);
nypad=round(ypad/dy);
ny2=2^nextpow2(ny+nypad);
kx=freqfft(x,nx2,1);
ky=freqfft(y,ny2,1);
%need radial wavenumber as a 2D array
kx=kx(:);
ky=ky(:)';
nkx=length(kx);
nky=length(ky);
kkx=kx(:,ones(1,nky));%matrix of kx
kky=ky(ones(nkx,1),:);%matrix of ky
kr=sqrt(kkx.^2+kky.^2);%radial wavenumber
% nf=length(f)-1;

%express the filter reject regions in slowness
if(vmin==0)
    vmin=(.00001*vmax);
end
sa1=1/vmin;
sa2=1/vmax;
sa1p=max([inf,1/(vmin-dv)]);
sa2p=1/(vmax+dv);
% If sr is radial slowness on a constant f plane, then filter is all-pass for
% s2<sa2p, is all reject for sa2<sr<sa1, and tapers from all-pass to all
% reject for sa2p<sr<sa2 and tapers from all-reject to all-pass for
% sa1<sr<sa1p.
%


ifmask=round(fmask/df)+1;
nfmask=1;
masks=cell(size(ifmask));

for k=2:length(f)%skip 0 hz
    %wavnumber transform on the frequency slice
    slice=zeros(nx2,ny2,'single');%padded out array of zeros
    tmp=squeeze(specfxy(k,:,:));
    izero=tmp==0;%remember where the hard zeros are
    slice(1:nx,1:ny)=tmp;%copy into the padded array
    tmp = ifft2(slice);%2D transform and leave wrapped
    %                     if(k==kstop)
    %                         disp('here');
    %                         kstop =2*kstop;
    %                     end
    
    mask=ones(nkx,nky);%initialize filter mask
    sr=kr/f(k);%radial slowness at all points on the grid
    ind1=find(sr>sa2p);%find all radial slowness greater than sa2p (outer boundary of reject)
    ind2=find(sr(ind1)<=sa2);%find those of ind1 that are less than sa2 (full reject bdy)
    %                     ind1=sr>sa2p;%find all radial slowness greater than sa2p (outer boundary of reject)
    %                     ind2=sr(ind1)<=sa2;%find those of ind1 that are less than sa2 (full reject bdy)
    mask(ind1(ind2))=.5+.5*cos((sr(ind1(ind2))-sa2p)*pi/(sa2-sa2p));%first taper
    ind1=find(sr>sa2);%everything slower than sa2
    ind2= sr(ind1)<=sa1;%everything slower than sa2 and faster than sa1
    mask(ind1(ind2))=0;%reject anulus between sa1 and sa2
    ind1=find(sr>sa1);%everything slower than sa1
    ind2=find(sr(ind1)<=sa1p);%%slower than sa1 but faster than sa1p
    mask(ind1(ind2))=.5+.5*cos((sr(ind1(ind2))-sa1p)*pi/(sa1-sa1p));%second taper
    %apply the mask and inverse transform
    tmp2=fft2(mask.*tmp);
    %remove spatial pad and re-zero
    tmp=tmp2(1:nx,1:ny);
    tmp(izero)=0;
    specfxy(k,:,:)=shiftdim(tmp,-1);%put the result back in the array
    if(~isempty(fmask))
        if(nfmask<=length(fmask))
            if(k==ifmask(nfmask))
                %the transpose is here because we want kx to be the column coordinate. However, the
                %squeeze command eliminates the first dimension (f) and promotes kx to dimension 1
                %and ky to dimension 2. This makes kx the row coordinate so we transpose.
                masks{nfmask}=mask';
                nfmask=nfmask+1;
            end
        end
    end
end

if(debug)
    tnow2=clock;
    timeused=etime(tnow2,tnow);
    disp(['Filter applied in ' int2str(timeused) ' seconds'])
    %inverse transform
    disp('Beginning inverse transform');
end
seisf=ifftrl(specfxy,f);
if(nt<size(seisf,1))
    nt2=size(seisf,1);
    seisf(nt+1:nt2,:,:)=[];%remove temporal pad
end
if(debug)
    tnow3=clock;
    timeused=etime(tnow3,tnow2);
    disp(['Inverse transform completed in ' int2str(timeused) ' seconds'])
    timeused=etime(tnow3,t0);
    disp(['3D fan filter total time ' int2str(timeused) ' seconds'])
end
 
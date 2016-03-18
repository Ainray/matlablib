function  g=wienerfilter(x,y,n,noise)
if nargin<5
    noise=0.001;
end
Nx=length(x);
Ny=length(y);
if (Ny<Nx)
    error('Output must be longer than input');
end
rxx=xcorr(x,x);
r=rxx(Nx:Nx+n-1);

rxy=xcorr(y,x);
% [mr,ir]=max(abs(rxy)); %#ok<ASGLU> % x and y maybe some delay and phase opposite
b=rxy(Ny:Ny+n-1);
b=b/r(1);r=r/r(1); 
r(1)=r(1)+noise;
g=levidurb(r,b);

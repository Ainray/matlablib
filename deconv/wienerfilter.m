function  g=wienerfilter(x,y,n,noise)
% author: Ainray
% date: 20160324
% bug-report: wwzhang0421@163.com
% introduction: wiener fitlering deconvolution
%   input: x, the input 
%          y, the observed data, also the desired output here
%          n, the length of impulse reponse
% 	   noise, regulation factor for stationarity

if nargin<5
    noise=0.001;
end
Nx=length(x);
Ny=length(y);
if (Ny<Nx)
    error('Output must be longer than input');
end
%correlation
[r,b]=accorr(x,y,n);
r(1)=r(1)+noise;
g=levidurb(r,b);
 
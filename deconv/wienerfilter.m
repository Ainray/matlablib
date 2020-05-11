function  [g,e]=wienerfilter(x,y,n,prenoise)
% author: Ainray
% date: 20160324, 20170608
% bug-report: wwzhang0421@163.com
% introduction: wiener fitlering deconvolution
%   input: x, the input 
%          y, the observed data, also the desired output here
%          n, the length of impulse reponse
% 	prenoise, regulation factor for stationarity
x=v2col(x);y=v2col(y);
if nargin<4
    prenoise=0;
end
Nx=length(x);
Ny=length(y);
if (Ny<Nx)
    error('Output must be longer than input');
end
%correlation
[r,b]=accorr(x,y,1,n);
% [r,b,rxx,rxy]=accorr(x,y,n); % correlation
% Ny=length(y);
% [r1,b1]=accorr(rxx(Ny-n+1:end)/rxx(Ny),rxy(Ny-n+1:end)/rxx(Ny),n);
% b2=synresp(rxx(Ny-Ng+1:end),g);b2=b2(Ng:end);  % convolution
g=levidurb(r,b,n,prenoise);
e=1-g'*b(1:n)/(y'*y);
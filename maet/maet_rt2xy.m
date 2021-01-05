function [x,y] = maet_rt2xy(r, theta,x0, y0)
% function maet_rt2xy(r, theta,x0, y0)
% author: ainray
% date: 20200821
% email: wwzhang0421@163.com
% modified: 20200821, create, current only for constant velocity
%
% introducton: convert local polar coordinate to Cartesian lab coordiante.
% input: 
%         r, local polar axis coordinate, in columns
%     theta, local polar angle coordinate, vector, has same dimension as column number of r 
%        x0, optional, rotation center x coordinate, in lab coordinate
%        y0, optional, rotation center y coordinate, in lab coordinate

if(size(r,1) == 1)
    r = r(:);
end
n = size(r,2);
if(n~=1 && n ~= length(theta) )
    error('wrong dimension of theta: theta must has same dimension as column number of r');
end

if(nargin <= 2)
    x0=0;
    y0=0;
end
if(n ~= length(x0)  && length(x0) ~=1 )
    error('wrong dimension of x0: x0 must has same dimension as column number of r, or scalar');
end
if(n ~= length(y0) && length(y0) ~=1 )
    error('wrong dimension of y0: y0 must has same dimension as column number of r, or scalar');
end

x = zeros(size(r));
y = zeros(size(r));
if(length(x0) == 1)
    x0 = x0*ones(size(theta));
end
if(length(y0) == 1)
    y0 = y0*ones(size(theta));
end
if(n==1)
    for i=1:length(theta)
        x(:,i)= x0(i) + r*cos(theta(i)/180*pi);
        y(:,i)= y0(i) + r*sin(theta(i)/180*pi);
    end
else
    for i=1:n
        x(:,i)= x0(i) + r(:,i)*cos(theta(i)/180*pi);
        y(:,i)= y0(i) + r(:,i)*sin(theta(i)/180*pi);
    end
end
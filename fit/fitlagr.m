function [y,b]=fitlagr(xp,yp,x)
% function y=fitlagr(x,xp,yp)
% author: inray
% date:20170719
% email: wwzhang0421@163.com
% introduction: lagrange approximation of degree length(xp)

% create lagrange basis
Ni=length(xp); % degree
Nd=length(x);  % number of data points to be evaluated
for i=1:Ni
    for j=1:Nd


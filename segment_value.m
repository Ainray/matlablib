function y = segment_value(x,segx,segy)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: piecewise function with values in segy, and segment thredhold values in
%               segx, defined domain is in x.
%               Used by MAT library, such as multi-layer homogenous
%               velocity model.
ns = numel(segx);
y = ones(size(x))*segy(ns);
if( ~ isempty(find(x>segx(ns), 1)))
    error('invalid segment coverage');
end
for i=ns-1:-1:1
    y( x<segx(i)) = segy(i);
end
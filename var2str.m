% function s=var2str(varargin)
% author: Ainray
% date: 2015/12/17
% bug-report: wwzhang0421@163.com
% introduction: return the name of the specified variable
%      input:   the name of one variable within workspace
%     output:   the name string of specified variable
function s=var2str(varargin)
if numel(varargin)~=1
    error('Input parameter must only one variable.\n');
else
    s=inputname(1); 
end

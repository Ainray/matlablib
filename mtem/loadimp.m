function imp=loadimp(fname)
% function loadimp(fname)
% author: Ainray
% date: 20170619
% bug-report:wwzhang0421@163.com
% introduction: load EIRs data saved by calling saveimp
%     Syntax:
%            imp=loadimp(fname);   % saved in the current path, with specified ng method
%     Note: it only load the first matched data, so it will load wrong
%           data, if your fname have more than two varibles with name like
%           'impmeta*' and you want load the second one.
% See also saveimp
imp=[];
eval(['load ',fname,' -regexp  ''^(impmeta)\w*'''])
%match the variable
vars=who; 
impvari=strfindindx(vars,'^(impmeta)\w*');
if ~isempty(impvari) % find valid variable
    eval(['impt=',vars{impvari},';']);
    imp=impt.data;
end

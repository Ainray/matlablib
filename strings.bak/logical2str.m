function str=logical2str(lv)
% author: Ainray
% date :20160321
% bug-report: wwzhang0421@163.com
% information: convert logical value into string 'true' or 'false'
%      syntax: str=logical2str(true)
%
%   reference: logical2cellstr
%              
%  See also logical2cellstr, cellstr2logical, str2logical

tmp=logical2cellstr(lv);
str=tmp{1};
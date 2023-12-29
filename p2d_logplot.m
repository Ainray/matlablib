function [pl, dn] = p2d_logplot(x, y, clr, name, varargin)
% author: Ainray
% date: 20220817
% bug-report: wwzhang0421@163.com
% introduction: export cmap for Surfer
% modify:

idx = find(diff(sign(y)) ~= 0) + 1;
narg = numel(varargin);
para = [];
pl = [];
dn = [];
for i=1:narg
    arg = varargin{i};
    if isnumeric(arg)
        sarg = num2str(arg);
    else
        sarg = ['''',arg,''''];
    end
    if i>1
        para = [para, ',',sarg];
    else
        para = sarg;
    end
end
if(~isempty(idx))
    styles ={clr; [clr, '--']};
    dn0 = {[name, ' positive'],[name, ' negtive']};
    offset = 0;
    if(y(1) > 0)
         offset = 1;          
    end
    n = length(idx) + 1;
    idx = [0; idx; length(y)];    
    for i=1:n
        ii = mod(i+offset,2) + 1;
        if i < 3
            eval(['pl0 = loglog(x(idx(i)+1:idx(i+1)), abs(y(idx(i)+1:idx(i+1))),''', styles{ii}, ''', ''DisplayName'',''', dn0{ii}, ''',', para,');']);
            dn = [dn dn0(ii)];
            pl = [pl pl0];
        else
            eval(['loglog(x(idx(i)+1:idx(i+1)), abs(y(idx(i)+1:idx(i+1))),''', styles{ii} ,''',', para,');']);
        end
        hold on;
    end 
else
     if(y(1) > 0)
         style = clr;
         dn = {[name, ' positive']};
     else
         style = [clr, '--'];
         dn = {[name, ' negtive']};
     end
     eval(['pl = loglog(x, abs(y),''', style, ''', ''DisplayName'',''', dn{1}, ''',', para,');']);
     hold on;
end
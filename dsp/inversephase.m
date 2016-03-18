% function invg=inversephase(g)
% author: Ainray
% time  : 2015/11/23
% bug report: wwzhang0421@163.com
% information: Inversing the phase of impulse, i.e., obtain the value of
%               ngetive of input: -g, but only when it is necessary
% input:
%       g,   the input
%  output:
%   invg,   When the value, whose absoulte value is  maximum, of input is 
%           positive, then invg is the same as input; and when the maximum
%           whose absoulte value is  maximum,of input is negtive, then 
%           invg=-g.
function invg=inversephase(g)
%     [mms,fmax]=peak(g);
%     if (fmax>2 && g(mms(fmax-1))<0)  || (fmax<2) && g(mms(fmax))<0 
        
if (g(abs(g)==max(abs(g)))<0)
       invg=-1.0*g;
    else
        invg=g;
    end
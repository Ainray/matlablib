function g=inversephase(g)
% author: Ainray
% time  : 2015/11/23, 20160320
% version: 1.2
% bug report: wwzhang0421@163.com
% information: Inversing the phase of impulse, i.e., obtain the value of
%               ngetive of input: -g, but only when it is necessary
%
% input:
%       g,   the input
%  output:
%       g,   the output with correct phase

% 20160320, determine the phase by the area between the signal with
%           x axis, i.e., the sum of samples dividing by time interval
%           that is equal to the sum.
   N=size(g,2);
   for i=1:N
       h=g(:,i);
        if(sum(h(1:min(2000,length(h))))<0)
            g(:,i)=-1.0*g(:,i);
        end
   end


%----------------------------------------------version 1.1-----------------
% input:
%       g,   the input
%  output:
%      g,   When the value, whose absoulte value is  maximum, of input is 
%           positive, then invg is the same as input; and when the maximum
%           whose absoulte value is  maximum,of input is negtive, then 
%           invg=-g.
% function g=inversephase(g)
%     [mms,fmax]=peak(g);
%     if (fmax>2 && g(mms(fmax-1))<0)  || (fmax<2) && g(mms(fmax))<0 
%     gtmp=g(1:end-2000,:);
%     if (g(abs(gtmp)==max(abs(gtmp)))<0)
%        invg=-1.0*g;
%     else
%         invg=g;
%     end

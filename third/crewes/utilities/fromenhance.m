function val=fromenhance(hfig)
% Used by various tools to check if a given window is part of the Enhance system. The key signal is
% that the figure 'tag' must be the string 'fromenhance'
if(nargin<1)
    hfig=gcf;
end
val=false;
if(strcmp(get(hfig,'tag'),'fromenhance'))
    val=true;
end
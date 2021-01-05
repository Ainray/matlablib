function disableDA(hfig)
%
% disable Matlab's default activity that appears in 2019a
%

haxes=findobj(hfig,'Type','axes');
for k=1:length(haxes)
    disableDefaultInteractivity(haxes(k));
end
%example usage
% fname='thesis_ch22_p_1';res='-r600';type='-depsc';
% heigth=3;
% width=6;
% matquafig_save;

% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% save
% print_fig(fname,type,res);
cmyk='-cmyk';res='-r600';type='-depsc';
print(fname,type,cmyk,res);
type='-dpdf';
print(fname,type,cmyk,res);
% eps 2 png
fid=fopen(['eps2png_',fname,'.bat'],'w');
fprintf(fid,'%s\n',['del ',fname,'.png']);
fprintf(fid,['gswin32c -o -q -sDEVICE=png256 -dEPSCrop ',res,' -o',fname,'.png ',fname,'.eps']);
fclose(fid);
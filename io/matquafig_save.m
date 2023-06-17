% author: Ainray
% email: wwzhang0421@163.com
% date: 20220211
function matquafig_save(fname, width, height, res)
if nargin<2 || isempty(width)
    width = 3;
end
if nargin<3 || isempty(height)
    height = 3;
end
if nargin<4 || isempty(res)
    res = '-r600';
end

% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);


% save
savefig(fname);
% issues 318, refer to https://github.com/altmany/export_fig/issues/318
set(gcf, 'visible', 'off')
export_fig(fname, '-png', '-pdf', '-eps', res);
set(gcf, 'visible', 'on')

% eps 2 png
fid=fopen(['eps2png_',fname,'.bat'],'w');
fprintf(fid,'%s\n',['del ',fname,'.png']);
% fprintf(fid,['gswin32c -o -q -sDEVICE=png256 -dEPSCrop ',res,' -o',fname,'.png ',fname,'.eps']);
fprintf(fid,['gswin64c -o -q -sDEVICE=png256 -dEPSCrop ',res,' -o',fname,'.png ',fname,'.eps']);
fclose(fid);

% old version
% %example usage
% % fname='thesis_ch22_p_1';res='-r600';type='-depsc';
% % heigth=3;
% % width=6;
% % matquafig_save;
% if nargin<2 || isempty(width)
%     width = 3;
% end
% if nargin<3 || isempty(height)
%     height = 3;
% end
% if nargin<4 || isempty(res)
%     res = '-r600';
% end
% 
% if nargin<5 || isempty(type)
%     type = 'eps';
% end
% 
% % Here we preserve the size of the image when we save it.
% set(gcf,'InvertHardcopy','on');
% set(gcf,'PaperUnits', 'inches');
% papersize = get(gcf, 'PaperSize');
% left = (papersize(1)- width)/2;
% bottom = (papersize(2)- height)/2;
% myfiguresize = [left, bottom, width, height];
% set(gcf,'PaperPosition', myfiguresize);
% % save
% % print_fig(fname,type,res);
% export_fig([fname,'.',type],res);
% % cmyk='rgb'; %res='-r600';type='-depsc';
% % print(fname,type,cmyk,res);
% type='pdf';
% % print(fname,type,cmyk,res);
% export_fig(fname,type,res);
% type='png';
% export_fig(fname,type,res);
% % type='-dpdf';
% % print(fname,type,res);
% % eps 2 png
% fid=fopen(['eps2png_',fname,'.bat'],'w');
% fprintf(fid,'%s\n',['del ',fname,'.png']);
% fprintf(fid,['gswin32c -o -q -sDEVICE=png256 -dEPSCrop ',res,' -o',fname,'.png ',fname,'.eps']);
% fclose(fid);
%function print_fig(fname,fig_type,fig_res)
% author: Ainray
% date: 2016/01/03
% bug report: wwzhang0421@163.com
% introduciton: Interface to export figures with high resolution, simutaneously 
%               saving '*.fig' file. 
% syntax: print_fig('mypicture','-jpg','-m3');
%   input:
%      fname, file name of exported image file.
%   fig_type, image format to be exported: '-jpg', '-eps', and so on.
%    fig_res, a parameter determing the resolution of exported image.
%             on 32-bit, '-m2' is recommended, on 64-bit with memory 
%             more than 4GB, '-m3' can export images with higth resolution.
%
%    (For more detailed information or more customed control about images, 
%     type 'help export_fig' within the command window.)
%  output:
%          (none)
function print_fig(fname,fig_type,fig_res)
set(gcf,'Color','w');
saveas(gcf,fname,'fig');
export_fig(fname,fig_type,fig_res);
disp([fname,' succeed to be printed.']);
% close ;
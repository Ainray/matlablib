%function print_fig(fname,fig_type,fig_res,handle,figyn,quiet) 
% author: Ainray
% date: 2016/01/03
% bug report: wwzhang0421@163.com
% introduciton: Interface to export figures with high resolution, simutaneously 
%               saving '*.fig' file. 
% syntax: print_fig('mypicture','-jpg','-m3','y');
%   input:
%      fname, file name of exported image file.
%   fig_type, image format to be exported: '-jpg', '-eps', and so on.
%    fig_res, a parameter determing the resolution of exported image.
%             on 32-bit, '-m2' is recommended, on 64-bit with memory 
%             more than 4GB, '-m3' can export images with higth resolution.
%
%     handle, the handle of figure/axis, added by Ainray on 20160328
%     figyn, whether save *.fig files or not, the default is not.
%            modified on 20160220
%     quiet, no prompt
%
%    (For more detailed information or more customed control about images, 
%     type 'help export_fig' within the command window.)
%  output:
%          (none)
function print_fig(fname,fig_type,fig_res,handle,figyn,quiet) %add figyn parameter
% function print_fig(fname,fig_type,fig_res)
% --------modified on 20160328----------
if nargin<4
    handle=gcf;
end

% --------modified on 20160220----------
if nargin<5
    figyn='n';
end
if nargin<6
    quiet=false;
end
while figyn~='y' && figyn~='n'
    figyn=input('Please enter ''''y'''' or ''''n''''indicating whether save *.fig file or not');
end  
%---------------------------------------
set(gcf,'Color','w');
%--------------- modfieid on 20160220-----------
% saveas(gcf,fname,'fig');
if figyn=='y'
    saveas(gcf,fname,'fig');
end
%------------------------------------------------
export_fig(fname,fig_type,fig_res,handle);
if ~quiet
    disp([fname,' succeed to be printed.']);
end
% close ;
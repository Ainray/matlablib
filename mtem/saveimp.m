function [fname]=saveimp(imp,fname)
% author: Ainray
% date: 20160328
% bug-report:wwzhang0421@163.com
% introduction: save EIRs by naming it with current time
%               for sake of overwritting variable
%     Syntax:
%            fname=saveimp(imp);   % saved in the current path, with time nameing method
%            saveimp(imp,fname);   % save imp as specified path and filename
% See also loadimp
    datetmp=fix(clock);  % current time
    datestr=[num2str(datetmp(1),4),num2str(datetmp(2),'%02d'),num2str(datetmp(3),'%02d')...
         num2str(fix(hour(now)),'%02d'), num2str(fix(minute(now)),'%02d')...
         ,num2str(fix(second(now)),'%02d')];
     if nargin<2
        fname=[datestr,'-imp.mat'];
     end
    vname=['impmeta',datestr,];
    tmp.fname=fname;
    tmp.time=datetmp;
    tmp.data=indximp(imp,0,'Mode','Mark');
    eval([vname,'=tmp;']);
    save(fname, vname,'-v7.3');  %save
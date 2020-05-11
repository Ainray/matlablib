function sfname=indxfname(fname,type,val)
% function sfname=indxfname(fname,type,val)
% syntax:
%       sfname=indxfname(fname,1,[1301,1302]);     (array version)
%       sfname=indxfname(fname,1,{1301,1302});     (cell version)
%       sfname=indxfname(fname,1,{'1301','1302'}); (string version)
%       sfname=indxfname(fname,1,{1301,'1302'});   (mixed version)
%
%       sfname=indxfname(fname,2,[101,102,103,104]);
%       sfname=indxfname(fname,2,{101,102,103,104});
%       sfname=indxfname(fname,2,{'101','102','103','104'});
%
%       sfname=indxfname(fname,3,32);
%       sfname=indxfname(fname,3,{32});
%       sfname=indxfname(fname,3,'32');  
%
%       sfname=indxfname(fname,4,{[1301,1302],[101,102,103,104],32});
%       sfname=indxfname(fname,4,{{1301,1302},[101,102,103,104],32});
%       sfname=indxfname(fname,4,{{1301,1302},{'101','102',103,104],32});
%       sfname=indxfname(fname,4,{[1301,1302],[101,102,103,104],{'32','512'}});
%
%       sfname=indxfname(fname,-1,1300+[1:50]);
%       sfname=indxfname(fname,-1,{1301,1302});
%       sfname=indxfname(fname,-1,{'1301',1302});
%
%       sfname=indxfname(fname,-2,101:7260);
%       sfname=indxfname(fname,-3,[32, 1024,4096]);
%       sfname=indxfname(fname,-4,{1300+[1:50],101:7260,[32, 1024,4096]});
%       sfname=indxfname(fname,-4,{1300+[1:50],101:7260,{32, 1024,'4096'}});
%       ...
%
%  input:
%        fname, cell of data file list
%         type, screen type 
%               1, sn
%               2, rn
%               3, fre
%               4, all
%               -1, multiple match for sn
%               -2, multiple match for rn
%               -3, multiple match for fre
%               -4, multiple match for all
%         val, cell of index array ( {sn}/{rn}/{fre}/[{sn},{rn},{fre}])
%  output:
%      sfname, subset of fname
%                
%              [sn]        for type 1
%              [rn]        for type 2
%              [fre]=      for type 3
%           sn, array of serial number of receivers
%           rn, array of record number
%          fre, array of frequences
sfname=cell(0);
switch type
    case 4
        %'C\w*ST\w*_ch\w*'); 
        for i=1:numel(val{1})
            for j=1:numel(val{2})
                for k=1:numel(val{3})                  
                    pat=strcat('C',string(val{2}(j)),'ST',...
                        string(val{1}(i)), '\w*',string(val{3}(k)));
                    indx=strfindindx(fname,pat);
                    tmp=fname(indx);
                    sfname=[sfname;tmp];
                end
            end
        end
%         lia=ismember(srf(:,1),val(1));
%         sfname=fname(lia==1);
%         ssrf=srf(lia==1,:);
%         
%         lia=ismember(ssrf(:,2),val(2));
%         sfname=sfname(lia==1);
%         ssrf=ssrf(lia==1,:);
%         
%         lia=ismember(ssrf(:,3),val(3));
%         sfname=sfname(lia==0);
%         ssrf=ssrf(lia==1);
    case 1
%           lia=ismember(srf(:,1),val(1));
%           sfname=fname(lia==1);
%           ssrf=srf(lia==1);        
        for k=1:numel(val)
            pat=strcat('C\w*ST',string(val(k)));
            indx=strfindindx(fname,pat);
            tmp=fname(indx);
            sfname=[sfname;tmp];
        end
    case 2
        for k=1:numel(val)        
            pat=strcat('C',string(val(k)),'ST');
            indx=strfindindx(fname,pat);
            tmp=fname(indx);
            sfname=[sfname;tmp];
        end
    case 3
        for k=1:numel(val)        
            pat=strcat('C\w*ST\w*_',string(val(k)));
            indx=strfindindx(fname,pat);
            tmp=fname(indx);
            sfname=[sfname;tmp];
        end
    case -1  % multiple 
           srf=fname2srfn(fname,1);
%            if isnumeric(val)
%                val=(strsplit(strjoin(val,'|'),'|'))';
%            end
           lia=ismember(srf,string(val));
           sfname=fname(lia==1);        
    case -2
           srf=fname2srfn(fname,2);          
           lia=ismember(srf,string(val));
           sfname=fname(lia==1);  
    case -3
           srf=fname2srfn(fname,3);
           lia=ismember(srf,string(val));
           sfname=fname(lia==1);  
    case -4
           srf=fname2srfn(fname,0);
           lia=ismember(srf(:,1),string(val{1}));
           sfname=fname(lia==1);
           ssrf=srf(lia==1,:);
                 
           lia=ismember(ssrf(:,2),string(val{2}));
           sfname=sfname(lia==1);
           ssrf=ssrf(lia==1,:);
           
           lia=ismember(ssrf(:,3),string(val{3}));   
           sfname=sfname(lia==0);         
    otherwise
end

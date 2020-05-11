function ssrp=datascreen(srp,type,val)
% function ssrp=datascreen(srp, type,val)
% syntax:
%       ssrp=datascreen(srp, 1,[1301,1302]);     (array version)
%       ssrp=datascreen(srp, 1,{1301,1302});     (cell version)
%       ssrp=datascreen(srp, 1,{'1301','1302'}); (string version)
%       ssrp=datascreen(srp, 1,{1301,'1302'});   (mixed version)
%
%       ssrp=datascreen(srp, 2,[101,102,103,100]);
%       ssrp=datascreen(srp, 2,{101,102,103,100});
%       ssrp=datascreen(srp, 2,{'101','102','103','100'});
%
%       ssrp=datascreen(srp, 3,32);
%       ssrp=datascreen(srp, 3,{32});
%       ssrp=datascreen(srp, 3,'32');  
%
%       ssrp=datascreen(srp, 0,{[1301,1302],[101,102,103,100],32});
%       ssrp=datascreen(srp, 0,{{1301,1302},[101,102,103,100],32});
%       ssrp=datascreen(srp, 0,{{1301,1302},{'101','102',103,100],32});
%       ssrp=datascreen(srp, 0,{[1301,1302],[101,102,103,100],{'32','512'}});
%       ...
%
%  input:
%        fname, cell of data file list
%         type, screen type 
%               1, sn
%               2, rn
%               3, fre
%               0, all
%         val, cell of index array ( {sn}/{rn}/{fre}/[{sn},{rn},{fre}])
%  output:
%      ssrp, subset of fname
%                
%              [sn]        for type 1
%              [rn]        for type 2
%              [fre]=      for type 3
%           sn, array of serial number of receivers
%           rn, array of record number
%          fre, array of frequences
ssrp=cell(0);
switch type
    case 0
        %'C\w*ST\w*_ch\w*'); 
%         for i=1:numel(val{1})
%             for j=1:numel(val{2})
%                 for k=1:numel(val{3})                  
%                     pat=strcat('C',string(val{2}(j)),'ST',...
%                         string(val{1}(i)), '\w*',string(val{3}(k)));
%                     indx=strfindindx(pat);
%                     tmp=fname(indx);
%                     ssrp=[ssrp;tmp];
%                 end
%             end
%         end
        lia=ismember(srp(:,7),string(val{1}));
        ssrp=srp(lia==1,:);
        
        lia=ismember(ssrp(:,1),string(val{2}));
        ssrp=ssrp(lia==1,:);

        lia=ismember(ssrp(:,8),string(val{3}));
        ssrp=ssrp(lia==1,:);
    case 1
          lia=ismember(srp(:,7),string(val));
          ssrp=srp(lia==1,:);        
%         for k=1:numel(val)
%             pat=strcat('C\w*ST',string(val(k)));
%             indx=strfindindx(pat);
%             tmp=fname(indx);
%             ssrp=[ssrp;tmp];
%         end
    case 2
          lia=ismember(srp(:,1),string(val));
          ssrp=srp(lia==1,:);  
%         for k=1:numel(val)        
%             pat=strcat('C',string(val(k)),'ST');
%             indx=strfindindx(pat);
%             tmp=fname(indx);
%             ssrp=[ssrp;tmp];
%         end
    case 3
          lia=ismember(srp(:,8),string(val));
          ssrp=srp(lia==1,:);  
%         for k=1:numel(val)        
%             pat=strcat('C\w*ST\w*_',string(val(k)));
%             indx=strfindindx(pat);
%             tmp=fname(indx);
%             ssrp=[ssrp;tmp];
%         end
%     case -1  % multiple 
%            srf=fname2srfn(1);
% %            if isnumeric(val)
% %                val=(strsplit(strjoin(val,'|'),'|'))';
% %            end
%            lia=ismember(srf,string(val));
%            ssrp=fname(lia==1,:);        
%     case -2
%            srf=fname2srfn(2);          
%            lia=ismember(srf,string(val));
%            ssrp=fname(lia==1,:);  
%     case -3
%            srf=fname2srfn(3);
%            lia=ismember(srf,string(val));
%            ssrp=fname(lia==1,:);  
%     case -0
%            srf=fname2srfn(0);
%            lia=ismember(srf(:,1),string(val{1}));
%            ssrp=fname(lia==1,:);
%            ssrp=srf(lia==1,:);
%                  
%            lia=ismember(ssrp(:,2),string(val{2}));
%            ssrp=ssrp(lia==1,:);
%            ssrp=ssrp(lia==1,:);
%            
%            lia=ismember(ssrp(:,3),string(val{3}));   
%            ssrp=ssrp(lia==0);         
    otherwise
end

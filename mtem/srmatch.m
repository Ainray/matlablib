% function srt=srmatch(fname,srcsn,srcch)
% author:Ainray
% date: 20160312 20161203, fix a bug when read receiver informations
%       20170615, acceleration
% bug-report: wwzhang0421@163.com
% information: match source-receiver pair according to file name list
%              with full path.
%  syntax: srt=srmatch(fname,1351,0);
%     input:
%          fname, full file name list, cell string array
%               srcsn, the source acquisition meter serial number
%               srcch, the channel of source acquisition meter: 0,2
%                      any other value mean theorical waveform
%   output:
%                 srt, the source-receiver pair table N*8 cell
%                      -----------------------------------------------------------------------------
%                           col.1           col.2               col.3               col. 4                
%                       record number   source file name    receiver file name     short source name     
%                      -----------------------------------------------------------------------------
%                      -----------------------------------------------------------------------------
%                           col.5           col.6               col.7               col. 8                
%                       short rcv number   logical flags    receiver serical number   frequencies     
%                      -----------------------------------------------------------------------------
function srt=srmatch(fname,srcsn,srcch)   
srt=cell(0);
if srcch==0 ||srcch==2 || srcch==1
    srcsn=num2str(srcsn);
    srcch=['0',num2str(srcch)];	
    % find sources data with 'ch' channel
	
    % find all sources data
    indxs0=strfindindx(fname,['ST',srcsn,'_ch']); 
    if isempty(indxs0) % no valid data
        return;
    end
    % seperate source and receiver data
    srcfname=fname(indxs0);
    rcvfname=deselect(fname,indxs0);
    
    % excluding source data with channel no. ~= ch
    indxs=strfindindx(srcfname,['ST',srcsn,'_ch',srcch]); 
    srcfname=srcfname(indxs);
    
    % get record numbers
    [srfs,indx]=sort_nat(fname2srfn(srcfname,2));
    srcfname=srcfname(indx);
    srfr=fname2srfn(rcvfname,0);
    
    % sort receiver
    [lia,lib]=ismember(srfr(:,2),srfs); 
    [~,indx]=sort(lib);       
    srfr=srfr(indx,:);
    lia=lia(indx);              
    rcvfname=rcvfname(indx);
    %exclude rcvs has no corresponding sources
    srfr=srfr(lia~=0,:);       
    rcvfname=rcvfname(lia~=0);
    
    % get histgram of rcv numbers per src 
    [h,s1,s2]=histgi(lib); 
    % exclude src has no rcvs 
%     srfs=srfs(max(s1,1):s2);  
%     srfs=srfs(h~=0);
    srcfname=srcfname(max(s1,1):s2);
    if s1==0
        h=h(2:end);
    end
    srcfname=srcfname(h~=0); 
    h=h(h~=0);
 

%     srfs=v2col(rude(h,srfs));
    ssrcfname=partsfile(srcfname);
    srcfname=v2col(rude(h,srcfname));
    ssrcfname=v2col(rude(h,ssrcfname));
    srt=srfr(:,2);      %  record number
    srt(:,2)=srcfname;  %  source name
    srt(:,3)=rcvfname;  %  rcvfname
    srt(:,4)=ssrcfname;  %  short source name
    srt(:,5)=srfr(:,4); %  short receiver name
    srt(:,6)=repmat({false},size(srfr,1),1); % logical flags
    srt(:,7)=srfr(:,1);  % meter sn
    srt(:,8)=srfr(:,3);  % meter fre   
end   
    
% 	% match source-receiver pair
% 	cc=1;
% 	for i=1:ns
% 		% shot num
%         r=regexpi(srcfname{i},['C\w*ST',srcsn,'_ch\w*.dat']);
% 		recnum=srcfname{i}(r+1:strfind(srcfname{i},['ST',srcsn,'_ch'])-1);		
% 		% match receiver
% 		indxr=strfindindx(rcvfname,['C',recnum,'ST']);      
% 		nrps=length(indxr);  % number of receiver per source
% 		if nrps>0  % matched
% 			ccf=cc+nrps-1;
% 			srt(cc:ccf,1)=repmat({recnum},nrps,1);  % record num:1
% 			srt(cc:ccf,6)=repmat(srcfname(i),nrps,1); % source file name:6
%             head=readhead(srcfname{i});
%             srt(cc:ccf,8)=repmat({head.chinfo(1).sndpnum},nrps,1);  %source position:8
%             [~,fname]=partsfile(srcfname(i));
%             srt(cc:ccf,2)=repmat(fname,nrps,1);  % source file short name:2
%             [~,fname]=partsfile(rcvfname(indxr)); 
%             srt(cc:ccf,3)=fname;% receiver file short name:3
% 			srt(cc:ccf,7)=rcvfname(indxr); % reciever file name:7
%             rcvpostmp=cell(numel(indxr),1);
%             for iii=1:numel(indxr)
%                 head=readhead(rcvfname{indxr(iii)});
% 				% 20161203, fix this bug, 
% 				% head=readhead(rcvfname{iii});
%                 rcvpostmp(iii)={head.chinfo(1).sndpnum};
%             end
%             srt(cc:ccf,9)=rcvpostmp; % receiver position:9
%             srt(cc:ccf,4)=repmat({srcsn},nrps,1); % source serial number:4
%             srt(cc:ccf,5)=repmat({false},nrps,1); % bool value :5
% 			cc=ccf+1;
% 		end
% 	end
% 	
% else % theorical wave
%     rcvfname=v2col(fname); 
% 	% match source-receiver pair
% 	for i=1:numel(rcvfname)
%             cc=i;
%             % rcv num
%             r=regexpi(rcvfname{i},['C\w*ST\w*_ch\w*.dat']);
%             re=regexpi(rcvfname{i},['ST\w*_ch\w*.dat']);
%             recnum=rcvfname{i}(r+1:re-1);
%             [rp,rfn,]=fileparts(rcvfname{i});
%             ree=regexpi(rfn,['_ch\w*']);
%             fre=rfn(ree+6:end);
% 			srt(cc,1)={recnum};
%             srt(cc,2)=['C',recnum,'ST',num2str(srcsn),...
%                 '_ch00_',fre,'.dat'];
% 			srt(cc,6)={fullfile(rp,['C',recnum,'ST',num2str(srcsn),...
%                 '_ch00_',fre,'.dat'])};
%             srt(cc,8)={srcch};
%             [~,fname]=partsfile(rcvfname(cc));
%             srt(cc,3)=fname;
% 			srt(cc,7)=rcvfname(cc);   
%             head=readhead(rcvfname{cc});
%             srt(cc,9)={head.chinfo(1).sndpnum};
%             srt(cc,4)={srcsn};
%             srt(cc,5)=false;
%     end
% end
% 
% % srt
% if ~isempty(srt)
%     [~,indx]=sort_nat(srt(:,1));
%     srt(:,:)=srt(indx,:);
% end
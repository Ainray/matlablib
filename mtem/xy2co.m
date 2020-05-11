% function [cmp,offset,mask,mask_offset,srt]=xy2co(src,rcv,spacing,mode,seg,offsetlimit)
% author: Ainray
% created: 2015/5/22
% last modified: 2015/5/22
% modified: 2015/11/10,2015/11/28,20160310
% version: v1.0
% mail: wwzhang0421@163.com
% introduction: This program generating the profile within cmp-offset
% coordinate. The source and receiver postion within x-z coordinate and 
%             within cmp-offset coordinate can be mutually transformed 
%             as follows:
%                        cmp=(x_src+x_rcv)/2, offset=x_src-x_rcv.
%                         x_src=cmp+offset/2,  x_rcv=cmp-offset/2.
% input: 
%         src, the source lateral position 
%         rcv, the receiver lateral position 
%     spacing, the interval between adjoint points 
%        mode, 'dual','custom','increased','decreased','bottom'
%                   dual, dual-side coverage, 
%                 custom, source-receiver pair must been given as table,
%                         refer to  geo_get function
%              increased, single_side coverage in deep earth
%              decreased, the same as increased, except that the segments
%                         starting with points with large distance
%               dbottom,  alike 'dual' ,but set the maximum offset limit                     
%               sibottom, alike 'increased' ,but set the maximum 
%                         offset limit
%               sdbottom,  alike 'decreased',but set the maximum 
%                         offset limit. The prefix 's' means single-side mode, 
%                         contrary to dual-mode
%         seg, number of segments
% offsetlimit, only valid for 'sibottom' and 'sdbottom', indicating the offset limit
% output:
%         cmp, the common mid-point coordinate
%      offset, the distance between the source-recevier pair
%        mask, the profile mask matrix, where there are elements with
%              values of one, whose column index, is lateral position 
%              index, indicating the lateral distance from the minimum CMP, 
%              with respect to spacing/2; 
%                   i.e,
%                       indx=(CMPcur-CMPmin)/(spacing/2) 
%              whose row index, is the offset index, indicating the offset
%              from the minimum offset, with repect to spacing/2;
%                   i.e.,
%                       indx=(OFFSETcur-OFFSETmin)/(spacing/2) 
% mask_offset, when the mask is not related to the first the segment of the
%              the survey line, mask_offset can corret the lateral postion
%              calculating from mask. Alikely, when offset is not start
%              from zero, mask_offset can corret the vertical apparent
%              depth (indicated by offset).
%         srt, soure-receiver pair table
function [cmp,offset,mask,mask_offset,srt]=xy2co(src,rcv,spacing,mode,seg,offsetlimit)
if nargin<4
    mode='dual';
end
if nargin<5
    seg=1;
end
if nargin<6
    offsetlimit=1000000000; % a large number
end
%check the mode
while( ~strcmp(mode,'custom') && ~strcmp(mode, 'dual') && ~strcmp(mode,'increased') ...
       && ~strcmp(mode,'decreased') &&~strcmp(mode,'sibottom')...
       &&~strcmp(mode,'sdbottom')&&~strcmp(mode,'dbottom'))
    mode=input(['The mode must be : dual, custom, increased, decreased,'...
        ,'sibottom, sdbottom, dbottom sourrouding by single \n'...
        ,'quotation. If any problem, try  typing'...
        ,' help xy2co on the command window.\n']);
end
%convert source and receiver indices into distance
% src=sort(src);
% rcv=sort(rcv);


% covert source-receiver pair into cmp-offset pair, ergodically
if strcmp(mode,'dual') %dual
%     for i=1:n_src 
%         for j=1:n_rcv
%             cmp((i-1)*n_rcv+j)=(src(i)+rcv(j))/2;
%             offset((i-1)*n_rcv+j)=src(i)-rcv(j);   
%         end
%     end
   %modified by Ainray , 20160310
    ns=length(src);
    nr=length(rcv);
    srt(1:ns*nr,1)=sort(repmat(v2col(src),nr,1));
    srt(1:ns*nr,2)=repmat(sort(v2col(rcv)),ns,1);
    cmp=(srt(:,1)+srt(:,2))/2;
    offset=srt(:,1)-srt(:,2); 
   [mask,mask_offset]=mappingco(cmp,offset,spacing);
elseif strcmp(mode,'custom')  % source-receiver pair must been given as table
    cmp=(src+rcv)/2;
    offset=src-rcv;
    [mask,mask_offset]=mappingco(cmp,offset,spacing);
elseif strcmp(mode,'increased') % increasely single-side
    if length(seg)==1
        seg(2)=seg(1);
    end
    src=sort(v2col(src),'ascend');
    rcv=sort(v2col(rcv),'ascend');
    ns=length(src);nr=length(rcv);
    num_rcv_once=floor(nr/seg(2)); % part segments by receiver
    num_src_once=floor(ns/seg(1)); 
    % receiver segment limit
    rcvlimit(:,1)=1:num_rcv_once:nr-mod(nr,seg(2));
    rcvlimit(:,2)=[num_rcv_once:num_rcv_once:nr-mod(nr,seg(2))-1,nr];
    % soure segment limit
    srclimit(:,1)=1:num_src_once:ns-mod(ns,seg(1));
    srclimit(:,2)=[num_src_once:num_src_once:ns-mod(ns,seg(1))-1,ns];
    len=0;  % no s-r pair
    for i_seg=1:seg(1)
        N=nr-rcvlimit(i_seg,1)+1; % the number of receiver per source of the 'i_seg'th segment       
        nsps=srclimit(i_seg,2)-srclimit(i_seg,1)+1;%number of source per segment   
        srt(len+1:len+N*nsps,1)=sort(repmat(...
               src(srclimit(i_seg,1):srclimit(i_seg,2)),N,1));    
        srt(len+1:len+N*nsps,2)=repmat(...
            rcv(rcvlimit(i_seg,1):nr),nsps,1);
        len=size(srt,1); % update s-r pair counter
    end
    cmp=(srt(:,1)+srt(:,2))/2;
    offset=srt(:,1)-srt(:,2); 
    [mask,mask_offset]=mappingco(cmp,offset,spacing);
% %     src_t=[];
% %     rcv_t=[];
%     for i_seg=1:seg(1)
%         N=(seg(1)-i_seg+1)*num_rcv_once; % the number of receiver per source of the 'i_seg'th segment
%         len=length(src_t);
%         nsps=min(num_src_once,ns-(i_seg-1)*num_src_once);%number of source per segment
%         for i=1:nsps % source
%             src_t(len+1+(i-1)*N:len+i*N)=repmat(src(i+num_src_once*(i_seg-1)),N,1);  
%         end
%         len=length(rcv_t);
%         rcv_t(len+1:len+N*nsps)=repmat(...
%             rcv((i_seg-1)*num_rcv_once+1:end),1,nsps);
%     end
%     src_t=v2col(src_t);   
%     rcv_t=v2col(rcv_t);
%     srt=[src_t';rcv_t']';
%     cmp=(src_t+rcv_t)/2;
%     offset=src_t-rcv_t;     
%     [mask,mask_offset]=mappingco(cmp,offset,spacing);
elseif strcmp(mode,'decreased')
    src=v2col(sort(src,'descend'));
    rcv=v2col(sort(rcv,'descend'));
    if length(seg)==1
        seg(2)=seg(1);
    end
   
    ns=length(src);nr=length(rcv);
    num_rcv_once=floor(nr/seg(2)); % part segments by receiver
    num_src_once=floor(ns/seg(1)); 
    % receiver segment limit
    rcvlimit(:,1)=1:num_rcv_once:nr-mod(nr,seg(2));
    rcvlimit(:,2)=[num_rcv_once:num_rcv_once:nr-mod(nr,seg(2))-1,nr];
    % soure segment limit
    srclimit(:,1)=1:num_src_once:ns-mod(ns,seg(1));
    srclimit(:,2)=[num_src_once:num_src_once:ns-mod(ns,seg(1))-1,ns];
    len=0;  % no s-r pair
    for i_seg=1:seg(1)
        N=nr-rcvlimit(i_seg,1)+1; % the number of receiver per source of the 'i_seg'th segment       
        nsps=srclimit(i_seg,2)-srclimit(i_seg,1)+1;%number of source per segment   
        srt(len+1:len+N*nsps,1)=sort(repmat(...
               src(srclimit(i_seg,1):srclimit(i_seg,2)),N,1));    
        srt(len+1:len+N*nsps,2)=repmat(...
            rcv(rcvlimit(i_seg,1):nr),nsps,1);
        len=size(srt,1); % update s-r pair counter
    end
    cmp=(srt(:,1)+srt(:,2))/2;
    offset=srt(:,1)-srt(:,2); 
    [mask,mask_offset]=mappingco(cmp,offset,spacing);
    
%     src_t=[];
%     rcv_t=[];
%     for i_seg=1:seg(1)
%         % the number of receiver per source of the 'i_seg'th segment
%         N=(seg(1)-i_seg+1)*num_rcv_once;     
%         len=length(src_t);
%         nsps=min(num_src_once,ns-(i_seg-1)*num_src_once);%number of source per segment
%         for i=1:nsps % source
%             src_t(len+1+(i-1)*N:len+i*N)=repmat(src(i+num_src_once*(i_seg-1)),N,1);  
%         end
%         len=length(rcv_t);
%         rcv_t(len+1:len+N*nsps)=repmat(...
%             rcv((i_seg-1)*num_rcv_once+1:end),1,nsps);
%     end
%     src_t=v2col(src_t);   
%     rcv_t=v2col(rcv_t);
%     srt=[src_t';rcv_t']';
%     cmp=(src_t+rcv_t)/2;
%     offset=src_t-rcv_t; 
%      len=0;  % no s-r pair
%      for i_seg=1:seg(1)
%         N=(seg(1)-i_seg+1)*num_rcv_once; % the number of receiver per source of the 'i_seg'th segment       
%         nsps=min(num_src_once,ns-(i_seg-1)*num_src_once);%number of source per segment
%         for i=1:nsps % source
%             srt(len+1+(i-1)*N:len+i*N,1)=repmat(src(i+num_src_once*(i_seg-1)),N,1);  
%         end    
%         srt(len+1:len+N*nsps,2)=repmat(...
%             rcv((i_seg-1)*num_rcv_once+1:end),nsps,1);
%         len=size(srt,1); % update s-r pair counter
%      end
%     cmp=(srt(:,1)+srt(:,2))/2;
%     offset=srt(:,1)-srt(:,2); 
%     [mask,mask_offset]=mappingco(cmp,offset,spacing);
    
elseif strcmp(mode,'dbottom')
        src=sort(v2col(src),'ascend');
        rcv=sort(v2col(rcv),'ascend');
        if length(seg)==1
            seg(2)=seg(1);
        end
        ns=length(src);nr=length(rcv);
        %assume : ceil(nr/segnum)*(segnum-1)<nr
        num_rcv_once=floor(nr/seg(2)); % part segments by receiver
%         num_src_once=floor(ns/seg(1)); 
    %     nss=ceil(ns/num_src_once);  % recalcu
    %     nsr=ceil(nr/num_rcv_once); 
        % receiver segment limit
        rcvlimit(:,1)=1:num_rcv_once:nr-mod(nr,seg(2));
        rcvlimit(:,2)=[num_rcv_once:num_rcv_once:nr-mod(nr,seg(2))-1,nr];
        % soure segment limit
%         srclimit(:,1)=1:num_src_once:ns-mod(ns,seg(1));
%         srclimit(:,2)=[num_src_once:num_src_once:ns-mod(ns,seg(1))-1,ns];

        len=0;  % no s-r pair 
        for i_seg=1:seg(2) % the ith segment
    %         %debug
    %         if i_seg==5
    %             i_seg
    %         end
%             for j_seg=min(i_seg,seg(1)):-1:1
              for j=1:ns
                 if min(abs(src(j)-rcv(rcvlimit(i_seg,1):rcvlimit(i_seg,2))))...
                         <offsetlimit
                 % distance of source segment and receiver segment
                 % defined by the closest two points
%                 if srdistance(src,rcv,srclimit(j_seg,:),rcvlimit(i_seg,:))<offsetlimit
                    %number of source for current segment 
%                     nsps=srclimit(j_seg,2)-srclimit(j_seg,1)+1; 
                    % the number of receiver for current source  
                    nsps=1;
                    N=rcvlimit(i_seg,2)-rcvlimit(i_seg,1)+1; 
                    %
                    srt(len+1:len+N*nsps,1)=...
                        sort(repmat(src(j),N,1));
                    srt(len+1:len+N*nsps,2)=repmat(...
                        rcv(rcvlimit(i_seg,1):rcvlimit(i_seg,2)),nsps,1);
                    len=size(srt,1); % update s-r pair counter
    %                 %debug
    %                 [i_seg,j_seg]
    % %             else
    % %                 break;
                 end  
             end
%             for j_seg=i_seg+1:1:seg(1); % find backward
%                 if srdistance(src,rcv,srclimit(j_seg,:),rcvlimit(i_seg,:))<offsetlimit
%                     %number of source for current segment 
%                     nsps=srclimit(j_seg,2)-srclimit(j_seg,1)+1; 
%                     % the number of receiver for current source         
%                     N=rcvlimit(i_seg,2)-rcvlimit(i_seg,1)+1; 
%                     %
%                     srt(len+1:len+N*nsps,1)=...
%                         sort(repmat(src(srclimit(j_seg,1):srclimit(j_seg,2)),N,1));
%                     srt(len+1:len+N*nsps,2)=repmat(...
%                         rcv(rcvlimit(i_seg,1):rcvlimit(i_seg,2)),nsps,1);
%                     len=size(srt,1); % update s-r pair counter
%     %                 %debug
%     %                 [i_seg,j_seg]
%     % %             else
%     % %                 break;
%                 end  
%             end  
        end
        cmp=(srt(:,1)+srt(:,2))/2;
        offset=srt(:,1)-srt(:,2); 
        [mask,mask_offset]=mappingco(cmp,offset,spacing);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
elseif strcmp(mode,'sibottom')
        if length(seg)==1
            seg(2)=seg(1);
        end
        src=sort(v2col(src),'ascend');
        rcv=sort(v2col(rcv),'ascend');
        ns=length(src);nr=length(rcv);
        num_rcv_once=floor(nr/seg(2)); % part segments by receiver
        num_src_once=floor(ns/seg(1)); 
        % receiver segment limit
        rcvlimit(:,1)=1:num_rcv_once:nr-mod(nr,seg(2));
        rcvlimit(:,2)=[num_rcv_once:num_rcv_once:nr-mod(nr,seg(2))-1,nr];
        % soure segment limit
        srclimit(:,1)=1:num_src_once:ns-mod(ns,seg(1));
        srclimit(:,2)=[num_src_once:num_src_once:ns-mod(ns,seg(1))-1,ns];
        len=0;  % no s-r pair
       
        for i_seg=1:seg(1) % indexing source 
            rcvsul=nr;  %default value
            for j_seg=i_seg+1:seg(2) % exclude remote receiver segment
                if srdistance(src,rcv,srclimit(i_seg,:),rcvlimit(j_seg,:))>=offsetlimit
                    rcvsul=rcvlimit(j_seg-1,2); % receiver segment up limit
                    break;
                end
            end
            N=rcvsul-rcvlimit(i_seg,1)+1; % the number of receiver per source of the 'i_seg'th segment       
            nsps=srclimit(i_seg,2)-srclimit(i_seg,1)+1;%number of source per segment   
            srt(len+1:len+N*nsps,1)=sort(repmat(...
                   src(srclimit(i_seg,1):srclimit(i_seg,2)),N,1));    
            srt(len+1:len+N*nsps,2)=repmat(...
                rcv(rcvlimit(i_seg,1):rcvsul),nsps,1);
            len=size(srt,1); % update s-r pair counter
        end
        cmp=(srt(:,1)+srt(:,2))/2;
        offset=srt(:,1)-srt(:,2); 
        [mask,mask_offset]=mappingco(cmp,offset,spacing); 
        
elseif strcmp(mode,'sdbottom')
        if length(seg)==1
            seg(2)=seg(1);
        end
        src=sort(v2col(src),'descend');
        rcv=sort(v2col(rcv),'descend');
        ns=length(src);nr=length(rcv);
        num_rcv_once=floor(nr/seg(2)); % part segments by receiver
        num_src_once=floor(ns/seg(1)); 
        % receiver segment limit
        rcvlimit(:,1)=1:num_rcv_once:nr-mod(nr,seg(2));
        rcvlimit(:,2)=[num_rcv_once:num_rcv_once:nr-mod(nr,seg(2))-1,nr];
        % soure segment limit
        srclimit(:,1)=1:num_src_once:ns-mod(ns,seg(1));
        srclimit(:,2)=[num_src_once:num_src_once:ns-mod(ns,seg(1))-1,ns];
        len=0;  % no s-r pair
       
        for i_seg=1:seg(1) % indexing source 
            rcvsul=nr;  %default value
            for j_seg=i_seg+1:seg(2) % exclude remote receiver segment
                if srdistance(src,rcv,srclimit(i_seg,:),rcvlimit(j_seg,:))>=offsetlimit
                    rcvsul=rcvlimit(j_seg-1,2); % receiver segment up limit
                    break;
                end
            end
            N=rcvsul-rcvlimit(i_seg,1)+1; % the number of receiver per source of the 'i_seg'th segment       
            nsps=srclimit(i_seg,2)-srclimit(i_seg,1)+1;%number of source per segment   
            srt(len+1:len+N*nsps,1)=sort(repmat(...
                   src(srclimit(i_seg,1):srclimit(i_seg,2)),N,1));    
            srt(len+1:len+N*nsps,2)=repmat(...
                rcv(rcvlimit(i_seg,1):rcvsul),nsps,1);
            len=size(srt,1); % update s-r pair counter
        end
        cmp=(srt(:,1)+srt(:,2))/2;
        offset=srt(:,1)-srt(:,2); 
        [mask,mask_offset]=mappingco(cmp,offset,spacing); 

end

function srdist=srdistance(src,rcv,srclimit,rcvlimit)
    dist(1)=src(srclimit(1))-rcv(rcvlimit(1));
    dist(2)=src(srclimit(1))-rcv(rcvlimit(2));
    dist(3)=src(srclimit(2))-rcv(rcvlimit(1));
    dist(4)=src(srclimit(2))-rcv(rcvlimit(2));
    srdist=min(abs(dist));


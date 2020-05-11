function imps=sortimp( imps, varargin )
% author: Ainray
% date :20160315
% bug-report: wwzhang0421@163.com
% vervion: 1.2 refert to peakimp
% introduction: sort EIRs array by differnt mode.
%
%     input: 
%          imps, array of EIR structures
%          
%          (optional parameter-value pair)
%             'Method', 'cmpoffset'/'offsetcmp'/'src'/'frequency'
%                       'cmpoffset', fisrt sort by CMP, then by offset, CMP gather
%                       'offsetcmp', first by offset, then by CMP,  CO gather
%                       'src',       first by source, then by receiver, CS gather
%                       'frequency', just let frequencies of one points increases
%   output: imps: sorted cell array of impulse structures

p=inputParser;
expectedmethods={'src','cmpoffset','offsetcmp','frequency'};

addRequired(p,'imps',@isstruct);
addOptional(p,'Method','src',@(x) any(validatestring(x,expectedmethods)));

parse(p,imps,varargin{:});

method=p.Results.Method;

impulse=imps;
N=numel(impulse);  % number of points
srct=zeros(N,1);
rcvt=zeros(N,1);
for i=1:N
     srct(i)=impulse(i).meta.srcpos;
     rcvt(i)=impulse(i).meta.rcvpos;
end
cmp=(srct+rcvt)/2;
offset=srct-rcvt;

switch method
    case 'src'
        [srct,indx]=sort(srct); % sort by source
        impulse=impulse(indx);
        rcvt=rcvt(indx);        % update receiver positions

        srcnum=unique(srct);    % unique source positions
        cc=0;                   % the segment offset for current source
        for i=1:length(srcnum)   % sort by receiver
            indxsrcv=find(srct==srcnum(i));  % within some shot, receiver indices
                                             % which is still global
            [~,indxr]=sort(rcvt(indxsrcv)); % sort by receiver positions, the 
                                                 % returned indices is local for 
                                                 % current source
            impulse(indxsrcv)=impulse(indxr+cc); % cc is
            cc=cc+length(indxsrcv);
        end
    case 'cmpoffset'
        [cmp,indx]=sort(cmp); % sort by CMP
        impulse=impulse(indx);
        offset=offset(indx);        % update offsets 
        
        cmpnum=unique(cmp);    % unique CMP positions
        cc=0;                   % the segment offset for current CMP gather
        for i=1:length(cmpnum)   % sort by offset
            indxco=find(cmp==cmpnum(i));  % the CMP gather, offset indices
                                             % which is still global
            [~,indxo]=sort(abs(offset(indxco))); % sort by offset, the 
                                                 % returned indices is local for 
                                                 % current CMP gather
            impulse(indxco)=impulse(indxo+cc); % cc is
            cc=cc+length(indxco);
        end
    case 'offsetcmp'
        absoffset=abs(offset);  %sort by OFFSET
        [absoffset,indx]=sort(absoffset);
        offset=offset(indx); % update offset
        impulse=impulse(indx);
        cmp=offset(indx);        % update offsets 
        
        absoffsetnum=unique(absoffset);    % unique CO 
        cc=0;                   % the segment offset for current CO gather
        for i=1:length(absoffsetnum)   % sort by cmp
            indxoc= find(absoffset==absoffsetnum(i));  % the CMP gather, offset indices
                                             % which is still global
            [~,indxcmp]=sort(cmp(indxoc));  % sort by cmp, the 
                                                 % returned indices is local for 
                                                 % current CO gather
            impulse(indxoc)=impulse(indxcmp+cc); % cc is offset of CO gather
            cc=cc+length(indxoc);
        end
    case 'frequency'
        for i=1:N
            M=numel(impulse{i});
            fres=ones(M,1);
            for j=1:M
                fres(j)=impulse{i}(j).fs;
            end
            [~,indx]=sort(fres);
            impulse{i}(:)=impulse{i}(indx);        
        end
end
imps=impulse;
%     % sort by frequency
%     offset=0;        %offset by receiver within some shot
%     rcvpos=unique(rcvt);
%     for j=1:length(rcvpos)
%         indx_fr=find(rcvt==rcvpos(j));
%         indx_fr=v2col(indx_fr);
%         fr=[];
%         for k=1:length(indx_fr)
%             fr(k)=imps(cc+indx_fr(k)).code(2);
%         end
%         fr=v2col(fr);
%         [fre,indx_f]=sort(fr);
%         imps(cc+indx_fr)=imps(cc+offset+indx_f);
%         offset=offset+length(indx_fr);
%     end   
%     cc=cc+length(indxsrcv);  %offset by shot
% end
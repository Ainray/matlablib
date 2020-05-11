function [imps,indx,nlb,nloc]=indximp(imps,sv,varargin)
% author: Ainray
% date: 20160327 20161202
% bug-report: wwzhang0421@163.com
% introduciton: indexing EIR by chip frequency, source position(Common Shot Gathe, CSG)
%               receiver position, mid-points (Common Mid-point Gather, CMG), offset
%               (Common offet Gather, COG)
%  Syntax:
%              [imps,indx,nlb,nloc]=indximp(imps,sv)      % CSG
%              [imps,indx,nlb,nloc]=indximp(imps,sv,'Mode','COG') % COG
%              [imps,indx,nlb,nloc]=indximp(imps,sv,'Mode','CMG') % CMG
%              [imps,indx,nlb,nloc]=indximp(imps,sv,'Mode','CFG') % CFG
%              [imps,indx,nlb,nloc]=indximp(imps,sv,'Mode','CRG') % CRG
%              [imps,indx,nlb,nloc]=indximp(imps,0,'Mode','Mark') % get only effective EIRs
%   NOTE: This function does check whether the searth value is valid or not. 
%   input: 
%          imps, array of EIRs
%            sv, searth value(s)
%          (Optinal parameter-value pair)
%           'Mode', 'CMG'/'COG'/'CSG'/'CFG'
%                   'CSG', the default, common shot gather
%                   'CMG', common midpoint gather
%                   'COG', common offset gather
%           		'CFG', common frequency 
%                   'CRG', common receiver
%                  'Mark', effective EIRs
p=inputParser;
addRequired(p,'imps',@isstruct);
addRequired(p,'sv',@(x) isnumeric(x));
addOptional(p,'Mode','CSG',@(x) any(validatestring(x,{'CSG',...
		'COG','CMG','CFG','CRG','Mark'})));
parse(p,imps,sv,varargin{:});
mode=p.Results.Mode;

N=numel(imps);
M=numel(sv);
cc=0;
cb=0;
indx=[];nlb=[];nloc=[];
switch mode
	case 'CRG'
        for j=1:M
            cc0=cc;
            for i=1:N          
                if imps(i).meta.rcvpos==sv(j)
                    cc=cc+1;
                    tmp(cc)=imps(i);
                    indx(cc)=i;
                end
            end
            if cc==cc0 % nothing found
                cb=cb+1;
                nlb(cb)=sv(j);
                nloc(cb)=j;
            end
        end
	case 'CFG'
        for j=1:M
             cc0=cc;
            for i=1:N
                if imps(i).meta.code(2)==sv(j)
                    cc=cc+1;
                    tmp(cc)=imps(i);
                    indx(cc)=i;
                end
            end
            if cc==cc0 % nothing found
                cb=cb+1;
                nlb(cb)=sv(j);
                nloc(cb)=j;
            end
        end
	case 'CSG'
        for j=1:M
             cc0=cc;
            for i=1:N
                if imps(i).meta.srcpos==sv(j)
                    cc=cc+1;
                    tmp(cc)=imps(i);
                    indx(cc)=i;
                end
            end
             if cc==cc0 % nothing found
                cb=cb+1;
                nlb(cb)=sv(j);
                nloc(cb)=j;
            end
        end
	case 'COG'
        for j=1:M
             cc0=cc;
            for i=1:N
                if abs(imps(i).meta.offset)==sv(j)
                    cc=cc+1;
                    tmp(cc)=imps(i);
                    indx(cc)=i;
                end
            end
        end
	case 'CMG'
        for j=1:M
            cc0=cc;
            for i=1:N
                if imps(i).meta.cmp==sv(j)
                    cc=cc+1;
                    tmp(cc)=imps(i);
                    indx(cc)=i;
                end
                
            end
            if cc==cc0 % nothing found
                cb=cb+1;
                nlb(cb)=sv(j);
                nloc(cb)=j;
            end
        end
	case 'Mark'
		for i=1:N
			if imps(i).mask==1
				cc=cc+1;
				tmp(cc)=imps(i);
				indx(cc)=i;
			end
		end
		
end
if cb==M % nothing to be found
    tmp=[];
end
imps=tmp;
% fre=zeros(2,1);
% for i=1:length(imps)
%     fre(i)=imps(i).code(2);
% end
% indx=find(fre==code_fre);
% imps_fre=zeros(2,1);
% imps_fre=v2col(imps(indx));

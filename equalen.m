% function m=equalen(x,varargin)
% author: Ainray
% time  : 2016/1/3
% version: 1.2.2, by Ainray, 20160315
% bug report: wwzhang0421@163.com
% information: let the length of arrays be the same with padding zeros.
% syntax:  m=equalen(x)
%          m=equalen(x,N)
%          m=equallen({a,b,c},N)
% input:
%         x,   cell of array list.
%
%             (optional parameter-value pair)
%         N, optional, pecifying the mininum slength, the default value is set
%            the maximum length of element of x
%  output:
%         m, the output matrix, each column is from each vector.
function m=equalen(x,N)
if nargin<2
    N=0;
end
Nx=numel(x);
L=0;
for i=1:Nx
    M(i)=numel(x{i});
   if L<M(i)
      L=M(i);
   end
end
L=max(L,N);
m=zeros(L,Nx);
for i=1:Nx
    tmp=v2col(x{i});
    m(:,i)=[tmp;zeros(L-M(i),1)];
end

%-----------------------v1.2--------------------------------
% x,           array list, it must contains at least two vectors.
%              The first two parameters must be arrays. From three, we can pecify the mininum 
%              slength, by transfering parameter-value pair, like, 'LenLimit',20; which indicating
%              the mininum length is 20.
% output:
%         m, the output matrix, each column is from each vector.
% function m=equalen(varargin)
%   num=numel(varargin);
%   if num<2
%       error('Input parameters must more than 1.\n');
%   end
%  
%   arr(1:2)=varargin(1:2);  % save the first two arrays
%   
%   minlen=0;   % no length limit
%   v=3 ; % search from postion 3
%   while v<num % exclude the last one
% 	 if strcmp(varargin{v},'LenLimit')  % with length limit
% 		minlen=varargin{v+1};
% 		break;
% 	else % array paramter
% 		arr{v}=varargin{v};
%         v=v+1;
%      end
%   end
%   
%   if v<num  % indicating have length limit
% 	arr{[v+2:num]-2}=varargin{v+2:num};
%   else  
%       arr{num}=varargin{num};  % the last
%   end
%   
%   num=numel(arr); %update element number
%   
%   maxlen=0;  % get mininum length
%   for i=1:num
%       if maxlen<length(arr{i})
%           maxlen=length(arr{i});
%       end
%   end
%  maxlen=max(maxlen,minlen);
%  
%   m=zeros(maxlen,num); % alloc buffer
%   if mod(num,2)==0
%         for i=1:2:num-1		    
%            m(:,i:i+1)=equaldual(arr{i},arr{i+1},maxlen);
%         end
%   else
%         for i=1:2:num-1
%             m(:,i:i+1)=equaldual(arr{i},arr{i+1},maxlen);
%         end
%          m(:,num)=[v2col(arr{num});zeros(maxlen-length(arr{num}),1)];
%   end
% end
% 
% function m2=equaldual(x0,y0,lenlimit)  % for two arrays
%     x0=v2row(x0);y0=v2row(y0);
%     nx=length(x0);ny=length(y0);
%     len=max(max(nx,ny),lenlimit);
%     x=[x0,zeros(1,len-nx)];
%     y=[y0,zeros(1,len-ny)];
%     m2=[x;y]';
% end

%--------------------------version 1.0---------------------%
% % function [x,y,z]=equalen(x0,y0,z0)
% % author: Ainray
% % time  : 2015/7/27
% % bug report: wwzhang0421@163.com
% % information: let the length of dual or triple array be the same with padding zeros.
% % input:
% %      x0,
% %      y0, 
% %      z0,
% %  output:
% %       x, 
% %       y, 
% %       z,
% function [x,y,z]=equalen(x0,y0,z0)
% narginchk(2, 3);
% if nargin==2
%     x0=v2col(x0);y0=v2col(y0);
%     nx=length(x0);ny=length(y0);
%     len=max(nx,ny);
%     x=[x0;zeros(len-nx,1)];
%     y=[y0;zeros(len-ny,1)];
% else
%      x0=v2col(x0);y0=v2col(y0);z0=v2col(z0);
%     nx=length(x0);ny=length(y0);nz=length(z0);
%     len=max(max(nx,ny),nz);
%     x=[x0;zeros(len-nx,1)];
%     y=[y0;zeros(len-ny,1)];
%     z=[z0;zeros(len-nz,1)];
% end
        
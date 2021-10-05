function x=cover(x0,y,head)
% function x=conver(x0,y)
% author: Ainray
% date: 20210922
% email:wwzhang0421@163.com
% introduction: extend x periodically to cover y
%            x0, input signal to be extendeded
%             y, input signal to be covered
%          head, head is allowed more than Nx to indicate where x0 starts from
%                some middle point of y, still used as phase regulator, default value is
%                set 1.
%             x, the peroidic extension of x0

Ny=length(y);
Nx=length(x0);

if nargin<3
    head=1; % is large, so x will be [x0;repmat[x0,L,1)];
end

if Nx>=Ny
    error('Invalid Input: x0 must be shorter than y');
end

if head > Ny || head <1
    error(['Invalid Input: head must be within 1~',num2str(Ny)]);
end

vx0=x0(:);

% tailing part
Ny1 = Ny - head + 1;
Ny2 = Ny - Ny1;

L1 = floor(Ny1/Nx);
L2 = floor(Ny2/Nx);

R1 = Ny1 - L1 * Nx;
R2 = Ny2 - L2 * Nx;

x = [vx0(Nx-R1+1:Nx);repmat(vx0,L2,1); repmat(vx0,L1,1);vx0(1:R2)];

% old version
% function x=cover(x0,y,head)
% % function x=conver(x0,y)
% % author: Ainray
% % date: 20170619
% % email:wwzhang0421@163.com
% % introduction: extend x periodically to cover y
% %            x0, input signal to be extendeded
% %             y, input signal to be covered
% %          head, phase regulator,if L=length(y)/length(x) is not an integer
% %                'head' number of x0 samples are inserted ahead of its
% %                perodic extension. For example, 
% %                if head=0, then x=[repmat(x0,L,1);x0(1:Ny-L*Nx)]; 
% %                if head=1, then x=[x0(end-1:end);repmat(x0,L);x0(1:Ny-L*Nx-1)]
% %                if head>=Ny-L*Nx, then x=[x0;repmat(x0,L,1)] 
% %             x, the peroidic extension of x0
% Ny=length(y);
% Nx=length(x0);
% if nargin<3
%     head=Nx; % is large, so x will be [x0;repmat[x0,L,1)];
% end
% if Nx>=Ny
%     error('Invalid Input: x0 must be shorter than y');
% end
% L=floor(Ny/Nx);
% 
% vx0=v2col(x0);
% if L*Nx==Ny % covered exactly
%    x=repmat(vx0,L,1); 
% else
%     R=Ny-L*Nx;
%     x=[x0(Nx-min(head,R)+1:Nx);repmat(vx0,L,1);x0(1:R-head)];    
% end

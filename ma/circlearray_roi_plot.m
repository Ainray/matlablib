function circlearray_roi_plot(rx,ry,npx,npy,Ne,r,theta_offset)
% example: circlearray_roi_plot(0.06,0.06,100,100,32, 0.065);

if nargin < 7
    theta_offset = pi/2;
end

% ROI
dx = rx/npx;
dy = ry/npy;
offsetx = -rx*0.5;
offsety = -ry*0.5;

x = offsetx + (0:npx-1)*dx + 0.5*dx;
y = offsety + (0:npy-1)*dy + 0.5*dy;
[X,Y]=meshgrid(x,y);

x = X(1,:);
y = Y(:,1);
x = x - dx*0.5;
y = y - dy*0.5;

x = [x(:); x(end)+dx];
y = [y(:); y(end)+dy];
nx = length(x);
ny = length(y);

% source

theta_delta = 2*pi/Ne;
% theta_offset = pi/2;
theta(1:Ne) = theta_offset - (0:Ne-1) * theta_delta;
sx = r*cos(theta);
sy = r*sin(theta);

figure();
plot([x x]', [y(1);y(end)]*ones(1,ny),'k');
hold on;
plot([x(1);x(end)]*ones(1,nx), [y y]','k');
plot(sx,sy,'sk');

set(gca,'DataAspectRatio',[1,1,1]);
set(gcf,'color',[1 1 1]);

xlabel('m');
ylabel('m');
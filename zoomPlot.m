function az = zoomPlot(ah, source_pos, target_pos)
% FUNCTION ZOOMPLOT(AH, source_pos, target_pos)
%
% This function takes in a handle to an axes, makes a zoom-in plot on top
% of the existing plot based on the source and target positions given. 
% Note that the positions are specified as [x1, y1, x2, y2] where x1 and y1 
% specifies the lower left corner of the rectangle, x2 and y2 specifieds 
% the upper right corner of the rectangle. 
% 
% Inputs: 
%  ah           - handle to the existing axes to be zoomed in. 
%  source_pos   - position of the portion to be zoomed in 
%  target_pos   - position on the original plot where the zoom-in plot will be
%  made
%
% Output: 
%
%  za           - handle of the axes for the zoom-in plot
%  Wei Shang 
%  University of New Brunswick 
%  wei.shang@unb.ca 

% getting the normalized position from the original plot
% we want to know the boundaries of the existing axes. 
hold on;
pos = get(ah, 'position'); 
xn = pos(1); yn = pos(2); 
wn = pos(3); hn = pos(4); 

% getting the data boundaries of the original plot 
xd  = get(ah, 'xlim'); yd  = get(ah, 'ylim');
wd   = xd(2) - xd(1);  hd  = yd(2) - yd(1);

% calculate the ratio between the data unit to the normalized unit. 
x_n2d = wd / wn; 
y_n2d = hd / hn;

% Read in the position vector of the zoom-in plot based on data boundary 
tx1 = target_pos(1); tx2 = target_pos(3); 
ty1 = target_pos(2); ty2 = target_pos(4);

% compute the corresponding position vector based on the normalized unit 
target_pos(1) = (tx1 - xd(1)) / x_n2d + xn;
target_pos(2) = (ty1 - yd(1)) / y_n2d + yn; 
target_pos(3) = (tx2 - xd(1)) / x_n2d + xn;
target_pos(4) = (ty2 - yd(1)) / y_n2d + yn;

% drawing a rectangle around the source position 
rect_x = source_pos(1); rect_y = source_pos(2); 
rect_w = source_pos(3) - source_pos(1); 
rect_h = source_pos(4) - source_pos(2);
source_rect = rectangle('position', [rect_x, rect_y, rect_w, rect_h], 'linestyle', '-', 'EdgeColor', 'k');

% create the zoom-in axes based on the compuated position 
az = axes('position', [target_pos(1), target_pos(2), target_pos(3)-target_pos(1), target_pos(4)-target_pos(2)]); 
% copy all object from the orignal axes 
copyobj(allchild(ah), az);

% set the x- and y-limit based on the given zoom-in target. 
% xlim([source_pos(1) source_pos(3)]);
% ylim([source_pos(2) source_pos(4)]);
xlim([700 710]);
ylim([-0.01 0.01]*yd(2));
% customize the zoom-in plot 
set(az, 'xtick', [], 'ytick', []);
set(source_rect, 'linestyle','-','linewidth',1,...
  'Edgecolor', 'k');
box on;

% making the original plot the active plot. 
axes(ah); 
% making sure the original plot is behind all the other elements  
uistack(ah, 'bottom');


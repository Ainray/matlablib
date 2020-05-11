% Defaults for this blog post
width = 6; %6.2992126;     % Width in inches, 16cm/ 7.5cm 2.9527559 inches
height = 3;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 8;      % Fontsize
lw = 2;      % LineWidth
msz = 6;       % MarkerSize
hf=figure('color',[1 1 1]);
pos = get(gcf, 'Position');
set(gcf, 'Position', [400 300 width*100, height*100]); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
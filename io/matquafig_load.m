% author: Ainray
% email: wwzhang0421@163.com
% date: 20220211
function [lw, msz, width, height, hf, pos, alw, fsz] = matquafig_load(wi, hi, fszi, lwi, mszi, alwi)

if nargin< 1 || isempty(wi)
    wi = 3;  %6.2992126;     % Width in inches, 16cm/ 7.5cm 2.9527559 inches
end

if nargin< 2 || isempty(hi)
    hi = 3;    % Height in inches
end


if nargin< 3 || isempty(fszi)
    fszi = 9;      % Fontsize
end

if nargin< 4 || isempty(lwi)
    lwi = 1;      % LineWidth
end

if nargin< 5 || isempty(mszi)
    mszi = 4;       % MarkerSize
end

if nargin< 6 || isempty(alwi)
    alwi = 0.75;    % AxesLineWidth
end

width = wi;
height = hi;
alw = alwi;
fsz = fszi;
lw = lwi;
msz = mszi;
hf=figure('color',[1 1 1]);
pos = get(gcf, 'Position');
set(gcf, 'Position', [400 300 width*100, height*100]); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
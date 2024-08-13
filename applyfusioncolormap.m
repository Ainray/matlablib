function [customMap, cr] = applyfusioncolormap(a, b, c, d, ax)
    if nargin < 5
        ax = gca;
    end
    if ~(a < b && b <= c && c < d)
        error('Ensure that a < b <= c < d');
    end

    totalColors = 256;
    grayLength = round((b - a) / (d - a) * totalColors);
    jetLength = totalColors - grayLength;

    grayMap = gray(grayLength);
    jetMap = jet(jetLength);

    customMap = [grayMap; jetMap];
    cr = [a,d];
    if nargout < 1
        colormap(ax,customMap);
        caxis(ax, cr);
    end
end
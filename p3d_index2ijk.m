function [i, j, k] = p3d_index2ijk(index, nx, ny)
% author: Ainray
% date: 20220831
% bug-report: wwzhang0421@163.com
% introduction: index 2 ijk
% modify:
k = floor(index/(nx*ny));
if k * nx * ny < index
    k = k + 1;
end
kr = index - (k-1) * (nx * ny);
j = floor(kr/nx);
if j * nx < kr
    j = j + 1;
end
jr = kr - (j-1)*nx;
i = jr;


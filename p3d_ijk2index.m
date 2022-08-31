function index = p3d_ijk2index(ijk, nx, ny)
% author: Ainray
% date: 20220831
% bug-report: wwzhang0421@163.com
% introduction: cell index 2 ijk
% modify:
i = ijk(:,1);
j = ijk(:,2);
k = ijk(:,3);
index = i + (j-1) * nx + (k-1) * nx * ny;


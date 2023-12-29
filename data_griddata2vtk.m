function p3d_griddata2vtk(fname, data, name, x, y, z)
% author: Ainray
% date: 20220831
% bug-report: wwzhang0421@163.com
% introduction: export data to vtk
% modify: 
%   20220814, data support multiple properties

fid = fopen(fname, 'w');
fprintf(fid,'# vtk DataFile Version 2.0\n'); 
fprintf(fid,'Corner point grid\n'); 
fprintf(fid,'ASCII\n'); 
fprintf(fid,'DATASET UNSTRUCTURED_GRID\n');

% nodes
nx = length(x);
ny = length(y);
nz = length(z);

nx1 = nx - 1;
ny1 = ny - 1;
nz1 = nz - 1;

nn = nx * ny * nz;
fprintf(fid,'POINTS  %d  float\n', nn); 
for k=1:nz
    for j=1:ny
        for i=1:nx  
            fprintf(fid, '%f %f %f\n', x(i), y(j), z(k));
        end
    end
end
nc = nx1 * ny1 * nz1;
nc9 = nc * 9;
fprintf(fid,'CELLS  %d  %d\n', nc, nc9);

for ic=0:nc-1
    
    [i, j, k] = p3d_index2ijk(ic, nx1, ny1);
    
    p = ones(8, 3);
    
    p(1, :) = [i, j ,k];
    p(2, :) = [i+1, j ,k];
    p(3, :) = [i, j+1, k];
    p(4, :) = [i+1, j+1, k];
    
    p(5, :) = [i, j ,k+1];
    p(6, :) = [i+1, j ,k+1];
    p(7, :) = [i, j+1, k+1];
    p(8, :) = [i+1, j+1, k+1];
    
    pindex = p3d_ijk2index(p, nx, ny);
    
    fprintf(fid, "%d %d %d %d %d %d %d %d %d\n", 8, pindex');
end
fprintf(fid,'CELL_TYPES  %d\n', nc);
type = 11; %VTK_VOXEL
fprintf(fid, '%d\n', ones(nc, 1)*type);

fprintf(fid, 'CELL_DATA %d\n', nc);

np = numel(data);
for i=1:np
    fprintf(fid, ['SCALARS ', name{i}, ' float\n']);
    fprintf(fid, 'LOOKUP_TABLE default\n');
    fprintf(fid, '%f\n', data{i});
end

fclose(fid);



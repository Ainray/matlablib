function data_griddata2vtk_binary(fname, data, name, x, y, z)
    % author: Ainray
    % date: 20220831
    % bug-report: wwzhang0421@163.com
    % introduction: export data to binary VTK
    % modify: 
    %   20220814, data support multiple properties

    fid = fopen(fname, 'wb');  % Open in binary write mode
    fprintf(fid, '# vtk DataFile Version 2.0\n'); 
    fprintf(fid, 'Corner point grid\n'); 
    fprintf(fid, 'BINARY\n');  % Set to binary mode
    fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');

    % nodes
    nx = length(x);
    ny = length(y);
    nz = length(z);

    nx1 = nx - 1;
    ny1 = ny - 1;
    nz1 = nz - 1;

    nn = nx * ny * nz;
    fprintf(fid, 'POINTS  %d  float\n', nn); 

    % Write the node coordinates in binary format
    for k = 1:nz
        for j = 1:ny
            for i = 1:nx  
                fwrite(fid, [single(x(i)), single(y(j)), single(z(k))], 'float', 'b');
            end
        end
    end
    fprintf(fid, '\n');
    
    nc = nx1 * ny1 * nz1;
    nc9 = nc * 9;
    fprintf(fid, 'CELLS  %d  %d\n', nc, nc9);

    for ic = 0:nc-1
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
        
        % Convert to 4-byte integers and write in binary format
        fwrite(fid, [8; pindex], 'int32', 'b');
    end
    fprintf(fid, '\n');
    
    fprintf(fid, 'CELL_TYPES  %d\n', nc);
    type = 11; % VTK_VOXEL   
    % Convert to 4-byte integers and write in binary format
    fwrite(fid, ones(nc, 1) * type, 'int32', 0, 'b');
    fprintf(fid, '\n');
    
    fprintf(fid, 'CELL_DATA %d\n', nc);
    np = numel(data);    
    for i = 1:np
        fprintf(fid, ['SCALARS ', name{i}, ' float\n']);
        fprintf(fid, 'LOOKUP_TABLE default\n');
        
        % Convert to single-precision float and write in binary format
        fwrite(fid, single(data{i}), 'float', 0, 'b');
        fprintf(fid, '\n');
    end    
    fclose(fid);
end

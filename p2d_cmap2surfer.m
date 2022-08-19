function out = p2d_cmap2surfer(fname, clr, sz)
% author: Ainray
% date: 20220817
% bug-report: wwzhang0421@163.com
% introduction: export cmap for Surfer
% modify:
n = size(clr, 1);

if nargin < 3
   sz = n;
end

% Initialize variable for Surfer colormap
%reduce to 101 samples
sawtooth_surfer=zeros(sz, 5);

% Make Surfer colormap
% add R,G,B columnns
xx = (1:1:sz)';
xxn = normalab(xx, 0, 100);
for i=1:3 
    sawtooth_surfer(:,i+1)=round(interp1(xxn, clr(:,i),linspace(1, 100, sz)')*255);
end

% add counter and alpha (opacity) columns
sawtooth_surfer(:,1)=linspace(0,100, sz);
sawtooth_surfer(:,5)=ones(sz,1)*255;

% Create output file 
filename = [fname, '.clr'];
fileID=fopen(filename,'wt');

%  Write Surfer colormap header
fprintf(fileID,'ColorMap 2 1\n');
fclose(fileID);

% Add the colormap:
dlmwrite(filename, sawtooth_surfer,'precision',5,'delimiter','\t', '-append');

out = sawtooth_surfer;
function x = time2depthinv(ts, vec, segtime)
% function x = time2depthinv(x, vec)
% author: ainray
% date: 2021124
% email: wwzhang0421@163.com
% modified: 20211124, support layered constat velocity model

% introducton: convert depth to time with specified velocity model.
% input: 
%         x, point
%       vec, velocity model
%     depth, layer thickness
% output: 
%         t, time ticks

if(nargin<3 || isempty(segtime)) % constant model
    x = ts/vec;
else %layered model
    x=zeros(size(ts));
    n = length(vec);
    if(length(segtime) < n-1)
        error('duration dimension: too few duration'); 
    end
    nj = size(ts,2);
    for j=1: nj
        xx = ts(:,j);
        offset = 1;
        xstart = 0;
        tstart = 0;
        for i=1:n-1
            dx0 = segtime(i)*vec(i); 
            dx = dx0 + xstart;  
            k = find(xx > dx, 1, 'first');
            if(isempty(k)) % to end
               x(j,offset:end) = tstart+(xx(offset:end)-xstart)/vec(i);
               return;
            end
            x(j,offset:k-1) = tstart + (xx(offset:k-1)-xstart)/vec(i);
            tstart = tstart + segtime(i);
            xstart = dx;
            offset = k;
        end
        x(j,offset:end) = xx(offset:end)/vec(n);
    end
end

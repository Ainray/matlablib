function x = maet_time2depth(time, vec, depth)
% function x = maet_time2depth(time, vec)
% author: ainray
% date: 20200821
% email: wwzhang0421@163.com
% modified: 20200821, create, current only for constant velocity
%           20200912, add layered constat velocity model

% introducton: convert time series to depth with specified velocity model.
% input: 
%      time, time ticks
%       vec, velocity model
%     depth, layer thickness
if(nargin<3) % constant model
    x = time*vec;
else %layered model
    x=zeros(size(time));
     n = length(vec);
    if(length(depth) < n-1)
        error('depth dimension: too few layer thickness'); 
    end
    %dt = depth(1:n-1)./vec(1:n-1); % the first n-1 layers
    offset = 1;
    tstart = 0;
    xstart = 0;
    for i=1:n-1
        dt0 = depth(i)./vec(i);  % duration of current layer
        dt = dt0 + tstart;       % total duration 
        k = find(time > dt, 1, 'first');
        if(isempty(k)) % to end
           x(offset:end) = xstart+(time(offset:end)-tstart)*vec(i);
           return;
        end
        x(offset:k-1) = xstart + (time(offset:k-1)-tstart)*vec(i);
        xstart = xstart + depth(i);
        tstart = dt;
        offset = k;
    end
    x(offset:end) = time(offset:end)*vec(n);
end

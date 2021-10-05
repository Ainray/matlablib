function s = em_source_trap(delay, uprize, ontime, downrize, amp, t)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: calculate trapezoidal source

s = zeros(size(t));
t0 = delay;
if(t(end)>=t0)
    indx = t>=t0;
    s(indx) = amp/uprize*(t(indx)-t0);
    
    t0 = delay+uprize;
    if(t(end)>=t0)
        indx = t>=t0;
        s(indx) = amp*ones(size(t(indx)));

        t0 = delay+uprize+ontime;
        if(t(end)>=t0)
            indx = t>=t0;
            s(indx) = amp - amp/downrize*(t(indx)-t0);

            t0 = delay+uprize+ontime + downrize;
            if(t(end)>=t0)
                indx = t>=t0;
                s(indx) = 0;
            end
        end
    end
end
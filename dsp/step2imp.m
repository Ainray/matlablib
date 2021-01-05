function imp=step2imp(step,dt)
%function step2imp(step,dt)
imp=diff(step(:));
imp=[imp;imp(end)];
imp=imp/dt;
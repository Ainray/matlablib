function [B, A]=notch_2nd1(w, bw)
% refer to : The scientist Engineer's Guide to Digital Signal Processing,
% Steven W. Simth, 1997

r = 1 - 3*bw;
alpha = cos(w);
k = (1 - 2*r*alpha + r*r)/(2 - 2*alpha);

A = [1 -2*r*alpha r*r]';
B = [k -2*k*alpha k]';
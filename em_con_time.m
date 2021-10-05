function [t, a] = em_con_time(epsilonr, sigma, r)
% author: Ainray
% date: 20210921
% email: wwzhang0421@163.com
% introduction: esitmate time range for transient field in conductive media

mu = 4*pi*1e-7;
epsilon0 = 1/36/pi*1e-9;

epsilon = epsilon0 * epsilonr;
if sigma < eps
    tau2 = 0;
else
    tau2 = 2 * epsilon / sigma;
end
t2 = mu * epsilon * r * r;

t = sqrt(t2 + tau2);
a = tau2;
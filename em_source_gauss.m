function s = em_source_gauss(t0, t, amp, order)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: calculate specified order derivate of gauss source
%   t0 = 2e-9; 
    if(nargin < 4)
        order = 0;
    end
    switch(order)
        case 0
            s = gauss_src(t0, t, amp);
        case 1
            s = gauss_src(t0, t, amp).*(-2*(t-3*t0)/t0/t0); 
        case 2
            s = gauss_src(t0, t, amp).*(4*(t-3*t0).^2/t0^4 - 2/t0/t0);
        case 3
            s = gauss_src(t0, t, amp).*((-2*(t-3*t0)/t0/t0).^3+12*(t-3*t0)/t0^4);
    end
end

function g = gauss_src(t0, t, amp)
%      t0 = 2e-9; 
%      g = 10^-10*exp(-(t-3*t0).^2/t0^2);
	g = amp*exp(-(t-3*t0).^2/t0^2);
end
% function y=synresp(x,h,isstep,n)
% author: Ainray
% date: 20160315
% modified: 20201216, support both impulse and step 
% bug-report: wwzhang0421@163.com
% information; synthesizing MTEM voltage reponse from impulse response or step response,
%   inputs:
%       x, input signal
%       h, type I, impulse response
%          type II, step response, for step respnse with non-zero initial
%                   value, integral of impulse response do not give step response
%                   due the costant, so step response should be given explicitly
%          type III, especially for non-contious input, like prbs
%     type, 0 for I, 1 for II, 2 for III
%       n, truncated y
function [y,t]=mtem_synresp(x, fs, ps, offset, type, n)
narginchk(4,6);
x=x(:);
if(nargin<5)
    type = 0;
end
if(nargin<6)
    type = 1;
end
switch type
    case 0 % impulse
        g = analyticimpulse(ps, offset, fs);
        y = fconv(x,g,n);
        y = y + rho/pi/offset^3;
        t=time_vector(x,fs);
    case 1 % step
        h = analyticstep(ps, offset, fs, time_vector(x,fs));
        dx = diff([0;x(:)]);
        
end
% if nargin<5
%     n=length(x)+length(h)-1;
% end
% if nargin<4
%     type = 0; % default impulse
% end
% if nargin<3
%     fs=1;
% end
% dt=1/fs;
% 
% if type==0
%     y=fconv(x,h)*dt;
% elseif(type == 1)
%     dx=diff(x);dx=[dx(:);dx(end)];
% %     dx=diff([0;x(:)]); % !!! error
%     y=fconv(dx,h);
%     y(1:length(h))= y(1:length(h)) + h(:)*x(1);
%     y(1:length(x))= y(1:length(x)) - x(:)*h(1);
% else
%     mx = max(x);
%     dx=diff([0;x(:)]);
%     indx = find(abs(dx)>0.8*mx);
%     y = zeros(size(x));
%     for i=1:length(indx)
%         if(i<length(indx))
%             indx0 = indx(i):indx(i+1)-1;
%         else
%             indx0 = indx(i):length(y);
%         end
%         for j=1:i
%            ss=h(indx0-(indx(j)-1));
%            y(indx0) = y(indx0) + dx(indx(j)) * ss(:);
%         end
%     end
% %     y=[y(2:end);y(end)];
% end
% y=y(1:min(n,length(y)));
% t=time_vector(y,fs);
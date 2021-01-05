% function y=synresp(x,h,isstep,n)
% author: Ainray
% date: 20160315
% modified: 20201216, support both impulse and step 
% bug-report: wwzhang0421@163.com
% information; synthesizing reponse from impulse response or step response
%   inputs:
%       x, input signal
%       h, type I, impulse response
%          type II, step response, for step respnse with non-zero initial
%                   value, integral of impulse response do not give step response
%                   due the costant, so step response should be given explicitly
%          type III, especially for non-contious input, like prbs
%     type, 0 for I, 1 for II, 2 for III
%       n, truncated y
function [y,t]=synresp(x,h,fs,type,n)
x=x(:);
h=h(:);
if nargin<5
    n=length(x)+length(h)-1;
end
if nargin<4
    type = 0; % default impulse
end
if nargin<3
    fs=1;
end
dt=1/fs;

if type==0
    y=fconv(x,h)*dt;
elseif(type == 1)
    dx=diff(x);dx=[dx(:);dx(end)];
%     dx=diff([0;x(:)]); % !!! error
%     dx=diff([0;x(:);0]);
    y=fconv(dx,h);
    y(1:length(h))= y(1:length(h)) + h(:)*x(1);
    y(1:length(x))= y(1:length(x)) - x(:)*h(1);
else
    mx = max(x);
    dx=diff([0;x(:)]);
    indx = find(abs(dx)>0.2*mx);
    y = zeros(size(x));
    for i=1:length(indx)
        if(i<length(indx))
            indx0 = indx(i):indx(i+1)-1;
        else
            indx0 = indx(i):length(y);
        end
        for j=1:i
           ss=h(indx0-(indx(j)-1));
           y(indx0) = y(indx0) + dx(indx(j)) * ss(:);
        end
    end
%     y=[y(2:end);y(end)];
end
y=y(1:min(n,length(y)));
t=time_vector(y,fs);

% function y=synresp(x,h,n,isstep)
% if nargin<3
    % n=length(x)+length(h)-1;
% end
% if nargin<4
    % isstep=false;
% end
% if ~isstep
    % y=fconv(x,h);
% else
    % dx=diff([0,v2row(x),0]);  % the fisrt and last zero indicating staring and stopping
                              % % of source current input
    % y=fconv(dx',h); 
% end
% y=y(1:min(n,length(y)));
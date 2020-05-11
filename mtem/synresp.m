% function y=synresp(x,h,isstep,n)
% author: Ainray
% date: 20160315
% bug-report: wwzhang0421@163.com
% information; synthesizing reponse from impulse response or step response
% 
function [y,t]=synresp(x,h,fs,isstep,n)
if nargin<5
    n=length(x)+length(h)-1;
end
if nargin<4
    isstep=false;
end
if nargin<3
    fs=1;
end
dt=1/fs;
if ~isstep
    y=fconv(x,h)*dt;
else
    dx=diff([0,v2row(x)]);  % the fisrt and last zero indicating staring and stopping
                              % of source current input
    hh=[v2col(h);ones(length(dx)-1,1)*h(end)];
    y=fconv(dx',h)*dt-x(1)*hh;
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
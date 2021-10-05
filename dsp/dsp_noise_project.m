function [s, n] = dsp_noise_project(x, w)
% [s, n] = dsp_noise_project(x, w)
% author: Ainray
% date: 20210922
% email: wwzhang0421@163.com
% introduction: project a signal into real signal and noise by using sinusoidal bases
%        x, signals are arranged by columns
%        w, digital notch frequency and its harmonics

nw=length(w);   % hormonics
nw2=nw*2;       % sin and cos

m = length(x);

if m<nw2        % at least twice of number of hormonics
    error('no enough data for projection');
end
  
% base matrix
P0=zeros(m,nw2);
for i=1:nw
    P0(:,i*2-1:i*2)=[cos((0:m-1)'*w(i)) sin((0:m-1)'*w(i))];
end   
n=P0*(pinv(P0'*P0)*P0'*x);          % noise
s = x -n;                         % signal
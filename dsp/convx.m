function [y,ny]=convx(x,h,nx,nh)
% conv with shifted abscisca

n1=nx(1)+nh(1)+1;
n2=nx(end)+nh(end);
ny=[n1,n2];
y=fconv(x,h);
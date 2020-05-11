%funciton h=winrect(len,pass)
% author: Ainray
% date: 20151021
% bug report: wwzhang0421@163.com
% introduction: rectangle moving average filter 
% input:
%      tail, number of samples of the tail 
%     width, number of samples of window 
%      pass, times of passing rectangle filter:1,2,4
% output: 
%        h, the filter kernel
function h=winrect(tail,width,pass)
if nargin<3
    pass=1;
end
if mod(width,2)~=1
%     width=input('The filter length must be odd');
    width=width+1;
end
%rectangle filer
% len=2*tail+width;
rect=[zeros(tail,1);ones(width,1);zeros(tail,1)]/width;

%convlution
while(pass~=1 && pass~=2 && pass~=4)
    pass=input('pass must be 1, 2 or 4:  ');
end
switch(pass)
    case 1
        h=rect;
    case 2
        r2=fconv(rect,rect);
%         [r2max,indx]=max(r2);
%         h=r2(indx-(len-1)/2:indx+(len-1)/2);
        h=r2;
    case 4
        r2=fconv(rect,rect);
        r4=fconv(r2,r2);
%         [r4max,indx]=max(r4);       
%         h=r4(indx-(len-1)/2:indx+(len-1)/2); 
         h=r4;
end

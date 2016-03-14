%funciton y=movingavgfilter(x,N)
% author: Ainray
% date: 20151021
% bug report: wwzhang0421@163.com
% introduction: recursive algorithm of moving average filter
% input:
%      x, the input
%      N, the number of points for averaging
% output: 
%      y, the filter output
function y=movingavgfilter(x,N)
while(mod(N,2)~=1)
%     N=input('The number of avering smaples must be odd: ');
      N=N+1;
end
y=zeros(size(x));
% y(1:(N-1)/2)=x(1:(N-1)/2);  the tails are not dealed with.
if N>5
    for i=1:(N-1)/2
        y(i)=sum(x(max(1,i-2):i+2))/(i+3-max(1,i-2));  % 5-point moving average
    end
end
acc=sum(x(1:N));   % the (N+1)/2
y((N+1)/2)=acc/N;
for i=(N+3)/2:length(x)-(N+1)/2
    acc=acc+x(i+(N+1)/2)-x(i-(N-1)/2);
    y(i)=acc/N;
end
if N>5
    for i=length(x)-(N-1)/2:length(x)
        y(i)=sum(x(i-2:min(i+2,length(x))))/(min(i+2,length(x))-i+3); % 5-point moving average
    end 
end
% y(length(x)-(N-1)/2:length(x))=x(length(x)-(N-1)/2:length(x));
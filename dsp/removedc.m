%function y=removedc(x,ssn)
% Author: Ainray
% date: 20151203
% bug-report: wwzhang0421@163.com
% introduction: The program move dc segment-by-segment
%    input: 
%          x, the input
%        ssn, the segment information
%             -----------------------------------------
%             ssn(1)        ssn(2)       ssn(3)
%             start         step    number of segments
%             -----------------------------------------
%             the setp is critical, it must not be small, where the result will
%             near zero everywhere; it must not be large, where the result
%             will still have a varied dc component. In PRBS, the step can 
%             be 2~3 times of one period.
%  output:
%         y, the output
%        dc, a vetor fo dc components, if all the segment juat exactly cover the entire input, 
%            then the ast element is meaningfulless, last element of input
function [y,dc,ssn]=removedc(x,ssn)
N=length(x);
if nargin<2
	ssn=[1,N,1];
end
start=1;  % start
step=ssn(2);   % step
if step>=N
    number=1;
else
    number=min(floor(N/step),ssn(3)); % number of segments
end
dc=[];
y=x;
 for i=1:number % number is the times of calculating impules    
    end_=start+step-1;
    if end_>N && i==1
        end_=N;
    end
	if end_<=N
		dctmp=mean(x( start:end_));
        dc=[dc,dctmp];
		y(start:end_)=x( start:end_)-dctmp;
        start=start+step;
    end
 end
 
if N>i*step  % the last segment
	dctmp=mean(x( start:end));
	dc=[dc,dctmp];
	y(start:end)=x(start:end)-dctmp;
end

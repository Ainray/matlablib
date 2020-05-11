%function y=removedc(x,ssn)
% Author: Ainray
% date: 20151203
% bug-report: wwzhang0421@163.com
% introduction: The program move dc segment-by-segment
%    input: 
%          x, the input,can be multichannel signal
%        ssn, the segment information
%             --------------------
%             ssn(1)        ssn(2)
%             start         step    
%             --------------------
%             the setp is critical, it must not be small, where the result will
%             near zero everywhere; it must not be large, where the result
%             will still have a varied dc component. In PRBS, the step can 
%             be 2~3 times of one period.
%  output:
%         y, the output
%        dc, a vetor fo dc components, if all the segment juat exactly cover the entire input, 
%            then the ast element is meaningfulless, last element of input
function [y,dc]=removedc(x,ssn)
x=v2col(x);
oldx=x; % save origal signal

N=length(x);
if nargin<2
	ssn=[1,N,1];
end

start=ssn(1);  % start
step=ssn(2);   % step

if start>N  % large start
	error('access violation: start index is large');
else
	x=x(start:end); % cut head: assume the start is always 1.
	N=length(x);
end

if step>=N      % large step
	step=N;
    number=1;
else
    number=floor(N/step); % number of segments
end

N0=N;
if number*step<N % not exactly cover
	number=number+1;
	N=number*step;
	m=equalen({x},N);
	x=m;
end
	
dc=[]; % alloc array for direct value

for i=1:number
	start_=(i-1)*step+1;
	end_=i*step;
	dctmp=ones(step,1)*mean(x(start_:end_));
	dc=[dc;dctmp];
end
y=x-dc;
y=[oldx(1:start-1);y(1:N0)];
dc=[repmat(mean(oldx(1:start-1)),start-1,1);dc(1:N0)];

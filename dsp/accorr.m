function  [r,b,rr,bb]=accorr(x,y,type,n)
% function  [r,b]=accorr(x,y,type,n)
% version 2.0
% author: Ainray
% date: 20160324, 20170525
% bug-report: wwzhang0421@163.com
% introduction: calculating biased auto/cross correlation 
%               x is shifted by the assumption
%   input: x, the input 
%          y, the observed data, also the desired output here
%          n, the length of impulse reponse
%       type, 1 general/linear  correlation
%             2 circular correlation of zero-padding x
%             3 circular correlation
%    test example:
%         [r,b]=accorr([1:5,1:5],[1:5,1:5],10,[1,5,2]);
if nargin<3
    type=1; % linear is the default
end
switch type
    case 1                  % linear correlation: y is the linear convolution: x*h
        rr=fxcorr(x,x);      % the cross correltion is linear correlation with: y,x
        bb=fxcorr(y,x);      % the auto correlation is linear correlation with x-self
%       r=r(length(x):end); % after transformlation, the convolution is still linear
%       b=b(length(x):end); %   Ryx(tao)=h(lamda)Rxx(tao-lamda) (summing over lamda)
                            % but the autocorrelation is symmetric, the convolution 
                            % is start from -(Nx-1), if we only conern the impulse peak
                            % we can exclude the the first Nx-1 samples of cross correlation 
        r=rr(length(x):end);
        b=bb(length(x):end);
    case 2
        x=equalen({x},length(y));           
        r=fcxcorr(x);                       % first padding x with zero
        b=fcxcorr(y,x);                     % then circular correlation
                                            % so y is still the linear convoution
        rr=0;
        bb=0;
    case 3
        cy=lconv2c(y,length(x),n);          % y is the peroidic covolution 
        r=fcxcorr(x,x);                     % after 
        b=fcxcorr(cy,x);
        rr=0;
        bb=0;
end
% version 1.0
% % author: Ainray
% % date: 20160324
% % bug-report: wwzhang0421@163.com
% % introduction: calculating biased auto/cross correlation by calling xcorr
% %               for suprress noise, take divide-average scheme.
% %   input: x, the input 
% %          y, the observed data, also the desired output here
% %          n, the length of impulse reponse
% %    test example:
% %         [r,b,rxx,rxy]=accorr([1:5,1:5],[1:5,1:5],10,[1,5,2]);
% %         rxx/rxy return the same result with xcorr([1:5]);
% if nargin<2
%     y=x;
% end
% if nargin<3
%     n=10^20;  % a large number
% end
% m=equalen({x,y}); % let both series be of equal length
% x=m(:,1);y=m(:,2); 
% 
% L=size(m,1);  % the length
% 
% if nargin<4
%     ssn=[1,L,1];
% end
% start=ssn(1);  % start
% step=ssn(2);   % step
% 
% if start>L  % large start
% 	error('access violation: start index is large');
% else
% 	x=x(start:end); % cut head: assume the start is always 1.
% 	y=y(start:end);
% 	L=length(x);
% end
% 
% if step>L  % large step
%     step=L;
%     number=1;
% else
%     number=min(floor((L-start+1)/step),ssn(3)); % number of segments
% end
% 
% if number*step<L % not exactly cover
%     L=(number+1)*step;
%     m=equalen({x,y},L);
%     number=number+1;
% end
% 
% x=m(:,1);
% y=m(:,2);
% 
% % alloc matrix for auto/cross correlations
% 
% rxx=zeros(step*2-1,number);
% rxy=zeros(step*2-1,number);
% % rxx=zeros(step,number);
% % rxy=zeros(step,number);
% 
% for i=1:number % number is the times of calculating impules
%     start=(i-1)*step+1;
%     end_=i*step;
%     rxx(:,i)=v2col(xcorr(x(start:end_),x(start:end_)));   % auto-correlation
%     rxy(:,i)=v2col(xcorr(y(start:end_),x(start:end_)));	  % cross-correlation(y,x)
% %      rxx(:,i)=v2col(fcxcorr(x(start:end_),x(start:end_)));   % auto-correlation
% %      rxy(:,i)=v2col(fcxcorr(y(start:end_),x(start:end_)));	  % cross-correlation(y,x)
% end
% 
% rxx=mean(rxx,2);
% rxy=mean(rxy,2);  % mean
% 
% N=min(n,step); % length of EIR
% 
% M=step; % maximum
% 
% r=rxx(M:M+N-1);
% b=rxy(M:M+N-1);
% 
% % Normalization
% % r(1)=max(abs(r(1)),eps);
% % b=b/r(1);r=r/r(1); 
% 

 
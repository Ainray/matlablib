function ends=prbsends(fe,order,fs,cycle,idlen)
% date:20170524
% author: Ainray
% email:wwzhang0421@163
% introduction: because the sampling interval not factorial of the entire period duration
%               so there will have different number (1 more than) of samples per period.
%               this function return the ends of per periods
if nargin<5
    idlen=0;
end
N=2^order-1;
ends=floor(N*(1:cycle)'/fe*fs)+idlen*(1:cycle)';
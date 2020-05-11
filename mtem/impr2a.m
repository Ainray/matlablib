function ag=impr2a(g,r,tp,fs)
% function ag=impr2a(g,r,tp,fs)
% author:Ainray
% date: 20160719
% email: wwzhang0421@163.com
% introduction: calculating analytic homogneouse impulse response with 
%               the same peak as the real impulse reponse 'g'.
%       input:
%              g, real impulse response, array or matrix
%              r, offset, scalar or array
%             tp, peak time
%             fs, 
%      output:
%             ag, analytic homogeneous impulse response,array or matrix

ap=4*3.141592653589793*r*r*1e-8/(tp); 
N=size(g,1);
ag=analyticimpulse(ap,r,fs,N); % anayltic EIR
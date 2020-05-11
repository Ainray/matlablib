function [h,H,invF,F,r,b]=fcorrdeconv(x,y,type,varargin)
% [h,H,invF,F,r,b]=fcorrdeconv(x,y,type,varargin)
% author: Ainray
% date: 2017/05/29
% bug report: wwzhang0421@163.com
% introduction:  deconvolution in the frequency domain, H(jw)=Y(jw)/X(jw)
% reference :
%      [1] The deconvolution problem: an overview, Sedki M. Riad, 1986               
%      [2] Ziolkowski A.,2007, Multitransient electromagnetic demonstration survey in France
%      [4] Pesce K. A., 2010, Comparison of receiver function deconvolution techniques.
%      [5] http://cnx.org/contents/BCzesWfo@2/Deconvolution-with-  
%  input:
%           x, the source signature, i.e., the input 
%           y, the observation, i.e., the output
%        type, filter("F") type as regularization
%              H=Y/X
%               =Y*X'/|X|^2
%              <=>Y*X'/(|X|^2+F), damping factor
%               =Y/X/[1/(1+F/|X|^2)], 
% output:
%           h, the estimated impulse response
%           H, the linear spectum of estimated impulse response
%        invF, the inverse filter in the freqency domain, H=invF.*Y%              
%           F, regularized filter
%           r, auto correlation of x
%           b, cross correlation of y and x

    m=equalen({x,y});  %padding zeros if necessary
    x=m(:,1); y=m(:,2);
    N=length(x);
   
    L=2^nextpow2(2*N);
    X=fft(x,L);
    Y=fft(y,L); 
    absX2=abs(X).*abs(X);
    if nargin<3           % no filtering
        type=0;
    end 
    switch(type)
        case 0
            F=zeros(L,1);
        case 1
            alpha=varargin{1};
            F=alpha*ones(L,1);
        case 2  %water level
             alpha=varargin{1};
             F=zeros(L,1);
             F(alpha>absX2)=alpha;
        case 3 %
             alpha=varargin{1};
             F=zeros(L,1);
             F(abs(X)<alpha)=alpha*X(abs(X)<alpha)-absX2(abs(X)<alpha);
        case 4   % Wiener filter
            n=varargin{1};
            alpha=varargin{2};
            N=fft(n,L);
            X = X.*(abs(X)>0)+eps.*(abs(X)==0); % in case of dividing zero
            F=N.*conj(N)./absX2*alpha;           
    end
    % calculating the inverse filter in the frequency domain
    den=absX2+F;
    num=Y.*conj(X);
    invF=conj(X)./den;
    r=real(ifft(absX2));
    b=real(ifft(num));
    
    r=[r(L-N+2:L);r(1:N)];      % the positively lagged items
    b=[b(L-N+2:L);b(1:N)];      % the negtively lagged items
    
    H=num./den;
    h=real(ifft(H));
%   h=h(1:N);     
    
   
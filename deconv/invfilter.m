%function h=invfilter(x,y,water_level,len)
% author: Ainray
% date: 2015/7/28
% modified: 2015/10/28
% bug report: wwzhang0421@163.com
% introduction:  deconvolution in the frequency domain, setting a water
%                level for zeros of the spectrum of input.
% reference:
%      [1] Ziolkowski A.,2007, Multitransient electromagnetic demonstration survey in France
%      [2] Pesce K. A., 2010, Comparison of receiver function deconvolution techniques.
%      [3] http://cnx.org/contents/BCzesWfo@2/Deconvolution-with-Inverse-and
% input: 
%           x, the source signature, i.e., the input 
%           y, the observation, i.e., the output
% water_level, the water level for thredhold value of the spectrum of the input
%      method, Three methods of setting the threshold:
%              'plus',  entire spectrum is added with a dampling factor, with the inverse filtering 
%                       of:  
%                                    invFilter(f)=conj(X(f))/(abs(X(f))^2+water_level)
%              'level', when the value of sepctrum is less than water_level, just
%                       be replacing with water_level, with the inverse filtering of:
%                                                    { conj(X(f))/abs(X(f))^2,   if abs(X(f))< water_level
%                                    invFilter(f)(f)={
%                                                    { conj(X(f)/water_level,    else             
%                       
%         len, optional, the length of impulse length after truncation
% output:
%           h, the estimated impulse response
function h=invfilter(x,y,water_level,method,len)
    if nargin<3
        method='plus';
    end
    while ~strcmp(method,'plus') && ~strcmp(method,'level')
        method=input(['The method setting water level support two values: ',...
            '''plus'' ','''level''' ]);
    end
    N=2^nextpow2(max(length(x),length(y)));
    if nargin<4
        len=N;
    end
    % the DFT of input and output  
    X=fft(x,N);
    Y=fft(y, N);   
    
    % the inverse filter in the frequency domain
    absX2=abs(X).*abs(X);
    if strcmp(method,'plus')
        F=conj(X)./(absX2+water_level);
    else
        F=conj(X)./(absX2.*(absX2>water_level)+water_level*(absX2<water_level));
    end
    % the frequency response
    H=F.*Y;
    % reback to time domain, obtainning the impules response
    h=real(ifft(H,N));
    
    %truncatation
    h=h(1:len);
   
%function h=anton(x,y,water_level,len)
% author: Ainray
% date: 2015/7/28
% modified: 2015/10/28
% bug report: wwzhang0421@163.com
% introduction:  deconvolution in the frequency domain, setting a water
%                level for zeros of the spectrum of input.
% reference:
%      [1] Ziolkowski A.,2007, Multitransient electromagnetic demonstration survey in France
%      [2] Pesce K. A., 2010, Comparison of receiver function deconvolution techniques.
% input: 
%           x, the source signature, i.e., the input 
%           y, the observation, i.e., the output
% water_level, the water level for thredhold value of the spectrum of the input
%         len, optional, the length of impulse length after truncation
% output:
%           h, the estimated impulse response
function h=anton(x,y,water_level,len)
    N=2^nextpow2(max(length(x),length(y)));
    if nargin<4
        len=N;
    end
    % the DFT of input and output  
    X=fft(x,N);
    Y=fft(y, N);   
    
    % the inverse filter in the frequency domain
    F=conj(X)./(abs(X).*abs(X)+water_level);
    
    % the frequency response
    H=F.*Y;
    % reback to time domain, obtainning the impules response
    h=real(ifft(H,N));
    
    %truncatation
    h=h(1:len);
   
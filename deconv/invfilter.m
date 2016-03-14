%function [h,invF]=invfilter(x,y)
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
%           (optional parameter-value pairs)
%           'Level', water_level
%           'Method', 'plus'
%           'Length', len
%           'Gauss', flase;
%           'GaussLamda',0.5
%           'PolyFit',false
%           'PolyFitOrder',1
%           
%           
%           'Level',    water_level
%                       the water level for thredhold value of the spectrum 
%                       of the input
%           'Method',   'plus' or 'replace','third'
%                       method, Three methods of setting the threshold:
%                           'plus',     entire spectrum is added with a dampling 
%                                       factor ,with the inverse filtering of:  
%             invFilter(f)=conj(X(f))/(abs(X(f))^2+water_level)
%                           'replace',  when the value of sepctrum is less than water_level,
%                                       just be replacing with water_level, with the
%                                       inverse filtering of:             
%                          { conj(X(f))/abs(X(f))^2,   if abs(X(f))> water_level
%             invFilter(f)={
%                          { conj(X(f)/water_level,    else             
%                          'third',
%                          { 1/X(f),   if abs(X(f))> water_level
%             invFilter(f)={
%                          {|X(f)|/X(f)/water_level   
%           'Length',   len
%                       the length of impulse length after truncation       
%           'Gauss',    flase
%                       whether applying gaussian filter or not
%           'GaussLamda',0.5 
%                       gaussian filtering parameter, refer to 'dft_gauss' 
%           'PolyFit',   false
%                       whether polyfitting the impulse or not
%           'PolyFitOrder',  1
%                       the order of polynomial
% output:
%           h, the estimated impulse response
%        invF, the inverse filter in the freqency domain.

function [h,invF]=invfilter(x,y,varargin)
    p=inputParser;
    
    addRequired(p,'x',@isnumeric);
    addRequired(p,'y',@isnumeric);
    addOptional(p,'Level',0.1,@isnumeric);
    addOptional(p,'Method','plus',@isstr);
    addOptional(p,'Length',16000,@isnumeric);
    addOptional(p,'Gauss',false, @islogical);
    addOptional(p,'GaussLamda',0.5,@isnumeric);
    addOptional(p,'PolyFit',false,@islogical);
    addOptional(p,'PolyFitOrder',1,@isnumeric);
    parse(p,x,y,varargin{:});
    
    water_level=p.Results.Level;
    method=p.Results.Method;
    len=p.Results.Length;
    isgauss=p.Results.Gauss;
    lamda=p.Results.GaussLamda;
    ispolyfit=p.Results.PolyFit;
    polyfitorder=p.Results.PolyFitOrder;
    
    while ~strcmp(method,'plus') && ~strcmp(method,'level') &&~strcmp(method,'third') 
        method=input(['The method setting water level support three values: ',...
            '''plus'' ','''level''','''third''','\n' ]);
    end
%     N=2^nextpow2(max(length(x),length(y)));
    N=max(length(x),length(y));
%     if nargin<5
%         len=N;
%     end
%     if nargin<6
%         isgauss=false;
%     end
%     if nargin<7
%         lamda=0.25;
%     end
    % the DFT of input and output  
    X=fft(x,N);
    Y=fft(y, N);   
    
    % the inverse filter in the frequency domain
    absX2=abs(X).*abs(X);
    if strcmp(method,'plus')
        F=conj(X)./(absX2+water_level);
%         F=conj(X)./(abs(X).*abs(X)+water_level);
    elseif strcmp(method,'level')
        F=conj(X)./(absX2.*(absX2>=water_level)+water_level*(absX2<water_level));
    else  %still water level, similarly
        % handle singular case (zero case)
        X = X.*(abs(X)>0)+eps.*(abs(X)==0);
        % invert Hf using threshold water_level
        F =conj(X)./(absX2.*(abs(X)>=water_level)+water_level*abs(X).*(abs(X)<water_level));
    end
    invF=F;%real(ifft(F,N));
    % the frequency response
    H=F.*Y;
    
    % Gaussian filter, the default filter paramter is 0.25, i.e., the cut-off 
    % frequency is set to be 0.125*16000=2000Hz
    if isgauss
        G=dft_gauss(N,lamda,'one-side');
        H=H.*G;
    end
    % reback to time domain, obtainning the impules response
    h=real(ifft(H,N));
    h=inversephase(h);
    if ispolyfit
        hp=h;
        warning('off','all');
        [mms,fmax]=peak(hp);
        if fmax>1
            ii=(mms(fmax+1):floor(N*0.6))';
            p=polyfit(ii,hp(ii),polyfitorder);
            yp=polyval(p,ii);
            hp(ii)=yp;
            iii=(ii(1)-20:ii(1)+20)';
            p=polyfit(iii,hp(iii),2);
            hp(iii)=polyval(p,iii);
        end
        warning('on','all');
    h=hp;
    end
    %truncatation
    h=h(1:len);
   
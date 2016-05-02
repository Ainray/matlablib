function y=selectivestack(x,varargin)
% author: Ainray
% date: 20160324
% bug-report: wwzhang0421@163.com
% introduction: selective stack based on different rule
% ------------------------------------------------------
%    y=selectivestack(x);
%    y=selectivestack(x,'Method','mean')
%    y=selectivestack(x,'Method','mean','MeanAlpha',0.4);
%    y=selectivestack(x,'Method','mean','MeanAlpha',0.4,'SigmaMul',1);
%    input:	
%           x, the input
%              (optional parameter-value pair)
%              'Method', 'std'/....
%                        std, just direct average
%                        mean, alpha-trimmed mean method
%                        mtem, special for mtem method, select more smooth EIR
%                             
%              'MeanAlpha', percentage of rejection from both ends of the sorted amplitudes,
%                           for calculating the preliminary Mean and STD
%              'SigmaMul', muptiple of STD to be kept for stacking
% 
%referenc: T. Watt, J.B. Bednar, Role of the alpha-trimmed mean in combining and
%          analyzing seismic commmon-depth-point gathers
%          K. M. Strack, Exploration with deep transient eletromagnetics
%          K. M. Starck, T.H. Hanstein, H.N. Eilenz, LOMTEM data processing for areas with higth cultural noise levels

p=inputParser;
addRequired(p,'x',@isnumeric);
addOptional(p,'Method','std',@(x) any(validatestring(x,{'std',...
    'mean','mtem'})));
addOptional(p,'MeanAlpha',0.3, @(x)  x>0 && x<0.4);
addOptional(p,'SigmaMul',1,@isnumeric);

parse(p,x,varargin{:});

method=p.Results.Method;
meanalpha=p.Results.MeanAlpha;
sigmamul=p.Results.SigmaMul;
switch method
    case 'std'
        y=mean(x,2);
    case 'mean'
         ls=size(x,2);
         if mod(ls,2)==0
             ls=ls+1;
         end
         [m,n]=size(x);
         tmp=sort(x,2);
         i_min=max(1,floor(meanalpha*ls));i_max=min(ls,ls-floor(meanalpha*ls));       
         mui=mean(tmp(:,i_min:i_max),2);
         sigma=std(tmp(:,i_min:i_max),0,2);
         for i=1:m
             sum=0;
             cc=0;
             for j=1:n
                 if abs(x(i,j)-mui(i))<=sigma(i)*sigmamul
                     sum=sum+x(i,j);cc=cc+1;
                 end
             end
             y(i)=sum/cc;
         end
%          upl=(mui+sigma*sigmamul)*ones(1,n);
%          downl=(mui-sigma*sigmamul)*ones(1,n);        
%          indx=find(upl>=x & x>=downl);  % check 2-sigma  
%          dindx=deselect(1:m*n,indx);     % uneffective elements
%          tmp=x;
%          tmp(dindx)=0;
%          y=mean(tmp,2);
    case 'mtem'
        sigma=std(x(1:end-2000,:));
        [mms,fmax]=peak(sigma);
        y=mean(x(:,mms(fmax:2:end)),2);
        % impulse
        % more large std, more smooth 
end
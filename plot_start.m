% function plot_start(x0,x1,fs,ratio,N,start_,varargin)
% author: Ainray
% date: 20160111
% bug-report: wwzhang0421@163.com
% introduction: plot mupliple lines for comparison.
%     input:
%           m, the line data, one colum per line  
%           (optional parameter-value pairs)
%
%           'SamplingRate',1    sampling rate 
%           'Ratio',1           scaling lines
%           'Length',1600       number of points per line
%           'Start',1           starting index of all lines 
%           'XScale','linear'   linear ('linear') or logarithmic('log') scaling for x axis  
%           'YScale','linear'   linear ('linear') or logarithmic('log') scaling for x axis       
%     output:
%           (none)

function plot_start(m,varargin)
   p = inputParser;
   defaultfs = 1;   % default sampling rate
   defaultratio=1;  % default sclaing ratio (scale or array)
   defaultlength=1600; % default length
   defaultstart=1;     % default starting point
   
   expectedscale={'linear','log'}; 
   defaultxscale='linear'; % default x axis scale.
   defaultyscale='linear'; % default y axis scale.
   
   addRequired(p,'m',@isnumeric);
   addOptional(p,'SamplingRate',defaultfs,@isnumeric);
   addOptional(p,'Ratio',defaultratio,@isnumeric);
   validlen=@(x) x==round(x) && isscalar(x) && (x>0);
   addOptional(p,'Length',defaultlength, validlen);
   addOptional(p,'Start',defaultstart, validlen);
   addOptional(p,'Xscale',defaultxscale,...
                 @(x) any(validatestring(x,expectedscale)));
   addOptional(p,'Yscale',defaultyscale,...
                 @(x) any(validatestring(x,expectedscale)));
   addOptional(p,'IsErr',0);
   parse(p,m,varargin{:});
   fs=p.Results.SamplingRate; 
   ratio=p.Results.Ratio;
   N=p.Results.Length;
   start_=p.Results.Start;   
   clr=['-r','-b','-c','-m','-y','-g','+r','og','*b','.c','xm','sy','dr'];
   if length(ratio)<size(m,2)
       ratio(length(ratio):size(m,2))=ratio(1);
   end
   
   if p.Results.IsErr
       subplot(2,1,2);
       plot([start_:start_+min(N,length(m(:,1)))-1]/fs,abs((m(start_:start_+min(N,length(m(:,1)))-1,2)-...
           m(start_:start_+min(N,length(m(:,1)))-1,1))./m(start_:start_+min(N,length(m(:,1)))-1,1))*100);
       subplot(2,1,1);
   end
   for j=1:size(m,2)
        plot([start_:start_+min(N,length(m(:,j)))-1]/fs,m(start_:start_+min(N,length(m(:,j)))-1,j)...
            *ratio(j),clr((j-1)*2+1:j*2),'linewidth',1,'MarkerSize',2.5);
%                , 'linewidth',1,'MarkerSize',2.5);
        hold on;
   end
   set(gca,'Xscale',p.Results.Xscale,'Yscale',p.Results.Yscale);
%     std=size(varargin,2);
%     
%     lr=length(ratio);
%     lc=0;
%     for i=1:std
%         lc=lc+size(varargin{i},2);
%     end
%     ratio(lr+1:lc+2)=ratio(1);
%     plot( [start_:start_+min(N,length(x0))-1]'/fs,x0( start_:start_+ min(N,length(x0))-1 ),'linewidth',1);
%     hold on;
%     plot([start_:start_+min(N,length(x1))-1]/fs,x1(start_:start_+min(N,length(x1))-1)*ratio(2),'-ok','linewidth',1,'MarkerSize',2);
%     set(gca,'Xscale',p.Results.Xscale,'Yscale',p.Results.Yscale);
% 
%     cc=0;
%     for i=1:std   
%         third=[];
%         third=varargin{i};
%         for j=1:size(third,2)
%             cc=cc+1;
%             plot([start_:start_+min(N,length(third(:,j)))-1]/fs,third(start_:start_+min(N,length(third(:,j)))-1,j)*ratio(2+cc),clr((cc-1)*2+1:cc*2)...
%                , 'linewidth',1,'MarkerSize',2.5);
%         end
%     end
% plot([1:N]/fs,x0(1:N)-mean(x0(1:N)));
% hold on;
% plot([1:N]/fs,(x1(1:N)-mean(x1(1:N)))*ratio,'r');
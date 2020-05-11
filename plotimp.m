function plotimp(imps,varargin)
% author: Ainray
% date: 20160311
% bug-report: wwzhang0421@163.com
% update date: 20160314, by Ainray
%              20160325, by Ainray
% version:1.2.1 
% introduction: function for ploting impulse in batch
% input:
%       imps, array of EIR structures ,  if 'CMP' mode is on, imps is 
%                    matrix of EIR structures, the same column has different
%                    frequencies but the same point.
%
%           (optional parameter-value pairs)
%      'Phase',+/-1                 flip the signal up and down, i.e., phase reverse
%      'NPlotPerPage',8             number of subplots per figure
%      'SamplingRate',16000         sampling rate
%      'Width', width,              the figure width
%      'Heigth',heigh,              the figure height
%      'Length',1600,               the length of displayed impulse
%       
%      'Xscale','log'/'linear'      the x axis scale
%      'Yscale','log'/'linear'      the y axis scale
%      'Xlabel',xlabel,             the x label
%      'Ylabel',ylabel              the y label
%      'Color', color               line type and color scheme
%      'Peak' false                 whether plot peak or not
%      'Cmp', false                 multiple frequcies or not
%      'Visibility', 'on'           whether the figure is visible
%      'Print',  false              whether export figure as jpeg or other format
%      'Format', '-jpg'             the exported image format
%      'Quality','-m3',             the resolution, '-m3' is for 64bit 
%                                   OS and more than 4GB memeory, If you 
%                                   run on 32-bit, '-m2' is recommend.
%      'Offset', 1                  the build-in nameing scheme for exported
%                                   image have a order number at the first, 
%                                   the default is always starting with 1
%                                   you change it by set 'Offset' by other value
%
%     'Fit', false                 whether plot fitting EIR or not

p=inputParser;

defnppp=12;              % default number of pictures per page
deffs=16000;            % default sampling rate
defwd=1440;             % default width
defh=900;               % default height
deflen=1600;            % default impulse length (samples)

expectedscale={'linear','log'}; 
defxscale='linear';     % default x axis scale.
defyscale='linear';     % default y axis scale.
defxlabel='Time (s)';
defylabel='Amplitude (\Omega/m^2/s)';
defclr={'r','b','g','m','k','y','c','w'}; 


addRequired(p, 'imps', @isstruct);
addOptional(p, 'Phase',1,@isnumeric);
addOptional(p, 'NPlotPerPage',defnppp,@isnumeric);
addOptional(p, 'SamplingRate', deffs, @isnumeric);
addOptional(p, 'Length', deflen,  @isnumeric);
addOptional(p, 'Width', defwd, @isnumeric);
addOptional(p, 'Height', defh, @isnumeric);
addOptional(p, 'Xscale', defxscale, @(x) any(validatestring(x,expectedscale)));
addOptional(p, 'Yscale', defyscale, @(x) any(validatestring(x,expectedscale)));
addOptional(p, 'Xlabel', defxlabel, @isstr);
addOptional(p, 'Ylabel', defylabel, @isstr);
addOptional(p, 'Color',  defclr, @iscell);
addOptional(p, 'Peak',false,@islogical);
addOptional(p, 'Cmp',false,@islogical);
addOptional(p, 'Visibility','on',@isstr);
addOptional(p, 'Print', false, @islogical)
addOptional(p, 'Format','-jpg',@isstr);
addOptional(p, 'Quality','-m3',@isstr);
addOptional(p, 'Offset',0,@isnumeric);
addOptional(p, 'Fit',false,@islogical);

parse(p,imps,varargin{:});

phf=p.Results.Phase; 
nppp=p.Results.NPlotPerPage;
len=p.Results.Length; 

width=p.Results.Width;
height=p.Results.Height;
fs=p.Results.SamplingRate;
clr=p.Results.Color;
xscale=p.Results.Xscale;
yscale=p.Results.Yscale;
xlabel=p.Results.Xlabel;
ylabel=p.Results.Ylabel;
visibility=p.Results.Visibility;
ispeak=p.Results.Peak;
iscmp=p.Results.Cmp;
isprint=p.Results.Print;
fmt=p.Results.Format;
qual=p.Results.Quality;
offset=p.Results.Offset;
isfit=p.Results.Fit;

%subplots layout
xyr=14.65/24.52*0.85;      	% A4, default size, no including margins
wd=height/width*xyr;        %normalized width: screen width is one
NA=size(imps,2);            % number of points
NF=ceil(NA/nppp);
% if NF >10
%     ch=input(['There will be ',num2str(NF),' figures being created.\nIt is '...
%             ,'recommended that you re-run:\n plotimp(imps,''Print'',true)\n'...
%           ,'Are you sure to exit(y/n): '],'s');
%     while ~strcmpi(ch,'y') && ~strcmpi(ch,'n')
%       ch=input(['There will be ',num2str(NF),' figures being created.\nIt is '...
%             ,'recommended that you re-run:\n plotimp(imps,''Print'',true)\n'...
%           ,'Are you sure to exit(y/n): '],'s');
%     end
%     if strcmpi(ch,'y')
%         return;
%     end
% end
if isprint
    subplotpos=zeros(1,4);
    srcsz=get(0,'ScreenSize');   %get screen size
    for k=1:nppp:NA
        imp=imps(k:min(k+nppp-1,NA));  %segment
        N=min(nppp,NA-k+1);
       hf= figure('Position',srcsz,'visible',visibility);
        ax=zeros(N,1);  
        if N>4
            row=ceil(N/2);	
            for i=1:N
        subplotpos(i,1)=(1-wd)*0.5+(1-mod(i,2))*0.5*wd; % x_start position
        subplotpos(i,2)=0.05+0.95/row*(row-ceil(i/2));% y_start position
        subplotpos(i,3)=0.44*wd;  %width
        subplotpos(i,4)=0.9/row; %height
        subplot(row,2,i);
    %     subplot(gcf,'Position',subplotpos);
        ax(i)=get(gcf,'CurrentAxes');  
            end
        else     % one column
            row=N;
            for i=1:N
                subplotpos(i,1)=(1-wd)*0.5; % x_start position
                subplotpos(i,2)=1/row*(row-i);% y_start position
                subplotpos(i,3)=wd;  %width
                subplotpos(i,4)=1/row;
                subplot(row,1,i);
                ax(i)=get(gcf,'CurrentAxes');
            end
        end

        for i=1:N 
            set(gcf,'CurrentAxes',ax(i)); hold on; 
            clegends=0;  % legends counter
            if iscmp
                M=imp(i,1).meta.num;
            else
                M=1;
            end
            for j=1:M
              if(isempty(imp(j,i).meta.rcvpos)==0)  % valid point
                     clegends=clegends+1;
                     lenlimit=imp(j,i).para.length;
                     maxlen=min(lenlimit,len);
                     ys=phf*imp(j,i).g(1:maxlen);
                     ts=imp(j,i).ts(1:maxlen);
                     h(j)=plot(ts,ys,clr{j},'linewidth',1.5);  
                     if ispeak                  
                         plot(ts(min(maxlen,imp(j,i).pn)),imp(j,i).apv,'or','MarkerFace','r');
                     end
                     if isfit
                        hold on;
                        plot(ts,imp(j,i).ag(1:maxlen));
                        hold off
                     end
                     y_lim_min=0;y_lim_max=0;
                     legend_(clegends)={[num2str(imp(j,i).meta.code(2)),'Hz']};
                     if(y_lim_min>min(ys))
                        y_lim_min=min(ys);
                     end
                     if(y_lim_max<max(ys))
                        y_lim_max=max(ys);
                     end
                end
            end    
            legend(legend_); 
    %         title_=['Souce at ',...
    %           num2str(imp(1,i).meta.srcpos),'m and receiver at ',...
    %             num2str(imp(1,i).meta.rcvpos),'m']; 
                 title_=['S: ',...
              num2str(imp(1,i).meta.srcpos),'m, R: ',...
                num2str(imp(1,i).meta.rcvpos),'m']; 
            x_lim=[-10,maxlen]/fs;
            y_lim=[max(y_lim_min*1.1,-y_lim_max*0.1),y_lim_max*1.1+eps];%,'xTick',x_tick,...
            set(gca,'Box','on','XScale',xscale,'xLim',...
                x_lim,'yLim',y_lim,'YScale',yscale)
                %   'yTick',y_tick,'yTickLabel',y_ticklabel);
                %   set(gca,'ticklength',2*get(gca,'ticklength'));
            set(get(gca,'xLabel'),'String',xlabel,'FontSize',8,'FontWeight','normal');
            set(get(gca,'yLabel'),'String',ylabel,'FontSize',8,'FontWeight','normal');
            set(get(gca,'Title'),'String',title_,'FontSize',8,'FontWeight','normal');
            set(ax(i),'OuterPosition',subplotpos(i,:),'FontSize',6);
            set(ax(i),'YtickMode','manual');
            set(ax(i),'YtickLabel',num2str(v2col(get(ax(i),'Ytick')),'%.2e'));
            if exist('h','var')~=0
                set(h,'LineWidth',0.6);
            end
        end
            suptitle('THE EARTH IMPULSE CURVE');
            fname=[num2str(offset+k),'-',num2str(offset+k+N-1)...
                ,'-',num2str(imp(1,1).meta.code(2)),...
                '-',num2str(imp(1,1).meta.srcpos),'-',...
            num2str(imp(1,1).meta.rcvpos),'-',...
            num2str(imp(1,N).meta.rcvpos),'-',...
            num2str(imp(1,1).meta.recnum)];
            print_fig(fname,fmt,qual,hf);
            close;
    end
else % no print
    srcsz=get(0,'ScreenSize');   %get screen size
    for k=1:nppp:NA
        imp=imps(k:min(k+nppp-1,NA));  %segment
        N=min(nppp,NA-k+1);
        hf= figure('Position',srcsz,'visible','on');     
        row=ceil(N/2);	           
        for i=1:N         
            if N>1
                subplot(row,2,i);
            end
            hold on;
            clegends=0;  % legends counter
            if iscmp
                M=imp(i,1).meta.num;
            else
                M=1;
            end
            for j=1:M
              if(isempty(imp(j,i).meta.rcvpos)==0)  % valid point
                     clegends=clegends+1;
                     lenlimit=imp(j,i).para.length;
                     maxlen=min(lenlimit,len);
                     ys=phf*imp(j,i).g(1:maxlen);
                     ts=imp(j,i).ts(1:maxlen);
                     h(j)=plot(ts,ys,clr{j});  
                     if ispeak                  
                         plot(ts(min(maxlen,imp(j,i).pn)),imp(j,i).apv,'or','MarkerFace','r');
                     end
                     if isfit
                        hold on;
                        plot(ts,imp(j,i).ag(1:maxlen));
                        hold off
                     end
                     y_lim_min=0;y_lim_max=0;
                     legend_(clegends)={[num2str(imp(j,i).meta.code(2)),'Hz']};
                     if(y_lim_min>min(ys))
                        y_lim_min=min(ys);
                     end
                     if(y_lim_max<max(ys))
                        y_lim_max=max(ys);
                     end
                end
            end    
            legend(legend_); 
    %         title_=['Souce at ',...
    %           num2str(imp(1,i).meta.srcpos),'m and receiver at ',...
    %             num2str(imp(1,i).meta.rcvpos),'m']; 
                 title_=['Source at ',...
              num2str(imp(1,i).meta.srcpos),'m, Receiver at ',...
                num2str(imp(1,i).meta.rcvpos),'m']; 
            x_lim=[-10,maxlen]/fs;
            y_lim=[max(y_lim_min*1.1,-y_lim_max*0.1),y_lim_max*1.1+eps];%,'xTick',x_tick,...
            set(gca,'Box','on','XScale',xscale,'xLim',...
                x_lim,'yLim',y_lim,'YScale',yscale)
                %   'yTick',y_tick,'yTickLabel',y_ticklabel);
                %   set(gca,'ticklength',2*get(gca,'ticklength'));
            set(get(gca,'xLabel'),'String',xlabel,'FontSize',12,'FontWeight','normal');
            set(get(gca,'yLabel'),'String',ylabel,'FontSize',12,'FontWeight','normal');
            set(get(gca,'Title'),'String',title_,'FontSize',12,'FontWeight','normal');
            set(gca,'YtickMode','manual');
            set(gca,'YtickLabel',num2str(v2col(get(gca,'Ytick')),'%.2e'),'FontWeight','bold');
            if exist('h','var')~=0
                set(h,'LineWidth',0.6);
            end
        end
%             suptitle('THE EARTH IMPULSE CURVE');       
    end  
end


% y_lim=[-0.1,1.1];y_tick=[0:0.2:1];
% y_ticklabel={'0';'0.2';'0.4';'0.6';'0.8';'1.0'};%;'1E+006';'1E+007''1E+000';
%x_lim=[1e-4,1]; x_tick=[0.1,1,10,100,1000]/1000;
%x_ticklabel={'10^{4}';'10^3';'10^-2';'10^-1';'1'};
 % legend('512Hz','1024Hz','2048Hz','4096Hz'); 
% function [maxmins,fmax]=peak(x)
% author: Ainray
% date: 20160308
% version: 1.0
% bug-report: wwzhang0421@163.com
% introduction: get peaks of time series
% input:
%        x, the input
% output:
%  maxmins, the peaks
%     fmax, 0, constant, increase, decrease 
%           1, descrease then increase
%           2, increase then descrease
%           3, D-type, d->i(peak)->d
%           4, C-type, i->d->i(peak)->d
%           5, B-type, i->d->i(peak)->d
%           6, A-type, i(peak)->d-i->d
function [maxmins,fmax]=mtem_peak(x)
      % find local max/min points
      N=length(x);
      d = diff(x); % approximate derivative
      maxmins = []; % to store the optima (min and max without distinction so far)
      for i=1:N-2
         if d(i)==0                        % we are on a zero
            maxmins = [maxmins, i];
         elseif sign(d(i))~=sign(d(i+1))   % we are straddling a zero so
            maxmins = [maxmins, i+1];        % define zero as at i+1 (not i)
         end
      end
      
      %remove early oscillation
      mms=maxmins;
      dmms=diff(mms);
      [mdmms,~]=max(dmms); % potential peak
      % potential oscillation zone
      idmms=find(dmms<mdmms/5);
      if ~isempty(idmms)
          cdmms=max(idmms(idmms<mdmms)); % cut index for maxmins
          maxmins=maxmins(cdmms+2:end);
%             indx=deselect(1:length(dmms),idmms);
%             maxmins=mms(indx+1);
      end
      maxmins=[1,maxmins];  % the first element is assuming always a extrema.
      if length(maxmins)==1 % constant or monotonously increase or descrease
           fmax=0;
      elseif length(maxmins)==2 
         if x(maxmins(2))<x(maxmins(1))   
             fmax=1; % descrease then increase
         else
             fmax=2; % increase then descrease
         end
      elseif length(maxmins)>2
        % divide maxmin into maxes and mins
        if x(maxmins(2))>x(maxmins(3))              % second one is a max not a min
            if x(maxmins(4))>x(max(maxmins(2)))      % C-type
                fmax=4;
            elseif (maxmins(4)-maxmins(3))/(maxmins(3)-maxmins(2))>3
                 % be consider tailing oscilation
                 fmax=6;
            else
                fmax=5;                             % B-type                      
            end
        else                                        % is the other way around
            fmax=3;                                 % D-type
        end
     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% amp=[];time=[];indx=[];
% x_label='Time (s)';y_label='Normalized earth impulse';
% %x_lim=[1e-4,1]; x_tick=[0.1,1,10,100,1000]/1000;
% %x_ticklabel={'10^{4}';'10^3';'10^-2';'10^-1';'1'};
% y_lim=[-0.1,1.1];y_tick=[0:0.2:1];
% y_ticklabel={'0';'0.2';'0.4';'0.6';'0.8';'1.0'};%;'1E+006';'1E+007''1E+000';
% 
% xyr=14.63/26;            % A4 
% wd=heigth/width*xyr;    %normalized width: screen width is one
% datar=0.9;          % A4
% nplot=size(tag_impulse,2);
% 
% clr=['r','b','g','m','k','y','c','w'];
% set(gcf,'Color','w');
% %subplots
% subplot_position=zeros(1,4);
% if nplot>5
%     row=ceil(nplot/2);	
%     for i=1:nplot
%         subplot_position(1)=(1-wd)*0.545+(1-mod(i,2))*0.52*wd; % x_start position
%         subplot_position(2)=0.05+0.96/row*(row-ceil(i/2));% y_start position
%         subplot_position(3)=0.35*wd;   %width
% %         if(0.35*wd*datar<0.98/row)
% %             subplot_position(4)=0.35*wd*datar; %height
% %         else
% %             subplot_position(4)=0.96/row*0.9; %height
% %         end   
%         subplot_position(4)=0.95/row*(0.8-(row-2)*0.05); %height
%         subplot('position',subplot_position);
%         ax(i)=get(gcf,'CurrentAxes');
%     end
% else     % one column
%     row=nplot;
%     for i=1:nplot
%         subplot_position(1)=(1-wd)*0.545; % x_start position
%         subplot_position(2)=0.05+0.95/row*(row-i);% y_start position
%         subplot_position(3)=0.9*wd;   %width
%         if nplot>8
%         if(0.9*wd*datar<0.98/row)
%             subplot_position(4)=0.9*wd*datar; %height
%         else
%             subplot_position(4)=0.95/row*0.9; %height
%         end   
%         else
%             subplot_position(4)=0.95/row*(0.8-(row-2)*0.05); %height
%         end
%         subplot('position',subplot_position);
%         ax(i)=get(gcf,'CurrentAxes');
%     end
% end
% for i=1:nplot
%     title_=['Souce at ',...
%         num2str(tag_impulse(1,i).shot_num),'m and receiver at ',...
%         num2str(tag_impulse(1,i).rcv_num),'m'];  
% %     axes(ax(i));
%     set(gcf,'CurrentAxes',ax(i));
%     hold on; 
%     y_lim_min=0;y_lim_max=0;jj_legend=0;
%     for j=1:rep(i)       
%      if(isempty(tag_impulse(j,i).rcv_num)==0)
%          jj_legend=jj_legend+1;
%          len_=length(tag_impulse(j,i).t_s);
%          h(j)=plot([0:min(len_,len)-1]/fs...
%             ,tag_impulse(j,i).g(1:min(len_,len)),clr(j)); 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %get max
%         if start>0
%             [g_max,t_max,g_i]=get_max(tag_impulse(j,i).g,tag_impulse(j,i).t_s,start);
%             amp(i)=g_max;time(i)=t_max;indx(i)=g_i;
%             plot(t_max,g_max,'k.');
%         end        
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         legend_(jj_legend)={[num2str(tag_impulse(j,i).code(2)),'Hz']};
%         if(y_lim_min>min(tag_impulse(j,i).g))
%             y_lim_min=min(tag_impulse(j,i).g);
%         end
%         if(y_lim_max<max(tag_impulse(j,i).g))
%             y_lim_max=max(tag_impulse(j,i).g);
%         end
%     end
%     end
%     legend(legend_);
%    % legend('512Hz','1024Hz','2048Hz','4096Hz'); 
%     x_lim=[-5,min(len,len_)]/fs;
%     y_lim=[y_lim_min*1.1,y_lim_max*1.1];
%     set(gca,'FontSize',6,'Box','on','XScale','linear','xLim',x_lim,'yLim',y_lim)%,'xTick',x_tick,...
%       % 'yTick',y_tick,'yTickLabel',y_ticklabel);
%     set(gca,'ticklength',2*get(gca,'ticklength'));
%     set(get(gca,'xLabel'),'String',x_label,'FontSize',8');
%     set(get(gca,'yLabel'),'String',y_label,'FontSize',6,'Color','k');
%     set(get(gca,'Title'),'String',title_,'FontSize',6);
%     if logon
%         set(gca,'xScale','log');
%     end
%     if exist('h')~=0
%     set(h,'LineWidth',0.6);
%     end
% end
% suptitle('THE EARTH IMPULSE CURVE');
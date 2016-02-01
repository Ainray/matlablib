% function simplewaterfall(x,z,type,rcv,step,scale,log,exc,mx)
% simplewaterfall is a simple version of waterfall, used to dispaly multi
% trace data in the same temporal or spacical scale
% Input:
%       x, the temporal or spacial sampling node, more closer to the top or
%          the left, more early or more near
%       z, the multi-channel data, every column is a time series of a
%          receiver, more closer to the top, the more previous time from now
%         
%    step, the step between two traces, supporting  varying step
%   scale, the scale vetor, supporting diffrent scaling for different trace
%    type, some common display ways: 1. like seismic section time series in 
%          the same spacial scale. 2. spacial series in the same temporal
%          scale.  3. like 2, but filled, 4, like  
%     rcv, the postion indices
%     log, whether abscissa using logarithmic scale,if not, unset; else, set
%     exc, the exclued trace indices or temporal node indices
%      mz, maximum values
function simplewaterfall(x,z,type,rcv,mx,log,step,scale,exc)
[m,n]=size(z);
x=v2col(x);
if nargin<3
    type=2;
end
if nargin<4
    rcv=[0:n+1];  % real ordinates
end
if nargin<5
    mx=max(z);
end
if nargin<6
    log=0;
end
if nargin<7
    step=ones(n,1);
end
if nargin<8
    scale=ones(1,n)*0.4;
end

if nargin<9
    exc=-1; 
end

scales_={'linear','log'};
if exc~=-1
    z(:,exc)=zeros(m,length(exc));   % filling columns with zeros.
end
ordinate=v2row(cumsum(step));    % ordinates
scalemat=ones(m,1)*v2row(scale); % scaling matrix
stepmat=ones(m,1)*ordinate;      % ordinates matrix, i.e.,center lines
mz=z.*scalemat+stepmat;          % scaled and shifted data
%
% muptiple profiles with the same abscissa      
%
if type==3 || type==4
    clr='r';
else
    clr='k';
end
plot(x,mz,clr);  % plot curves
hold on; 
% plot([x(1),x(end)],[ordinate;ordinate]','k');  %plot center lines
set(gca,'yTick',cumsum([0,v2row(step),step(end)])...
    ,'yTickLabel',num2str(v2col(rcv)),'xscale',scales_{log+1});  
axis([x(1),x(end),0,n+1]);
if type==3
%
% fill
%
X=[x',fliplr(x')]'; % two parts for upper and low bound, the vector will
                    % be extended automatically
Y=[stepmat;flipud(mz)];     %stepmat serves as axis bound(center line),
                            %mz serves as curve bound
% if the case is simple, where the curve is entirely above 
% the center axis, you just first step forward along the axis,
% then back along the curve                                    
hf=fill(X,Y,'r');
set(hf,'edgecolor','none');  
xlabel('Time (s)');
% set text
text(x(end-20000)*ones(n-1,1),v2col(cumsum(step(1:n-1))+0.5),...
    strcat('(max=',num2str(v2col(mx(1:n-1)),'%.2E'),...
    ', $\delta=$',num2str(10.^(1:9)','%.2E'),')'), 'interpreter','latex'...%);
    ,'Fonts',10,'FontN','arial', 'Hor','center','Ver','cap');
text(x(end-16020),sum(step)+0.5,strcat('orignal',', max=',...
    num2str(mx(end),'%.2E')),'Fonts',10,'FontN','arial', 'Hor','center','Ver','cap');
% cantenate peaks
[mm,mi]=max(mz);
semilogx(x(mi),mm,'k');
end
%         Y2=mz;
%         y2=z(:,i)*scale(i)+sum(step(1:i));y2=y2';
%         y1=ones(1,length(x))*sum(step(1:i));
%         Y=[y1,fliplr(y2)];
%         fill(X,Y,'r');
% i the traces of data
%         if(isempty(find(i==exc)))
%             if(log==1)
%                 semilogy(z(:,i)*scale(i)+sum(step(1:i)),x,'k');                    
%             else
%                 plot(z(:,i)*scale(i)+step(i)*i,x,'k')
%             end 
%             hold on;
%         end
 
%     for i=1:n
%         if(log==1)
%             semilogy([sum(step(1:i)),sum(step(1:i))],[x(1),x(end)],'--');
%         else
%             plot([sum(step(1:i)),sum(step(1:i))],[x(1),x(end)],'--');
%         end
%     end
%     axis([0,sum(step),min(x)-0.1*min(x),max(x)]);axis ij;
% elseif type==2
%      if mx>1 && nx==1
%         x=x';
%      end
%      for i=1:n  % i the time step
%         if(isempty(find(i==exc))) 
%             if(log==1)
%                 semilogx(x,z(:,i)*scale(i)+step(i)*i,'r');
%             else
%                 plot(x,z(:,i)*scale(i)+sum(step(1:i)),'r');
% %                 if i>1
% %                 area(x,z(:,i),sum(step(1:i-1)));
% %                 else
% %                      area(x,z(:,i),0);
% %                 end             
%             end  
%             hold on;
%                x=v2col(x);
%                
%         end
%      end
%      %plot gird line, as abscissa axis
%      for i=1:n 
%         plot([x(1),x(end)],[sum(step(1:i)),sum(step(1:i))],'--');
%      end
%      cc=0;
%      for i=1:3:length(step)
%          cc=cc+1;
%          ytick_(cc)=sum(step(1:i));
%      end
%      set(gca,'yTick',ytick_,'yTicklabel',rcv(1:3:end));
% %      yticklabel_rotate(ytick_,90);
%     axis([min(x)-0.1*min(x),max(x),0,sum(step)+step(end)]);
% elseif type==3
%      if mx==1 && nx>1
%         x=x';
%     end
%     for i=1:n  % i the traces of data
%         if(isempty(find(i==exc)))         
%                 fill(z(:,i)*scale(i)+step(i)*i,x,'r','edgealpha',0)
%         end   
%         hold on;
%     end
%      for i=1:n     
%             plot([sum(step(1:i)),sum(step(1:i))],[x(1),x(end)],'--');
%     end
%     axis([0,sum(step)+step(end),min(x)-0.1*min(x),max(x)]);axis ij;
% else
%    error(1,'type must be either 1,2 or 3');
% end
% xtitle
% hold off;


% simplewaterfall(x,z,scale,step,type,exc,rcv)
% simplewaterfall is a simple version of waterfall, used to dispaly multi
% trace data in the same temporal or spacical scale
% Input:
%       x, the temporal or spacial sampling node, more closer to the top or
%          the left, more early or more near
%       z, the multi-channel data, every column is a time series of a
%          receiver, more closer to the top, the more previous time from now
%         
%   scale, the scale vetor, supporting diffrent scaling for different trace
%    step, the step between two traces, supporting  varying step
%    type, two common display ways: 1. like seismic section time series in 
%          the same spacial scale. 2. spacial series in the same temporal
%          scale. Others: 3. fill 
%     log, whether using logarithmic scale
%     exc, the exclued trace indices or temporal node indices
%     rcv, the postion indices
function simplewaterfall(x,z,scale,step,type,rcv,str,log,exc)
if nargin<6
    rcv=step;
end
if nargin<8
    log=0;
end
if nargin<9
    exc=-1;
end
if length(x) == numel(x)
      x=v2col(x);
end

[m,n]=size(z);
[mx,nx]=size(x);
if(type==1)
    if mx==1 && nx>1
        x=x';
    end
    for i=1:n  % i the traces of data
        if(isempty(find(i==exc)))
            if(log==1)
                semilogy(z(:,i)*scale(i)+sum(step(1:i)),x,'k');                    
            else
                plot(z(:,i)*scale(i)+step(i)*i,x,'k')
            end 
            hold on;
        end
    end
    for i=1:n
        if(log==1)
            semilogy([sum(step(1:i)),sum(step(1:i))],[x(1),x(end)],'--');
        else
            plot([sum(step(1:i)),sum(step(1:i))],[x(1),x(end)],'--');
        end
    end
    axis([0,sum(step),min(x)-0.1*min(x),max(x)]);axis ij;
elseif type==2
     if mx>1 && nx==1
        x=x';
     end
     for i=1:n  % i the time step
        if(isempty(find(i==exc))) 
            if(log==1)
                semilogx(x,z(:,i)*scale(i)+step(i)*i,'r');
            else
                plot(x,z(:,i)*scale(i)+sum(step(1:i)),'r');
%                 if i>1
%                 area(x,z(:,i),sum(step(1:i-1)));
%                 else
%                      area(x,z(:,i),0);
%                 end             
            end 
            hold on;
               x=v2col(x);
               X=[x',fliplr(x')];
               y2=z(:,i)*scale(i)+sum(step(1:i));y2=y2';
               y1=ones(1,length(x))*sum(step(1:i));
               Y=[y1,fliplr(y2)];
               fill(X,Y,'r');
        end
     end
     for i=1:n
        plot([x(1),x(end)],[sum(step(1:i)),sum(step(1:i))],'-k');
     end
     cc=0;
     for i=1:3:length(step)
         cc=cc+1;
         ytick_(cc)=sum(step(1:i));
     end
     set(gca,'yTick',ytick_,'yTicklabel',rcv(1:3:end));
%      yticklabel_rotate(ytick_,90);
    axis([min(x)-0.1*min(x),max(x),0,sum(step)+step(end)]);
elseif type==3
    for i=1:n  % i the traces of data
%         if i==18
%             i
%         end
        if(isempty(find(i==exc, 1)))
                ss=sum(step(1:i));
                if length(x) ~= numel(x)
                    xx=x(:,i);
                else
                    xx=x;
                end
                fill([z(:,i)*scale(i)+ss;ss*ones(m,1)],[xx;xx(end:-1:1)],'r','edgealpha',0);
        end    
        hold on;
        plot([sum(step(1:i)),sum(step(1:i))],[min(min(x)),max(max(x))],'-k');
    end
    axis([0,sum(step)+step(end),min(min(x))-0.1*min(min(x)),max(max(x))]);
    axis ij;
    xlabel('Distance (m)','Fontsize',14);ylabel('Time (s)','fontsize',14);
    if ~isempty(str)
        title(str,'fontsize',14);
    end
    set(gca,'yTicklabel',get(gca,'yTicklabel'),'Fontweight','bold','Fontsize',14,...
        'xTicklabel',v2col(rcv));
    xt=get(gca,'xTick');
    if(xt(1)<step(1))
        xt(1)=step(1);
    end
    if(xt(end)>sum(step))
        xt(end)=sum(step);
    end
    if xt(end)<sum(step)
        xt=[xt,sum(step)];
    end
    [lb,loc]=ismember(xt,cumsum(step));
    set(gca,'xTick',xt,'xTickLabel',rcv(loc));
    if log==1
        set(gca,'yscale','log');
    end
    elseif type==4
    for i=1:n  % i the traces of data
        if(isempty(find(i==exc, 1)))
                ss=sum(step(1:i));
                if length(x) ~= numel(x)
                    xx=x(:,i);
                else
                    xx=x;
                end
                fill([z(:,i)*scale(i)+ss;ss*ones(m,1)],[xx;xx(end:-1:1)],'r','edgealpha',0);
        end    
        hold on;
%         plot([sum(step(1:i)),sum(step(1:i))],[min(min(x)),max(max(x))],'-k');
    end
    axis([0,sum(step)+step(end),min(min(x))-0.1*min(min(x)),max(max(x))]);
    axis ij;
    xlabel('Index','Fontsize',14);ylabel('Time (s)','fontsize',14);
    if ~isempty(str)
        title(str,'fontsize',14);
    end
    set(gca,'yTicklabel',get(gca,'yTicklabel'),'Fontweight','bold','Fontsize',14,...
        'xTicklabel',v2col(rcv));
    xt=get(gca,'xTick');
    if(xt(1)<step(1))
        xt(1)=step(1);
    end
    if(xt(end)>sum(step))
        xt(end)=sum(step);
    end
    if xt(end)<sum(step)
        xt=[xt,sum(step)];
    end
    [lb,loc]=ismember(xt,cumsum(step));
    set(gca,'xTick',xt,'xTickLabel',rcv(loc));
    if log==1
        set(gca,'yscale','log');
    end
else
   error(1,'type must be either 1,2 or 3,4');
end

hold off;


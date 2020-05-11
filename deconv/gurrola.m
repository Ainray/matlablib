function [h,err,nh]=gurrola(x,y,mu,pre)
% author: Ainray
% date: 20170530
% bug report: wwzhang0421@163.com
% introduction: iterative time-domain least-square deconvolution
% input:
%        x, the input
%        y, observed output
% output:
%        h, the estimated impulse response
%      err, the error between calculated and observed  reponses
%       nh, the 'size' of estimated impulse response
%      pre, precision between two errors
%    cycle, when mutliple
    if nargin<3
        mu=0;
    end
    if nargin<4
        pre=1e-4;   % 0.01%
    end
    xx=sum(x,2);
    yy=sum(y,2);
    n=length(y)-length(x)+1;  % the length of impulse
    M=size(x,2);                % form multiple events
%     X=convmtx(x(:,1),n);
%     XX=X'*X;
    
    yx=X'*y(:,1);
    for i=2:M          
        X=convmtx(x(:,i),n);
        XX=XX+X'*X;
        yx=yx+X'*y(:,i);
    end
   
    k=length(mu); % max iterative times
    h=zeros(n,k);
    err=zeros(k,1);
    nh=zeros(k,1);
    alpha=mu(1);     % regularization
    for i=1:k
        hh=(XX+alpha*eye(size(XX)))\yx;
        h(:,i)=hh;
        err0=norm(fconv(xx,hh)-yy)/sqrt(ld);
        err(i)=err0;
        nh0=norm(hh)^2;
        nh(i)=nh0;
        % iterative ends ahead of time
        if i>1
            if (abs(err(i)-err(min(1,i-1)))/err(i-1))<pre
                h=h(:,1:i);
                err=err(1:i);
                nh=nh(1:i);
                break;
            end
        end
    end
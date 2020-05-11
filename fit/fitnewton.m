function yy=fitnewton(xp,yp,x,type,spos,nd)
% function y=newton(xp,yp,x,type,spos,nd)
% author: Ainray
% date: 20170709
% email:wwzhang0421@163.com
%
% test example: xp=[0     5    10    15    20    25    30    35    40]';
%               yp=[0 4.87 10.52 17.24 25.34 35.16 46.97 61.09 77.85]';
%              Newton I: 22 is close to 20, spos=5
%               y=newton(xp,yp,22,1,5,2);  
%              Newton II: 22 is close 25, spos=6
%               y=newton(xp,yp,22,2,6,2); 
%              Newton III (Gauss): spos=5
%               y=newton(xp,yp,22,3,5);
%              Newton III (Gauss): spos=6
%               y=newton(xp,yp,22,4,6);
%              Stirling: spos=5
%               y=newton(xp,yp,22,5,5);
%              Bessel:  spos=5
%               y=newton(xp,yp,22,6,5);
% 
xp=v2col(xp);
yp=v2col(yp);
N=length(xp); 
if nargin<6
    nd=N-1;
end
Nx=length(x);
yy=zeros(Nx,1);
for i=1:Nx
    yy(i)=yp(spos);  % y0
end

dy=yp;
switch type  
    case 1          % Newton type I 
        for j=1:nd  
            df=(dy(2:N-j+1)-dy(1:N-j))./(xp(1+j:N)-xp(1:N-j));  % divided difference
            dy=df;
            if j>N-spos   % maximum order of dd
                break;
            end
            indx=spos:spos+j-1;   % nodes position 
            pos=spos;      % divided difference position  
            for i=1:Nx
                yy(i)=yy(i)+df(pos)*prod(x(i)-xp(indx));
            end
        end
            
    case 2          % Newton type II 
        for j=1:nd  
            df=(dy(2:N-j+1)-dy(1:N-j))./(xp(1+j:N)-xp(1:N-j));  % divided difference
            dy=df;
            if j>spos-1
                break;
            end
            indx=spos-j+1:spos;
            pos=spos-j;
            for i=1:Nx
                yy(i)=yy(i)+df(pos)*prod(x(i)-xp(indx));
            end
        end         
    case 3          % Newton type III (Gauss) 
        for j=1:nd  
            df=(dy(2:N-j+1)-dy(1:N-j))./(xp(1+j:N)-xp(1:N-j));  % divided difference
            dy=df;
            indx=spos-floor((j-1)/2):spos+floor(j/2);
            pos=spos-floor(j/2);
            if pos>N-j
                break;
            end
            for i=1:Nx
                yy(i)=yy(i)+df(pos)*prod(x(i)-xp(indx));
            end
        end    
    case 4          % Newton type IV(Gauss)
        for j=1:nd  
            df=(dy(2:N-j+1)-dy(1:N-j))./(xp(1+j:N)-xp(1:N-j));  % divided difference
            dy=df;
            indx=spos-floor(j/2):spos+floor((j-1)/2);
            pos=spos-floor((j+1)/2);
            if pos>N-j
                break;
            end
            for i=1:Nx
                yy(i)=yy(i)+df(pos)*prod(x(i)-xp(indx));
            end
        end
    case 5          % Stirling: average III and IV
        for j=1:nd  
            df=(dy(2:N-j+1)-dy(1:N-j))./(xp(1+j:N)-xp(1:N-j));  % divided difference
            dy=df;
            if mod(j,2)==1 % odd
                indx=spos-floor((j-1)/2):spos+floor(j/2);
                pos=spos-floor(j/2);
                if pos>N-j
                    break;
                end
                for i=1:Nx
                    yy(i)=yy(i)+(df(pos)+df(pos-1))/2*prod(x(i)-xp(indx));      %average dd
                end
            else   % even
                pos=spos-floor(j/2);
                if pos>N-j
                    break;
                end
                indx=spos-floor((j-1)/2):spos+floor(j/2);
                for i=1:Nx
                    yy(i)=yy(i)+df(pos)*prod([x-xp(indx(1:end-1));...
                    x(i)-(xp(indx(end))+xp(indx(1)-1))/2]);      % average nodes 
                end
            end
        end
            
    case 6          % Bessel
        for j=1:nd  
            df=(dy(2:N-j+1)-dy(1:N-j))./(xp(1+j:N)-xp(1:N-j));  % divided difference
            dy=df;
           if mod(j,2)==0 % even
                indx=spos-floor((j-1)/2):spos+floor(j/2);
                pos=spos-floor(j/2);
                if pos+1>N-j
                    break;
                end
                for i=1:Nx
                    yy(i)=yy(i)+(df(pos)+df(pos+1))/2*prod(x(i)-xp(indx));      %average dd
                end
           else
                if j>1% odd
                    pos=spos-floor(j/2);
                    if pos>N-j
                        break;
                    end
                    indx=spos-floor((j-1)/2):spos+floor(j/2);
                    for i=1:Nx
                        yy(i)=yy(i)+df(pos)*prod([x-xp(indx(2:end));...
                            x(i)-(xp(indx(1))+xp(indx(end)+1))/2]);      % average nodes
                    end
                else   % dy0*(x-x0)
                    for i=1:Nx
                        yy(i)=yy(i)+df(spos)*(x(i)-xp(spos));
                    end
                end
           end 
        end
end



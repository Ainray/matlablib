%
%
%function [rf ,misfit,sz ]=gurrola(w,d,fs,xp,iter,fig)
function [rf ,t_rf,misfit,sz ]=gurrola(w,d,fs,range,iter,fig)
if nargin<5
    iter=20;
end
if nargin<5
    fig=0;
end

M=size(d,2);
w_stack=selective_stack(w);
d_stack=selective_stack(d);

ld=length(d);
lw=length(w);
lr=ld-lw+1; 

WW=zeros(lr,lr); 
den=zeros(lr,1);

for i=1:M
    Wl=zeros(ld,lr);
    for a=1:lr
        b=a+lw-1;
        Wl(a:b,a)=w(:,i);
    end
    
    W_Tl=Wl';
    WWl=W_Tl*Wl;
    WW=WW+WWl;
    den=den+W_Tl*d(:,i);
end

mu=range(1);
rf(:,1)=(WW+mu^2*eye(size(WW)))\(den);
misfit(1)=norm(convolution(w_stack,rf(:,1),fs)-d_stack)/sqrt(ld);
sz(1)=norm(rf(:,1))^2;
z=2;
for mu=range(2:end)
    rf(:,z)=(WW+mu^2*eye(size(WW)))\(den);
    misfit(z)=norm(convolution(w_stack,rf(:,z),fs)-d_stack)/sqrt(ld);
    sz(z)=norm(rf(:,z))^2;
    if abs((misfit(z-1)-misfit(z))/misfit(z-1))<5*1e-6
        break;
    end
    z=z+1;
    if(z>=iter)
        break;
    end
end
t_rf=time_vector(rf,fs);
if fig
figure();
plot(sz,misfit,'bx','MarkerSize',10,'LineWidth',3);
hold on;
plot(sz,misfit);
xlabel('Model Size ||rf||^2')
ylabel('Misfit-RMS difference between observed and predicted');

k=2:z
misfit_change=abs(misfit(k-1)-misfit(k))/misfit(k-1);
figure();
plot(k,misfit_change,'bx','MarkerSize',10,'LineWidth',3);
hold on;
plot(k,misfit_change);
xlabel('Iteration');ylabel('Misfit percent change');


figure;
plot(t_rf,rf(:,end));
title(['Gurrola, Lagrange Multiplier=',num2str(mu),' number of iterations=',...
    num2str(z)]);
xlabel('Time (s)');
ylabel('Receiver Function');
 end
    
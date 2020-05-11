% function r=xcorr_m(x,y,nr,ns,ne,lta)
% NOTE:
%      'ns' must larger than nr, it guarantee periodic shift
%
% introduction: for multiple periodic signal ,it works
% c.f. , 李白男，伪随机信号及相关辨识，1987，科学出版社 
function r=xcorr_m(x,y,nr,ns,ne,lta)
% if nargin==6
rt=zeros(nr,1);  
num=ne-ns+1;     %number of sampling in correlation fuction       
for k=1:nr
    kk=k-1;      % include N1 point with first sigal
    rt(k)=v2row(y(ns:ne))*v2col(x((ns:ne)-kk*lta));
    rt(k)=rt(k)/num;

%     tmp=0;  
%     for i=ns:ne
%         ik=i-kk*lta;
%         if(ik<1)
%             tmp=tmp+0;       %  for negtive subsrcipt(more earlier signal), assume zero
%         else
%             tmp=tmp+y(i)*x(ik);   %normalzied
%         end
%     end
%     rt(k)=tmp/num;
end
r=rt;
% else
%     r=zeros(nr,1);  
% num=ne-ns+1;     %number of sampling in correlation fuction       
% for k=1:nr
%     kk=k-1;      % include N1 point with first sigal
%     tmp=0;  
%     for i=ns:ne
%         ik=i-kk*lta;
%         if(ik<1)
%             rt=0;       %  for negtive subsrcipt(more earlier signal), assume zero
%         else
%             rt=y(i)*x(ik)/num;   %normalzied
%         end
%         tmp=tmp+rt;
%     end
%     r(k)=tmp;
% end
%     tmp=r;
%     r(1:ppe)=tmp(nr-ppe+1:nr);
%     r(ppe+1:nr)=tmp(1:nr-ppe);
% end

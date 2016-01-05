% function [A,b]=levin_lsq_ne(x,y,P,ns)
% author:Ainray
% created: 2015/05/13
% last modified: 2015/05/13
% version: 0.0
% mail: wwzhang0421@163.com
% introduction :This routine is used to generate the Toeplitz matrix and
% right-side vector of the normal equation, for Wiener filter.
% c.f.s:  Optimum Estimation of Impulse Response in the Presence fo Noise,
% Morris J. Levin, 1959
% inputs:  x, input signal samples
%          y, output signal samples
%          P, the number of samples of impulse response to be recovred
%             the defult value is length(y)+1-length(x)
% outputs: r, the auto-correlation of input, i.e., x.           
%          b, the right-side, generated the cross-correlation of input and
%             output,i.e. x and y, respectively.

function [r,b]=levin_lsq_ne(x,y,P,ns,ne,len,type)
% error(nargchk(2, 3, nargin, 'struct'));
% N=length(x);    %length of input  
% M=length(y);    %length of output
% if nargin==2
%     P=M+1-N;
% elseif nargin==3
%    while P>M+1-N
%    P=input(['function levin_lsq_ne:',...
%        'The number of samples of impulse response must be\n ', ...
%        'less or equal than thenumber of input substracting output plus one.\n',...,'
%        'Please enter the number of impulse reponse smaples(M=:',num2str(M),',N=',num2str(N),')'])
%    end
% end
if nargin<6
    len=0;
end
if nargin<7
    type=2;
end
if nargin<5
    ne=min(length(x),length(y));
end
switch(type)
    case 0
        x1=x(ns:end);y1=y(ns:end);
        r1=cross_cor(x1,x1);
        b1=cross_cor(x1,y1);
        xc=r1(1:min(P-len,length(r1)));
        b=b1(1:min(P,length(b1)));
        r=xc/xc(1);
        b=b/xc(1);
    case 1
        x=x(ns:ne);x=y(ns:ne);
        N=min(length(x),length(y));
        xc=rxcorr(x,x,P-len,ns,N,1);
        r=xc/xc(1);
        b=rxcorr(x,y,P,ns,N,1);
        b=b/xc(1);
    case 2
        N=length(x);    %length of input  
        M=length(y);    %length of output
        if nargin==2
            P=M+1-N;
        elseif nargin==3
           while P>M+1-N
           P=input(['function levin_lsq_ne:',...
               'The number of samples of impulse response must be\n ', ...
               'less or equal than thenumber of input substracting output plus one.\n',...,'
               'Please enter the number of impulse reponse smaples(M=:',num2str(M),',N=',num2str(N),')'])
           end
        end
    % the normal matrix
    xc=xcorr(x,'biased')/norm(y)^2;   %auto correlation
    xc=xc(N:min(N+P-1,length(xc)));         %only the postive side
    r=xc/xc(1);
    % the normal right-side vector of 
    b=xcorr(y,x);
    b=b(M:min(M+P-1,length(b)))/N/norm(y)^2;
    b=b/xc(1);
end



% N=min(length(x),length(y));
% r=xcorr_m(x,x,P,ns,N,1);
% b=xcorr_m(x,y,P,ns,N,1);



% % the normal matrix
% xc=xcorr(x,'biased')/norm(y)^2;   %auto correlation
% xc=xc(N:min(N+P-1,length(xc)));         %only the postive side
% r=xc/xc(1);
% % the normal right-side vector of 
% b=xcorr(y,x);
% b=b(M:min(M+P-1,length(b)))/N/norm(y)^2;
% b=b/xc(1);


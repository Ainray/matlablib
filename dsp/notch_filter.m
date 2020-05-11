function y=notch_filter(B,A,x,m,w,dual)
%   date: 20190813
%   email: wwzhang0421@163.com
%   lated: 20190813
% 
%   Introduction: general filter subroutine
%       matlab filter a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%                               - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
%   Input:
%        B, [b(1), b(2), ..., b(nb+1)] 
%        A, [   1, a(2), ..., a(na+1)] 
%        x, input data
%        m, method: >1, third initial condition/project notch; 
%                 0, 1, second condition 
%                   <0, first initial condition
%        w, digital notch frequency, only for m>1
%     dual, indicate wheather single direction or dual direction

if nargin<6
    dual=1; % default is dual direction
end
x=v2col(x);
n=length(x);
A=v2col(A);
B=v2col(B);

if m>1      % projection filter
    % project operator
    %[1 cos(w0)   ... cos((M-1)w0)]
    %[0 sin(w0)   ... sin((M-1)w0)]
    %[1 cos(w1)   ... cos((M-1)w1)]
    %[0 sin(w1)   ... sin((M-1)w1)]
    % ...
    y=zeros(n,1);
    nw=length(w);
    nw2=nw*2;
    if m<nw2
        m=nw2;
    end
    if(m<length(A)-1)
        m=length(A)-1;
    end
    
    P0=zeros(m,nw2);
    for i=1:nw
        P0(:,i*2-1:i*2)=[cos((0:m-1)'*w(i)) sin((0:m-1)'*w(i))];
    end
%     P=P0*((P0'*P0)\P0');
%     s=(eye(m)-P)*x(1:m);
    
    n0=P0*(pinv(P0'*P0)*P0'*x(1:m)); % noise
    s=x(1:m)-n0;                     % signal
    y(1:m)=s;                        % initial conditions
    na=length(A);
    nb=length(B);
    for i=m+1:n
         y(i)=[y(i-1:-1:i-na+1)' x(i:-1:i-nb+1)']*[-A(2:end);B];
    end
    
    if dual==1
        x= y(end:-1:1);
        n0=P0*(pinv(P0'*P0)*P0'*x(1:m));
        s=x(1:m)-n0;
        y(1:m)=s;
        for i=m+1:n
            y(i)=[y(i-1:-1:i-nw2)' x(i:-1:i-nw2)']*[-A(2:nw2+1);B];
        end
        y=y(end:-1:1);
    end    
elseif m>-1         % the second initial conditions
    m=length(A)-1;
    y=zeros(n+m,1);  
    xx=[zeros(m,1);x];
    y(1:m)=ones(m,1)*x(1);% input as the initial conditions
    for i=1:n
        y(i+m)=[y(i+m-1:-1:i); xx(i+m:-1:i)]'*[-A(2:end);B];
    end
    if dual==1
        xx=[ones(m,1)*y(end);y(end:-1:m+1)];
        for i=1:n
             y(i+m)=[y(i+m-1:-1:i);xx(i+m:-1:i)]'*[-A(2:end);B];
        end
        y=y(end:-1:m+1);
    else
        y=y(m+1:end);
    end 
    
else  % the first intial condition
    m   =   length(A)-1;        % number of intial values, output and input
                                % are both shifted
    y   =   zeros(n+m,1);       
    xx  =   [zeros(m,1);x];    % initial conditions are zeros
    
    % saying na=nb=2, i.e, second order notch, B A both have three
    % coefficients, then m=2, at first, y(3)=[y(2:-1:1); xx(3:-1:1)
    
    % filter
    for i=1:n
        y(i+m)=[y(i+m-1:-1:i);xx(i+m:-1:i)]'*[-A(2:end);B];
    end
    
    % filter twice to canel phase shift
    % x*f -> r -> r(-n) -> r(-n)*f -> y(-n)  -> y(n)
    % XF  -> R -> R(-w) -> R(-w)F  -> R(-w)F -> R(w)F
    if dual==1
        xx=[zeros(m,1); y(end:-1:m+1)];     % reverse
        for i=1:n
             y(i+m)=[y(i+m-1:-1:i);xx(i+m:-1:i)]'*[-A(2:end);B];
        end
        y=y(end:-1:m+1);
    else
        y=y(m+1:end);
    end
end
% function y=conv_m(g,x,dt,n)
% n is the number of input and output data
% dt is the sampling time step
function y=conv_m(g,x,dt,n)
    error(nargchk(3, 4, nargin, 'struct'));
    if nargin==3
        n=length(g)+length(x);
    end
    y=zeros(n,1); % initialing the output
    [mx,nx]=size(x);
    % let x is a row vetor
    if mx>1 && nx==1
        x=x';
    end
    x=[x,zeros(1,n-length(x))]; % padding x with zeros
    ng=length(g); % the number of filter coeffients 
    for i=1:n
        for j=1:ng
            ij=i+1-j;
            if ij<1
                yy=0;     %more earlier time when there is no input
            else
                yy=g(j)*x(ij)*dt;
            end
            y(i)=y(i)+yy;
        end
    end
        
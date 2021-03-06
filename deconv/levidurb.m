% function x=levidurb(r,b,N,prenoise)
% author: Ainray
% bug-report: wwzhang0421@163.com
% levinson-durbin algorithm for solving Yule-Walker equations 
% Input: 
%        r, n length of vector, r(2:n) is used to generate n*n Toeplitz
%           matrix
%        b, n length vector on the right side
% Output: 
%        x, solution vector 
%
% generalized Yule-Walker equation: 
% r=-(1,r2,,...,rk-1,rk)T,x=(x1,...,xk-1,xk)T, Tk-1 is k order Toeplitz
% matrix, whose diagonal has been normalized:
%        |1   r2  ... rk   |
%        |r2  1   ... rk-1 |
%  Tk=   |r3  r2  ... rk-2 |
%        |... ... ...  ... |
%        |rk   rk-1 ... 1  |
%  Ek is k order exchange matrix,then k order generalized Yule-Walker equation is
%        |1   r2  ... rk   |  | x1 |  |b1 |
%        |r2  1   ... rk-1 |  | x2 |  |b2 |
%        |r3  r2  ... rk-2 |* | x3 |= |b3 |
%        |... ... ...  ... |  | ...|  |...|
%        |rk  rk-1 ... 1   |  | xk |  |bk |

% test 
%r=[1,0.5,0.2];b=[4,-1,3];format rational; x=(355,-376,285)/56

function [x,alphas]=levidurb(r,b,N,prenoise)
if nargin<3
    N= length(r);
end

if nargin<4
    prenoise=0.0;
end
% default r and b is column vector
[mr,nr]=size(r);
if mr==1 && nr>1
    r=r';
end
[mb,nb]=size(b);
if mb==1 && nb>1
    b=b';
end
nr=max([mr,nr]);
nb=max([mb,nb]);
% if nr~=nb && nargin<3
%     error('b and r must have the same length')
%     return;
% end
% normalized r,and b
if(r(1)==0)
    error(-1,'r(1) must not be zero')
    return;
end
r(1)=(prenoise+1)*r(1);
b=b/r(1); r=r/r(1); %r=(1,r2,...rn-1,rn)
% solving equation 
sigma=1;alpha=-r(2);y=-r(2); x=b(1);
alphas=alpha;
nr=min([nr,nb,N]);
for k=1:nr-1
    sigma=(1-alpha^2)*sigma;
    mui=(b(k+1)-r(k+1:-1:2)'*x(1:k))/sigma;
    x=[(x(1:k)+mui*y(k:-1:1));mui];
    if(k<nr-1)
        alpha=-(r(k+1:-1:2)'*y(1:k)+r(k+2))/sigma;
        alphas=[alphas;alpha];
        y=[(y(1:k)+alpha*y(k:-1:1));alpha];
    end
end


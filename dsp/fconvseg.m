% function y=fconvseg(x,h,L)
% author: Ainray
% date: 2015/12/13
% bug-report: wwzhang0421@163.com
% introduciton: implemention of convolution segment-by-segment, your segment
%               size is recommend to be larger than the impulse reponse.
%   input:
%            x, the input 
%            h, the impulse reponse of the system
%            L, the calculated length of every segment
%  output:
%            y, the output
function y=fconvseg(x,h,L)
N=length(x);  % the length of input
M=length(h);  % filer length 
K=floor(N/L);   % the number of segment
result_left=zeros(M-1,1);  % the stacked part of every convolution
y=zeros(N+M-1,1);          % alloc the output 
for K_count=1:K         % segment-by-segment
       
    xs=x((K_count-1)*L+1:K_count*L); % retrieve the input of per segment
    ys=fconv(v2col(xs),v2col(h));  % fast convlution based on FFT
    ys(1:M-1)=ys(1:M-1)+result_left(1:M-1);  % stack the current convlution result
                                      % with last stacked part
    y((K_count-1)*L+1:K_count*L)=ys(1:L); % save the current 
    result_left(1:M-1)=ys(L+1:L+M-1); % update the stacked part
end
% deal with the tail of input
if(K_count*L<N)  % have tail 
   xse=x(K_count*L+1:N);
   yse=fconv(xse,h);
   yse(1:M-1)= yse(1:M-1)+result_left     ;        
   y(K_count*L+1:N+M-1)=yse;
else  % have no tail
   y(K_count*L+1:N+M-1)=ys(L+1:L+M-1); 
   
end

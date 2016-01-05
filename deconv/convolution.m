function [c2 t_c]=convolution(a,b,fs)
[A B B2]=freq_domain(a,b);
C=A.*B; 
c=real(ifft(C)); 

lc=length(c);
e=conv(a,b);
le=length(e);
z=le-lc;
% if z<0
%     error('Inputs are inappropriate lengths')
% else
%     c2=[c;zeros(z,1)];
% end
c2=e;
t_c=time_vector(c2,fs);
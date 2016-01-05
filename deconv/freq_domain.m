% function  [D W W2]=freq_domain(d,w)
% author: Ainray, rewirriten from 
% time  : 2015/7/30
% information: fft transform.
% input:
%              d, recorded data
%              w, wavelet or impulse or transient
%  output:
%              D, fft transform of data
%              W, fft of wavelate
%             W2, conjugate of W
function  [D W W2]=freq_domain(d,w)
l=max([size(d,1) size(w,1)]);
NFFT=2^nextpow2(l);
D=fft(d,NFFT);
W=fft(w,NFFT);
W2=conj(W);
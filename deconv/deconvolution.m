function rf=deconvolution(w,d)
[D W WW]=freq_domain(d,w);
RF=D./W;
rf=real(ifft(RF));
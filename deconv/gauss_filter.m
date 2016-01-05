function y=guass_filter(x,f0,fc)
    nx=length(x);
    x_spec=fft(x, nx);
    
    % gauss filter for band-limited aprroximation
    f=[1:nx]'/nx*fc;
    gaos=exp(-f.*f/f0^2);
    xg_spec=x_spec.*gaos;
    y=real(ifft(xg_spec,nx));
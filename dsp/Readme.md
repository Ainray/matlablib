Name: DSP 
Version: 1.0
Author: Ainray
Date: 20151228
Bug report: wwzhang0421@163.com
Introduciton: Basic DSP operations:
		1. random noise
		2. filter
		   2.1 A family of filters constructed from Windowed-Sinc lowpass filter.
		3. window functions
		
Function list
-------------
        addnoise
			Syntax:[b,pert] = addnoise(b_exact, NSR )
			Introduciton: Add random noise specified by NSR, which is the signal STD divided 
						  by noise STD, i.e., AC component.  Assuming that DC component of both
						  signal and noise is zero.
					

		blackman_win
			Syntax:h=blackman_win(N)
			Introduciton: Generate Blackman window.
						
		esd		
			Syntax: [mx,f]=esd(x,fs,xLim,varargin)
			Introduciton: Simple spectral analysis tool, based on DFT(FFT).
		
		fconv
			Syntax: [y]=fconv(x, h)
			Introduciton: Fast convolution based on FFT.
			
		filter_analyzer
			Syntax:[step, amp]=filter_analyzer(impulse,fs,...)
			Introduciton: A simple filter properties, such as impulse kernel, step response,
			              amplitude spectrum, analysis tool.
		gauss_src
			Syntax: [gs,t_s]=gauss_src(N,...)
			Introduciton: Generate gassian source wavelet.
			
		hamming_win
			Syntax: h=hamming_win(N)
			Introduciton: Generate Hamming window.
		movingavgfilter
			Syntax: y=movingavgfilter(x,N)
			Introduciton: Moving average filter, both ends will be unchanged after filtering.
		
		prbs_src
			Syntax: [src_i,t_s,single_num]=prbs_src(t_ele,order,cycle,fs,type,I,...)
			Introduciton: Generate m sereis.
			
		rect_win
			Syntax: h=rect_win(tail,width,...)
			Introduciton: Rectangle window family: rectangle, triangle and so on. 
		
		winsinc_bandpass	
			Syntax: h=winsinc_bandpass(fc,N,...)
			Introduciton: Sinc bandpass filter with Blackman window.
			
		winsinc_bandstop
			Syntax: h=winsinc_bandstop(fc,N,...)
			Introduciton: Sinc bandstop filter with Blackman window.
			
		winsinc_highpass
			Syntax  h=winsinc_highpass(fc,N,...)
			Introduciton: Sinc highpass filter with Blackman window.
			
		winsinc_lowpass
			Syntax: h=winsinc_lowpass(fc,N,...)
			Introduciton: Sinc lowpass filter with Blackman window.
			

		
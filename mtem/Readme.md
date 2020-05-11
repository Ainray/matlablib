Name: MTEMPreprocessor
Version: 1.2.1
Author: Ainray
Date: 20151024, upadte 20160321
Bug report: wwzhang0421@163.com
Introduction: MTEMPreprocessor is a toolkit for preprocessing filed data of MTEM.
Dependencies: www.github.com/Ainray/matlablib                                  
Matlab verision: 8.0.0.783 (R2012b)                                             

0. File System
--------------
   dsp, the digital singal processing tool box, provide basic dsp routines, like smooth, filter, spectral analysis, and etc.

   deconv, the deconvlution tool box, provide the basic deconvolution routines, like damping factor, water level, 
Wiener filter, simutanious time-domain deconvolution and etc.

   Readme.md, a simple introduction of this toolkit, i.e., this document

1. Introduction
--------------
	1.1 data structure
       imps, array of impulse structure

                   (member of main structure)
                g, calculated earth impulse response
               ng, EIR after 50Hz notchering
               bg, back up the orignal calculated EIR
			   ag, fitted analytic EIR
                r, for wiener auto correlation
                b, for wiener cross correlation			   
               ts, sample times
               pv, peak value calculated EIR
			  cpv, current peak value of calculated EIR
              apv, peak value of analytic EIR
               pn, sample number of peak, i.e. peak time (samples)
			  cpn, current peak time (samples)
              rho, apparent resistivity
			 mask, assuming effective data

                   (meta description paramter)
             meta, sub structure of discription parameter
                   (member of sub structure 'meta')
           srcpos, source position
           rcvpos, receiver position
		   recnum, recording number
              cmp, the middle-point position, (srcpos+rcvpos)/2
           offset, the offset, srcpos-rcvpos   
             code, input current parameter, refer to readhead
			  npp, number of samples per period
			 ncpp, number of PRBS chips per period
	        rcvsn, receiver meter sn
            rcvch, receiver meter channel 
               fs, sampling rate
			  num, number of frequencies, for comparison of multiple frequecies
                   the default value is 1, refer to reshapeimp
				   
                   (control parameter)
            para,  sub structure of control parameter 
                   (member of sub structure 'para')
            srcsn, the source acquisition meter serial number
            srcch, source channel,i.e. 
                   the type of source data: 
                                0 current from Hall sensor
                                2 voltage from small bipole
                             3050 the position of soure, indicating theorical PRBS 
		   length, the length of EIR, typical value:16000
           method, deconvolution method: 'wiener', 'invfitler'
            stack, the stack method: 
                   'prestack', first deconvolution, then stack 
                   'poststack' first stack, then deconvolution
           start, start point (samples) of input signal to be used for deconvolution
            step, number of cycles per segment to used for deconvolution
          number, the maximum of segment to be used for deconvolution
                  
                   (other deconvolution parameters)
         notcher, true or false
           nfres, notcher harmonics,[50,150,250,...]
     wienernoise, the stationary noise, tipically 1%
	   invflevel, invfilter water level, default,0.001
      invflength, impulse length of inverse filtering
	  invfmethod, method for setting water level within inverse filter
	   invfgauss, when use inverse filtering, apply gauss filter or not
  invfgausslamda, gauss filter factor, just double of numerical cutoff frequency
    notcherwidth, notcher numerical band width
             ...,
				   
	1.2  processing
			what you only need to do is type 'decmain',
		 then just follows the Introduction
		 
		 (the procedure is schematically illustrated)
		 0) start main program from the command window
			decmain
		 1) initializing
			
		 2) set the control parameter
			a.) The parameter files default is 'mtem.par file'.
			b.) If no such file, you can choose another file.
			c.) create your own parameter file by "writepara('File','sample.par')"
			    refer to 1.3
				
		 3) load data
		
		 4) deconvolution
	
	1.3  how to write you self paramter control file
			You can first call:
				writepara('File','mtem.par');
		 to generate a sample file, then change the values as you want.
		 The parameter names are build-in, changes are forbidden.
		 (Sample file)
--------------------------------------------------------------------------------------------------------------------
|		# This document set the deconvolution parameters                                                           |
|		# Lines start with # is comments                                                                           |
|		# Parameter-value(para-value) pairs are line-by-line,with delimeter of ":" and without space               |
|		# String after #(must prefixed by spaces),but with the same line with para-value pair is also comments     |
|		# Blank lines are ommitted                                                                                 |
|		# This is sample.                                                                                          |
|                                                                                                                  |
|         srcsn:1351                    				# souce meter sn                                           |
|         srcch:2                       				# source channel                                           |
|        length:16000                    				# length of EIR                                            |
|        method:wiener                  				# deconvolution method                                     |
|         stack:prestack                				# deconvolution first here                                 |
|         start:0                       				# from the start of time series                            |
|          step:2                       				# two cycles per deconvolution                             |
|        number:2                     					# maximum times of deconvolution                           |
|       notcher:true                    				# nocher on                                                |
|         nfres:[50]                    				# nocher harmonics                                         |
|   wienernoise:0.001                   				# noise added in wiener filter for stationarity            |
|     invfgauss:false                   				# whether gauss filter or not                              |
|invfgausslamda:0.5                     				# guass filter factor, numerical cutoff frequency times    |
|     invflevel:0.001                   				# inverse filter water level                               |
|    invfmethod:plus                    				# inverse method for setting water level                   |
|    invflength:10000000000             				# inverse filter IR length                                 |
|                                                                                                                  |
|                                                                                                                  |
--------------------------------------------------------------------------------------------------------------------

		
2. Interfaces
-------------
   print_fig, the high interface to export figs as files.

   decmain, the high interface to deconvolving the impulse

   
3. References
-------------
   export_fig, an tool box printing graphs as files, like .jpg, .bmp and etc, which exists in E:\Prj\matlablib\export_fig.
   
   
4. Funcitons list
-----------------
	NOTE: For detailed information about some function, try "help (function-name)" within the Command Window


	analyticimpulse
		Syntax: [g,t_s]=analyticimpulse(ps,offset,fs,...)
		Introduction: Calculating the analytic EIR.
		
	analyticstep
		Syntax: [s,t_s]=analyticstep(ps,offset,fs,...)
		Introduction: Calculating the analytic step response.				
	
	gettpn
		Syntax: [tpn,pv]=gettpn(g);
		Introduction:automatically identification of peak values and its correspoinding
					 time (samples)
	
	indximp
		Syntax: [imps,indx=indximpfre(imps,'var')
		Introduction: indexing EIR 
	
	initialdec: 
		Syntax: dec=initialdec;
		Introduction: initializing the deconvlution structure
	
	initialimp
		Syntax: imp=initialimp;
		Introduction: initializing the EIR structure
	
	invfitler
		Syntax:htmp=invfilter(src,rcv,'Level',invflevel,...
                        'Method',invfmethod,'Length',invflen,'Gauss',invfGauss...
                        ,'GaussLamda',invfgausslamda);
		Introduction: deconvolution in the frequency domain

	insersephase
		Syntax:  htmp=inversephase(htmp);
		Introduction:reverse phase if necessary     
	
	listimp
		Syntax:[imptbl,impitems]=listimp(imp)
		Introduction: list EIRs by src-rcv-fre triples
		
	mapimp 
		Syntax:  imp=mapimp(imp);
		Introduction: mapping EIR into subsurface apparent resistivity
	 
	mtemdeconv
		Syntax: imp=mtemdeconv(x,y,imp);
		Introduction:arrange data into the deconvolution
		
	peak	
		Syntax: [maxmins,fmax]=peak(x);
		Introduction: get peaks of time series
	
	peakimp
		Syntax: imp=peakimp(imp)
		Introduction:calculate peak time and peak value of EIR automatically
	
	plotimp
		Syntax:plotimp(imps);
		Introduction: ploting impulse in batch
		
	plotstart
		Syntax: plotstart(m,varargin);
		Introduction:plot mupliple lines for comparison
	
	readdata
		Syntax: [src,rcv,meta]=readdata(srt,srcch,fs);
		Introduction: load MTEM data, from specified directory.
		
	readhead
		Syntax:header=readhead(filename)
		Introduction: read header information of cutted data
		
	readts
		Syntax:[head,data]=readts('1.dat');
		Introduction: read MTEM time series
	
	removedc
		Syntax:y=removedc(x,ssn)
		Introduction: move dc segment-by-segment
	
	saveimp
		Syntax; saveimp(imp);
		Introduction: save EIRs by name it with current time
	
	selectivestack
		Syntax:y=selectivestack(x,varargin)
		Introduction:selective stack based on different rule
		
	setpara
		Syntax:	setpara(imp,'STDIN',6,'File',ffname);
				setpara(imp,'SDIIO',5,'Index',2,'CopyFromIndex',1);
		Introduction: set the control parameter of EIR structure
	
	sortimp
		Syntax:imps=sortimp(imps,varargin)
		Introduction: sort EIRs array by differnt mode
	
	srmatch
		Syntax:srt=srmatch(ffnamelist,srcsn,srcch); 
		Introduction: load data, and match pairs
	
	sub50Hz
		Syntax: g=sub50Hz(g)
		Introduction: remove 50Hz noise
	
	synresp
		Syntax: y=synresp(x,h)
		Introduction: synthetizing the reponse by convolving the input and the EIR
		
	winsincfilter
		Syntax:[y,h]=winsincfilter(x,fc,'lp');
		Introduction:itering by windowed-sinc filter

	writeimp
		Syntax:writeimp(imp);
		Introduction: write EIRs into file
	
	writepara
		Syntax:writepara(fname,imp)
		Introduction: save parameters based on the default values or current settings
	
	
	
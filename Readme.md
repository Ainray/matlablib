Author: Ainray
Date: 20160105
Version: 1.0
Bug-report: wwzhang0421@163.com
Introduction: This library is a simple and general lib of matlab. Now it includes basic DSP tools,
	exporting figures as files interface, deconvolution, and other generallay using tools.


Toolkit list
------------
		deconv, deconvolution toolkit.
		dsp, DSP toolkit
		io, input and output toolkit.
		third libraries:
		    export_fig-master, exporting figures toolkit
                    crewes
                    NMESdata
                    REGU
                    SeismicLab
		
General function list
---------------------
		cellstrindx
			Syntax: x=cellstrindx(c,indx) 
			Introduction:return the partitions of the elements 
		deselect
			Syntax: dx=deselect(x,indx)
			Introduction: De-select vector x by not selecting the elements indexed by indx.
			
		equalen
			Syntax: m=equalen(...)
			Introduction: Align all given vectors with the same length by padding zeros. You can also
						  specify the least length by para-value pair ('LenLimit',20) from at least the
                          third parameter.

        finddisc
			Syntax: m=finddisc(x,sse)
			Introduction: Finding discontinuies based start-setp-end triple.
		
		print_fig
			Syntax: print_fig(fname,fig_type,fig_res)
			Introduction: High interface of exporting figures.
		
		rude
			Syntax: p=rude(rep,vec)
			Introduction: Repeat vector element with different times.
		
		simplewaterfall
			Syntax: simplewaterfall(x,z,step,scale,type,rcv,log,exc)
			Introduction: plotting curves
		
		sort_nat
			Syntax: [cs,index] = sort_nat(c,mode)
			Introduction: Sorting cell array naturally. 
						  For example, if c = {'file1.txt','file2.txt','file10.txt'}, 
						  a normal sort will give you
 								{'file1.txt'  'file10.txt'  'file2.txt'}
 						  whereas, sort_nat will give you
								{'file1.txt'  'file2.txt'  'file10.txt'}
		strfindindx
			Syntax: i,k]=strfindindx(c,pat) 
			Introduction: return the indices of any occurrences of the string 'pat'
						: in the cell array c, and also return the starting indices 
						: if some element of c matching pat according to strfind function
			
		time_vector
			Syntax: t_v=time_vector(x,fs,start)
			Introduction: Give time abscissa for a series.
		
		v2col
			Syntax: c=v2col(v)
			Introduction: Let the vector always be a column vector.
		
		v2row
			Syntax: c=v2row(v)
			Introduction: Let the vector always be a row vector.
			
		var2str
			Syntax: s=var2str(varname)
			Introduction: Return the variable name as a string.
		

Name: io 
Version: 1.0
Author: Ainray
Date: 20160105
Bug report: wwzhang0421@163.com
Introduciton: Basic io operations.
		
Function list
-------------
		cutbinary
			Syntax: state=cutbinary(infname,outfname,start,size,bufsize)
			Introduciton: Extracting a part of binray file.
			
		dualbytes2uint16
			Syntax: num=dualbytes2uint16(dualbytes)
			Introduciton: Convert two bytes into unsigned integer.
		
		quarbytes2int
			Syntax: intvalue=quarbyte2int(quarbytes)
			Introduciton: Convert four bytes into integer.

		sizeof
			Syntax: bytes=sizeof(var)
			Introduciton: Retrieve number of bytes of a variable. 
						  NOTE: Matlab uses Unicode code, 2 bytes for 
						        a character.
		
		tribytes2int
			Syntax: intvalue=tribytes2int(tribytes)
			Introduciton: Convert three bytes into integer.
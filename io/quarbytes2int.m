% function intvalue=quarbytes2int(quarbytes)
% author: Ainray
% date: 2016/01/05
% bug-report: wwzhang0421@163.com
% introduction: covert four bytes into int32
%  input:
%         quarbytes, four-byte array
% output:
%         intvalue, return int32 value.
function intvalue=quarbytes2int(quarbytes) 
quarbytes_sign=bitshift(bitand(quarbytes(4),128),-7);
if quarbytes_sign==0    % sign is positive
    intvalue=bitor(bitshift(quarbytes(4),24),...
						bitor(bitshift(quarbytes(3),16),...
							bitor(bitshift(quarbytes(2),8),quarbytes(1) )...
							 )...
						 );	 					
else
    intvalue=bitor(bitshift(bitand(quarbytes(4),127),24),...
						bitor(bitshift(quarbytes(3),16),...
							bitor(bitshift(quarbytes(2),8),quarbytes(1) )...
							 )...
						 )-bitshift(1,31);	
end
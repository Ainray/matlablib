%function num=dualdualbytes2uint16(dualbytes)
% author: Ainray
% date:2015/12/18
% bug-report:wwzhang0421@163.com
% introduction: convert two dualbytes into an unsigned 16-bit integer.
% 	input: 
%         dualbytes, the dual dualbytes array, high-byte follows low-byte
%  output:
%         num, the converted 16-bit integer
function num=dualdualbytes2uint16(dualbytes)
if( length(dualbytes)~=2)
	error(['Input must be 2-element array: high-byte after low-byte']);
end
num=bitor(bitshift(dualbytes(2),8),dualbytes(1));

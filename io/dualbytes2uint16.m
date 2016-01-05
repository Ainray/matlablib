%function num=dualbytes2uint16(bytes)
% author: Ainray
% date:2015/12/18
% bug-report:wwzhang0421@163.com
% introduction: convert two bytes into an unsigned 16-bit integer.
% 	input: 
%         bytes, the dual bytes array, high-byte follows low-byte
%  output:
%         num, the converted 16-bit integer
function num=dualbytes2uint16(bytes)
if( length(bytes)~=2)
	error(['Input must be 2-element array: high-byte after low-byte']);
end
num=bitor(bitshift(bytes(2),8),bytes(1));

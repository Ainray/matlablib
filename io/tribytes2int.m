% function intvalue=tribytes2int(tribytes)
% author: Ainray
% date: 2016/01/05
% bug-report: wwzhang0421@163.com
% introduction: covert four bytes into int32
%  input:
%         tribytes, four-byte array
% output:
%         intvalue, return int32 value.
function intvalue=tribytes2int(tribytes)
tribytes_sign=bitand(tribytes(3),128)/128;
if tribytes_sign==0    % sign is positive
    intvalue=bitor( bitor(bitshift(tribytes(3),16),bitshift(tribytes(2),8) ),tribytes(1));
else
    intvalue=bitor(bitor( bitshift(bitand(tribytes(3),127),16),...
        bitshift(tribytes(2),8)),tribytes(1))-bitshift(1,23);
end
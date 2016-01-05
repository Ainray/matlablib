function intvalue=tribyte2int(tribyte)
tribyte_sign=bitand(tribyte(3),128)/128;
if tribyte_sign==0    % sign is positive
    intvalue=bitor( bitor(bitshift(tribyte(3),16),bitshift(tribyte(2),8) ),tribyte(1));
else
    intvalue=bitor(bitor( bitshift(bitand(tribyte(3),127),16),...
        bitshift(tribyte(2),8)),tribyte(1))-bitshift(1,23);
end
eorder = 'b';

unsonebyte = uint8(1:240);
unstwobyte = typecast(unsonebyte,'uint16');
unsfourbyte = typecast(unsonebyte,'uint32');
unseightbyte = typecast(unsonebyte,'uint64');
onebyte = typecast(unsonebyte,'int8');
twobyte = typecast(unsonebyte,'int16');
fourbyte = typecast(unsonebyte,'int32');
eightbyte = typecast(unsonebyte,'int64');
singlebyte = typecast(unsonebyte,'single');
doublebyte = typecast(unsonebyte,'double');

f=File('endian.tst','w',eorder);
f.fwrite(onebyte,'int8');
f.fwrite(unsonebyte,'uint8');
f.fwrite(twobyte,'int16');
f.fwrite(unstwobyte,'uint16');
f.fwrite(fourbyte,'int32');
f.fwrite(unsfourbyte,'uint32');
f.fwrite(eightbyte,'int64');
f.fwrite(unseightbyte,'uint64');
f.fwrite(singlebyte,'single');
f.fwrite(doublebyte,'double');

f = File('endian.tst','r',eorder);
bytes = f.fread(Inf,'uint8');

if strcmp(eorder,'b')
    
    %swap bytes for 2 byte read as 1 byte
    idx2(1:2:240) = 2:2:240;
    idx2(2:2:240) = 1:2:240;
    
    %swap bytes for 2 byte read as 1 byte
    idx4(1:4:240) = 4:4:240;
    idx4(2:4:240) = 3:4:240;
    idx4(3:4:240) = 2:4:240;
    idx4(4:4:240) = 1:4:240;
    
    %swap bytes for 8 byte read as 1 byte
    idx8(1:8:240) = 8:8:240;
    idx8(2:8:240) = 7:8:240;
    idx8(3:8:240) = 6:8:240;
    idx8(4:8:240) = 5:8:240;
    idx8(5:8:240) = 4:8:240;
    idx8(6:8:240) = 3:8:240;
    idx8(7:8:240) = 2:8:240;
    idx8(8:8:240) = 1:8:240;
    
    for ii=1:10
        startidx = 1+240*(ii-1);
        endidx = startidx +240 -1;
        
        if ii == 3 || ii == 4
            b = bytes(startidx:endidx);
            b = b(idx2);
            bytes(startidx:endidx) = b;
        end
        
        if ii == 5 || ii == 6 || ii == 9
            b = bytes(startidx:endidx);
            b = b(idx4);
            bytes(startidx:endidx) = b;
        end
        
        if ii == 7 || ii == 8 || ii == 10
            b = bytes(startidx:endidx);
            b = b(idx8);
            bytes(startidx:endidx) = b;
            
        end
    end
    
    plot(bytes,'r-')
end

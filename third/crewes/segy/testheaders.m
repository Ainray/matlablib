filename = '1042.sgy'

sf = SegyFile('1042.sgy');

for ii=1:16
    sf.FormatCode = ii;
    ii
    try
    trchdrs.(sprintf('fc%d',ii)) = sf.Trace.read(1:5,'headers2');
    catch ex
        disp([ex.message])
    end
end


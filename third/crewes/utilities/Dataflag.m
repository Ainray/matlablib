function outarg=Dataflag(action,inarg)
% dataflag ... 0 means normal seismic 'seis', 1 means amp spectra 'aspec', -1 means phase spectra
% 'pspec', 2 means frequencies (fdom) 'freq',
% the userdata of an image is then set to [spaceflag dataflag]

switch action
    case 'get'
        %strip parens if present
        inarg=strrep(inarg,'(','');
        inarg=strrep(inarg,')','');
        
        switch inarg
            case 'seis'
                outarg=0;
            case 'aspec'
                outarg=1;
            case 'pspec'
                outarg=-1;
            case 'freq'
                outarg=2;
        end
        
    case 'unget'
        switch inarg
            case 0
                outarg='seis';
            case 1
                outarg='aspec';
            case -1
                outarg='pspec';
            case 2
                outarg='freq';
        end
end
        
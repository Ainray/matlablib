function outarg=Spaceflag(action,inarg)
% spaceflag ... 0 means input is in (x,t) space, 1 means (x,z) space, 2 means (x,y) space, 3 means
%       (y,t) space, 4 means (y,z) space, 5 means (x,f) or (y,f) space, 6 means (k,f) space,
% the userdata of an image is then set to [spaceflag dataflag]

switch action
    case 'get'
        %strip parens if present
        inarg=strrep(inarg,'(','');
        inarg=strrep(inarg,')','');
        
        switch inarg
            case 'x,t'
                outarg=0;
            case 'x,z'
                outarg=1;
            case 'x,y'
                outarg=2;
            case 'y,t'
                outarg=3;
            case 'y,z'
                outarg=4;
            case 'x,f'
                outarg=5;
            case 'k,f'
                outarg=6;
        end
        
    case 'unget'
        switch inarg
            case 0
                outarg='(x,t)';
            case 1
                outarg='(x,z)';
            case 2
                outarg='(x,y)';
            case 3
                outarg='(y,t)';
            case 4
                outarg='(y,z)';
            case 5
                outarg='(x,f)';
            case 6
                outarg='(k,f)';
        end
end
        
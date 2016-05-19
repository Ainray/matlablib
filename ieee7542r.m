function r=ieee7542r(s,e,f)
s = bin2dec(s);  
e = bin2dec(e);
f = eval(['Fr_bin2dec(.',f,')']);

r=(-1)^s*2^(e-127)*(1+f);
function v=dbmw2v(p,r)
% author: ainray
% date: 20170526
% email: wwzhang0421@163.com
% introduction: convert dBmW into dBmV, with the definition as:
%               1dBmV=20log10([v]mV)=20log10([v]V*1000)=1dBV+60
%               1dBmW=10log10([p]mW)=10log10([p]W*1000)=1dBW+30
%                    =10log10([v]V^2/[R]ohm*1000)
%                    =20log10([v]V)+30-10log10([R]ohm)
%                    =1dBV+30-10log10([R]ohm)
%                    =1dBmv-30-10log10([R]ohm)
% input:
%          v, power in dBmW
%          r, reference resistor in Ohm
% output:
%          p, voltage in dBmV
v=p+30+10*log10(r);
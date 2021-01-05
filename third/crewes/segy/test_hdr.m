function test_hdr(insgyfile)
% 'sevens' test files:
%
% 4. optional trace headers are set:
% type   byte contents
% int16  181  -10*chan
% int32  183  -10*chan
% ibm32  187  -10*chan
% ieee32 191  -10*chan
% ieee64 195  -10*chan
%
% NOTE: SegyFile byte locations are equal to ProMAX byte locations -1
%

disp(['### File: ' insgyfile])
sf = SegyFile(insgyfile); %create SegyFile object

trchdrdef = sf.Trc.HdrDef; %get default Trace Header Definition
idx = sf.Trc.word2idx('CdpX'); %get row number of CdpX, which just happens to be at byte 180

%modify HdrDef
trchdrdef(idx,:)   = {'TestInt16','int16',180,'','TestInt16'};
trchdrdef(idx+1,:) = {'TestInt32','int32',180+2,'','TestInt32'};
trchdrdef(idx+2,:) = {'TestIBM32','ibm32',180+2+4,'','TestIBM32'};
trchdrdef(idx+3,:) = {'TestIEEE32','ieee32',180+2+4+4,'','TestIEEE32'};
trchdrdef(idx+4,:) = {'TestIEEE64','ieee64',180+2+4+4+4,'','TestIEEE64'};
trchdrdef(idx+5,:) = [];

sf.Trc.HdrDef = trchdrdef; %set modified Trace Header Definition

n=figure;
disp(['Figure: ' num2str(n.Number)])

%should get diagonal line xrange 1:100, yrange -10:-1000
% sf.Trc.read([],'TestInt16')
plot(sf.Trc.read([],'TestInt16'),'rv'); hold;
title('Trace Header Test')
plot(sf.Trc.read([],'TestInt32'),'ro');
plot(sf.Trc.read([],'TestIBM32'),'bs');
plot(sf.Trc.read([],'TestIEEE32'),'mx');
plot(sf.Trc.read([],'TestIEEE64'),'k^');
legend('int16','int32','ibm32','ieee32','ieee64')


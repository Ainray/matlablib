
function test_segy(insgyfile, outsgyfile, osegfmt, obytord)
%function test_segy(insgyfile, outsgyfile)
%
% Uses SegyFile to read insgyfile, then uses SegyFile to write outsgyfile
% We then read both files back as uint8 and compare them. If any 
% differences are found warnings are displayed
%

if nargin < 2
    error('Usage: test_segy(''in.sgy'',''out.sgy'')')
end

if nargin < 3
    osegfmt=[];
end
if nargin < 4
    obytord=[];
end

disp(['### Reading File: ' insgyfile])

TXTHDRSIZE = 3200; 
BINHDRSIZE = 400;
TRCHDRSIZE = 240;

% warning('ON');

%Get some basic info about input file
sf = SegyFile(insgyfile,'r');
NTRACE = sf.Trc.TracesInFile;
TRCDATSIZE = sf.Trc.TraceSize-TRCHDRSIZE;
clear sf;

%test readsegy and writesegy
[trcdat,sampint,segfmt,txtfmt,bytord,txthdr,binhdr,exthdr,trchdr] = readsegy(insgyfile,true);
% trcdat = trcdat(1:10,:); %test writing trace shorter than bin hdr nsamp
% w = whos('trcdat'); %test writing trace longer that bin hdr nsamp
% trcdat = [trcdat; zeros(10,NTRACE,w.class)]; %test writing trace longer that bin hdr nsamp
% disp(['Trace one sample one: ' num2str(trcdat(1,1))])
disp(['### Writing File: ' outsgyfile])
if ~isempty(osegfmt)
    segfmt = osegfmt;
end
if ~isempty(obytord)
    bytord = obytord;
end
writesegy(outsgyfile, trcdat, sampint, segfmt, txtfmt, bytord, txthdr, binhdr, exthdr, trchdr);

% warning('ON');

%% Check if in and out are the same
f1 = File(insgyfile,'r');
f2 = File(outsgyfile,'r');

fs1 = File.size(f1.FileID);
fs2 = File.size(f2.FileID);

disp('comparing file sizes')
if ~isequal(fs1-fs2,0)
    warning('Files are different sizes')
end

disp('comparing file txt headers')
d1 = File.read(f1.FileID,TXTHDRSIZE,'uint8=>uint8');
d2 = File.read(f2.FileID,TXTHDRSIZE,'uint8=>uint8');

if sum(d1-d2) %should be zero
    warning('File TxtHdr are different')
end

disp('comparing file bin headers')
d1 = File.read(f1.FileID,BINHDRSIZE,'uint8=>uint8');
d2 = File.read(f2.FileID,BINHDRSIZE,'uint8=>uint8');

if sum(d1-d2) %should be zero
    warning('File BinHdr are different')
end

% disp('comparing traces 1:NTRACE')
disp('comparing traces 1:3')
for ii=1:3 %NTRACE
    d1 = File.read(f1.FileID,TRCHDRSIZE,'uint8=>uint8');
    d2 = File.read(f2.FileID,TRCHDRSIZE,'uint8=>uint8');
    
    if sum(d1-d2) %should be zero
        warning(['TrcHdr ' num2str(ii) ' are different'])
    end
    
    d1 = File.read(f1.FileID,TRCDATSIZE,'uint8=>uint8');
    d2 = File.read(f2.FileID,TRCDATSIZE,'uint8=>uint8');
    
    if sum(d1-d2) %should be zero
        warning(['TrcDat ' num2str(ii) ' are different'])
    end
end

%% last check
f1 = SegyFile(insgyfile);
f2 = SegyFile(outsgyfile);
disp(['Reading back trace 1 from input file: ' insgyfile])
tr1 = f1.Trc.read(1);
disp(['Reading back trace 1 from output file: ' outsgyfile])
tr2 = f2.Trc.read(1);
disp(['Input  trace 1, sample1: ' num2str(tr1(1))]);
disp(['Output trace 1, sample1: ' num2str(tr2(1))]);
s = sum(double(tr1)-double(tr2));
disp(['Sum of trace1-trace2 differences: ' num2str(s)]);
if ~isequal(s,0)
    warning('Trace samples are not identical. Did you change the format code?')
end

   
   
    


%% read everything, header word by header word
filename = 'J:/Data/Brooks/BrooksOct2017/Fotech/Line23_Flag136_Shot3_Sweep2_19.00.31.364002.segy';
disp('** readsegy')
tic; readsegy(filename); toc

%% read everything all at once, plan to modify later
disp('** fread everything')
f = File(filename);
nsamp = 18980;
ntrace = 7346;
nhdr = 240/4; %60

tic;
f.fseek(3600,'bof') %skip file headers
a = fread(f.FileID,[nsamp+nhdr ntrace],'single=>single');
%a(1:60,:)=[]; %nuke trace headers
% hdr = a(1:60,:);
% dat = reshape(a(61:end,:),1,nsamp*ntrace);
% dat = reshape(typecast(dat,'single'),nsamp,ntrace);
toc;

%% read just trace data
disp('** fread just trace data')
f = File(filename);
nsamp = 18980;
ntrace = 7346;
nhdr = 240/4; %60

tic;
f.fseek(3600+240,'bof') %skip file headers
[dat,v] = fread(f.FileID,[nsamp ntrace],'single=>single',nhdr);
toc;

%% read just headers data
disp('** fread just trace data')
f = File(filename);
nsamp = 18980;
ntrace = 7346;
nhdr = 240/4; %60

tic;
f.fseek(3600,'bof') %skip file headers
[dat,v] = fread(f.FileID,[nhdr ntrace],'single=>single',nsamp);
toc;
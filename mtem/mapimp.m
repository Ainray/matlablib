function imp=mapimp(imp)
% author: Ainray
% date: 20160319
% bug-report: wwzhang0421@163.com
% information: fitting calculated impulse with homogeous half-space EIR,
%              mapping it into subsurface resistivity
% input:
%         imp, EIR structure
% output:
%         imp, EIR

% known parameter 

% peak time (samples) for fitting analytic EIR
% peak value for corretion EIR

% calulating analytic EIR
r=abs(imp.meta.offset);  % offset
fs=imp.meta.fs; % sampling rate
ap=4*3.141592653589793*r*r*1e-8/((imp.cpn-1)/imp.meta.fs);  
imp.ag=analyticimpulse(ap,r,fs,imp.para.length); % anayltic EIR

imp.apv=max(imp.ag); % analytic peak value of EIR
imp.rho=ap;   % apparent resistivity

% corretion 
m=imp.apv/imp.cpv;  % correction factor
imp.g=imp.g*m;  % EIR with corretion 

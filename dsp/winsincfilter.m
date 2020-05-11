function [y,h]=winsincfilter(x,fc,varargin)
% author:Ainray
% date:2016319
% bug-report: wwzhang0421@163.com
% information: fitering by windowed-sinc filter
% syntax: y=winsincfilter(x)
%         y=winsincfilter(x,'lp')
% input: 
%          x, the input signal
%         fc, the numerical cut-off frequency, i.e., 50Hz/1600Hz
%             50Hz is the analog cut-off frequency, and 1600Hz is sampling 
%             frequency
%         
%       (optional parameter-value pair)
%      Mode, 'lp'/'hp'/'bp'/'bs'
%            set the filter mode, 'lp', refers to lowpass filter
%                                 'hp', refers to highpass filter
%                                 'bp', refers to bandpass filter
%                                 'bs', refers to bandstop filter
%                                 'gs', gauss filter
%
% output:
%       y, the fitered output
%       h, the filter
p=inputParser;
addRequired(p,'x',@isnumeric);
addRequired(p,'fc',@isnumeric);
addOptional(p,'Mode','lp',@(x) any(validatestring(x,{'lp','hp','bp','bs','gs'})));

parse(p,x,fc,varargin{:});

mode=p.Results.Mode;
N=length(x);
switch mode
    case 'lp'
        h=winsinc_lowpass(fc,16000,2);
        tmp=fconv(x,h);
        y=tmp(16001:16001+N-1);
    case 'hp'
         h=winsinc_highpass(fc,64000,2);
         tmp=fconv(x,h);
         y=tmp(64001:64001+N-1);
    case 'bp'
          h=winsinc_bandpass(fc,64000,2);
          tmp=fconv(x,h);
          y=tmp(64001:64001+N-1);
    case 'gs'
         [g,G]=dft_gauss(16001,fc,'one-side');
         tmp=fconv(x,g);
         y=tmp(8001:8001+N-1);
    case 'bs'
         h=winsinc_bandstop(fc,64000,2);
         tmp=fconv(x,h);
         y=tmp(64001:64001+N-1);
         
end
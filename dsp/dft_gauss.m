% function [...]=gauss_src(N,lamda,mode)
% author: Ainray
% date: 20160313
% bug report: wwzhang0421@163.com
% information: calculating gauss window.
%              In the freqency:
%               W=exp(-0.5*(2*pi*[-N/2:N/2]/N)^2/alpha^2), for symmetric mode
%               Set lamda=sqrt(2)/pi*alpha,then,  
%                    W=exp(-([-N/2:N/2]/(N/2))^2/lamda^2)
%               That is , lamda=sqrt(2)/pi/STD
%               The correspoinding time-domain window is also a gauss-funciton
%                    w=1/sqrt(2)/pi*exp(-t^2/2/sigma^2)
%                where,   
%                     sigma(i.e. STD)=sqrt(2)/pi/lamda
%                We have,
%                    w=0.5*sqrt(pi)*lamda*exp(-0.25*pi^2*lamda^2*t^2)
%               Examples:
%                 W=dft_gauss(10), return 11 samples of sysmmtric window
%                 W=dft_gauss(10,'one-side'), return 10 samples window,
%                 with only the left end point (1/e)
% syntax:
%               W=gauss_src(N,lamda,mode)  
%       one output, only frequency window
%               [w,W]=gauss_src(N,lamda,mode)
%       return both time and freqency window
% input:
%         N, the number of samples
%     lamda, Twice of the cut-off frequency: 2*f0. Let alpha  be the STD in 
%            frequency domain, just reciprocal of time-domain STD. If the 
%            frequency w0 in which the amplitude decay to 1/e is defined as 
%            the cut-off freqency, then
%                       w0=sqrt(2)*alpha, and f0=alpha/(sqrt(2)*pi). 
%            Substitute alpha with lamda, we have:
%                       f0=0.5*lamda, w0=pi*lamda
%            so if we choose, f0=1/4, i.e., half the Nyquist freqency, we should
%            set lamda=1/2, corresponding to alpha=pi/sqrt(2)/2
%               In Matlab , 'alpha' corresponds to sqrt(2)/lamda=pi/STD.In the 
%            default case, where alpha=2.5, the band width is sqrt(2)/5.
%            So if we set lamda=sqrt(2)/alpha, then the resulted window coincides 
%            with Matlab's.
%      mode, 'symmetric', the window have odd samples.if N is even, padding one sample.
%                         the window have sysmmetric zeros at both left and right ends.
%            'one-side',  return N samples, only the left zero is guaranted.
% output:
%         W, the freqency window, shiffted so the window
%            is even about zero( with respect to periodal
%            extension)
%         w, the corresponding time window
function varargout=dft_gauss(N,lamda,mode)
if nargin<2
   lamda=0.5;
end
if nargin<3
    mode='symmetric';
end
while strcmp(mode,'symmetric')==0 && strcmp(mode,'one-side')==0
    mode=input('mode must be either ''symmetric'' or ''one-side'': ');
end

if strcmp(mode,'symmetric')
    if mod(N,2)==0  
        N=N+1; % padding one sample
    end
    n=(-(N-1)/2:(N-1)/2)';
    wf=exp(-(2*n/(N-1)).^2/lamda/lamda);
    wf=dft_shift(wf,(N-1)/2);
    % time window
    wt=0.5*sqrt(pi)*lamda*exp(-0.25*pi^2*lamda^2*n.^2);
else
    n=[-floor(N/2):floor((N+1)/2)-1]';
    wf=exp(-(n/floor(N/2)).^2/lamda/lamda);
    wf=dft_shift(wf,floor(N/2));
    wt=0.5*sqrt(pi)*lamda*exp(-0.25*pi^2*lamda^2*n.^2);
end

if nargout>3
    error('Wrong output arguments\n');
elseif nargout==1
    varargout{1}=wf;
else
    varargout{1}=wt;
    varargout{2}=wf;
end












% %function [gs t_s]=gauss_src(N,fs,w0,mui)
% % author: Ainray
% % date: 2015/09/14
% % modified: 2015/4/16,2015/7/28
% % bug report: wwzhang0421@163.com
% % input:
% %              N, the number of source wavelet samples
% %             fs, the sampling rate
% %          w0, a factor control the shape,default w0=5, with
% %                 -108.6dB attenuation at the end: exp(-0.5*([-N/2:N/2]/(N/2)
% %            mui, mean
% % output:
% %             gs, the gaussian source wavelet
% %            t_s, the time indices
% function[gs,t_s]=gauss_src(N,fs,w0,mui)
% if nargin<2
%     fs=1;
% end
% if nargin<3
%     w0=5;
% end
% if nargin<4
%     mui=0;
% end
% gs=gausswin(N,w0);
% t_s=time_vector(gs,fs)+mui/fs-(floor((N+1)/2)-1)/fs;
% 
% 

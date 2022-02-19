function I = bmode(IQ,DR)

%BMODE   B-mode image from I/Q signals
%   BMODE(IQ,DR) converts the I/Q signals (in IQ) to 8-bit log-compressed
%   ultrasound images with a dynamic range DR (in dB). IQ is a complex
%   whose real (imaginary) part contains the inphase (quadrature)
%   component.
%
%   BMODE(IQ) uses DR = 40 dB;
%
%
%   Example:
%   -------
%   %-- Analyze undersampled RF signals and generate B-mode images
%   % Download experimental data (128-element linear array + rotating disk) 
%   load('PWI_disk.mat')
%   % Demodulate the RF signals with RF2IQ.
%   IQ = rf2iq(RF,param);
%   % Create a 2.5-cm-by-2.5-cm image grid.
%   dx = 1e-4; % grid x-step (in m)
%   dz = 1e-4; % grid z-step (in m)
%   [x,z] = meshgrid(-1.25e-2:dx:1.25e-2,1e-2:dz:3.5e-2);
%   % Create a Delay-And-Sum DAS matrix with DASMTX.
%   param.fnumber = []; % an f-number will be determined by DASMTX
%   M = dasmtx(1i*size(IQ),x,z,param,'nearest');
%   % Beamform the I/Q signals.
%   IQb = M*reshape(IQ,[],32);
%   IQb = reshape(IQb,[size(x) 32]);
%   % Create the B-mode images with a -30dB range.
%   I = bmode(IQb,30);
%   % Display four B-mode images.
%   for k = 1:4
%   subplot(2,2,k)
%   imshow(I(:,:,10*k-9))
%   axis off
%   title(['frame #' int2str(10*k-9)])
%   end
%   colormap gray
%
%
%   This function is part of MUST (Matlab UltraSound Toolbox).
%   MUST (c) 2020 Damien Garcia, LGPL-3.0-or-later
%
%   See also RF2IQ, TGC, SPTRACK.
%
%   -- Damien Garcia -- 2020/06
%   website: <a
%   href="matlab:web('https://www.biomecardio.com')">www.BiomeCardio.com</a>


narginchk(1,2)
% assert(~isreal(IQ),'IQ must be complex')

if nargin==1, DR = 40; end % dynamic range in dB
assert(DR>0,'The dynamic range DR (in dB) must be >0')

I = abs(IQ); % real envelope
I = 20*log10(I/max(I,[],'all'))+DR;
I = uint8(255*I/DR); % 8-bit log-compressed image
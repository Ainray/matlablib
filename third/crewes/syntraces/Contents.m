% CREWES synthetic seismogram toolbox
% This contains tools to create convolutional synthetic seismograms
% 
%Wavelets
% ORMSBY - Creates an Ormsby bandpass filter
% RICKER - creates a Ricker wavelet
% WAVELOW - a Butterworth low pass wavelet, 0 or min phase.
% WAVEMIN - creates a minimum phase wavelet for impulsive sources
% WAVEZ - creates a zero phase wavelet the same amplitude spectrum as WAVEMIN
% WAVEVIB - creates a vibroseis (Klauder) wavelet
% SURFACEWAVE - simulates a surface wave waveform
% SWEEP - generate a linear Vibroseis sweep
% TNTAMP - create an amplitude spectrum for an impulsive source 
% WAVEBUTTER - Butterworth bandpass wavelet
% WAVEDYN - minimum phase wavelet for impulsive sources (try WAVEMIN first)
% WAVENORM - normalize (rescale) a wavelet
% WAVESEIS - Create a zero phase wavelet with the amplitude spectrum of a seismic trace
% WAVEVIB - Create a zero-phase Klauder wavelet by autocorrelating a sweep
%
%Time series
% COMB - create a comb function (spikes every n samples)
% IMPULSE - create a simple time series with an impulse in it
% REFLEC - synthetic pseudo random reflectivity
% RNOISE - create a random noise signal with a given s/n
% SPIKE - create a signal with a single impulse in it
% SWEEP - generate a Vibroseis sweep
% WATERBTM - compute the zero offset water bottom response
%
% Synthetic seismograms
% SEISMOGRAM - compute a 1-D normal incidence seismogram using the Goupillaud model.
% SEISMO - a simplified interface to SEISMOGRAM
% SEISMO1D - improved/simplified version of SEISMOGRAM
%
% Zoeppritz equations
% ZOEPPRITZ - calculate Zoeppritz reflection and transmission coefficients
% ZOEPPLOT - Untility to plot Zoeppritz versus offset or angle
%
% NOTE: See QTOOLS for a description of tools that can be applied to the
% synthetics made here to simulate constant-Q attenuation
%

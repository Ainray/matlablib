%
% FGFT Interpolation pacakge
%
% This package provides Matlab codes for the Interpolation of seismic data 
% using a Fast Generalized Fourier Transform (FGFT). To use the package run 
% the programs which start with test_*.m inside a Matlab environment. There 
% are several 1D synthetic examples such as Chirp, Sine, and Box functions, 
% as well as  synthetic seismic data examples.
%
% B_SPLINE_WINDOW - Create a B-Spline window by consecutive convolution of 
%     box car functions
% FORWARD_FGFT - Perform time-frequency analysis (Gabor, S-Transform, etc.) 
%     in a very efficient way
% FX_FGFT_INTERPOLATION - Interpolate regularly sampled seismic traces 
%     using FGFT
% FX_FGFT_IRREGULAR_INTERPOLATION - Interpolate irregularly sampled seismic
%     traces using FGFT
% INVERSE_FGFT - Compute the inverse FGFT
% IRLS_FITTING_FGFT - Fit available data using iterative reweighting least 
%     squares (IRLS) FGFT
% LS_MASK_FITTING_FGFT - Fit a known mask function and available data 
%     using FGFT
% MATRIX_SCALING - Project values from array(nx1,ny1) to array(nx2, ny2) 
%     using nearest neighbor interpolation
% MY_CHIRP - Compute a hyperbolic chirp
% PLOT_FGFT - Plot FGFT coefficients 
% SCALE_FGFT - Remove the SQRT(nh) factor from forward transformed FGFT data
% SETIT - Set plot fonts and colors
% UPDATE_MASK_FGFT - Update the mask function for IRLS fitting of FGFT
%


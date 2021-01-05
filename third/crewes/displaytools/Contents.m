% CREWES display tools
%
% Seismic plotting
%
% NOTE: If you are unsure, then use SEISPLOT as your default seismic viewer. However, if you have
% only a few traces then TRPLOT and DBSPEC give useful time domain and frequency domain views. If
% you need event picking (2D) use PLOTIMAGE. If you need to see wiggle traces use PLOTSEISMIC. If
% you need to browse a 3D dataset use PLOTIMAGE3D.
%
%  Seismic Image viewers
%  PLOTIMAGE - Image display utility for seismic matrices (fast and full featured, new figure window) Includes interactive picking.
%  PLOTIMAGE3D - Image display for 3D seismic matrices. GUI interface for 3D browsing. See also MAKE3DVOL.
%  SEISPLOT - simplified viewer much like plotimage but with less overhead. Opens a new figure window.
%  SEISPLOTA - like seisplot except that it plots in the current axes. Useful with subplot.
%  SEISPLOTTWO - Like seisplot except that two axes are created allowing comparison of two different seismic matrices.
%  SEISPLOTCOMPARE - A seisplot based utility to compared two seismic gathers or sections.
%  SEISPLOTFK - Like seisplot except that two axes are created with the first showing the x-t view and the second showing the f-k view.
%  SEISPLOTFKFILT - Based on seisplot allowing Interactive FK filtering
%  SEISPLOTFX - Like seisplot except that two axes are created with the first showing the x-t view and the second showing the f-x view.
%  SEISPLOTFDOM - like seisplot but with interactive dominant frequency calculations
%  SEISPLOTDECON - like seisplot but with interactive Wiener decon
%  SEISPLOTGABDECON - like seisplot but with interactive Gabor decon
%  SEISPLOTFILT - like seisplot but with interactive bandpass filtering
%  SEISPLOTDIFF - like seisplot but includes a difference of two sections
%  SEISPLOTSVD_FILT - like seisplot but enables interactive SVD filtering
%  SEISPLOTSVD_SEP - like seisplot but enables interactive SVD separation into Gross and Detail.
%  SEISPLOTSPECD - like seisplot but with interactive spectral decomposition
%  SEISPLOTTVS - like seisplot but has data on left and spectra in three time windows on right.
%  PLOTGATHERS - Display a suite of seismic gathers in a way that facilitates comparison (new figure window).
%  PLOTSNAPS - Display a set of wavefield snapshots superimposed on a velocity model (new figure window) (Makes great movies!!).
%  PLOTAXES - Display a set of similar x-y plots in a vertical set of axes for easy comparison (new figure window).
%  SEISCOMPARE - Compare two seismic sections (must have the same geometry)
%  SPECD_VIEWER - GUI to display a vertical section spectral decomp (see specdecomp in the seismic toolbox)
%
%  Helpful vieweres (in the segy toolbox, type help segy)
%  VIEWTEXTHEADER - view a SEGY text header
%  VIEWBINHEADER - view a SEGY binary header
%  VIEWTRACEHEADERS - view SEGY trace headers
%
%  NOTE: PLOTGATHERS, PLOTSNAPS, and PLOTAXES are similar tools that all facilitate the anaysis of
%  suites of data. They also make movies and PowerPoint slides very easy.  See the help for each of
%  them for more information.
%
%  MAKE3DVOL - reshape a 3D dataset into a 3D matrix for viewing with plotimage3D
% 
%  Single trace (or a few traces) viewers:
%  DBSPEC - compute and plot the Fourier amplitude spectrum of a few traces using a decibel scale
%  TRPLOT - utility to make a comparative plot of a few traces. Similar to DBSPEC but in the time domain
%  TVDBSPEC - examine spectra in 3 different windows. Similar to DBSPEC but shows time variation.
%
%  Wiggle trace viewers and plotting
%  PLOTSEIS - Plot a seismic matrix (trace gather) using WTVA format (rudimentary display in current figure)
%  PLOTSEISMIC - Plot a seismic matrix with WTVA format and UI controls (new figure window)
%  WTVA - plot a seismic trace in wiggle-trace variable-area format. This is the fundamental WTVA tool and is used by PLOTSEIS and PLOTSEISMIC
%
% Colormaps
%  LISTCOLORMAPS - List all colormaps
%  LISTMATCOLORMAPS - List Matlab colormaps
%  LISTCRCOLORMAPS - List CREWES colormaps
%  PLOTCOLORMAPS - Plot colormaps returned by listcolormaps
%  
% Utilities
%  AXESLABELSIZE - change the size of axes labels
%  AXESTITLESIZE - change the size of axes titles
%  BIGFIG - enlarges a figure to an optimal size for a slide
%  BIGFONT - increases (or decreases) fontsize in a figure
%  BOLDLINES - changes the thickness of lines and the size of markers
%  CLEARPICKS - clear (delete) the picks in a figure
%  CLIPPING - automatically determine clipping levels when using imagesc
%  FLIPX - script to flip the direction of the x (horizontal) axis
%  FLIPY - script to flip the direction of the y (vertical) axis
%  GREYFIG - changes the current figure's background to grey
%  HIDEUI - hide (or restore) user interface controls (see UNHIDEUI)
%  LEGENDFONTSIZE - change the font size in a legend
%  LINESGRAY - gray level plotting of line data for publications
%  PLOTBLOCKY - plot a piecewise constant function as a staircase
%  PITITLE - like Matlab's title but also changes the Figure name.
%  POSNFIG - position a figure anywhere. Default is center of screen.
%  PREPFIG - simple utility to prepare a graphic for publication
%  PREPFIGA - alternative to prepfig that enlarges fonts a bit less
%  PREPFIGUI - similar to prepfig excepth that ui controls are not hidden
%  SHOWINFO - utility to show user information in tabbed scrolling panels. See seisplotdecon for an example.
%  TITLEFONTSIZE - change the font size in figure/axes titles
%  UNHIDEUI - restore user interface controls (see HIDEUI)
%  UISCROLLPANEL - makes a vertically scrolling uipanel
%  UISCROLLPANEL_HOR - makes a horizontally scrolling uipanel
%  WHITEFIG - change a figure background to white (for publication)
%  WINEXTRACTOR - visualize and adjust a windowed area on a single trace
%  XOFF - turn off the x axis labels and tick marks
%  YOFF - turn off the y axis labels and tick marks
%  

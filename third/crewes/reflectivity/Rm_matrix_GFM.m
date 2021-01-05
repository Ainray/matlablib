function rm = Rm_matrix(nL,a,b,rho,S2Velocity,uuC,uC2,uC,thick,wC,z_Source)                    
% Computation of reflection and transmission coefficients for a stack of layers
%   due to the incident waves from layer above it 
%
% nL ... number of layers (also lengths of a,b,rho)
% a ... vertical p slowness (vector)
% b ... vertical s slowness (vector)
% rho ... density (vector)
% S2Velocity ... shear velocity squared (complex) (vector)
% uuC ... complex horizontal slowness squared (scalar)
% uC2 ... 2 times uC (scalar)
% uC ... complex horizontal slowness (scalar)
% thick ... vector of layer thisknesses
% wC ... complex angular frequency
% z_Source ... source depth
%
% rm ... reflectivity matrix (2x2 complex)
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE

%           (Muller (1985), Table 1)

% the reflectivity coeficients corresponding to the top of the bottom layer
mB = RT_GFM(nL-1,nL,a,b,rho,S2Velocity,uuC,uC2,uC);


% Recursively build up the reflectivity and transmission matrices in a
% system consisting of 'nL' blocks of homogeneous layers from the top of the bottom
% (nL'th) layer to the top of the '2nd' layer (n = 2)

for n = nL-1 : -1 : 2
    
    % vertical slowness of the #nL layer
    am = a(n);
    bm = b(n);
    amI = complex(-imag(am),real(am));
    bmI = complex(-imag(bm),real(bm));
    
    % the phase shift matrix (Muller (1985), Equation (23))
    %wThick = -  2 * wC * thick(nL);
    wThick = -  2 * wC * thick(n);
    E(1,1) = exp(amI * wThick);
    E(1,2) = exp((amI + bmI) * wThick*0.5);
    E(2,1) = E(1,2);
    E(2,2) = exp(bmI * wThick);
    
    % applying phase-shift (Muller (1985), Equation (22))
    mT = mB .* E;
    
    % the reflectivity an transmission coeficients for the top of layer i
    [rD,tD,rU,tU] = RT_GFM(n-1,n,a,b,rho,S2Velocity,uuC,uC2,uC);
    
    % computing Equation (31)(Muller, 1985)
    mTtD = mT * tD;
    AA=eye(2) - (mT * rU);
    AAI=[AA(2,2),-AA(1,2);-AA(2,1),AA(1,1)]/(AA(1,1)*AA(2,2)-AA(1,2)*AA(2,1));
    mB=rD + (tU * AAI * mTtD);
    
end

% vertical slowness of the first layer
am = a(1);
bm = b(1);
amI = complex(-imag(am),real(am));
bmI = complex(-imag(bm),real(bm));

% computing the final phase-shift matrix
wThick = -  2 * wC * (thick(1)-z_Source);% To the level of source depth, not the surface (See R^- matrix in Muller 1985)
E(1,1) = exp(amI * wThick);
E(1,2) = exp((amI + bmI) * wThick* 0.5);
E(2,1) = E(1,2);
E(2,2) = exp(bmI * wThick);

% applying the final phase-shift
rm = mB .* E; 

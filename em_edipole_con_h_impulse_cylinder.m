function s = em_edipole_con_h_impulse_cylinder(r, z, t, con)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: h filed of electrical dipole in cylinder coordinates in
%               conducting media
%   funciton name:  em, electromagnetic
%                   edipole, electric dipole
%                   con, conductive medium
%                   e, eletric field
%                   impulse, impulse response
%                   cylinder, cylinder coordinates
    if(t(1) <eps)
        t(1)=eps;
    end
    
    mu0 = 4*pi*1e-7;
    eta = sqrt(mu0*con./t/4);
    rr2 = r.*r + z.*z;
    rr = sqrt(rr2);
    
    eta2rr2 = eta.^2*rr2;
    eta3 = eta.^3;
    
    coef = eta3*r*pi^(-1.5)/2./t;
    s= coef.*exp(-eta2rr2);
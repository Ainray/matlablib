function s = em_edipole_con_h_step_cylinder(r, z, t, con)
% author: Ainray
% date: 20210923
% email: wwzhang0421@163.com
% introduction: h filed of electrical dipole in cylinder coordinates in
%               conducting media
%   funciton name:  em, electromagnetic
%                   edipole, electric dipole
%                   con, conductive medium
%                   h, magnetic field
%                   step, step response
%                   cylinder, cylinder coordinates
    if(t(1) <eps)
        t(1)=eps;
    end
    
    mu0 = 4*pi*1e-7;
    eta = sqrt(mu0*con./t/4);
    rr2 = r.*r + z.*z;
    rr = sqrt(rr2);
    
    etarr = eta*rr;
    eta2rr2 = eta.^2*rr2;
    
    coef = r/rr^3/4/pi;
    s= coef.*(2/sqrt(pi)*etarr.*exp(-eta2rr2) + erfc(etarr));
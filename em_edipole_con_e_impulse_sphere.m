function s = em_edipole_con_e_impulse_sphere(rho, z, t, con)
% author: Ainray
% date: 20210923
% email: wwzhang0421@163.com
% introduction: e filed of electrical dipole in spherical coordinates in conducting media
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
    eta = sqrt(mu0*con*0.25./t);
    r = sqrt(rho.*rho + z.*z);

    eta2r2 = eta.^2*r*r;
    eta3 = eta.^3;
    coef = eta3*pi^(-1.5)/con./t;
    erho = coef.*exp(-eta2r2).*eta2r2*rho*z/r^2;
    ez = coef.*exp(-eta2r2).*(1-eta2r2*(1-z^2/r^2));
    s(:,1) = erho;
    s(:,2) = ez;
    s(1,:) = 0;
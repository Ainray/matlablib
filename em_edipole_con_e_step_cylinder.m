function s = em_edipole_con_e_step_cylinder(r, z, t, con)
% author: Ainray
% date: 20210916
% email: wwzhang0421@163.com
% introduction: e filed of electrical dipole in cylinder coordinates in
%               conducting media
%   funciton name:  em, electromagnetic
%                   edipole, electric dipole
%                   con, conductive medium
%                   e, eletric field
%                   step, step response
%                   cylinder, cylinder coordinates
    mu0 = 4*pi*1e-7;
    eta = sqrt(mu0*con./t/4);
    rr = sqrt(r.*r + z.*z);
   
    etarr = eta*rr;
    eta2rr2 = eta.^2*rr*rr;
    eta3rr3 = eta.^3*rr^3;
 
    coef = 1/(4*pi*con*rr^3);
    
    er = ((4/sqrt(pi)*eta3rr3+6/sqrt(pi)*etarr).*exp(-eta2rr2)+3*erfc(etarr))*r*z/rr^2;
    
    ez = ((4/sqrt(pi)*eta3rr3+6/sqrt(pi)*etarr).*exp(-eta2rr2)+3*erfc(etarr))*z*z/rr^2;
    ez = ez - ((4/sqrt(pi)*eta3rr3+2/sqrt(pi)*etarr).*exp(-eta2rr2)+erfc(etarr));
    
    s(:,1) = er;
    s(:,2) = ez;
    
    s = s * coef;
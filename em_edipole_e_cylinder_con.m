function s = em_edipole_e_cylinder_con(rho, z, t, t0, amp, con)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: e filed of electrical dipole in cylinder coordinates in
%               conducting media
    mu0 = 4*pi*1e-7;
    eta = sqrt(mu0*con*0.25./t);
    detadt = -0.5./(eta.*t);
    r = sqrt(rho.*rho + z.*z);
    
    pt = em_source_gauss(t0, t-r/c0, amp);
    dpt = em_source_gauss(t0, t-r/c0,amp,1);
    dpt2 = em_source_gauss(t0,t-r/c0,amp,2);
    s=zeros(length(t),2);  
    s(:,1) = mu0/(4*pi*r)*(3*rho*z/r^2*(c0/r*dpt+c0*c0/r/r*pt)+rho*z/r^2*dpt2);
    s(:,2) = mu0/(4*pi*r)*((3*z^2/r^2-1)*(c0/r*dpt+c0*c0/r/r*pt) - rho^2/r^2*dpt2);
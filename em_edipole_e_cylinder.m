function s = em_edipole_e_cylinder(r, z, t, t0, amp)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: e filed of electrical dipole in cylinder coordinates
    mu0 = 4*pi*1e-7;
    c0 = 299792458;
    rr = sqrt(r.*r + z.*z);
    pt = em_source_gauss(t0, t-rr/c0, amp);
    dpt = em_source_gauss(t0, t-rr/c0,amp,1);
    dpt2 = em_source_gauss(t0,t-rr/c0,amp,2);
    s=zeros(length(t),2);  
    s(:,1) = mu0/(4*pi*rr)*(3*r*z/rr^2*(c0/rr*dpt+c0*c0/rr/rr*pt)+r*z/rr^2*dpt2);
    s(:,2) = mu0/(4*pi*rr)*((3*z^2/rr^2-1)*(c0/rr*dpt+c0*c0/rr/rr*pt)-r^2/rr^2*dpt2);
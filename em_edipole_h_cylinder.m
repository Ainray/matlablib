function s = em_edipole_h_cylinder(rho, z, t, t0, amp)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: h filed of electrical dipole in cylinder coordinates
    c0 = 299792458;
    r = sqrt(rho^2 + z^2);
    dpt = em_source_gauss(t0, t-r/c0,  amp, 1);
    dpt2 = em_source_gauss(t0, t-r/c0, amp, 2);
    s = 1/(4*pi*r^2)*rho/r*(r/c0*dpt2 + dpt);
end
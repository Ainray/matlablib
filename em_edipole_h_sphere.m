function s = em_edipole_h_sphere(r, theta, t, t0, amp)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: e filed of electrical dipole in sphere (also cylinder) coordinates
    c0 = 299792458;
    dpt = em_source_gauss(t0, t-r/c0,  amp, 1);
    dpt2 = em_source_gauss(t0, t-r/c0, amp, 2);
    s = 1/(4*pi*r^2)*sin(theta)*(r/c0*dpt2 + dpt);
end
function s = em_edipole_free_e_any_sphere(r, theta, t, p)
% author: Ainray
% date: 20210826
% email: wwzhang0421@163.com
% introduction: e filed of electrical dipole in spherical coordinates
%   funciton name:  em, electromagnetic
%                   edipole, electric dipole
%                   free, free space
%                   e, eletric field
%                   any, atrbitray source function specified by dipole moment p
%                   sphere, spherical coordinates
    mu0 = 4*pi*1e-7;
    c0 = 299792458;
    
    pt = p9%em_source_gauss(t0, t-r/c0, amp);
    dpt = em_source_gauss(t0, t-r/c0,amp,1);
    dpt2 = em_source_gauss(t0,t-r/c0,amp,2);
    s=zeros(length(t),2);  
    s(:,1) = mu0/(4*pi*r)* 2 *cos(theta)*(c0/r*dpt+c0*c0/r/r*pt);
    s(:,2) = mu0/(4*pi*r)* sin(theta)*(dpt2 + c0/r*dpt+c0*c0/r/r*pt);
end
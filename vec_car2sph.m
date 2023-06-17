function [vr, vt, vphi] = vec_car2sph(vc, coords)
% author: Ainray
% date: 20220816
% bug-report: wwzhang0421@163.com
% introduction: convert vector compoenet from spheric coordinates to
%               Cartisian coordinates
%　vc, coords, vs are 3*N matrix

x = coords(1,:);
y = coords(2,:);
z = coords(3,:);

r = sqrt(x .* x + y .* y + z .* z);
rho = sqrt(x.*x + y.*y);
sintheta = rho./r;
costheta = z./r;
sinphi = y./rho;
cosphi = x./rho;

n = size(vc, 2);
vs = zeros(size(vc));
for i=1:n
    vs(:,i) = [sintheta(i) .* cosphi(i) sintheta(i) .* sinphi(i) costheta(i); ...
        costheta(i) .* cosphi(i) costheta(i) .* sinphi(i) -sintheta(i); ...
        -sinphi(i) cosphi(i) 0] * vc(:,i);
end
vr = vs(1,:)';
vt = vs(2,:)';
vphi = vs(3,:)';






    



















































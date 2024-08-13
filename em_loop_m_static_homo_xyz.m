function H = em_loop_m_static_homo_xyz(x, y, z, a, I)
% author: Ainray
% date: 20240813
% email: wwzhang0421@163.com
% introduction: H filed of loop in cartisian coordinates
%       test:
%           H = em_loop_m_static_homo_xyz(0,0,1,0.17,1700)
%               result: 23.5373 (A/m)
%           https://www.e-magnetica.pl/doku.php/calculator/current_loop_axis
     n = length(x);
     H = zeros(n, 3);
     for i=1:n
         x0 = x(i);
         y0 = y(i);
         z0 = z(i);
         defun = @(theta) ((x0 - a*cos(theta)).^2 + (y0 - a*sin(theta)).^2 + z0^2).^(3/2);
         xfun = @(theta) (cos(theta).*(y0 - a * sin(theta)))./defun(theta);
         yfun = @(theta) (sin(theta).*(x0 - a * cos(theta)))./defun(theta);
         zfun = @(theta) (a - x0 * cos(theta) - y0 * sin(theta))./defun(theta);
         
         H(i,1) = I*a*z(i)/4/pi*integral(xfun, 0, 2*pi);
         H(i,2) = I*a*z(i)/4/pi*integral(yfun, 0, 2*pi);
         H(i,3) = I*a/4/pi*integral(zfun, 0, 2*pi);
     end
end
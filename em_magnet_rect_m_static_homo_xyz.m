function B = em_magnet_rect_m_static_homo_xyz(x, y, z, a, b, h, Br)
% author: Ainray
% date: 20240813
% email: wwzhang0421@163.com
% introduction: B filed of loop in cartisian coordinates
% reference: 
%      [1] 施伟, 周强和刘斌, 《基于旋转永磁体的超低频机械天线电磁特性分析》, 物理学报, 期 18, 页 314–324, 2019.
%      [2] 刘宏娟, 《矩形永磁体三维磁场空间分布研究》, 2006.
%
% test:
%           B = em_magnet_rect_m_static_homo_xyz(0, 0, 1.15, 0.03, 0.03, 0.3, 0.8)
%               resutl: 2.3385e5 (T)
%           B = em_magnet_rect_m_static_homo_xyz(1.015, 1.015, 1.15, 0.03, 0.03, 0.3, 0.8)
%               result: [0.2855    0.2855    0.0447]*1e-5 (T)
%           https://www.integratedsoft.com/calculator/rectangular-bar-magnet-calculator

     n = length(x);
     B = zeros(n, 3);
     for i=1:n
         x0 = x(i);
         y0 = y(i);
         z0 = z(i);
         
         xdefun1 = @(yp, zp) (( x0 - a/2)^2 + (y0 - yp).^2 + (z0 - zp).^2).^(3/2);
         xdefun2 = @(yp, zp) (( x0 + a/2)^2 + (y0 - yp).^2 + (z0 - zp).^2).^(3/2);
         
         ydefun1 = @(xp, zp) (( x0 - xp).^2 + (y0 - b/2)^2 + (z0 - zp).^2).^(3/2);
         ydefun2 = @(xp, zp) (( x0 - xp).^2 + (y0 + b/2)^2 + (z0 - zp).^2).^(3/2);
           
         xfun = @(yp, zp) (z0 - zp).*(1./xdefun1(yp,zp) - 1./xdefun2(yp,zp));
         yfun = @(xp, zp) (z0 - zp).*(1./ydefun1(xp,zp) - 1./ydefun2(xp,zp));
         zfun1 = @(yp,zp) (a/2 - x0)./xdefun1(yp, zp) + (a/2 + x0) ./ xdefun2(yp, zp);
         zfun2 = @(xp,zp) (b/2 - y0)./ydefun1(xp, zp) + (b/2 + y0) ./ ydefun2(xp, zp);
         
         B(i,1) = Br/4/pi*integral2(xfun, -b/2, b/2, -h/2, h/2);
         B(i,2) = Br/4/pi*integral2(yfun, -a/2, a/2, -h/2, h/2);
         B(i,3) = Br/4/pi*(integral2(zfun1, -b/2, b/2, -h/2, h/2) + integral2(zfun2, -a/2, a/2, -h/2, h/2));
     end
end
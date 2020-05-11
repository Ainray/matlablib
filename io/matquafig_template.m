%matquafig_load;
% plot here
% -------------------------------------------------------------------------
f = @(x) x.^2;
g = @(x) 5*sin(x)+5;
dmn = -pi:0.001:pi;
xeq = dmn(abs(f(dmn) - g(dmn)) < 0.002);
plot(dmn,f(dmn),'b-',dmn, g(dmn),'r--',xeq,f(xeq),'g*','LineWidth',lw,'MarkerSize',msz); %<- Specify plot properites
xlim([-pi pi]);
legend('f(x)', 'g(x)', 'f(x)=g(x)', 'Location', 'SouthEast');
xlabel('x');
title('Improved Example Figure');

% Set Tick Marks
set(gca,'XTick',-3:3);
set(gca,'YTick',0:10);

% file setting
fname='freimp_p1_impscale';
type='-depsc';
% res='-r300' %300dpi
res='-r600'; %600dpi
%type='-djpeg'
%type='-dpng'
% -------------------------------------------------------------------------
% matquafig_save;
%% anaylitic
% r = 0.5;
% t=(0:263)*83.333e-12;
% theta = pi/2;
% t0 = 2e-9; 
% amp = 10^-10;
% s = em_edipole_e_sphere(r,theta,t, t0, amp);
% Ez = s(:,2);
% subplot(1,2,1);
% plot(t,Ez);
% xlabel('t/ns');ylabel('E_z(V/m)');
% Hphi =em_edipole_h_sphere(r,theta,t, t0, amp);
% subplot(1,2,2);
% plot(t,Hphi);
% xlabel('t/ns');ylabel('H_\phi(A/m)');

%% comparing field at  (0.5, 0) in cylinder coordinates with that at (0.5, pi/2) in spherical coorindate 
% t0 = 2e-9; 
% amp = 10^-10;
% r = 0.5;
% theta = pi/2;
% rho = 0.5;
% z = 0;
% t=(0:263)*83.333e-12;
% 
% s = em_edipole_e_sphere(r,theta,t, t0, amp);
% Er = s(:,1);
% Etheta = s(:,2);
% 
% s = em_edipole_e_cylinder(rho,z,t,t0,amp);
% Erho = s(:,1);
% Ez = s(:,2);
% 
% subplot(1,2,1);
% title(['E_z compoent at (',num2str(r), ', ', num2str(z), ')']);
% hold on;
% plot(t, -Etheta);
% plot(t, Ez, '*');
% xlabel('t/ns');ylabel('E_z(V/m)');
% legend('Shpere','Cylinder');
% subplot(1,2, 2);d
% title(['E_\rho compoent at (',num2str(r), ', ', num2str(z), ')']);
% hold on;
% plot(t, Er);
% plot(t, Erho, '*');
% xlabel('t/ns');ylabel('E_\rho(V/m)');
% legend('Shpere','Cylinder');


%% cylinder coordinates, step .vs. impulse

close all; clear; clc;

% t0 = 1.3e-05; % estimated by em_con_time
% dt = 2e-5;
% t = t0 + (0:1000-1)*dt;
% r = 1000;
% z = 500;

% t = linspace(0, 1e-4,5e2)';
% dt = t(2)-t(1);
% r = 100;
% z = 50;

t0 = 1.3e-7; 
dt = 2e-7;
fs = 1/dt;
t = t0 + (0:1000-1)*dt;
r = 100;
z = 50;

con = 0.01;
s = em_edipole_con_e_impulse_cylinder(r, z, t, con);
erimp = s(:,1);
ezimp = s(:,2);
s = em_edipole_con_e_step_cylinder(r, z, t, con);  
% estepr = s(:,1);
% estepz = s(:,2);
erstep = s(:,1);
ezstep = s(:,2);

s = em_edipole_con_h_impulse_cylinder(r, z, t, con);
himp = s;
s = em_edipole_con_h_step_cylinder(r, z, t, con);  
hstep = s;

erimp2 = diff(erstep)/dt;
ezimp2 = diff(ezstep)/dt;
erstep2 = cumtrapz(t,erimp);
ezstep2 = cumtrapz(t,ezimp);

himp2 = diff(hstep)/dt;
hstep2 = cumtrapz(t, himp);

subplot(3,2,1);
plot(t,erimp,'b');
hold on;
plot(t(1:end-1), erimp2, 'r.');
xlabel('t/s');ylabel('E_r(V/m)');
legend('Analytic','Diff');
title(['E_r compoent impulse response at (',num2str(r), ', ', num2str(z), ')']);

subplot(3,2,2);
plot(t,erstep, 'b');
hold on;
plot(t, erstep2, 'r.');
xlabel('t/s');ylabel('E_r(V/m)');
legend('Analytic','Integration');
title(['E_r compoent step response at (',num2str(r), ', ', num2str(z), ')']);

subplot(3,2,3);
plot(t,ezimp,'b');
hold on;
plot(t(1:end-1), ezimp2, 'r.');
xlabel('t/s');ylabel('E_z(V/m)');
legend('Analytic','Diff');
title(['E_z compoent impulse response at (',num2str(r), ', ', num2str(z), ')']);

subplot(3,2,4);
plot(t,ezstep, 'b');
hold on;
plot(t, ezstep2, 'r.');
xlabel('t/s');ylabel('E_z(V/m)');
legend('Analytic','Integration');
title(['E_z compoent step response at (',num2str(r), ', ', num2str(z), ')']);

subplot(3,2,5);
plot(t,himp,'b');
hold on;
plot(t(1:end-1), himp2, 'r.');
xlabel('t/s');ylabel('H_\phi(A/m)');
legend('Analytic','Diff');
title(['H_\phi compoent impulse response at (',num2str(r), ', ', num2str(z), ')']);

subplot(3,2,6);
plot(t, hstep, 'b');
hold on;
plot(t, hstep2, 'r.');
xlabel('t/s');ylabel('H_\phi(A/m)');
legend('Analytic','Integration');
title(['H_\phi compoent step response at (',num2str(r), ', ', num2str(z), ')']);

%input 
con =[0.5, 0.1 0.2]';       % S/m
rt =[0.02, 0.04, 0.1]';     % m, layer depth
b0 = 1;         %T
b1 = 0.00125;   %T
mu = 4*pi*1e-7;
h1 = b1 / mu;

% recursive process
nl  = length(con);
d = zeros(nl,1);
d(nl) = -0.25 * con(nl) * b1 * rt(nl)*rt(nl);

for i = nl-1:-1:1
  d(i) = d(i+1) - 0.25*rt(i)*rt(i)*b1*(con(i)-con(i+1));
end

% calcuation second field
r0=0;
r = linspace(r0, rt(nl),100)';
cr = segment_value(r,rt,con);

dr = segment_value(r,rt,d);
b2 = 0.25*b1*r.*r.* cr + dr;
h2 = b2/mu;
j2 = -0.5*b1*cr.*r;
e2 = -0.5*b1*r;
q = - b0*b1*cr;
h = h1 + h2;

%plot
subplot(3,2,1);plot(r,b2,'k');
set(gca,'xlim',[r(1) r(end)]);
xlabel('radius (m)');
ylabel('H_2 (T)');
subplot(3,2,2);plot(r,j2,'k');
xlabel('radius (m)');
ylabel('J_2(A/m^2)');
subplot(3,2,3);plot(r,e2,'k');
xlabel('radius (m)');
ylabel('E_2(V/m)');
subplot(3,2,4);plot(r,q,'k');
xlabel('radius (m)');
ylabel('Q(N/m^4)');
subplot(3,2,5);stairs(r,cr,'k');
% set(gca,'xlim',[r(1) r(end)],'ylim',[min(cr)*0.9 max(cr)*1.1]);
set(gca,'xlim',[r(1) r(end)],'ylim',[0 max(cr)*1.1],'ytick',sort(con));
grid on;
xlabel('radius (m)');
ylabel('conductivity (S/m)');
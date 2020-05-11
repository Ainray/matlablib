format rational;
v=[2,3,-1]';
T=[-2 0 3;0 0 -1; 1 2 0]; % 2-order tesnor
g_1=[1 -1 2]'; g_2=[0,1,1]';g_3=[-1,-2,1]';
G=[g_1 g_2 g_3];

% contraviriant bases
Gi=invbase([g_1 g_2 g_3]);

g1=Gi(1,:)'; g2=Gi(2,:)';g3=Gi(3,:)';

% g1
% g2
% g3

% components of T for bases G/Gi
% cellar components:
T_i_j=component(T,G,0);
% T_i_j

%roof components:
Tij=component(T,G,1);
% Tij

% mixed components:
Ti_j=component(T,G,2);
% Ti_j

% mixed components
T_ij=component(T,G,3);
T_ij;

% coordinate tranforms/change of basis
%transform matrix
A=[1 2 1;2 1 0;-1 0 1];
T_i_jp=transform(T_i_j,A,0);
% T_i_jp

Tijp=transform(Tij,A,1);
% Tijp

Ti_jp=transform(Ti_j,A,2);
% Ti_jp

T_ijp=transform(T_ij,A,3);
% T_ijp

vp=transform(v,A,1);
format short;
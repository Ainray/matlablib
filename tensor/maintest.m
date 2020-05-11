format rational;
v=[3,3,6]';
T=[-2 0 3;0 0 -1; 1 2 0]; % 2-order tesnor
g_1=[1 -1 2]'; g_2=[0,1,1]';g_3=[-1,-2,1]';
G=[g_1 g_2 g_3];

% components of vector
[cv, rv]=component(v,G);
% cv
% rv

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
vi=[2,3,-1]';
vp=transform(vi,A,1);

%it function
v=it(vi,G,1);
v_i=[12,9,-3]';
v=it(v_i,G,0);

% dot product
ui=[2,-1,4]';w_i=[-3,2,-2]';
duv=dotproduct(ui,v_i,G,[1,0]);
dwv=dotproduct(w_i,vi,G,[0,1]);
dwv=dotproduct(w_i,v_i,G,[0 0]);
duw=dotproduct(ui,w_i,G,[1,0]);
% squared modulus
dvv=dotproduct(v_i,v_i,G,[0 0]);
dvv=dotproduct(v_i,vi,G,[0,1]);
dvv=dotproduct(vi,v_i,G,[1 0]);
dvv=dotproduct(vi,vi,G,[1,1]);
dvv=dotproduct(v,v,eye(3),[0 0]);

% cross product
u=it(ui,G,1);

format short;
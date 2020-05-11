% main function for exercise 2.1
g1=[4,6,2]';g2=[1,0,1]';g3=[1,3,0]';
fprintf('Exercises 2.1:\n');
if isbase([g1 g2 g3])==1
    fprintf('	(a), g1, g2 g3 is a basis\n');
else
    fprintf('	(a), g1, g2 g3 is not a basis\n');
end

g1=[1,1,0]';g2=[0,2,2]';g3=[3,0,3]';
if isbase([g1 g2 g3])==1
    fprintf('	(b), g1, g2 g3 is a basis\n');
else
    fprintf('	(b), g1, g2 g3 is not a basis\n');
end

g1=[1,1,1]';g2=[1,-1,1]';g3=[-1,1,-1]';
if isbase([g1 g2 g3])==1
    fprintf('	(c), g1, g2 g3 is a basis\n');
else
    fprintf('	(c), g1, g2 g3 is not a basis\n');
end

fprintf('\nExercises 2.2:\n');

G=[-1,0,0;1,1,0;1,1,1;]';
m=num2str(invbase(G));
fprintf('	                                       |%s|\n',m(1,:))
fprintf('	rceiprocal vectors are rows of maxtrix:|%s|\n',m(2,:));
fprintf('	                                       |%s|\n',m(3,:))
v=[1,2,3]';
[cv,rv]=component(v,G);
fprintf('	cellar/covariant components of v=(1,2,3) is (%s,%s,%s)\n',...
    strtrim(rats(cv(1))),strtrim(rats(cv(2))),strtrim(rats(cv(3))));
fprintf('	roof/contravariant components of v=(1,2,3) is (%s,%s,%s)\n',...
    strtrim(rats(rv(1))),strtrim(rats(rv(2))),strtrim(rats(rv(3))));


fprintf('\nExercises 2.3:\n');
ui=[2,2,1]';vi=[-3,1,2]';
m=num2str(G);
fprintf('	                                                      |%s|\n',m(1,:))
fprintf('	cross product of (2,2,1)¡Á(-3,1,2) with basis maxtrix:|%s| is: (%s)\n',m(2,:),num2str(crossproduct(ui,vi,G,0)'));
fprintf('	                                                      |%s|\n',m(3,:))
% all vectors are column vector

Ac = [1 2 0; 1 2 -1; 0 -1 1]'; % new base
Bc = [1 1 0; 0 1 2; 2 1 -1]';  % old base

det(Ac),
det(Bc),

Ar = invbase(Ac)'
Br = invbase(Bc)'

Trji = Bc\Ac
Trji =  Br' * Ac

Trji
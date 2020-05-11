function y=directop(G,type,i,j)
% find the (i,j) direct product of G
N=size(G,1);
Gi=inv(G);
y=cell(0);
if nargin<3
    ii=[1:N];
    jj=[1:N];
end

if nargin==4
    ii=mod(i,N);
    jj=floor(i/N)+1;
    if ii==0
        ii=N;
        jj=jj-1;
    end
    if type==0 % cellar component
        y=directproduct(Gi(ii,:)',Gi(jj,:)');
    elseif type==1
        y=directproduct(G(:,ii),G(:,jj));
    elseif type==2 ||type==3
        y=directproduct(G(:,ii),Gi(jj,:));
    end
    return;
end
if nargin==5
    ii=i;
    jj=j;
end
y=cell(N,N);
for k=ii
    for q=jj
         if type==0 % cellar component
            y(k,q)=directproduct(Gi(k,:)',Gi(q,:)');
         elseif type==1
            y=directproduct(G(:,k),G(:,q));
         elseif type==2 ||type==3
            y=directproduct(G(:,k),Gi(q,:));
         end
    end
end

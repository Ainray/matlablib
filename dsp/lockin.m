function y=lockin(x,w,indx)
    nx=length(x);
    nw=length(w);
    nw2=nw*2;
    m=length(indx);
    if m<nw2
    	m=nw2;
    end
    P0=zeros(m,nw2);
    P1=zeros(nx,nw2);
    for i=1:nw
    	P0(:,i*2-1:i*2)=[cos((0:m-1)'*w(i)) sin((0:m-1)'*w(i))];
    end
    alpha=pinv(P0'*P0)*P0'*x(indx); 
    % extrapolation
    mm=(1:nx)-indx(1);
    for i=1:nw
    	P1(:,i*2-1:i*2)=[cos((mm-1)'*w(i)) sin((mm-1)'*w(i))];
    end
    n0=P1*alpha;

    y=x-n0;
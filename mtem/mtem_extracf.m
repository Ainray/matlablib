function fg=mtem_extracf(f,g,a,fig,df)
% f, given frequency
% g, given impulse response
% a, specfied ampltitude
% df, precision
if nargin<4
    fig=0;
end
if nargin<5
    df=1e-5;
end
fg=zeros(length(a),1);
% find initial position
for i=1:length(a)
    a0=a(i);
    indx0=find(g<a0, 1 );
    f0=f(2)-f(1);
    if f0>df
        maxf=f(min(indx0+10,length(f)));
        minf=f(max(indx0-10,1));
        nx=floor((maxf-minf)/df);
        x=linspace(minf,maxf,nx);
        y=interp1(f(max(indx0-10,1):min(indx0+10,length(f))),...
            g(max(indx0-10,1):min(indx0+10,length(f))),x,'spline');
        indx1=find(y<a0,1);
        fg(i)=(x(indx1)+x(indx1-1))/2;
    else
        % find the frequency
        fg(i)=(f(indx0)+f(indx0-1))/2;
    end
end
if fig==1
    plot(f,g,'k');
    hold on;
    plot(fg,a,'ro');
    set(gca,'xscale','log');
end
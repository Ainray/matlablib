function imp=convertimp(impcsy)
N=numel(impcsy);
% covert format
for i=1:N
    impxa=initialimp;
    impxa.g=impcsy(i).g;
    impxa.ts=impcsy(i).t_s;
    impxa.meta.srcpos=impcsy(i).shot_num;
    impxa.meta.rcvpos=impcsy(i).rcv_num;
    impxa.meta.code=impcsy(i).code;
    impxa.meta.recnum=impcsy(i).rec_num;
    impxa.meta.rcvch=impcsy(i).rcv_ch;
    impxa.meta.rcvsn=impcsy(i).rcv_sn;
    imp(i)=impxa;
end



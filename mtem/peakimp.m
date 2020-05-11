function imp=peakimp(imp)
[tpn,pv]=gettpn(imp.g);     %get peak time (smaples) and peak value
if isempty(tpn) || isempty(pv) % just any value
   tpn=50;
   pv=1e-6;
end
imp.pn=tpn;                 % peak time (samples)
imp.pv=pv;                  % peak value;
imp.cpv=pv;                 % current peak value
imp.cpn=tpn;            % current peak time (samples)
imp=mapimp(imp);
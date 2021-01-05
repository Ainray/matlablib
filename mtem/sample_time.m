%function [ts, single_num] = sample_time(t_ele, N, cycle, fs, idlen)
% 
% author: Ainray
% date: 2020/12/13
% bug report: wwzhang0421@163.com
% introduction: generate sample time for 'cycle' periods, with 'N' number of elements per period.
% Also refer to prbs_src.
%    input:
%          t_ele, time width per element
%          N, number of elements per cycle
%          cycle, number of periods, can be float
%             fs, the sampling frequency
%          idlen, idle per periods, default is zero
%   output:     
%             ts, the time series of source
%     single_num, number of samples per period
%           npad, number of samples padding the tail after stop transmittion
%          idlen, number of idle samples bwteen periods

function [ts, single_num, idlen] = sample_time(t_ele, N, cycle, fs, idle)  
    narginchk(4,5); %check the input arguments
    if nargin<5   
        idle= 0;
    end
    
    nc = floor(cycle);
    num_ele = N; 	% 2^order-1, for m sequence
    num_ele_all = num_ele * nc;floor(cycle) + ceil((cycle-floor(cycle) * num_ele));
    
    nc = floor(cycle);
    if(nc < cycle)
        nc = nc + 1;
        num_ele_all = num_ele_all + floor(cycle) + ceil((cycle-floor(cycle) * num_ele));
    end
    
    endn1=zeros(nc,1);
    endn2=zeros(nc-1,1);
    
    periodtime = num_ele * t_ele ;
    for i=1:nc-1
        endn1(i) = floor((periodtime * i + (i-1)*idle) * fs);  %the end number of samples per period
        endn2(i)= floor( (periodtime+idle)*i*fs);               %the end number of samples per period with idle  
    end
    duration = t_ele * num_ele_all + idle * (nc-1);
    endn1(nc) = floor(duration*fs);
    
    single_num=zeros(nc,1);
    if nc>1
        single_num(2:end) = endn1(2:end) - endn2(1:end);
        idlen= endn2(1:end)-endn1(1:end-1);
    end
    single_num(1) = endn1(1);
    
    ts = time_vector(zeros(endn1(nc),1),fs);
%function [src_i,t_s,single_num]=prbs_src(t_ele,order,cycle,fs,I,type,pic,n)
% author: Ainray
% date: 2014/11/29
% modified: 2015/4/16,2015/7/28,20170310,20160318, 20170529
%           20170310, correct a bug for idle time.
%           20160318, add a parameter to control the idle time, the pic and n
%                     are shifted backward.
%           20170529, recomment the codes
%           20190410, type 0, load prbs4_18.mat, 1~ means 
%                     phase shift, and change odrder of "type" and "I"
% bug report: wwzhang0421@163.com
% introduction: generate the m sequence
%    input:
%          t_ele, reciprocal of source current switching frequecny
%          order, the order of m sequence, i.e. the number of shift registers
%          cycle, number of periods of m sequence
%             fs, the sampling frequency
%           type, 1, the PRBS source is generated by calling Matlab built-in function: idinput
%                 0, the PRBS source is loaded from file 'prbs4_18.mat'
%              I, the amplitude of m sequece
%          idlen, number of listening samples between PRBS periods (add by Ainray, on 20160315 
%            pic, whether plot the source or not
%              n, the sampling number to be plotted
%   output:
%          src_i, the m sequence with bipolor amplitude of I
%            t_s, the time series of source
%     single_num, the number of sample per period

function [src_i,t_s,single_num]=prbs_src(t_ele,order,cycle,fs,I,type,idlen,pic,n)
    narginchk(4,9); %check the input arguments
    if nargin<5
        I=1;
    end
    if nargin<6
        type=-1;
    end
    if nargin<7
        idlen=0;
    end
    if nargin<8
        pic=0;          % no ploting
    end
    num_ele=2^order-1;                   % the number of elements of one period
    if(type>num_ele)
        type=num_ele;
    end
    if(type<0)
        type=num_ele;
    end
    if (type==0)  % mode  
        m_series=prbs_(order);  % from generated file
        m_series(m_series==0)=-1;
    else
         m_series=idinput(num_ele,'prbs');    % m sequence
         m_series=[m_series(type+1:num_ele);m_series(1:type)];
    end
    % periodic extension
    tmp=repmat(m_series,floor(cycle),1);
    m_series=[tmp',tmp(1:ceil((cycle-floor(cycle))*num_ele))']';  
    %%%%%%%%% sampling%%%%%%%%%%
    num_all_ele=length(m_series);   %number of all elements
    end_=zeros(num_all_ele,1);      %the end number of samples per element
    ppe=zeros(num_all_ele,1);       %number of samples per element
%     for i=1:num_all_ele
%         end_    = floor(t_ele*fs*i+(fs*t_ele-floor(fs*t_ele))*0.1);             
%         src_i(start_:end_)=repmat(m_series(i),end_-start_+1,1)*I; 
%         start_  = end_+1;                   % update  
%     end
    %plus (fs*t_elefloor(fs*t_ele))*0.1 to eliminate the numerical error
    %because the every time increasing (fs*t_elefloor(fs*t_ele))
    end_(1:end)=floor([1:num_all_ele]*t_ele*fs);%+(fs*t_ele-floor(fs*t_ele))*0.001);
    ppe(2:end)=end_(2:end)-end_(1:end-1);ppe(1)=end_(1);
    % sampling
    src_i=rude(ppe,m_series);
    src_i=src_i'*I;
    % add idle 
    y=zeros(length(src_i)+idlen*floor(cycle),1);
    single_num=zeros(floor(cycle),1);
    for i=1:floor(cycle)
        single_num(i)=sum(ppe(1:num_ele*i))-sum(ppe(1:num_ele*(i-1)));
        start=sum(single_num(1:i-1))+1;
        y((start:start-1+single_num(i))+idlen*(i-1))=src_i(start:start-1+single_num(i));
    end
    src_i=y;
%     if(cycle>floor(cycle))
%         single_num(floor(cycle)+1)=sum(ppe)-sum(single_num(1:floor(cycle)));
%     end
    t_s=time_vector(src_i,fs);
    if(pic~=0)
        figure;
        if nargin==8
            n=length(src_i);
        end
        plot_(src_i,fs,n);
    end
end
function plot_(src_i,fs,n)
        error(nargchk(2,3,nargin,'struct')); %check the input arguments
        if nargin==2
            n=length(src_i);
        end
        t=(0:n-1)/fs;
        plot(t,src_i(1:n),'r.');
        hold on;
        plot(t,src_i(1:n));
        axis([0,t(end)*1.1,min(src_i)*1.1,max(src_i)*1.1]);
        xlabel('time/s');ylabel('current/A');
        axis([0,t(end),1.1*min(src_i),max(src_i)*1.1]);
end
function m_series=prbs_(order)
if(order<4 ||order>18)
    error('Order must be from 4 to 18(included)');
end
    load prbs4_18.mat;
    switch(order)
    case 4
        m_series=prbs4;
    case 5
        m_series=prbs5;
    case 6
         m_series=prbs6;
    case 7
         m_series=prbs7;
    case 8
         m_series=prbs8;
    case 9
         m_series=prbs9;
    case 10
         m_series=prbs10;
    case 11
         m_series=prbs11;
    case 12
         m_series=prbs12;
    case 13
         m_series=prbs13;
    case 14
         m_series=prbs14;
    case 15
         m_series=prbs15;
    case 16
         m_series=prbs16;
    case 17
         m_series=prbs17;
    case 18
         m_series=prbs18;
    end
end
        
        

  
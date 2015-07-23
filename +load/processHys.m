function hysteresis=processHys(data,header,S,contact,varargin)
    
    %Get header and data
    %[hysteresis.header,data]=loadHys(fn);
    
    %Cut data in lines
    hysteresis=cutData(data,S,varargin{:});
    
    %Fit model to data
    hysteresis.model=load.fitModel(hysteresis);
    
    if isfield(header,'TIP_Z_m')
        header.TIP_Z_m=header.TIP_Z_m-contact;
    end
    
    hysteresis.header=header;
    hysteresis.S=S;
    
    %save Neq
    EqCountRate=4*hysteresis.meanCH0/(hysteresis.Q+1);
    hysteresis.Neq=EqCountRate*header.AVRG_WAIT_ms*1e-3;
end

function hysteresis=cutData(data,S,varargin)
    
    %Load time
    time=data(:,1);
    
    %The data is cut at maximum and minimum load time
    bounds=find(time==max(time)|time==min(time));
    
    %Remove last bounds if asked for it
    if nargin >2
        nloop=varargin{1};
        nB=1+2*nloop;
        if nB>2 && nB<numel(bounds)
            bounds=bounds(1:nB);
        end
        
    end
    
    %save time vector
    time=time(bounds(1):bounds(2));
    
    loopsIdx=bounds(1):bounds(end);
    %Q is computed such as mean = 0 (Over a loop, the values from counter 0 and 2 should be equal)
    Q=sum(data(loopsIdx,2))/sum(data(loopsIdx,3));
    
    %Compute contrast
    Contr=1/S*(Q*data(:,3)-data(:,2))./(Q*data(:,3)+data(:,2));
    
    %Separate lines
    for i=(floor((numel(bounds)-3)/2)*2+1):-2:1%make sure we have an even number of back and forth
        idx=(i+1)/2;
        fallingLines(:,idx)=Contr(bounds(i):bounds(i+1));
        risingLines(:,idx)=flip(Contr(bounds(i+1):bounds(i+2)));
    end
    
    %Switch if rising first
    if time(1)<time(end)
        %Switch lines
        tmp=fallingLines;
        fallingLines=risingLines;
        risingLines=tmp;
    end
    
    hysteresis.time=time;
    hysteresis.fallingLines=fallingLines;
    hysteresis.risingLines=risingLines;
    hysteresis.Q=Q;
    
    %Compute mean raw values
    hysteresis.meanCH0=mean(data(loopsIdx,2));
    hysteresis.meanCH2=mean(data(loopsIdx,3));
    
    if size(data,2)>3
        hysteresis.meanI=mean(data(loopsIdx,4));
    else
        hysteresis.meanI=nan;
    end
    hysteresis.meanContr=mean([fallingLines(:); risingLines(:)]);
    hysteresis.NLoop=numel(risingLines);
end

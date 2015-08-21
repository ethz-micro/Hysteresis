function hysteresis=processHys(data,header,S,contact,varargin)
    
    %Get header and data
    %[hysteresis.header,data]=loadHys(fn);
    
    %Cut data in lines
    hysteresis.data=cutData(data,S,varargin{:});
    
    %Fit model to data
    hysteresis.model=load.fitModel(hysteresis);
  
    if isfield(header,'TIP_Z_m')
        header.TIP_Z_m=header.TIP_Z_m-contact;
    end
    
    hysteresis.header=header;
    hysteresis.data.S=S;
    
    %save Neq
    EqCountRate=4*hysteresis.data.meanCH0/(hysteresis.data.Q+1);
    hysteresis.data.Neq=EqCountRate*header.AVRG_WAIT_ms*1e-3;
end

function dataStruct=cutData(data,S,varargin)
    ch0Idx=2;
    ch2Idx=3;
    
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
    Q=sum(data(loopsIdx,ch0Idx))/sum(data(loopsIdx,ch2Idx));
    
    %Compute contrast
    Contr=1/S*(Q*data(:,ch2Idx)-data(:,ch0Idx))./(Q*data(:,ch2Idx)+data(:,ch0Idx));
    
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
    
    dataStruct.time=time;
    dataStruct.fallingLines=fallingLines;
    dataStruct.risingLines=risingLines;
    dataStruct.Q=Q;
    
    %Compute mean raw values
    dataStruct.meanCH0=mean(data(loopsIdx,ch0Idx));
    dataStruct.meanCH2=mean(data(loopsIdx,ch2Idx));
    
    if size(data,2)>3
        dataStruct.meanI=mean(data(loopsIdx,4));
    else
        dataStruct.meanI=nan;
    end
    dataStruct.meanContr=mean([fallingLines(:); risingLines(:)]);
    dataStruct.NLoop=size(risingLines,2);
end

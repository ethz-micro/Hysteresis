function hysteresis=processHys(data,header,S,contact,varargin)
    
    %Get header and data
    %[hysteresis.header,data]=loadHys(fn);
    
    %Cut data in lines
    hysteresis=cutData(data,S,varargin{:});
    
    %Fit model to data
    hysteresis.model=fitModel(hysteresis.time,hysteresis.risingLines,hysteresis.fallingLines);
    
    if isfield(header,'TIP_Z_m')
        header.TIP_Z_m=header.TIP_Z_m-contact;
    end
    hysteresis.header=header;
    hysteresis.S=S;
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
end

function model = fitModel(Time,risingLines,fallingLines)
    %% Find data shape
    
    %For the amplitude we keep Time>0 for falling and Time <0 for rising
    %to be sure we only have the stable level
    amplitude=1/2*(mean(mean(fallingLines(Time>0,:)))-mean(mean(risingLines(Time<0,:))));
    
    %For the flip position, we know that the integral if the data are
    %centered should be 2*flipIdx*amplitude as the rest cancels out
    dt=abs(Time(2)-Time(1));%Step
    
    flipFalling=1/2*(min(Time)-sum(dt*mean(fallingLines(Time<0,:),2))/amplitude);
    flipRising=1/2*(max(Time)-sum(dt*mean(risingLines(Time>0,:),2))/amplitude);
    %flipFalling=-sum(dt*mean(fallingLines,2))/(2*amplitude);
    %flipRising=-sum(dt*mean(risingLines,2))/(2*amplitude);
    %The flip index should be the same for rising and falling, therefore
    %we take the mean
    flipIdx=(flipRising-flipFalling)/2;
    
    model.amplitude=amplitude;
    model.flipIdx=flipIdx;
    
    %We draw the resulting values for convinient plotting
    idxHighFalling=Time>-flipIdx;
    idxHighRising=Time>flipIdx;
    
    model.falling=amplitude.*(idxHighFalling-(~idxHighFalling));
    model.rising=amplitude.*(idxHighRising-(~idxHighRising));
    
    %Compute noise RMS and R-square
    data=[mean(fallingLines,2);mean(risingLines,2)];
    fit=[ model.falling;model.rising];
    model.RSquared=RSquared(data,fit);
    model.rms=rms(data-fit);
    
    %Compute noise on amplitude and Index
    model.ampSTD=model.rms/sqrt(numel(Time));
    model.flipSTD=(model.rms/(2*amplitude*sqrt(numel(Time))))...
        *sqrt((min(Time)+2*flipIdx)^2-min(Time)*max(Time));
    
    model.diffAmp=mean(mean(fallingLines(Time>0,:)))+mean(mean(risingLines(Time<0,:)));
    
end

function RS = RSquared(data,fit)
    %Compute R-squared fit of data
    SSTot=sum((data-mean(data)).^2);
    SSRes=sum((data-fit).^2);
    RS=1-SSRes/SSTot;
    
end
function model = fitModel(hysteresis,varargin)
    Time=hysteresis.time;
    if nargin >1
        maxLoop=varargin{1};
        risingLines=hysteresis.risingLines(1:maxLoop);
        fallingLines=hysteresis.fallingLines(1:maxLoop);
    else
        
        risingLines=hysteresis.risingLines;
        fallingLines=hysteresis.fallingLines;
    end
    
    %% Find data shape
    
    %For the amplitude we keep Time>0 for falling and Time <0 for rising
    %to be sure we only have the stable level
    amplitude=1/2*(mean(mean(fallingLines(Time>0,:)))-mean(mean(risingLines(Time<0,:))));
    
    %If amplitude <=0, we can't compute the rest
    if amplitude <=0 %No hysteresis
        model.amplitude=0;
        model.rms=rms([mean(fallingLines,2);mean(risingLines,2)]);
        model.RSquared=0;
        model.flipIdx=nan;
        model.falling=0*Time;
        model.rising=0*Time;
        model.flipSTD=nan;
        model.diffAmp=0;
        model.diffFlip=nan;
    else
        model.amplitude=amplitude;
        %For the flip position, we know that the integral if the data are
        %centered should be 2*flipIdx*amplitude as the rest cancels out
        
        dt=abs(Time(2)-Time(1));%Step
        
        flipFalling=1/2*(min(Time)-sum(dt*mean(fallingLines(Time<0,:),2))/amplitude);
        flipRising=1/2*(max(Time)-sum(dt*mean(risingLines(Time>0,:),2))/amplitude);
        flipIdx=(flipRising-flipFalling)/2+dt/2;
        
        %{
        FirstRMS=getModelFit(Time,fallingLines,risingLines,amplitude,flipIdx);
        flipSTD=(FirstRMS/(2*amplitude*sqrt(numel(Time))))...
            *sqrt((min(Time)+2*flipIdx)^2-min(Time)*max(Time));
        
        %}
        %The flip index should be the same for rising and falling, therefore
        %we take the mean
        
        
        
        
        
        trialIDX = Time(Time>=0)+dt/2;
        [RMS, RS] = getModelFit(Time,fallingLines,risingLines,amplitude,trialIDX);
        [model.rms,I]=min(RMS);
        model.RSquared=RS(I);
        model.flipIdx=trialIDX(I);
        
        model.diffFlip=flipIdx-model.flipIdx;
        
        idxHighFalling=Time>-model.flipIdx;
        idxHighRising=Time>model.flipIdx;
        
        model.falling=amplitude.*(idxHighFalling-(~idxHighFalling));
        model.rising=amplitude.*(idxHighRising-(~idxHighRising));
        
        model.flipSTD=(model.rms/(2*amplitude*sqrt(numel(Time))))...
            *sqrt((min(Time)+2*model.flipIdx)^2-min(Time)*max(Time));
        model.diffAmp=mean(mean(fallingLines(Time>0,:)))+mean(mean(risingLines(Time<0,:)));
    end
    %Compute noise on amplitude and Index
    model.ampSTD=model.rms/sqrt(numel(Time));
    
    
end

function [RMS, RS] = getModelFit(Time,fallingLines,risingLines,amplitude,flipIdx)
    [TG,FG]=ndgrid(Time,flipIdx);
    %We draw the resulting values for convinient plotting
    idxHighFalling=TG>-FG;
    idxHighRising=TG>FG;
    
    falling=amplitude.*(idxHighFalling-(~idxHighFalling));
    rising=amplitude.*(idxHighRising-(~idxHighRising));
    
    %Compute noise RMS and R-square
    data=repmat([mean(fallingLines,2);mean(risingLines,2)],1,numel(flipIdx));
    fit=[falling;rising];
    RS=RSquared(data,fit);
    RMS=rms(data-fit,1);
    
    %{
    %We draw the resulting values for convinient plotting
    idxHighFalling=Time>-flipIdx;
    idxHighRising=Time>flipIdx;
    
    falling=amplitude.*(idxHighFalling-(~idxHighFalling));
    rising=amplitude.*(idxHighRising-(~idxHighRising));
    
    %Compute noise RMS and R-square
    data=[mean(fallingLines,2);mean(risingLines,2)];
    fit=[falling;rising];
    RS=RSquared(data,fit);
    RMS=rms(data-fit);
    %}
end

function RS = RSquared(data,fit)
    %Compute R-squared fit of data
    SSTot=sum((data-repmat(mean(data,1),size(data,1),1)).^2,1);
    SSRes=sum((data-fit).^2,1);
    RS=1-SSRes./SSTot;
    
end
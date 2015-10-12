function model = fitModel(hysteresis)
    
    %Extract Time
    Time=hysteresis.data.time;
    
    %Extract Rising and Falling lines.
    risingLines=hysteresis.data.risingLines;
    fallingLines=hysteresis.data.fallingLines;
    
    % Find data shape
    
    %To compute the amplitude, Time>0 for falling and Time <0 for rising
    %are assumed to be flat
    amplitude=1/2*(mean(mean(fallingLines(Time>0,:)))-...
        mean(mean(risingLines(Time<0,:))));
    
    %If amplitude <=0, we can't compute the rest of the data, and it is
    %assumed that no hysteresis has been detected.
    if amplitude <=0 %No hysteresis
        %No amplitude
        model.amplitude=0;
        model.diffAmp=nan;
        model.falling=0*Time;
        model.rising=0*Time;
        
        %No flip index
        model.flipIdx=nan;
        model.diffFlip=nan;
        model.flipSTD=nan;
        model.RSquared=nan;
        
        %RMS
        model.rms=rms([mean(fallingLines,2);mean(risingLines,2)]);
         
    else
        %Save amplitude
        model.amplitude=amplitude;
        model.diffAmp=(mean(mean(fallingLines(Time>0,:)))+...
            mean(mean(risingLines(Time<0,:))))/2;
        
        %Use formula to find theoritical flip index
        dt=abs(Time(2)-Time(1));%Step
        flipFalling=1/2*(min(Time)-dt-...
            sum(dt*mean(fallingLines(Time<0,:),2))/amplitude);
        flipRising=1/2*(max(Time)+dt-...
            sum(dt*mean(risingLines(Time>0,:),2))/amplitude);
        flipIdx=(flipRising-flipFalling)/2;
        
        %Use brute force to find numerical index
        trialIDX = Time(Time>=0)+dt/2;
        [RMS, RS] = getModelFit(Time,fallingLines,risingLines,amplitude,trialIDX);
        [model.rms,I]=min(RMS);
        model.RSquared=RS(I);
        model.flipIdx=trialIDX(I);
        
        %Compute theorical STD
        model.flipSTD=sqrt(...
        (model.rms^2/(4*amplitude^2*numel(Time)))...
            *((min(Time)-dt+2*model.flipIdx)^2+min(Time)^2)...
           +1/12*dt^2);
        
        %Compute difference between two results
        model.diffFlip=flipIdx-model.flipIdx;
        
        %Get fit data for easy plotting
        idxHighFalling=Time>-model.flipIdx;
        idxHighRising=Time>model.flipIdx;
        model.falling=amplitude.*(idxHighFalling-(~idxHighFalling));
        model.rising=amplitude.*(idxHighRising-(~idxHighRising));
        
        
    end
    %Compute noise on amplitude and Index
    model.ampSTD=model.rms/sqrt(numel(Time));
end

function [RMS, RS] = getModelFit(Time,fallingLines,risingLines,amplitude,flipIdx)
    
    %Create ndgrid to test different load times at once
    [TG,FG]=ndgrid(Time,flipIdx);
    
    %Determine Fit Data
    idxHighFalling=TG>-FG;
    idxHighRising=TG>FG;
    falling=amplitude.*(idxHighFalling-(~idxHighFalling));
    rising=amplitude.*(idxHighRising-(~idxHighRising));
    fit=[falling;rising];
    
    %Resize data to match the ndgrid
    data=repmat([mean(fallingLines,2);mean(risingLines,2)],1,numel(flipIdx));
    
    %Compute noise RMS and R-square
    RS=RSquared(data,fit);
    RMS=rms(data-fit,1);

end

function RS = RSquared(data,fit)
    %Compute R-squared fit of data
    SSTot=sum((data-repmat(mean(data,1),size(data,1),1)).^2,1);
    SSRes=sum((data-fit).^2,1);
    RS=1-SSRes./SSTot;
    
end
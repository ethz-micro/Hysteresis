function [NE,RMS,FIT,hys]=RMSvsNBRE(datas,headers,S,contact)
    %For each hysteresis, we will Consider the RMS over 1,...,N loops
    %This will give several data point for the evolution of RMS with the number
    %of secondary electronds
    %Get model for falling + rising
    
    hys=cellfun(@(x,y) processHys(x,y,S,contact),datas,headers);
    for j=numel(hys):-1:1%For each hysteresis
        
        for i=size(hys(j).fallingLines,2):-1:1%For each line
            
            %make the mean over all the loops up to i  
            H=processHys(datas{j},headers{j},S,contact,i);
            data=[mean(H.fallingLines,2);mean(H.risingLines,2)];
            
            %Correcponding Fit
            modelfit=[H.model.falling;H.model.rising];
            
            %Compute noise RMS
            RMS{j}(i)=rms(data-modelfit);
            
            %Compute corresponding number of electrons (Counts ~const)
            %CountRate=min([H.meanCH0,H.meanCH2]);
            CountRate=4*H.meanCH0/(H.Q+1);
            NE{j}(i)=i*CountRate*H.header.AVRG_WAIT_ms*1e-3;
        end
        X=NE{j}.^-0.5;
        Y=RMS{j};
        FIT(j).p1=min(Y./X);
        FIT(j).p2=0;
        %{
        %Fit if we can
        try
            f=fit((NE{j}.^-0.5)',(RMS{j})','p1*x','StartPoint',7);
            FIT(j).p1=f.p1;
            FIT(j).p2=0;%f.p2;
        catch exception
            FIT(j).p1=nan;
            FIT(j).p2=nan;
        end
        %}
    end
    
end
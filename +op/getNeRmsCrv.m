function [NE,RMS] = getNeRmsCrv(data,header,S,contact)
    
    N = loopNumber(data);
    for i=N:-1:1%For each line
        
        %make the mean over all the loops up to i
        H=load.processHys(data,header,S,contact,i);
        
        %Compute noise RMS
        RMS(i)=H.model.rms;
        
        %Compute corresponding number of electrons (Counts ~const)
        NE(i)=i*H.data.Neq;
    end
end

function N = loopNumber(data)
    %Compute the number of loops in data
    time=data(:,1);
    Nmax=sum(time==max(time));
    Nmin=sum(time==min(time));
    N=max([Nmax Nmin])-1;
end
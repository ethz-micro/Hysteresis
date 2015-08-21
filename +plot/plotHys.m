function plotHys(hysteresis,varargin)
    %Get Time
    X=hysteresis.data.time;
    xname = 'load time [\mus]';
    if nargin>1
        if strcmp(varargin,'Field')
            X=load.LoadTime2Field(hysteresis.data.time,hysteresis.header.MSR_VOLT);
            xname = 'Pulsed field [G]';
        end
    end
    
    
    
    %Get mean data and model
    YR=mean(hysteresis.data.risingLines,2);
    YF=mean(hysteresis.data.fallingLines,2);
    YMR=hysteresis.model.rising;
    YMF=hysteresis.model.falling;
    
    %Plot everithing
    figure
    hold all
    plot(X,YR,'bx','DisplayName','Raising');
    plot(X,YMR,'b-','DisplayName','Raising Fit');
    plot(X,YF,'rx','DisplayName','Falling');
    plot(X,YMF,'r-','DisplayName','Falling Fit');
    
    l1=hysteresis.header.MSR_DATE;     
    l2=sprintf('Bias= %.4g V, \\DeltaZ= %g nm',abs(hysteresis.header.TIP_BIAS_V),hysteresis.header.TIP_Z_m*1e9);
    
    
    
    legend(gca,'show','Location','northwest');
    
    xlabel(xname)
    polName = sprintf('Polarization (Uncalib., S=%g) [au]',hysteresis.data.S);
    ylabel(polName)
    set(gca,'FontSize',20)
    title({l1,l2},'FontSize',12);
end
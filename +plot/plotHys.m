function plotHys(hysteresis,varargin)
    %Get Time
    X=hysteresis.time;
    xname = 'load time [\mus]';
    if nargin>1
        if strcmp(varargin,'Field')
            X=load.LoadTime2Field(hysteresis.time,hysteresis.header.MSR_VOLT);
            xname = 'Pulsed field [G]';
        end
    end
    
    
    
    %Get mean data and model
    YR=mean(hysteresis.risingLines,2);
    YF=mean(hysteresis.fallingLines,2);
    YMR=hysteresis.model.rising;
    YMF=hysteresis.model.falling;
    
    %Plot everithing
    figure
    hold all
    plot(X,YR,'bx','DisplayName','Raising');
    plot(X,YMR,'b-','DisplayName','Raising Fit');
    plot(X,YF,'rx','DisplayName','Falling');
    plot(X,YMF,'r-','DisplayName','Falling Fit');
    
    title(sprintf('Bias= %.4g V, \\DeltaZ= %g nm',abs(hysteresis.header.TIP_BIAS_V),hysteresis.header.TIP_Z_m*1e9));
    
    legend(gca,'show','Location','northwest');
    
    xlabel(xname)
    polName = sprintf('Polarization (Uncalib., S=%g) [au]',hysteresis.S);
    ylabel(polName)
    set(gca,'FontSize',20)
end
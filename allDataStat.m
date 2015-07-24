function allDataStat(sfn)
    close all
    %call loadFolder in all folder inside superfolder
    %sfn = 'Data';
    files=dir(sfn);
    
    global hys
    if(numel(hys)==0)
        for i=1:numel(files)
            file = files(i);
            if file.isdir && file.name(1)~='.'
                hys = [hys; getHysFolder([sfn,'/', file.name])];
            end
        end
    end
    %Q=[hys.Q];
    rms=arrayfun(@(x) x.model.rms,hys)';
    amplitude=arrayfun(@(x) x.model.amplitude,hys)';
    Fdiff=arrayfun(@(x) x.model.diffFlip,hys)';
    FStd=arrayfun(@(x) x.model.flipSTD,hys)';
    FlipIdx=arrayfun(@(x) x.model.flipIdx,hys)';
    FITSigma = [hys.fitSigmaE];
    diffAmp = arrayfun(@(x) x.model.diffAmp,hys)';
    ampSTD = arrayfun(@(x) x.model.ampSTD,hys)';
    
    ignored = FITSigma(FITSigma>200);
    figure
    histogram(FITSigma*.01,0.5:.05:2);
    xlabel('\sigma_e^2')
    title(sprintf('Median = %.2f, Std = %.2f ,%d off-scale',nanmedian(FITSigma((FITSigma<200))*.01),nanstd(FITSigma((FITSigma<200))*.01),numel(ignored)));
    set(gca,'FontSize',20)
    
    figure
    histogram(Fdiff./FStd,-5:.2:5)
    xlabel('(Theorical - minimized) Flip / Flip std')
    title(sprintf('STD = %.2f, mean = %.2f',nanstd(Fdiff./FStd),nanmean(Fdiff./FStd)))
    set(gca,'FontSize',20)
    
    figure
    histogram(amplitude,70)
    xlabel('Amplitude')
    set(gca,'FontSize',20)
    
    figure
    histogram(FlipIdx,0:35)
    xlabel('Flip Load Time [\mus]')
    set(gca,'FontSize',20)
    
    figure
    histogram(diffAmp./ampSTD,30)
    title(sprintf('STD = %.2f, mean = %.2f',nanstd(diffAmp./ampSTD),nanmean(diffAmp./ampSTD)))
    
    
    
end

function hysArray = getHysFolder(folderName)
    %Search all hys files
    files = dir([folderName, '/*.hys']);
    if numel(files)>0
        fns=arrayfun(@(x) [folderName,'/',x.name],files,'UniformOutput',false);
        [headers,datas]=cellfun(@load.loadHys,fns,'UniformOutput',false);
        hysArray=cellfun(@(x,y) load.processHys(x,y,.1,0),datas,headers);
        
        [NE,RMS] = cellfun(@(x,y) op.getNeRmsCrv(x,y,.1,0),datas,headers,'UniformOutput',false);
        fitSigmaE = cellfun(@(X,Y) median(X.*Y.*Y) ,NE,RMS);
        hysArray=arrayfun(@(x,y) setfield(x,'fitSigmaE',y),hysArray,fitSigmaE);
    else
        hysArray=[];
    end
    
end

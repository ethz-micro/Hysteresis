function allDataStat(sfn)
    
    %Close all opeened figures
    close all
    
    %Global variable to save hys between calls to this function
    global hys
    if(numel(hys)==0)
        files=dir(sfn);
        for i=1:numel(files)
            file = files(i);
            if file.isdir && file.name(1)~='.'
                hys = [hys; getHysFolder([sfn,'/', file.name])];
            end
        end
    end
   
    %Prepare every variable
    rms=arrayfun(@(x) x.model.rms,hys)';
    amplitude=arrayfun(@(x) x.model.amplitude,hys)';
    Fdiff=arrayfun(@(x) x.model.diffFlip,hys)';
    FStd=arrayfun(@(x) x.model.flipSTD,hys)';
    FlipIdx=arrayfun(@(x) x.model.flipIdx,hys)';
    FITSigma = [hys.fitSigmaE];
    diffAmp = arrayfun(@(x) x.model.diffAmp,hys)';
    ampSTD = arrayfun(@(x) x.model.ampSTD,hys)';
    V=arrayfun(@(x) x.header.MSR_VOLT,hys)';
    fields = arrayfun(@(x) load.LoadTime2Field(x.model.flipIdx,x.header.MSR_VOLT),hys);
    names = arrayfun(@(x) x.header.SOURCE_INFOS,hys,'UniformOutput',false)';
    fitSigmaESTD=[hys.fitSigmaESTD];
    found=regexp(names,'(JEOL|STM)');
    nfesem=cellfun(@isempty,found);
    ignored = FITSigma(FITSigma>200);
    ratio=Fdiff./FStd;

    %Plot STD sigma_e^2
    X=fitSigmaESTD*.01;
    figure
    histogram(X,0:.05:1)
    xlabel('STD \sigma_e^2')
    title(sprintf('STD = %.2f, median = %.2f',nanstd(X),nanmedian(X)))
    set(gca,'FontSize',20)
    
    %Plot \sigma_e^2
    figure
    histogram(FITSigma*.01,0.5:.05:2);
    xlabel('\sigma_e^2')
    title(sprintf('Median = %.2f, Std = %.2f ,%d off-scale',nanmedian(FITSigma((FITSigma<200))*.01),nanstd(FITSigma((FITSigma<200))*.01),numel(ignored)));
    set(gca,'FontSize',20)
    
    %Plot '(Theorical - minimized) Flip / Flip std'
    figure
    histogram(Fdiff./FStd,-5:.2:5)
    xlabel('(Theorical - minimized) Flip / Flip std')
    title(sprintf('STD = %.2f, mean = %.2f',nanstd(Fdiff./FStd),nanmean(Fdiff./FStd)))
    set(gca,'FontSize',20)
    
    %Plot '(Theorical - minimized) Flip / Flip std for 80V, amp>std'
    X=ratio(amplitude>rms&V==80);
    figure
    histogram(X,-5:.2:5)
    xlabel('(Theorical - minimized) Flip / Flip std for 80V, amp>std')
    title(sprintf('STD = %.2f, mean = %.2f',nanstd(X),nanmean(X)))
    set(gca,'FontSize',20)
    
    %Plot '(Theorical - minimized) Flip / Flip std for 80V, amp<std'
    X=ratio(~(amplitude>rms)&V==80);
    figure
    histogram(X,-5:.2:5)
    xlabel('(Theorical - minimized) Flip / Flip std for 80V, amp<std')
    title(sprintf('STD = %.2f, mean = %.2f',nanstd(X),nanmean(X)))
    set(gca,'FontSize',20)
    
    %Plot 'Amplitude'
    figure
    histogram(amplitude,0:0.01:0.35)
    xlabel('Amplitude')
    set(gca,'FontSize',20)
    
    %Plot 'amplitude>RMS'
    figure
    histogram(amplitude(amplitude>rms),0:0.01:0.35)
    xlabel('Amplitude')
    title('amplitude>RMS')
    set(gca,'FontSize',20)
    
    %Plot 'amplitude>RMS, NFESEM'
    figure
    histogram(amplitude(amplitude>rms & nfesem),0:0.01:0.2)
    xlabel('Amplitude')
    title('amplitude>RMS, NFESEM')
    set(gca,'FontSize',20)
    
    %Plot 'amplitude>RMS, SEMPA'
    figure
    histogram(amplitude(amplitude>rms & ~nfesem),0:0.01:0.35)
    xlabel('Amplitude')
    title('amplitude>RMS, SEMPA')
    set(gca,'FontSize',20)
    
    %Plot 'Flip Load Time [\mus]'
    figure
    histogram(FlipIdx(V==80),0:32)
    xlabel('Flip Load Time [\mus]')
    title('V_{load}=80')
    set(gca,'FontSize',20)
    
    %Plot 'V_{load}=80, amplitude>RMS'
    figure
    histogram(FlipIdx(amplitude>rms&V==80),3:16)
    xlabel('Flip Load Time [\mus]')
    title('V_{load}=80, amplitude>RMS')
    set(gca,'FontSize',20)
    
    %Plot 'V_{load}=80, amplitude>RMS, NFESEM'
    figure
    histogram(FlipIdx(amplitude>rms&V==80 & nfesem),3:16)
    xlabel('Flip Load Time [\mus]')
    set(gca,'FontSize',20)
    title('V_{load}=80, amplitude>RMS, NFESEM','FontSize',15)
    
    %Plot 'V_{load}=80, amplitude>RMS, SEMPA'
    figure
    histogram(FlipIdx(amplitude>rms&V==80 & ~nfesem),3:16)
    xlabel('Flip Load Time [\mus]')
    set(gca,'FontSize',20)
    title('V_{load}=80, amplitude>RMS, SEMPA','FontSize',15)
    
    %Plot 'Flip Field [G]'
    figure
    histogram(fields,35)
    xlabel('Flip Field [G]')
    set(gca,'FontSize',20)
    
    %Plot diffAmp./ampSTD
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
        fitSigmaESTD = cellfun(@(X,Y) nanstd(X.*Y.*Y) ,NE,RMS);
        hysArray=arrayfun(@(x,y) setfield(x,'fitSigmaE',y),hysArray,fitSigmaE);
        hysArray=arrayfun(@(x,y) setfield(x,'fitSigmaESTD',y),hysArray,fitSigmaESTD);
    else
        hysArray=[];
    end
    
end

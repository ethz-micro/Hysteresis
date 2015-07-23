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
    
    figure
    histogram(FITSigma*.01,0:.1:2);
    xlabel('\sigma_e^2')
    title(sprintf('Median = %g',nanmedian(FITSigma*.01)));
    set(gca,'FontSize',20)
    
    figure
    histogram(amplitude,0:0.01:0.35)
    xlabel('Amplitude')
    
    figure
    histogram(FlipIdx,0:30)
    xlabel('FlipIdx')
    
    figure
    histogram(FlipIdx(amplitude>rms),0:30)
    xlabel('FlipIdx')
    title('amplitude > RMS')
    
    figure
    histogram(Fdiff,-10:.5:10)
    xlabel('FlipIdx diff')
    title(sprintf('STD = %g, mean = %g',nanstd(Fdiff),nanmean(Fdiff)))
    
    figure
    histogram(Fdiff./FStd,30)
    xlabel('FlipIdx diff/FISTD')
    
    Fdiff=Fdiff(amplitude>rms);
      figure
    histogram(Fdiff,-10:.5:10)
    xlabel('FlipIdx diff')
    title(sprintf('Better? STD = %g, mean = %g',nanstd(Fdiff),nanmean(Fdiff)))
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

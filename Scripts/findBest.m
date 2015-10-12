function findBest(sfn)
    %call loadFolder in all folder inside superfolder
    %SuperFolder = 'Data';
    files=dir(sfn);
    figure
    hold all
    
    for i=numel(files):-1:1
        file = files(i);
        if file.isdir
            file.name
            sigoRMS=loadFolder([sfn,'/', file.name]);
            plot(sigoRMS,'DisplayName',file.name)
        end
    end
    
    legend(gca,'show')
    
end
function sigoRMS=loadFolder(folderName)
    
     %Search all hys files
    files = dir([folderName, '/*.hys']);
    if(numel(files)==0)
        sigoRMS=0;
    end
    
    %Loop through all sxm files
    for i=numel(files):-1:1
        
        %Load file
        fileInfo=files(i);
        fn = [folderName,'/',fileInfo.name];
        [header,data]=load.loadHys(fn);
        hys=load.processHys(data,header,0.2,0);
        sigoRMS(i)=hys.model.amplitude./hys.model.rms;       
    end
end

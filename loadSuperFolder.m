function loadSuperFolder(sfn)
    %call loadFolder in all folder inside superfolder
    %SuperFolder = 'Data/March';
    files=dir(sfn);
    
    
    for i=numel(files)-2:numel(files)
        file = files(i);
        if file.isdir
            file.name
            loadFolder([sfn,'/', file.name]);
        end
    end
    
end
function loadFolder(folderName)
    
    
    
    %Create a text folder
    txtFolder = [folderName, '/text/'];
    mkdir(txtFolder);
    
     %Search all hys files
    files = dir([folderName, '/*.hys']);
    
    %Loop through all sxm files
    for i=1:numel(files)
        
        %Load file
        fileInfo=files(i);
        fn = [folderName,'/',fileInfo.name];
        
        %prepare image name
        A = strsplit(fileInfo.name,'.');
        imgNbr = A{1};
        rootImgName=[txtFolder, imgNbr];
        bin2ascii(fn,rootImgName);       
    end
end
function bin2ascii(InputFN,BaseOutputFN)

%Infos
S=1;


%Load
[header,data]=loadHys(InputFN);
hysteresis=processHys(data,header,S,0);

OutputFN=sprintf('%s-Q=%.2f.txt',BaseOutputFN,hysteresis.Q);
%Prepare datas to wite
data=cat(2,hysteresis.time,mean(hysteresis.fallingLines,2),mean(hysteresis.risingLines,2));
%Write header and data
dlmwrite(OutputFN,header.RAWTXT,'');
dlmwrite(OutputFN,data,'-append');
end
function folder2txt(folderName,varargin)
    
    %Shermann factor
    S=1;
    if nargin>1
        S=varargin{1};
    end
    
    %remove / at the end of the folder name
    if folderName(end)=='/'
        folderName=folderName(1:end-1);
    end
    
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
        
        %Write the file
        bin2ascii(fn,rootImgName,S);       
    end
end
function bin2ascii(InputFN,BaseOutputFN,S)
%Load
[header,data]=load.loadHys(InputFN);
hysteresis=load.processHys(data,header,S,0);

OutputFN=sprintf('%s-Q=%.2f.txt',BaseOutputFN,hysteresis.Q);
%Prepare datas to wite
data=cat(2,hysteresis.time,mean(hysteresis.fallingLines,2),mean(hysteresis.risingLines,2));
%Write header and data
dlmwrite(OutputFN,header.RAWTXT,'');
dlmwrite(OutputFN,data,'-append');
end
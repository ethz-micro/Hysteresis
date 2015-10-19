function recursiveFolderFunction(folderName, fctn)
    
    %call loadFolder in all folder inside superfolder
    files=dir(folderName);
    
    
    for i=numel(files)-2:numel(files)
        file = files(i);
        if file.isdir
            file.name
            fctn([sfn,'/', file.name]);
        end
    end
end
function PlotRMSFolders(sfn)
    %call loadFolder in all folder inside superfolder
    %SuperFolder = 'Data/March';
    files=dir(sfn);
    
    
    A=[];
    B=[];
    Amp=[];
    
    for i=1:numel(files)
        file = files(i);
        
        if file.isdir && file.name(1)~='.'
            
            [f,q,a]=loadFolder([sfn,'/', file.name],file.name);
            A=[A,f];
            B=[B,q];
            Amp=[Amp,a];
            
            
        end
        
    end
    
    idx=(abs(B-1)<.15);
    
    figure
    histogram(A(idx),200);
    xlabel('Fit Value')
    figure
    plot(B(~idx),A(~idx),'x')
    
    figure
    histogram(Amp(idx),200);
    xlabel('Fit Value')
    
    
end
function [FITP,Q,ampl] = loadFolder(folderName,name)
    persistent loadedData
    
    fieldName=folderName;
    fieldName(fieldName=='/')=[];
    %Search all hys files
    files = dir([folderName, '/*.hys']);
    if numel(files)>0
        if isfield(loadedData,fieldName)
            headers=loadedData.(fieldName).headers;
            datas=loadedData.(fieldName).datas;
        else
            
            fns=arrayfun(@(x) [folderName,'/',x.name],files,'UniformOutput',false);
            [headers,datas]=cellfun(@loadHys,fns,'UniformOutput',false);
            
            loadedData.(fieldName).headers=headers;
            loadedData.(fieldName).datas=datas;
        end
        
        
        [NE,RMS,FIT,hys]=RMSvsNBRE(datas,headers,0.1,0);
        FITP=[FIT.p1];
        Q=[hys.Q];
        ampl=arrayfun(@(x) x.model.amplitude,hys)';
        rms=arrayfun(@(x) x.model.rms,hys)';
        
        figure
        plot(FITP,'x--');%,'DisplayName',name);
        hold all
        plot(Q,'x--')
        plot(ampl,'x--')
        plot(rms,'x--')
        title(name)
        xlabel('index')
        ylabel('Fit Value')
        %legend(gca,'show')
        
        figure
        hold all
        for j=1:numel(NE)
            if (abs(Q(j)-1)<.15)%Keep 15% around Q
                plot(NE{j}.^-0.5,RMS{j},'x-','DisplayName',sprintf('%d',j));
            end
        end
        legend(gca,'show')
        xlabel('Nbr e- \^(-.5)')
        ylabel('RMS')
        
        
    else
        FITP=[];
        Q=[];
        ampl=[];
    end
    
end
